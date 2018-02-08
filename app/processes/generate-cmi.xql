xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://hbas.at/config" at "../modules/config.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:media-type "application/xml";

let $base-url := request:get-url()
let $gnd-base := "http://d-nb.info/gnd/"
let $geonames-base := "http://sws.geonames.org/"
return

<TEI xmlns="http://www.tei-c.org/ns/1.0">
<teiHeader>
    <fileDesc>
        <titleStmt>
            <title>Briefwechsel Hermann Bahr, Arthur Schnitzler (1891–1931)</title>
            <editor>
                <!-- [Name of the person, who is responsible for this file (not the edition) -->
                Martin Anton Müller
                <email>martin.anton.mueller@univie.ac.at</email>
            </editor>
        </titleStmt>
        <!--
 Template for a TEI XML file according to the Corrspondence Metadata Interchange (CMI) format 
-->
        <publicationStmt>
            <publisher>
                <ref target="[URL of the publisher]">
                    [Name of the Publisher. IMPORTANT: This name will be used as CC BY attribution]
                </ref>
            </publisher>
            <idno type="url">{request:get-url()}</idno>
            <date when="{substring-before(string(current-date()),'+')}"/>
            <availability>
                <!--  The CC BY 4.0 license is mandatory  -->
                <licence target="https://creativecommons.org/licenses/by/4.0/">
                    This file is licensed under the terms of the Creative-Commons-License CC-BY 4.0
                </licence>
            </availability>
        </publicationStmt>
        <sourceDesc>
            <bibl type="hybrid">
                <author>Hermann Bahr</author>
                <author>Arthur Schnitzler</author> 
                <title level="m">Briefwechsel, Aufzeichnungen, Dokumente 1891–1931</title>
                <respStmt>
                    <resp>Herausgegeben von</resp>
                    <editor>Kurt Ifkovits</editor>
                    <editor>Martin Anton Müller</editor>
                </respStmt>
                <pubPlace>Göttingen</pubPlace>
                <publisher>Wallstein Verlag</publisher>
                <date when="2018">2018</date>
                <idno type="ISBN">978-3-8353-3228-7</idno>
                <ref target="http://bahrschnitzler.acdh.oeaw.ac.at">bahrschnitzler.acdh.oeaw.ac.at</ref>
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
                            attribute when {}
                        }
                    else ()
                }
                
                <!--
 the date has to be note as YYYY-MM-DD, YYYY-MM or YYYY. Attributes @when, @from, @to, @notBefore, @notAfter are possible 
-->
            </correspAction>
            <correspAction type="received">
                <persName ref="[Authority controlled ID like VIAF, GND etc. for addressee]">
                    [Name of the addressee in the manner you want to show it]
                </persName>
                <placeName ref="[Authority controlled ID, i.e. GeoNames for addressees place]">
                    [Name of addressees place in the manner you want to show it]
                </placeName>
                <!--  unkown date should be skipped  -->
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

