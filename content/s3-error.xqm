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
 : Implementation of Error Messages returned from S3. 
 :
 : Adapted from Klaus Wichmann's xaws library for use with eXist
 : 
 : Original namespace URI for this module: "http://www.xquery.co.uk/modules/connectors/aws/s3/error"
 : 
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @contributor Joe Wicentowski
 : @see http://docs.amazonwebservices.com/AmazonS3/2006-03-01/API/index.html?ErrorResponses.html
 : @see https://github.com/dknochen/xaws
 :)
module namespace s3-error = "http://history.state.gov/ns/xquery/aws/s3/error";

import module namespace aws-error = "http://history.state.gov/ns/xquery/aws/error";

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $s3-error:ACCESSDENIED := xs:QName("s3-error:ACCESSDENIED");
declare variable $s3-error:ACCOUNTPROBLEM := xs:QName("s3-error:ACCOUNTPROBLEM");
declare variable $s3-error:AMBIGUOUSGRANTBYEMAILADDRESS := xs:QName("s3-error:AMBIGUOUSGRANTBYEMAILADDRESS");
declare variable $s3-error:BADDIGEST := xs:QName("s3-error:BADDIGEST");
declare variable $s3-error:BUCKETALREADYEXISTS := xs:QName("s3-error:BUCKETALREADYEXISTS");
declare variable $s3-error:BUCKETALREADYOWNEDBYYOU := xs:QName("s3-error:BUCKETALREADYOWNEDBYYOU");
declare variable $s3-error:BUCKETNOTEMPTY := xs:QName("s3-error:BUCKETNOTEMPTY");
declare variable $s3-error:CREDENTIALSNOTSUPPORTED := xs:QName("s3-error:CREDENTIALSNOTSUPPORTED");
declare variable $s3-error:CROSSLOCATIONLOGGINGPROHIBITED := xs:QName("s3-error:CROSSLOCATIONLOGGINGPROHIBITED");
declare variable $s3-error:ENTITYTOOSMALL := xs:QName("s3-error:ENTITYTOOSMALL");
declare variable $s3-error:ENTITYTOOLARGE := xs:QName("s3-error:ENTITYTOOLARGE");
declare variable $s3-error:EXPIREDTOKEN := xs:QName("s3-error:EXPIREDTOKEN");
declare variable $s3-error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION := xs:QName("s3-error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION");
declare variable $s3-error:INCOMPLETEBODY := xs:QName("s3-error:INCOMPLETEBODY");
declare variable $s3-error:INCORRECTNUMBEROFFILESINPOSTREQUEST := xs:QName("s3-error:INCORRECTNUMBEROFFILESINPOSTREQUEST");
declare variable $s3-error:INLINEDATATOOLARGE := xs:QName("s3-error:INLINEDATATOOLARGE");
declare variable $s3-error:INTERNALERROR := xs:QName("s3-error:INTERNALERROR");
declare variable $s3-error:INVALIDACCESSKEYID := xs:QName("s3-error:INVALIDACCESSKEYID");
declare variable $s3-error:INVALIDADDRESSINGHEADER := xs:QName("s3-error:INVALIDADDRESSINGHEADER");
declare variable $s3-error:INVALIDARGUMENT := xs:QName("s3-error:INVALIDARGUMENT");
declare variable $s3-error:INVALIDBUCKETNAME := xs:QName("s3-error:INVALIDBUCKETNAME");
declare variable $s3-error:INVALIDDIGEST := xs:QName("s3-error:INVALIDDIGEST");
declare variable $s3-error:INVALIDLOCATIONCONSTRAINT := xs:QName("s3-error:INVALIDLOCATIONCONSTRAINT");
declare variable $s3-error:INVALIDPAYER := xs:QName("s3-error:INVALIDPAYER");
declare variable $s3-error:INVALIDPOLICYDOCUMENT := xs:QName("s3-error:INVALIDPOLICYDOCUMENT");
declare variable $s3-error:INVALIDRANGE := xs:QName("s3-error:INVALIDRANGE");
declare variable $s3-error:INVALIDSECURITY := xs:QName("s3-error:INVALIDSECURITY");
declare variable $s3-error:INVALIDSOAPREQUEST := xs:QName("s3-error:INVALIDSOAPREQUEST");
declare variable $s3-error:INVALIDSTORAGECLASS := xs:QName("s3-error:INVALIDSTORAGECLASS");
declare variable $s3-error:INVALIDTARGETBUCKETFORLOGGING := xs:QName("s3-error:INVALIDTARGETBUCKETFORLOGGING");
declare variable $s3-error:INVALIDTOKEN := xs:QName("s3-error:INVALIDTOKEN");
declare variable $s3-error:INVALIDURI := xs:QName("s3-error:INVALIDURI");
declare variable $s3-error:KEYTOOLONG := xs:QName("s3-error:KEYTOOLONG");
declare variable $s3-error:MALFORMEDACLERROR := xs:QName("s3-error:MALFORMEDACLERROR");
declare variable $s3-error:MALFORMEDPOSTREQUEST := xs:QName("s3-error:MALFORMEDPOSTREQUEST");
declare variable $s3-error:MALFORMEDXML := xs:QName("s3-error:MALFORMEDXML");
declare variable $s3-error:MAXMESSAGELENGTHEXCEEDED := xs:QName("s3-error:MAXMESSAGELENGTHEXCEEDED");
declare variable $s3-error:MAXPOSTPREDATALENGTHEXCEEDEDERROR := xs:QName("s3-error:MAXPOSTPREDATALENGTHEXCEEDEDERROR");
declare variable $s3-error:METADATATOOLARGE := xs:QName("s3-error:METADATATOOLARGE");
declare variable $s3-error:METHODNOTALLOWED := xs:QName("s3-error:METHODNOTALLOWED");
declare variable $s3-error:MISSINGATTACHMENT := xs:QName("s3-error:MISSINGATTACHMENT");
declare variable $s3-error:MISSINGCONTENTLENGTH := xs:QName("s3-error:MISSINGCONTENTLENGTH");
declare variable $s3-error:MISSINGREQUESTBODYERROR := xs:QName("s3-error:MISSINGREQUESTBODYERROR");
declare variable $s3-error:MISSINGSECURITYELEMENT := xs:QName("s3-error:MISSINGSECURITYELEMENT");
declare variable $s3-error:MISSINGSECURITYHEADER := xs:QName("s3-error:MISSINGSECURITYHEADER");
declare variable $s3-error:NOLOGGINGSTATUSFORKEY := xs:QName("s3-error:NOLOGGINGSTATUSFORKEY");
declare variable $s3-error:NOSUCHBUCKET := xs:QName("s3-error:NOSUCHBUCKET");
declare variable $s3-error:NOSUCHKEY := xs:QName("s3-error:NOSUCHKEY");
declare variable $s3-error:NOSUCHVERSION := xs:QName("s3-error:NOSUCHVERSION");
declare variable $s3-error:NOTIMPLEMENTED := xs:QName("s3-error:NOTIMPLEMENTED");
declare variable $s3-error:NOTSIGNEDUP := xs:QName("s3-error:NOTSIGNEDUP");
declare variable $s3-error:OPERATIONABORTED := xs:QName("s3-error:OPERATIONABORTED");
declare variable $s3-error:PERMANENTREDIRECT := xs:QName("s3-error:PERMANENTREDIRECT");
declare variable $s3-error:PRECONDITIONFAILED := xs:QName("s3-error:PRECONDITIONFAILED");
declare variable $s3-error:REDIRECT := xs:QName("s3-error:REDIRECT");
declare variable $s3-error:REQUESTISNOTMULTIPARTCONTENT := xs:QName("s3-error:REQUESTISNOTMULTIPARTCONTENT");
declare variable $s3-error:REQUESTTIMEOUT := xs:QName("s3-error:REQUESTTIMEOUT");
declare variable $s3-error:REQUESTTIMETOOSKEWED := xs:QName("s3-error:REQUESTTIMETOOSKEWED");
declare variable $s3-error:REQUESTTORRENTOFBUCKETERROR := xs:QName("s3-error:REQUESTTORRENTOFBUCKETERROR");
declare variable $s3-error:SIGNATUREDOESNOTMATCH := xs:QName("s3-error:SIGNATUREDOESNOTMATCH");
declare variable $s3-error:SLOWDOWN := xs:QName("s3-error:SLOWDOWN");
declare variable $s3-error:TEMPORARYREDIRECT := xs:QName("s3-error:TEMPORARYREDIRECT");
declare variable $s3-error:TOKENREFRESHREQUIRED := xs:QName("s3-error:TOKENREFRESHREQUIRED");
declare variable $s3-error:TOOMANYBUCKETS := xs:QName("s3-error:TOOMANYBUCKETS");
declare variable $s3-error:UNEXPECTEDCONTENT := xs:QName("s3-error:UNEXPECTEDCONTENT");
declare variable $s3-error:UNRESOLVABLEGRANTBYEMAILADDRESS := xs:QName("s3-error:UNRESOLVABLEGRANTBYEMAILADDRESS");
declare variable $s3-error:USERKEYMUSTBESPECIFIED := xs:QName("s3-error:USERKEYMUSTBESPECIFIED");

(: Error messages :)
declare variable $s3-error:messages :=
    <s3-error:messages>
        <s3-error:ACCESSDENIED locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="AccessDenied" http-error="403 Forbidden">Access Denied</s3-error:ACCESSDENIED>
        <s3-error:ACCOUNTPROBLEM locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="AccountProblem" http-error="403 Forbidden">There is a problem with your AWS account that prevents the operation from completing successfully. Please use Contact Us .</s3-error:ACCOUNTPROBLEM>
        <s3-error:AMBIGUOUSGRANTBYEMAILADDRESS locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="AmbiguousGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided is associated with more than one account.</s3-error:AMBIGUOUSGRANTBYEMAILADDRESS>
        <s3-error:BADDIGEST locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="BadDigest" http-error="400 Bad Request">The Content-MD5 you specified did not match what we received.</s3-error:BADDIGEST>
        <s3-error:BUCKETALREADYEXISTS locale="{$aws-error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyExists" http-error="409 Conflict">The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.</s3-error:BUCKETALREADYEXISTS>
        <s3-error:BUCKETALREADYOWNEDBYYOU locale="{$aws-error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyOwnedByYou" http-error="409 Conflict">Your previous request to create the named bucket succeeded and you already own it.</s3-error:BUCKETALREADYOWNEDBYYOU>
        <s3-error:BUCKETNOTEMPTY locale="{$aws-error:LOCALE_EN}" param="0" http-code="409" code="BucketNotEmpty" http-error="409 Conflict">The bucket you tried to delete is not empty.</s3-error:BUCKETNOTEMPTY>
        <s3-error:CREDENTIALSNOTSUPPORTED locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="CredentialsNotSupported" http-error="400 Bad Request">This request does not support credentials.</s3-error:CREDENTIALSNOTSUPPORTED>
        <s3-error:CROSSLOCATIONLOGGINGPROHIBITED locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="CrossLocationLoggingProhibited" http-error="403 Forbidden">Cross location logging not allowed. Buckets in one geographic location cannot log information to a bucket in another location.</s3-error:CROSSLOCATIONLOGGINGPROHIBITED>
        <s3-error:ENTITYTOOSMALL locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="EntityTooSmall" http-error="400 Bad Request">Your proposed upload is smaller than the minimum allowed object size.</s3-error:ENTITYTOOSMALL>
        <s3-error:ENTITYTOOLARGE locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="EntityTooLarge" http-error="400 Bad Request">Your proposed upload exceeds the maximum allowed object size.</s3-error:ENTITYTOOLARGE>
        <s3-error:EXPIREDTOKEN locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="ExpiredToken" http-error="400 Bad Request">The provided token has expired.</s3-error:EXPIREDTOKEN>
        <s3-error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="IllegalVersioningConfigurationException" http-error="400 Bad Request">Indicates that the Versioning configuration specified in the request is invalid.</s3-error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION>
        <s3-error:INCOMPLETEBODY locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="IncompleteBody" http-error="400 Bad Request">You did not provide the number of bytes specified by the Content-Length HTTP header</s3-error:INCOMPLETEBODY>
        <s3-error:INCORRECTNUMBEROFFILESINPOSTREQUEST locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="IncorrectNumberOfFilesInPostRequest" http-error="400 Bad Request">POST requires exactly one file upload per request.</s3-error:INCORRECTNUMBEROFFILESINPOSTREQUEST>
        <s3-error:INLINEDATATOOLARGE locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InlineDataTooLarge" http-error="400 Bad Request">Inline data exceeds the maximum allowed size.</s3-error:INLINEDATATOOLARGE>
        <s3-error:INTERNALERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="500" code="InternalError" http-error="500 Internal Server Error">We encountered an internal error. Please try again.</s3-error:INTERNALERROR>
        <s3-error:INVALIDACCESSKEYID locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="InvalidAccessKeyId" http-error="403 Forbidden">The AWS Access Key Id you provided does not exist in our records.</s3-error:INVALIDACCESSKEYID>
        <s3-error:INVALIDADDRESSINGHEADER locale="{$aws-error:LOCALE_EN}" param="0" http-code="" code="InvalidAddressingHeader" http-error="">You must specify the Anonymous role.</s3-error:INVALIDADDRESSINGHEADER>
        <s3-error:INVALIDARGUMENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidArgument" http-error="400 Bad Request">Invalid Argument</s3-error:INVALIDARGUMENT>
        <s3-error:INVALIDBUCKETNAME locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidBucketName" http-error="400 Bad Request">The specified bucket is not valid.</s3-error:INVALIDBUCKETNAME>
        <s3-error:INVALIDDIGEST locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidDigest" http-error="400 Bad Request">The Content-MD5 you specified was an invalid.</s3-error:INVALIDDIGEST>
        <s3-error:INVALIDLOCATIONCONSTRAINT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidLocationConstraint" http-error="400 Bad Request">The specified location constraint is not valid. For more information about Regions, see How to Select a Region for Your Buckets .</s3-error:INVALIDLOCATIONCONSTRAINT>
        <s3-error:INVALIDPAYER locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="InvalidPayer" http-error="403 Forbidden">All access to this object has been disabled.</s3-error:INVALIDPAYER>
        <s3-error:INVALIDPOLICYDOCUMENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidPolicyDocument" http-error="400 Bad Request">The content of the form does not meet the conditions specified in the policy document.</s3-error:INVALIDPOLICYDOCUMENT>
        <s3-error:INVALIDRANGE locale="{$aws-error:LOCALE_EN}" param="0" http-code="416" code="InvalidRange" http-error="416 Requested Range Not Satisfiable">The requested range cannot be satisfied.</s3-error:INVALIDRANGE>
        <s3-error:INVALIDSECURITY locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="InvalidSecurity" http-error="403 Forbidden">The provided security credentials are not valid.</s3-error:INVALIDSECURITY>
        <s3-error:INVALIDSOAPREQUEST locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidSOAPRequest" http-error="400 Bad Request">The SOAP request body is invalid.</s3-error:INVALIDSOAPREQUEST>
        <s3-error:INVALIDSTORAGECLASS locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidStorageClass" http-error="400 Bad Request">The storage class you specified is not valid.</s3-error:INVALIDSTORAGECLASS>
        <s3-error:INVALIDTARGETBUCKETFORLOGGING locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidTargetBucketForLogging" http-error="400 Bad Request">The target bucket for logging does not exist, is not owned by you, or does not have the appropriate grants for the log-delivery group.</s3-error:INVALIDTARGETBUCKETFORLOGGING>
        <s3-error:INVALIDTOKEN locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidToken" http-error="400 Bad Request">The provided token is malformed or otherwise invalid.</s3-error:INVALIDTOKEN>
        <s3-error:INVALIDURI locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="InvalidURI" http-error="400 Bad Request">Couldn't parse the specified URI.</s3-error:INVALIDURI>
        <s3-error:KEYTOOLONG locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="KeyTooLong" http-error="400 Bad Request">Your key is too long.</s3-error:KEYTOOLONG>
        <s3-error:MALFORMEDACLERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</s3-error:MALFORMEDACLERROR>
        <s3-error:MALFORMEDACLERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</s3-error:MALFORMEDACLERROR>
        <s3-error:MALFORMEDPOSTREQUEST locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MalformedPOSTRequest" http-error="400 Bad Request">The body of your POST request is not well-formed multipart/form-data.</s3-error:MALFORMEDPOSTREQUEST>
        <s3-error:MALFORMEDXML locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MalformedXML" http-error="400 Bad Request">This happens when the user sends a malformed xml (xml that doesn't conform to the published xsd) for the configuration. The error message is, "The XML you provided was not well-formed or did not validate against our published schema."</s3-error:MALFORMEDXML>
        <s3-error:MAXMESSAGELENGTHEXCEEDED locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MaxMessageLengthExceeded" http-error="400 Bad Request">Your request was too big.</s3-error:MAXMESSAGELENGTHEXCEEDED>
        <s3-error:MAXPOSTPREDATALENGTHEXCEEDEDERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MaxPostPreDataLengthExceededError" http-error="400 Bad Request">Your POST request fields preceding the upload file were too large.</s3-error:MAXPOSTPREDATALENGTHEXCEEDEDERROR>
        <s3-error:METADATATOOLARGE locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MetadataTooLarge" http-error="400 Bad Request">Your metadata headers exceed the maximum allowed metadata size.</s3-error:METADATATOOLARGE>
        <s3-error:METHODNOTALLOWED locale="{$aws-error:LOCALE_EN}" param="0" http-code="405" code="MethodNotAllowed" http-error="405 Method Not Allowed">The specified method is not allowed against this resource.</s3-error:METHODNOTALLOWED>
        <s3-error:MISSINGATTACHMENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="" code="MissingAttachment" http-error="">A SOAP attachment was expected, but none were found.</s3-error:MISSINGATTACHMENT>
        <s3-error:MISSINGCONTENTLENGTH locale="{$aws-error:LOCALE_EN}" param="0" http-code="411" code="MissingContentLength" http-error="411 Length Required">You must provide the Content-Length HTTP header.</s3-error:MISSINGCONTENTLENGTH>
        <s3-error:MISSINGREQUESTBODYERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MissingRequestBodyError" http-error="400 Bad Request">This happens when the user sends an empty xml document as a request. The error message is, "Request body is empty."</s3-error:MISSINGREQUESTBODYERROR>
        <s3-error:MISSINGSECURITYELEMENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityElement" http-error="400 Bad Request">The SOAP 1.1 request is missing a security element.</s3-error:MISSINGSECURITYELEMENT>
        <s3-error:MISSINGSECURITYHEADER locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityHeader" http-error="400 Bad Request">Your request was missing a required header.</s3-error:MISSINGSECURITYHEADER>
        <s3-error:NOLOGGINGSTATUSFORKEY locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="NoLoggingStatusForKey" http-error="400 Bad Request">There is no such thing as a logging status sub-resource for a key.</s3-error:NOLOGGINGSTATUSFORKEY>
        <s3-error:NOSUCHBUCKET locale="{$aws-error:LOCALE_EN}" param="0" http-code="404" code="NoSuchBucket" http-error="404 Not Found">The specified bucket does not exist.</s3-error:NOSUCHBUCKET>
        <s3-error:NOSUCHKEY locale="{$aws-error:LOCALE_EN}" param="0" http-code="404" code="NoSuchKey" http-error="404 Not Found">The specified key does not exist.</s3-error:NOSUCHKEY>
        <s3-error:NOSUCHVERSION locale="{$aws-error:LOCALE_EN}" param="0" http-code="404" code="NoSuchVersion" http-error="404 Not Found">Indicates that the version ID specified in the request does not match an existing version.</s3-error:NOSUCHVERSION>
        <s3-error:NOTIMPLEMENTED locale="{$aws-error:LOCALE_EN}" param="0" http-code="501" code="NotImplemented" http-error="501 Not Implemented">A header you provided implies functionality that is not implemented.</s3-error:NOTIMPLEMENTED>
        <s3-error:NOTSIGNEDUP locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="NotSignedUp" http-error="403 Forbidden">Your account is not signed up for the Amazon S3 service. You must sign up before you can use Amazon S3 . You can sign up at the following URL: http://aws.amazon.com/s3</s3-error:NOTSIGNEDUP>
        <s3-error:OPERATIONABORTED locale="{$aws-error:LOCALE_EN}" param="0" http-code="409" code="OperationAborted" http-error="409 Conflict">A conflicting conditional operation is currently in progress against this resource. Please try again.</s3-error:OPERATIONABORTED>
        <s3-error:PERMANENTREDIRECT locale="{$aws-error:LOCALE_EN}" param="0" http-code="301" code="PermanentRedirect" http-error="301 Moved Permanently">The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.</s3-error:PERMANENTREDIRECT>
        <s3-error:PRECONDITIONFAILED locale="{$aws-error:LOCALE_EN}" param="0" http-code="412" code="PreconditionFailed" http-error="412 Precondition Failed">At least one of the pre-conditions you specified did not hold.</s3-error:PRECONDITIONFAILED>
        <s3-error:REDIRECT locale="{$aws-error:LOCALE_EN}" param="0" http-code="307" code="Redirect" http-error="307 Moved Temporarily">Temporary redirect.</s3-error:REDIRECT>
        <s3-error:REQUESTISNOTMULTIPARTCONTENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="RequestIsNotMultiPartContent" http-error="400 Bad Request">Bucket POST must be of the enclosure-type multipart/form-data.</s3-error:REQUESTISNOTMULTIPARTCONTENT>
        <s3-error:REQUESTTIMEOUT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="RequestTimeout" http-error="400 Bad Request">Your socket connection to the server was not read from or written to within the timeout period.</s3-error:REQUESTTIMEOUT>
        <s3-error:REQUESTTIMETOOSKEWED locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="RequestTimeTooSkewed" http-error="403 Forbidden">The difference between the request time and the server's time is too large.</s3-error:REQUESTTIMETOOSKEWED>
        <s3-error:REQUESTTORRENTOFBUCKETERROR locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="RequestTorrentOfBucketError" http-error="400 Bad Request">Requesting the torrent file of a bucket is not permitted.</s3-error:REQUESTTORRENTOFBUCKETERROR>
        <s3-error:SIGNATUREDOESNOTMATCH locale="{$aws-error:LOCALE_EN}" param="0" http-code="403" code="SignatureDoesNotMatch" http-error="403 Forbidden">The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method. For more information, see REST Authentication and SOAP Authentication for details.</s3-error:SIGNATUREDOESNOTMATCH>
        <s3-error:SLOWDOWN locale="{$aws-error:LOCALE_EN}" param="0" http-code="503" code="SlowDown" http-error="503 Service Unavailable">Please reduce your request rate.</s3-error:SLOWDOWN>
        <s3-error:TEMPORARYREDIRECT locale="{$aws-error:LOCALE_EN}" param="0" http-code="307" code="TemporaryRedirect" http-error="307 Moved Temporarily">You are being redirected to the bucket while DNS updates.</s3-error:TEMPORARYREDIRECT>
        <s3-error:TOKENREFRESHREQUIRED locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="TokenRefreshRequired" http-error="400 Bad Request">The provided token must be refreshed.</s3-error:TOKENREFRESHREQUIRED>
        <s3-error:TOOMANYBUCKETS locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="TooManyBuckets" http-error="400 Bad Request">You have attempted to create more buckets than allowed.</s3-error:TOOMANYBUCKETS>
        <s3-error:UNEXPECTEDCONTENT locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="UnexpectedContent" http-error="400 Bad Request">This request does not support content.</s3-error:UNEXPECTEDCONTENT>
        <s3-error:UNRESOLVABLEGRANTBYEMAILADDRESS locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="UnresolvableGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided does not match any account on record.</s3-error:UNRESOLVABLEGRANTBYEMAILADDRESS>
        <s3-error:USERKEYMUSTBESPECIFIED locale="{$aws-error:LOCALE_EN}" param="0" http-code="400" code="UserKeyMustBeSpecified" http-error="400 Bad Request">The bucket POST must contain the specified field name. If it is specified, please check the order of the fields.</s3-error:USERKEYMUSTBESPECIFIED>
    </s3-error:messages>
;


(:~
 :  Throws an error with the default locale.
 : 
:)
declare function s3-error:throw(
    $http-code as xs:double,
    $http-response as item()*
) {
    aws-error:throw($http-code, $http-response, $aws-error:LOCALE_DEFAULT, $s3-error:messages)
};


declare function s3-error:throw(
    $http-code as xs:double,
    $http-response as item()*,
    $locale as xs:string
) {
    aws-error:throw($http-code, $http-response, $locale, $s3-error:messages)
};
