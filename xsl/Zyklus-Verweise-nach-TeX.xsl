<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:foo="whatever"
                version="3.0">
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>
  <!-- subst root persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc sender addressee placeSender placeAddressee context date witnessdate -->

   <!-- Globale Parameter -->

  <xsl:param name="persons" select="document('personen.xml')"/>
  <xsl:param name="works" select="document('werke.xml')"/>
  <xsl:param name="orgs" select="document('organisationen.xml')"/>
  <xsl:param name="places" select="document('orte.xml')"/>
  
  <xsl:key name="person-lookup" match="row" use="Nummer"/>
  <xsl:key name="work-lookup" match="row" use="Nummer"/>
  <xsl:key name="org-lookup" match="row" use="Nummer"/>
  <xsl:key name="place-lookup" match="row" use="Nummer"/>
    
   <xsl:param name="first" as="xs:string"/> 
   <!-- Enthält den Anfang eines Strings (bspw. "A00022") -->
    <xsl:param name="last" as="xs:string"/> 
   <!-- Enthält den Rest des Strings first -->
 
   <!-- Funktionen -->

   <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
   <xsl:function name="foo:umlaute-entfernen">
      <xsl:param name="umlautstring"/>
      <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E'), 'È', 'E'),'ò', 'o'), 'Č', 'C'), 'D’','D'), 'd’','D'), 'Ś', 'S'), '’', ' '), 'xxkaufmannsund', 'und'), 'ë', 'e')"/>
   </xsl:function>
   
   <!-- Ersetzt im übergegeben String die Kaufmannsund -->
   <xsl:function name="foo:sonderzeichen-ersetzen">
      <xsl:param name="sonderzeichen"/>
      <xsl:value-of select="replace($sonderzeichen, '&amp;', '{\\kaufmannsund} ')"/>
   </xsl:function>
   
   <!-- Gibt zwei Werte zurück: Den Indexeintrag zum sortieren und den, wie er erscheinen soll -->
   <xsl:function name="foo:index-sortiert">
      <xsl:param name="index-sortieren"/>
      <xsl:param name="shape" as="xs:string"/>
      <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($index-sortieren))"/>
      <xsl:text>@</xsl:text>
      <xsl:choose>
         <xsl:when test="$shape = 'sc'">
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$shape = 'it'">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   
   
   
   <!-- Diese Funktion setzt den Inhalt eines Index-Eintrags einer Person. Übergeben wird nur der key -->
   <xsl:function name="foo:person-fuer-index">
      <xsl:param name="xkey" as="xs:string"/>
      <xsl:variable name="indexkey" select="key('person-lookup', $xkey, $persons)" as="node()?"/>
      <xsl:variable name="kNachname" as="xs:string?" select="normalize-space($indexkey/Nachname)"/>
      <xsl:variable name="kVorname" as="xs:string?" select="normalize-space($indexkey/Vorname)"/>
      <xsl:variable name="kZusatz" as="xs:string?" select="normalize-space($indexkey/Zusatz)"/>
      <xsl:variable name="kBeruf" as="xs:string?" select="normalize-space($indexkey/Beruf)"/>
      <xsl:variable name="kGeburtsdatum" as="xs:string?" select="normalize-space($indexkey/Geburtsdatum)"/>
      <xsl:variable name="kGeburtsort" as="xs:string?" select="normalize-space($indexkey/Geburtsort)"/>
      <xsl:variable name="kTodesdatum" as="xs:string?" select="normalize-space($indexkey/Todesdatum)"/>
      <xsl:variable name="kTodesort" as="xs:string?" select="normalize-space($indexkey/Todesort)"/>
      <xsl:choose>
         <xsl:when test="normalize-space($kNachname) = '??'">
            <xsl:choose>
               <xsl:when test="substring($kBeruf,1,3) = 'A00'">
                  <xsl:value-of select="foo:person-fuer-index(substring-before($kBeruf,' '))"/>
                  <xsl:text>!0</xsl:text>
                  <xsl:value-of select="foo:index-sortiert(substring-after($kBeruf,' '), 'sc')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>00anonym@Nicht ermittelte Personen!</xsl:text>
                  <xsl:if test="not($kBeruf = '')">
                     <xsl:value-of select="foo:index-sortiert($kBeruf, 'sc')"/>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="not($kVorname='') and not($kNachname='')">
            <xsl:value-of select="foo:index-sortiert(concat($kNachname, ', ', $kVorname), 'sc')"/>
         </xsl:when>
         <xsl:when test="not($kVorname='') and $kNachname=''">
            <xsl:value-of select="foo:index-sortiert($kVorname, 'sc')"/>
         </xsl:when>
         <xsl:when test="$kVorname='' and not($kNachname='')">
            <xsl:value-of select="foo:index-sortiert($kNachname, 'sc')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{XXXXXX INDEXFEHLER}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not($kZusatz = '')">
         <xsl:text>, </xsl:text>
         <xsl:value-of select="$kZusatz"/>
         <xsl:text/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="not(empty($kGeburtsdatum)) and not($kGeburtsdatum='')">
            <xsl:text> (</xsl:text>
            <xsl:choose>
               <xsl:when test="not(empty($kTodesdatum)) and not($kTodesdatum='')">
                  <xsl:value-of select="$kGeburtsdatum"/>
                  <xsl:choose>
                     <xsl:when test="not(empty($kGeburtsort)) and not($kGeburtsort='')">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="replace($kGeburtsort, '/', '{\\slash}')"/>
                        <xsl:text> </xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:text>–</xsl:text>
                  <xsl:choose>
                     <xsl:when test="not(empty($kTodesort)) and not($kTodesort='')">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$kTodesdatum"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="replace($kTodesort, '/', '{\\slash}')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$kTodesdatum"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose><!-- Für Personen, bei denen nur das Jahrhundert bekannt ist, in dem sie lebten -->
                     <xsl:when test="contains($kGeburtsdatum, 'Jh.')">
                        <xsl:value-of select="$kGeburtsdatum"/>
                        <xsl:choose>
                           <xsl:when test="not(empty($kGeburtsort)) and not($kGeburtsort='')">
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="$kGeburtsort"/>
                           </xsl:when>
                        </xsl:choose>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>* </xsl:text>
                        <xsl:value-of select="$kGeburtsdatum"/>
                        <xsl:choose>
                           <xsl:when test="not(empty($kGeburtsort)) and not($kGeburtsort='')">
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="replace($kGeburtsort, '/', '{\\slash}')"/>
                           </xsl:when>
                        </xsl:choose>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
         </xsl:when>
         <xsl:when test="not(empty($kTodesdatum)) and not($kTodesdatum='')">
            <xsl:text> (</xsl:text>
            <xsl:text>† </xsl:text>
            <xsl:value-of select="$kTodesdatum"/>
            <xsl:choose>
               <xsl:when test="not(empty($kTodesort)) and not($kTodesort='')">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="replace($kTodesort, '/', '{\\slash}')"/>
               </xsl:when>
            </xsl:choose>
            <xsl:text>)</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="not($kBeruf='') and not($kNachname='??')">
         <xsl:text>, \emph{</xsl:text><xsl:value-of select="normalize-space($kBeruf)"/><xsl:text>}</xsl:text>
         <xsl:text/>
      </xsl:if>
   </xsl:function>
   
   
   <xsl:function name="foo:personen-key-check" as="xs:boolean">
      <xsl:param name="indexkey" as="xs:string"/>
      <xsl:sequence select="string-length($indexkey) != 7 or not(starts-with($indexkey,'A002') or starts-with($indexkey,'A003') or starts-with($indexkey,'A004'))"/> 
   </xsl:function>
   
   <xsl:function name="foo:werke-key-check" as="xs:boolean">
      <xsl:param name="indexkey" as="xs:string"/>
      <xsl:sequence select="string-length($indexkey) != 7 or not(starts-with($indexkey,'A020') or starts-with($indexkey,'A021'))"/> 
   </xsl:function>
   
   <xsl:function name="foo:orte-key-check" as="xs:boolean">
      <xsl:param name="indexkey" as="xs:string"/>
      <xsl:if test="not(empty($indexkey))">
         <xsl:sequence select="string-length($indexkey) != 7 or not(starts-with($indexkey,'A001') or starts-with($indexkey,'A000'))"/>
      </xsl:if>
   </xsl:function>
   
   <xsl:function name="foo:werk-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:variable name="work-entry" select="key('work-lookup', $first, $works)"/>
      <xsl:variable name="zyklus-entry" select="key('work-lookup', substring($work-entry/Zyklus,1, 7), $works)"/>
      <xsl:choose>
         <xsl:when test="($work-entry/Autor ='') and $im-text">
            <xsl:text>\pwindex{</xsl:text>
         </xsl:when>
         <xsl:when test="($work-entry/Autor ='') and not($im-text)">
            <xsl:text>\pwindex{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:person-in-index($work-entry/Autor,$im-text)"/>
            <xsl:text>!</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <!-- Sonderbehandlung für Bahrs Tagebuch-Kolumne -->
      <xsl:choose>
         <xsl:when test="$work-entry/Autor='A002002' and starts-with($work-entry/Titel,'Tagebuch')">
            <xsl:text>Tagebuch@\emph{– Tagebuch}!</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with($work-entry/Titel,'Tagebuch. ')">
                  <xsl:value-of select="tokenize($work-entry/Bibliografie,' ')[last()]"/>
                  <xsl:choose>
                     <xsl:when test="string-length(tokenize($work-entry/Bibliografie,' ')[last()-1]) = 2">
                        <xsl:text>0</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:value-of select="tokenize($work-entry/Bibliografie,' ')[last()-1]"/>
                  <xsl:choose>
                     <xsl:when test="string-length(tokenize($work-entry/Bibliografie,' ')[last()-2]) = 2">
                        <xsl:text>0</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:value-of select="tokenize($work-entry/Bibliografie,' ')[last()-2]"/>
                  <xsl:value-of select="$work-entry/Titel"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                  <xsl:value-of select="$work-entry/Titel"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>@\emph{</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with($work-entry/Titel,'Tagebuch. ')">
                  <xsl:value-of select="substring-after($work-entry/Titel,'Tagebuch. ')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <xsl:when test="starts-with($work-entry/Titel,'Tagebuch ')">
                        <xsl:value-of select="substring-after($work-entry/Titel,'Tagebuch ')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>XXXXX </xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with($work-entry/Titel,'Tagebuch ')">
                  <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:if test="$work-entry/Bibliografie!=''">
                     <xsl:text>, </xsl:text>
                     <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="not(normalize-space($work-entry/Zyklus) ='')">
            <xsl:value-of select="foo:werk-kuerzen($zyklus-entry/Titel)"/>
            <xsl:text>@\emph{– </xsl:text>
            <xsl:apply-templates select="foo:sonderzeichen-ersetzen($zyklus-entry/Titel)"/>
            <xsl:text>}</xsl:text>
            <xsl:choose>
               <xsl:when test="$zyklus-entry/Bibliografie!='' and $zyklus-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($zyklus-entry/Bibliografie)"/>
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($zyklus-entry/Aufführung)"/>
               </xsl:when>  
               <xsl:when test="$zyklus-entry/Bibliografie!='' and $zyklus-entry/Aufführung =''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($zyklus-entry/Bibliografie)"/>
               </xsl:when>  
               <xsl:when test="$zyklus-entry/Bibliografie='' and $zyklus-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($zyklus-entry/Aufführung)"/>
               </xsl:when>  
            </xsl:choose>
            <xsl:text>!</xsl:text>
            <xsl:value-of select="substring-after($work-entry/Zyklus,',')"/>
            <xsl:apply-templates select="foo:werk-kuerzen($work-entry/Titel)"/>
            <xsl:text>@\emph{– </xsl:text>
            <xsl:choose>
               <xsl:when test="$work-entry/Autor='A002003' and starts-with($work-entry/Titel,'[O. V.:] ')">
                  <xsl:apply-templates select="substring(foo:sonderzeichen-ersetzen($work-entry/Titel), 9)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="foo:sonderzeichen-ersetzen($work-entry/Titel)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:choose>
               <xsl:when test="$work-entry/Bibliografie!='' and $work-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Aufführung)"/>
               </xsl:when>  
               <xsl:when test="$work-entry/Bibliografie!='' and $work-entry/Aufführung =''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
               </xsl:when>  
               <xsl:when test="$work-entry/Bibliografie='' and $work-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Aufführung)"/>
               </xsl:when>  
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="foo:werk-kuerzen($work-entry/Titel)"/>
            <xsl:text>@\emph{– </xsl:text>
            <xsl:choose>
               <xsl:when test="$work-entry/Autor='A002003' and starts-with($work-entry/Titel,'[O. V.:] ')">
                  <xsl:apply-templates select="substring(foo:sonderzeichen-ersetzen($work-entry/Titel), 9)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="foo:sonderzeichen-ersetzen($work-entry/Titel)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:choose>
               <xsl:when test="$work-entry/Bibliografie!='' and $work-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Aufführung)"/>
               </xsl:when>  
               <xsl:when test="$work-entry/Bibliografie!='' and $work-entry/Aufführung =''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
               </xsl:when>  
               <xsl:when test="$work-entry/Bibliografie='' and $work-entry/Aufführung !=''">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="foo:date-translate($work-entry/Aufführung)"/>
               </xsl:when>  
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:choose>
        <xsl:when test="not(normalize-space($work-entry/Zyklus) ='')">
           <xsl:text>\pwindex{</xsl:text>
           <xsl:value-of select="foo:person-in-index($work-entry/Autor,$im-text)"/>
           <xsl:text>!</xsl:text>
           <xsl:apply-templates select="foo:werk-kuerzen($zyklus-entry/Titel)"/>
           <xsl:text>@\emph{– </xsl:text>
           <xsl:apply-templates select="foo:sonderzeichen-ersetzen($zyklus-entry/Titel)"/>
           <xsl:text>}|see{</xsl:text>
           <xsl:apply-templates select="foo:sonderzeichen-ersetzen($work-entry/Titel)"/>
           <xsl:text>}}</xsl:text>
        </xsl:when>
     </xsl:choose>-->
   </xsl:function>
   
   
   <xsl:function name="foo:org-key-check" as="xs:boolean">
      <xsl:param name="indexkey" as="xs:string"/>
      <xsl:sequence select="string-length($indexkey) != 7 or not(starts-with($indexkey,'A080') or starts-with($indexkey,'A081'))"/> 
   </xsl:function>

   <xsl:function name="foo:person-in-index">
      <xsl:param name="indexkey" as="xs:string"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:if test="not($indexkey='')">
         <xsl:choose>
            <xsl:when test="foo:personen-key-check($indexkey)=true()">
               <xsl:text>\textcolor{red}{PERSONENINDEX FEHLER}{</xsl:text>
            </xsl:when>
            <xsl:when test="$im-text=true()">
               <xsl:text>\pwindex{</xsl:text>
               <xsl:choose>
                  <!-- Sonderregel für anonym -->
                  <xsl:when test="$indexkey ='A002003'">
                     <xsl:text>00anonym@Nicht ermittelte Verfasser</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="foo:person-fuer-index($indexkey)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>\pwindex{</xsl:text>
               <!-- Sonderregel für anonym -->
               <xsl:choose>
                  <!-- Sonderregel für anonym -->
                  <xsl:when test="$indexkey ='A002003'">
                     <xsl:text>00anonym@Nicht ermittelte Verfasser</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="foo:person-fuer-index($indexkey)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:function>  
   
 
 <xsl:function name="foo:werk-um-artikel-kuerzen">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:choose>
       <xsl:when test="starts-with($string,'Der ')">
          <xsl:value-of select="substring-after($string, 'Der ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'Das ')">
          <xsl:value-of select="substring-after($string, 'Das ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'Die ')">
          <xsl:value-of select="substring-after($string, 'Die ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'The ')">
          <xsl:value-of select="substring-after($string, 'The ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'Ein ')">
          <xsl:value-of select="substring-after($string, 'Ein ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'An ')">
          <xsl:choose>
             <xsl:when test="starts-with($string,'An die') or starts-with($string,'An ein') or starts-with($string,'An den') or starts-with($string,'An das')">
                <xsl:value-of select="$string"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="substring-after($string, 'An ')"/>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
       <xsl:when test="starts-with($string,'A ')">
          <xsl:value-of select="substring-after($string, 'A ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'La ')">
          <xsl:value-of select="substring-after($string, 'La ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'Il ')">
          <xsl:value-of select="substring-after($string, 'Il ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'Les ')">
          <xsl:value-of select="substring-after($string, 'Les ')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'L’')">
          <xsl:value-of select="substring-after($string, 'L’')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'‹s')">
          <xsl:value-of select="substring-after($string, '‹s')"/>
       </xsl:when>
       <xsl:when test="starts-with($string,'‹s')">
          <xsl:value-of select="substring-after($string, '‹s')"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:value-of select="$string"/>
       </xsl:otherwise>
    </xsl:choose>
 </xsl:function>
    
   <xsl:function name="foo:werk-kuerzen">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:choose>
        <xsl:when test="substring($string,1,1)='»'">
           <xsl:value-of select="foo:werk-kuerzen(substring($string,2))"/>
         </xsl:when>
         <xsl:when test="substring($string,1,1)='['">
            <xsl:choose><!-- Das unterscheidet ob Autorangabe [H. B.:] oder unechter Titel [Jugend in Wien] -->
               <xsl:when test="contains($string,':]')">
                  <xsl:value-of select="foo:werk-kuerzen(substring-after($string,':] '))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:werk-kuerzen(substring($string,2))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($string))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
     <!-- <xsl:if test="tokenize(">
        
      </xsl:if>  -->

  
   
   
  
  <xsl:function name="foo:organisation-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="position-im-text" as="xs:boolean"/>
      <xsl:variable name="org-entry" select="key('org-lookup', $first, $orgs)"/>
      <xsl:if test="$first!=''">
         <xsl:if test="$org-entry/Titel!=''">
            <xsl:choose>
               <xsl:when test="foo:org-key-check($first)=true()">
                  <xsl:text>\textcolor{red}{ORGINDEX FEHLER}{</xsl:text>
               </xsl:when>
               <xsl:when test="$position-im-text">
                  <xsl:text>\orgindex{</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\orgindex{</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$org-entry/Ort !=''">
               <xsl:value-of select="foo:index-sortiert(normalize-space($org-entry/Ort), 'up')"/>
               <xsl:text>!</xsl:text>
            </xsl:if>
            <xsl:value-of select="foo:index-sortiert(normalize-space($org-entry/Titel), 'up')"/>
            <xsl:if test="$org-entry/Typ !=''">
               <xsl:text>, \emph{</xsl:text><xsl:value-of select="normalize-space($org-entry/Typ)"/><xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:if>
         <xsl:text/>
      </xsl:if>
  </xsl:function>
  
  
  <xsl:function name="foo:absatz-position-vorne">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend='center'">
            <xsl:text>\centering{}</xsl:text>
         </xsl:when>
         <xsl:when test="$rend='right'">
            <xsl:text>\raggedleft{}</xsl:text>
         </xsl:when>
      </xsl:choose>
  </xsl:function>
  
  <xsl:function name="foo:absatz-position-hinten">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend='center'">
            <xsl:text></xsl:text>
         </xsl:when>
         <xsl:when test="$rend='right'">
            <xsl:text></xsl:text>
         </xsl:when>
      </xsl:choose>
  </xsl:function>
  
  <!-- Dient dazu, in der Kopfzeile »März 1890« erscheinen zu lassen -->
    <xsl:function name="foo:monatUndJahrInKopfzeile">
       <xsl:param name="datum" as="xs:string"/>
       <xsl:variable name="monat" as="xs:string" select="substring($datum,5,2)"/>
       <xsl:text>\ihead{\textsc{</xsl:text>
       <xsl:choose>
          <xsl:when test="$monat = '01'">
             <xsl:text>januar </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '02'">
             <xsl:text>februar </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '03'">
             <xsl:text>märz </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '04'">
             <xsl:text>april </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '05'">
             <xsl:text>mai </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '06'">
             <xsl:text>juni </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '07'">
             <xsl:text>juli </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '08'">
             <xsl:text>august </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '09'">
             <xsl:text>september </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '10'">
             <xsl:text>oktober </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '11'">
             <xsl:text>november </xsl:text>
          </xsl:when>
          <xsl:when test="$monat = '12'">
             <xsl:text>dezember </xsl:text>
          </xsl:when>
       </xsl:choose>
       <xsl:value-of select="substring($datum, 1,4)"/>
       <xsl:text>}}</xsl:text>
    </xsl:function>
   
   
   <xsl:function name="foo:date-repeat">
      <xsl:param name="date-string" as="xs:string"/>
      <xsl:param name="amount" as="xs:integer"/>
      <xsl:param name="counter" as="xs:integer"/>
      <xsl:variable name="roman" select=
         "'IVX'"/>
      <xsl:variable name="romanzwo" select=
         "'IVX.'"/>
      <xsl:choose> 
         <!-- Fall 1: Leerzeichen und davor Punkt und Zahl -->
         <xsl:when test="substring($date-string,$counter,1) =' ' and substring($date-string,$counter -1,1) = '.' and number(substring($date-string,$counter -2,1)) = number(substring($date-string,$counter -2,1))">
            <xsl:choose>
               <xsl:when test="number(substring($date-string,$counter +1,1)) = number(substring($date-string,$counter +1,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:when test="substring($date-string,$counter +1,1) ='[' and number(substring($date-string,$counter +2,1)) = number(substring($date-string,$counter +2,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:when test="string-length(translate(substring($date-string,$counter +1,1), $roman,''))=0 and string-length(translate(substring($date-string,$counter +2,1), $romanzwo,''))=0">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($date-string,$counter,1)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!-- Fall 2: Leerzeichen und davor eckige Klammer und Zahl -->
         <xsl:when test="substring($date-string,$counter,1) =' ' and (substring($date-string,$counter -2,2) = '.]' and number(substring($date-string,$counter -3,1)) = number(substring($date-string,$counter -3,1)))">
            <xsl:choose>
               <xsl:when test="number(substring($date-string,$counter +1,1)) = number(substring($date-string,$counter +1,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:when test="substring($date-string,$counter +1,1) ='[' and number(substring($date-string,$counter +2,1)) = number(substring($date-string,$counter +2,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:when test="string-length(translate(substring($date-string,$counter +1,1), $roman,''))=0 and string-length(translate(substring($date-string,$counter +2,1), $romanzwo,''))=0">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($date-string,$counter,1)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!-- Fall 3: Leerzeichen und davor römische Zahl -->
         <xsl:when test="substring($date-string,$counter,1) =' ' and substring($date-string,$counter -1,1) = '.' and string-length(translate(substring($date-string,$counter -2,1), $roman,''))=0">
            <xsl:choose>
               <xsl:when test="number(substring($date-string,$counter +1,1)) = number(substring($date-string,$counter +1,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:when test="substring($date-string,$counter +1,1) ='[' and number(substring($date-string,$counter +2,1)) = number(substring($date-string,$counter +2,1))">
                  <xsl:text>{\mini}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($date-string,$counter,1)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="substring($date-string,$counter,1) ='['">
            <xsl:text>{[}</xsl:text>
         </xsl:when>
         <xsl:when test="substring($date-string,$counter,1) =']'">
            <xsl:text>{]}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="substring($date-string,$counter,1)"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$counter &lt;= $amount">
         <xsl:value-of select="foo:date-repeat($date-string, $amount,$counter+1)"/>
      </xsl:if>
   </xsl:function>
   
   <xsl:function name="foo:date-translate">
      <xsl:param name="date-string" as="xs:string"/>
      <xsl:value-of select="foo:date-repeat($date-string, string-length($date-string),1)"/>
   </xsl:function>
   
  
    <xsl:function name="foo:section-titel-token">
       <!-- Das gibt den Titel für das Inhaltsverzeichnis aus. Immer nach 50 Zeichen wird umgebrochen -->
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="position" as="xs:integer"/>
      <xsl:param name="bereitsausgegeben" as="xs:integer"/>
      
    <xsl:choose>
        <xsl:when test="string-length(substring(substring-before($titel, tokenize($titel,' ')[$position+1]), $bereitsausgegeben)) &lt; 50">
          <xsl:value-of select="replace(replace(tokenize($titel,' ')[$position],'\[','{[}'),'\]','{]}')"/>
          <xsl:choose>
             <xsl:when test="not(tokenize($titel,' ')[$position] = tokenize($titel,' ')[last()])">
                <xsl:text> </xsl:text>
                <xsl:value-of select="foo:section-titel-token($titel,$position + 1, $bereitsausgegeben)"/>
             </xsl:when>
          </xsl:choose> 
       </xsl:when>
       <xsl:otherwise>
          <xsl:text>\\{}</xsl:text>
          <xsl:value-of select="replace(replace(tokenize($titel,' ')[$position],'\[','{[}'),'\]','{]}')"/>
          
          <xsl:choose>
             <xsl:when test="not(tokenize($titel,' ')[$position] = tokenize($titel,' ')[last()])">
                <xsl:text> </xsl:text>
                <xsl:value-of select="foo:section-titel-token($titel,$position + 1, string-length(substring-before($titel, tokenize($titel,' ')[$position+1])))"/>
             </xsl:when>
          </xsl:choose>  
       </xsl:otherwise>
    </xsl:choose>  
   </xsl:function>
   
   
   <xsl:function name="foo:sectionInToc">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="counter" as="xs:integer"/>
      <xsl:param name="gesamt" as="xs:integer"/>
      <xsl:variable name="titelminusdatum" as="xs:string" select="substring-before($titel,tokenize($titel,',')[last()])"/>
      <xsl:variable name="datum" as="xs:string" select="tokenize($titel,', ')[last()]"/>
      <xsl:choose>
         <xsl:when test="string-length($titel) &lt;= 50">
            <xsl:value-of select="replace(replace($titelminusdatum,'\[','{[}'),'\]','{]}')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="foo:date-translate($datum)"/>
         </xsl:when>
         <xsl:when test="string-length($titel) - string-length($datum) &lt;= 50">
            <xsl:value-of select="replace(replace($titelminusdatum,'\[','{[}'),'\]','{]}')"/>
            <xsl:text>\\{}</xsl:text>
            <xsl:value-of select="foo:date-translate($datum)"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="foo:section-titel-token($titel,1,0)"/> 
         </xsl:otherwise>
       </xsl:choose>
   </xsl:function>
  
  <!-- HAUPT -->

   <xsl:template match="TEI">
      <xsl:text>\addchap*{</xsl:text>
      <xsl:value-of select="/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level='a']"/>
      <xsl:text>}</xsl:text>
    <xsl:apply-templates select="text"/>  
   </xsl:template> 
      
   <xsl:template match="teiHeader">
      <xsl:apply-templates/>
   </xsl:template>

  <xsl:template match="origDate"/>
  
  <xsl:template match="text">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="title"/>
  
  <xsl:template match="frame">
      <xsl:text>\begin{mdbar}</xsl:text>  
      <xsl:apply-templates/>
      <xsl:text>\end{mdbar}</xsl:text>
  </xsl:template>
  
  <xsl:template match="funder"/>
 
  <xsl:template match="editionStmt"/>
  <xsl:template match="seriesStmt"/>
  <xsl:template match="publicationStmt"/>
  

  
  <xsl:template match="sourceDesc"/>
 
  <xsl:template match="profileDesc"/>
  
  <xsl:template match="sender">
      <xsl:apply-templates/>
  </xsl:template>
  
   <xsl:template match="sender/persName"/>
  
  <xsl:template match="addressee">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="addressee/persName"/>
  
  <xsl:template match="placeSender"/>
  <xsl:template match="placeAddressee"/>
  <xsl:template match="msIdentifier/country"/>
  
  
  <xsl:template match="biblStruct">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="monogr">
      <xsl:apply-templates/>   
  </xsl:template>
  
  <xsl:template match="monogr/author">
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
  </xsl:template>
 
  <xsl:template match="monogr/title[@level='m']">
      <xsl:apply-templates/>   
      <xsl:text>. </xsl:text>
  </xsl:template>
  
  <xsl:template match="editor"/>
     
  
  <xsl:template match="biblScope[@type='pp']">
      <xsl:text>, S. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@type='vol']">
      <xsl:text>, Bd. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@type='jg']">
      <xsl:text>, Jg. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@type='nr']">
      <xsl:text>, Nr. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  

  <xsl:template match="imprint/date">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="imprint/pubPlace">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
  </xsl:template>
  
  <xsl:template match="imprint/publisher">
      <xsl:apply-templates/>
  </xsl:template>
 
  
  <xsl:template match="dateSender/date"/>
  
  <!-- Autoren in den Index -->
  <xsl:template match="author[not(ancestor::biblStruct)]"/>
   
  <xsl:template match="correspDesc">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="listWit">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="witness">
        <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="msDesc">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="msIdentifier">
     <xsl:choose>
        <xsl:when test="settlement ='Cambridge'">
           <xsl:text>CUL, </xsl:text>
           <xsl:apply-templates select="idno"/>
        </xsl:when>
        <xsl:when test="repository ='Theatermuseum'">
           <xsl:text>ÖTM, </xsl:text>
           <xsl:apply-templates select="idno"/>
        </xsl:when>
        <xsl:when test="repository ='Deutsches Literaturarchiv'">
           <xsl:text>DLA, </xsl:text>
           <xsl:apply-templates select="idno"/>
           </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates/>
        </xsl:otherwise>
     </xsl:choose>
     
  </xsl:template>
  
  <xsl:template match="msIdentifier/settlement">
     <xsl:apply-templates/>
      <xsl:text>, </xsl:text>
  </xsl:template>
  
  <xsl:template match="msIdentifier/repository">
      <xsl:apply-templates/>
      <xsl:text>, </xsl:text>
  </xsl:template>
  
  <xsl:template match="msIdentifier/idno">
     <xsl:apply-templates/>
     <xsl:choose>
        <xsl:when test="ends-with(normalize-space(current()),'.')"/>
        <xsl:otherwise>
           <xsl:text>.</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
    </xsl:template>
    
  <xsl:template match="physDesc/p[text()='']"/>
  
  <xsl:template match="physDesc/stamp[text()='']"/>
  
  <xsl:template match="revisionDesc">
      <xsl:text>\sffamily\small{}</xsl:text>
      <xsl:choose>
         <xsl:when test="@status='approved'">
            <xsl:text>\marginpar{\textcolor{green}{$\heartsuit$}}</xsl:text>
         </xsl:when>
         <xsl:when test="@status='candidate'">
      </xsl:when>
         <xsl:otherwise>
            <xsl:text>\subsection*{\textcolor{red}{Status: Angelegt}}</xsl:text>
            <xsl:text>\sffamily </xsl:text>
            <xsl:if test="child::change">
               <xsl:apply-templates/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
   <xsl:template match="change">
      <xsl:value-of select="substring(@when,7,2)"/>
      <xsl:text>. </xsl:text>
      <xsl:value-of select="substring(@when,5,2)"/>
      <xsl:text>. </xsl:text>
      <xsl:value-of select="substring(@when,1,4)"/>
      <xsl:text> </xsl:text>  
      <xsl:apply-templates/>
      <xsl:text>\newline </xsl:text>
   </xsl:template>

  <xsl:template match="front"/>
  <xsl:template match="back"/>
     
   <xsl:template match="date">
      <xsl:choose>
         <xsl:when test="child::*">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:date-translate(.)"/>
         </xsl:otherwise>
      </xsl:choose> 
   </xsl:template>
  
 
    
    <xsl:function name="foo:imprint-in-index">
       <xsl:param name="monogr" as="node()"/>
      <xsl:variable name="imprint" as="node()" select="$monogr/imprint"/>
      <xsl:choose> 
         <xsl:when test="$imprint/pubPlace !=''">
         <xsl:value-of select="$imprint/pubPlace"/>
         <xsl:choose>
          <xsl:when test="$imprint/publisher !=''">
             <xsl:text>: </xsl:text>
             <xsl:value-of select="$imprint/publisher"/>
             <xsl:choose>
                <xsl:when test="$imprint/date !=''">
                   <xsl:text> </xsl:text>
                   <xsl:value-of select="$imprint/date"/>
                </xsl:when>
             </xsl:choose>
          </xsl:when>
          <xsl:when test="$imprint/date !=''">
             <xsl:text>: </xsl:text>
             <xsl:value-of select="$imprint/date"/>
          </xsl:when>
       </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$imprint/publisher !=''">
                  <xsl:value-of select="$imprint/publisher"/>
                  <xsl:choose>
                     <xsl:when test="$imprint/date !=''">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$imprint/date"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$imprint/date !=''">
                  <xsl:text>(</xsl:text>
                  <xsl:value-of select="$imprint/date"/>
                  <xsl:text>)</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:jg-bd-nr">
       <xsl:param name="monogr" as="node()"/>
          <!-- Ist Jahrgang vorhanden, stehts als erstes -->
          <xsl:if test="$monogr/imprint/biblScope[@type='jg']">
             <xsl:text>, Jg. </xsl:text>
             <xsl:value-of select="$monogr/imprint/biblScope[@type='jg']"/>
          </xsl:if>
          <!-- Ist Band vorhanden, stets auch -->
          <xsl:if test="$monogr/imprint/biblScope[@type='vol']">
             <xsl:text>, Bd. </xsl:text>
             <xsl:value-of select="$monogr/imprint/biblScope[@type='vol']"/>
          </xsl:if>
          <!-- Jetzt abfragen, wie viel vom Datum vorhanden: vier Stellen=Jahr, sechs Stellen: Jahr und Monat, acht Stellen: komplettes Datum
              Damit entscheidet sich, wo das Datum platziert wird, vor der Nr. oder danach, oder mit Komma am Schluss -->
          <xsl:choose>
             <xsl:when test="string-length($monogr/imprint/date/@when) = 4">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$monogr/imprint/date"/>
                <xsl:text>) </xsl:text>
                <xsl:if test="$monogr/imprint/biblScope[@type='nr']">
                   <xsl:text> Nr. </xsl:text>
                   <xsl:value-of select="$monogr/imprint/biblScope[@type='nr']"/>
                </xsl:if>
             </xsl:when>
             <xsl:when test="string-length($monogr/imprint/date/@when) = 6">
                <xsl:if test="$monogr/imprint/biblScope[@type='nr']">
                   <xsl:text>, Nr. </xsl:text>
                   <xsl:value-of select="$monogr/imprint/biblScope[@type='nr']"/>
                </xsl:if>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$monogr/imprint/date"/>
                <xsl:text>)</xsl:text>
             </xsl:when>
             <xsl:otherwise>
                <xsl:if test="$monogr/imprint/biblScope[@type='nr']">
                   <xsl:text>, Nr. </xsl:text>
                   <xsl:value-of select="$monogr/imprint/biblScope[@type='nr']"/>
                </xsl:if>
                <xsl:if test="$monogr/imprint/date">
                   <xsl:text>, </xsl:text>
                   <xsl:value-of select="$monogr/imprint/date"/></xsl:if>
             </xsl:otherwise>
          </xsl:choose>    
    </xsl:function>
    
    <xsl:function name="foo:monogr-angabe">
       <xsl:param name="monogr" as="node()"/>
       <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -->
       <xsl:choose>
          <xsl:when test="$vor-dem-at">
          <xsl:if test="$monogr/author[1]">
                   <xsl:value-of select="foo:autor-rekursion($monogr, count($monogr/author), count($monogr/author), false())"/>
             <xsl:text>: </xsl:text>
          </xsl:if>
          <xsl:value-of select="foo:werk-kuerzen($monogr/title)"/>
          <xsl:text>@</xsl:text>
             <xsl:if test="$monogr/author[1]">
                <xsl:value-of select="foo:autor-rekursion($monogr, count($monogr/author), count($monogr/author), false())"/>
                <xsl:text>: </xsl:text>
             </xsl:if>
          <xsl:value-of select="$monogr/title"/>
             <xsl:if test="$monogr/editor[1]">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="$monogr/editor"/>
             </xsl:if>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="count($monogr/author) > 0">
                   <xsl:value-of select="foo:autor-rekursion($monogr,count($monogr/author),count($monogr/author), false())"/>
                   <xsl:text>: </xsl:text>
                </xsl:when>
             </xsl:choose>
             <xsl:value-of select="$monogr/title"/>
             <xsl:if test="$monogr/editor[1]">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="$monogr/editor"/>
             </xsl:if>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:choose>
          <!-- Hier Abfrage, ob es ein Journal ist -->
          <xsl:when test="$monogr/title[@level='j']">
             <xsl:value-of select="foo:jg-bd-nr($monogr)"/>
          </xsl:when>
          <!-- Im anderen Fall müsste es ein 'm' für monographic sein -->
          <xsl:otherwise>
             <xsl:text>. </xsl:text>
             <xsl:if test="$monogr[child::imprint]">
                  <xsl:value-of select="foo:imprint-in-index($monogr)"/>
             </xsl:if>
            </xsl:otherwise>
       </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:autor-rekursion">
       <xsl:param name="monogr" as="node()"/>
       <xsl:param name="autor-count" as="xs:integer"/>
       <xsl:param name="autor-count-gesamt" as="xs:integer"/>
       <xsl:param name="keystattwert" as="xs:boolean"/>
       <!-- in den Fällen, wo ein Text unter einem Kürzel erschien, wird zum sortieren der key-Wert verwendet -->
       <xsl:variable name="autor" select="$monogr/author"/>
       <xsl:choose>
          <xsl:when test="$keystattwert and $monogr/author[$autor-count-gesamt - $autor-count +1]/@key">
             <xsl:value-of select="concat(normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Vorname))"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="$autor[$autor-count-gesamt - $autor-count +1]"/>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$autor-count >1">
         <xsl:text>; </xsl:text>
          <xsl:value-of select="foo:autor-rekursion($monogr,$autor-count -1,$autor-count-gesamt, $keystattwert)"/>
       </xsl:if>
    </xsl:function>
    
   <xsl:function name="foo:autor-rekursion-vorname-vorne">
      <xsl:param name="monogr" as="node()"/>
      <xsl:param name="autor-count" as="xs:integer"/>
      <xsl:param name="autor-count-gesamt" as="xs:integer"/>
      <xsl:variable name="autor" select="$monogr/author"/>
      <xsl:choose>
         <xsl:when test="contains($autor[$autor-count-gesamt - $autor-count +1],',')">
            <xsl:value-of select="tokenize($autor[$autor-count-gesamt - $autor-count +1],', ')[2]"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="tokenize($autor[$autor-count-gesamt - $autor-count +1],', ')[1]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$autor[$autor-count-gesamt - $autor-count +1]"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$autor-count >1">
         <xsl:text>; </xsl:text>
         <xsl:value-of select="foo:autor-rekursion($monogr,$autor-count -1,$autor-count-gesamt, false())"/>
      </xsl:if>
   </xsl:function>
    
  
    <xsl:function name="foo:herausgeber-nach-dem-titel">
       <xsl:param name="monogr" as="node()"/>
       <xsl:if test="$monogr/editor !='' and $monogr/author !=''">
          <xsl:value-of select="$monogr/editor"/>
       </xsl:if>
    </xsl:function>
    
    <xsl:function name="foo:analytic-angabe">
       <xsl:param name="gedruckte-quellen" as="node()"/>
       <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -->
       <xsl:variable name="analytic" as="node()" select="$gedruckte-quellen/analytic"/>
       <xsl:choose>
          <xsl:when test="$vor-dem-at">
             <xsl:choose>
                <xsl:when test="$analytic/author[1]/@key='A002003'">
                   <xsl:text>00anonym@anonym!</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:if test="$analytic/author[1]">
                      <xsl:value-of select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), true())"/>
                      <xsl:text>: </xsl:text>
                   </xsl:if>
                </xsl:otherwise>
             </xsl:choose>
             <xsl:value-of select="foo:werk-kuerzen($analytic/title)"/>
             <xsl:text>@</xsl:text>
             <xsl:if test="$analytic/author[1] and $analytic/author[1]/@key!='A002003'">
                      <xsl:value-of select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), false())"/>
                      <xsl:text>: </xsl:text>
                   </xsl:if>
          </xsl:when>
          <xsl:otherwise>
                   <xsl:if test="$analytic/author[1]">
                      <xsl:value-of select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), false())"/>
                      <xsl:text>: </xsl:text>
                   </xsl:if>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:value-of select="normalize-space($analytic/title)"/>
       <xsl:choose>
          <xsl:when test="ends-with(normalize-space($analytic/title),'!')">
             <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="ends-with(normalize-space($analytic/title),'?')">
             <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>.</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$analytic/editor[1]">
          <xsl:value-of select="$analytic/editor"/>
          <xsl:text>. </xsl:text>
       </xsl:if>
       
    </xsl:function>




  <!-- body -->
  
  
  <xsl:template match="body">
      <xsl:apply-templates/>
  </xsl:template>
  
 
  
  <xsl:template match="lb">
      <xsl:text>{\\[\baselineskip]}</xsl:text>
  </xsl:template>
  
    <xsl:template match="footNote[ancestor::text/body]">
       <xsl:text>\footnote{</xsl:text>
       <xsl:apply-templates/>
       <xsl:text>}</xsl:text>
    </xsl:template> 
 
   <xsl:template match="p">
     <xsl:choose>
        <xsl:when test="parent::footNote">
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="preceding-sibling::*[position()=1][name()='head']">
           <xsl:text>
              \noindent{}</xsl:text>
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>
              
           </xsl:text>
           <xsl:apply-templates/>
        </xsl:otherwise>
     </xsl:choose>
   </xsl:template>
   
   <xsl:template match="list">
      <xsl:text>\begin{itemize}[noitemsep]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{itemize}</xsl:text>
   </xsl:template>
   
   <xsl:template match="item">
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
      </xsl:text>
   </xsl:template>
   
   <xsl:template match="hi[@rend='overline']">
      <xsl:text>{\overbar{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}</xsl:text>
      
   </xsl:template>
  
   <xsl:template match="anchor[@type='label']">
      <!-- <xsl:choose>
      <xsl:when test="ancestor::body and not(kommentar) and not(textkonstitution)">-->
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>v}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>h}</xsl:text>
      <!--     </xsl:when>
      <xsl:otherwise>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="@xml:id"/>
         <xsl:text>}</xsl:text>
      </xsl:otherwise>
   </xsl:choose>-->
   </xsl:template>
   
   <xsl:template match="anchor[@type='commentary']">
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>v}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>h}</xsl:text>
   </xsl:template>
   
   <xsl:template match="ptr">
      <xsl:text>\myrangeref{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>v}{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>h}</xsl:text>
   </xsl:template>
   
 

  
  
   <xsl:template match="opener">
      <xsl:apply-templates/>
  </xsl:template>
  

  <!-- Titel -->
  <xsl:template match="head">
     <xsl:text>\addsec{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}
         
      </xsl:text>
  </xsl:template>

   <xsl:template match="head[@type='sub']">
      <xsl:text>\subsection*{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}
        
      </xsl:text>
   </xsl:template>
   


   
  <xsl:template match="quote">
     <xsl:choose>
        <xsl:when test="ancestor::kommentarinhalt">
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>\begin{quotation}\noindent{}</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>\end{quotation}</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
    
    <xsl:template match="lg[@type='poem']">
       <xsl:text>\stanza{}</xsl:text>
       <xsl:apply-templates/>
       <xsl:text>\stanzaend{}</xsl:text>
       <xsl:if test="following-sibling::*[1] = lg[@type='poem']">
          <xsl:text>\smallskip </xsl:text>
       </xsl:if>
    </xsl:template>
    
    <xsl:template match="l[ancestor::lg[@type='poem']]">
       <xsl:if test="@rend='inline'">
          <xsl:text>\stanzaindent{2}</xsl:text>
       </xsl:if>
       <xsl:if test="@rend='center'">
          <xsl:text>\centering </xsl:text>
       </xsl:if>
       <xsl:apply-templates/>
       <xsl:if test="following-sibling::l">
       <xsl:text>\newverse{}</xsl:text>
       </xsl:if>
    </xsl:template>
    
 
  <!-- Pagebreaks -->
  <xsl:template match="pb">
      <xsl:text>{\pb}</xsl:text>
  </xsl:template> 
    
  <!-- Kaufmanns-Und & -->
  <xsl:template match="c[@rendition='#kaufmannsund']">
      <xsl:text>{\kaufmannsund}</xsl:text>
  </xsl:template>
  
  <!-- Prozentzeichen % -->
  <xsl:template match="c[@rendition='#prozent']">
      <xsl:text>{\%}</xsl:text>
  </xsl:template>
  
  <!-- Dollarzeichen $ -->
  <xsl:template match="c[@rendition='#dollar']">
      <xsl:text>{\$}</xsl:text>
  </xsl:template>


  
  <!-- Unleserlich, unsicher Entziffertes -->
  <xsl:template match="unclear">
      <xsl:text>\textcolor{Gray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Durch Zerstörung unleserlich. Text ist stets Herausgebereingriff -->
  <xsl:template match="damage">
      <xsl:text>\colorbox{Lightgray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  
  <!-- Loch / Unentziffertes -->
  <xsl:function name="foo:gapigap">
      <xsl:param name="gapchars" as="xs:integer"/>
      <xsl:text>×</xsl:text>
      <xsl:if test="$gapchars&gt;1">
        <xsl:value-of select="foo:gapigap($gapchars - 1)"/>
      </xsl:if>
  </xsl:function>
  
  <xsl:template match="gap[@unit='chars' and @reason='illegible']">
     <xsl:text>\sffamily\textcolor{Gray}{</xsl:text>
      <xsl:value-of select="foo:gapigap(@quantity)"/>
     <xsl:text>}\rmfamily{}</xsl:text>
  </xsl:template>
  
  <xsl:template match="gap[@reason='outOfScope']">
      <xsl:text>[\ldots]</xsl:text>
  </xsl:template>
  
  <xsl:template match="gap[@reason='gabelsberger']">
      <xsl:text>\sffamily\textcolor{BurntOrange}{[Gabelsberger]}\rmfamily{}</xsl:text>
  </xsl:template>
  

   <!-- Die folgenden Templates kümmern sich um horizontale Abstände. Man hätte es wohl auch mit \hspace lösen können
  aber hier ist es mir Rekursion umgesetzt-->

  <xsl:template name="spacep">
      <xsl:param name="spacep" select="1"/>
      <xsl:text>\ </xsl:text>
      <xsl:if test="$spacep &gt; 0">
         <xsl:call-template name="spacep">
            <xsl:with-param name="spacep" select="$spacep - 1"/>
         </xsl:call-template>
        </xsl:if>    
  </xsl:template>
  
  <xsl:template match="space[@unit='chars']">
      <xsl:call-template name="spacep">
         <xsl:with-param name="spacep" select="@quantity"/>
      </xsl:call-template>
  </xsl:template>

  <!-- Hinzufügung im Text -->
  <xsl:template match="add[@place='above' and not(parent::subst)]">
      <xsl:text>\introOben{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introOben{}</xsl:text>
  </xsl:template>
  
  <xsl:template match="add[@place='below' and not(parent::subst)]">
      <xsl:text>\introUnten{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introUnten{}</xsl:text>
  </xsl:template>
  
  <xsl:template match="add[@place='inline' and not(parent::subst)]">
      <xsl:text>\introMitteVorne{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introMitteHinten{}</xsl:text>
  </xsl:template>
  
  <xsl:template match="add[@place='margin' and not(parent::subst)]">
      <xsl:text>\sffamily\tiny{}[Seitlich:] \rmfamily\normalsize\textcolor{green}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="add[@place='margin' and parent::subst]">
      <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Streichung -->
  <xsl:template match="del[not(parent::subst)]">
      <xsl:text>\sout{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="del[parent::subst]">
      <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Substi -->
  <xsl:template match="subst">
      <xsl:text>\substVorne{}\textsuperscript{</xsl:text>
      <xsl:apply-templates select="del"/>
      <xsl:text>}</xsl:text>
     <xsl:if test="string-length(del) &gt; 5">
        <xsl:text>{\allowbreak}</xsl:text>
     </xsl:if>
     <xsl:text>\substDazwischen{}</xsl:text>
      <xsl:apply-templates select="add"/>
      <xsl:text>\substHinten{}</xsl:text>
  </xsl:template>

  
  <!-- Wechsel der Schreiber <handShift -->
  
  <xsl:template match="handShift[not(@scribe)]">
      <xsl:choose>
         <xsl:when test="@medium='typewriter'">
            <xsl:text>\sffamily[ms.:]\rmfamily\normalsize{} </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\sffamily[hs.:]\rmfamily\normalsize{} </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
   <xsl:template match="handShift[@scribe]">
      <xsl:text>\sffamily{[}hs. </xsl:text>
      <xsl:choose><!-- Sonderregeln wenn Gerty und Olga im gleichen Brief vorkommen wie Schnitzler und Hofmannsthal -->
         <xsl:when test="@scribe='A002038' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002001'">
            <xsl:value-of select="normalize-space(key('person-lookup', @scribe, $persons)/Vorname)"/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when test="@scribe='A002134' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002011'">
            <xsl:value-of select="normalize-space(key('person-lookup', @scribe, $persons)/Vorname)"/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when test="@scribe='A002676' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002675'">
            <xsl:value-of select="normalize-space(key('person-lookup', @scribe, $persons)/Vorname)"/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:value-of select="normalize-space(key('person-lookup', @scribe, $persons)/Nachname)"/>
      <!-- Sonderregel für Hofmannsthal senior -->
      <xsl:if test="@scribe='A002139'">
         <xsl:text> (sen.)</xsl:text>
      </xsl:if>
      <xsl:text>:{]}\rmfamily\normalsize{} </xsl:text>
      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author/@key != @scribe">
      <xsl:value-of select="foo:person-in-index(@scribe,true())"/>
      <xsl:text>}</xsl:text>
      </xsl:if>
  </xsl:template>
  
  <!-- Kursiver Text für Schriftwechsel in den Handschriften-->
  <xsl:template match="hi[@rend='latintype']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
   
   <!-- Kursiver Text für Schriftwechsel im gedruckten Text-->
   <xsl:template match="hi[@rend='antiqua']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
  
  <!-- Kursiver Text -->
  <xsl:template match="hi[@rend='italic']">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Fetter Text -->
  <xsl:template match="hi[@rend='bold']">
     <xsl:choose>
        <xsl:when test="ancestor::head|parent::signed">
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>\textbf{</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>}</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- Kapitälchen -->
  <xsl:template match="hi[@rend='small-caps']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Gesperrter Text -->
  <xsl:template match="hi[@rend='spaced_out' and not(child::hi)]">
      <xsl:text>\so{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
    
  <!-- Hochstellung -->
  <xsl:template match="hi[@rend='superscript']">
      <xsl:text>\textsuperscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Tiefstellung -->
  
  <xsl:template match="hi[@rend='subscript']">
      <xsl:text>\textsubscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="note[@type='introduction']">
      <xsl:text>\sffamily{}[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>] \rmfamily{}</xsl:text>
  </xsl:template>
    
    <!-- Dieses Template bereitet den Schriftwechsel für griechische Zeichen vor -->
    <xsl:template match="foreign[@xml:lang='el']">
       <xsl:text>\griechisch{</xsl:text>
    <xsl:apply-templates/><xsl:text>}</xsl:text>
        </xsl:template>
    
 

   <!-- Ab hier PERSONENINDEX, WERKINDEX UND ORTSINDEX -->

   <!-- Diese Funktion setzt die Fußnoten und Indexeinträge der Personen, wobei übergeben wird, ob man sich gerade im 
  Fließtext oder in Paratexten befindet und ob die Person namentlich genannt oder nur auf sie verwiesen wird -->
 
 
 
    
  <!-- Da mehrere Personen-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:persNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="im-text" as="xs:boolean"/>
         <xsl:if test="$first!=''">
            <xsl:choose>
               <xsl:when test="$first='A002001' or $first='A002002'">
                  <!-- Einträge von Bahr und Schnitzler raus -->
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:person-in-index($first, $im-text)"/>
                  <xsl:text>}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$rest!=''">
               <xsl:value-of select="foo:persNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text)"/>
            </xsl:if>
         </xsl:if>
   </xsl:function>  
    
    <xsl:function name="foo:personInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('person-lookup',$first,$persons)"/>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="$first=''">
             <xsl:text>\sffamily\textcolor{red}{PERSON OFFEN}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="empty($entry/Vorname) and not(empty($entry/Nachname))">
                   <xsl:value-of select="normalize-space($entry[1]/Nachname)"/>
                </xsl:when>
                <xsl:when test="empty($entry/Nachname) and not(empty($entry/Vorname))">
                   <xsl:value-of select="normalize-space($entry[1]/Vorname)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="concat(normalize-space($entry[1]/Vorname[1]),' ', normalize-space($entry[1]/Nachname))"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:text>.</xsl:text>
    </xsl:function>
    
    <xsl:function name="foo:persNameEndnoteR">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:value-of select="foo:personInEndnote($first, $verweis)"/>
      <xsl:if test="$rest!=''">
         <xsl:text>; </xsl:text>
         <xsl:value-of select="foo:persNameEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
      </xsl:if>
    </xsl:function>
         
  <xsl:function name="foo:candidate_or_final_status" as="xs:boolean">
      <xsl:param name="candidate" as="xs:string"/>
     <xsl:sequence select="$candidate = 'candidate' or $candidate = 'final'"/>
  </xsl:function>
  
   <!-- Personen Haupttemplate -->
    <xsl:template match="persName|rs[@type='person']">
      <xsl:param name="inhalt" select="current()"/>
      <xsl:param name="first" select="substring(@key,1,7)"/>
      <xsl:param name="rest" select="substring-after(@key,' ')"/>
      <xsl:param name="candidate"
                 select="foo:candidate_or_final_status(ancestor::TEI/teiHeader/revisionDesc/@status)"
                 as="xs:boolean"/>
       <xsl:choose>
        
          <xsl:when test="ancestor::TEI/teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-E'">
             <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="self::persName">
                      <xsl:value-of select="foo:persNameRoutine($first, $rest, false(), false())"/>
                   </xsl:when>
                   <xsl:when test="self::rs">
                      <xsl:value-of select="foo:persNameRoutine($first, $rest, true(), false())"/>
                   </xsl:when>
            </xsl:choose>
                <xsl:if test="$candidate=false()">
                   <xsl:text>\footnote{PERSONENINDEX:</xsl:text>
                   <xsl:choose>
                      <xsl:when test="self::rs">
                           <xsl:value-of select="foo:persNameEndnoteR($first, $rest, true())"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="foo:persNameEndnoteR($first, $rest, false())"/>
                      </xsl:otherwise>
                   </xsl:choose>
                   <xsl:text>}</xsl:text>
                </xsl:if>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>DAS DÜRFTE HIER NICHT STEHEN</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
  </xsl:template>
  
  <xsl:template match="table">
     <xsl:text>\begin{longtable}{| p{.50\textwidth} | p{.20\textwidth} |}</xsl:text>
     <xsl:apply-templates/>
     <xsl:text>\end{longtable}</xsl:text>
  </xsl:template> 
   
   
   <xsl:template match="cell[1]">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="cell">
      <xsl:text> &amp; </xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   
  <xsl:template match="hyphenation">
     <xsl:if test="@alt">
        <xsl:value-of select="@alt"/>
     </xsl:if>
  </xsl:template>
   
   <!-- WERKE -->
    
    <!-- Da mehrere Werke-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:workNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <!--<xsl:param name="candidate" as="xs:boolean"/>-->
          <xsl:if test="$first!=''">
             <xsl:choose>
                <xsl:when test="foo:werke-key-check($first)=true()">
                <xsl:text>\textcolor{red}{WERKINDEX FEHLER}</xsl:text>  
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="foo:werk-in-index($first, $im-text)"/>
                   <xsl:text>}</xsl:text>
                </xsl:otherwise>
             </xsl:choose>
             <xsl:if test="$rest!=''">
                <xsl:value-of select="foo:workNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text)"/>
             </xsl:if>
          </xsl:if>
    </xsl:function>  
    
    <xsl:function name="foo:werkInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('work-lookup',$first,$works)"/>
       <xsl:variable name="author-entry" select="key('person-lookup',$entry/Autor,$persons)"/>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:if test="$entry/Autor!=''">
          <xsl:choose>
             <xsl:when test="$author-entry/Vorname=''">
                <xsl:apply-templates select="$author-entry/Nachname"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:apply-templates select="concat($author-entry/Vorname,' ',$author-entry/Nachname)"/>
             </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="not(contains($entry/Titel,':]') and starts-with($entry/Titel,'['))">
          <xsl:text>:</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="contains($entry/Titel,':]') and starts-with($entry/Titel,'[')">
             <xsl:value-of select="substring-before($entry/Titel,':]')"/>
             <xsl:text>]: \emph{</xsl:text>
             <xsl:value-of select="substring-after($entry/Titel,':]')"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>\emph{</xsl:text>
             <xsl:value-of select="$entry/Titel"/>
             <xsl:text>}</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$entry/Bibliografie!=''">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="foo:date-translate($entry/Bibliografie)"/>
       </xsl:if>
    </xsl:function>
    
    
    <xsl:function name="foo:workNameEndnoteR">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:choose>
          <xsl:when test="$first=''">
             <xsl:text>\sffamily\textcolor{red}{WERK OFFEN}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="foo:werkInEndnote($first, $verweis)"/>
             <xsl:choose>
                <xsl:when test="$rest!=''">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="foo:workNameEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
             </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="ends-with(key('work-lookup',$first,$works)/Titel,'!')">
                         <xsl:text> </xsl:text>
                      </xsl:when>
                      <xsl:when test="ends-with(key('work-lookup',$first,$works)/Titel,'?')">
                         <xsl:text> </xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:text>.</xsl:text>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:function>
   
   
    <xsl:function name="foo:werkOhneAutorInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('work-lookup',$first,$works)"/>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:text>\emph{</xsl:text>
       <xsl:apply-templates select="$entry/Titel"/>
       <xsl:text>}</xsl:text>
    </xsl:function>
  
  
    <xsl:function name="foo:workNameOhneAutorEndnoteR">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:choose>
          <xsl:when test="$first=''">
             <xsl:text>\sffamily\textcolor{red}{WERK OFFEN}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="foo:werkOhneAutorInEndnote($first, $verweis)"/>
             <xsl:choose>
                <xsl:when test="$rest!=''">
                   <xsl:text>; </xsl:text>
                   <xsl:value-of select="foo:workNameOhneAutorEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="ends-with(key('work-lookup',$first,$works)/Titel,'!')"/>
                      <xsl:when test="ends-with(key('work-lookup',$first,$works)/Titel,'?')"/>
                      <xsl:otherwise>
                         <xsl:text>.</xsl:text>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:function>
  <!-- Werke -->
    
    
    <xsl:template match="workName|rs[@type='work']">
       <xsl:param name="inhalt" select="current()"/>
       <xsl:param name="first" select="substring(@key,1,7)"/>
       <xsl:param name="rest" select="substring-after(@key,' ')"/>
       <xsl:param name="candidate"
          select="foo:candidate_or_final_status(ancestor::TEI/teiHeader/revisionDesc/@status)"
          as="xs:boolean"/>
       <xsl:choose>
          <xsl:when test="ancestor::TEI/teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-E'">
             <xsl:choose>
                <xsl:when test="not(ancestor::quote) and self::workName">
                   <xsl:text>\emph{</xsl:text> <!-- Titel kursiv wenn sie in Herausgebertexten sind -->
                   <xsl:apply-templates/>
                   <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:apply-templates/>
                </xsl:otherwise>
             </xsl:choose>
             <xsl:choose>
                <xsl:when test="self::workName">
                   <xsl:value-of select="foo:workNameRoutine($first, $rest, false(), false())"/>
                </xsl:when>
                <xsl:when test="self::rs">
                   <xsl:value-of select="foo:workNameRoutine($first, $rest, true(), false())"/>
                </xsl:when>
             </xsl:choose>
             <xsl:if test="$candidate=false()">
                <xsl:text>\footnote{WERKINDEX:</xsl:text>
                <xsl:choose>
                   <xsl:when test="self::rs">
                      <xsl:value-of select="foo:workNameEndnoteR($first, $rest, true())"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="foo:workNameEndnoteR($first, $rest, false())"/>
                   </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}</xsl:text>
             </xsl:if>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>DAS DÜRFTE HIER NICHT STEHEN</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    

<!-- ORGANISATIONEN -->

    
    <!-- Da mehrere Org-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:orgNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:if test="$first!=''">
          <xsl:value-of select="foo:organisation-in-index($first, $im-text)"/>
          <xsl:text>}</xsl:text>
          <xsl:if test="$rest!=''">
             <xsl:value-of select="foo:orgNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text)"/>
          </xsl:if>
       </xsl:if>
    </xsl:function>  
    
    <xsl:function name="foo:orgInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('org-lookup',$first,$orgs)"/>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="$first=''">
             <xsl:text>\sffamily\textcolor{red}{ORGANISATION OFFEN}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
                <xsl:if test="$entry[1]/Titel[1]!=''">
                   <xsl:value-of select="normalize-space($entry[1]/Titel)"/>
                </xsl:if>
                <xsl:if test="$entry[1]/Ort[1]!=''">
                   <xsl:text>, </xsl:text>
                   <xsl:value-of select="normalize-space($entry[1]/Ort)"/>
                </xsl:if>
             <xsl:if test="$entry[1]/Ort[1]!=''">
                <xsl:text>, \emph{</xsl:text>
                <xsl:value-of select="normalize-space($entry[1]/Typ)"/>
                <xsl:text>}</xsl:text>
             </xsl:if>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:text>.</xsl:text>
    </xsl:function>
    
    <xsl:function name="foo:orgNameEndnoteR">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:value-of select="foo:orgInEndnote($first, $verweis)"/>
       <xsl:if test="$rest!=''">
          <xsl:text>; </xsl:text>
          <xsl:value-of select="foo:orgNameEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
       </xsl:if>
    </xsl:function>
    
    <!-- Organisationen Haupttemplate -->
    <xsl:template match="orgName|rs[@type='org']">
       <xsl:param name="inhalt" select="current()"/>
       <xsl:param name="first" select="substring(@key,1,7)"/>
       <xsl:param name="rest" select="substring-after(@key,' ')"/>
       <xsl:param name="candidate"
          select="foo:candidate_or_final_status(ancestor::TEI/teiHeader/revisionDesc/@status)"
          as="xs:boolean"/>
       <xsl:choose>
        
          <xsl:when test="ancestor::TEI/teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-E'">
             <xsl:apply-templates/>
             <xsl:choose>
                <xsl:when test="$first=''">
                   <xsl:text>\sffamily\textcolor{red}{ORGANISATION OFFEN}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="self::orgName">
                         <xsl:value-of select="foo:orgNameRoutine($first, $rest, false(), false())"/>
                      </xsl:when>
                      <xsl:when test="self::rs">
                         <xsl:value-of select="foo:orgNameRoutine($first, $rest, true(), false())"/>
                      </xsl:when>
                   </xsl:choose>
                   <xsl:if test="$candidate=false()">
                      <xsl:text>\sffamily\textcolor{red}{ORG: </xsl:text>
                      <xsl:choose>
                         <xsl:when test="self::rs">
                            <xsl:value-of select="foo:orgNameEndnoteR($first, $rest, true())"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="foo:orgNameEndnoteR($first, $rest, false())"/>
                         </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>}</xsl:text>
                   </xsl:if>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>DAS DÜRFTE HIER NICHT STEHEN</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
  
   <!-- ORTE: -->
    
    <!-- Da mehrere place-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:placeNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:if test="$first!=''">
          <xsl:choose>
             <xsl:when test="foo:orte-key-check($first)=true()">
                <xsl:text>\textcolor{red}{ORTINDEX FEHLER}</xsl:text>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="foo:place-in-index($first, $im-text)"/>
                <xsl:text>}</xsl:text>
             </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="$rest!=''">
             <xsl:value-of select="foo:placeNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text)"/>
          </xsl:if>
       </xsl:if>
    </xsl:function>  
    
    <xsl:function name="foo:placeInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="ort" select="key('place-lookup', $first, $places)/Ort"/>
       <xsl:variable name="bezirk" select="key('place-lookup', $first, $places)/Bezirk"/>
       <xsl:variable name="einrichtung" select="key('place-lookup', $first, $places)/Name"/>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="$first=''">
             <xsl:text>\sffamily\textcolor{red}{ORT OFFEN}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:if test="$ort!=''">
                <xsl:value-of select="normalize-space($ort)"/>
             </xsl:if>
             <xsl:if test="$bezirk!=''">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="normalize-space($bezirk)"/>
             </xsl:if>
             <xsl:if test="$einrichtung!=''">
                <xsl:text>, \emph{</xsl:text>
                <xsl:value-of select="normalize-space($einrichtung)"/>
                <xsl:text>}</xsl:text>
             </xsl:if>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:text>.</xsl:text>
    </xsl:function>
    
    <xsl:function name="foo:placeNameEndnoteR">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:value-of select="foo:placeInEndnote($first, $verweis)"/>
       <xsl:if test="$rest!=''">
          <xsl:text>; </xsl:text>
          <xsl:value-of select="foo:placeNameEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
       </xsl:if>
    </xsl:function>
    
    <!-- places Haupttemplate -->
    <xsl:template match="placeName|rs[@type='place']">
       <xsl:param name="inhalt" select="current()"/>
       <xsl:param name="first" select="substring(@key,1,7)"/>
       <xsl:param name="rest" select="substring-after(@key,' ')"/>
       <xsl:param name="candidate"
          select="foo:candidate_or_final_status(ancestor::TEI/teiHeader/revisionDesc/@status)"
          as="xs:boolean"/>
       <xsl:choose>
          
          <xsl:when test="ancestor::TEI/teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-E'">
             <xsl:apply-templates/>
             <xsl:choose>
                <xsl:when test="$first='' and not(child::settlement)">
                   <xsl:text>\sffamily\textcolor{red}{ORT OFFEN}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="self::placeName">
                         <xsl:value-of select="foo:placeNameRoutine($first, $rest, false(), false())"/>
                      </xsl:when>
                      <xsl:when test="self::rs">
                         <xsl:value-of select="foo:placeNameRoutine($first, $rest, true(), false())"/>
                      </xsl:when>
                   </xsl:choose>
                   <xsl:if test="$candidate=false()">
                      <xsl:text>\sffamily\textcolor{red}{ORT: </xsl:text>
                      <xsl:choose>
                         <xsl:when test="self::rs">
                            <xsl:value-of select="foo:placeNameEndnoteR($first, $rest, true())"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="foo:placeNameEndnoteR($first, $rest, false())"/>
                         </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>}</xsl:text>
                   </xsl:if>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>DAS DÜRFTE HIER NICHT STEHEN</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
   
   <xsl:function name="foo:normalize-und-umlaute">
      <xsl:param name="wert" as="xs:string"/>
      <xsl:value-of select="normalize-space(foo:umlaute-entfernen($wert))"/>
   </xsl:function>

  <xsl:function name="foo:place-in-index">
      <xsl:param name="first"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:variable name="ort" select="key('place-lookup', $first, $places)/Ort"/>
      <xsl:variable name="bezirk" select="key('place-lookup', $first, $places)/Bezirk"/>
      <xsl:variable name="einrichtung" select="key('place-lookup', $first, $places)/Name"/>
     <xsl:variable name="typ" select="key('place-lookup', $first, $places)/Typ"/>
      <xsl:choose>
         <xsl:when test="$im-text and not(empty($ort))">
            <xsl:text>\oindex{</xsl:text>
            <xsl:apply-templates select="foo:normalize-und-umlaute($ort)"/>
            <xsl:text>@</xsl:text>
            <xsl:apply-templates select="normalize-space($ort)"/>
            <xsl:if test="$bezirk!=''">
               <xsl:text>!</xsl:text>
               <xsl:choose>
                  <xsl:when test="$bezirk='Bezirksübergreifend'">
                     <xsl:text>00</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='I'">
                     <xsl:text>01</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='II'">
                     <xsl:text>02</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='III'">
                     <xsl:text>03</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='IV'">
                     <xsl:text>04</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='V'">
                     <xsl:text>05</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VI'">
                     <xsl:text>06</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VII'">
                     <xsl:text>07</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VIII'">
                     <xsl:text>08</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='IX'">
                     <xsl:text>09</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='X'">
                     <xsl:text>10</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XI'">
                     <xsl:text>11</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XII'">
                     <xsl:text>12</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIII'">
                     <xsl:text>13</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIV'">
                     <xsl:text>14</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XV'">
                     <xsl:text>15</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVI'">
                     <xsl:text>16</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVII'">
                     <xsl:text>17</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVIII'">
                     <xsl:text>18</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIX'">
                     <xsl:text>19</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XX'">
                     <xsl:text>20</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXI'">
                     <xsl:text>21</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXII'">
                     <xsl:text>22</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXIII'">
                     <xsl:text>23</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:apply-templates select="foo:normalize-und-umlaute($bezirk)"/>
               <xsl:text>@</xsl:text>
               <xsl:apply-templates select="normalize-space($bezirk)"/>
            </xsl:if>
            <xsl:if test="$einrichtung!=''">
               <xsl:text>!</xsl:text>
               <xsl:apply-templates select="foo:normalize-und-umlaute($einrichtung)"/>
               <xsl:text>@</xsl:text>
               <xsl:apply-templates select="foo:sonderzeichen-ersetzen(normalize-space($einrichtung))"/>
            </xsl:if>
            <xsl:if test="$typ !=''">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="normalize-space($typ)"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:when>
         <xsl:when test="not($im-text) and not(empty($ort))">
            <xsl:text>\oindex{</xsl:text>
            <xsl:apply-templates select="foo:normalize-und-umlaute($ort)"/>
            <xsl:text>@</xsl:text>
            <xsl:apply-templates select="$ort"/>
            <xsl:if test="$bezirk!=''">
               <xsl:text>!</xsl:text>
               <xsl:choose>
                  <xsl:when test="substring-before($bezirk, '.')='I'">
                     <xsl:text>01</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='II'">
                     <xsl:text>02</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='III'">
                     <xsl:text>03</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='IV'">
                     <xsl:text>04</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='V'">
                     <xsl:text>05</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VI'">
                     <xsl:text>06</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VII'">
                     <xsl:text>07</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='VIII'">
                     <xsl:text>08</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='IX'">
                     <xsl:text>09</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='X'">
                     <xsl:text>10</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XI'">
                     <xsl:text>11</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XII'">
                     <xsl:text>12</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIII'">
                     <xsl:text>13</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIV'">
                     <xsl:text>14</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XV'">
                     <xsl:text>15</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVI'">
                     <xsl:text>16</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVII'">
                     <xsl:text>17</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XVIII'">
                     <xsl:text>18</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XIX'">
                     <xsl:text>19</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XX'">
                     <xsl:text>20</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXI'">
                     <xsl:text>21</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXII'">
                     <xsl:text>22</xsl:text>
                  </xsl:when>
                  <xsl:when test="substring-before($bezirk, '.')='XXIII'">
                     <xsl:text>23</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:apply-templates select="foo:normalize-und-umlaute($bezirk)"/>
               <xsl:text>@</xsl:text>
               <xsl:apply-templates select="$bezirk"/>
            </xsl:if>
            <xsl:if test="$einrichtung!=''">
               <xsl:text>!</xsl:text>
               <xsl:apply-templates select="foo:normalize-und-umlaute($einrichtung)"/>
               <xsl:text>@</xsl:text>
               <xsl:apply-templates select="foo:sonderzeichen-ersetzen(normalize-space($einrichtung))"/>
            </xsl:if>
            <xsl:if test="$typ !=''">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="normalize-space($typ)"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
           </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{ORTFEHLER</xsl:text>
            <xsl:value-of select="$ort"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:function>
    
    <xsl:function name="foo:settlementsetz">
       <xsl:param name="sttlmnt"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:param name="candidate" as="xs:boolean"/>
             <xsl:choose>
                <xsl:when test="not($candidate) and not($im-text)">
                   <xsl:text> [O: </xsl:text> 
                   <xsl:apply-templates select="$sttlmnt"/>
                   <xsl:text>] </xsl:text>
                </xsl:when>
             </xsl:choose>
             <xsl:text>\\oindex{</xsl:text>
             <xsl:value-of select="foo:umlaute-entfernen(normalize-space($sttlmnt))"/>
             <xsl:text>@</xsl:text>
             <xsl:value-of select="$sttlmnt"/>
             <xsl:text>}</xsl:text>
    </xsl:function>
    
 
 <!-- KOMMENTAR -->



    

<!-- Bilder einbetten -->
<xsl:template match="figure">
   <xsl:choose>
      <!-- Illustrationen werden nur einfach so gesetzt -->
      <xsl:when test="ancestor::TEI//teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-J'">
         <xsl:text>\begin{figure}[tb]</xsl:text>
         <xsl:text>\centering</xsl:text>
         <xsl:text>\noindent</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>\end{figure}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text>\begin{figure}[H]</xsl:text>
         <xsl:text>\centering</xsl:text>
         <xsl:text>\noindent</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>\end{figure}</xsl:text>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="caption">
   <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>\captionof{figure}[]{\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}</xsl:text>
</xsl:template>
    
<xsl:template match="graphic">
   <xsl:text>\includegraphics</xsl:text>
      <xsl:text>[max height=\linewidth,max width=\linewidth]
</xsl:text>
   <!--<xsl:choose>
      <xsl:when test="@width">
         <xsl:text>[width=</xsl:text>
         <xsl:value-of select="@width"/>
         <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="@height">
         <xsl:text>[height=</xsl:text>
         <xsl:value-of select="@height"/>
         <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text>[width=\linewidth,height=\textheight,
keepaspectratio]</xsl:text>
      </xsl:otherwise>
   </xsl:choose>-->
   <xsl:text>{</xsl:text>
   <xsl:value-of select="substring(@url,3)"/>
   <xsl:text>}</xsl:text>
</xsl:template>

   
   <xsl:template match="Zyklus">
      <xsl:variable name="work-entry" select="key('work-lookup', preceding-sibling::Nummer, $works)"/>
      <xsl:variable name="zyklus-entry" select="key('work-lookup', substring(.,1, 7), $works)"/>
      <xsl:choose>
         <xsl:when test="$work-entry/Titel = $zyklus-entry/Titel"/>
         <xsl:when test="starts-with(., 'A0')">
            <xsl:value-of select="foo:person-in-index($work-entry/Autor, false())"/>
            <xsl:text>!</xsl:text>
            <xsl:value-of select="foo:werk-kuerzen(preceding-sibling::Titel)"/>
            <xsl:text>@\emph{– </xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen(preceding-sibling::Titel)"/>
            <xsl:text>}|see{\emph{</xsl:text>
            <xsl:value-of select="$zyklus-entry/Titel"/>
            <xsl:text>}}}
            </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="row">
      <xsl:apply-templates select="Zyklus"/>
   </xsl:template>
   
</xsl:stylesheet>