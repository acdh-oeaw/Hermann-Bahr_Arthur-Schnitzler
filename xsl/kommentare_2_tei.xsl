<?xml version="1.0" encoding="UTF-8"?>
<!-- Konvertiert Spreadsheet nach tei:note für Kommentar  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:template match="/">
    <xsl:apply-templates select="//root"/>
  </xsl:template>
  
  
  <xsl:template match="row">
    <xsl:element name="note">
      <xsl:attribute name="xml:id" select="KommID"></xsl:attribute>
      <xsl:attribute name="type" select="'editorial'"/>
      <xsl:attribute name="subtype" select="'commentary'"/>
      <xsl:if test="Lemma">
        <xsl:element name="seg">
          <xsl:attribute name="type" select="'lemma'"/>
          <xsl:value-of select="Lemma"/>
        </xsl:element>
      </xsl:if>    
      <xsl:element name="p">
        <xsl:apply-templates select="Kommentartext"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="Kommentartext">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>