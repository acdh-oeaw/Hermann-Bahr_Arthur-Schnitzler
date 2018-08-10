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
declare namespace custom="http://bahrschnitzler.acdh.oeaw.ac.at/ns";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" ;
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#" ;
declare namespace dc11="http://purl.org/dc/elements/1.1/" ;
declare namespace gndo="http://d-nb.info/standards/elementset/gnd#" ;
declare namespace owl="http://www.w3.org/2002/07/owl#" ; 


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
  
    (: build elements with functions and then insert to $RDF:)  
    let $labels := for $titleString in local:getTitlesOfDoc($docId) return
        <rdfs:label>{$titleString}</rdfs:label>
    
    let $titles := for $titleString in local:getTitlesOfDoc($docId) return
        <dc11:title>{$titleString}</dc11:title>
    
    
    
    let $authors := for $authorkey in local:getAuthorsOfDoc($docId) return 
        <dc11:creator rdf:resource="http://bahrschnitzler.acdh.oeaw.ac.at/id/{$authorkey}"/>
        
        
    let $date := <dc11:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{api:DocSortDate($docId)}</dc11:date>
    
    
    let $RDF := <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                        xmlns:dc11="http://purl.org/dc/elements/1.1/">
                        {
                            
                            <rdf:Description rdf:about="https://bahrschnitzler.acdh.oeaw.ac.at/id/{$docId}">
                            {
                             ($labels, $titles, $authors, $date)
                            }
                            </rdf:Description>
                        }
                </rdf:RDF>
    
    return $RDF
    
};


(: local:getAuthorsOfDoc :)
declare function local:getAuthorsOfDoc($docId as xs:string) {
    (:~ Helper Function returns  IDs of Authors of a Document as sequence
    : @param $docId xml:id of the document
    : @returns sequence of ids
    :)
    
    (: check, if correct form of ID :)
    
    if (matches($docId, '[DLT][0-9]{6}')) then
        
        (: check if Document exists :)
        if (collection($config:data-root)/id($docId)) then
            
            for $authorkey in collection($config:data-root)/id($docId)//tei:titleStmt//tei:author/@key/string()
            return $authorkey
            
            
            else <error>No such document</error>
        
    else 
        <error>Incorrect DocId</error>
    
};

(: local:getTitlesOfDoc :)
declare function local:getTitlesOfDoc($docId as xs:string) {
    (:~ Helper Function returns the titles of Documents 
    @param $docId 
    @returns sequence of Titles
    :)
    
    (: check, if correct docId :)
    if (matches($docId, '[DLT][0-9]{6}')) then
        
        (: check if Document exists :)
        if (collection($config:data-root)/id($docId)) then
            
            for $title in collection($config:data-root)/id($docId)//tei:titleStmt//tei:title[@level='a']
            return normalize-space($title/text())
            
            
            else <error>No such document</error>
        
    else 
        <error>Incorrect DocId</error>
    
    
};
 
declare function local:getMainEntityType($entityId as xs:string) {
    (:~ Helper Function gets the Type of an Entity
    @param $entityId xml:id of the entity
    @returns Entity Type as String; values can be "person", "place", "work", "organization"
    :)
    
    (: Element-Type can be "person" --> person, "place" --> place, "biblFull" --> work, "org" --> organization:)
    
    (: URIs for entity Types need to be defined! :)
    
    (: check, if correct entity id:)
    if (matches($entityId, '[A][0-9]{6}')) then
        (: check, if entity exists :)
        if (collection($config:data-root)/id($entityId)) then
            
            switch(collection($config:data-root)/id($entityId)/name())
            case "person" return "person"
            case "place" return "place"
            case "biblFull" return "work"
            case "org" return "organization"
            default return "none"
            
            
        else <error>No such entity!</error>
    else <error>Wrong Entity Id</error>
    
    
    
};


declare function local:aboutPersonInnerRDF($entityId as xs:string) {
    (:~ Returns info on a Person in RDF; is called by entity/{$entityId}/about.rdf
    @param $entityId xmlid of the entity
    @returns RDF/XML
    :)
    
    
    (: quick fix; this works more or less at the moment; implement parsers for the entities; especially name is a problem, but the code is already there in the module :)
    (
    <rdfs:label>{
        collection($config:data-root)/id($entityId)//tei:surname || ', ' || 
        collection($config:data-root)/id($entityId)//tei:forename
    }</rdfs:label> ,
    <owl:sameAs rdf:resource="http://d-nb.info/gnd/{collection($config:data-root)/id($entityId)//tei:idno[@type='GND']/text()}"/>
    )
};


(: entity/{$entityId}/about.rdf :)
declare function api:EntityAboutRdf($entityId as xs:string) {
    (:~ This Function supplies the functionality for entity/{$entityId}/about.rdf
    
    @param $entityId The xml:id of the Entity.
    :)
    
    
    (: get type of entity :)
    (: local:getEntityType($entityId) :)
    
    
    
     (: check, if correct entity id:)
    if (matches($entityId, '[A][0-9]{6}')) then
        (: check, if entity exists :)
        if (collection($config:data-root)/id($entityId)) then
            
           
           
           
           (: Main block follows here:)
           
           
           
           (: put output RDF together:)
           
           let $RDF := <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                        xmlns:gndo="http://d-nb.info/standards/elementset/gnd#" 
                        xmlns:owl="http://www.w3.org/2002/07/owl#"
                        >
                        {
                            
                            <rdf:Description rdf:about="https://bahrschnitzler.acdh.oeaw.ac.at/id/{$entityId}">
                            {
                             (: switch on entity type, get triples based on entity type :)
                             switch (local:getMainEntityType($entityId))
                             case "person" return local:aboutPersonInnerRDF($entityId)
                             case "place" return ()
                             case "work" return ()
                             case "organization" return ()
                             default return ()
                            }
                            </rdf:Description>
                        }
                </rdf:RDF>
    
    return $RDF
           
           
           (: End Main Block:)
           
           
           
            
            (: entity doesn't exist:)
        else <error>No such entity!</error>
            (: error in entity id :)
    else <error>Wrong Entity Id</error>
    
    
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
    (:~ Helper function gets xml:ids of Documents of a Date. Function doesn't calculate sortdate, but looks it up in data/meta/sortdates4docs.xml 
    @param $date in Format YYYY-MM-DD :)
    (: Check, if sortdates-index exists... :)
    if (doc($config:data-root ||'/meta/sortdates4docs.xml')) then
        
        (: check, if $date matches the format YYYY-MM-DD :)
        if (matches($date,'[0-9]{4}-[0-1][0-9]-[0-3][0-9]')) then
            doc($config:data-root ||'/meta/sortdates4docs.xml')//custom:doc[@sortdate eq $date]/@id/string()
        
        else 
            (: incorrect date format:)
            <error>{$date}</error>
    else
        <error>No sortdate Index-File!</error>
};


declare function local:getDocsByDateRange($range as xs:string) {
    (:~ Get documents in a defined date range 
    @param $range Date range in format range(startdate,enddate)
    :)
    
    (: test if correct range() notation :)
    if (matches($range, 'range\(([0-9]{4}-[0-9]{2}-[0-9]{2}),([0-9]{4}-[0-9]{2}-[0-9]{2})\)')) then
    
    let $startDate := xs:date(replace($range, 'range\(([0-9]{4}-[0-9]{2}-[0-9]{2}),([0-9]{4}-[0-9]{2}-[0-9]{2})\)','$1'))
    let $endDate := xs:date(replace($range, 'range\(([0-9]{4}-[0-9]{2}-[0-9]{2}),([0-9]{4}-[0-9]{2}-[0-9]{2})\)','$2'))
    return
        doc($config:data-root || '/meta/sortdates4docs.xml')//custom:doc[($startDate <= xs:date(@sortdate)) and (xs:date(@sortdate) <= $endDate)]/@id/string()
    
    else
        <error>range()-notation not correct!</error>
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
    let $output :=
        
        switch(count(map:keys($queryMap)))
        case 1 return
            switch (map:keys($queryMap))
                case "type" return local:getDocsByTypes(map:get($queryMap,'type'))
                case "author" return local:getDocsByAuthors(map:get($queryMap,'author'))
                case "date" return 
                    if (contains(map:get($queryMap,'date'),'range')) then local:getDocsByDateRange(map:get($queryMap,'date')) 
                    else local:getDocsByDate(map:get($queryMap,'date'))
                default return "invalid params"
            
        case 2 return 
            switch ( string-join(map:keys($queryMap),',') )
                case "author,date" return 
                    if (contains(map:get($queryMap,'date'),'range')) then 
                        local:getDocsByDateRange(map:get($queryMap,'date'))[.=local:getDocsByAuthors(map:get($queryMap,'author'))] 
                    else local:getDocsByDate(map:get($queryMap,'date'))[.=local:getDocsByAuthors(map:get($queryMap,'author'))]
                case "author,type" return local:getDocsByAuthors(map:get($queryMap,'author'))[.=local:getDocsByTypes(map:get($queryMap,'type'))]
                case "date,type" return if (contains(map:get($queryMap,'date'),'range')) then 
                        local:getDocsByDateRange(map:get($queryMap,'date'))[.=local:getDocsByTypes(map:get($queryMap,'type'))] 
                    else local:getDocsByDate(map:get($queryMap,'date'))[.=local:getDocsByTypes(map:get($queryMap,'type'))]
                    
                default return "invalid params"
        
        case 3 return
            if ( string-join(map:keys($queryMap),',') eq "author,date,type") then 
                    if (contains(map:get($queryMap,'date'),'range')) then 
                        local:getDocsByDateRange(map:get($queryMap,'date'))[.=local:getDocsByAuthors(map:get($queryMap,'author'))][.=local:getDocsByTypes(map:get($queryMap,'type'))] 
                    else local:getDocsByDate(map:get($queryMap,'date'))[.=local:getDocsByAuthors(map:get($queryMap,'author'))][.=local:getDocsByTypes(map:get($queryMap,'type'))]
                
                else "invalid params"
        
        default return ()
            
        return 
            <ApiResponse>
                <docs>
                {
                    for $id in $output
                    return
                        <doc>https://bahrschnitzler.acdh.oeaw.ac.at/id/{$id}</doc>
                }
                </docs>
            </ApiResponse>
        
};



declare function api:DocSortDate($docId as xs:string) {
    (:~ Get the date for sorting of a document; in day is not known, assumes 01; if month is not know, assumes 01.
    
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
            let $isodate := 
                    if ($m != '00' and $d != '00') then $y || "-" || $m || "-" || $d
                    else if ($m eq '00') then  $y || "-" || "01" || "-" || "01"
                    else $y || "-" || $m || "-" || "01"
                        
            return $isodate
    else
        (:don't know how formated... return as is:)
        $date
    
    return 
        (:returns formatted date:)
        $formatedDate
    
    else 
        (: No such Document:)
        response:set-status-code(404)
};