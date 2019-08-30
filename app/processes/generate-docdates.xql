xquery version "3.1";
import module namespace config="http://hbas.at/config" at "../modules/config.xqm";
import module namespace api="http://bahrschnitzler.acdh.oeaw.ac.at/api" at "../modules/api.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
let $filename := "sortdates4docs.xml"
let $location := $config:data-root || "/meta/"
let $docs :=
<docs xmlns="http://bahrschnitzler.acdh.oeaw.ac.at/ns">
{
    for $doc in collection($config:data-root)/tei:TEI[@xml:id][matches(substring(@xml:id/string(),1,1),'^[TLD]')]
    let $sortdate := api:DocSortDate($doc/@xml:id/string())
    order by $sortdate
    return 
        <doc id="{$doc/@xml:id/string()}" sortdate="{$sortdate}"/>
}   
</docs>
return
    (xmldb:store($location, $filename, $docs),$docs)