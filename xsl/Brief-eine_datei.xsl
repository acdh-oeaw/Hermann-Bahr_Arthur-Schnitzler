<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:param name="file-suffix" as="xs:string" select="'L*.xml'"/>
 
  <xsl:template match="/" name="main">
      <gesamt>
         <xsl:perform-sort select="collection(concat('.?select=', $file-suffix))/*">
            <xsl:sort select="tei:teiHeader/fileDesc/sourceDesc/correspDesc/dateSender/date/xs:integer(@when)"/>
         </xsl:perform-sort>
      </gesamt>
  </xsl:template>
</xsl:stylesheet>
