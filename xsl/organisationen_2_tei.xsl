<?xml version="1.0" encoding="UTF-8"?>
<!-- Konvertiert Spreadsheet nach tei:org für tei:listOrg -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/">
        <xsl:apply-templates select="//root"/>
    </xsl:template>
    
    <xsl:template match="row">
        <xsl:element name="org">
            <xsl:attribute name="xml:id" select="Nummer"/>
            <xsl:if test="Typ !=''">
            <xsl:attribute name="type" select="replace(Typ,' ','_')"/>
            </xsl:if>
            <xsl:element name="orgName">
                <xsl:value-of select="Titel"/>
            </xsl:element>
            <xsl:if test="Typ != ''">
                <xsl:element name="desc">
                    <xsl:value-of select="Typ"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="(Ort != '') or (Bezirk != '')">
                <xsl:element name="location">
                    <xsl:element name="address">
                        <xsl:if test="Bezirk != ''">
                            <xsl:element name="district">
                                <xsl:value-of select="Bezirk"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="Ort != ''">
                            <xsl:element name="settlement">
                                <xsl:value-of select="Ort"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:element> <!-- /address -->
                </xsl:element> <!-- /location -->
            </xsl:if>
            <xsl:if test="Kommentare != ''">
                <xsl:element name="note">
                    <xsl:value-of select="Kommentare"/>
                </xsl:element>
            </xsl:if>
        </xsl:element> <!-- /org -->   
    </xsl:template>
    
</xsl:stylesheet>