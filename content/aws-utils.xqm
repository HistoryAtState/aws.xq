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
 : Original namespace URI for this module: "http://www.xquery.co.uk/modules/connectors/aws/helpers/utils"
 : 
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see https://github.com/dknochen/xaws
 :)
module namespace aws-utils = "http://history.state.gov/ns/xquery/aws/utils";

import module namespace functx = "http://www.functx.com";

(:~
 : Generate a date formated according to rfc822. Example: Fri, 15 Oct 10
 :
 : cf: http://www.faqs.org/rfcs/rfc822.html
 :
 : @return rfc822 formated date as xs:string
:)
declare function aws-utils:http-date() as xs:string {
    (: TODO replace day of week with [FNn,*-3] when https://github.com/eXist-db/exist/issues/1878 is resolved :)
    let $day-of-week := substring(functx:day-of-week-name-en(util:system-date()), 1, 3)
    let $rest := 
        format-dateTime(adjust-dateTime-to-timezone(util:system-dateTime(), xs:dayTimeDuration("PT0H")), "[D] [MNn] [Y0001] [H01]:[m01]:[s01] [ZN]", "en", (), "US")
    return
        concat($day-of-week, ", ", $rest)
};

(:~
 : Generate a date formatted "YYYYMMDD'T'HHMMSS'Z'" for x-amz-date required by AWS Signature Version 4. Example: 20150830T123600Z
 :
 : @see https://docs.aws.amazon.com/general/latest/gr/sigv4-date-handling.html
 : @return x-amz-date formatted dateTime as xs:string
:)
declare function aws-utils:x-amz-date() as xs:string {
    format-dateTime(adjust-dateTime-to-timezone(util:system-dateTime(), xs:dayTimeDuration("PT0H")), "[Y0001][M01][D01]T[H01][m01][s01][ZZ]")
};

(:~
 : Generate a date formatted "YYYYMMDD" for date value required by AWS Signature Version 4. Example: 20150830
 :
 : @see https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html
 : @return YYYYMMDD formatted date as xs:string
:)
declare function aws-utils:yyyymmdd-date() as xs:string {
    format-date(adjust-date-to-timezone(util:system-date(), xs:dayTimeDuration("PT0H")), "[Y0001][M01][D01]")
};
