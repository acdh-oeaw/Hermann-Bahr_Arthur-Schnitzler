xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";

let $docs := for $doc in collection($config:data-root)/tei:TEI
        let $id := $doc/@xml:id/string()
        let $type := substring($id,1,1)
        let $title := $doc//tei:titleStmt/tei:title[@level="a"]/text()
        let $author := $doc//tei:titleStmt/tei:title/tei:author/text()
        let $date := 
            switch (substring($id,1,1))
            case "L" return $doc//tei:dateSender/tei:date/@when/string()
            case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
            case "T" return $doc//tei:origDate/@when/string()
            default return "none"
        order by $date ascending
        return 
            <doc>
                <id>{$id}</id>
                <type>{$type}</type>
                <author>{$title}</author>
                <title>{$title}</title>
                <date>{$date}</date>
            </doc>
    let $session := session:set-attribute("docs", $docs) (: store result into session :)
    (: only return the first 10 nodes :)
    
    return session:get-attribute("docs")[2]
    (: Generate HTML for output :)