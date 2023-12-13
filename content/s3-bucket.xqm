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
 : Original namespace URI for this module: "http://www.xquery.me/modules/xaws/s3/bucket"
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see https://github.com/dknochen/xaws
 :)

module namespace s3-bucket = "http://history.state.gov/ns/xquery/aws/s3/bucket";

import module namespace aws-request = "http://history.state.gov/ns/xquery/aws/request";
import module namespace ec2-metadata = "http://history.state.gov/ns/xquery/aws/ec2/metadata";
import module namespace s3-request = "http://history.state.gov/ns/xquery/aws/s3/request";

(:
 : Create and update binaries in S3 using STS tokens
 : 
 : Adapted from bucket:list()
:)

(: example result
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <Name>static.history.state.gov.v3</Name>
    <Prefix/>
    <Marker/>
    <MaxKeys>1000</MaxKeys>
    <Delimiter>/</Delimiter>
    <IsTruncated>false</IsTruncated>
    <Contents>
        <Key>robots.txt</Key>
        <LastModified>2023-02-18T15:29:54.000Z</LastModified>
        <ETag>"c01eb66a3fe2ce453baf386ef773e933"</ETag>
        <Size>59</Size>
        <Owner>
            <ID>b88fca9d58e24e15e1c1bdf8cde052bcaebff95809e96d687e531abcd0a5a329</ID>
            <DisplayName>awsaccounts+se-aws-mod-commercial-fsi-oh-hist-st-gov-prd</DisplayName>
        </Owner>
        <StorageClass>STANDARD</StorageClass>
    </Contents>
    <CommonPrefixes>
        <Prefix>about/</Prefix>
    </CommonPrefixes>
    <CommonPrefixes>
        <Prefix>buildings/</Prefix>
    </CommonPrefixes>
    ...
</ListBucketResult>
:)
declare function s3-bucket:list(
    $bucket as xs:string,
    $delimiter as xs:string?,
    $marker as xs:string?,
    $max-keys as xs:string?,
    $prefix as xs:string?
) as item()* {
    let $credentials := ec2-metadata:get-credentials()
    let $href as xs:string := concat("https://s3.amazonaws.com/", $bucket, "/")
    let $parameters := 
        (
            <parameter name="X-Amz-Security-Token" value="{$credentials?Token}" />,
            if (exists($delimiter)) then <parameter name="delimiter" value="{$delimiter}"/> else (),
            if (exists($marker)) then <parameter name="marker" value="{$marker}"/> else (),
            if (exists($max-keys)) then <parameter name="max-keys" value="{$max-keys}"/> else (),
            if (exists($prefix)) then <parameter name="prefix" value="{$prefix}"/> else ()
        )
    let $request := aws-request:create("GET", $href, $parameters)
    let $signed-request := aws-request:sign($request, $bucket, "", $credentials?AccessKeyId, $credentials?SecretAccessKey)
    return 
        s3-request:send($signed-request)
};
