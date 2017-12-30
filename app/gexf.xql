xquery version "3.1";


declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://hbas.at/config" at "modules/config.xqm";


let $output :=
for $doc in collection($config:data-root || "/letters")/tei:TEI[@xml:id]
    let $docID := $doc/@xml:id/string()
    let $date :=  switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return $doc//tei:origDate/@when/string()
                        case "D" return $doc//tei:text//tei:date[@when][1]/@when/string()
                        case "L" return $doc//tei:dateSender/tei:date/@when/string()
                        default return $doc//tei:date[@when][1]/@when/string()
    
    let $iso-date := substring($date,1,4) || "-" || substring($date,5,2)  || "-" || substring($date,7,2)
    let $title := $doc//tei:titleStmt/tei:title[@level='a']/string()
    let $doctype := switch (substring($doc/@xml:id/string(),1,1))
                        case "T" return "text"
                        case "D" return "diary"
                        case "L" return "letter"
                        default return "other"
    let $authorKey := $doc//tei:titleStmt/tei:author/@key/string()
    let $sender := string-join($doc//tei:correspDesc//tei:sender/tei:persName/@key/string(), ';')
    let $addressee := string-join($doc//tei:correspDesc//tei:addressee/tei:persName/@key/string(),';')
                    order by $date
return
       if (count(tokenize($sender,';'))>1 or count(tokenize($addressee,';'))>1) then 
           (:mehrere Sender und/oder Empfänger:)
           if ((count(tokenize($sender,';'))>1 and not(count(tokenize($addressee,';'))>1))) then
               (:mehrere Sender, aber nur 1 Empfänger:)
               for $single-sender in tokenize($sender,';') return
                   <edge xmlns="http://www.gexf.net/1.2draft" id="{$docID || '-' || $single-sender}" source="{$single-sender}" target="{$addressee}" start="{$iso-date}" end="{$iso-date}"/>
           else
               (:mehrere Empfänger und vielleicht mehrere Sender:)
               if (count(tokenize($sender,';'))>1) then
                   (:mehrere Empfänger, aber nur 1 Sender:)
                    for $single-addressee in tokenize($addressee,';') return
                        <edge xmlns="http://www.gexf.net/1.2draft" id="{$docID || '-' || $single-addressee}" source="{$sender}" target="{$single-addressee}" start="{$iso-date}" end="{$iso-date}"/>


                   else (:mehrere Sender und mehrere Empfänger:)
                        for $single-sender in tokenize($sender,';') return
                            for $single-addressee in tokenize($addressee,';') return
                               <edge xmlns="http://www.gexf.net/1.2draft" id="{$docID || '-' || $single-sender || '-' || $single-addressee}" source="{$single-sender}" target="{$single-addressee}" start="{$iso-date}" end="{$iso-date}"/> 
       else
       <edge xmlns="http://www.gexf.net/1.2draft" id="{$docID}" source="{$sender}" target="{$addressee}" start="{$iso-date}" end="{$iso-date}"/>
return
    <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
        <meta lastmodifieddate="{current-date()}">
            <creator>Ingo Boerner</creator>
            <description>Network based on Letters in "Hermann Bahr – Arthur Schnitzler: Briefwechsel, Aufzeichnungen, Dokumente (1891–1931)" edited by Kurt Ifkovits and Martin Anton Müller (bahrschnitzler.acdh.oeaw.ac.at).</description>
   </meta>
    <graph mode="dynamic" defaultedgetype="directed" timeformat="date">
        <nodes>
            {
                for $person in distinct-values(collection($config:data-root || "/letters")/tei:TEI[@xml:id]//tei:correspDesc//tei:persName/@key/string())
                let $name := string-join(collection($config:data-root)/id($person)//tei:surname,'') ||', ' || normalize-space(string-join(collection($config:data-root)/id($person)//tei:forename,'')) 
                return
                    <node id="{$person}" label="{$name}"/>
            }
        </nodes>
        <edges>
            {$output}
        </edges>
    </graph>
    </gexf>
