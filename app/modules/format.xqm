xquery version "3.0";

(:~
 : Formatierungen für Hermann Bahr – Arthur Schnitzler-Briefwechsel
 : Ingo Börner
 :)
module namespace format="http://hbas.at/format";
import module namespace config="http://hbas.at/config" at "config.xqm";

declare namespace templates="http://exist-db.org/xquery/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(: ---------------------- Typeswitch-Funktion zur Formatierung von Dokumenten ---------------------------- :)

declare function format:tei2html($nodes as node()*) {
(: 
 : Typeswitch um Dokument zu formatieren: XML > HTML
 :)
    for $node in $nodes
    return
        typeswitch($node)
        
        (: ### A ###:)
        
        (: tei:add :)
        case element(tei:add) return
            if ($node[parent::tei:subst]) then
                (:add in subst:)
                <span class="subst-add">{format:tei2html($node/node())}</span>
            else
            element span {
            attribute class {
                (
                "add",
                if ($node/@place) then concat('place_',$node/@place) else ()
                )
            },
            attribute data-commentary {
                switch ($node/@place)
                case "inline" return "Einfügung in der Zeile."
                case "above" return "Einfügung oberhalb der Zeile."
                case "below" return "Einfügung unterhalb der Zeile."
                case "margin" return "Einfügung am Blattrand."
                case "overwritten" return "Überschrieben."
                default return $node/@place
            },
            format:tei2html($node/node())
            }
        
        (:tei:address :)
        case element(tei:address) return
            <div class="address">{format:tei2html($node/node())}</div>
            
        (: addressee :)
        case element(tei:addressee) return
            <span class="addressee">{format:tei2html($node/node())}</span>
        
        (: tei:addrLine :)
        (:kommt offensichtlich bei Ansichtskarten text @type="card" vor:)
        case element(tei:addrLine) return
            <div class="addrLine">{format:tei2html($node/node())}</div>
        
        (: analytic :)
        (: Literaturangaben in bibl:)
        case element(tei:analytic) return
           <span class="analytic">{format:tei2html($node/node())}</span>
        
        (: tei:anchor :)
        (: 
            @type: commentary, label, textConst
            @xml:id
        :)
        case element(tei:anchor) return
            switch ($node/@type)
            case "commentary" return 
                (
                <a
                id="{$node/@xml:id}"
                class="commentary"
                >{format:tei2html($node/node())}</a>,
                <a id="FN-ref_{$node/@xml:id}"
                class="commentary-ref"
                href="#FN_{$node/@xml:id}"><sup>{count($node/preceding::tei:anchor[@type='commentary'])+1}</sup></a>
                )
            case "label" return <a class="anchor_label" id="{$node/@xml:id}">{format:tei2html($node/node())}</a>
            (:Was mit textConst machen?:)
            case "textConst" return 
                (
                <a
                id="{$node/@xml:id}"
                class="textConst"
                >{format:tei2html($node/node())}</a>,
                <a id="FN-ref_{$node/@xml:id}"
                class="commentary-ref"
                href="#FN_{$node/@xml:id}"><sup>{count($node/preceding::tei:anchor[@type='commentary'])+1}</sup></a>
                )
            default return ()
        
        (: tei:author :)
        (: 24x ohne @key, :)
        (: kommt vor in tei:analytic; monogr; titleStmt
        kommt niemals im tei:text vor, nur in den Metadaten/im Header; in bibliographischen Angaben
        soll ich das verlinken, oder nicht?
        :)
        case element(tei:author) return
            (: 
            if ($node/@key) then
                <a class="author"
                data-toggle="popover"
                data-container="body"
                data-title="Person"
                data-html="true"
                data-placement="top"
                data-content="{format:popover_person($node/@key)}"
                >{format:tei2html($node/node())}</a>
                else <span class="author">{format:tei2html($node/node())}</span>  
            :)
            <span class="author {if ($node/following-sibling::tei:author) then () else 'last'}">{format:tei2html($node/node())}</span>
        
        (: availability :)
        case element(tei:availability) return
            <span class="availability">{format:tei2html($node/node())}</span>
        
        (: ### B ###:)
        
        
        (: biblScope :)
        case element(tei:biblScope) return
            <span class="biblScope {$node/@type}">{format:tei2html($node/node())}</span>
        
        (: biblStruct :)
        (:Bibliographische Angabe in sourceDesc und zwar nur hier:)
        case element(tei:biblStruct) return 
            if ($node/preceding-sibling::tei:biblStruct or $node/ancestor::tei:sourceDesc/tei:listWit) then
                
            <li class="biblStruct">Weiterer Druck: {format:tei2html($node/node())}</li>
            else
               <li class="biblStruct">{format:tei2html($node/node())}</li> 
        
        (: tei:body :)
        case element(tei:body) return
                (
                <a id="{concat("start_",$node/ancestor::tei:TEI/@xml:id)}"/> (: = Jumplink:),
                <div class="body">{format:tei2html($node/node())}</div>
                )
        
        
        (: ### C ###:)
        
        (: c :)
        (: @rendition= #prozent, #kaufmannsund, #dollar :)
        case element(tei:c) return
            switch ($node/@rendition) 
            case "#dollar" return "$"
            case "#kaufmannsund" return "&amp;"
            case "#prozent" return "%"
            case "#dots" return
                for $n in 1 to xs:int(number($node/@n)) return '.&#160;'
            default return $node/@rendition
        
        (: caption :)
        case element(tei:caption) return
            <div class="caption">{format:tei2html($node/node())}</div>
        
        (: cell :)
        
        case element(tei:cell) return
            <td>{format:tei2html($node/node())}</td>
        
        (: change :)
        
        (: tei:closer :)
        case element(tei:closer) return
            <div class="closer">{format:tei2html($node/node())}</div>
        
        (: context :)
        (: in correspDesc, aber nicht in Verwendung:)
        case element(tei:context) return
            format:tei2html($node/node())
        
        (: correspDesc :)
        case element(tei:correspDesc) return
            <div class="correspDesc">{format:tei2html($node/node())}</div>
        
        (: country :)
        (:kommt vor in msIdentifier und placeName:)
        case element(tei:country) return
            <span class="country">{format:tei2html($node/node())}</span>
        
        (: ### D ###:)
        
        (: tei:damage :)
        (: @agent=hole, ink, paperloss, water :)
        case element(tei:damage) return
            (:Wenns tei:supplied gibt, dann das anzeigen und den @agent dort abgreifen, ansonsten Zeichen für Textverlusst angeben :)
            (:ignoriert textnodes in <damage>!:)
            if ($node/node()) then <span class="damage" data-agent="{$node/@agent}">{format:tei2html($node/element())}</span> 
            else 
                <a class="damage damage-empty"
                data-toggle="popover"
                data-container="body"
                data-title="Textverlusst"
                data-html="true"
                data-placement="top"
                data-content="Textverlusst durch {
                    switch ($node/@agent)
                    case "hole" return "Lochung"
                    case "water" return "Wasserschaden"
                    case "ink" return "Tintenfleck"
                    default return $node/@agent
                }."
                />
            
            
        
        (:  tei:date :)
        (: kommt in den Metadaten und im text vor:)
        (:Attribute @when, @n??:)
        case element(tei:date) return
            if ($node/ancestor::tei:text) then
                <a class="date">{format:tei2html($node/node())}</a>
            else <span class="date{if ($node/ancestor::tei:monogr/tei:biblScope) then ' date-pp' else ()}">{format:tei2html($node/node())}</span>
        
        
        
        (:  dateline :)
        (:hat Attribut @rend= center, right:)
        case element(tei:dateline) return
            <div class="dateline{if ($node/@rend) then 
                switch ($node/@rend) 
                case "center" return " text-center" 
                case "right" return " text-right"
                default return () 
                else ()}">{format:tei2html($node/node())}</div>
        
        (:  dateSender :)
        case element(tei:dateSender) return
            <span class="dateSender">{format:tei2html($node/node())}</span>
        
        (:  datum :)
        (:ignorier ich:)
        
        (:  del :)
        (:@rend = strikethrough, overwritten, erased:)
       
       case element(tei:del) return 
           
           if ($node[parent::tei:subst]) then
               
               <span class="subst-del">{format:tei2html($node/node())}</span>
               
               else
           
           <del class="{$node/@rend}"
           title="{
               (:mouseover:)
               switch ($node/@rend)
               case "strikethrough" return "gestrichen"
               case "overwritten" return "überschrieben"
               case "erased" return "gelöscht"
               default return $node/@rend
           }"
           >{format:tei2html($node/node())}</del>
       
        
        (: tei:div :)
        (: schwieriger, das kann an mehreren Stellen vorkommen :)
        (:  div type=address – bei Postkarten der Adressblock :)
        
        case element(tei:div) return
            element div {
                if($node/@xml:id) then attribute id {$node/@xml:id} else () ,
                attribute class {
                    (
                    (: text-divs unterscheiden von anderen :)    
                    if ($node/ancestor::tei:text) then "text-div" else (),
                    if ($node/@type) then $node/@type else ()
                    )
                } ,
                format:tei2html($node/node())
            }
        
        
        (: ### E ###:)
        
        (: tei:edition :)
        case element(tei:edition) return
            <span class="edition">{format:tei2html($node/node())}</span>
        
        (: tei:editionStmt :)
        case element(tei:editionStmt) return
            <div class="editionStmt">{format:tei2html($node/node())}</div>
        
        (: tei:editor :)
        case element(tei:editor) return
            <span class="editor">{format:tei2html($node/node())}</span>
        
        
        (: ### F ###:)
        
        (: figure :)
        
       
        case element (tei:figure) return
            (
            <a
            data-toggle="modal" data-target="#modal_img_{count($node/preceding::tei:figure)+1}"
            >
            <img class="thumbnail" src="{$config:img-base-url || substring-after($node/tei:graphic/@url,'./images/')}.jpg"></img></a>,
            <div
            id="modal_img_{count($node/preceding::tei:figure)+1}"
            class="modal" tabindex="-1" role="dialog" aria-labelledby="">
                <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <img class="img img-responsive" src="{$config:img-base-url || substring-after($node/tei:graphic/@url,'./images/')}.jpg"></img>
                    {format:tei2html($node/node())}
                </div>
                </div>
            </div>
            )
        
        (: fileDesc :)
        case element(tei:fileDesc) return
            <div class="fileDesc">{format:tei2html($node/node())}</div>
        
        (: footNote :)
        (:wahrscheinlich tei:note rend=footnote oder was auch immer:)
        
        case element(tei:footNote) return
            <a id="{$node/@xml:id}" class="footnote-ref" href="#FN_{$node/@xml:id}"><sup>{count($node/preceding::tei:footNote)+1}</sup></a>
            
        (: foreign :)
        (:Übersetzen??:)
        case element(tei:foreign) return
            <span class="foreign lang_{$node/@xml:lang}" 
            title="{
                switch($node/@xml:lang)
                case "fr" return "Französisch"
                case "el" return "Griechisch"
                default return $node/@xml:lang
                
            }"
            data-lang="$node/@xml:lang">{format:tei2html($node/node())}</span>
        
        (: frame :)
        (:gibts nur 1x:)
        case element(tei:frame) return
            <div class="frame">{format:tei2html($node/node())}</div>
        
        (: tei:funder :)
        case element(tei:funder) return
            <span class="funder">{format:tei2html($node/node())}</span>
        
        
        (: ### G ###:)
        
    (: tei:gap :)
    (:quantity, unit= chars eignetlich immer:)
    (: reason = G/gabelsberger, illegible, outOfScope, :)
    case element(tei:gap) return 
        if ($node/@reason eq "illegible") then 
            <span class="gap illegible">{for $quant in 1 to xs:integer($node/@quantity) return <span class="malzeichen">×</span>}</span>
        else 
            if (count($node/following-sibling::element())>1 or count($node/preceding-sibling::element())>1) then
                 "[…]"
                 else
            <span class="gap {$node/@reason}"></span>
        
    
    
    (: geogName :)
    case element(tei:geogName) return
        <span class="geogName {$node/@type}">{format:tei2html($node/node())}</span>
    
    (: graphic :)
    (:kommt nur in tei:figure vor; dort hab ich damit schon was gemacht:)
        
        (: ### H ###:)
        
        (: tei:handShift :)
        (: scribe hat den @key-value :)
        (: medium :)
        case element(tei:handShift) return
            <span class="handShift">
            {
             if ($node/@medium = 'typewriter') then "[ms.:] " 
             else
                 if ($node/@scribe) then
                     "[hs. " || string-join(collection($config:data-root)//id($node/@scribe/string())//tei:surname,' ') ||", " || string-join(collection($config:data-root)//id($node/@scribe/string())//tei:forename,' ') || "] "
                     else "[hs.:] "
            }
            </span>
        
        (:  tei:head :)
        (:@rend center, sub?–wohl Fehler; @type: sub - Untertitel)
        .head; .subhead :)
        case element(tei:head) return
            switch ($node/@type)
            case "sub" return <div class="subhead {format:text-align($node/@rend)}">{format:tei2html($node/node())}</div>
            default return <div class="head {format:text-align($node/@rend)}">{format:tei2html($node/node())}</div>
        
        (:  tei:hi :)
        (: Attribute n, rend ; was n tut, ist mir nicht klar:)
        (: Werte von rend: antiqua, bold, italic,latintype, overline, small-caps, spaced_out, strikethrough, subscript, superscript, underline
 :)
    case element(tei:hi) return
        if ($node/@rend eq "underline") then
            if ($node/@n = "1") then 
             <span class="hi rend_{$node/@rend}-single">{format:tei2html($node/node())}</span>   
            else 
               <span class="hi rend_{$node/@rend}-multiple">{format:tei2html($node/node())}</span> 
        else
        <span class="hi rend_{$node/@rend}">{format:tei2html($node/node())}</span>
        
        (: ### I ###:)
        
        
        (: tei:idno :)
        (:Offensichtlich sowas wie Dokumentennummer Werte von @type HBAS-D, HBAS-L:)
        case element(tei:idno) return
            switch ($node/@type) 
            case "HBAS-D" return <span class="idno type_HBAS-D">{$node/@n}</span>
            case "HBAS-L" return <span class="idno type_HBAS-L">{$node/@n}</span>
            case "HBAS-T" return <span class="idno type_HBAS-T">{$node/@n}</span>
            default return <span class="idno type_{$node/@type}">{format:tei2html($node/node())}</span>
        
        
        
        (: tei:imprint:)
        case element(tei:imprint) return
            <span class="imprint">{format:tei2html($node/node())}</span>
        
        (: tei:item :)
        case element(tei:item) return
            if ($node/parent::tei:list and $node/preceding-sibling::tei:label[1]) then
                ()
                else format:tei2html($node/node())
        
        
        (: ### L ###:)
        
        (: label :)
        case element(tei:label) return
            if ($node/parent::tei:list and $node/following-sibling::tei:item[1]) then
                <li>
                    <span class="tei_label">{format:tei2html($node/node())}</span>
                    <span class="item">{format:tei2html($node/following-sibling::tei:item[1]/node())}</span>
                </li>
                else format:tei2html($node/node())
        
        (: l :)
        case element(tei:l) return
            <div class="l">{format:tei2html($node/node())}</div>
        
        (:   lb :)
        case element(tei:lb) return
            <br />
        
        (:  lg :)
        (:Lyrik in Strophenform:)
        (:Attribute: type, output: true – allerdings nur 4x :)
        (:type is immer poem:)
        case element(tei:lg) return
            <div class="lg {$node/@type}">{format:tei2html($node/node())}</div>
        
        (: list :)
        
        (:@type = gloss, simple-gloss:)
        case element(tei:list) return
            <ul class="list list_{$node/@type}">
            {format:tei2html($node/node())}
            </ul>
            
        (:  listBibl :)
        case element (tei:listBibl) return
            <ul class="listBibl">{format:tei2html($node/node())}</ul>
        
        (:   listWit :)
        case element(tei:listWit) return
            <ul class="listWit">{format:tei2html($node/node())}</ul>
        
         (: ### M ###:)
        
        (: monogr :)
        case element(tei:monogr) return
            <span class="monogr">{format:tei2html($node/node())}</span>
        
        (: msDesc :)
        case element(tei:msDesc) return
            <div class="msDesc">{format:tei2html($node/node())}</div>
        
        (: msIdentifier :)
        case element(tei:msIdentifier) return
            <span class="msIdentifier">{format:tei2html($node/node())}</span>
        
        (: ### N ###:)
        
        (:name :)
        (:Namen im Header, kann "Martin Anton Müller", "Kurt Ifkovits" oder "FWF - Fonds für Wissenschaft und Forschung" sein:)
        case element (tei:name) return
            <span class="name">{format:tei2html($node/node())}</span>
        
        (: note :)
        (:Attribute: @type: introduction, summary:)
        case element (tei:note) return
            <span class="note type_{$node/@type}">{format:tei2html($node/node())}</span>
        
        (: ### O ###:)
        
        (: opener :)
        case element(tei:opener) return
            <div class="opener">{format:tei2html($node/node())}</div>
        
        (: orgName :)
        (:Attribut @key:)
        case element(tei:orgName) return
            if ($node//element()[@key]) then
                    let $keys := string-join($node/@key/string(),',') || "," || replace(string-join($node//element()[@key]/@key/string(),','), ' ', ',')
                    return
                    <a class="rs" href="register.html?key={$keys}">{$node//text()}</a>
                    else
            if ($node/@key) then
            <a class="orgName" href="register.html?key={$node/@key}&amp;type=org">{format:tei2html($node/node())}</a>
        else
            <span class="orgName-nolink">{format:tei2html($node/node())}</span>
        
        (: origDate :)
        (:im Header:)
        case element(tei:orgiDate) return
            <span class="origDate" data-when="{$node/@when}">{format:tei2html($node/node())}</span>
        
        
        (: ### P ###:)
        
        (: tei:p :)
        (:Attribute: @output, @part, @rend:)
        (: output: Werte true, dots kommt aber nur 3x vor:)
        (:rend hat Werte: right, center, inline:)
        (:@part : keine Ahnung, was das soll, die xPath-Abfrage im Oxygen funktioniert auch nicht:)
        case element(tei:p) return
            element p {
            (: tei:p im text-Element oder an einem anderen Ort :)
            if ($node/ancestor::tei:text) then (
                attribute class {
                    ("text-p",
                    if ($node/@rend) then format:text-align($node/@rend) else ()
                    )
                    
                }
                ) else (),
            format:tei2html($node/node())    
            }
            
        
        (: pb :)
        case element(tei:pb) return
            <a class="pb"/>
            
        (: persName :)
        case element(tei:persName) return
            if ($node//element()[@key]) then
                    let $keys := $node/@key/string() || "," || replace(string-join($node//element()[@key]/@key/string(),','), ' ', ',')
                    return
                    <a class="rs" href="register.html?key={$keys}">{$node//text()}</a>
                    else
            
            <a class="persName" href="register.html?key={$node/@key}&amp;type=p">{format:tei2html($node/node())}</a>
            
            
        (: persNamey :)
        (:a Schmarrn, nur 1x mit Ludassy...:)
        
        (: physDesc :)
        case element (tei:physDesc) return
            <div class="physDesc">{format:tei2html($node/node())}</div>
        
        (: place :)
        (:Fehler? gibt's nur 1x:)
        
        (: placeAddressee :)
        case element (tei:placeAddressee) return
            <span class="placeAddressee">{format:tei2html($node/node())}</span>
        
        
        (: placeName :)
        (:Attribut @key, @type – vernachlässigbar hat nur den Wert place :)
        (:unterscheiden, ob im Header oder im Text:)
        case element(tei:placeName) return
            
            
        if ($node/ancestor::tei:text) then 
            (:im Text mit popup:)
            if ($node//element()[@key]) then
                    let $keys := $node/@key/string() || "," || replace(string-join($node//element()[@key]/@key/string(),','), ' ', ',')
                    return
                    <a class="rs" href="register.html?key={$keys}">{$node//text()}</a>
                    else
            
            <a class="placeName" href="register.html?key={$node/@key}&amp;type=o">{format:tei2html($node/node())}</a>
                 else
                     if ($node/ancestor::tei:physDesc) then
                                    <a class="placeName" href="register.html?key={$node/@key}&amp;type=o">{format:tei2html($node/node())}</a>

 
                    else
            <span class="placeName">{format:tei2html($node/node())}</span>    
            
        
        
        
        (: placeSender :)
        case element (tei:placeSender) return
            <span class="placeSender">{format:tei2html($node/node())}</span>
        
        (: postCode :)
        case element (tei:postCode) return
            <span class="postCode">{format:tei2html($node/node())}</span>
        
        (: postscript :)
        case element (tei:postscript) return
            <div class="postscript">{format:tei2html($node/node())}</div>

        (: profileDesc :)
        
        case element (tei:profileDesc) return
            <div class="profileDesc">{format:tei2html($node/node())}</div>
        
        
        (: ptr :)
        case element (tei:ptr) return
            if (contains($node/@target, '-')) then
            <a class="ptr" href="view.html?id={collection($config:data-root)/id($node/@target/string())/ancestor::tei:TEI/@xml:id/string()}&amp;show=a&amp;view-mode=2#FN-ref_{$node/@target/string()}">{collection($config:data-root)/id($node/@target/string())/ancestor::tei:TEI//tei:titleStmt/tei:title[@level='a']/text()}</a>
            else (: Verweis auf ganzen Text :)
            <a class="ptr" href="view.html?id={$node/@target/string()}">{collection($config:data-root)/id($node/@target/string())//tei:titleStmt/tei:title[@level='a']/text()}</a>
            
            
        
        (: publicationStmt :)
        case element (tei:publicationStmt) return
            <div class="publicationStmt">{format:tei2html($node/node())}</div>
        
        
        (: publisher :)
        case element (tei:publisher) return
            <span class="publisher">{format:tei2html($node/node())}</span>
        
        (: pubPlace :) 
        case element (tei:pubPlace) return
            <span class="pubPlace">{format:tei2html($node/node())}</span>
        
        (: quote :)
        case element (tei:quote) return
            format:tei2html($node/node())
        
        (: ### R ###:)
        
        (: repository :)
        case element (tei:repository) return
            <span class="repository">{format:tei2html($node/node())}</span>
        
        (: resp :)
        case element (tei:resp) return
            <span class="resp">{format:tei2html($node/node())}</span>
        
        (: respStmt :)
        case element (tei:respStmt) return
            <div class="respStmt">{format:tei2html($node/node())}</div>
        
        (: revisionDesc :)
        case element (tei:revisionDesc) return
            <div class="revisionDesc">{format:tei2html($node/node())}</div>


        
        (: tei:row :)
        case element(tei:row) return
            <tr>{format:tei2html($node/node())}</tr>
        
        (:tei:rs:)
        (:Attribute @key, @type:)
        (:@type-Werte: org, person, place, work:)
            case element(tei:rs) return
                
                if ($node//element()[@key]) then
                    let $keys := $node/@key/string() || "," || replace(string-join($node//element()[@key]/@key/string(),','), ' ', ',')
                    return
                    <a class="rs" href="register.html?key={$keys}">{$node//text()}</a>
                    else
                
                switch ($node/@type) 
                case "org" return 
                    <a class="rs rs_org" href="register.html?key={replace($node/@key,' ',',')}&amp;type=org">{format:tei2html($node/node())}</a>
                case "person" return 
                    <a class="rs rs_person" href="register.html?key={replace($node/@key,' ',',')}&amp;type=p">{format:tei2html($node/node())}</a>
                case "place" return 
                    <a class="rs rs_place" href="register.html?key={replace($node/@key,' ',',')}&amp;type=o">{format:tei2html($node/node())}</a>
                case "work" return 
                    <a class="rs rs_work" href="register.html?key={replace($node/@key,' ',',')}&amp;type=w">{format:tei2html($node/node())}</a>
                default return <span class="rs rs_{$node/@type}" data-key="{replace($node/@key,' ',',')}">{format:tei2html($node/node())}</span>
                
        
        (: ### S ###:)
        
        (: salate :)
        

        
        (: tei:salute:)
        (:das umgebende div kommt von tei:opener:)
        case element(tei:salute) return
            <span class="salute">{format:tei2html($node/node())}</span>
            
        (: seg :)
        (:verwendet im tei:opener, oft, um rechtsbündig zu setzen :)
        (:Attribute rend: left center right:)
        (:da ist ein fehler in der Auszeichnung, die Ausrichtung müste man wahrscheinlich anders machen; seg ist kein Block-Level-Element, so, wie ich das verstehe;:)
        case element (tei:seg) return
            <span class="seg {
                if ($node/@rend) then format:text-align($node/@rend) else ()
            }">{format:tei2html($node/node())}</span>
        
        
        (: sender :)
        case element (tei:sender) return
            <span class="sender">{format:tei2html($node/node())}</span>
        
        (: series :)
        case element (tei:series) return
            <span class="series">{format:tei2html($node/node())}</span>
        
        
        (: seriesStmt :)
        
        case element(tei:seriesStmt) return
            <div class="seriesStmt">{format:tei2html($node/node())}</div>
        
        (: settlement :)
        case element (tei:settlement) return
            <span class="settlement">{format:tei2html($node/node())}</span>
        
        (: signed :)
        case element (tei:signed) return
            <span class="signed">{format:tei2html($node/node())}</span>
        
        (: sourceDesc :)
        case element (tei:sourceDesc) return
            <div class="sourceDesc">{format:tei2html($node/node())}</div>
        
        (: space :)
        (: Attribute: quantity, unit :)
        case element (tei:space) return 
            
            if ($node/@quantity = "1") then
                " " else
            <span class="space" style="width:{$node/@quantity}em"> </span>
        
        (: stamp :)
        case element(tei:stamp) return
            <div class="stamp" data-n="{$node/@n}"><span>Stempel {$node/@n/string()}: </span>{format:tei2html($node/node())}</div>
            
        (: street :)
        case element(tei:street) return
            <span class="street">{format:tei2html($node/node())}</span>
        
        (: subst :)
        case element(tei:subst) return
            <span class="subst">{format:tei2html($node/node())}</span>

        (: tei:supplied :)
        (: wenn innerhalb von damage, dann kann man @agent von damage abfragen:)
        case element(tei:supplied) return
            element span {
                attribute class {
                    "supplied"
                },
                attribute title {"Von den Herausgebern ergänzt."},format:tei2html($node/node())}
            
        
        (: ### T ###:)
        
        (: tei:table :)
        case element(tei:table) return
            <table>{format:tei2html($node/node())}</table>
        
        (: tei:teiHeader :)
        (: momentan einfach verstecken, später braucht's zumindest die correspDesc :)
        case element(tei:teiHeader) return
                <div class="teiHeader">{format:tei2html($node/node())}</div>
        
        (: tei:text :)
        (:NOCH NICHT FEERTIG:)
        (:Was sind die @type von text:)
         case element(tei:text) return
                <div class="text type_{$node/@type}">{format:tei2html($node/node())}</div>
        
        (: time :)
        (:kommt nur innerhalb von stamp vor:)
        case element (tei:time) return
            <span class="time">{format:tei2html($node/node())}</span>
        
        (: title :)
        (:kommt nur im Header vor?: ja, parent::titleStmt; parent::monogr, parent::series, parent::analytic :)
        (: Attribute @level, @key:)
        case element(tei:title) return
            <span class="title level_{$node/@level}">{format:tei2html($node/node())}</span>
        
        
        (: titleStmt :)
        case element (tei:titleStmt) return
            <div class="titleStmt">{format:tei2html($node/node())}</div>
        
         (: ### U ###:)
        
        (: uhr :)
        (:?? gibt's vielleicht eh nicht mehr:)
        (: uhrzeit :)
        (:?? gibt's vielleicht eh nicht mehr:)
        
        (: unclear :)
        case element (tei:unclear) return
            <span class="unclear" title="Entzifferung unsicher.">{format:tei2html($node/node())}</span>
        
        (: ### V ###:)
        
        (:vorgang:)
        (:kommt in stamp vor:)
        case element (tei:vorgang) return
            <span class="vorgang">{format:tei2html($node/node())}</span>
        
        (: ### W ###:)
        
        (: witness :)
        case element (tei:witness) return
            if ($node/parent::tei:listWit) then 
                <li class="witness">{format:tei2html($node/node())}</li>
            else <div class="witness">{format:tei2html($node/node())}</div>
        
        
        (:  workName:)
        case element (tei:workName) return
            
            if ($node//element()[@key]) then
                    let $keys := $node/@key/string() || "," || replace(string-join($node//element()[@key]/@key/string(),','), ' ', ',')
                    return
                    <a class="rs" href="register.html?key={$keys}">{$node//text()}</a>
                    else
            
            if ($node/@key) then
                if(contains($node/@key," ")) then
                    <a class="workName" href="register.html?key={replace($node/@key,' ',',')}&amp;type=w">{format:tei2html($node/node())}</a>
                    else
            
                    <a class="workName" href="register.html?key={$node/@key}&amp;type=w">{format:tei2html($node/node())}</a>
         else 
             <span class="workName-nolink">{format:tei2html($node/node())}</span>
         
            
        (: exist:match zu html:mark :)
            case element(exist:match) return
                <mark>{format:tei2html($node/node())}</mark>
        
        (: ### DEFAULT ###:)
                
        (: the following seven lines pass anything that isn't the element(exist:match) through without change :)
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    for $child in $node/node()
                    return
                        format:tei2html($child)
                }
            default return
                $node    
        
        
};


(: Popovers :)
declare function format:popover_kommentar($id) {
    (:liefert data-content="{format:popover_Kommentar($node/@xml:id)}" :)
    (: Wo ist der Kommetartext?: :)
    $id
    
};

declare function format:popover_person($key) {
    (: liefert data-content für Personen-popover :)
    for $person-id in tokenize($key, ' ') return
        let $surname := collection($config:data-root)/id($person-id)//tei:surname
        let $forename := collection($config:data-root)/id($person-id)//tei:forename
        return "<div>" || "<a class='popup-link' href='register.html?key=" || $person-id ||"&amp;type=p'>" || $surname || ", " || $forename || "</a>" || "</div>"
};

declare function format:popover_orgName($key) {
    (: liefert data-content für Organisationen-popover :)
    for $org-id in tokenize($key, ' ') return
        let $orgName := collection($config:data-root)/id($org-id)//tei:orgName
        let $desc := collection($config:data-root)/id($org-id)//tei:desc
        return "<div>" || "<a class='popup-link' href='register.html?key=" || $org-id ||"&amp;type=org'>" || $orgName || " (" || $desc || ")" || "</a>" || "</div>"
};
 

declare function format:popover_datum($node) {
    (:liefert data-content für Datums-popover:)
    if ($node/@when) then 
        $node/@when (:Hier muss man dann das Datum parsen:) else $node//text()
};

declare function format:popover_gap($node) {
    (: liefert data-content für gap-popover:)
    
    (: reason = G/gabelsberger, illegible, outOfScope, :)
    switch(lower-case($node/@reason))
    case "gabelsberger" return $node/@quantity || " Zeichen unentziffert (Gabelsberger)."
    case "illegible" return $node/@quantity || " Zeichen unentziffert."
    default return $node/@quantity || " Zeichen unentziffert. Grund: " || $node/@reason
};

declare function format:popover_handShift($node) {
    (:liefert data-content für den handShift-Popover:)
    "Schreiber: " || collection($config:data-root)/id($node/@scribe)//tei:surname || ", " || collection($config:data-root)/id($node/@scribe)//tei:forename || (if($node/@medium) then $node/@medium else ())
};


declare function format:popover_place($node) {
    (:liefert data-content für place-popover:)
    (:überarbeiten, wenn listPlace metadaten:)
    (:wenn alles @key hat, dann nicht $node übergeben, sondern nur mehr @key:)
    
    if ($node/@key) then
        for $place-id in tokenize($node/@key, ' ') return
            "<div>" || "<a class='popup-link' href='register.html?key=" || $place-id ||"&amp;type=o'>" || collection($config:data-root)/id($place-id)/tei:placeName || "</a>" || "</div>"
    else $node
};

declare function format:popover_work($node) {
    if ($node/@key) then
        for $work-id in tokenize($node/@key, ' ') return
            "<div>" || "<a class='popup-link' href='register.html?key=" || $work-id ||"&amp;type=w'>" || collection($config:data-root)/id($work-id)//tei:forename || ' ' || collection($config:data-root)/id($work-id)//tei:surname ||': ' || collection($config:data-root)/id($work-id)//tei:title || "</a>" || "</div>"
    else $node
};


declare function format:text-align($rend) {
    (: übernimmt das @rend-Attribut und setzt entsprechendes bootstrap-class-Attribut zur Ausrichtung:)
    switch ($rend)
    case "center" return "text-center"
    case "left" return "text-left"
    case "right" return "text-right"
    default return $rend
    
};