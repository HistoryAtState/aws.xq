xquery version "3.1";

(:~
 : Helpers for constructing and sending signed requests to the AWS Textract API.
 :
 : Textract uses AWS JSON 1.1 RPC: all operations are POST / with an X-Amz-Target
 : header identifying the operation and a JSON body. Responses are JSON; errors
 : are JSON with a "__type" field.
 :
 : @see https://docs.aws.amazon.com/textract/latest/dg/API_Operations.html
 :)
module namespace textract-request = "http://history.state.gov/ns/xquery/aws/textract/request";

import module namespace aws-request = "http://history.state.gov/ns/xquery/aws/request";
import module namespace aws-utils = "http://history.state.gov/ns/xquery/aws/utils";
import module namespace ec2-metadata = "http://history.state.gov/ns/xquery/aws/ec2/metadata";

import module namespace crypto = "http://expath.org/ns/crypto";

declare namespace http = "http://expath.org/ns/http-client";

declare variable $textract-request:service := "textract";
declare variable $textract-request:content-type := "application/x-amz-json-1.1";

(:~
 : Build the endpoint URL for a given region.
 :)
declare function textract-request:endpoint($region as xs:string) as xs:string {
    "https://textract." || $region || ".amazonaws.com/"
};

(:~
 : Build a signed Textract request ready for http:send-request.
 :
 : @param $region   AWS region (e.g. "us-east-1")
 : @param $target   Textract operation name without the "Textract." prefix
 :                  (e.g. "StartDocumentAnalysis", "GetDocumentAnalysis")
 : @param $payload  operation payload as a map that will be serialized to JSON
 : @return          a signed http:request element
 :)
declare function textract-request:create(
    $region as xs:string,
    $target as xs:string,
    $payload as map(*)
) as element(http:request) {
    let $credentials := ec2-metadata:get-credentials()
    let $body-text := serialize($payload, map {
        "method": "json",
        "indent": false()
    })
    let $body-hash := crypto:hash($body-text, "sha256", "hex")
    let $base :=
        <http:request method="POST"
                      href="{textract-request:endpoint($region)}"
                      http-version="1.1"
                      chunked="false">
            <http:header name="x-amz-date" value="{aws-utils:x-amz-date()}"/>
            <http:header name="Date" value="{aws-utils:http-date()}"/>
            <http:header name="X-Amz-Target" value="Textract.{$target}"/>
            <http:header name="Content-Type" value="{$textract-request:content-type}"/>
            <http:header name="x-amz-content-sha256" value="{$body-hash}"/>
            {
                if (exists($credentials?Token) and string-length($credentials?Token) gt 0) then
                    <http:header name="X-Amz-Security-Token" value="{$credentials?Token}"/>
                else
                    ()
            }
            <http:body media-type="{$textract-request:content-type}" method="text">{$body-text}</http:body>
        </http:request>
    return
        aws-request:sign-v4(
            $base,
            $textract-request:service,
            $region,
            $credentials?AccessKeyId,
            $credentials?SecretAccessKey
        )
};

(:~
 : Send a Textract request and parse the JSON response.
 :
 : On HTTP 200, returns the response body parsed as a map. On any other status,
 : throws an error with a QName derived from the Textract "__type" field
 : (e.g. InvalidS3ObjectException) and the decoded error body as the error object.
 :
 : @param $request a signed http:request element from textract-request:create()
 : @return         the parsed JSON response body as a map
 :)
declare function textract-request:send($request as element(http:request)) as map(*) {
    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    let $body := $response[2]
    let $body-string :=
        typeswitch ($body)
            case xs:base64Binary return util:base64-decode($body)
            case xs:string return $body
            default return string($body)
    let $parsed :=
        try {
            parse-json($body-string)
        } catch * {
            map { "raw": $body-string }
        }
    return
        if ($status = 200) then
            $parsed
        else
            let $type := ($parsed?__type, "TextractError")[1]
            let $local-name := tokenize($type, "#")[last()] => replace("[^A-Za-z0-9_]", "_")
            let $qname := QName("http://history.state.gov/ns/xquery/aws/textract/error", $local-name)
            let $message :=
                "Textract " || string($request/http:header[@name = "X-Amz-Target"]/@value) ||
                " failed with HTTP " || $status || ": " ||
                ($parsed?Message, $parsed?message, $body-string)[1]
            return
                error($qname, $message, $parsed)
};
