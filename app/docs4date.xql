xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";

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
    map {$doc/@xml:id/string(): $date}   
return map:merge($output)