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


(: /doc/{docId}/mentions.rdf :)
declare function api:DocMentionsRdf($docId as xs:string) {
    (:~ Get Mentions of Entities in a Document: /doc/{docId}/mentions.rdf 
    @param $docId ID of the Document
    @returns RDF of Mentions of Entites in a Document
    :)
    
    (:Example Response:)
    (:
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:schema="http://schema.org/">

  <rdf:Description rdf:about="http://bahrschnitzler.acdh.oeaw.ac.at/id/D041003">
    <schema:mentions rdf:resource="http://bahrschnitzler.acdh.oeaw.ac.at/id/A002216"/>
    <schema:mentions rdf:resource="http://bahrschnitzler.acdh.oeaw.ac.at/id/A000235"/>
    <schema:mentions rdf:resource="http://bahrschnitzler.acdh.oeaw.ac.at/id/A002218"/>
  </rdf:Description>

</rdf:RDF>
    
    :)
    
    (: check if document exists, otherwhise send 404 :)
    if (collection($config:data-root)/id($docId)) then
        (:Doc exists, return tei:teiHeader:)
    
    (: Generate RDF root element:)
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:schema="http://schema.org/">
  <rdf:Description rdf:about="http://bahrschnitzler.acdh.oeaw.ac.at/id/{$docId}">
    {
        (: loop over all Elements with a @key-Attribute – and hope, that these are the mentions.. :)
        for $key in distinct-values(collection($config:data-root)/id($docId)//tei:body//element()[@key]/@key/string())
        return
            <schema:mentions rdf:resource="http://bahrschnitzler.acdh.oeaw.ac.at/id/{$key}"/>
    }
  </rdf:Description>
</rdf:RDF>

else
    (: Document with this id doesn't exist, send 404 :)
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