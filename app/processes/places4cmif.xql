xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "../modules/config.xqm";

(: Alle placeNames, die in correspDesc vorkommen :)
let $output :=
let $placeNameKeys :=
for $correspDescKey in doc("/db/apps/hbas/cmif.xml")//tei:correspDesc/@key
let $placeNameKey := collection($config:data-root)//id($correspDescKey)//tei:placeSender/tei:placeName/@key/string()
return $placeNameKey
for $distinctKey in  distinct-values($placeNameKeys)
return 
    <placeName key="{$distinctKey}">{collection($config:data-root)//id($distinctKey)//tei:placeName/text()}</placeName>
return
    <placeNames>
        {$output}
    </placeNames>
