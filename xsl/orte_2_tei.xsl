<?xml version="1.0" encoding="UTF-8"?>
<!-- Konvertiert Spreadsheet nach tei:place für tei:listPlace -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/">
        <xsl:apply-templates select="//root"/>
    </xsl:template>
    
    <!-- MUSTER -->
    
    <!-- 
        <place xml:id="id">
            <placeName></placeName>
            <location>
             <address>
                  <street>Straße</street>
                  <settlement>Stadt</settlement>
                  <district>Bezirk</district>
                  <postCode>PLZ</postCode>
                  <country>LAND</country>
               </address>
               <geo></geo>
            </location>  
            <idno type="geonames">Geonames-ID</idno>
            <idno type="GND">GND</idno>
         </place>
     -->
    
    
    <xsl:template match="row">
        <xsl:element name="place">
            <xsl:attribute name="xml:id" select="Nummer"/>
            <xsl:if test="Typ!=''">
                <xsl:attribute name="type" select="lower-case(replace(Typ,' ','_'))"/>
            </xsl:if>
            <xsl:element name="placeName">
                <xsl:choose>
                    <xsl:when test="Name!=''">
                        <xsl:value-of select="Name"/>
                    </xsl:when>
                    <xsl:when test="Name='' and Ort!=''">
                        <xsl:value-of select="Ort"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:if test="Typ!=''">
                <xsl:element name="desc">
                    <xsl:value-of select="Typ"/>
                </xsl:element>
            </xsl:if>
                <xsl:element name="location">
                    <xsl:if test="Ort or Bezirk">
                        <xsl:element name="address">
                    <xsl:if test="Bezirk!=''">
                        <xsl:element name="district">
                            <xsl:value-of select="Bezirk"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="Ort!=''">
                        <xsl:element name="settlement">
                            <xsl:value-of select="Ort"/>
                        </xsl:element>
                    </xsl:if>
                        </xsl:element> <!-- /address -->
                    </xsl:if>
                    <xsl:element name="geo">
                        <xsl:comment>Koordinaten</xsl:comment>
                    </xsl:element>
                </xsl:element> <!-- /location -->
            <xsl:element name="idno">
                <xsl:attribute name="type" select="'genonames'"/>
                <xsl:comment>Geonames-ID</xsl:comment>
            </xsl:element>
            <xsl:element name="idno">
                <xsl:attribute name="type" select="'GND'"/>
                <xsl:comment>GND</xsl:comment>
            </xsl:element>
            <xsl:if test="Notiz">
                <xsl:element name="note">
                    <xsl:value-of select="Notiz"/>
                </xsl:element>
            </xsl:if>
        </xsl:element> <!-- /place -->
    </xsl:template>
    
</xsl:stylesheet>