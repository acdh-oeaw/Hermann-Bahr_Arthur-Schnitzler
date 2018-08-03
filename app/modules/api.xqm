xquery version "3.1";

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
 

(: /doc/{docId}/transcription.xml :)
declare function api:DocTransciptionXML($docId as xs:string) {
    (:~ Get the XML-Transcription of a Document. It's almost TEI..
    @param $docId xml:id of the Document
    @retuns XML snipped tei:text/tei:body
    :)
    
    if (collection($config:data-root)/id($docId)) then
        (:Document exists, return it:)
        collection($config:data-root)/id($docId)//tei:body
    else
        (:doc doesn't exist, send 404:)
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

declare function local:parseQueryString($query as xs:string) {
    (:~ Helper Function to parse the query string
    @param $query Querystring
    @returns a map with Parameters as keys
    :)
        let $params := 
    map:new(
        for $queryPart in tokenize($query, '&amp;')
            let $paramName := tokenize($queryPart,'=')[1]
            let $paramValue := tokenize($queryPart,'=')[2]
        return
            map:entry($paramName, $paramValue)
    )
    return $params
};

declare function local:getDocsByTypes($docTypes as xs:string) {
    (:~ Helper function returns documentIds by type as sequence
    @param $docTypes Type of document; can be "L" letter, "D" diary, "T" text or any combination of these separated by comma
    @returns sequence of xml:ids
    :)
    (: check, if $docType is correct :)
    if (matches($docTypes, "^([DLT],?)*$")) then
        for $docType in tokenize($docTypes, ',') return
            (: check for 1st letter of xml:id; if its $type then return the ids :)
            (collection($config:data-root)/tei:TEI[substring(@xml:id/string(),1,1) eq $docType]/@xml:id/string())
        else
            <error>{$docTypes}</error>
};

declare function local:getDocsByAuthors($authors as xs:string) {
    (:~ Get Documents written by an author with AXXXXX
    @param $authors keys of Authors separated by comma
    @returns a sequence of xml:ids :)
    
    if (matches($authors, '^((A[0-9]{6}),?)+$')) then
        for $author in tokenize($authors, ',') return
        (: Documents, written by Author:)
        (collection($config:data-root)//tei:titleStmt//tei:author[@key eq $author]/ancestor::tei:TEI/@xml:id/string())
    else
        <error>{$authors}</error>
};

declare function local:getDocsByDate($date as xs:string) {
    (:~ Helper function gets xml:ids of Documents of a Date 
    @param $date in Format YYYY-MM-DD :)
    <date>{$date}</date>
};

(: /doc/filterBy :)
declare function api:DocFilterBy($query as xs:string) {
    (:~ Filter Documents on some Criteria 
    @param $query Querystring
    :)
    (: get Query as map and get the keys 
    <query>{local:parseQueryString($query) => map:keys()}</query> 
    :)
    let $queryMap := local:parseQueryString($query)
    let $countQueryParams := count(map:keys($queryMap))
    return
    <test>{map:get($queryMap,'date'), $countQueryParams} {local:getDocsByTypes('')}
        {local:getDocsByAuthors('')} {local:getDocsByDate('1984-05-30')}
    </test>
};

declare function api:DocSortDate($docId as xs:string) {
    (:~ Get the date for sorting of a document;
    
    @param $docId xml:id of the Document
    @returns date for sorting in YYYY-MM-DD as plaintext
    :)
    
    (: check, if document exists ... else 404:)
    if (collection($config:data-root)/id($docId)) then
    
    let $doc := collection($config:data-root)/id($docId)
    let $date := switch (substring($docId,1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        default return $doc//tei:date[@when][1]/@when/string()
    
    (: convert this string to isodate if needed:)
    let $formatedDate := 
        if (matches($date,"[0-9]{8}")) then
            let $y := substring($date,1,4)
            let $m := substring($date,5,2)
            let $d := substring($date,7,2)
            let $isodate := $y || "-" || $m || "-" || $d
            return $isodate
    else
        (:don't know how formated... return as is:)
        $date
    
    return 
        (:returns plaintext:)
        (response:set-header('Content-Type', 'text/plain'), $formatedDate)
    
    else 
        (: No such Document:)
        response:set-status-code(404)
};