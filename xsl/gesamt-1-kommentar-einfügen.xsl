<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:foo="whatever"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
  <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
 
  <xsl:param name="commentary" select="document('kommentare.xml')"/>
  <xsl:key name="commentary-lookup" match="row" use="KommID"/>
  
  <xsl:param name="textconst" select="document('textkonstitution.xml')"/>
  <xsl:key name="textconst-lookup" match="row" use="textConstID"/>
  
  <xsl:template match="anchor[starts-with(@xml:id,'K')]">
      <xsl:variable name="commentary-entry"
                    select="key('commentary-lookup', @xml:id, $commentary)"/>
    <xsl:variable name="lemmatext" select="normalize-space(string(.))"/>
    <xsl:copy>
      <xsl:copy-of select="@*" />
        <kommentar>
          <zu-kommentieren>
            <xsl:apply-templates/>
          </zu-kommentieren>
          <lemma>
          <xsl:choose>
            <xsl:when test="$commentary-entry[child::Lemma]">
              <xsl:value-of select="$commentary-entry/Lemma/."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="string-length($lemmatext) gt 30 and count(tokenize($lemmatext,' ')) gt 5">
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
                  <xsl:text> … </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext,' ')[last()]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
              
            </xsl:otherwise>
          </xsl:choose>
          </lemma>
          <kommentarinhalt>
            <xsl:choose>
              <xsl:when test="$commentary-entry[2]">
                <xsl:text>\textcolor{red}{\emph{Zwei Kommentare!}}</xsl:text>
              </xsl:when>
              <xsl:when test="(normalize-space($commentary-entry[1]/Kommentartext[1]) = '' and not($commentary-entry[1]/Kommentartext[1][descendant::ptr])) or empty($commentary-entry/Kommentartext/.)">
                  <xsl:text>\textcolor{red}{\emph{Kommentar fehlt}}</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:copy-of select="$commentary-entry/Kommentartext/."/>
              </xsl:otherwise>
            </xsl:choose>            
          </kommentarinhalt>
        </kommentar>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="anchor[starts-with(@xml:id,'T')]">
    <xsl:variable name="textConst-entry"
      select="key('textconst-lookup', @xml:id, $textconst)"/>
    <xsl:variable name="lemmatext" select="normalize-space(string-join(node(),' '))"/>
    <textkonstitution>
      <zu-anmerken>
        <xsl:apply-templates/>
      </zu-anmerken>
      <lemma>
        <xsl:choose>
          <xsl:when test="$textConst-entry[child::Lemma]">
            <xsl:value-of select="$textConst-entry/Lemma/."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="string-length($lemmatext) gt 30 and count(tokenize($lemmatext,' ')) gt 5">
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
                <xsl:text> … </xsl:text>
                <xsl:value-of select="tokenize($lemmatext,' ')[last()]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
           
          </xsl:otherwise>
        </xsl:choose>
      </lemma>
      <textconst-inhalt>
        <xsl:choose>
          <xsl:when test="empty($textConst-entry/textConstText/.)">
            <xsl:text>\textcolor{red}{\emph{TEXTANMERKUNG FEHLT}}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$textConst-entry/textConstText/."/>
          </xsl:otherwise>
        </xsl:choose>            
      </textconst-inhalt>
    </textkonstitution>
  </xsl:template>
  
</xsl:stylesheet>
