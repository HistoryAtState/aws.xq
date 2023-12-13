(:
 : Copyright 2010 XQuery.co.uk
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
:)
xquery version "3.1";

(:~
 : Adapted from Klaus Wichmann's xaws library for use with eXist
 :
 : Original namespace URI for this module: "http://www.xquery.co.uk/modules/connectors/aws/helpers/error"
 : 
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see https://github.com/dknochen/xaws
 :)
module namespace aws-error = "http://history.state.gov/ns/xquery/aws/error";

(: locales :)
declare variable $aws-error:LOCALE_EN as xs:string := "en_EN";

declare variable $aws-error:LOCALE_DEFAULT as xs:string := $aws-error:LOCALE_EN;

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $aws-error:CONNECTION_FAILED as xs:QName := xs:QName("error:CONNECTION_FAILED");

(: Error messages :)
declare variable $aws-error:messages :=
    <error:messages>
        <error:CONNECTION_FAILED locale="{$aws-error:LOCALE_EN}" param="0" http-code="-1" code="CONNECTION_FAILED" http-error="-1 Request Failed">
            The HTTP/HTTPS connection of the http-client failed. Please, check connectability and/or proxy settings if any.
        </error:CONNECTION_FAILED>
    </error:messages>
;


(:~
 :  Throws an error with the default locale.
 : 
:)
declare function aws-error:throw(
    $http-code as xs:double,
    $http-response as item()*,
    $error-messages as element()
) {
    aws-error:throw($http-code, $http-response, $aws-error:LOCALE_DEFAULT, $error-messages)
};


declare function aws-error:throw(
    $http-code as xs:double,
    $http-response as item()*,
    $locale as xs:string,
    $error-messages as element()
) {
    let $error-obj :=
        if (empty($http-response[2])) then
            $http-response[1]
        else
            typeswitch ($http-response[2])
                case $resp as document-node()
                    return
                        if ($http-response[2]/Error) then
                            $http-response[2]/Error
                        else
                            $http-response[2]
                case $resp as xs:base64Binary
                    return
                        util:base64-decode($http-response[2])
                default $resp
                    return
                        $http-response[2]
    let $error-code :=
        if ($http-code eq -1) then
            "CONNECTION_FAILED"
        else
            $error-obj/Code/text()
    let $message-node as element()? :=
        let $temp := aws-error:get-message($error-code, $http-code, $locale, $error-messages)
        return
            if ($temp) then
                $temp
            else
                aws-error:get-message($error-code, $http-code, $locale, $aws-error:messages)
    let $description as xs:string :=
        if ($message-node) then
            concat(
                "AWS Error returned: ",
                let $http-error := $message-node/@http-error
                return
                    if ($http-error) then
                        concat(string($http-error), ". Reason: ")
                    else
                        "",
                $message-node/text()
            )
        else
            "An unexpected error happened. Please, investigate the error object for more details."
    let $error-qname as xs:QName :=
        if ($message-node) then
            node-name($message-node)
        else
            xs:QName("error:UNEXPECTED_ERROR")
    let $eo := serialize($error-obj)
    return
        error($error-qname, $description, trace($error-obj, "ERROROBJ: "))
};


declare function aws-error:get-message(
    $error-code as xs:string?,
    $http-code as xs:double,
    $locale as xs:string,
    $error-messages as element()
) as element()? {
    let $temp-node := $error-messages/element()[@code eq $error-code][@locale eq $locale]
    let $node :=
        if ($temp-node) then
            $temp-node
        else
            let $temp-node := $error-messages/element()[number(@http-code) eq $http-code][@locale eq $locale]
            return
                if (count($temp-node) eq 1) then
                    $temp-node
                else
                    if ($locale eq $aws-error:LOCALE_DEFAULT) then
                        ()
                    else
                        aws-error:get-message($error-code, $http-code, $aws-error:LOCALE_DEFAULT, $error-messages)
    return
        $node
};


declare function aws-error:to-string($code, $message, $obj) as xs:string {
    let $msgs :=
        (
            concat("Errorcode: ", $code),
            concat("Errormessage: ", $message),
            if ($obj) then
                concat("Errorobject: ", serialize($obj))
            else
                "Errorobject: ()"
        )
    return
        string-join($msgs, "&#10;")
};
