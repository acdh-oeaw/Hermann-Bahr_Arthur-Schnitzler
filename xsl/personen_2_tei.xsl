<?xml version="1.0" encoding="UTF-8"?>
<!-- Konvertiert Spreadsheet nach tei:person für tei:listPerson -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:template match="/">
    <xsl:apply-templates select="//root"/>
  </xsl:template>
  
  <xsl:template match="row">
    <xsl:element name="person">
      <xsl:attribute name="xml:id" select="Nummer"/>
      <xsl:if test="Nachname!='' or Vorname!='' or Zusatz!=''">
        <xsl:element name="persName">
          <xsl:if test="Nachname!=''">
            <xsl:element name="surname">
              <xsl:value-of select="Nachname"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="Vorname!=''">
            <xsl:element name="forename">
              <xsl:value-of select="Vorname"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="Zusatz!=''">
            <xsl:element name="addName">
              <xsl:value-of select="Zusatz"/>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Geburtsdatum!=''">
        <xsl:element name="birth">
          <xsl:attribute name="when" select="Geburtsdatum"/>
          <xsl:element name="date">
            <xsl:value-of select="Geburtsdatum"/>
          </xsl:element>
          <xsl:element name="placeName">
            <xsl:value-of select="Geburtsort"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Todesdatum!=''">
        <xsl:element name="death">
          <xsl:attribute name="when" select="Todesdatum"/>
          <xsl:element name="date">
            <xsl:value-of select="Todesdatum"/>
          </xsl:element>
          <xsl:element name="placeName">
            <xsl:value-of select="Todesort"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="GND!=''">
        <xsl:element name="idno">
          <xsl:attribute name="type" select="'GND'"/>
          <xsl:value-of select="GND"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Beruf!=''">
        <xsl:element name="occupation">
          <xsl:value-of select="Beruf"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Kommentar!=''">
        <xsl:element name="note">
          <xsl:attribute name="type" select="'editorial'"/>
          <xsl:value-of select="Kommentar"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>