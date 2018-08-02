xquery version "3.0";

(:
 : Funktionen für die API
 : Ingo Börner
 :)
(:~
@author Ingo Börner
:)
module namespace api="http://bahrschnitzler.acdh.oeaw.ac.at/api";
import module namespace config="http://hbas.at/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: /testme :)
declare function api:testme() {
    (:~
    Simple Function to test the API.
    @return will return "OK, it works" wrapped in <ApiResponse>
    :)
    <ApiResponse>OK, it works!</ApiResponse>
};

(: /entity/{$docId}/about.rdf :)
declare function api:DocAboutRdf($docId as xs:string) {
    (:~ This Function supplies the funcitionality for /doc/{$docId}/about.rdf
    
    @param $docId The xml:id of the Document.
    :)
    <ApiResponse>Get Info on Document {$docId}!</ApiResponse>
};

(: entity/{$entityId}/about.rdf :)
declare function api:EntityAboutRdf($entityId as xs:string) {
    (:~ This Function supplies the functionality for entity/{$entityId}/about.rdf
    
    @param $entityId The xml:id of the Entity.
    :)
    <ApiResponse>Get Info on Entity {$entityId}!</ApiResponse>
};

(: doc/{docId}/about.tei :)
declare function api:DocAboutTei($docId as xs:string) {
    (:~ This Function supplies the functionality for doc/{docId}/about.tei
    @param $docId the xml:id of the document
    @returns The Function returns the tei:teiHeader of the Document.
    :)
    
    if (collection($config:data-root)/id($docId)) then
        (:Doc exists, return tei:teiHeader:)
        collection($config:data-root)/id($docId)//tei:teiHeader
    else
        (: No such Document:)
        response:set-status-code(404)
    
};


(: entity/{entityId}/about.tei :)
declare function api:EntityAboutTei($entityId as xs:string) {
    (:~ This Function supplies the functionality for entity/{entityId}/about.tei
    @param $docId the xml:id of the Entity
    @returns The Function returns the TEI-Element of the Entity.
    :)
    
    if (collection($config:data-root)/id($entityId)) then
        (:Entity exists, return the Element:)
        collection($config:data-root)/id($entityId)
    else
        (: No such Entity:)
        response:set-status-code(404)
    
};