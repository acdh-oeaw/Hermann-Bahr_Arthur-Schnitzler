xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://hbas.at/config" at "../modules/config.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/plain";

let $usr := request:get-parameter('usr', '')
let $pwd := request:get-parameter('pwd', '')
let $dse-url := "http://bahrschnitzler.acdh.oeaw.ac.at"
let $base-url := $dse-url
let $gnd-base := "http://d-nb.info/gnd/"
let $geonames-base := "http://www.geonames.org/"
let $log-in := xmldb:login($config:app-root, $usr, $pwd)

let $cmif :=
<TEI xmlns="http://www.tei-c.org/ns/1.0">
<teiHeader>
    <fileDesc>
        <titleStmt>
                <title>CMIF: Briefwechsel Hermann Bahr, Arthur Schnitzler (1891–1931)</title>
                <editor>Martin Anton Müller
                <email>martin.anton.mueller@univie.ac.at</email>
                </editor>
                <editor>Ingo Börner
                    <email>ingo.boerner@univie.ac.at</email> 
                </editor>
            </titleStmt>
        <publicationStmt>
            <publisher>
                <ref target="{$dse-url}">Arthur Schnitzler, Hermann Bahr: Briefwechsel, Materialien, Dokumente 1891–1931. Hrsg. v. Kurt Ifkovits u. Martin Anton Müller.</ref>
            </publisher>
            <idno type="url">{$dse-url}</idno>
            <date when="{substring-before(string(current-date()),'+')}"/>
            <availability>
                <licence target="https://creativecommons.org/licenses/by/4.0/">
                    This file is licensed under the terms of the Creative-Commons-License CC-BY 4.0
                </licence>
            </availability>
        </publicationStmt>
        <sourceDesc>
                <bibl type="hybrid">
                    Hermann Bahr, Arthur Schnitzler. Briefwechsel, Aufzeichnungen, Dokumente 1891–1931. Herausgegeben von Kurt Ifkovits und Martin Anton Müller. Göttingen: Wallstein Verlag 2018
                   <ref target="{$dse-url}">{$dse-url}</ref>
                </bibl>
        </sourceDesc>
    </fileDesc>
    <profileDesc>
        {
            for $letter in collection($config:data-root || "/letters/")//tei:TEI
            return
                 <correspDesc key="{$letter/@xml:id/string()}" ref="{$base-url ||'/view.html?id=' || $letter/@xml:id/string()}">
            <correspAction type="sent">
                {
                   for $persName in $letter//tei:correspDesc//tei:sender//tei:persName return
                        element persName {
                            
                            if (collection($config:data-root)/id($persName/@key/string())//tei:idno[@type="GND"]) then attribute ref {concat($gnd-base,collection($config:data-root)/id($persName/@key/string())//tei:idno[@type="GND"]/text())} else () ,
                normalize-space($persName/text())
            }
                }
                
                {
                    if ($letter//tei:correspDesc//tei:placeSender) then
                        element placeName {
                            if (collection($config:data-root)/id($letter//tei:correspDesc//tei:placeSender/tei:placeName/@key/string())//tei:idno[@type="geonames"]) then attribute ref {concat($geonames-base,collection($config:data-root)/id($letter//tei:correspDesc//tei:placeSender/tei:placeName/@key/string())//tei:idno[@type="geonames"]/text())} else () ,
                            normalize-space($letter//tei:correspDesc//tei:placeSender/tei:placeName/text())
                            
                        }
                    else ()
                }
                    
                {
                    if ($letter//tei:correspDesc//tei:dateSender/tei:date) then
                        element date {
                            attribute when {
                                let $date := $letter//tei:correspDesc//tei:dateSender/tei:date/@when
                                let $y := substring($date,1,4)
                                let $m := substring($date,5,2)
                                let $d := substring($date,7,2)
                                return
                                if ($d != "00") then
                                    $y || "-" || $m || "-" || $d
                                else 
                                    $y || "-" || $m
                               
                            }
                        }
                    else ()
                }
                
            </correspAction>
            <correspAction type="received">
                
                 {
                   for $persName in $letter//tei:correspDesc//tei:addressee//tei:persName return
                        element persName {
                            
                            if (collection($config:data-root)/id($persName/@key/string())//tei:idno[@type="GND"]) then attribute ref {concat($gnd-base,collection($config:data-root)/id($persName/@key/string())//tei:idno[@type="GND"]/text())} else () ,
                normalize-space($persName/text())
            }
                }
                {
                    if ($letter//tei:correspDesc//tei:placeAddressee) then
                        element placeName {
                            if (collection($config:data-root)/id($letter//tei:correspDesc//tei:placeAddressee/tei:placeName/@key/string())//tei:idno[@type="geonames"]) then attribute ref {concat($geonames-base,collection($config:data-root)/id($letter//tei:correspDesc//tei:placeAddressee/tei:placeName/@key/string())//tei:idno[@type="geonames"]/text())} else () ,
                            normalize-space($letter//tei:correspDesc//tei:placeAddressee/tei:placeName/text())
                            
                        }
                    else ()
                }
            </correspAction>
        </correspDesc>
                
        }
        
       
    </profileDesc>
</teiHeader>
<text>
    <body>
        <p/>
    </body>
</text>
</TEI>

let $filename := "cmif.xml"
let $location := $config:data-root || "/../"
let $saved := xmldb:store($location, $filename, $cmif)
return
  "Success!"