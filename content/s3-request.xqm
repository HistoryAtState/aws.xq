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
 : Original namespace URI for this module: "http://www.xquery.co.uk/modules/connectors/aws/s3/request"
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see http://docs.amazonwebservices.com/AmazonS3/2006-03-01/API/index.html?ErrorResponses.html
 : @see https://github.com/dknochen/xaws
 :)
module namespace s3-request = "http://history.state.gov/ns/xquery/aws/s3/request";

import module namespace aws-utils = "http://history.state.gov/ns/xquery/aws/utils";
import module namespace aws-request = "http://history.state.gov/ns/xquery/aws/request";
import module namespace s3-error = "http://history.state.gov/ns/xquery/aws/s3/error";

declare namespace http = "http://expath.org/ns/http-client";

(:~
 : send an http request and return the response which is usually a pair of two items: One item containing the response
 : headers, status code,... and one item representing the response body (if any).
 :
 : @return the http response
 :)
declare function s3-request:send($request as element(http:request)) as item()* {
    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    return
        if ($status = (200, 204)) then
            $response
        else
            s3-error:throw($status, $response)
};


(:~
 : add an acl grant to the create request
 : 
 :)
declare function s3-request:add-acl-everybody(
    $request as element(http:request),
    $acl as xs:string?
) {
    let $acl-header := <http:header name="x-amz-acl" value="{$acl}"/>
    return
        if (exists($acl)) then
            (: insert node $acl-header as first into $request :)
            element {node-name($request)} {$request/@*, $acl-header, $request/*}
        else
            $request
};


(:~
 : add an metadata to the request
 : 
 :)
declare function s3-request:add-metadata(
    $request as element(http:request),
    $metadata as element()*
) {
    for $meta in $metadata
    let $name := concat("x-amz-meta-", $meta/local-name())
    let $value := string($meta/text())
    let $meta-header := <http:header name="{$name}" value="{$value}"/>
    return
        (:insert node $meta-header as first into $request:)
        element {node-name($request)} {$request/@*, $meta-header, $request/*}
};


(:~
 : Add reduced-redundancy flag to the request. This function simply turnes the reduced redundancy on by
 : passing the header x-amz-storage-class=REDUCED_REDUNDANCY.
 : 
 :)
declare function s3-request:add-reduced-redundancy($request as element(http:request)) {
    let $name := "x-amz-storage-class"
    let $value := "REDUCED_REDUNDANCY"
    let $meta-header := <http:header name="{$name}" value="{$value}"/>
    return
        (:insert node $meta-header as first into $request:)
        element {node-name($request)} {$request/@*, $meta-header, $request/*}
};
