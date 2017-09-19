xquery version "3.1";


declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

(:   10. 2. 1892 :)

(: Datum:
 : 
 : let $sortdate :=
                    switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        case "K" return () (:Kommentar:)
                        default return $doc//tei:date[@when][1]/@when/string()
                    order by $sortdate :)

let $output :=
for $doc in collection($config:data-root)//tei:TEI[@xml:id]
    let $date :=  switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        default return $doc//tei:date[@when][1]/@when/string()
                    order by $date
return
        if (matches($date,"[0-9]{8}")) then
        map {
            
        "id":$doc/@xml:id/string(),
        "name": $doc//tei:titleStmt/tei:title[@level='a']/string(),
        "startDate": 
            let $y := substring($date,1,4)
            let $m := substring($date,5,2)
            let $d := substring($date,7,2)
            let $isodate := $y || "-" || $m || "-" || $d
            return $isodate
        }
        else ()
return 
    array {$output}

(: dataSource: [
            {
                id: 0,
                name: 'Google I/O',
                location: 'San Francisco, CA',
                startDate: new Date(currentYear, 4, 28),
                endDate: new Date(currentYear, 4, 29)
            },
            {
                id: 1,
                name: 'Microsoft Convergence',
                location: 'New Orleans, LA',
                startDate: new Date(currentYear, 2, 16),
                endDate: new Date(currentYear, 2, 19)
            } :)