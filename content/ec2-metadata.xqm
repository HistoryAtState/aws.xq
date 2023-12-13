xquery version "3.1";

(:~
 : Retrieve temporary credentials from the AWS metadata API
 :
 : @author Joe Wicentowski
 : @see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-metadata-v2-how-it-works.html
 :)

module namespace ec2-metadata = "http://history.state.gov/ns/xquery/aws/ec2/metadata";

declare namespace http = "http://expath.org/ns/http-client";

(: Keep STS credentials valid for 5 minutes :)
declare variable $ec2-metadata:credentials-ttl-seconds := 300;
declare variable $ec2-metadata:cache-name := "ec2-metadata";
declare variable $ec2-metadata:credentials-key := "credentials";


declare function ec2-metadata:get-credentials() {
    ec2-metadata:get-credentials($ec2-metadata:credentials-ttl-seconds)
};

declare function ec2-metadata:get-credentials($ttl-seconds as xs:integer) {
    let $cached-credentials := cache:get($ec2-metadata:cache-name, $ec2-metadata:credentials-key)
    return
        if (exists($cached-credentials)) then
            if (current-dateTime() ge xs:dateTime($cached-credentials?Expiration)) then
                (
                    cache:clear($ec2-metadata:cache-name),
                    ec2-metadata:get-credentials($ttl-seconds)
                )
            else
                $cached-credentials
        else
            let $get-token-url := "http://169.254.169.254/latest/api/token"
            let $get-token-request := 
                <http:request href="{$get-token-url}" method="PUT">
                    <http:header name="x-aws-ec2-metadata-token-ttl-seconds" value="{$ttl-seconds}"/>
                </http:request>
            let $token := http:send-request($get-token-request)[2]
            let $get-security-credentials-url := "http://169.254.169.254/latest/meta-data/iam/security-credentials"
            let $get-security-credentials-request := 
                <http:request href="{$get-security-credentials-url}" method="GET">
                    <http:header name="X-aws-ec2-metadata-token" value="{$token}"/>
                </http:request>
            let $security-credentials := http:send-request($get-security-credentials-request)[2]
            let $get-temporary-credential-url := "http://169.254.169.254/latest/meta-data/iam/security-credentials/" || $security-credentials
            let $temporary-credentials-request := 
                <http:request href="{$get-temporary-credential-url}" method="GET">
                    <http:header name="X-aws-ec2-metadata-token" value="{$token}"/>
                </http:request>
            let $credentials := http:send-request($temporary-credentials-request)[2] => parse-json()
            let $expire-ms := (min(($ttl-seconds, 5)) - 5) * 1000 (: expire cache 5 seconds before credentials actually expire :)
            let $cache-create := 
                cache:create(
                    $ec2-metadata:cache-name, 
                    map {
                        "expireAfterAccess": $expire-ms, 
                        "expireAfterWrite": $expire-ms, 
                        (: expireAfterWrite to be released with eXist 6.2.1 - see https://github.com/eXist-db/exist/pull/4975
                         : TODO switch from expireAfterAccess to expireAfterWrite when we adopt this release :)
                        "permissions": 
                            map { 
                                "put-group": "dba", 
                                "get-group": "dba", 
                                "remove-group": "dba", 
                                "clear-group": "dba"
                            }
                    }
                ) 
            let $cache-put := cache:put($ec2-metadata:cache-name, $ec2-metadata:credentials-key, $credentials) 
            return 
                $credentials
};
