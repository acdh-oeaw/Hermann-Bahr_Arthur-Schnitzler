xquery version "3.1";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";
let $headerAccept := request:get-header('Accept')
let $id := tokenize(request:get-url(),'/id/')[2]
let $rootID := collection($config:data-root)/id($id)/root()/tei:TEI/@xml:id/string()
return

   if ($id eq $rootID) then
       (:a document:)
        if ($headerAccept eq 'application/rdf+xml')
        (:requested rdf:)
        then
            response:redirect-to(xs:anyURI(iri-to-uri("https://bahrschnitzler.acdh.oeaw.ac.at/api/v1.0/doc/" || $id || "/about.rdf")))
        else 
            (:redirect to http-page:)
            (:a document HTTP html requested redirect:)
            response:redirect-to(xs:anyURI(iri-to-uri("https://bahrschnitzler.acdh.oeaw.ac.at/view.html?id=" || $id)))
    else
        (:an entity:)
        if ($headerAccept eq 'application/rdf+xml')
        (:requested rdf:)
        then
            response:redirect-to(xs:anyURI(iri-to-uri("https://bahrschnitzler.acdh.oeaw.ac.at/api/v1.0/entity/" || $id || "/about.rdf")))
        else
            (:normal website redirect:)
        response:redirect-to(xs:anyURI(iri-to-uri("https://bahrschnitzler.acdh.oeaw.ac.at/register.html?key=" || $id)))
