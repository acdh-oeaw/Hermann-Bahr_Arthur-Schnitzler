xquery version "3.1";

module namespace app="http://hbas.at/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace hbas="http://hbas.at/ns";


import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://hbas.at/config" at "config.xqm";
import module namespace format="http://hbas.at/format" at "format.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";


(: --------------------------- Test für die Startseite - später löschen  ----------------------------------------- :)
(: Filtert die Ausgegeben Files nach Dokumenttypen :)

declare
    %templates:wrap
function app:list-files($node as node(), $model as map(*), $type, $id) {
    let $data-path := 
    switch($type)
    case "T" return $config:data-root || "/texts"
    case "D" return $config:data-root || "/diaries"
    case "L" return $config:data-root || "/letters"
    default return $config:data-root
    let $data := collection($data-path)
    for $doc in $data//tei:TEI
return 
    $doc/@xml:id/string()
};


(: ---------------------- correspDesc-Metadaten ---------------------------- :)
(: deprecated :)
declare function app:corresp-meta($id) {
    let $corresp-data := collection($config:data-root)/id($id)//tei:correspDesc
    return
        <div class="correspMeta">
            <span class="sender">{$corresp-data/tei:sender}</span>
            <span class="addressee">{$corresp-data/tei:addressee}</span>
            <span class="placeSender">{$corresp-data/tei:placeSender}</span>
            <span class="placeAddressee">{$corresp-data/tei:placeAddressee}</span>
            <span class="dateSender">{$corresp-data/tei:dateSender}</span>
        </div>
    
};

declare
    %templates:wrap
function app:page-title($node as node(), $model as map(*)) {
    <div class="page-title-box">
                    <a href="index.html">
                    <h1 class="page-title">
                    <span class="page-title-main">Hermann Bahr </span> 
                    <span class="page-title-main">Arthur Schnitzler </span>
                    <span class="page-title-sub">Briefwechsel, </span>
                    <span class="page-title-sub">Aufzeichnungen, </span>
                    <span class="page-title-sub">Dokumente </span>
                    <span class="page-title-sub">1891–1931</span>
                    </h1>
                    </a>
    </div>
};


(: --------------------------- view.html - Seite  ----------------------------------------- :)

declare
 %templates:wrap
 %templates:default("type", "")
 function app:page_view($node as node(), $model as map(*),$id,$type,$date,$author,$show,$view-mode,$q) {
 (: 
  : Seite zeigt ein einzelnes Dokument an. Welches angezeigt werden soll, wird per $id übergeben.
  : $id xml:id des Dokuments
  : $type für Listenansicht: T texts, D diaries, L letters
  : $show steuert die Ansicht
 :)

let $output := if ($id!="") then
        app:view_single($id,$type,$show, $view-mode,$q)
    else
        app:view_list($type,$date,$author,$id,$q)
 return $output
 };

declare function app:view_list($type,$date,$author,$id,$q) {
    (:Gibt eine Liste mit allen verfügbaren Dokumenten aus:)
    if ($date!='' or $author!='') then 
        (:$date oder author gesetzt, weiter filtern:)
        if ($date!='') then
            (:"Datum gesetzt, Autor?":)
            if ($author!='') then  "Datum und Autor gesetzt" 
            
            else "Nur Datum gesetzt"
        else
            if ($type!='') then (: "Nur Autor gesetzt, Filter auf Typ":)
                if ($type="L") then "Briefe von einem Autor"
                else
            
            <div class="col-sm-9">
                <div class="title-box">
                <h2 class="doc-title">Nur Autor gesetzt, Filter auf Typ(aber nicht Brief)</h2>
            </div>
            </div>
            else
            (:nur Autor?:)
            if ($author='all') then app:view_verfasserliste()
            else
            (
        <div class="col-sm-9">
            <div class="title-box">
                <h2 class="doc-title">Verfügbare Dokumente von {collection($config:data-root)/id($author)//tei:forename || " " || collection($config:data-root)/id($author)//tei:surname}</h2>
            </div>
            {
            
            for $doc in collection($config:data-root)//tei:fileDesc//tei:titleStmt//tei:author[contains(@key,$author)]/ancestor::tei:TEI
        let $date := 
            switch (substring($doc/@xml:id/string(),1,1))
            case "T" return $doc//tei:origDate/@when/string()
            case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
            case "L" return $doc//tei:dateSender/tei:date/@when/string()
            default return $doc//tei:date[@when][1]/@when/string()
        order by $date ascending
            
    (:
    sortieren nach @when, @n:; bei Briefen sortieren nach senderDater > date ; bei Tagebuch body > date[1]
    bei Texten origDate
    :)
return
    <div class="docListItem">
        <span class="autor">{$doc//tei:titleStmt/tei:author/string()}</span>
        <a href="{concat('view.html?id=',$doc/@xml:id/string())}" class="title-link">{$doc//tei:titleStmt/tei:title[@level='a']/string()}</a>
    </div>
    }
        </div>,
        (:Briefe an:)
        
        if (collection($config:data-root)//tei:addressee//tei:persName[contains(@key,$author)]) then
        
        <div class="col-sm-9">
            <div class="title-box briefe-an">
                <h2 class="doc-title">Briefe an {collection($config:data-root)/id($author)//tei:forename || " " || collection($config:data-root)/id($author)//tei:surname}</h2>
            </div>
            {
                for $letter in collection($config:data-root)//tei:addressee/tei:persName[contains(@key,$author)]/ancestor::tei:TEI
                let $date := $letter//tei:dateSender/tei:date/@when/string()
                order by $date ascending
                return 
                    <div class="docListItem">
        <span class="autor">{$letter//tei:titleStmt/tei:author/string()}</span>
        <a href="{concat('view.html?id=',$letter/@xml:id/string())}" class="title-link">{$letter//tei:titleStmt/tei:title[@level='a']/string()}</a>
    </div>
            }
            
            
            
            
            
            
            
            
    </div>
    else ()
    )
    else (:$date oder $author nicht gesetzt:) 
    <div class="col-sm-9">
    <div class="title-box">
    <h2 class="doc-title">{
        switch($type)
                case "T" return "Texte"
                case "D" return "Tagebucheinträge"
                case "L" return "Briefe"
        default return "Inhalt"}
            
            </h2>
        </div>
    {
       let $data-path :=
       if ($type) then
            switch($type)
                case "T" return $config:data-root || "/texts"
                case "D" return $config:data-root || "/diaries"
                case "L" return $config:data-root || "/letters"
            default return $config:data-root
        else $config:data-root
    let $data := collection($data-path)
    for $doc in $data//tei:TEI[@xml:id]
        let $date := 
            switch (substring($doc/@xml:id/string(),1,1))
            case "T" return $doc//tei:origDate/@when/string()
            case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
            case "L" return $doc//tei:dateSender/tei:date/@when/string()
            default return $doc//tei:date[@when][1]/@when/string()
        order by $date ascending
            
    (:
    sortieren nach @when, @n:; bei Briefen sortieren nach senderDater > date ; bei Tagebuch body > date[1]
    bei Texten origDate
    :)
return
    <div class="docListItem doctype_{substring($doc/@xml:id/string(),1,1)}">
        <span class="autor">{$doc//tei:titleStmt/tei:author/string()}</span>
        <a href="{concat('view.html?id=',$doc/@xml:id/string())}" class="title-link">{$doc//tei:titleStmt/tei:title[@level='a']/string()}</a>
    </div>
    }
    </div>
};

declare function app:view_single($id,$type,$show, $view-mode,$q) {
    (:Gibt eine Einzelansicht eines Dokuments aus:)
    
    
    for $docid in tokenize($id,',') return
    <div id="content-box" class="col-sm-9">
        <div class="title-box">
            {
                
            (: fix #119:)
            if (contains($id,',')) then 
                <h2 class="doc-title">
                <a href="view.html?id={$docid}">
                    {collection($config:data-root)/id($docid)//tei:titleStmt//tei:title[@level='a']/text()}
                </a>
                </h2>
            else
            <h2 class="doc-title">{collection($config:data-root)/id($docid)//tei:titleStmt//tei:title[@level='a']/text()}</h2>
            
            }   
            <div class="authors">
            {for $authorkey in collection($config:data-root)/id($docid)//tei:titleStmt//tei:author/@key return
            <a class="author-link" href="view.html?author={$authorkey}">
            {collection($config:data-root)/id($authorkey)//tei:forename || " " || collection($config:data-root)/id($authorkey)//tei:surname}</a>
            }    
            </div>
        </div> <!-- /title-box -->
        <div class="text-box leseansicht">
            {format:tei2html(collection($config:data-root)/id($docid)//tei:text)}
            {
                if (collection($config:data-root)/id($docid)[.//tei:footNote]) then
                    app:do_footnotes($docid)
                    else ()
                
                
            }
        </div>
        <div class="anhang anhang-box collapse">
            {
                if (substring($docid,1,1)="L") then
                    <div class="correspDesc">
                        <span class="glyphicon glyphicon-envelope"></span>
                        <div class="sender-box">
                            <span class="sender">
                                {format:tei2html(collection($config:data-root)/id($docid)//tei:sender//tei:persName)}
                            </span>
                            {format:tei2html(collection($config:data-root)/id($docid)//tei:placeSender)}
                            {
                                if (collection($config:data-root)/id($docid)//tei:dateSender) then
                                format:tei2html(collection($config:data-root)/id($docid)//tei:dateSender)
                                else ()
                            }
                            
                        </div>
                        <div class="addressee-box">
                            {format:tei2html(collection($config:data-root)/id($docid)//tei:addressee)}
                            {format:tei2html(collection($config:data-root)/id($docid)//tei:placeAddressee)}
                            {format:tei2html(collection($config:data-root)/id($docid)//tei:dateAddressee)}
                        </div>
                    </div>
                    
                else ()
            }
            {
                if (collection($config:data-root)/id($docid)//tei:listWit) then
            <div class="witnessBox">
                <span class="glyphicon glyphicon-map-marker"></span>
                {format:tei2html(collection($config:data-root)/id($docid)//tei:listWit)}
            </div>
                else ()
            }
            {
            if (collection($config:data-root)/id($docid)//tei:listBibl) then
            <div class="biblBox">
            <span class="glyphicon glyphicon-book"></span>
                {format:tei2html(collection($config:data-root)/id($docid)//tei:listBibl)}
            </div>
            else ()
            }
            {
            if (collection($config:data-root)/id($docid)//tei:anchor[@type='commentary']) then
        <div id="kommentar" class="kommentar-box">
            {
                for $kommentar in collection($config:data-root)/id($docid)//tei:anchor[@type='commentary' or @type='textConst']
                return 
                    <div class="commentary-fn">
                        <sup class="fn-marker"><a id="FN_{$kommentar/@xml:id}"
                        href="#FN-ref_{$kommentar/@xml:id}"
                        >
                            {count($kommentar/preceding::tei:anchor[@type='commentary' or @type='textConst'])+1}
                        </a></sup>
                        <span class="lemma">{$kommentar}</span>
                        <span class="kommentar-txt">
                        {format:tei2html(collection($config:data-root||"/meta")/id($kommentar/@xml:id)//tei:p/node())}
                        </span>
                    </div>
            }
        </div>
        else ()
        }
            
        </div> <!-- /anhang-box -->
        
    </div>
    
    (: 
    <div class="row">
        <h2>{collection($config:data-root)/id($id)//tei:titleStmt/tei:title[@level='a']/text()}</h2>
        {
            if (substring($id,1,1)='L') then
                app:corresp-meta($id)
            else ()
        }
        
        {format:tei2html(collection($config:data-root)/id($id))}
    </div>
    :)
    
};

declare function app:view_verfasserliste() {
    <div class="col-sm-9">
                <div class="title-box">
                <h2 class="doc-title">Verfasserinnen und Verfasser</h2>
            </div>

            {
                for $verfasser-id in distinct-values(collection($config:data-root)//tei:fileDesc//tei:titleStmt//tei:author/@key) 
                let $vorname := collection($config:data-root)//id($verfasser-id)//tei:forename
                let $nachname := collection($config:data-root)//id($verfasser-id)//tei:surname
                order by $nachname
                return
                    <div class="docListItem">
                        <a href="view.html?author={$verfasser-id}">{concat(string-join($nachname, ' '), ', ', string-join($vorname, ' '))}</a>
                    </div>
            }
            </div>
            
};

(: Fußnoten :)
 declare function app:do_footnotes($docid) {
     <div class="footnotes">
     {
         for $footnote in collection($config:data-root)//id($docid)//tei:footNote return
            <div id="FN_{$footnote/@xml:id}" class="footnote">
                <a class="footnote-marker" href="#{$footnote/@xml:id}"><sup>{count($footnote/preceding::tei:footNote)+1}</sup></a>
                {format:tei2html($footnote/node())}
            </div>
     }
     </div>
 };

declare
    %templates:wrap
function app:prev-next($node as node(), $model as map(*),$id,$type,$view-mode,$show) {
    if ($id != "") then
        if (contains($id,',') or $id="E000001" or $id="E000002" or $id="E000003" or $id="E000004" or $id="E000005") then ()
        else
            if ($id="D041003") then 
                (: erster Eintrag :)
              
                
                <nav class="prev-next-pager">
                <ul class="pagerNew">
                    <!-- <li class="previous">
                    <a id="prev" href="view.html?id={app:prev-doc-id($id,$type)}&amp;type={$type}&amp;show={$show}&amp;view-mode={$view-mode}">
                    <span class="pager-button">&lt;</span>
                    <span class="pager-title">
                        {
                            let $id := app:prev-doc-id($id,$type)
                            return collection($config:data-root)//id($id)//tei:titleStmt/tei:title[@level='a']/string()
                        }
                    </span>
                        
                    </a></li> -->
                    <li class="next">
                    <a id="next" href="view.html?id={app:next-doc-id($id,$type)}&amp;type={$type}&amp;show={$show}&amp;view-mode={$view-mode}">
                    <span class="pager-button">&gt;</span>
                    <span class="pager-title">
                        {
                            let $id := app:next-doc-id($id,$type)
                            return collection($config:data-root)//id($id)//tei:titleStmt/tei:title[@level='a']/string()
                        }
                    </span>
                        
                    </a></li>
                </ul>
             </nav>
       
                
            else
            
    <nav class="prev-next-pager">
                <ul class="pagerNew">
                    <li class="previous">
                    <a id="prev" href="view.html?id={app:prev-doc-id($id,$type)}&amp;type={$type}&amp;show={$show}&amp;view-mode={$view-mode}">
                    <span class="pager-button">&lt;</span>
                    <span class="pager-title">
                        {
                            let $id := app:prev-doc-id($id,$type)
                            return collection($config:data-root)//id($id)//tei:titleStmt/tei:title[@level='a']/string()
                        }
                    </span>
                        
                    </a></li>
                    <li class="next">
                    <a id="next" href="view.html?id={app:next-doc-id($id,$type)}&amp;type={$type}&amp;show={$show}&amp;view-mode={$view-mode}">
                    <span class="pager-button">&gt;</span>
                    <span class="pager-title">
                        {
                            let $id := app:next-doc-id($id,$type)
                            return collection($config:data-root)//id($id)//tei:titleStmt/tei:title[@level='a']/string()
                        }
                    </span>
                        
                    </a></li>
                </ul>
             </nav>
    else 
        (:Inhaltsverzeichnis:)
        <nav class="prev-next-pager">
                <ul class="pagerNew">
                    <li class="next">
                    <a id="next" href="view.html?id=D041003&amp;view-mode=1">
                    <span class="pager-button">&gt;</span>
                    <span class="pager-title">
                        {
                            let $id := "D041003"
                            return collection($config:data-root)//id($id)//tei:titleStmt/tei:title[@level='a']/string()
                        }
                    </span>
                        
                    </a></li>
                </ul>
             </nav>
        
};


(: register.html :)

declare
 %templates:wrap
 function app:register_view($node as node(), $model as map(*),$key, $type) {
 (: 
  Seite zeigt einen Registereintrag an: 
  entweder einen Einzeleintrag, wenn $key gesetzt ist,
  oder eine Liste, wenn $type gesetzt ist: 
  Werte für $type: p(persName), o(placeName), w(workName)
  
 :)

let $output := if ($key!="") then
        app:register_single($key)
    else
        app:register_liste($type)
 return $output
 };



(: --------------------------- register-Liste  ----------------------------------------- :)

declare
function app:register_liste($type) {
    (: Werte für $type: p(persName), o(placeName), w(workName) :)
            <div class="col-sm-9">
                <div class="title-box">
                <h2 class="doc-title">Register</h2>
            </div>
            <div class="verfListHinweis">
                <a href="view.html?author=all">Verfasserverzeichnis</a>
            </div>
                <div class="filterSearch">
                <form class="filter_search">
                    <div class="input-group input-group-sm">
                        <input id="filter_register" type="text" class="form-control" placeholder="Suche...">
                    </input>
                </div>
                </form>
                </div>
                {
                    doc($config:data-root || "/meta/register.xml")//ul
                }
            </div>
};

declare function app:register_single($keys) {
        for $key in tokenize(replace($keys,' ',','),',')
        return
            <div class="row">
                <div class="col-sm-9">
                <div class="title-box">
              <h2>
                  {
                      switch(collection($config:data-root)/id($key)/name())
                      case "person" return 
                          (
                          if (collection($config:data-root)/id($key)//tei:forename and collection($config:data-root)/id($key)//tei:surname) then
                          collection($config:data-root)/id($key)//tei:forename || " " || collection($config:data-root)/id($key)//tei:surname
                          else 
                              (:nicht(Vorname AND Nachname):)
                              
                              (:"Vorname UND NICHT Nachname":)
                              if (collection($config:data-root)/id($key)//tei:forename and not(collection($config:data-root)/id($key)//tei:surname)) then collection($config:data-root)/id($key)//tei:forename else 
                                  
                                  (:"NICHT Vorname und Nachname":)
                                  if(not(collection($config:data-root)/id($key)//tei:forename) and collection($config:data-root)/id($key)//tei:surname) then collection($config:data-root)/id($key)//tei:surname else 
                              
                              
                              collection($config:data-root)/id($key)//tei:persName/text()
                          (:genauer ansehen!:)
                          
                          
                          ,
                          
                          if (collection($config:data-root)/id($key)//tei:birth/@when and collection($config:data-root)/id($key)//tei:death/@when) then
                              "(" || collection($config:data-root)/id($key)//tei:birth/@when || "–" || collection($config:data-root)/id($key)//tei:death/@when || ")"
                              else
                                  
                                  (:nur Geburtsdatum:)
                                  if (collection($config:data-root)/id($key)//tei:birth/@when and not(collection($config:data-root)/id($key)//tei:death/@when)) then 
                                      if (collection($config:data-root)/id($key)//tei:birth/tei:placeName) then
                                      (: Geburtsdatum und Geburtsort:)
                                      "(" || "*&#160;" ||  collection($config:data-root)/id($key)//tei:birth/@when || " " || collection($config:data-root)/id($key)//tei:birth/tei:placeName ||  ")"
                                      
                                      
                                      (:nur Geburtsjahr, kein Geburtsort:)
                                      else 
                                          
                                          "(" || "*&#160;" ||  collection($config:data-root)/id($key)//tei:birth/@when ||  ")"
                                      
                                      else 
                                      (:nur Todesjahr:)
                                      if (not(collection($config:data-root)/id($key)//tei:birth/@when) and collection($config:data-root)/id($key)//tei:death/@when) then 
                                          
                                          (:Todesjahr und Sterbeort:)
                                          if (collection($config:data-root)/id($key)//tei:death/tei:placeName) then
                                          
                                        "(" || "†&#160;" ||  collection($config:data-root)/id($key)//tei:death/@when || " " || collection($config:data-root)/id($key)//tei:death/tei:placeName ||  ")" 
                                        
                                        else 
                                            (: Nur Todesjahr, kein Sterbeort:)
                                            "(" || "†&#160;" ||  collection($config:data-root)/id($key)//tei:death/@when ||  ")"
                                        
                                          else ()
                                  
                                  
                                  
                                  ,
                                  
                            if (collection($config:data-root)/id($key)//tei:addName) then
                                <span>, {collection($config:data-root)/id($key)//tei:addName/text()}</span>
                                else (),
                                  
                          if (collection($config:data-root)/id($key)//tei:occupation) then
                              (
                              <br/>,collection($config:data-root)/id($key)//tei:occupation/text()
                              )
                              else ()
                          
                          
                          )
                      case "place" return 
                          (
                          if (collection($config:data-root)/id($key)//tei:district) then
                              if (contains(collection($config:data-root)/id($key)//tei:placeName,"Wien")) then collection($config:data-root)/id($key)//tei:settlement || " " || collection($config:data-root)/id($key)//tei:district
                              else collection($config:data-root)/id($key)//tei:placeName
                          else
                               collection($config:data-root)/id($key)//tei:placeName 
                              
                          )
                      case "biblFull" return 
                          (
                          if (collection($config:data-root)/id($key)//tei:title and collection($config:data-root)/id($key)//tei:author) then 
                              if (collection($config:data-root)/id($key)//tei:author//tei:surname) then
                                  collection($config:data-root)/id($key)//tei:author//tei:surname/text() || ": " || collection($config:data-root)/id($key)//tei:title/text()
                              else
                                  collection($config:data-root)/id($key)//tei:title/text() 
                          else "Werk " || $key
                          )
                      case "org" return 
                          (
                              if (collection($config:data-root)/id($key)//tei:orgName) then 
                                  (
                                  collection($config:data-root)/id($key)//tei:orgName,
                                  if (collection($config:data-root)/id($key)//tei:desc) then
                                      
                                      (
                                      <br/>,
                                      collection($config:data-root)/id($key)//tei:desc
                                      )
                                      else ()
                                  
                                  )
                                  else "Organisation " || $key
                          )
                          
                      default return $key
                  }
              </h2>
              
          </div>
          {
              (: Vollständig abgedruckte Werke:)
              if (collection($config:data-root)/id($key)/name() eq "biblFull" and collection($config:data-root)//tei:titleStmt/tei:title[contains(@key,$key)]) then 
                    <div>
                        <a href="view.html?id={collection($config:data-root)//tei:TEI[.//tei:titleStmt/tei:title[contains(@key,$key)]]/@xml:id/string()}">{collection($config:data-root)/id($key)//tei:author//tei:surname/text() || ": " || collection($config:data-root)/id($key)//tei:title/text()}
                        </a>
                    </div>
                  else ()
          }
      </div>
      </div>,
      <div class="register-meta">
          {
              if (not(contains($keys, ','))) then
                switch (collection($config:data-root)/id($keys)/name())
                case "person" return
                (
                <p>{"*&#160;" || collection($config:data-root)/id($keys)//tei:birth/@when/string() || " " || collection($config:data-root)/id($keys)//tei:birth/tei:placeName}</p>,
                <p>{"†&#160;" || collection($config:data-root)/id($keys)//tei:death/@when/string() || " " || collection($config:data-root)/id($keys)//tei:death/tei:placeName}
                </p>,
                
                if (collection($config:data-root)/id($keys)//tei:idno[@type='GND']) then
                    <p>GND: <a href="http://d-nb.info/gnd/{collection($config:data-root)/id($keys)//tei:idno[@type='GND']/string()}">{collection($config:data-root)/id($keys)//tei:idno[@type='GND']/string()}</a></p> else ()
                
                
                )
                    
                case "place" return (: "Ort-Meta" :) ""
                case "biblFull" return 
                    
                        (
                        if (collection($config:data-root)/id($keys)//tei:ab[@type="Auffuehrung"]) then
                            <p>
                            {collection($config:data-root)/id($keys)//tei:ab[@type="Auffuehrung"]}
                            </p>
                            else ""
                        ,
                        
                    if (collection($config:data-root)/id($keys)//tei:ab[@type="Bibliografie"]) then
                        collection($config:data-root)/id($keys)//tei:ab[@type="Bibliografie"]/text()
                        else 
                            if (collection($config:data-root)/id($keys)//tei:ab[@type="Erscheinungsdatum"])
                            then 
                                <p>{collection($config:data-root)/id($keys)//tei:ab[@type="Erscheinungsdatum"]/text()}</p>
                                else ""
                        )
                    
            
                case "org" return (: "Organisations-Meta" :) ""
                default return ""
              else ()
          }
      </div>
      ,
        <div class="search-hits">
          {
              let $liste :=
                for $key in tokenize($keys,',') return
                    for $doc in (collection($config:data-root)//tei:body//element()[contains(@key,$key)]/ancestor::tei:TEI[@xml:id], collection($config:data-root)//tei:note[@xml:id]//element()[contains(@key,$key)]/ancestor::tei:note, collection($config:data-root)//tei:physDesc//element()[contains(@key,$key)]/ancestor::tei:TEI)
                    (:issue #108 – physDesc :)
                    let $sortdate :=
                    switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        case "K" return () (:Kommentar:)
                        default return $doc//tei:date[@when][1]/@when/string()
                    order by $sortdate
                    return
                       <div class="search-hit" data-docdate="{$sortdate}">
                <span class="hit-title">
                <a href="view.html?id={
                
                    
                    if (substring($doc/@xml:id/string(),1,1)="K") then 
                        collection($config:data-root)//id($doc/@xml:id)/ancestor::tei:TEI/@xml:id 
                        else (:kein Kommentar:)
                    $doc/@xml:id
                    
                }">{
                    
                    
                    if (substring($doc/@xml:id/string(),1,1)="K") then 
                        (
                        "Kommentar zu: ",
                        collection($config:data-root)//id($doc/@xml:id)/ancestor::tei:TEI/tei:titleStmt/tei:title[@level="a"]/text()
                        ) else
                    $doc//tei:titleStmt/tei:title[@level="a"]/text()
                }</a>
                </span>
                <p>
                    { 
                        
                        for $hit in $doc//tei:body//element()[contains(@key,$key)]
                        return
                            (
                            <span class="previous">... 
                            {
                                
                                let $prev := string-join($hit/preceding-sibling::node())
                                let $len := string-length($prev)-60
                                return substring($prev,$len) 
                            }</span>,
                            <span class="hi">{$hit}</span>,
                            <span class="following">{substring(string-join($hit/following-sibling::node()),1,60)} ...</span>
                            )
                            
                    }
                </p>
            </div> 
      return
          $liste      
         }
      </div>  
};


declare
    %templates:wrap
function app:nav($node as node(), $model as map(*)) {
    (:Navigation:)
    <nav class="navbar navbar-default" role="navigation">
                        <div class="navbar-header">
                            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#menu">
                                <span class="sr-only">Toggle navigation</span>
                                <span class="icon-bar"/>
                                <span class="icon-bar"/>
                                <span class="icon-bar"/>
                            </button>
                            <span class="visible-xs navbar-brand">Menü</span>
                        </div> <!-- /.navbar-header -->
                        <div id="menu" class="navbar-collapse collapse">
                            <ul class="nav navbar-nav">
                                <li class="dropdown visible-xs" id="nav_home">
                                    <a href="index.html">Home</a>
                                </li>
                                <li class="dropdown hidden-md hidden-lg" id="nav_dokumente">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Inhalt</a>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <a href="view.html?type=L">Briefe</a>
                                        </li>
                                        <li>
                                            <a href="view.html?type=D">Aufzeichnungen</a>
                                        </li>
                                        <li>
                                            <a href="view.html?type=T">Texte</a>
                                        </li>
                                    </ul>
                                </li> 
                                <li class="hidden-xs hidden-sm">
                                    <a href="view.html">Inhalt</a>
                                </li>
                                <!-- /Inhalt -->
                                <li class="dropdown" id="nav_kalender">
                                    <a href="calendar.html">Kalender</a>
                                </li>
                                
                                <li class="dropdown" id="nav_suche">
                                    <a href="search.html">Suche</a>
                                </li> <!-- /Suche -->
                                
                                <li class="dropdown hidden-md hidden-lg" id="nav_register">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Register</a>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <a href="register.html?type=p">Personen</a>
                                        </li>
                                        <li>
                                            <a href="register.html?type=w">Werke</a>
                                        </li>
                                        <li>
                                            <a href="register.html?type=o">Orte</a>
                                        </li>
                                        <li>
                                            <a href="register.html?type=org">Verlage, Körperschaften u.a.</a>
                                        </li>
                                        
                                        
                                    </ul>
                                </li> 
                                <li class="hidden-xs hidden-sm">
                                    <a href="register.html">Register</a>
                                </li>
                                <!-- /Register -->


                                <li class="dropdown" id="nav_ueber">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Zur Edition</a>
                                    <ul class="dropdown-menu">
                                        <li>
                                                <a href="impressum.html">Impressum</a>
                                            </li>
                                            
                                        <li>
                                                <a href="view.html?id=E000003">Buchausgaben</a>
                                            </li>
                                         <li>
                                                <a href="view.html?id=E000006">Theaterbesuche</a>
                                            </li>
                                         <li>
                                                <a href="view.html?id=E000007">Aus Schnitzlers Tagebuch</a>
                                            </li>    
                                        <li>
                                                <a href="view.html?id=E000001">Editorische Richtlinien</a>
                                            </li>
                                        <li>
                                                <a href="view.html?id=E000005">Korrespondenz Bahr–Schnitzler</a>
                                            </li>
                                        <li>
                                                <a href="view.html?id=E000002">Nachwort</a>
                                            </li>
                                        <li>
                                                <a href="view.html?id=E000004">Dank</a>
                                            </li>
                                    </ul>
                                </li> <!-- /About -->


                            </ul> <!-- /Navigations-Liste -->
                        </div> <!--/.nav-collapse -->
        </nav>
};


declare
    %templates:wrap
function app:inhalt-liste($node as node(), $model as map(*)) {
    (:Funktioniert nicht, wegen der Session:)
    for $doc in app:meta-docs(1,100) return
        <li>{$doc/title/text()}</li>
};

declare function app:meta-docs($start,$n) {
    
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
    (: only return $n nodes starting at $start nodes :)
    
    for $doc in subsequence($docs, $start, $n)
    return 
        $doc
    
};

declare function app:order-ids() {
    let $ids :=
    for $doc in collection($config:data-root)/tei:TEI
    let $id := $doc/@xml:id/string()
    let $date := 
            switch (substring($id,1,1))
            case "L" return $doc//tei:dateSender/tei:date/@when/string()
            case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
            case "T" return $doc//tei:origDate/@when/string()
            default return "none"
        order by $date ascending
    return 
        <id type="{substring($id,1,1)}">{$id}</id>
    return
        <ids>{$ids}</ids>
};

declare function app:next-doc-id($id,$type) {
    (:Liefert das folgende Dokument;nutzt die Session wahrscheinlich nicht:)
    let $ordered-ids :=
        if (session:get-attribute("ids")) then
            session:get-attribute("ids")
        else 
            session:set-attribute("ids", app:order-ids())
    return
        if ($type!='') then
            $ordered-ids//id[text()=$id]/following-sibling::id[@type=$type][1]
            else
        $ordered-ids//id[text()=$id]/following-sibling::id[1]
    (: 
    app:order-ids()//id[text()=$id]/following-sibling::id[1]
    :)
    
};

declare function app:prev-doc-id($id,$type) {
    (:Liefert das folgende Dokument;nutzt die Session wahrscheinlich nicht:)
    let $ordered-ids :=
        if (session:get-attribute("ids")) then
            session:get-attribute("ids")
        else 
            session:set-attribute("ids", app:order-ids())
    return
        if ($type!='') then
            $ordered-ids//id[text()=$id]/preceding-sibling::id[@type=$type][1]
            else
        $ordered-ids//id[text()=$id]/preceding-sibling::id[1]
    (: 
    app:order-ids()//id[text()=$id]/following-sibling::id[1]
    :)
    
};

(: Filteroptionen für Register :)
 (: app:register_filter :)
 declare
     %templates:wrap
 function app:register_filter($node as node(), $model as map(*),$key) {
    if (not($key)) then
        <form class="filter_form">
            <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_register_P" checked="checked"> Personen</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_register_T" checked="checked"> Werke</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_register_O" checked="checked"> Orte</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_register_Org" checked="checked"> Verlage, Körperschaften u.a.</input>
            </label>
        </div>
            
        </form>
    else ()
 };


declare
    %templates:wrap
function app:settings($node as node(), $model as map(*),$show, $view-mode, $id) {
    if ($id != "") then
        
        if (contains($id,',')) then (:fix #119: Wenn mehrere Dokumente angezeigt werden, Filterbox nicht ausgeben:) ()
        else
        
    <form class="filter_form">
        <!-- 
        <select id="select-view-mode" class="custom-select">
            <option>Leseansicht</option>
            <option>Erweiterte Ansicht</option>
        </select>
        -->
        <div class="checkbox">
            <label>
                <input type="checkbox" id="check_auszeichnungen" > Markierungen</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="check_anhang" data-toggle="collapse" data-target="#anhang"> Anhang</input>
            </label>
        </div>
        
    </form>
    else 
        (: Listenansicht :)
        <form class="hidden-xs hidden-sm filter_form">
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_doctype_L" checked="checked"> Briefe</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_doctype_D" checked="checked"> Aufzeichnungen</input>
            </label>
        </div>
        <div class="checkbox">
            <label>
                <input type="checkbox" id="toggle_doctype_T" checked="checked"> Dokumente</input>
            </label>
        </div>
        </form>
        
};

(: --------------------------- search.html - Seite  ----------------------------------------- :)
(: Suche :)
declare
    %templates:wrap
function app:searchbox($node as node(), $model as map(*),$q) {
   <form class="form-inline" action="search.html">
            <div class="form-group col-sm-7">
                <label class="sr-only" for="Suche_Suchfeld">Volltextsuche im Datenbestand</label>
                <div class="input-group input-group-lg">
                    <input type="text" class="form-control" id="Suche_Suchfeld" name="q" 
                placeholder="{if ($q!='') then $q else "Suche..."}"/>
                <span class="input-group-btn">
                    <button class="btn btn-default" type="submit"><span class="glyphicon glyphicon-search"></span></button>
                </span>
                </div>
                
            </div>
            
        </form>,
        <div>
        <!--
        <a href="">Erweiterte Suche</a>
        -->
        </div>
};

declare
    %templates:wrap
    %templates:default("orderby", "date")
function app:search_results($node as node(), $model as map(*),$q,$type,$orderby) {
    app:format_searchresults(app:search($q, $type), $q, $type, $orderby)
};

declare
function app:search($q,$type) {
    (: --------------- Die Suchfunktion -------------------------- :)
    (:
     : $q Suchstring
     : $type
     
     Die Funktion liefert XML-Elemente zurück <hit ft-score="">TEI-item-Element</hit>
     
     :)
    let $ergebnisse :=
    (:Überprüfen, ob ein Suchstring gesetzt ist:)
    if ($q!="") then 
        (:Suchstring ist vorhanden, Suche starten:)
        (:Überprüfen, ob Filter gesetzt sind, wenn ja, dann anpassen, wo gesucht wird:)
        (:Optionen überprüfen, entsprechend den Ergebnissen Suchkontext $kontext setzen. Kontext enthält die entsprechenden Daten, in denen gesucht wird:)
            (:Überprüfen, ob nur innerhalb von bestimmten Einträgen gesucht werden soll, dann entfällt nämlich die weitere Kontext-Einschränkung, nicht aber die $w-switches:)
            
                                    (:überall, kein Filter:)
                                    for $hit in collection($config:data-root)//tei:div[ft:query(.,$q)]
                                    let $ft-score := ft:score($hit)
                                    let $docid := $hit/ancestor::tei:TEI/@xml:id
                                    let $docdate := 
                                        switch (substring($docid,1,1))
                                        case "L" return collection($config:data-root)/id($docid)//tei:dateSender/tei:date/@when/string()
                                        case "D" return collection($config:data-root)/id($docid)//tei:text//tei:date[@when][1]/@when/string()
                                        case "T" return collection($config:data-root)/id($docid)//tei:origDate/@when/string()
                                        default return "0000-00-00"
                                    let $doctitle := $hit/ancestor::tei:TEI//tei:titleStmt//tei:title[@level='a']/text()
                                    return 
                                        <hit docid="{$docid}" doctitle="{$doctitle}" docdate="{$docdate}" ft-score="{$ft-score}">
                                            {kwic:expand($hit)}
                                        </hit>
                                        
    else ()
    (:Kein Suchstring angegeben, deswegen wird das Suchfeld angezeig:)
    return
        $ergebnisse

};

declare function app:format_searchresults($ergebnisse, $q, $type, $orderby) {
    (:Funktion, die eine Ergebnisliste für die Suchergebnisse aus app:suche erstellt. Übernimmt alle Suchfilterparameter + die Ergebnisse der Suche $ergebnisse:)
    (:momentan gibt das Zeugs eine Tabelle aus, aber man könnte wahrscheinlich noch mehr machen, wenn man weitere Parameter, z.B. einen $stil, $zielformat oder so etwas übergibt:)
     if ($q !='') then
     <div>
     <h3>Ergebnisse:</h3>
     <div id="Ergebnisuebersicht">
        <strong>{count($ergebnisse)} Treffer für "{$q}"</strong>
    </div>
        <div class="search-hits">
        {
         for $hit in $ergebnisse
         order by $hit/@docdate
         return 
            <div class="search-hit" data-docdate="{$hit/@docdate}" data-ftScore="{$hit/@ft-score}">
                <span class="hit-title">
                <a href="view.html?id={$hit/@docid/string()}&amp;q={$q}">{$hit/@doctitle/string()}</a>
                </span>
                {kwic:summarize($hit, <config width="60"/>)}
            </div>
        }
     
     </div>
     </div>
     else ()
};


