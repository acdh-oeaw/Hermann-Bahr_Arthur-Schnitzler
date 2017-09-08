<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:foo="whatever"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  
  <!-- Diese Datei streicht bei mehreren aufeinander folgenden gekürzten Absätzen diese auf einen Zusammen -->
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
   <xsl:template match="@*|node()">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
   
   <xsl:template match="p[missing-paragraph]">
   <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][missing-paragraph]"/>
      <xsl:when test="count(preceding-sibling::*) = 0"/>
      <xsl:when test="following-sibling::*[not(missing-paragraph)]">
         <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
         </xsl:copy>
      </xsl:when>
      <xsl:otherwise/>
   </xsl:choose>
   </xsl:template>
    
    
</xsl:stylesheet>
