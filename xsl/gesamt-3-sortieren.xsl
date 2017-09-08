<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
      <start>
         <xsl:copy>
            <xsl:apply-templates select="start/TEI">
               <xsl:sort select="xs:integer(@when)"/>
               <xsl:sort select="xs:integer(@n)"/>
            </xsl:apply-templates>
         </xsl:copy>
      </start>
  </xsl:template> 
 
 
</xsl:stylesheet>
