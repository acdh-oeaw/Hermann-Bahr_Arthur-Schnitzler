<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:foo="whatever"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
   <xsl:template match="@*|node()">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
  
 
  <!-- TEMPLATES -->
  
   <!-- Texte.       Allerein. Besondere Behandlung bei outOfScope und output=true-->
  <xsl:template match="TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-T']">
      <xsl:choose>
         <xsl:when test="descendant::gap[@reason='outOfScope']">
            <TEI short="true()">
                  <xsl:apply-templates select="@*|node()"/>
            </TEI>
         </xsl:when>
         <xsl:when test="descendant::*[@output='true'] and descendant::p[ancestor::body and not(@output) and not(descendant::*/@key='A002002') and not(descendant::*/@key='A002001')]">
            <TEI short="true()">
               <xsl:apply-templates select="@*|node()"/>
            </TEI>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy copy-namespaces="no">
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
   
   <!-- Tagebücher -->
   <xsl:template match="TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-D']">
      <xsl:choose>
         <!-- Unveröffentlicht -->
         <xsl:when test="teiHeader/fileDesc/sourceDesc/listWit and not(teiHeader/fileDesc/sourceDesc/listBibl)">
               <!-- Hierher müsste der Fall, dass es unveröffentlichte Tagebücher gibt, die trotzdem gekürzt werden -->
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
         </xsl:when>
         <!-- Veröffentlicht -->
         <xsl:otherwise>
            <xsl:choose>
               <!-- Einträge von Schnitzler -->
               <xsl:when test="teiHeader/fileDesc/titleStmt/author[@key='A002001']">
                  <xsl:choose>
                     <xsl:when test="descendant::*[@output='true'] and descendant::p[ancestor::body and not(@output) and not(descendant::*/@key='A002002')]">
                        <TEI short="true()">
                           <xsl:apply-templates select="@*|node()"/>
                        </TEI>
                     </xsl:when>
                     <xsl:when test="text/body//p[not(@output='true' or descendant::*/@key='A002002')]">
                        <TEI short="true()">
                           <xsl:apply-templates select="@*|node()"/>
                        </TEI>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:copy copy-namespaces="no">
                           <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
                  <!-- Einträge von Bahr -->
                  <xsl:when test="teiHeader/fileDesc/titleStmt/author[@key='A002002']">
                     <xsl:choose>
                        <xsl:when test="descendant::*[@output='true'] and descendant::p[ancestor::body and not(@output) and not(descendant::*/@key='A002001')]">
                           <TEI short="true()">
                              <xsl:apply-templates select="@*|node()"/>
                           </TEI>
                        </xsl:when>
                        <xsl:when test="text/body//p[not(@output='true' or descendant::*[@key,'A002001'])]">
                           <TEI short="true()">
                              <xsl:apply-templates select="@*|node()"/>
                           </TEI>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:copy copy-namespaces="no">
                              <xsl:apply-templates select="@*|node()"/>
                           </xsl:copy>
                        </xsl:otherwise>
                     </xsl:choose>
               </xsl:when>
               <xsl:when test="descendant::*[@output='true'] and descendant::p[ancestor::body and not(@output) and not(descendant::*/@key='A002001' and descendant::*/@key='A002002')]">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <xsl:when test="descendant::p//*[@output='true']">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <!-- Andernfalls vollständig -->
               <xsl:otherwise>
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- Briefe -->
   <xsl:template match="TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-L']">
      <xsl:choose>
         <!-- Unveröffentlicht -->
         <xsl:when test="teiHeader/fileDesc/sourceDesc/listWit and not(teiHeader/fileDesc/sourceDesc/listBibl)">
            <xsl:choose>
               <!-- Briefe Schnitzlers an Bahr rein -->
               <xsl:when test="teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/sender[1]/persName[@key='A002001'] and teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/addressee[1]/persName[@key='A002002']">
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
               </xsl:when>
               <!-- umgekehrt -->
               <xsl:when test="teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/sender[1]/persName[@key='A002002'] and teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/addressee[1]/persName[@key='A002001']">
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
               </xsl:when>
               <!-- Die Briefe von dritten können gekürzt werden, wenn sie output enthalten -->
               <xsl:when test="descendant::*[@output='true'] and not(teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/sender[1]/persName[@key='A002001' or @key='A002002'])">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <!-- Gibst ein outOfScope ists kurz -->
               <xsl:when test="descendant::gap[@reason='outOfScope']">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <xsl:otherwise> <!-- Andernfalls gesamter Text rein -->
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!-- Veröffentlicht -->
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="descendant::gap[@reason='outOfScope']">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <xsl:when test="descendant::*[@output='true'] and descendant::p[ancestor::body and not(@output) and not(descendant::*/@key='A002001') and not(descendant::*/@key='A002002')]">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <!-- Wenn in einem Eintrag Bahrs nicht Schnitzler vorkommt, ist's kurz -->
               <xsl:when test="teiHeader/fileDesc/titleStmt/author[@key='A002002'] and not(descendant::body//*[@key,'A002001'])">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <!-- umgekehrt -->
               <xsl:when test="teiHeader/fileDesc/titleStmt/author[@key='A002001'] and not(descendant::body//*[@key,'A002002'])">
                  <TEI short="true()">
                     <xsl:apply-templates select="@*|node()"/>
                  </TEI>
               </xsl:when>
               <!-- Andernfalls vollständig -->
               <xsl:otherwise>
                  <xsl:copy copy-namespaces="no">
                     <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   
   <!-- Das kürzt jene Absätze, die einen Anchor mit output haben -->
  <xsl:template match="p/anchor[@output='true' and not(preceding-sibling::node())]">
     <p> 
     <xsl:apply-templates/>
      <xsl:text> {[}\dots{]}</xsl:text>
     </p>
  </xsl:template>
  
  <xsl:template match="p/anchor[@output='true' and preceding-sibling::node() and following-sibling::node()]">
     <p>
      <xsl:text>{[}\dots{]} </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> {[}\dots{]}</xsl:text>
     </p>
  </xsl:template>
  
  <xsl:template match="p/anchor[@output='true' and not(following-sibling::node())]">
     <p>
      <xsl:text>{[}\dots{]} </xsl:text>
      <xsl:apply-templates/>
     </p>
  </xsl:template>
 
   <xsl:template match="p[ancestor::body]|salute[parent::opener]|dateline[parent::opener]|dateline[parent::postscript]|seg[parent::opener]|closer|lg|head">
    <xsl:choose>
 <!-- TEXT -->
       <xsl:when test="ancestor::TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-T']">
          <xsl:choose><!-- Zuerst jene Texte, die ein output true vermerkt haben -->
             <!-- Wenn output true vorkommt, werden jene ohne output gekürzt -->
             <xsl:when test="ancestor::body//*[@output='true']">
                <xsl:choose>
                   <!-- Ist innerhalb des Absatzes gekürzt -->
                   <xsl:when test="child::anchor[@output='true']">
                      <xsl:apply-templates select="anchor[@output='true']"/>
                   </xsl:when>
                   <xsl:when test="self::*[@output='true']">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                   <!-- kommt der jeweils andere vor, ausgeben -->
                   <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002'] and descendant::*[contains(@key,'A002001')]">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                   <!-- andersrum -->
                   <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001'] and descendant::*[contains(@key,'A002002')]">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                 
                   <xsl:otherwise>
                      <p><missing-paragraph/></p>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:when>             
             <!-- Wenn Absätze ausgelassen sind, wird geschaut, ob zwischen zwei abgedruckten Absätzen -->
             <xsl:when test="child::gap[@reason='outOfScope']">
                <xsl:choose>
                   <xsl:when test="count(child::*) = 1">
                      <xsl:choose>
                         <xsl:when test="not(preceding-sibling::*)"/>
                         <xsl:when test="not(following-sibling::*)"/>
                         <xsl:otherwise>
                            <p><missing-paragraph/></p>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:when>
             <!-- sonst alle Texte ausgeben -->
             <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                   <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
  <!-- TAGEBUCH -->
       <xsl:when test="ancestor::TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-D']">
          <!-- erste Unterscheidung: gedruckt oder ungedruckt -->
          <xsl:choose>
             <!-- Zuerst die gedruckten Fälle-->
                <xsl:when test="ancestor::TEI[teiHeader/fileDesc/sourceDesc/listBibl]">
                   <xsl:choose>
                      <!-- Ist innerhalb des Absatzes gekürzt -->
                      <xsl:when test="child::anchor[@output='true']">
                         <xsl:apply-templates select="anchor[@output='true']"/>
                      </xsl:when>
                      <!-- kommt der jeweils andere vor, ausgeben -->
                      <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002'] and descendant::*[contains(@key,'A002001')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                      <!-- andersrum -->
                      <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001'] and descendant::*[contains(@key,'A002002')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                      <!-- Aufzeichnungen Dritter mit beiden vorkommend -->
                      <xsl:when test="not(ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001']) and not(ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002']) and descendant::*[contains(@key,'A002001')] and descendant::*[contains(@key,'A002002')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                      <!-- Ist innerhalb des Absatzes gekürzt -->
                      <xsl:when test="child::anchor[@output='true']">
                         <xsl:apply-templates select="anchor[@output='true']"/>
                      </xsl:when>
                      <xsl:when test="@output='true'">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                      <xsl:otherwise>
                         <p><missing-paragraph/></p>
                      </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
             <!-- ungedruckt -->
             <xsl:otherwise>
                <xsl:choose>
                   <xsl:when test="@output='true'">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                      <!-- kommt der jeweils andere vor, ausgeben -->
                      <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002'] and descendant::*[contains(@key,'A002001')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                      <!-- andersrum -->
                      <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001'] and descendant::*[contains(@key,'A002002')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                   <!-- ists vom Bahr und kommt kein output vor -->
                   <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002'] and not(ancestor::body//*[@output='true'])">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                   <!-- andersrum -->
                   <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001'] and not(ancestor::body//*[@output='true'])">
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:when>
                      <!-- Ist innerhalb des Absatzes gekürzt -->
                      <xsl:when test="child::anchor[@output='true']">
                         <xsl:apply-templates select="anchor[@output='true']"/>
                      </xsl:when>
                      <!-- Aufzeichnungen Dritter -->
                      <xsl:when test="not(ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001']) and not(ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002']) and descendant::*[contains(@key,'A002001')] and descendant::*[contains(@key,'A002002')]">
                         <xsl:copy copy-namespaces="no">
                            <xsl:apply-templates select="@*|node()"/>
                         </xsl:copy>
                      </xsl:when>
                   <xsl:otherwise>
                      <p><missing-paragraph/></p>
                   </xsl:otherwise>
                </xsl:choose>
             
             </xsl:otherwise>
            
          </xsl:choose>
       </xsl:when>
 <!-- BRIEFE -->      
       <xsl:when test="ancestor::TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-L']">
          <xsl:choose>
             <!-- Ein Brief von Bahr an Schnitzler wird ausgegeben -->
             <xsl:when test="teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/sender[1]/persName[@key='A002001'] and teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/addressee[1]/persName[@key='A002002']">
                <xsl:copy copy-namespaces="no">
                   <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
             </xsl:when>
             <!-- umgekehrt -->
             <xsl:when test="teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/sender[1]/persName[@key='A002002'] and teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/addressee[1]/persName[@key='A002001']">
                <xsl:copy copy-namespaces="no">
                   <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
             </xsl:when>
             <!-- Wenn output true ist, wird ausgegeben -->
             <xsl:when test="@output='true'">
                <xsl:copy copy-namespaces="no">
                   <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
             </xsl:when>
             <!-- Wenn im Absatz gekürzt ist -->
             <xsl:when test="child::anchor[@output='true']">
                <xsl:apply-templates select="anchor[@output='true']"/>
             </xsl:when>
             <!-- Wenn Absätze ausgelassen sind, wird geschaut, ob zwischen zwei abgedruckten Absätzen -->
             <xsl:when test="child::gap[@reason='outOfScope']">
                <xsl:choose>
                   <xsl:when test="count(child::*) = 1">
                      <xsl:choose>
                         <xsl:when test="not(preceding-sibling::*)"/>
                         <xsl:when test="not(following-sibling::*)"/>
                         <xsl:otherwise>
                            <p><missing-paragraph/></p>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:copy copy-namespaces="no">
                         <xsl:apply-templates select="@*|node()"/>
                      </xsl:copy>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:when>
             <xsl:otherwise>
                <!-- jetzt noch die Sonderregeln ob gedruckt oder nicht -->
                <xsl:choose><!-- gedruckt -->
                   <xsl:when test="ancestor::TEI[teiHeader/fileDesc/sourceDesc/listBibl]">
                      <xsl:choose>
                         <!-- Ein Brief Bahrs, in dem Schnitzler erwähnt wird -->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002002'] and descendant::*[contains(@key,'A002001')]">
                               <xsl:copy copy-namespaces="no">
                                  <xsl:apply-templates select="@*|node()"/>
                               </xsl:copy>
                      </xsl:when>
                      <!-- andersrum -->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author[@key='A002001'] and descendant::*[contains(@key,'A002002')]">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                      </xsl:when>
                         <!-- Gedruckte Briefe an Schnitzler in denen kein output ist ganz-->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002001'] and not(ancestor::body//*[@output='true'])">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:when>
                         <!-- Gedruckte Briefe an Bahr in denen kein output ist, ganz-->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002002'] and not(ancestor::body//*[@output='true'])">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:when>
                         <!-- Gedruckte Briefe an Schnitzler -->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002001'] and descendant::*[@key='A002002']">
                                  <xsl:copy copy-namespaces="no">
                                     <xsl:apply-templates select="@*|node()"/>
                                  </xsl:copy>
                         </xsl:when>
                         <!-- Gedruckte Briefe an Bahr -->
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002002'] and descendant::*[@key='A002001']">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:when>
                         <!-- Gedruckte Briefe Dritter an Dritte wenn kein output ist -->
                         <xsl:when test="not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002001']) and not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/addressee/persName[@key='A002002']) and not(ancestor::body//*[@output='true'])">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:when>                         
                         <xsl:otherwise>
                            <!-- Wenn ein gedruckter Text und nicht einer der beiden vorkommt, wird nicht ausgegeben -->
                                  <p><missing-paragraph/></p>
                            
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:when>
                   <!-- Nun unveröffentlichte Briefe, eigentlich immer ausgegeben, es sei denn, Briefe dritter mit output -->
                   <xsl:otherwise>
                      <xsl:choose>
                         <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/correspDesc/sender/persName[@key='A002001' or @key='A002002']">
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:when>
                         <xsl:when test="ancestor::body//*[@output='true'] and not(descendant::*[@output='true'])">
                            <p><missing-paragraph/></p>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:copy copy-namespaces="no">
                               <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
  <!-- BILDER werden immer ausgegeben -->
       <xsl:when test="ancestor::TEI[teiHeader/fileDesc/publicationStmt/idno/@type='HBAS-I']">
          <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
       </xsl:when>
       <xsl:otherwise>
          <xsl:text>\textcolor{red}{KÜRZUNG FEHLER}</xsl:text>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
            
</xsl:stylesheet>




            
        
         
         
         
         
         
       
        
   
