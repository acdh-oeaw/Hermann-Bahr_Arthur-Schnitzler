xquery version "3.1";


declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";


let $output :=
for $doc in collection($config:data-root)//tei:TEI[@xml:id]
    let $date :=  switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        default return $doc//tei:date[@when][1]/@when/string()
    let $title := $doc//tei:titleStmt/tei:title[@level='a']/string()
    let $doctype := switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return "text"
                        case "D" return "diary"
                        case "L" return "letter"
                        default return "other"
    let $authorKey := $doc//tei:titleStmt/tei:author/@key/string()
                    order by $date
return
        (:Problematisch: Nur Dokumente ausgeben, die ein Datum haben, das einen gewissen Muster entspricht:)
        if (matches($date,"[0-9]{8}")) then
        map {
        "id":$doc/@xml:id/string(),
        "doctype": $doctype,
        "title": $title,
        "authorKey": $authorKey,
        "sortDate": 
            let $y := substring($date,1,4)
            let $m := substring($date,5,2)
            let $d := substring($date,7,2)
            let $isodate := $y || "-" || $m || "-" || $d
            return $isodate
        }
        else ()
return 
    array {$output}
