(:
 : Copyright 2010 XQuery.me
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
 : Original namespace URI for this module: "http://www.xquery.me/modules/xaws/s3/object"
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see https://github.com/dknochen/xaws
 :)

module namespace s3-object = "http://history.state.gov/ns/xquery/aws/s3/object";

import module namespace aws-request = "http://history.state.gov/ns/xquery/aws/request";
import module namespace ec2-metadata = "http://history.state.gov/ns/xquery/aws/ec2/metadata";
import module namespace s3-request = "http://history.state.gov/ns/xquery/aws/s3/request";

(:
 : Create and update binaries in S3 using STS tokens
 : 
 : Adapted from object:write()
:)
declare function s3-object:put(
    $bucket as xs:string, 
    $filename as xs:string, 
    $binary as xs:base64Binary
) {
    let $credentials := ec2-metadata:get-credentials()
    let $href := concat("https://s3.amazonaws.com/", $bucket, "/", $filename)
    let $parameters := <parameter name="X-Amz-Security-Token" value="{$credentials?Token}"/>
    let $file-extension := replace($filename, "^.+?(\.[a-z]+)$", "$1")
    let $content-type := 
        switch ($file-extension)
            case ".epub" return "application/epub+zip"
            case ".jpg"  return "image/jpeg"
            case ".mobi" return "application/x-mobipocket-ebook"
            case ".pdf"  return "application/pdf"
            case ".png"  return "image/png"
            case ".tif"
            case ".tiff" return "image/tiff"
            case ".txt"  return "text/plain"
            case ".xml"  return "application/xml"
            default return "binary/octet-stream"
    let $request := 
        aws-request:create("PUT", $href, $parameters) 
        => aws-request:add-content-binary($binary, $content-type)
    let $signed-request := aws-request:sign($request, $bucket, $filename, $credentials?AccessKeyId, $credentials?SecretAccessKey)
    return
        s3-request:send($signed-request)
};

(:
 : Delete binaries in S3 using STS tokens
 : 
 : Adapted from object:delete()
:)
declare function s3-object:delete(
    $bucket as xs:string, 
    $filename as xs:string
) {
    let $credentials := ec2-metadata:get-credentials()
    let $href := concat("https://s3.amazonaws.com/", $bucket, "/", $filename)
    let $parameters := <parameter name="X-Amz-Security-Token" value="{$credentials?Token}" />
    let $request := aws-request:create("DELETE", $href, $parameters)
    let $signed-request := aws-request:sign($request, $bucket, $filename, $credentials?AccessKeyId, $credentials?SecretAccessKey)
    return
        s3-request:send($signed-request)
};
