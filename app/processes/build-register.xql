xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace hbas="http://hbas.at/ns";

import module namespace config="http://hbas.at/config" at "../modules/config.xqm";
import module namespace format="http://hbas.at/format" at "../modules/format.xqm";

declare option exist:serialize "method=text media-type=text/plain";


let $persName-keys := collection($config:data-root)//tei:persName/tokenize(@key,' ')
let $placeName-keys := collection($config:data-root)//tei:placeName/tokenize(@key,' ')
let $workName-keys := collection($config:data-root)//tei:workName/tokenize(@key,' ')
let $orgName-keys := collection($config:data-root)//tei:orgName/tokenize(@key,' ')

let $all-keys := distinct-values(($persName-keys, $placeName-keys, $workName-keys, $orgName-keys))

let $output :=
for $key in $all-keys
    let $data := collection($config:data-root)/id($key)
    let $type := collection($config:data-root)/id($key)/name()
    (:returns: person, place, org, bibl:)
    let $sortstring := 
        switch ($type)
            case "person" return 
                let $forename := string-join($data//tei:forename, ' ')
                let $surname := string-join($data//tei:surname, ' ')
                let $occupation:= string-join($data//tei:occupation, ' ')
                let $birth :=  $data//tei:birth/@when
                let $death := $data//tei:death/@when
                    return 
                        if ($forename !='') then
                            if ($surname !='' ) then
                                concat($surname, ', ', $forename,'| ','(', $birth,'-',$death, ') , ',$occupation)
                            else $forename
                        else
                            $surname
            case "place" return 
                let $placeName := $data//tei:placeName
                let $district := $data//tei:district
                let $settlement := $data//tei:settlement
                return
                    if ($district !="") then
                        (:Wien-Ort:)
                        concat($settlement, ', ', $district, ', ', $placeName)
                    else
                        (:Nicht-Wien-Ort:)
                        if ($settlement != $placeName) then
                            ()
                        else $settlement
                            
            case "biblFull" return
                let $author :=
                    if ($data//tei:author) then
                        let $forename := string-join($data//tei:forename, ' ')
                        let $surname := string-join($data//tei:surname, ' ')
                        return 
                            if ($forename !='') then
                                concat($surname, ', ', $forename)
                            else
                                $surname
                    else ''
                        return 
                            if ($author !='') then 
                                concat($author, '| ', string-join($data//tei:title, ' '))
                            else string-join($data//tei:title, ' ')
                                            
            case "org" return 
                string-join($data//tei:orgName, ' ')
            default return ()
order by $sortstring
                            
return 
    if ($type != "biblFull") then
                            <li class="register_{$type}" data-sortstring="{$sortstring}">
                                <a href="register.html?key={$key}"><span>{tokenize($sortstring,'\|')[1]}</span>
                                    {
                                        if ($type = "person") then
                                            
                                            if ($data/tei:birth/@when and $data/tei:death/@when)
                                                then
                                                    <span class="date">{concat($data/tei:birth/@when,'–',$data/tei:death/@when)}</span>
                                                else 
                                                    if ($data/tei:birth/@when and not($data/tei:death/@when))                                                            then
                                                            <span class="date">{concat("*&#160;", $data/tei:birth/@when)}</span>
                                                        else 
                                                            if (not($data/tei:birth/@when) and $data/tei:death/@when) then <span class="date">{concat("†&#160;", $data/tei:death/@when)}</span> 
                                                            else ()
                                        else ()
                                    }
                                    {
                                        if ($data/tei:occupation) then
                                                <span class="occupation">{$data/tei:occupation//text()}</span>
                                            else ()
                                    }
                                </a>
                            </li>
                        else 
                            (: Texte :)
                            (: wenn es mehrere Texte von einem Autor gibt, dann zusätzliche Klasse .multiple oder sowas und die Filterfunktion nur für li mit dieser class erlauben:)
                            let $autor-ref := $data//tei:author/@ref
                            let $ref-count := count(doc($config:data-root||"/meta/Werke.xml")//tei:body//tei:author[contains(@ref,$autor-ref)])
                            return
                            <li class="register_{$type} {if ($ref-count > 1) then "multiple" else ()}" data-sortstring="{$sortstring}" data-autor-ref="{$autor-ref}" data-ref-count="{$ref-count}">
                                <a href="register.html?key={$key}">
                                    <span class="author">{tokenize($sortstring,"\|")[1]}</span>
                                    <span class="title hide_author">{tokenize($sortstring,"\|")[2]}</span>
                                </a>
                            </li>
                            
                    
                        
            
let $out := 
    <ul class="register">{$output}</ul>
let $filename := "register.xml"
let $location := $config:data-root || "/meta/"
let $saved := xmldb:store($location, $filename, $out)
return 
  "Success!"