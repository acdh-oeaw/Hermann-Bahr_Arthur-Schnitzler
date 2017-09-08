<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:foo="whatever"
                version="3.0">
  <xsl:output method="xml"/>
  <xsl:strip-space elements="*"/>
  <!-- subst root persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc sender addressee placeSender placeAddressee context date witnessdate -->

   <!-- Globale Parameter -->

  <xsl:param name="persons" select="document('personen.xml')"/>
  <xsl:param name="works" select="document('werke.xml')"/>
  <xsl:param name="orgs" select="document('organisationen.xml')"/>
  <xsl:param name="places" select="document('orte.xml')"/>
   <xsl:param name="sigle" select="document('siglen.xml')"/>
   
  <xsl:key name="person-lookup" match="row" use="Nummer"/>
  <xsl:key name="work-lookup" match="row" use="Nummer"/>
  <xsl:key name="org-lookup" match="row" use="Nummer"/>
   <xsl:key name="place-lookup" match="row" use="Nummer"/>
  <xsl:key name="sigle-lookup" match="row" use="siglekey"/>
    
   <xsl:param name="first" as="xs:string"/> 
   <!-- Enthält den Anfang eines Strings (bspw. "A00022") -->
    <xsl:param name="last" as="xs:string"/> 
   <!-- Enthält den Rest des Strings first -->
 
   <!-- Funktionen -->

   <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
   <xsl:function name="foo:umlaute-entfernen">
      <xsl:param name="umlautstring"/>
      <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E'), 'È', 'E'),'ò', 'o'), 'Č', 'C'), 'D’','D'), 'd’','D'), 'Ś', 'S'), '’', ' '), '&amp;', 'und'), 'ë', 'e'), '!', ''), 'č', 'c')"/>
   </xsl:function>

  <!-- Ersetzt im übergegeben String die Kaufmannsund -->
  <xsl:function name="foo:sonderzeichen-ersetzen">
      <xsl:param name="sonderzeichen"/>
      <xsl:value-of select="replace(replace($sonderzeichen, '&amp;', '{\\kaufmannsund} '), '!', '{\\rufezeichen}')"/>
  </xsl:function>
  
   <!-- Gibt zwei Werte zurück: Den Indexeintrag zum sortieren und den, wie er erscheinen soll -->
   <xsl:function name="foo:index-sortiert">
      <xsl:param name="index-sortieren" as="xs:string"/>
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
         <xsl:when test="$shape = 'bf'">
               <xsl:text>\textbf{</xsl:text>
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
                  <xsl:text>+@Nicht ermittelte Personen!</xsl:text>
                  <xsl:if test="not($kBeruf = '')">
                     <xsl:value-of select="foo:index-sortiert($kBeruf, 'sc')"/>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="not($kVorname='') and not($kNachname='')">
            <xsl:value-of select="foo:umlaute-entfernen(concat($kNachname, ', ', $kVorname, ' ', $kGeburtsdatum, '–', $kTodesdatum))"/>
            <xsl:text>@</xsl:text>
                  <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen(concat($kNachname, ', ', $kVorname))"/>
           <xsl:text>}</xsl:text>
          </xsl:when>
         <xsl:when test="not($kVorname='') and $kNachname=''">
            <xsl:value-of select="foo:umlaute-entfernen(concat($kVorname, ' ', $kGeburtsdatum, '–', $kTodesdatum))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($kVorname)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$kVorname='' and not($kNachname='')">
            <xsl:value-of select="foo:umlaute-entfernen(concat($kNachname, ' ', $kGeburtsdatum, '–', $kTodesdatum))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($kNachname)"/>
            <xsl:text>}</xsl:text>
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
         <xsl:when test="not(empty($kGeburtsdatum) or $kGeburtsdatum='')">
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
                     <xsl:when test="not(empty($kTodesort)) and not($kTodesort='')">
                        <xsl:text> </xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:text>–</xsl:text>
                  <xsl:choose>
                     <xsl:when test="not(empty($kTodesort)) and not($kTodesort='')">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$kTodesdatum"/>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                           <xsl:when test="normalize-space($kGeburtsort) = normalize-space($kTodesort)">
                              <xsl:text>ebd.</xsl:text>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="replace($kTodesort, '/', '{\\slash}')"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:if test="not(number(translate(substring($kTodesdatum, 1, 1),'0','1')))"><!-- Für den Fall dass es mit 'um' oder 'ca.' beginnt -->
                           <xsl:text> </xsl:text>
                        </xsl:if>
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
                        <xsl:text>*\,</xsl:text>
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
            <xsl:text>†\,</xsl:text>
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
               <xsl:text>--@Nicht ermittelte Verfasser</xsl:text>
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
                  <xsl:text>--@Nicht ermittelte Verfasser</xsl:text>
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

<xsl:function name="foo:werk-metadaten-in-index">
   <xsl:param name="typ" as="xs:string?"/>
   <xsl:param name="erscheinungsdatum" as="xs:string?"/>
   <xsl:param name="auffuehrung" as="xs:string?"/>
   
   <xsl:choose>
      <xsl:when test="$erscheinungsdatum!='' or $typ!='' or $auffuehrung!=''">
         <xsl:text> {[}</xsl:text>
      </xsl:when>
   </xsl:choose>
   <xsl:if test="$typ!=''">
      <xsl:value-of select="normalize-space($typ)"/>
   </xsl:if>
   <xsl:if test="$erscheinungsdatum!=''">
      <xsl:if test="$typ!=''">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="normalize-space($erscheinungsdatum)"/>
   </xsl:if>
   <xsl:if test="$auffuehrung!=''">
      <xsl:if test="$typ!='' or $erscheinungsdatum!=''">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="normalize-space(foo:date-translate($auffuehrung))"/>
   </xsl:if>
   <xsl:choose>
      <xsl:when test="$erscheinungsdatum!='' or $typ!='' or $auffuehrung!=''">
         <xsl:text>{]}</xsl:text>
      </xsl:when>
   </xsl:choose>
</xsl:function>
  
  <xsl:function name="foo:werk-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="im-text" as="xs:boolean"/>
     <xsl:param name="abgedruckt" as="xs:boolean"/>
      <xsl:variable name="work-entry" select="key('work-lookup', $first, $works)"/>
     <xsl:variable name="zyklus-entry" select="key('work-lookup', substring($work-entry/Zyklus,1, 7), $works)"/>
     <xsl:choose>
        <xsl:when test="empty($work-entry)">
           <xsl:text>\textcolor{red}{XXXX}</xsl:text>
        </xsl:when>
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
        <xsl:when test="$work-entry/Autor='A002002' and starts-with($work-entry/Titel,'Tagebuch') and not(normalize-space($work-entry/Titel) = 'Tagebuch')">
           <xsl:text>Tagebuch@\strich\emph{Tagebuch}!</xsl:text>
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
           <xsl:value-of select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, '')"/>
         <!--  <xsl:choose>
              <xsl:when test="starts-with($work-entry/Titel,'Tagebuch ')">
                 <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:if test="$work-entry/Bibliografie!=''">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="foo:date-translate($work-entry/Bibliografie)"/>
                 </xsl:if>
              </xsl:otherwise>
           </xsl:choose>-->
        </xsl:when>
        <xsl:when test="not(normalize-space($work-entry/Zyklus) ='')">
           <xsl:value-of select="foo:werk-kuerzen($zyklus-entry/Titel)"/>
           <xsl:value-of select="($zyklus-entry/Erscheinungsdatum)"/>
           <xsl:value-of select="($zyklus-entry/Typ)"/>
           <xsl:text>@\strich\emph{</xsl:text>
           <xsl:apply-templates select="normalize-space(foo:sonderzeichen-ersetzen($zyklus-entry/Titel))"/>
           <xsl:text>}</xsl:text>
           <xsl:value-of select="foo:werk-metadaten-in-index($zyklus-entry/Typ, $zyklus-entry/Erscheinungsdatum, $zyklus-entry/Aufführung)"/>
           <xsl:text>!</xsl:text>
           <xsl:value-of select="substring-after($work-entry/Zyklus,',')"/>
           <xsl:apply-templates select="foo:werk-kuerzen($work-entry/Titel)"/>
           <xsl:text>@\strich\emph{</xsl:text>
           <xsl:choose>
              <xsl:when test="$work-entry/Autor='A002003' and contains($work-entry/Titel,'O. V.:')">
                 <xsl:apply-templates select="normalize-space(substring(foo:sonderzeichen-ersetzen($work-entry/Titel), 9))"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:apply-templates select="normalize-space(foo:sonderzeichen-ersetzen($work-entry/Titel))"/>
              </xsl:otherwise>
           </xsl:choose>
           <xsl:text>}</xsl:text>
           <xsl:value-of select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, $work-entry/Aufführung)"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="foo:werk-kuerzen($work-entry/Titel)"/>
           <!--<xsl:value-of select="($work-entry/Bibliografie)"/>-->
           <xsl:value-of select="($work-entry/Erscheinungsdatum)"/>
           <xsl:value-of select="($work-entry/Typ)"/>
           <xsl:text>@\strich\emph{</xsl:text>
           <xsl:choose>
              <xsl:when test="$work-entry/Autor='A002003' and contains($work-entry/Titel,'O. V.:')">
                 <xsl:apply-templates select="normalize-space(substring(foo:sonderzeichen-ersetzen($work-entry/Titel), 9))"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:apply-templates select="normalize-space(foo:sonderzeichen-ersetzen($work-entry/Titel))"/>
              </xsl:otherwise>
           </xsl:choose>
           <xsl:text>}</xsl:text>
           <xsl:value-of select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, $work-entry/Aufführung)"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:function>
  
  <xsl:function name="foo:organisation-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="position-im-text" as="xs:boolean"/>
      <xsl:variable name="org-entry" select="key('org-lookup', $first, $orgs)"/>
     <xsl:variable name="ort" select="$org-entry/Ort"/>
     <xsl:variable name="bezirk" select="$org-entry/Bezirk"/>
     <xsl:variable name="typ" select="$org-entry/Typ"/>
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
            <xsl:if test="$ort !=''">
               <xsl:value-of select="foo:index-sortiert(normalize-space($ort), 'bf')"/>
               <xsl:text>!</xsl:text>
            </xsl:if>
            <xsl:choose>
               <xsl:when test="normalize-space($ort) ='Wien'">
                  <xsl:choose>
                     <xsl:when test="($bezirk = '' or empty($bezirk)) and (normalize-space($typ) = 'Tageszeitung')">
                        <xsl:text>00 a@\emph{Tageszeitung}!</xsl:text>
                     </xsl:when>
                     <xsl:when test="$bezirk = '' or empty($bezirk) or starts-with($bezirk, 'Bezirksübergreifend')">
                        <xsl:text>00 b@\textbf{Übergreifend}!</xsl:text>
                     </xsl:when>
                     <xsl:otherwise><xsl:choose>
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
                        </xsl:when></xsl:choose>
                        <xsl:value-of select="foo:index-sortiert($bezirk, 'bf')"/>
                        <xsl:text>!</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
            <xsl:value-of select="foo:index-sortiert(normalize-space($org-entry/Titel), 'up')"/>
            <xsl:if test="$typ !='' and not($ort ='Wien' and $typ='Tageszeitung')">
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
       <!-- Das gibt den Titel für das Inhaltsverzeichnis aus. Immer nach 55 Zeichen wird umgebrochen -->
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="position" as="xs:integer"/>
      <xsl:param name="bereitsausgegeben" as="xs:integer"/>
    <xsl:choose>
        <xsl:when test="string-length(substring(substring-before($titel, tokenize($titel,' ')[$position+1]), $bereitsausgegeben)) &lt; 55">
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
         <xsl:when test="string-length($titel) &lt;= 55">
            <xsl:value-of select="replace(replace($titelminusdatum,'\[','{[}'),'\]','{]}')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="foo:date-translate($datum)"/>
         </xsl:when>
         <xsl:when test="contains($datum,'nach dem') and string-length($titelminusdatum) &lt;= 44">
            <xsl:value-of select="replace(replace($titelminusdatum,'\[','{[}'),'\]','{]}')"/>
            <xsl:text> {[}nach dem</xsl:text>
            <xsl:text>\\{}</xsl:text>
            <xsl:value-of select="foo:date-translate(substring-after($datum, 'nach dem '))"/>
         </xsl:when>
         <xsl:when test="contains($datum, 'zwischen') and string-length($titelminusdatum) &lt;= 44">
            <xsl:value-of select="replace(replace($titelminusdatum,'\[','{[}'),'\]','{]}')"/>
            <xsl:text> {[}zwischen</xsl:text>
            <xsl:text>\\{}</xsl:text>
            <xsl:value-of select="foo:date-translate(substring-after($datum, 'zwischen '))"/>
         </xsl:when>
         <xsl:when test="string-length($titel) - string-length($datum) &lt;= 55">
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
   
   <xsl:template match="start">
      <start>
         <xsl:apply-templates/>
      </start>
   </xsl:template>
   
   <xsl:template match="TEI[starts-with(@xml:id, 'E')]">
      <start>
      <xsl:text>\addchap{</xsl:text>
            <xsl:value-of select="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level='a']"/>
            <xsl:text>}</xsl:text>
      <xsl:text>\mylabel{</xsl:text>
      <xsl:value-of select="concat(@xml:id,'v')"/>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates select="text"/>
      <xsl:text>\mylabel{</xsl:text>
      <xsl:value-of select="concat(@xml:id,'h')"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\sffamily\footnotesize{}\vspace{0.4em}</xsl:text>
      <xsl:choose>
         <xsl:when test="descendant::revisionDesc[@status='proposed']">
            <xsl:text>\begin{mdframed}\begin{anhang}</xsl:text>
            <xsl:apply-templates select="teiHeader"/>
            <xsl:text>\subsection*{Index}</xsl:text>
            <xsl:text>\doendnotes{B}</xsl:text>
            <xsl:text>\end{anhang}\end{mdframed}</xsl:text>
            <xsl:text>\begin{center}\rule{0.5\textwidth}{0.5mm}\end{center}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="teiHeader"/>  
          <!--  <xsl:text>\doendnotes{B}</xsl:text>-->
         </xsl:otherwise>
      </xsl:choose> 
      </start>
   </xsl:template>
   

   <xsl:template match="TEI">
      <xsl:variable name="jahr-davor"
                    as="xs:string"
                    select="substring(preceding-sibling::TEI[1]/@when,1,4)"/>
      <xsl:if test="substring(@when,1,4) != $jahr-davor">
         <xsl:text>\addchap{</xsl:text>
         <xsl:value-of select="substring(@when,1,4)"/>
         <xsl:text>}
      </xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="starts-with(@xml:id,'E')">
            <xsl:text>\addchap{</xsl:text>
            <xsl:value-of select="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level='a']"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Kalendereintrag von Bahr, 14. 5. 1902'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 1[3]. 7. 1903'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] =''">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 11. 10. 1900'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, [14. 3.? 1901]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 1. 4. 1902'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Das Märchen, 2. 12. 1893'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 6. 10. 1929'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichung von Bahr, 25. 2. 1927'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 11. 9. 1931'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 23. 11. 1891'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler: [Privataufführung, Besetzungsliste], [18. 10. 1892?]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 18. 2. 1894'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 6. 2. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: [Vortrag bei Literaturfreunden, Notizen], [vor dem 13. 3. 1895]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Hofmannsthal, 27. 3. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Marie Reinhard, 25. 6. 1897'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 10. 12. 1898'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Freiwild, 29. 1. 1905'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Artur Schnitzler. Nachruf, 25. 10. 1931'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 2. 12. 1893'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, [vor dem 21. 6. 1897]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Hofmannsthal an Schnitzler, [18. 2. 1893?]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Anna Krieger: [Schnellfotografie, Besitz Schnitzler], [1. 4. 1894?]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 17. 7. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 4. 9. 1896'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Hofmannsthal an Schnitzler, [21. 4. 1893]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 25. 12. 1897'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 15. 10. 1905'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 29. 1. 1906'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 26. 4. 1907'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="contains(teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'], 'Buchversandliste Stimmen des Bluts')">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 10. 4. 1907'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 4. 5. 1906'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler u. a. an Bahr, 14. 12. 1903'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 13. 8. 1906'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 5. 2. 1908'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 16. 12. 1907'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 6. 11. 1910'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 14. 12. 1911'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 14. 1. 1912'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 19. 7. 1913'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 16. 3. 1916'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 26. 5. 1917'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 18. 4. 1916'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 20. 10. 1918'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an S. Fischer, 11. 3. 1922'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 11. 12. 1909'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 5. 11. 1918'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 23. 11. 1921'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Selbstbildnis, Juli 1923'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Max Reinhardt, 24. 12. 1909'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 21. 2. 1892'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 20. 1. 1893'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Beer-Hofmann und Schnitzler an Hofmannsthal, [5. 6. 1894]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 29. 1. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 11. 11. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 2. 12. 1893'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 6. [5. 1892]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 20. 8. 1892'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 4. 10. 1895'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, [10. 10. 1895]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 8. 7. 1897'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Salten an Schnitzler, 8. 8. 1892'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Hofmannsthal an Bahr, 23. 7. 1900'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] =''">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Reicher an Bahr, 15. 12. 1891'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 21. 2. 1892'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, [20. 4. 1894]'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Beer-Hofmann, 20. 10. 1894'">
                  <xsl:text>{\pagebreak}</xsl:text>
               </xsl:when>
               
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 5. 6. 1905'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr, Bauer, David, Hirschfeld, Salten, Speidel: Erklärung, 14. 9. 1900'">
                  <xsl:text>\enlargethispage{-\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 10.–12. 9. 1901'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 4. 11. 1901'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Leopold Hipp an Schnitzler, 28. 6. 1902'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, [30. 3. 1903]'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Beer-Hofmann an Bahr, 1. 8. 1904'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Beer-Hofmann an Schnitzler, [Mitte August 1905]'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Hofmannsthal an Bahr, 23. 7. 1900'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Erotisch, 22. 6. 1901'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bukovics an Bahr, 29. [6.?] 1902'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: Tagebuch. 1. Januar [1921], 16. 1. 1921'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 5. 2. [1896]'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 6. 3. 1899'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 9. 3. 1899'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 7. 8. 1904'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Beer-Hofmann an Schnitzler, Mitte August 1905'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 19. 7. 1903'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr: [Notizen zur Lektüre von Hofmannsthals Das gerettete Venedig?], [2.–3. 9. 1904?]'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 25. 9. 1904'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 25. 12. 1904'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 10. 1. 1907'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 13. 11. 1903'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Tagebuch von Schnitzler, 10. 2. 1906'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Felix Salten, 18. 1. 1907'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Schnitzler an Bahr, 16. [1.] 1909'">
                  <xsl:text>\enlargethispage{-\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Bahr an Schnitzler, 18. 12. 1907'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Moritz Johann Winter: [Fotografie von Mildenburg, aus Schnitzlers Besitz], [März 1909?]'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Brahm an Bahr, 10. 7. 1909'">
                  <xsl:text>\enlargethispage{-2\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Brahm an Schnitzler, 16. 12. 1909'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 20. 12. 1921'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Scofield Thayer an Schnitzler, 9. 7. 1922'">
                  <xsl:text>\enlargethispage{\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Aufzeichnung von Bahr, 15. 4. 1913'">
                  <xsl:text>\enlargethispage{-\baselineskip}</xsl:text>
               </xsl:when>
               <xsl:when test="teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level ='a'] ='Beer-Hofmann an Hofmannsthal, 10. 6. 1894'">
                  <xsl:text>\enlargethispage{2\baselineskip}</xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>
       \section[</xsl:text>
            <xsl:value-of select="foo:sectionInToc(teiHeader/fileDesc/titleStmt/title[@level='a'],0, count(contains(teiHeader/fileDesc/titleStmt/title[@level='a'],',')))"/>
        <xsl:text>]{</xsl:text>
            <xsl:value-of select="substring-before(teiHeader/fileDesc/titleStmt/title[@level='a'],tokenize(teiHeader/fileDesc/titleStmt/title[@level='a'],',')[last()])"/>
            <xsl:value-of select="foo:date-translate(tokenize(teiHeader/fileDesc/titleStmt/title[@level='a'],',')[last()])"/>
      <xsl:if test="@short='true()'">
         <xsl:text>\kuerzung{}</xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text></xsl:otherwise></xsl:choose>
      <xsl:text>\mylabel{</xsl:text>
      <xsl:value-of select="concat(@xml:id,'v')"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="not(starts-with(@xml:id, 'E'))">
      <xsl:value-of select="foo:monatUndJahrInKopfzeile(@when)"/>
      </xsl:if>
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="text"/>
      <xsl:text>\mylabel{</xsl:text>
      <xsl:value-of select="concat(@xml:id,'h')"/>
      <xsl:text>}\leavevmode{}</xsl:text>
      <xsl:choose>
         <xsl:when test="descendant::revisionDesc[@status='proposed']">
            <xsl:text>\begin{mdframed}\begin{anhang}</xsl:text>
            <xsl:apply-templates select="teiHeader"/>
            <xsl:text>\subsection*{Index}</xsl:text>
            <xsl:text>\doendnotes{B}</xsl:text>
            <xsl:text>\end{anhang}\end{mdframed}</xsl:text>
            <xsl:text>\begin{center}\rule{0.5\textwidth}{0.5mm}\end{center}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="teiHeader"/>  
<!--            <xsl:text>\doendnotes{B}</xsl:text>
-->         </xsl:otherwise>
      </xsl:choose> 
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
  
  <xsl:function name="foo:witnesse-als-item">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates select="$listWitnode/witness[$witness-count -$witnesse +1]"/>
      <xsl:if test="$witnesse&gt;1">
         <xsl:apply-templates select="foo:witnesse-als-item($witness-count, $witnesse -1, $listWitnode)"/>
      </xsl:if>
  </xsl:function>
  
  <xsl:template match="sourceDesc"/>
 
  <xsl:template match="profileDesc"/>
  
  <xsl:template match="sender">
      <xsl:apply-templates/>
  </xsl:template>
  
   <xsl:function name="foo:briefsender-rekursiv">
      <xsl:param name="empfaenger" as="node()"/>
      <xsl:param name="empfaengernummer" as="xs:integer"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of select="foo:briefsenderindex($sender-key, $empfaenger/persName[$empfaengernummer]/@key, $date-sort, $date-n, $datum, $vorne)"/>
      <xsl:if test="$empfaengernummer &gt; 1">
         <xsl:value-of select="foo:briefsender-rekursiv($empfaenger, $empfaengernummer -1, $sender-key, $date-sort, $date-n, $datum, $vorne)"/>
      </xsl:if>
   </xsl:function>
   
   <xsl:function name="foo:briefsender-in-personenindex-rekursiv">
      <xsl:param name="sender" as="node()"/>
      <xsl:param name="sender-nummer" as="xs:integer"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:param name="einszweidrei" as="xs:string"/>
      <xsl:variable name="first" as="xs:string" select="$sender/persName[$sender-nummer]/@key"/>
      <xsl:value-of select="foo:briefsender-in-personenindex($first, $sender-nichtempfaenger, $vorne, $einszweidrei)"/>
      <xsl:if test="$sender/persName[$sender-nummer +1]/@key">
         <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv($sender, $sender-nummer +1, $sender-nichtempfaenger, $vorne, $einszweidrei)"/>
      </xsl:if>
   </xsl:function>

      <xsl:function name="foo:briefsender-in-personenindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:param name="einszweidrei" as="xs:string"/>
      <xsl:choose><!-- Briefsender fett in den Personenindex -->
         <xsl:when test="not($sender-key = 'A002002' or $sender-key ='A002001')"><!-- Schnitzler und Bahr nicht -->
            <xsl:text>\pwindex{</xsl:text>
            <xsl:value-of select="foo:person-fuer-index($sender-key)"/>
            <xsl:choose>
               <xsl:when test="$sender-nichtempfaenger = true()">
                  <xsl:text>|pws</xsl:text>
                 <!-- <xsl:choose>
                     <xsl:when test="$einszweidrei = 'eins'">
                        <xsl:text>|pws</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'zwei'">
                        <xsl:text>|pwss</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'drei'">
                        <xsl:text>|pwsss</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'vier'">
                        <xsl:text>|pwssss</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>|pwsssss</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>-->
               </xsl:when>
               <xsl:when test="$sender-nichtempfaenger = false()">
                  <xsl:text>|pwe</xsl:text>
                  <!--<xsl:choose>
                     <xsl:when test="$einszweidrei = 'eins'">
                        <xsl:text>|pwe</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'zwei'">
                        <xsl:text>|pwee</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'drei'">
                        <xsl:text>|pweee</xsl:text>
                     </xsl:when>
                     <xsl:when test="$einszweidrei = 'vier'">
                        <xsl:text>|pweeee</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>|pweeeee</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>-->
               </xsl:when>
            </xsl:choose>
           <!-- <xsl:choose>
               <xsl:when test="$vorne">
                  <xsl:text>(</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>)</xsl:text>
               </xsl:otherwise>
            </xsl:choose>-->
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
  
  <xsl:function name="foo:briefsenderindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
     <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
     <xsl:choose>
        <xsl:when test="$sender-key = 'A002001' and $empfaenger-key = 'A002002'">
           <!-- Nichts tun, dann landets in der Konkordanz der Schnitzler-Briefe-->
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>\briefsenderindex{</xsl:text>
           <xsl:value-of select="foo:index-sortiert(concat(normalize-space(key('person-lookup', $sender-key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $sender-key, $persons)/Vorname)), 'sc')"/>
           <xsl:text>!</xsl:text>
           <xsl:value-of select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', $empfaenger-key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $empfaenger-key, $persons)/Vorname)))"/>
           <xsl:text>@\emph{an </xsl:text>
           <xsl:value-of select="concat(normalize-space(key('person-lookup', $empfaenger-key, $persons)/Vorname), ' ', normalize-space(key('person-lookup', $empfaenger-key, $persons)/Nachname))"/>
           <xsl:text>}!</xsl:text>
           <xsl:value-of select="$date-sort"/>
           <xsl:value-of select="$date-n"/>
           <xsl:text>@{</xsl:text>
           <xsl:value-of select="foo:date-translate($datum)"/>
           <xsl:text>}</xsl:text>
           <xsl:value-of select="foo:vorne-hinten($vorne)"/>
           <xsl:text>bs}</xsl:text>
          
        </xsl:otherwise>
     </xsl:choose>
  </xsl:function>
  
  <xsl:function name="foo:briefempfaenger-rekursiv">
      <xsl:param name="sender" as="node()"/>
      <xsl:param name="sendernummer" as="xs:integer"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
     <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of select="foo:briefempfaengerindex($empfaenger-key, $sender/persName[$sendernummer]/@key, $date-sort, $date-n, $datum, $vorne)"/>
      <xsl:if test="$sendernummer &gt; 1">
         <xsl:value-of select="foo:briefempfaenger-rekursiv($sender, $sendernummer -1, $empfaenger-key, $date-sort, $date-n, $datum, $vorne)"/>
      </xsl:if>
  </xsl:function>
  
  <xsl:function name="foo:briefempfaengerindex">
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
     <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
     <xsl:choose>
        <xsl:when test="$sender-key = 'A002001' and $empfaenger-key = 'A002002'">
           <!-- Nichts tun, dann landets in der Konkordanz -->
        </xsl:when>
        <xsl:otherwise>
      <xsl:text>\briefempfaengerindex{</xsl:text>
           <xsl:value-of select="foo:index-sortiert(concat(normalize-space(key('person-lookup', $empfaenger-key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $empfaenger-key, $persons)/Vorname)), 'sc')"/>
      <xsl:text>!zzz</xsl:text>
     <xsl:value-of select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', $sender-key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $sender-key, $persons)/Vorname)))"/>
      <xsl:text>@\emph{von </xsl:text>
     <xsl:value-of select="concat(normalize-space(key('person-lookup', $sender-key, $persons)/Vorname), ' ', normalize-space(key('person-lookup', $sender-key, $persons)/Nachname))"/>
      <xsl:text>}</xsl:text>
            <!--Das hier würde das Datum der Korrespondenzstücke der Briefempfänger einfügen. Momentan nur der Name-->
      <xsl:text>!</xsl:text> 
      <xsl:value-of select="$date-sort"/>
      <xsl:value-of select="$date-n"/>
     <xsl:text>@{</xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
          <xsl:text>}</xsl:text>
           <xsl:value-of select="foo:vorne-hinten($vorne)"/>
           <xsl:text>be}</xsl:text>
        </xsl:otherwise></xsl:choose>
  </xsl:function>
  
  <xsl:template match="sender/persName"/>
  
  <xsl:template match="addressee">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="addressee/persName"/>
  
  <xsl:template match="placeSender"/>
  <xsl:template match="placeAddressee"/>
  <xsl:template match="msIdentifier/country"/>
  
    <xsl:template match="physDesc">
      <xsl:text>\physDesc{</xsl:text>
       <xsl:apply-templates select="p"/>
       <xsl:apply-templates select="stamp"/>
       <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="listBibl">
      <xsl:apply-templates/>
  </xsl:template> 
  
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
     
  
  <xsl:template match="biblScope[@unit='pp']">
      <xsl:text>, S. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@unit='vol']">
      <xsl:text>, Bd. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@unit='jg']">
      <xsl:text>, Jg. </xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblScope[@unit='nr']">
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
 

  <xsl:template match="stamp[following-sibling::stamp]">
      <xsl:if test="preceding-sibling::p">
         <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>\sffamily{}</xsl:text>
      <xsl:for-each select="current()">
         <xsl:text>\emph{Stempel </xsl:text>
         <xsl:value-of select="@n"/>
         <xsl:text>:} »</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>«; </xsl:text>
      </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="stamp[not(following-sibling::stamp)]">
      <xsl:if test="preceding-sibling::p">
         <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>\sffamily{}</xsl:text>
      <xsl:choose>
         <xsl:when test="@n &gt; 1">
            <xsl:text>\emph{Stempel </xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>:} »</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{Stempel:} »</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:text>«</xsl:text>
  </xsl:template>
  
  <xsl:template match="time">
     <xsl:apply-templates/>
  </xsl:template>
 
  <xsl:template match="stamp/placeName|vorgang|stamp/date|stamp/time">
     <xsl:if test="current() != ''">
        <xsl:choose>
           <xsl:when test="self::placeName and @key='A000250'"/><!-- Wien raus -->
           <xsl:when test="self::placeName">
              <xsl:value-of select="foo:placeNameRoutine(substring(@key,1,7), substring-after(@key,' '), false(), true(), false(), false())"/>
           </xsl:when>
        </xsl:choose>
        <xsl:choose>
           <xsl:when test="self::date and not(child::*)">
              <xsl:value-of select="foo:date-translate(.)"/>
           </xsl:when>
           <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
         <xsl:choose>
            <xsl:when test="position() = last()">
               <xsl:if test="not(ends-with(self::*, '.'))">
                  <xsl:text>.</xsl:text>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>, </xsl:text>
            </xsl:otherwise>
         </xsl:choose>
     </xsl:if>
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
     <xsl:text>\Standort{</xsl:text>
     <xsl:choose>
        <xsl:when test="settlement ='Cambridge'">
           <xsl:text>CUL, </xsl:text>
           <xsl:apply-templates select="idno"/>
        </xsl:when>
        <xsl:when test="repository ='Theatermuseum'">
           <xsl:text>TMW, </xsl:text>
           <xsl:apply-templates select="idno"/>
        </xsl:when>
        <xsl:when test="repository ='Deutsches Literaturarchiv'">
           <xsl:text>DLA, </xsl:text>
           <xsl:apply-templates select="idno"/>
           </xsl:when>
        <xsl:when test="repository ='Beinecke Rare Book and Manuscript Library'">
           <xsl:text>YCGL</xsl:text>
           <xsl:apply-templates select="substring-after(idno, 'Yale Collection of German Literature')"/>
        </xsl:when>
        <xsl:when test="repository ='Freies Deutsches Hochstift'">
           <xsl:text>FDH, </xsl:text>
           <xsl:apply-templates select="idno"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates/>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="msIdentifier/settlement">
     <xsl:choose>
     <xsl:when test="contains(parent::msIdentifier/repository,.)"/>
     <xsl:otherwise>
     <xsl:apply-templates/>
      <xsl:text>, </xsl:text>
     </xsl:otherwise>
     </xsl:choose>
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
      <xsl:choose>
         <xsl:when test="@status='approved'"/>
         <xsl:when test="@status='candidate'"/>
         <xsl:otherwise>
            <xsl:text>\sffamily\small{}</xsl:text>
            <xsl:text>\subsection*{\textcolor{red}{Status: Angelegt}}</xsl:text>
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
  
  <xsl:function name="foo:briefempfaenger-mehrere-persName-rekursiv">
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="briefempfaenger-anzahl" as="xs:integer"/>
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="date" as="xs:integer"/>
     <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of select="foo:briefempfaenger-rekursiv($briefsender, count($briefsender/persName), $briefempfaenger/persName[$briefempfaenger-anzahl]/@key, $date, $date-n, $datum, $vorne)"/>
      <xsl:if test="$briefempfaenger-anzahl &gt;1">
         <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv($briefempfaenger, $briefempfaenger-anzahl -1, $briefsender, $date, $date-n, $datum, $vorne)"/>
      </xsl:if>
  </xsl:function>
   
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
  
  <xsl:function name="foo:briefsender-mehrere-persName-rekursiv">
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="briefsender-anzahl" as="xs:integer"/>
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="date" as="xs:integer"/>
     <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
     <!-- Briefe Schnitzlers an Bahr raus, aber wenn mehrere Absender diese rein -->
     <xsl:if test="not($briefsender/persName[$briefsender-anzahl]/@key = 'A002001' and $briefempfaenger/persName[1]/@key='A002002')">
      <xsl:value-of select="foo:briefsender-rekursiv($briefempfaenger, count($briefempfaenger/persName), $briefsender/persName[$briefsender-anzahl]/@key, $date, $date-n, $datum, $vorne)"/>
     </xsl:if>
        <xsl:if test="$briefsender-anzahl &gt;1">
         <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv($briefsender, $briefsender-anzahl -1, $briefempfaenger, $date, $date-n, $datum, $vorne)"/>
      </xsl:if>
  </xsl:function>
  
  <xsl:function name="foo:seitenzahlen-ordnen">
      <xsl:param name="seitenzahl-vorne" as="xs:integer"/>
      <xsl:param name="seitenzahl-hinten" as="xs:integer"/>
      <xsl:value-of select="format-number($seitenzahl-vorne, '00000')"/>
      <xsl:text>–</xsl:text>
      <xsl:choose>
         <xsl:when test="empty($seitenzahl-hinten)">
            <xsl:text>00000</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="format-number($seitenzahl-hinten, '00000')"/>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:function>

   <xsl:function name="foo:quellen-titel-kuerzen">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="starts-with($titel, 'Tagebuch von Schnitzler')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Schnitzler,', 'Eintrag vom')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'vor dem 21. 6. 1897')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Tagebuch von Bahr')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Bahr, ', 'Tagebucheintrag vom ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Bahr: ')">
            <xsl:value-of select="replace($titel, 'Bahr: ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Notizheft von Bahr: ')">
            <xsl:value-of select="replace($titel, 'Notizheft von Bahr: ', 'Notizheft, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Kalendereintrag von Bahr, ')">
            <xsl:value-of select="replace($titel, 'Kalendereintrag von Bahr, ', 'Kalendereintrag, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Aufzeichnung von Bahr')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Olga Schnitzler: Spiegelbild der Freundschaft')">
            <xsl:value-of select="replace($titel, 'Olga Schnitzler: Spiegelbild der Freundschaft, ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale,')">
            <xsl:value-of select="replace($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale, ', 'Leutnant Gustl. Äußere Schicksale, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Brief an Bahr, Anfang Juli')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'Leseliste')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$titel"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
    
    <xsl:function name="foo:imprint-in-index">
       <xsl:param name="monogr" as="node()"/>
      <xsl:variable name="imprint" as="node()" select="$monogr/imprint"/>
      <xsl:choose> 
         <xsl:when test="$imprint/pubPlace !=''">
         <xsl:value-of select="$imprint/pubPlace"/>
         <xsl:choose>
          <xsl:when test="$imprint/publisher !=''">
             <xsl:text>: \emph{</xsl:text>
             <xsl:value-of select="$imprint/publisher"/>
             <xsl:text>}</xsl:text>
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
          <xsl:if test="$monogr//biblScope[@unit='jg']">
             <xsl:text>, Jg. </xsl:text>
             <xsl:value-of select="$monogr//biblScope[@unit='jg']"/>
          </xsl:if>
          <!-- Ist Band vorhanden, stets auch -->
          <xsl:if test="$monogr//biblScope[@unit='vol']">
             <xsl:text>, Bd. </xsl:text>
             <xsl:value-of select="$monogr//biblScope[@unit='vol']"/>
          </xsl:if>
          <!-- Jetzt abfragen, wie viel vom Datum vorhanden: vier Stellen=Jahr, sechs Stellen: Jahr und Monat, acht Stellen: komplettes Datum
              Damit entscheidet sich, wo das Datum platziert wird, vor der Nr. oder danach, oder mit Komma am Schluss -->
          <xsl:choose>
             <xsl:when test="string-length($monogr/imprint/date/@when) = 4">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$monogr/imprint/date"/>
                <xsl:text>) </xsl:text>
                <xsl:if test="$monogr//biblScope[@unit='nr']">
                   <xsl:text> Nr. </xsl:text>
                   <xsl:value-of select="$monogr//biblScope[@unit='nr']"/>
                </xsl:if>
             </xsl:when>
             <xsl:when test="string-length($monogr/imprint/date/@when) = 6">
                <xsl:if test="$monogr//biblScope[@unit='nr']">
                   <xsl:text>, Nr. </xsl:text>
                   <xsl:value-of select="$monogr//biblScope[@unit='nr']"/>
                </xsl:if>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$monogr/imprint/date"/>
                <xsl:text>)</xsl:text>
             </xsl:when>
             <xsl:otherwise>
                <xsl:if test="$monogr//biblScope[@unit='nr']">
                   <xsl:text>, Nr. </xsl:text>
                   <xsl:value-of select="$monogr//biblScope[@unit='nr']"/>
                </xsl:if>
                <xsl:if test="$monogr/imprint/date">
                   <xsl:text>, </xsl:text>
                   <xsl:value-of select="$monogr/imprint/date"/></xsl:if>
             </xsl:otherwise>
          </xsl:choose>    
    </xsl:function>
    
    
    <xsl:function name="foo:monogr-angabe">
       <xsl:param name="monogr" as="node()"/>
             <xsl:choose>
                <xsl:when test="count($monogr/author) > 0">
                   <xsl:value-of select="foo:autor-rekursion($monogr,count($monogr/author),count($monogr/author), false(), true())"/>
                   <xsl:text>: </xsl:text>
                </xsl:when>
             </xsl:choose>
          <!--   <xsl:choose>
                <xsl:when test="substring($monogr/title/@key, 1, 3) ='A08' or $monogr/title/@level='j'">-->
                   <xsl:text>\emph{</xsl:text>
                   <xsl:value-of select="$monogr/title"/>
                   <xsl:text>}</xsl:text>
              <!--  </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$monogr/title"/>
                </xsl:otherwise>
             </xsl:choose>-->
             <xsl:if test="$monogr/editor[1]">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="$monogr/editor"/>
             </xsl:if>
       <xsl:choose>
          <!-- Hier Abfrage, ob es ein Journal ist -->
          <xsl:when test="$monogr/title[@level='j']">
             <xsl:value-of select="foo:jg-bd-nr($monogr)"/>
          </xsl:when>
          <!-- Im anderen Fall müsste es ein 'm' für monographic sein -->
          <xsl:otherwise>
             <xsl:if test="$monogr[child::imprint]">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="foo:imprint-in-index($monogr)"/>
              </xsl:if>
             <xsl:if test="$monogr/biblScope/@unit='vol'">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$monogr/biblScope[@unit='vol']"/>
             </xsl:if>
            </xsl:otherwise>
       </xsl:choose>
    </xsl:function>
   
   <xsl:function name="foo:vorname-vor-nachname">
      <xsl:param name="autorname" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="contains($autorname,', ')">
            <xsl:value-of select="substring-after($autorname, ', ')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="substring-before($autorname, ', ')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$autorname"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
    
    <xsl:function name="foo:autor-rekursion">
       <xsl:param name="monogr" as="node()"/>
       <xsl:param name="autor-count" as="xs:integer"/>
       <xsl:param name="autor-count-gesamt" as="xs:integer"/>
       <xsl:param name="keystattwert" as="xs:boolean"/>
       <xsl:param name="vorname-vor-nachname" as="xs:boolean"/>
       <!-- in den Fällen, wo ein Text unter einem Kürzel erschien, wird zum sortieren der key-Wert verwendet -->
       <xsl:variable name="autor" select="$monogr/author"/>
       <xsl:choose>
          <xsl:when test="$keystattwert and $monogr/author[$autor-count-gesamt - $autor-count +1]/@key">
             <xsl:choose>
                <xsl:when test="$vorname-vor-nachname">
                   <xsl:value-of select="foo:index-sortiert(concat(normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Vorname), ' ', normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Nachname)), 'sc')"/>
                 </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="foo:index-sortiert(concat(normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Nachname), ', ', normalize-space(key('person-lookup', $monogr/author[$autor-count-gesamt - $autor-count +1]/@key, $persons)/Vorname)), 'sc')"/>
                </xsl:otherwise>
             </xsl:choose>
             </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
             <xsl:when test="$vorname-vor-nachname">
                <xsl:value-of select="foo:vorname-vor-nachname($autor[$autor-count-gesamt - $autor-count +1])"/>
             </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="foo:index-sortiert($autor[$autor-count-gesamt - $autor-count +1], 'sc')"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$autor-count >1">
         <xsl:text>, </xsl:text>
          <xsl:value-of select="foo:autor-rekursion($monogr,$autor-count -1,$autor-count-gesamt, $keystattwert, $vorname-vor-nachname)"/>
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
     <!--  <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-\- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -\->
       <xsl:param name="quelle-oder-literaturliste" as="xs:boolean"/> <!-\- Ists Quelle, kommt der Titel kursiv und der Autor Vorname Nachname -\->-->
       <xsl:variable name="analytic" as="node()" select="$gedruckte-quellen/analytic"/>
                   <xsl:if test="$analytic/author[1]">
                      <xsl:value-of select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), false(), true())"/>
                      <xsl:text>: </xsl:text>
                   </xsl:if>
       <xsl:choose>
          <xsl:when test="not($analytic/title/@type='j')">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="normalize-space($analytic/title)"/>
       <xsl:choose>
          <xsl:when test="ends-with(normalize-space($analytic/title),'!')"/>
          <xsl:when test="ends-with(normalize-space($analytic/title),'?')"/>
          <xsl:otherwise>
             <xsl:text>.</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
             <xsl:text>}</xsl:text>
          </xsl:when>
       <xsl:otherwise>
          <xsl:value-of select="normalize-space($analytic/title)"/>
          <xsl:choose>
             <xsl:when test="ends-with(normalize-space($analytic/title),'!')"/>
             <xsl:when test="ends-with(normalize-space($analytic/title),'?')"/>
             <xsl:otherwise>
                <xsl:text>.</xsl:text>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$analytic/editor[1]">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$analytic/editor"/>
          <xsl:text>.</xsl:text>
       </xsl:if>
    </xsl:function>

<xsl:function name="foo:nach-dem-rufezeichen">
   <xsl:param name="titel" as="xs:string"/>
   <xsl:param name="gedruckte-quellen" as="node()"/>
   <xsl:param name="gedruckte-quellen-count" as="xs:integer"/>
   <xsl:value-of select="$gedruckte-quellen/ancestor::TEI/@when"/>  
   <xsl:text>@</xsl:text>
   <xsl:choose><!-- Hier auszeichnen ob es Archivzeugen gibt -->
      <xsl:when test="boolean($gedruckte-quellen/listWit)">
         <xsl:text>\emph{</xsl:text>
         <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
         <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="$gedruckte-quellen-count = 1 and not(boolean($gedruckte-quellen/listWit))">
         <xsl:text>\emph{\textbf{</xsl:text>
         <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
         <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text>\emph{</xsl:text>
         <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
         <xsl:text>}</xsl:text>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="not(empty($gedruckte-quellen/listBibl/biblStruct[$gedruckte-quellen-count]/monogr//biblScope[@unit='pp']))">
      <xsl:text> (S. </xsl:text>
      <xsl:value-of select="$gedruckte-quellen/listBibl/biblStruct[$gedruckte-quellen-count]/monogr//biblScope[@unit='pp']"/>
      <xsl:text>)</xsl:text>
   </xsl:if>
</xsl:function>

<xsl:function name="foo:vorne-hinten">
    <xsl:param name="vorne" as="xs:boolean"/>
   <xsl:choose>
      <xsl:when test="$vorne">
         <xsl:text>|(</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text>|)</xsl:text>
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>
   
   <xsl:function name="foo:weitere-drucke">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="anzahl-drucke" as="xs:integer"/>
      <xsl:param name="drucke-zaehler" as="xs:integer"/>
      <xsl:param name="erster-druck-druckvorlage" as="xs:boolean"/>
      <xsl:variable name="seitenangabe" as="xs:string?" select="$gedruckte-quellen/biblStruct[$drucke-zaehler]//biblScope[1][@unit='pp']"/>
            <xsl:text>\weitereDrucke{</xsl:text>
      <xsl:if test="($anzahl-drucke &gt; 1 and not($erster-druck-druckvorlage)) or ($anzahl-drucke &gt; 2 and $erster-druck-druckvorlage)">
        <xsl:choose>
           <xsl:when test="$erster-druck-druckvorlage">
              <xsl:value-of select="$drucke-zaehler -1"/>
           </xsl:when>
           <xsl:otherwise>
              <xsl:value-of select="$drucke-zaehler"/>
           </xsl:otherwise>
        </xsl:choose>
         <xsl:text>) </xsl:text>
      </xsl:if>
            <xsl:choose>
               <xsl:when test="$gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp">
                  <xsl:if test="not(empty($gedruckte-quellen/biblStruct[$drucke-zaehler]/monogr/title[@level='m']/@key))">
                     <xsl:value-of select="foo:werk-in-index($gedruckte-quellen/biblStruct[$drucke-zaehler]/monogr/title[@level='m']/@key, false(), false())"/>
                     <xsl:text>|pw</xsl:text>
                     <xsl:text>}</xsl:text>
                  </xsl:if>
                  <xsl:choose><!-- Der Analytic-Teil  auch bei siglierter Literatur ausgegeben, ist jetzt ausgeschalten -->
                    <!-- <xsl:when test="not(empty($gedruckte-quellen/biblStruct[$drucke-zaehler]/analytic)) and empty($seitenangabe)">
                        <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler])"/>
                        <xsl:text> In: </xsl:text>
                        <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, '')"/>
                     </xsl:when>
                     <xsl:when test="not(empty($gedruckte-quellen/biblStruct[$drucke-zaehler]/analytic)) and not(empty($seitenangabe))">
                        <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler])"/>
                        <xsl:text> In: </xsl:text>
                        <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, $seitenangabe)"/>
                     </xsl:when>-->
                     <xsl:when test="empty($seitenangabe)">
                        <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, '')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, $seitenangabe)"/>
                     </xsl:otherwise>
                  </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="$drucke-zaehler = 1">
                     <xsl:value-of select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler], true(), false())"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler], false(), false())"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:text>} </xsl:text>
      <xsl:if test="$drucke-zaehler &lt; $anzahl-drucke">
         <xsl:value-of select="foo:weitere-drucke($gedruckte-quellen, $anzahl-drucke, $drucke-zaehler +1, $erster-druck-druckvorlage)"/>
      </xsl:if>
   </xsl:function>
    
    <xsl:function name="foo:sigle-schreiben">
       <xsl:param name="siglen-wert" as="xs:string"/>
       <xsl:param name="seitenangabe" as="xs:string"/>
       <xsl:variable name="sigle-eintrag" select="key('sigle-lookup', $siglen-wert, $sigle)" as="node()?"/>
       <xsl:if test="$sigle-eintrag/sigle-vorne and not(normalize-space($sigle-eintrag/sigle-vorne)='')">
             <xsl:value-of select="$sigle-eintrag/sigle-vorne"/>
             <xsl:text> </xsl:text>
          </xsl:if>
       <xsl:text>\emph{</xsl:text>
       <xsl:value-of select="normalize-space($sigle-eintrag/sigle-mitte)"/>
       <xsl:text>}</xsl:text>
       <xsl:if test="$sigle-eintrag/sigle-hinten">
          <xsl:text> </xsl:text>
          <xsl:value-of select="normalize-space($sigle-eintrag/sigle-hinten)"/>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="(not(normalize-space($sigle-eintrag/sigle-band) =''))">
             <xsl:text> </xsl:text>
             <xsl:value-of select="normalize-space($sigle-eintrag/sigle-band)"/>
             <xsl:if test="not(empty($seitenangabe))">
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$seitenangabe"/>
             </xsl:if>
          </xsl:when>
          <xsl:when test="not(empty($seitenangabe))">
             <xsl:text> </xsl:text>
             <xsl:value-of select="$seitenangabe"/>
          </xsl:when>
       </xsl:choose>
       <xsl:text>. </xsl:text>
    </xsl:function>
    
        <!-- Diese Funktion dient dazu, jene Publikationen in die Endnote zu setzen, die als vollständige Quelle wiedergegeben werden, wenn es keine Archivsignatur gibt -->
    <xsl:function name="foo:buchAlsQuelle">
       <xsl:param name="gedruckte-quellen" as="node()"/>
       <xsl:param name="ists-druckvorlage" as="xs:boolean"/> <!-- wenn hier true ist, dann wird die erste bibliografische Angabe als Druckvorlage ausgewiesen -->
     <xsl:choose>
        <xsl:when test="$ists-druckvorlage and not($gedruckte-quellen/biblStruct[1]/@corresp='ASTB')"> <!-- Schnitzlers Tagebuch kommt nicht rein -->
           <xsl:text>\buchAlsQuelle{</xsl:text>
           <xsl:choose>
              <xsl:when test="$gedruckte-quellen/biblStruct[1]/@corresp"><!-- Siglierte Literatur -->
                 <xsl:variable name="seitenangabe" as="xs:string?" select="$gedruckte-quellen/biblStruct[1]/descendant::biblScope[@unit='pp']"/>
                 <xsl:if test="$gedruckte-quellen/biblStruct[1]/monogr/title[@level='m']/@key">
                    <xsl:value-of select="foo:werk-in-index($gedruckte-quellen/biblStruct[1]/monogr/title[@level='m']/@key, false(), false())"/>
                    <xsl:text>|pw</xsl:text>
                    <xsl:text>}</xsl:text>
                 </xsl:if>
                 <xsl:choose><!-- Der Analytic-Teil wird auch bei siglierter Literatur ausgegeben -->
                    <xsl:when test="not(empty($gedruckte-quellen/biblStruct[1]/analytic)) and empty($seitenangabe)">
                       <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/biblStruct[1])"/>
                       <xsl:text>In: </xsl:text>
                       <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, '')"/>
                    </xsl:when>
                    <xsl:when test="not(empty($gedruckte-quellen/biblStruct[1]/analytic)) and not(empty($seitenangabe))">
                       <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/biblStruct[1])"/>
                       <xsl:text>In: </xsl:text>
                       <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, $seitenangabe)"/>
                    </xsl:when>
                    <xsl:when test="empty($seitenangabe)">
                       <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, '')"/>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:value-of select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, $seitenangabe)"/>
                    </xsl:otherwise>
                 </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:value-of select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[1], true(), false())"/>
              </xsl:otherwise>
           </xsl:choose>
           <xsl:text>}</xsl:text>
        </xsl:when>
     </xsl:choose>
      <xsl:choose>
         <xsl:when test="($ists-druckvorlage and $gedruckte-quellen/biblStruct[2]) or (not($ists-druckvorlage) and $gedruckte-quellen/biblStruct[1])">
            <xsl:text>\buchAbdrucke{</xsl:text>
            <xsl:choose>
               <xsl:when test="$ists-druckvorlage and $gedruckte-quellen/biblStruct[2]">
                  <xsl:value-of select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/biblStruct), 2, true())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/biblStruct), 1, false())"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose> 
    </xsl:function>
   
   <xsl:function name="foo:bibliographische-angabe">
      <xsl:param name="biblstruct" as="node()"/>
      <xsl:param name="onalytic" as="xs:boolean"/> <!-- Wenn mehrere Abdrucke und da der analytic-Teil gleich, dann braucht der nicht wiederholt werden -->
      <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
         <!-- Zuerst das in den Index schreiben von Autor, Zeitschrift etc. -->
         <xsl:if test="starts-with($biblstruct/analytic[1]/title[1]/@key,'A02')">
            <xsl:value-of select="foo:workNameRoutine(substring($biblstruct/analytic[1]/title[1]/@key,1,7),substring-after($biblstruct/analytic[1]/title[1]/@key,' '), false(), false(), false(), $kommentar-oder-hrsg)"/>
         </xsl:if>
         <xsl:if test="starts-with($biblstruct//monogr[1]/title[1]/@key, 'A08')">
            <xsl:value-of select="foo:orgNameRoutine(substring($biblstruct/monogr[1]/title[1]/@key,1,7),substring-after($biblstruct/monogr[1]/title[1]/@key,' '), false(), false(), false(), $kommentar-oder-hrsg)"/>
         </xsl:if>
         <xsl:if test="starts-with($biblstruct//monogr[1]/title[1]/@key, 'A02')">
            <xsl:value-of select="foo:workNameRoutine(substring($biblstruct/monogr[1]/title[1]/@key,1,7),substring-after($biblstruct/monogr[1]/title[1]/@key,' '), false(), false(), false(), $kommentar-oder-hrsg)"/>
         </xsl:if>
         <xsl:if test="starts-with($biblstruct/analytic[1]/author[1]/@key,'A00') and not($biblstruct/analytic[1]/author[1]/@key = 'A002003')">
            <xsl:value-of select="foo:persNameRoutine(substring($biblstruct/analytic[1]/author[1]/@key,1,7),substring-after($biblstruct/analytic[1]/author[1]/@key,' '), false(), false(), false(), $kommentar-oder-hrsg)"/>
         </xsl:if>
         <xsl:if test="starts-with($biblstruct/monogr[1]/author[1]/@key,'A00') and not($biblstruct/analytic[1]/author[1]/@key = 'A002003')">
            <xsl:value-of select="foo:persNameRoutine(substring($biblstruct/monogr[1]/author[1]/@key,1,7),substring-after($biblstruct/monogr[1]/author[1]/@key,' '), false(), false(), false(), $kommentar-oder-hrsg)"/>
         </xsl:if>
         <xsl:choose>
            <!-- Zuerst Analytic -->
            <xsl:when test="$biblstruct/analytic">
               <xsl:choose>
                  <xsl:when test="$onalytic">
                     <xsl:value-of select="foo:analytic-angabe($biblstruct)"/>
                     <xsl:text> </xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:text>In: </xsl:text>
               <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
            </xsl:when>
            <!-- Jetzt abfragen ob mehrere monogr -->
            <xsl:when test="count($biblstruct/monogr) = 2">
               <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
               <xsl:text>. Band</xsl:text>
              <!-- <xsl:if test="$biblstruct/monogr[last()]/biblScope/@unit='vol'">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$biblstruct/monogr[last()]/biblScope[@unit='vol']"/>
               </xsl:if>-->
               <xsl:text>: </xsl:text>
               <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[1])"/>
            </xsl:when>
            <!-- Ansonsten ist es eine einzelne monogr -->
            <xsl:otherwise>
               <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="not(empty($biblstruct/monogr//biblScope[@unit='pp']))">
            <xsl:text>, S. </xsl:text>
            <xsl:value-of select="$biblstruct/monogr//biblScope[@unit='pp']"/>
         </xsl:if>
      <xsl:text>.</xsl:text>
         <xsl:if test="not(empty($biblstruct/series))">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$biblstruct/series/title"/>
            <xsl:if test="$biblstruct/series/biblScope">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$biblstruct/series/biblScope"/>
            </xsl:if>
            <xsl:text>)</xsl:text>
         </xsl:if>   
   </xsl:function>
  
  <xsl:function name="foo:mehrere-witnesse">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
     <!-- <xsl:text>\emph{Standort </xsl:text>
      <xsl:value-of select="$witness-count -$witnesse +1"/>
      <xsl:text>:} </xsl:text>-->
      <xsl:apply-templates select="$listWitnode/witness[$witness-count -$witnesse +1]"/>
      <xsl:if test="$witnesse&gt;1">
         <!--<xsl:text>\\{}</xsl:text>-->
         <xsl:apply-templates select="foo:mehrere-witnesse($witness-count, $witnesse -1, $listWitnode)"/>
      </xsl:if>
  </xsl:function>
  
   <xsl:function name="foo:briefkonkordanz">
      <xsl:param name="sourceDesc" as="node()"/>
      <xsl:variable name="daviau" select="$sourceDesc/listBibl/biblStruct/analytic"/>
      <xsl:text>\makebox[10em][r]{\textbf{</xsl:text>
      <xsl:choose>
         <xsl:when test="ends-with($sourceDesc/correspDesc[1]/dateSender[1]/date[1],'?]')">
            <xsl:value-of select="substring-before($sourceDesc/correspDesc[1]/dateSender[1]/date[1], '?]')"/>
            <xsl:text>}}\makebox[1em][l]{?{]}}</xsl:text>
         </xsl:when>
         <xsl:when test="ends-with($sourceDesc/correspDesc[1]/dateSender[1]/date[1],']')">
            <xsl:value-of select="substring-before($sourceDesc/correspDesc[1]/dateSender[1]/date[1], ']')"/>
            <xsl:text>}}\makebox[1em][l]{{]}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$sourceDesc/correspDesc[1]/dateSender[1]/date[1]"/>
            <xsl:text>}}\hspace{1em}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>\hspace{1em}</xsl:text>
      <xsl:text>\makebox[2em][r]{</xsl:text>
      <xsl:choose>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/analytic/title = 'Briefe' and $sourceDesc/listBibl/biblStruct/monogr/title ='Die Neue Rundschau'">
            <xsl:text>N</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:text>\makebox[2em][c]{</xsl:text>
      <xsl:choose>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'Briefe 1875–1912'">
            <xsl:text>B</xsl:text>
         </xsl:when>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'Briefe 1913–1931'">
            <xsl:text>B</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:text>\makebox[2em][l]{</xsl:text>
      <xsl:choose>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'The Letters of Arthur Schnitzler to Hermann Bahr' and $daviau/respStmt = 'Abschrift'">
            <xsl:text>D\textsuperscript{\textsmaller[2]{A}} </xsl:text>
         </xsl:when>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'The Letters of Arthur Schnitzler to Hermann Bahr'">
            <xsl:text>D </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>— </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:choose>
         <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'The Letters of Arthur Schnitzler to Hermann Bahr'">
            <xsl:choose>
               <xsl:when test="contains($sourceDesc/listBibl/biblStruct/monogr[title = 'The Letters of Arthur Schnitzler to Hermann Bahr']/biblScope,'–')">
                  <xsl:text>\makebox[1.5em][r]{</xsl:text>
                  <xsl:value-of select="substring-before($sourceDesc/listBibl/biblStruct/monogr[title = 'The Letters of Arthur Schnitzler to Hermann Bahr']/biblScope, '–')"/>
                  <xsl:text>}</xsl:text>
                  <xsl:text>\makebox[1.5em][l]{–</xsl:text>
                  <xsl:value-of select="substring-after($sourceDesc/listBibl/biblStruct/monogr[title = 'The Letters of Arthur Schnitzler to Hermann Bahr']/biblScope, '–')"/>
                  <xsl:text>}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\makebox[1.5em][r]{</xsl:text>
                  <xsl:value-of select="$sourceDesc/listBibl/biblStruct/monogr[title = 'The Letters of Arthur Schnitzler to Hermann Bahr']/biblScope"/>
                  <xsl:text>}\hspace{1.5em}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="$sourceDesc/listBibl/biblStruct/monogr/title = 'The Letters of Arthur Schnitzler to Hermann Bahr' and not($sourceDesc/correspDesc[1]/dateSender[1]/date[1] = $daviau/date)">
                  <xsl:text>\hspace{1em}</xsl:text>
                  <xsl:text>\makebox[8em][r]{\emph{</xsl:text>
                  <xsl:choose>
                     <xsl:when test="ends-with($daviau/date,'?]')">
                        <xsl:value-of select="substring-before($daviau/date, '?]')"/>
                        <xsl:text>}}\makebox[1em][l]{\emph{?{]}}}</xsl:text>
                     </xsl:when>
                     <xsl:when test="ends-with($daviau/date,']')">
                        <xsl:value-of select="substring-before($daviau/date, ']')"/>
                        <xsl:text>}}\makebox[1em][l]{\emph{{]}}}</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$daviau/date"/>
                        <xsl:text>}}\hspace{1em}</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
      </xsl:choose>
      <xsl:text>\newline{}</xsl:text>
   </xsl:function>
  
  
  <!-- eigentlicher Fließtext START -->
  
   <xsl:template match="body">
      <xsl:param name="quellen"
         as="node()"
         select="ancestor::TEI/teiHeader/fileDesc/sourceDesc"/>
      <xsl:param name="gedruckte-quellen-count"
         as="xs:integer"
         select="count($quellen/listBibl/biblStruct)"/>
      <xsl:variable name="titel"
         as="xs:string"
         select="ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']"/>
      <xsl:variable name="titel-ohne-datum" as="xs:string" select="substring-before($titel, tokenize($titel,',')[last()])"/>
      <xsl:variable name="datum" as="xs:string" select="substring(substring-after($titel, tokenize($titel,',')[last() -1]),2)"/>
      <xsl:variable name="correspdesc-sender-vorher" select="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName/@key"/>
      <xsl:variable name="correspdesc-empf-vorher" select="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName/@key"/>
      <xsl:variable name="correspdesc-sender-nachher" select="ancestor::TEI/following-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName/@key"/>
      <xsl:variable name="correspdesc-empf-nachher" select="ancestor::TEI/following-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName/@key"/>
      <!-- Hier komplett abgedruckte Texte fett in den Index -->
      <xsl:if test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 'A0')">
         <xsl:value-of select="foo:abgedruckte-workNameRoutine(substring(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 1, 7), substring-after(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, ' '), true())"/>
      </xsl:if>
      <!-- Hier Briefe bei den Personen in den Personenindex -->
      <!-- Ein wenig gefizzelt ist, wenn der vorherige Brief schon von der gleichen Person war -->
      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
               <xsl:choose>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 0">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), true(), 'eins')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 1">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), true(), 'zwei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 2">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), true(), 'drei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 3">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), true(), 'vier')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 4">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), true(), 'fünf')"/>
                  </xsl:when>
               </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 0">
                        <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), true(), 'eins')"/>
                     </xsl:when>
                     <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 1">
                        <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), true(), 'zwei')"/>
                     </xsl:when>
                     <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 2">
                        <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), true(), 'drei')"/>
                     </xsl:when>
                     <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 3">
                        <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), true(), 'vier')"/>
                     </xsl:when>
                     <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 4">
                        <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), true(), 'fünf')"/>
                     </xsl:when>
                  </xsl:choose>
      </xsl:if>
      <xsl:variable name="language" select="substring(ancestor::TEI//profileDesc/langUsage/language/@ident, 1, 2)"/>
      <xsl:choose>
         <xsl:when test="$language = 'en'">
            <xsl:text>\selectlanguage{english}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'fr'">
            <xsl:text>\selectlanguage{french}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>\normalsize\beginnumbering</xsl:text>
      <!-- Hier werden Briefempfänger und Briefsender in den jeweiligen Index gesetzt -->
      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
         <xsl:choose><!-- Zuerst die Briefe Schnitzlers an Bahr für die Konkordanz herausfiltern -->
            <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName/@key='A002001' and ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName/@key='A002002'">
               <xsl:text>\toendnotes[D]{\noindent\makebox[4em][l]{\myrangerefkasten{</xsl:text>
               <xsl:value-of select="concat(ancestor::TEI/@xml:id,'v')"/>
               <xsl:text>}{</xsl:text>
               <xsl:value-of select="concat(ancestor::TEI/@xml:id,'h')"/>
               <xsl:text>}}</xsl:text>
               <xsl:value-of select="foo:briefkonkordanz(ancestor::TEI/teiHeader/fileDesc/sourceDesc)"/>
               <xsl:text>}</xsl:text>
               <xsl:choose>
                  <!-- Wenn es außer Schnitzler noch mehr als einen Absender gibt -->
                  <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName[2]">
                     <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
                     <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
                  </xsl:when>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
               <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <!-- Das Folgende schreibt Titel in den Anhang zum Kommentar -->
      <!-- Zuerst mal Abstand, ob klein oder groß, je nachdem, ob Archivsignatur und Kommentar war -->
      <xsl:choose>
         <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listBibl/biblStruct[1]/monogr/imprint/date/xs:integer(substring(@when,1,4)) &lt; 1935">
            \toendnotes[C]{\medbreak\pagebreak[2]}
         </xsl:when>
         <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listWit">
            \toendnotes[C]{\medbreak\pagebreak[2]}
         </xsl:when>
         <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//*[@subtype]">
            \toendnotes[C]{\medbreak\pagebreak[2]}
         </xsl:when>
         <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::kommentar">
            \toendnotes[C]{\medbreak\pagebreak[2]}
         </xsl:when>
         <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::textkonstitution">
            \toendnotes[C]{\medbreak\pagebreak[2]}
         </xsl:when>
         <xsl:otherwise>
            \toendnotes[C]{\smallbreak\pagebreak[2]}
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>\anhangTitel{\myrangeref{</xsl:text>
      <xsl:value-of select="concat(ancestor::TEI/@xml:id,'v')"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="concat(ancestor::TEI/@xml:id,'h')"/>
      <xsl:text>}}{</xsl:text>
      <xsl:value-of select="$titel-ohne-datum"/>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>\nopagebreak}</xsl:text>
      <!-- Wenn es Adressen gibt, diese in die Endnote -->
      <xsl:choose>
         <xsl:when test="div[@type='address']/address">
            <xsl:text>\Adresse{</xsl:text>
            <xsl:choose>
               <xsl:when test="div[@type='address']/address[2]">
                  <xsl:text>\emph{Absender}: »</xsl:text>
                  <xsl:apply-templates select="div[@type='address']/address[1]"/>
                  <xsl:text>«; </xsl:text><xsl:text>\emph{Anschrift}: »</xsl:text>
                  <xsl:apply-templates select="div[@type='address']/address[2]"/>
                  <xsl:choose>
                     <xsl:when test="ends-with(div[@type='address']/address[2]/addrLine[last()], '.')">
                        <xsl:text>«</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>«.</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text><!--\emph{Anschrift} :-->»</xsl:text>
                  <xsl:apply-templates select="div[@type='address']/address[1]"/>
                  <xsl:choose>
                     <xsl:when test="ends-with(div[@type='address']/address[1]/addrLine[last()], '.')">
                        <xsl:text>«</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>«.</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>     
      <!--       Zuerst mal die Archivsignaturen  
-->      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit"> 
         <xsl:text>\datumImAnhang{</xsl:text>
         <xsl:value-of select="foo:monatUndJahrInKopfzeile(ancestor::TEI/@when)"/>
         <xsl:text>}</xsl:text>
         <xsl:choose>
            <xsl:when test="count($quellen/listWit/witness) = 1">
               <xsl:apply-templates select="$quellen/listWit/witness[1]"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="foo:mehrere-witnesse(count($quellen/listWit/witness), count($quellen/listWit/witness), $quellen/listWit)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <!-- Alternativ noch testen, ob es gedruckt wurde -->
      <xsl:if test="$quellen/listBibl">
         <xsl:choose>
            <!-- Briefe Schnitzlers an Bahr raus, da gibt es Konkordanz -->
            <xsl:when test="ancestor::TEI[descendant::correspDesc/sender/persName/@key='A002001' and descendant::correspDesc/addressee/persName/@key='A002002']"></xsl:when>
            <!-- Gibt es kein listWit ist das erste biblStruct die Quelle -->
            <xsl:when test="not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit) and $quellen/listBibl/biblStruct">
               <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, true())"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, false())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$quellen/listBibl/biblStruct/@corresp='ASTB'"/><!-- Bei Schnitzler-Tagebuch keinen Abstand zwischen Titelzeile und Kommentar, da der Standort und die Drucke nicht vermerkt werden -->
         <xsl:when test="descendant::kommentar">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::*[@subtype]">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::textkonstitution">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::hi[@rend='underline' and (@n &gt; 2)]">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:text>\endnumbering</xsl:text>
      <xsl:choose>
         <xsl:when test="not($language = 'de')">
            <xsl:text>\selectlanguage{ngerman}</xsl:text>
         </xsl:when>
      </xsl:choose>
   <!--   <!-\- Hier Briefe bei den Personen in den Personenindex -\->
      <!-\- Ein wenig gefizzelt ist, weil xindy probleme mit aneinanderstoßenden ranges hat -\->
      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
               <xsl:choose>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 0">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), false(), 'eins')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 1">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), false(), 'zwei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 2">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), false(), 'drei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 3">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), false(), 'vier')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 4">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, 1, true(), false(), 'fünf')"/>
                  </xsl:when>
               </xsl:choose>
               <xsl:choose>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 0">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), false(), 'eins')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 1">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), false(), 'zwei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 2">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), false(), 'drei')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 3">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), false(), 'vier')"/>
                  </xsl:when>
                  <xsl:when test="count(ancestor::TEI/preceding-sibling::TEI) mod 5 = 4">
                     <xsl:value-of select="foo:briefsender-in-personenindex-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, 1, false(), false(), 'fünf')"/>
                  </xsl:when>
               </xsl:choose>
      </xsl:if>   -->   
      <xsl:if test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 'A0')">
         <xsl:value-of select="foo:abgedruckte-workNameRoutine(substring(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 1, 7), substring-after(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, ' '), false())"/>
      </xsl:if>
      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
         <xsl:choose><!-- Zuerst die Briefe Schnitzlers an Bahr für die Konkordanz herausfiltern -->
            <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName/@key='A002001' and ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName/@key='A002002' and not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName[2])"/>
            <xsl:otherwise>
               <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, false())"/>
               <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, false())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
  
  
  <!-- Das ist speziell für die Behandlung von Bildern, der eigentliche body für alles andere kommt danach -->
  
  <xsl:template match="image">
     <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="body[parent::image]">
     <xsl:param name="quellen"
        as="node()"
        select="ancestor::TEI/teiHeader/fileDesc/sourceDesc"/>
     <xsl:param name="gedruckte-quellen-count"
        as="xs:integer"
        select="count($quellen/listBibl/biblStruct)"/>
     <xsl:variable name="titel"
        as="xs:string"
        select="ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']"/>
     <xsl:variable name="titel-ohne-datum" as="xs:string" select="substring-before($titel, tokenize($titel,',')[last()])"/>
     <xsl:variable name="datum" as="xs:string" select="substring(substring-after($titel, tokenize($titel,',')[last() -1]),2)"/>
     
     <!-- Hier komplett abgedruckte Texte fett in den Index -->
     <xsl:if test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 'A0')">
        <xsl:value-of select="foo:abgedruckte-workNameRoutine(substring(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 1, 7), substring-after(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, ' '), true())"/>
     </xsl:if>
     <xsl:text>\normalsize
        \beginnumbering
        \pstart\ </xsl:text>
     <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
        <xsl:choose><!-- Zuerst die Briefe Schnitzlers an Bahr für die Konkordanz herausfiltern -->
           <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName/@key='A002001' and ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName/@key='A002002'">
              <xsl:text>\toendnotes[D]{\noindent\makebox[4em][l]{\myrangerefkasten{</xsl:text>
              <xsl:value-of select="concat(ancestor::TEI/@xml:id,'v')"/>
              <xsl:text>}{</xsl:text>
              <xsl:value-of select="concat(ancestor::TEI/@xml:id,'h')"/>
              <xsl:text>}}</xsl:text>
              <xsl:value-of select="foo:briefkonkordanz(ancestor::TEI/teiHeader/fileDesc/sourceDesc)"/>
              <xsl:text>}</xsl:text>
           </xsl:when>
           <xsl:otherwise>
              <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
              <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, true())"/>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:if>
     <!-- Das Folgende schreibt Titel in den Anhang zum Kommentar -->
     <!-- Zuerst mal Abstand, ob klein oder groß, je nachdem, ob Archivsignatur und Kommentar war -->
     <xsl:choose>
        <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listBibl/biblStruct[1]/monogr/imprint/date/xs:integer(substring(@when,1,4)) &lt; 1935">
           \toendnotes[C]{\medbreak}
        </xsl:when>
        <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listWit">
           \toendnotes[C]{\medbreak}
        </xsl:when>
        <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//*[@subtype]">
           \toendnotes[C]{\medbreak}
        </xsl:when>
        <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::kommentar">
           \toendnotes[C]{\medbreak}
        </xsl:when>
        <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::textkonstitution">
           \toendnotes[C]{\medbreak}
        </xsl:when>
        <xsl:otherwise>
           \toendnotes[C]{\smallbreak}
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>\anhangTitel{\myrangeref{</xsl:text>
     <xsl:value-of select="concat(ancestor::TEI/@xml:id,'v')"/>
     <xsl:text>}{</xsl:text>
     <xsl:value-of select="concat(ancestor::TEI/@xml:id,'h')"/>
     <xsl:text>}}{</xsl:text>
     <xsl:value-of select="$titel-ohne-datum"/>
     <xsl:value-of select="foo:date-translate($datum)"/>
     <xsl:text>}
     </xsl:text>
     <!--       Zuerst mal die Archivsignaturen  
-->      <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit"> 
            <xsl:text>\datumImAnhang{</xsl:text>
            <xsl:value-of select="foo:monatUndJahrInKopfzeile(ancestor::TEI/@when)"/>
        <xsl:text>}</xsl:text>
            <xsl:choose>
               <xsl:when test="count($quellen/listWit/witness) = 1">
                  <xsl:apply-templates select="$quellen/listWit/witness[1]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="foo:mehrere-witnesse(count($quellen/listWit/witness), count($quellen/listWit/witness), $quellen/listWit)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <!-- Alternativ noch testen, ob es gedruckt wurde -->
         <xsl:if test="$quellen/listBibl">
            <xsl:choose>
               <!-- Briefe Schnitzlers an Bahr raus, da gibt es Konkordanz -->
               <xsl:when test="ancestor::TEI[descendant::correspDesc/sender/persName/@key='A002001' and descendant::correspDesc/addressee/persName/@key='A002002']"></xsl:when>
               <!-- Gibt es kein listWit ist das erste biblStruct die Quelle -->
               <xsl:when test="not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit) and $quellen/listBibl/biblStruct">
                  <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, true())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, false())"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
     <xsl:text>\unskip\pend
        \endnumbering\leavevmode\vspace{-3em} 
     </xsl:text>
     <xsl:apply-templates/>
     <xsl:if test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 'A0')">
        <xsl:value-of select="foo:abgedruckte-workNameRoutine(substring(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, 1, 7), substring-after(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level='a']/@key, ' '), false())"/>
     </xsl:if>
     <xsl:choose>
        <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc">
           <xsl:value-of select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, false())"/>
           <xsl:value-of select="foo:briefsender-mehrere-persName-rekursiv(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender, count(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName), ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@when, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/@n, ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date, false())"/>
        </xsl:when>
     </xsl:choose>  
  </xsl:template>
   
   <!-- body und Absätze von Hrsg-Texten -->
   
   <xsl:template match="body[ancestor::TEI[starts-with(@xml:id, 'E')]]">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="p[ancestor::TEI[starts-with(@xml:id, 'E')]]">
      <xsl:apply-templates/>
      <xsl:text>

      </xsl:text>
   </xsl:template>
   
    
  <!-- body -->
  
  
  
  
  <xsl:template match="div[@type='address']"/>
     
    
 <xsl:template match="div[@type='address']/address">
    <xsl:apply-templates/>
 </xsl:template>
  
    <xsl:template match="addrLine[position()=last()]">
       <xsl:apply-templates/>
  </xsl:template>
    
    <xsl:template match="addrLine[not(position()=last())]">
       <xsl:apply-templates /><xsl:text>{\slashislash}</xsl:text>
    </xsl:template>
  
  <xsl:template match="lb">
      <xsl:text>{\\[\baselineskip]}</xsl:text>
  </xsl:template>
   
   <xsl:template match="lb[parent::item]">
      <xsl:text>{\newline}</xsl:text>
   </xsl:template>
  
    <xsl:template match="footNote[ancestor::text/body]">
       <xsl:text>\footnote{</xsl:text>
       <xsl:apply-templates/>
       <xsl:text>}</xsl:text>
    </xsl:template> 
 
   <xsl:template match="p">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="p[ancestor::body and not(ancestor::TEI[starts-with(@xml:id, 'E')]) and not(child::space[@dim] and not(child::*[2]) and empty(text())) and not(parent::opener)]|seg|closer">
<!--     <xsl:if test="self::closer">\leftskip=1em{}</xsl:if>
-->     <xsl:if test="self::p[@rend='inline']">\leftskip=3em{}</xsl:if>
     <xsl:choose>
        <xsl:when test="table"/>
        <xsl:when test="textkonstitution/zu-anmerken/table"/>
        <xsl:otherwise>
           <xsl:text>\pstart
           </xsl:text>
        </xsl:otherwise>
     </xsl:choose>
      <xsl:choose> <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when test="string-length(normalize-space(self::*)) = 0 and child::*[1]=space[@unit='chars' and @quantity='1'] and not(child::*[2])"><xsl:text>\numberlinefalse{}</xsl:text></xsl:when>
         <xsl:when test="string-length(normalize-space(self::*)) = 1 and node()='–' and not(child::*)"><xsl:text>\numberlinefalse{}</xsl:text></xsl:when>
         <xsl:when test="missing-paragraph">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
      </xsl:choose>
     <xsl:choose>
        <xsl:when test="table"/>
        <xsl:when test="closer"/>
        <xsl:when test="postcript"/>
   <!--     <xsl:when test="self::salute">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="ancestor::*[@] or self::p[@]">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="preceding-sibling::*[1][self::p[child::*[1]=space[@unit='chars' and @quantity='1'] and not(child::*[2])] and string-length(normalize-space(self::*)) = 0 ]">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="preceding-sibling::*[1][self::p[child::space[@dim] and not(child::*[2]) and empty(text())]]">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="string-length(normalize-space(self::*)) = 1 and node()='–' and not(child::*)">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="preceding-sibling::*[1][self::head]">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>
        <xsl:when test="preceding-sibling::p[1][missing-paragraph]">
           <xsl:text>\noindent{}</xsl:text>
        </xsl:when>  
        <xsl:when test="local-name(preceding-sibling::*[1]) = local-name(current())">
           <xsl:choose>
              <xsl:when test="preceding-sibling::*[1]/@rend='right'">
                 <xsl:text>\noindent{}</xsl:text>
              </xsl:when>
              <xsl:when test="preceding-sibling::*[1]/@rend='center'">
                 <xsl:text>\noindent{}</xsl:text>
              </xsl:when>
           </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>\noindent{}</xsl:text>
        </xsl:otherwise>-->
     </xsl:choose>
     <xsl:if test="@rend">
        <xsl:value-of select="foo:absatz-position-vorne(@rend)"/>
     </xsl:if>
     <xsl:choose>
        <xsl:when test="missing-paragraph">
           <xsl:text><!--\noindent-->{[}{\,\footnotesize\textparagraph\normalsize\,}{]}</xsl:text>
        </xsl:when>
     </xsl:choose>
     <xsl:apply-templates/>
     <xsl:if test="@rend">
        <xsl:value-of select="foo:absatz-position-hinten(@rend)"/>
     </xsl:if>
      <xsl:choose> <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when test="string-length(normalize-space(self::*)) = 0 and child::*[1]=space[@unit='chars' and @quantity='1'] and not(child::*[2])">
            <xsl:text>\numberlinetrue{}</xsl:text></xsl:when>
         <xsl:when test="string-length(normalize-space(self::*)) = 1 and node()='–' and not(child::*)">
            <xsl:text>\numberlinetrue{}</xsl:text></xsl:when>
         <xsl:when test="missing-paragraph">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
      </xsl:choose>
     <xsl:choose>
        <xsl:when test="table"/>
        <xsl:when test="textkonstitution/zu-anmerken/table"/>
        <xsl:otherwise>
           <xsl:text>\pend
           </xsl:text>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:if test="self::closer|self::p[@rend='inline']">\leftskip=0em{}</xsl:if>
    
  </xsl:template>
   
   <xsl:template match="opener/dateline">
      <xsl:text>\pstart\raggedleft{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>
   
   <xsl:template match="opener/p">
      <xsl:text>\pstart\raggedleft{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>
   
   <xsl:template match="salute[parent::opener]">
      <xsl:text>\pstart\raggedright{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>
   
   <xsl:template match="salute">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:function name="foo:tabellenspalten">
      <xsl:param name="spaltenanzahl" as="xs:integer"/>
      <xsl:text>l</xsl:text>
      <xsl:if test="$spaltenanzahl&gt;1">
         <xsl:value-of select="foo:tabellenspalten($spaltenanzahl -1)"/>
      </xsl:if>
   </xsl:function>
   
   <xsl:template match="closer[not(child::lb)]">
      <xsl:text>\pstart <!--\raggedleft\hspace{1em}--></xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend{}</xsl:text>
    </xsl:template>
   
   <xsl:template match="closer/lb[not(last())]">
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="closer/lb[last()][following-sibling::signed]">
<xsl:choose>
   <xsl:when test="not(following-sibling::node()[not(self::signed)])">
      <xsl:apply-templates/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:otherwise>
</xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="closer/lb[last()][not(following-sibling::signed)]">
      <!--      <xsl:text>\pend\pstart\raggedleft\hspace{1em}</xsl:text>
-->      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   
 
   
   <xsl:template match="table">
      <xsl:variable name="longest1">
         <xsl:variable name="sorted-cells" as="element(cell)*"><xsl:perform-sort select="row/cell[1]"><xsl:sort select="string-length()"/></xsl:perform-sort></xsl:variable><xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
         <xsl:variable name="longest2">
            <xsl:variable name="sorted-cells" as="element(cell)*"><xsl:perform-sort select="row/cell[2]"><xsl:sort select="string-length()"/></xsl:perform-sort></xsl:variable><xsl:copy-of select="$sorted-cells[last()]"/>
         </xsl:variable>
         <xsl:variable name="longest3">
            <xsl:variable name="sorted-cells" as="element(cell)*"><xsl:perform-sort select="row/cell[3]"><xsl:sort select="string-length()"/></xsl:perform-sort></xsl:variable><xsl:copy-of select="$sorted-cells[last()]"/>
         </xsl:variable>
         <xsl:variable name="longest4">
            <xsl:variable name="sorted-cells" as="element(cell)*"><xsl:perform-sort select="row/cell[4]"><xsl:sort select="string-length()"/></xsl:perform-sort></xsl:variable><xsl:copy-of select="$sorted-cells[last()]"/>
         </xsl:variable>
         <xsl:variable name="longest5">
            <xsl:variable name="sorted-cells" as="element(cell)*"><xsl:perform-sort select="row/cell[5]"><xsl:sort select="string-length()"/></xsl:perform-sort></xsl:variable><xsl:copy-of select="$sorted-cells[last()]"/>
         </xsl:variable>
      <xsl:variable name="tabellen-anzahl" as="xs:integer" select="count(ancestor::body//table)"/>
      <xsl:variable name="xml-id-part" as="xs:string" select="ancestor::TEI/@xml:id"/>
         <xsl:text>\settowidth{\longeste}{</xsl:text>
            <xsl:value-of select="normalize-space($longest1)"/>
         <xsl:text>}</xsl:text>
      <xsl:if test="normalize-space($longest1) = 'Schnitzler' and normalize-space($longest2) ='Erziehung zur Ehe'"><!-- Sonderfall einer Tabelle, wo eigentlich das vorletze Element länger ist -->
         <xsl:text>\addtolength\longeste{0.2em}</xsl:text>
      </xsl:if>
      <xsl:if test="contains(normalize-space($longest1),'Morren')"><!-- Sonderfall einer Tabelle, wo eigentlich das vorletze Element länger ist -->
         <xsl:text>\settowidth\longeste{ABCDEFGHIJ}</xsl:text>
      </xsl:if>
      
         <xsl:text>\settowidth{\longestz}{</xsl:text>
         <xsl:value-of select="normalize-space($longest2)"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\settowidth{\longestd}{</xsl:text>
         <xsl:value-of select="normalize-space($longest3)"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\settowidth{\longestv}{</xsl:text>
         <xsl:value-of select="normalize-space($longest4)"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\settowidth{\longestf}{</xsl:text>
         <xsl:value-of select="normalize-space($longest5)"/>
         <xsl:text>}</xsl:text>
      <xsl:choose>
         <xsl:when test="string-length($longest5) > 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{0.5em}
        \addtolength\longestd{0.5em}
        \addtolength\longestv{0.5em}
        \addtolength\longestf{0.5em}</xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest4) > 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
        \addtolength\longestv{1em}
      </xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest3) > 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
      </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
      </xsl:text>
         </xsl:otherwise>
       </xsl:choose>
      <xsl:choose>
         <xsl:when test="starts-with($longest1,'Chiav')">
            <xsl:text>\addtolength\longeste{2em}</xsl:text>
         </xsl:when>
      </xsl:choose>
         <xsl:choose>
            <xsl:when test="@cols &gt; 5">
            <xsl:text>\textcolor{red}{Tabellen mit mehr als fünf Spalten bislang nicht vorgesehen XXXXX}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:for-each select="row">
                  <xsl:text>\pstart\noindent</xsl:text>
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longeste</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:if test="ancestor::textkonstitution">
                  <xsl:if test="parent::table/row[1] = current()">
                     <xsl:text>\edlabel{</xsl:text>
                     <xsl:value-of select="concat($xml-id-part,$tabellen-anzahl,'vorne')"/>
                     <xsl:text>}</xsl:text>
                     <xsl:value-of select="foo:textkonstitution-tabelle(ancestor::textkonstitution/lemma,ancestor::textkonstitution/textconst-inhalt,concat($xml-id-part,$tabellen-anzahl,'vorne'),concat($xml-id-part,$tabellen-anzahl,'hinten'))"/>
                  </xsl:if></xsl:if>
                  <xsl:if test="ancestor::textkonstitution">
                     <xsl:if test="parent::table/row[last()] = current()">
                        <xsl:text>\edlabel{</xsl:text>
                        <xsl:value-of select="concat($xml-id-part,$tabellen-anzahl,'hinten')"/>
                        <xsl:text>}</xsl:text>
                       </xsl:if></xsl:if>
                  <xsl:apply-templates select="cell[1]"/>
                  <xsl:text>}</xsl:text>
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestz</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="cell[2]"/>
                  <xsl:text>}
                  </xsl:text>
                  <xsl:if test="string-length($longest3) > 0">
                        <xsl:text>\makebox[</xsl:text>
                        <xsl:text>\the\longestd</xsl:text>
                        <xsl:text>][l]{</xsl:text>
                        <xsl:apply-templates select="cell[3]"/>
                        <xsl:text>}</xsl:text>
                     </xsl:if>
                  <xsl:if test="string-length($longest4) > 0">
                     <xsl:text>\makebox[</xsl:text>
                     <xsl:text>\the\longestd</xsl:text>
                     <xsl:text>][l]{</xsl:text>
                     <xsl:apply-templates select="cell[4]"/>
                     <xsl:text>}</xsl:text>
                  </xsl:if>
                  <xsl:if test="string-length($longest5) > 0">
                     <xsl:text>\makebox[</xsl:text>
                     <xsl:text>\the\longestd</xsl:text>
                     <xsl:text>][l]{</xsl:text>
                     <xsl:apply-templates select="cell[5]"/>
                     <xsl:text>}</xsl:text>
                  </xsl:if>
                  <xsl:text>\pend</xsl:text>
                 </xsl:for-each>
            </xsl:otherwise>
         </xsl:choose>
   </xsl:template>
   
   <xsl:template match="table[@rend='group']">
      <xsl:text>\smallskip\hspace{-5.75em}\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols= 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols= 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols= 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   
  
   <xsl:template match="table[ancestor::table]">
      <xsl:text>\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols= 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols= 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols= 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   
   <xsl:template match="row[parent::table[@rend='group']]">
      <xsl:choose> <!-- Eine Klammer kriegen nur die, die auch mehr als zwei Zeilen haben -->
         <xsl:when test="child::cell/@role='label' and child::cell/table/row[2]">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="cell[not(@role='label')]"/>
            <xsl:text>\right\}$ </xsl:text>
            <xsl:apply-templates select="cell[@role='label']"/>
         </xsl:when>
         <xsl:when test="child::cell/@role='label' and not(child::cell/table/row[2])">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="cell[not(@role='label')]"/>
            <xsl:text>\right.$\hspace{0.9em}</xsl:text>
            <xsl:apply-templates select="cell[@role='label']"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="position() = last"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="row[parent::table[not(@rend='group')] and ancestor::table[@rend='group']]">
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="position() = last"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
<xsl:template match="anchor[@type='label']">
         <xsl:text>\label{</xsl:text>
         <xsl:value-of select="@xml:id"/>
         <xsl:text>v}</xsl:text>
   <xsl:apply-templates/>
   <xsl:text>\label{</xsl:text>
   <xsl:value-of select="@xml:id"/>
   <xsl:text>h}</xsl:text>
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
   <xsl:if test="not(@arrow ='no')">
   <xsl:text>$\triangleright$</xsl:text>
   </xsl:if>
   <xsl:text>\myrangeref{</xsl:text>
   <xsl:value-of select="@target"/>
   <xsl:text>v}{</xsl:text>
   <xsl:value-of select="@target"/>
   <xsl:text>h}</xsl:text>
</xsl:template>
 
 <!-- <xsl:template match="row">
      <xsl:apply-templates/>
     <xsl:if test="following-sibling::row">
        <xsl:text>\\{}</xsl:text>
     </xsl:if>
  </xsl:template>
  -->
   
   <xsl:template match="cell[parent::row[parent::table[@rend='group']]]">
      <xsl:apply-templates/>
     <xsl:if test="following-sibling::cell">
        <xsl:text> </xsl:text>
     </xsl:if>
  </xsl:template>
   
   <xsl:template match="cell[parent::row[parent::table[not(@rend='group')]] and ancestor::table[@rend='group']]">
      <xsl:choose>
         <xsl:when test="position() = 1">
            <xsl:text>\makebox[0.2\textwidth][r]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="position() = 2">
            <xsl:text>\makebox[0.5\textwidth][l]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::cell">
         <xsl:text>\newcell </xsl:text>
      </xsl:if>
   </xsl:template>
  
   <xsl:template match="opener">
      <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Titel -->
  <xsl:template match="head">
     <xsl:choose>
        <xsl:when test="preceding-sibling::*[1][name()='head']"/>
        <xsl:otherwise>
           <xsl:if test="@type='sub'">
              <xsl:text>\medskip
         </xsl:text>
           </xsl:if> 
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>
        {\centering\pstart\noindent\leftskip=3em plus1fill\rightskip\leftskip
      </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend}
      </xsl:text>
     <xsl:choose>
        <xsl:when test="following-sibling::*[1][name()='head']"/>
        <xsl:otherwise>
           <xsl:text>\medskip
         </xsl:text>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
   
   <xsl:template match="head[ancestor::TEI[starts-with(@xml:id, 'E')]]">
      <xsl:choose>
         <xsl:when test="@sub">
            <xsl:text>\subsection{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\addsec{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:text>}\noindent{}</xsl:text>
   </xsl:template>

  
  
   <xsl:template match="div[@type='writingSession' and not(ancestor::*[self::text[@type='dedication']])]">
      <xsl:apply-templates/>
  </xsl:template>
   
   <xsl:template match="div[@type='writingSession' and ancestor::*[self::text[@type='dedication']]]">
      <xsl:text>\centerline{\begin{minipage}{0.5\textwidth}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{minipage}}</xsl:text>
   </xsl:template>
   
   
   <xsl:template match="div[@type='image']">
      <xsl:apply-templates/>
   </xsl:template>
  
  <xsl:template match="postscript">
     <!--<xsl:text>\noindent{}</xsl:text>-->
     <xsl:apply-templates/>
   </xsl:template>
  
  <xsl:template match="physDesc/p">
      <xsl:choose>
         <xsl:when test="ends-with(self::*, '.')">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ends-with(self::*, '.«')">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ends-with(self::*, '?«')">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ends-with(self::*, '!«')">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>.</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
   
   <xsl:template match="quote">
      <xsl:choose>
         <xsl:when test="ancestor::kommentarinhalt|ancestor::textkonstitution|ancestor::physDesc">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ancestor::TEI[substring(@xml:id, 1, 1) = 'E']">
            <xsl:choose>
               <xsl:when test="substring(current(), 1,1) = '»'">
                  <xsl:text>\begin{quoting}\noindent{}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{quoting}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
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


  <!-- Unterstreichung -->
  <xsl:template match="hi[@rend='underline']">
      <xsl:choose>
         <xsl:when test="parent::hi[@rend='superscript']|parent::hi[parent::signed and @rend='overline']|ancestor::addrLine">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="not(@n)">
            <xsl:text>\textcolor{red}{UNTERSTREICHUNG FEHLER:</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@hand">
            <xsl:text>\uline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '1'">
            <xsl:text>\emph{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '2'">
            <xsl:text>\emph{\uline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{\uline{\edtext{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}{</xsl:text>
            <xsl:if test="@n &gt; 2">
               <xsl:text>\Cendnote{</xsl:text>
               <xsl:choose>
                  <xsl:when test="@n = 3">
                     <xsl:text>Drei</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 4">
                     <xsl:text>Vier</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 5">
                     <xsl:text>Fünf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 6">
                     <xsl:text>Sechs</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 7">
                     <xsl:text>Sieben</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n &gt; 7">
                     <xsl:text>Unendlich viele Quatrillionentrilliarden und noch viel mehrmal unterstrichen</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:text>fach unterstrichen.</xsl:text>
               <xsl:text>}}}</xsl:text>
               <xsl:text>}\rmfamily{}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
    
      </xsl:choose>
  </xsl:template>
  
  <xsl:template match="hi[@rend='overline']">
     <xsl:choose>
        <xsl:when test="parent::signed|ancestor::addressLine">
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
        <xsl:text>\textoverline{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- Herausgebereingriff -->
  <xsl:template match="supplied[not(parent::damage)]">
      <xsl:text disable-output-escaping="yes">{[}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text disable-output-escaping="yes">{]}</xsl:text>
  </xsl:template>
  
  <!-- Unleserlich, unsicher Entziffertes -->
  <xsl:template match="unclear">
      <xsl:text>\textcolor{Gray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Durch Zerstörung unleserlich. Text ist stets Herausgebereingriff -->
  <xsl:template match="damage">
      <xsl:text>\damage{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  
  
  <!-- Loch / Unentziffertes -->
  <xsl:function name="foo:gapigap">
      <xsl:param name="gapchars" as="xs:integer"/>
      <xsl:text>×\-</xsl:text>
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
      <xsl:param name="spacep" as="xs:integer"/>
      <xsl:if test="$spacep &gt; 0">
         <xsl:text>\ </xsl:text>
         <xsl:call-template name="spacep">
            <xsl:with-param name="spacep" select="$spacep - 1"/>
         </xsl:call-template>
        </xsl:if>    
  </xsl:template>
   
   <xsl:template match="p[child::space[@dim] and not(child::*[2]) and empty(text())]">
      <xsl:text>{\bigskip}</xsl:text>
   </xsl:template>
  
   <xsl:template match="space[@dim='vertical']">
      <xsl:apply-templates/>
   </xsl:template>
  
   <xsl:template match="space[@unit='chars']">
     <xsl:choose>
        <xsl:when test="@style ='hfill' and not(following-sibling::node()[1][self::signed])"/>
        <xsl:when test="@quantity= 1 and not(string-length(normalize-space(parent::p)) = 0 and parent::p[child::*[1]=space[@unit='chars' and @quantity='1']] and parent::p[not(child::*[2])])">
           <xsl:text>{ }</xsl:text>
        </xsl:when>
        <xsl:otherwise>
           <xsl:call-template name="spacep">
              <xsl:with-param name="spacep" select="@quantity"/>
           </xsl:call-template>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
   
   
   <xsl:template match="signed">
            <xsl:text>\spacefill</xsl:text>
            <xsl:text>\mbox{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>


  <!-- Hinzufügung im Text -->
  <xsl:template match="add[@place and not(parent::subst)]">
      <xsl:text>\introOben{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introOben{}</xsl:text>
  </xsl:template>
  
  
  <!-- Streichung -->
  <xsl:template match="del[not(parent::subst)]">
      <xsl:text>\strikeout{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="del[parent::subst]">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="hyphenation">
     <xsl:choose>
        <xsl:when test="@alt">
           <xsl:value-of select="@alt"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates/>
        </xsl:otherwise>
     </xsl:choose>
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
            <xsl:text>[ms.:] </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{[}hs.:{]} </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
   <xsl:template match="handShift[@scribe]">
      <xsl:text>{[}hs. </xsl:text>
      <xsl:choose><!-- Sonderregeln wenn Gerty und Olga im gleichen Brief vorkommen wie Schnitzler und Hofmannsthal -->
         <xsl:when test="@scribe='A002038' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002001'">
            <xsl:value-of select="substring(normalize-space(key('person-lookup', @scribe, $persons)/Vorname), 1, 1)"/>
            <xsl:text>. </xsl:text>
         </xsl:when>
         <xsl:when test="@scribe='A002134' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002011'">
            <xsl:value-of select="substring(normalize-space(key('person-lookup', @scribe, $persons)/Vorname), 1, 1)"/>
            <xsl:text>. </xsl:text>
         </xsl:when>
         <xsl:when test="@scribe='A002676' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002675'">
            <xsl:value-of select="substring(normalize-space(key('person-lookup', @scribe, $persons)/Vorname), 1, 1)"/>
            <xsl:text>. </xsl:text>
         </xsl:when>
         <xsl:when test="@scribe='A002375' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@key='A002035'">
               <xsl:value-of select="substring(normalize-space(key('person-lookup', @scribe, $persons)/Vorname), 1, 1)"/>
               <xsl:text>. </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:value-of select="normalize-space(key('person-lookup', @scribe, $persons)/Nachname)"/>
      <!-- Sonderregel für Hofmannsthal senior -->
      <xsl:if test="@scribe='A002139'">
         <xsl:text> (sen.)</xsl:text>
      </xsl:if>
      <xsl:text>:{]}\normalsize{} </xsl:text>
    <!--  <xsl:if test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author/@key != @scribe">
      <xsl:value-of select="foo:person-in-index(@scribe,true())"/>
      <xsl:text>}</xsl:text>
      </xsl:if>-->
  </xsl:template>
  
  <!-- Kursiver Text für Schriftwechsel in den Handschriften-->
  <xsl:template match="hi[@rend='latintype']">
     <xsl:choose>
        <xsl:when test="ancestor::signed">
           <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>\textsc{</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>}</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
    
  </xsl:template>
   
   <!-- Gabelsberger, wird derzeit Orange ausgewiesen -->
   <xsl:template match="hi[@rend='gabelsberger']">
      <xsl:apply-templates/>
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
 
 
   <!-- Diese Funktion setzt das Ende der vorderen Edtext-Klammer und das Lemma, je nachdem, mit oder ohne edtext-Klammer -->
  <xsl:function name="foo:edtext-hinten">
      <xsl:param name="lemmatext" as="xs:string"/>
      <xsl:param name="im-text" as="xs:boolean"/>  
      <xsl:choose>
         <xsl:when test="$im-text">
            <xsl:text>}{\lemma{</xsl:text>
            <xsl:choose>
               <xsl:when test="string-length(normalize-space($lemmatext)) gt 30 and count(tokenize($lemmatext,' ')) gt 5">
                  <xsl:value-of select="tokenize($lemmatext,' ')[1]"/>
                  <xsl:choose>
                     <xsl:when test="tokenize($lemmatext,' ')[2]=':'">
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[3]"/>
                     </xsl:when>
                     <xsl:when test="tokenize($lemmatext,' ')[2]=';'">
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[3]"/>
                     </xsl:when>
                     <xsl:when test="tokenize($lemmatext,' ')[2]='!'">
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[3]"/>
                     </xsl:when>
                     <xsl:when test="tokenize($lemmatext,' ')[2]='«'">
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[3]"/>
                     </xsl:when>
                     <xsl:when test="tokenize($lemmatext,' ')[2]='.'">
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[3]"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($lemmatext,' ')[2]"/>
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text> {\mdseries\ldots} </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext,' ')[last()]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$lemmatext"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
  </xsl:function>
    
  <!-- Da mehrere Personen-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:persNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:param name="certlow" as="xs:boolean"/>
      <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
         <xsl:if test="$first!=''">
            <xsl:choose>
               <xsl:when test="$first='A002001' or $first='A002002'">
                  <!-- Einträge von Bahr und Schnitzler raus -->
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:person-in-index($first, $im-text)"/>
                  <xsl:text>|pw</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$certlow=true()">
                        <xsl:text>u</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="$kommentar-oder-hrsg">
                        <xsl:text>k</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                  <xsl:when test="$verweis">
                        <xsl:text>v</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:text>}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$rest!=''">
               <xsl:value-of select="foo:persNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text, $certlow, $kommentar-oder-hrsg)"/>
            </xsl:if>
         </xsl:if>
   </xsl:function>  
    
    <xsl:function name="foo:personInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('person-lookup',$first,$persons)"/>
       <xsl:value-of select="foo:person-in-index($first, false())"/>
       <xsl:text>|pwk}</xsl:text>
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
         <xsl:text>, </xsl:text>
         <xsl:value-of select="foo:persNameEndnoteR(substring($rest,1,7), substring-after($rest,' '),$verweis)"/>
      </xsl:if>
    </xsl:function>
         
  
  
   <!-- Personen Haupttemplate -->
    <xsl:template match="persName|rs[@type='person']">
      <xsl:variable name="inhalt" select="string(.)"/>
       <xsl:variable name="first" select="substring(@key,1,7)"/>
       <xsl:variable name="rest" select="substring-after(@key,' ')"/>
       <xsl:variable name="candidate" as="xs:boolean" select="ancestor::TEI/teiHeader/revisionDesc/@status = 'approved' or ancestor::TEI/teiHeader/revisionDesc/@status = 'candidate'"/>
       <xsl:variable name="im-text" as="xs:boolean" select="ancestor::body and not(parent::note) and not(ancestor::kommentarinhalt) and not(ancestor::physDesc) and not(parent::footNote) and not(ancestor::caption) and not(parent::bibl) and not(ancestor::TEI[starts-with(@xml:id, 'E')]) and not(ancestor::addrLine)"/>
       <xsl:variable name="kommentar-herausgeber" as="xs:boolean" select="ancestor::kommentarinhalt or ancestor::TEI[starts-with(@xml:id, 'E')]"/>
       <xsl:variable name="cert" as="xs:boolean" select="@cert ='low'"/>
       <xsl:variable name="verweis" as="xs:boolean" select="@type='person'"/>
       <xsl:choose>
          <xsl:when test="(not($candidate) and $im-text) or (@subtype='local' and $im-text)">
             <xsl:text>\edtext{</xsl:text>
             <xsl:apply-templates/>
             <xsl:value-of select="foo:edtext-hinten($inhalt, $im-text)"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:apply-templates/>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:value-of select="foo:persNameRoutine($first, $rest, $verweis, $im-text, $cert, $kommentar-herausgeber)"/>
       <xsl:if test="@subtype and $im-text">
          <xsl:text>\Cendnote{</xsl:text>
          <xsl:value-of select="foo:persNameEndnoteR($first, $rest, false())"/>
          <xsl:text>}</xsl:text>
       </xsl:if>
       <xsl:choose>
          <xsl:when test="not($candidate) and $im-text">
          <xsl:text>\Bendnote{</xsl:text>
             <xsl:value-of select="foo:persNameEndnoteR($first, $rest, $verweis)"/>
          <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="not($candidate) and not($im-text)">
             <xsl:text>\footnote{PERSONENINDEX:</xsl:text>
             <xsl:value-of select="foo:persNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text></xsl:text>
          </xsl:when>
       </xsl:choose>
       <xsl:if test="$candidate=false() or (@subtype='local' and $im-text)">
             <xsl:text>}</xsl:text>
          </xsl:if>
       <xsl:if test="not(@key) and not(parent::bibl)">
          <xsl:text>\footnote{\textcolor{red}{PERSONENNUMMER FEHLT XXXXX!}}</xsl:text>
       </xsl:if>
  </xsl:template>
  
   
  
   
   <!-- WERKE -->
    
    <!-- Da mehrere Werke-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:workNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:param name="certlow" as="xs:boolean"/>
       <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
          <xsl:if test="$first!=''">
             <xsl:choose>
                <xsl:when test="foo:werke-key-check($first)=true()">
                <xsl:text>\textcolor{red}{WERKINDEX FEHLER}</xsl:text>  
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="foo:werk-in-index($first, $im-text, false())"/>
                   <xsl:text>|pw</xsl:text>
                   <xsl:choose>
                      <xsl:when test="$certlow=true()">
                         <xsl:text>u</xsl:text>
                      </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                      <xsl:when test="$kommentar-oder-hrsg">
                         <xsl:text>k</xsl:text>
                      </xsl:when>
                   </xsl:choose>   
                   <xsl:choose>
                   <xsl:when test="$verweis">
                         <xsl:text>v</xsl:text>
                      </xsl:when>
                   </xsl:choose>
                   <xsl:text>}</xsl:text>
                </xsl:otherwise>
             </xsl:choose>
             <xsl:if test="$rest!=''">
                <xsl:value-of select="foo:workNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text, $certlow, $kommentar-oder-hrsg)"/>
             </xsl:if>
          </xsl:if>
    </xsl:function>  
   
   <!-- Da mehrere Werke-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:abgedruckte-workNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:if test="$first!=''">
         <xsl:choose>
            <xsl:when test="foo:werke-key-check($first)=true()">
               <xsl:text>\textcolor{red}{WERKINDEX FEHLER}</xsl:text>  
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:werk-in-index($first, false(), true())"/>
               <xsl:text>|pwt</xsl:text>
               <xsl:choose>
                  <xsl:when test="$vorne">
                     <xsl:text>(</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>)</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:text>}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="$rest!=''">
            <xsl:value-of select="foo:abgedruckte-workNameRoutine(substring($rest,1,7),substring-after($rest,' '),$vorne)"/>
         </xsl:if>
      </xsl:if>
   </xsl:function>  
    
    <xsl:function name="foo:werkInEndnote">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:variable name="entry" select="key('work-lookup',$first,$works)"/>
       <xsl:variable name="author-entry" select="key('person-lookup',$entry/Autor,$persons)"/>
       <xsl:value-of select="foo:werk-in-index($first,false(), false())"/>
       <xsl:text>|pwk}</xsl:text>
       <xsl:if test="$verweis">
          <xsl:text>$\rightarrow$</xsl:text>
       </xsl:if>
       <xsl:if test="$entry/Autor!=''">
          <xsl:choose>
             <xsl:when test="$entry/Autor ='A002003'"/>
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
             <xsl:value-of select="substring-before($entry/Titel,':] ')"/>
             <xsl:text>]: \emph{</xsl:text>
             <xsl:value-of select="substring-after($entry/Titel,':] ')"/>
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
       <xsl:value-of select="foo:werk-in-index($first,false(), false())"/>
       <xsl:text>|pwk}</xsl:text>
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
       <xsl:variable name="inhalt" select="string(.)"/>
       <xsl:variable name="first" select="substring(@key,1,7)"/>
       <xsl:variable name="rest" select="substring-after(@key,' ')"/>
       <xsl:variable name="candidate" as="xs:boolean" select="ancestor::TEI/teiHeader/revisionDesc/@status = 'approved' or ancestor::TEI/teiHeader/revisionDesc/@status = 'candidate'"/>
       <xsl:variable name="im-text" as="xs:boolean" select="ancestor::body and not(parent::note) and not(ancestor::kommentarinhalt) and not(ancestor::physDesc) and not(ancestor::caption) and not(parent::bibl) and not(ancestor::TEI[starts-with(@xml:id, 'E')]) and not(ancestor::addrLine)"/>
       <xsl:variable name="kommentar-herausgeber" as="xs:boolean" select="ancestor::kommentarinhalt or (ancestor::TEI[starts-with(@xml:id, 'E')] and not(ancestor::TEI/@xml:id ='E000003'))"/> <!-- Sonderregel für Bücher im Gegenseitigen Besitz -->
       <xsl:variable name="cert" as="xs:boolean" select="@cert ='low'"/>
       <xsl:variable name="verweis" as="xs:boolean" select="@type='work'"/>
       <xsl:choose>
                <xsl:when test="(not($candidate) and $im-text) or @subtype">
                   <xsl:text>\edtext{</xsl:text>
                   <xsl:apply-templates/>
                   <xsl:value-of select="foo:edtext-hinten($inhalt, $im-text)"/>
                </xsl:when>
          <xsl:when test="self::workName and not($im-text) and not(ancestor::quote) and not(parent::workName)">
             <xsl:text>\emph{</xsl:text> <!-- Titel kursiv wenn sie in Herausgebertexten sind -->
             <xsl:apply-templates/>
             <xsl:text>}</xsl:text>
          </xsl:when>
                <xsl:otherwise>
                   <xsl:apply-templates/>
                </xsl:otherwise>
             </xsl:choose> 
             <xsl:value-of select="foo:workNameRoutine($first, $rest, $verweis, $im-text, $cert, $kommentar-herausgeber)"/>
       <xsl:if test="@subtype and $im-text">
                <xsl:text>\Cendnote{</xsl:text>
             <xsl:choose>
                <xsl:when test="@subtype='local'">
                   <xsl:value-of select="foo:workNameEndnoteR($first, $rest, false())"/>
                </xsl:when>
                <xsl:when test="@subtype='local-short'">
                   <xsl:value-of select="foo:workNameOhneAutorEndnoteR($first, $rest, false())"/>
                </xsl:when>
            </xsl:choose>
          <xsl:text>}</xsl:text>
             </xsl:if>
       <xsl:choose>
          <xsl:when test="not($candidate) and $im-text">
             <xsl:text>\Bendnote{</xsl:text>
                   <xsl:value-of select="foo:workNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="not($candidate) and not($im-text)">
             <xsl:text>\footnote{WERKINDEX:</xsl:text>
                   <xsl:value-of select="foo:workNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
       </xsl:choose>
       <xsl:if test="(not($candidate) and $im-text) or @subtype">
                <xsl:text>}</xsl:text>
             </xsl:if>
       <xsl:if test="not(@key) and not(parent::bibl)">
          <xsl:text>\footnote{\textcolor{red}{WERKNUMMER FEHLT XXXXX!}}</xsl:text>
       </xsl:if>
    </xsl:template>
    
    

<!-- ORGANISATIONEN -->
    
    <!-- Da mehrere Org-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:orgNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:param name="certlow" as="xs:boolean"/>
        <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
       <xsl:if test="$first!=''">
          <xsl:value-of select="foo:organisation-in-index($first, $im-text)"/>
          <xsl:text>|pw</xsl:text>
          <xsl:choose>
             <xsl:when test="$certlow=true()">
                <xsl:text>u</xsl:text>
             </xsl:when>
          </xsl:choose>
          <xsl:choose>
             <xsl:when test="$kommentar-oder-hrsg">
                <xsl:text>k</xsl:text>
             </xsl:when>
          </xsl:choose>
          <xsl:choose>
          <xsl:when test="$verweis">
                <xsl:text>v</xsl:text>
             </xsl:when>
          </xsl:choose>
          <xsl:text>}</xsl:text>
          <xsl:if test="$rest!=''">
             <xsl:value-of select="foo:orgNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text, $certlow, $kommentar-oder-hrsg)"/>
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
       <xsl:variable name="inhalt" select="current()"/>
       <xsl:variable name="first" select="substring(@key,1,7)"/>
       <xsl:variable name="rest" select="substring-after(@key,' ')"/>
       <xsl:variable name="candidate" as="xs:boolean" select="ancestor::TEI/teiHeader/revisionDesc/@status = 'approved' or ancestor::TEI/teiHeader/revisionDesc/@status = 'candidate'"/>
       <xsl:variable name="im-text" as="xs:boolean" select="ancestor::body and not(parent::note) and not(ancestor::kommentarinhalt) and not(ancestor::physDesc) and not(ancestor::caption) and not(parent::bibl) and not(ancestor::TEI[starts-with(@xml:id, 'E')]) and not(ancestor::addrLine)"/>
       <xsl:variable name="kommentar-herausgeber" as="xs:boolean" select="ancestor::kommentarinhalt or ancestor::TEI[starts-with(@xml:id, 'E')]"/>
       <xsl:variable name="cert" as="xs:boolean" select="@cert ='low'"/>
       <xsl:variable name="verweis" as="xs:boolean" select="@type='org'"/>
       <xsl:choose>
          <xsl:when test="(not($candidate) and $im-text) or @subtype">
             <xsl:text>\edtext{</xsl:text>
             <xsl:apply-templates/>
             <xsl:value-of select="foo:edtext-hinten($inhalt, $im-text)"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="self::orgName and not($im-text) and not(ancestor::quote)">
                   <xsl:text>\emph{</xsl:text>
                   <xsl:apply-templates/>
                   <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:apply-templates/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose> 
       <xsl:choose>
           <xsl:when test="self::orgName">
                   <xsl:choose>
                      <xsl:when test="$first='' and not(parent::bibl)">
                         <xsl:text>\textcolor{red}{ORGANGABE FEHLT}</xsl:text>
                      </xsl:when>
                      <xsl:when test="$first='' and parent::bibl"/>
                      <xsl:otherwise>
                         <xsl:value-of select="foo:orgNameRoutine($first, $rest, false(), $im-text, $cert, $kommentar-herausgeber)"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:when test="self::rs">
                   <xsl:value-of select="foo:orgNameRoutine($first, $rest, true(), $im-text, $cert, $kommentar-herausgeber)"/>
                </xsl:when>
             </xsl:choose>
             <xsl:if test="@subtype='local'">
                <xsl:text>\Cendnote{</xsl:text>
                <xsl:value-of select="foo:orgNameEndnoteR($first, $rest, $verweis)"/>
                <xsl:text>}</xsl:text>
             </xsl:if>
       <xsl:choose>
          <xsl:when test="not($candidate) and $im-text">
             <xsl:text>\Bendnote{</xsl:text>
             <xsl:value-of select="foo:orgNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="not($candidate) and not($im-text)">
             <xsl:text>\footnote{</xsl:text>
             <xsl:value-of select="foo:orgNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
       </xsl:choose>
             <xsl:if test="(not($candidate) and $im-text) or @subtype='local'">
                <xsl:text>}</xsl:text>
             </xsl:if>
         </xsl:template>
  
   <!-- ORTE: -->
    
    <!-- Da mehrere place-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
    <xsl:function name="foo:placeNameRoutine">
       <xsl:param name="first" as="xs:string"/>
       <xsl:param name="rest" as="xs:string"/>
       <xsl:param name="verweis" as="xs:boolean"/>
       <xsl:param name="im-text" as="xs:boolean"/>
       <xsl:param name="certlow" as="xs:boolean"/>
        <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
       <xsl:choose>
             <xsl:when test="foo:orte-key-check($first)=true()">
                <xsl:text>\textcolor{red}{ORTINDEX FEHLER}</xsl:text>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="foo:place-in-index($first, $im-text)"/>
                <xsl:text>|pw</xsl:text>
                <xsl:choose>
                   <xsl:when test="$certlow=true()">
                      <xsl:text>u</xsl:text>
                   </xsl:when>
                </xsl:choose>
                <xsl:choose>
                   <xsl:when test="$kommentar-oder-hrsg">
                      <xsl:text>k</xsl:text>
                   </xsl:when>
                </xsl:choose>
                <xsl:choose>
                   <xsl:when test="$verweis">
                      <xsl:text>v</xsl:text>
                   </xsl:when>
                </xsl:choose>
                <xsl:text>}</xsl:text>
             </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="$rest!=''">
             <xsl:value-of select="foo:placeNameRoutine(substring($rest,1,7),substring-after($rest,' '),$verweis,$im-text, $certlow, $kommentar-oder-hrsg)"/>
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
       <xsl:variable name="inhalt" select="current()"/>
       <xsl:variable name="first" select="substring(@key,1,7)"/>
       <xsl:variable name="rest" select="substring-after(@key,' ')"/>
       <xsl:variable name="candidate" as="xs:boolean" select="ancestor::TEI/teiHeader/revisionDesc/@status = 'approved' or ancestor::TEI/teiHeader/revisionDesc/@status = 'candidate'"/>
       <xsl:variable name="im-text" as="xs:boolean" select="ancestor::body and not(parent::note) and not(ancestor::kommentarinhalt) and not(ancestor::physDesc) and not(ancestor::caption) and not(parent::bibl) and not(ancestor::TEI[starts-with(@xml:id, 'E')]) and not(ancestor::addrLine)"/>
       <xsl:variable name="kommentar-herausgeber" as="xs:boolean" select="ancestor::kommentarinhalt or ancestor::TEI[starts-with(@xml:id, 'E')]"/>
       <xsl:variable name="cert" as="xs:boolean" select="@cert ='low'"/>
       <xsl:variable name="verweis" as="xs:boolean" select="@type='place'"/>
       <xsl:choose>
          <xsl:when test="$inhalt = 'Wien' or $first= 'A000250'">
             <xsl:apply-templates/>
          </xsl:when><!-- WIEN nicht in den Index -->
          <xsl:when test="parent::bibl"> <!-- Orte in bibliografischen Angaben nicht in den Index -->
             <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
          <xsl:choose>
             <xsl:when test="(not($candidate) and $im-text) or @local">
             <xsl:text>\edtext{</xsl:text>
             <xsl:apply-templates/>
             <xsl:text>}{</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:apply-templates/>
          </xsl:otherwise>
          </xsl:choose>
       <xsl:value-of select="foo:placeNameRoutine($first, $rest, $verweis, $im-text, $cert, $kommentar-herausgeber)"/>
       <xsl:choose>
         <xsl:when test="$im-text and @local">
             <xsl:text>\Cendnote{</xsl:text>
            <xsl:value-of select="foo:placeNameRoutine($first, $rest, $verweis, $im-text, $cert, $kommentar-herausgeber)"/>
             <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="not($im-text) and @local"/>
       </xsl:choose>
          <xsl:choose>
             <xsl:when test="not($candidate) and $im-text">
             <xsl:text>\Bendnote{</xsl:text>
               <xsl:value-of select="foo:placeNameEndnoteR($first, $rest, $verweis)"/>
             <xsl:text>}</xsl:text>
             </xsl:when>
                <xsl:when test="not($candidate) and not($im-text)">
                   <xsl:text>\footnote{</xsl:text>
                   <xsl:value-of select="foo:placeNameEndnoteR($first, $rest, $verweis)"/>
                   <xsl:text>}</xsl:text>
                </xsl:when>
          </xsl:choose>
          <xsl:if test="(not($candidate) and $im-text) or @local">
             <xsl:text>}</xsl:text>
          </xsl:if>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
   
   <xsl:function name="foo:normalize-und-umlaute">
      <xsl:param name="wert" as="xs:string"/>
      <xsl:value-of select="normalize-space(foo:umlaute-entfernen($wert))"/>
   </xsl:function>

  <xsl:function name="foo:place-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="im-text" as="xs:boolean"/>
     <xsl:variable name="eintrag" select="key('place-lookup', $first, $places)"/>
      <xsl:variable name="ort" select="$eintrag/Ort"/>
     <xsl:variable name="bezirk" select="$eintrag/Bezirk"/>
     <xsl:variable name="einrichtung" select="$eintrag/Name"/>
     <xsl:variable name="typ" select="$eintrag/Typ"/>
            <xsl:text>\oindex{</xsl:text>
            <xsl:apply-templates select="foo:index-sortiert($ort, 'bf')"/>
            <xsl:choose> <!-- Bei Wien die Bezirke einfügen -->
               <xsl:when test="normalize-space($ort) ='Wien'">
                  <xsl:text>!</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$bezirk = '' or empty($bezirk) or starts-with($bezirk, 'Bezirksübergreifend')">
                        <xsl:text>00 b@\textbf{Übergreifend}</xsl:text>
                     </xsl:when>
                     <xsl:otherwise><xsl:choose>
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
                        </xsl:when></xsl:choose>
                        <xsl:value-of select="foo:index-sortiert($bezirk, 'bf')"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
            <xsl:if test="$einrichtung!=''">
               <xsl:text>!</xsl:text>
               <xsl:apply-templates select="foo:index-sortiert($einrichtung, 'up')"/>
            </xsl:if>
            <xsl:if test="$typ !=''">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="normalize-space($typ)"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
  </xsl:function>
    
   
 <!-- KOMMENTAR -->
 
  <xsl:template match="kommentar">
      <xsl:text>\edtext{</xsl:text>
      <xsl:apply-templates select="zu-kommentieren"/>
      <xsl:text>}{\lemma{</xsl:text>
      <xsl:value-of select="normalize-space(lemma)"/>
      <xsl:text>}\Cendnote{</xsl:text>
      <xsl:apply-templates select="kommentarinhalt"/>
      <xsl:text>}}</xsl:text>
  </xsl:template>

<xsl:function name="foo:textkonstitution-tabelle">
   <xsl:param name="lemma" as="xs:string"/>
   <xsl:param name="textconst-inhalt" as="xs:string"/>
   <xsl:param name="linenum-vorne" as="xs:string"/>
   <xsl:param name="linenum-hinten" as="xs:string"/>
   <xsl:text>\edtext{}{\linenum{|\xlineref{</xsl:text>
   <xsl:value-of select="$linenum-vorne"/>
   <xsl:text>}|||\xlineref{</xsl:text>
   <xsl:value-of select="$linenum-hinten"/>
   <xsl:text>}||}\lemma{</xsl:text>
   <xsl:value-of select="normalize-space($lemma)"/>
   <xsl:text>}\Cendnote{</xsl:text>
    <xsl:apply-templates select="$textconst-inhalt"/>
   <xsl:text>}}</xsl:text>
</xsl:function>


    <xsl:template match="textkonstitution">
       <xsl:choose>
          <xsl:when test="zu-anmerken/table">
             <xsl:apply-templates select="zu-anmerken/table"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>\edtext{</xsl:text>
             <xsl:apply-templates select="zu-anmerken"/>
             <xsl:text>}{\lemma{</xsl:text>
             <xsl:value-of select="normalize-space(lemma)"/>
             <xsl:text>}\Cendnote{</xsl:text>
             <xsl:apply-templates select="textconst-inhalt"/>
             <xsl:text>}}</xsl:text>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

<!-- Bilder einbetten -->
<xsl:template match="figure">
   <xsl:choose>
      <xsl:when test="ancestor::TEI//teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-E'">
         <xsl:text>\begin{figure}[htbp]</xsl:text>
         <xsl:text>\centering</xsl:text>
         <xsl:text>\noindent</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>\end{figure}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
      <!-- Illustrationen werden nur einfach so gesetzt -->
     <xsl:choose> 
        <xsl:when test="ancestor::TEI//teiHeader[1]/fileDesc[1]/publicationStmt[1]/idno[1]/@type='HBAS-J'">
         <xsl:text>\begin{figure}[tb]</xsl:text>
         <xsl:text>\centering</xsl:text>
         <xsl:text>\noindent</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>\end{figure}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text>\begin{figure}[H]</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>\end{figure}</xsl:text>
      </xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="caption">
   <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>{\endgraf\footnotesize\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}</xsl:text>
</xsl:template>
    
<xsl:template match="graphic">
   <xsl:text>\includegraphics</xsl:text>
   <xsl:choose>
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
         <xsl:text>[max height=\linewidth,max width=\linewidth]
</xsl:text>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:text>{</xsl:text>
   <xsl:value-of select="substring(@url,3)"/>
   <xsl:text>}</xsl:text>
</xsl:template>

   <xsl:template match="list">
      <xsl:text>\begin{itemize}[noitemsep, leftmargin=*]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{itemize}</xsl:text>
   </xsl:template>
   
   <xsl:template match="item">
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
      </xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='gloss']">
      <xsl:text>\setlist[description]{font=\normalfont\upshape\mdseries,style=nextline}\begin{description}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{description}</xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='gloss']/label">
      <xsl:text>\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='gloss']/item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='simple-gloss']">
      <xsl:text>\begin{description}[font=\normalfont\upshape\mdseries, itemsep=0em, labelwidth=5em, itemsep=0em,leftmargin=5.6em]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{description}</xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='simple-gloss']/label">
      <xsl:text>\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   
   <xsl:template match="list[@type='simple-gloss']/item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

</xsl:stylesheet>
