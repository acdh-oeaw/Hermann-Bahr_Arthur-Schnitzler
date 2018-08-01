xquery version "3.1";
(: The APIResolver :)

 (: Set some Basic Stuff :)
 (: Put the Swagger Documentation here :)
 let $APIDocu := "https://bahrschnitzler.acdh.oeaw.ac.at/documentation/api.html"
 

(: Stuff to determine request :)


let $method := request:get-method()
(: let $headerNames := request:get-header-names() :)
let $headerAccept := request:get-header('Accept')
let $query := request:get-query-string()
let $servletPath := request:get-servlet-path()
let $url := request:get-url()
let $apicall := tokenize($url, '/api/v1.0/')[2]
return
        if (contains($url, '/api/v1.0/')) then
            (:start Interaction with API:)
            <response>
                "API Call: " method: {$method}; query: {$query}; servletPath {$servletPath}; url                {$url}; apicall {$apicall}; <!-- headerNames {$headerNames}; --> Accept: {$headerAccept}
            </response>
        else
            (: Incorrect Base, redirect to Documentation :)
            response:redirect-to($APIDocu)
    