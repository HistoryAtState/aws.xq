xquery version "3.1";

(:~
 : Public API for the AWS Textract service.
 :
 : Covers the asynchronous document-analysis operations used for multi-page PDFs:
 :   - StartDocumentAnalysis
 :   - GetDocumentAnalysis
 :
 : @see https://docs.aws.amazon.com/textract/latest/dg/API_StartDocumentAnalysis.html
 : @see https://docs.aws.amazon.com/textract/latest/dg/API_GetDocumentAnalysis.html
 :)
module namespace textract = "http://history.state.gov/ns/xquery/aws/textract";

import module namespace textract-request = "http://history.state.gov/ns/xquery/aws/textract/request";

(:~
 : Start an asynchronous document-analysis job.
 :
 : If $output-bucket is provided, Textract writes its paginated results directly
 : to s3://{$output-bucket}/{$output-prefix}/<JobId>/<N>. If $client-request-token
 : is provided, Textract treats identical tokens as the same job and returns the
 : original JobId instead of starting a duplicate.
 :
 : @param $region               AWS region
 : @param $document-bucket      bucket containing the source PDF
 : @param $document-key         S3 key of the source PDF
 : @param $feature-types        one or more of "TABLES", "FORMS", "LAYOUT", "SIGNATURES", "QUERIES"
 : @param $output-bucket        optional: S3 bucket where Textract should write results
 : @param $output-prefix        optional: key prefix for result objects (required if $output-bucket is set)
 : @param $client-request-token optional: idempotency token, 1-64 chars [A-Za-z0-9-_]
 : @return                      the JobId assigned by Textract
 :)
declare function textract:start-document-analysis(
    $region as xs:string,
    $document-bucket as xs:string,
    $document-key as xs:string,
    $feature-types as xs:string+,
    $output-bucket as xs:string?,
    $output-prefix as xs:string?,
    $client-request-token as xs:string?
) as xs:string {
    let $payload :=
        map:merge((
            map {
                "DocumentLocation": map {
                    "S3Object": map {
                        "Bucket": $document-bucket,
                        "Name": $document-key
                    }
                },
                "FeatureTypes": array { $feature-types }
            },
            if (exists($output-bucket)) then
                map {
                    "OutputConfig": map {
                        "S3Bucket": $output-bucket,
                        "S3Prefix": ($output-prefix, "")[1]
                    }
                }
            else
                (),
            if (exists($client-request-token) and string-length($client-request-token) gt 0) then
                map { "ClientRequestToken": $client-request-token }
            else
                ()
        ))
    let $request := textract-request:create($region, "StartDocumentAnalysis", $payload)
    let $response := textract-request:send($request)
    return
        $response?JobId
};

(:~
 : Fetch the status (and, if SUCCEEDED, the first page of results) of a job
 : started via textract:start-document-analysis().
 :
 : The returned map includes at least "JobStatus". For SUCCEEDED jobs it also
 : includes "DocumentMetadata", "Blocks" (the first page of blocks), and
 : optionally "NextToken" if further pages exist.
 :
 : @param $region AWS region
 : @param $job-id the JobId returned by StartDocumentAnalysis
 : @return        the parsed JSON response
 :)
declare function textract:get-document-analysis(
    $region as xs:string,
    $job-id as xs:string
) as map(*) {
    textract:get-document-analysis($region, $job-id, (), ())
};

(:~
 : Paginated variant of textract:get-document-analysis().
 :
 : @param $region      AWS region
 : @param $job-id      the JobId returned by StartDocumentAnalysis
 : @param $max-results optional: maximum number of block results per response
 : @param $next-token  optional: pagination token from a previous response
 : @return             the parsed JSON response
 :)
declare function textract:get-document-analysis(
    $region as xs:string,
    $job-id as xs:string,
    $max-results as xs:integer?,
    $next-token as xs:string?
) as map(*) {
    let $payload :=
        map:merge((
            map { "JobId": $job-id },
            if (exists($max-results)) then map { "MaxResults": $max-results } else (),
            if (exists($next-token) and string-length($next-token) gt 0) then
                map { "NextToken": $next-token }
            else
                ()
        ))
    let $request := textract-request:create($region, "GetDocumentAnalysis", $payload)
    return
        textract-request:send($request)
};
