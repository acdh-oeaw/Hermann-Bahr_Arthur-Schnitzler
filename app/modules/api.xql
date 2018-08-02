xquery version "3.1";
(: The APIResolver :)

import module namespace config="http://hbas.at/config" at "config.xqm";
import module namespace api="http://bahrschnitzler.acdh.oeaw.ac.at/api" at "api.xqm";


declare namespace tei="http://www.tei-c.org/ns/1.0";

(: local functions :)
 declare function local:test_response() {
    if (contains($url, '/api/v1.0/')) then
            (:start Interaction with API:)
            <response>
                "API Call: " method: {$method}; query: {$query}; servletPath {$servletPath}; url                {$url}; apicall {$apicall}; <!-- headerNames {$headerNames}; --> Accept: {$headerAccept}
            </response>
        else
            (: Incorrect Base, redirect to Documentation :)
            response:redirect-to($APIDocu)
};


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
    
    (: /testme :)
    if ($apicall eq "testme") then
        api:testme()
    
    (: /doc/{docId}/about.rdf :)
    else if (matches($apicall, 'doc/[DLT][0-9]{6}/about\.rdf')) then
        let $docId := tokenize($apicall,'/')[2]
        return
        api:DocAboutRdf($docId)
    
    (: /doc/{docId}/about.tei :)
    else if (matches($apicall, 'doc/[DLT][0-9]{6}/about\.tei')) then
        let $docId := tokenize($apicall,'/')[2]
        return
        api:DocAboutTei($docId)
    
    (: /doc/{docId}/mentions.rdf: :)    
    else if (matches($apicall, 'doc/[DLT][0-9]{6}/mentions\.rdf')) then
        let $docId := tokenize($apicall,'/')[2]
        return
        api:DocMentionsRdf($docId)
    
    (: /entity/{entityId}/about.tei :)
    else if (matches($apicall, 'entity/[A][0-9]{6}/about\.tei')) then
        let $entityId := tokenize($apicall,'/')[2]
        return
        api:EntityAboutTei($entityId)
    
    (: /entity/{entityId}/about.rdf :)
    else if (matches($apicall, 'entity/[A][0-9]{6}/about\.rdf')) then
        let $entityId := tokenize($apicall,'/')[2]
        return
        api:EntityAboutRdf($entityId)
        
        
    (: default :)
    else <ApiResponse>{$apicall}</ApiResponse> (: response:set-status-code(400) :)
    

        
    