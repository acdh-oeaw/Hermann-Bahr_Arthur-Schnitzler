<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
  <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
   
    <xsl:template match="TEI[descendant::text[@type='diaryDay']]|TEI[descendant::text[@type='image']]|TEI[descendant::image]">
        <TEI when="{(descendant::date[not(ancestor::kommentar) and ancestor::body]/@when)[1]}"
            n="{(descendant::date[not(ancestor::kommentar) and ancestor::body]/@n)[1]}">
         <xsl:apply-templates select="@*|node()"/>
      </TEI>
  </xsl:template>
  
  <xsl:template match="TEI[descendant::text[@type='manuscript']]|TEI[descendant::text[@type='article']]|TEI[descendant::text[@type='text']]|TEI[descendant::text[@type='note']]">
      <TEI when="{descendant::origDate/@when}" n="{descendant::origDate/@n}">
         <xsl:apply-templates select="@*|node()"/>
      </TEI>
  </xsl:template>
  
  
  <xsl:template match="TEI[descendant::correspDesc/dateSender/date]">
      <TEI when="{descendant::correspDesc/dateSender/date/@when}"
           n="{descendant::correspDesc/dateSender/date/@n}">
         <xsl:apply-templates select="@*|node()"/>
      </TEI>
  </xsl:template>
  
  
</xsl:stylesheet>
