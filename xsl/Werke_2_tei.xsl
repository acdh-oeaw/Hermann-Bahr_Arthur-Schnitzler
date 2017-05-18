<?xml version="1.0" encoding="UTF-8"?>
<!-- Konvertiert Spreadsheet nach tei:person für tei:listPerson -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/">
        <xsl:apply-templates select="//root"/>
    </xsl:template>
    
    <!-- 
    <biblFull xml:id="A020000">
                    <titleStmt>
                        <title>Spaziergang</title>
                        <author ref="#A002001">pull von Autoren</author>
                    </titleStmt>
                    <publicationStmt><p/></publicationStmt>
                    <notesStmt>
                        <note></note>
                    </notesStmt>
                </biblFull>
    
    -->
    
    
    <xsl:template match="row">
        <xsl:element name="biblFull">
            <xsl:attribute name="xml:id" select="Nummer"/>
            <xsl:element name="titleStmt">
                <xsl:element name="title">
                    <xsl:value-of select="Titel"/>
                </xsl:element>
                <xsl:element name="author">
                    <xsl:attribute name="ref" select="concat('#', Autor/text())"/>
                </xsl:element> <!-- /author -->
            </xsl:element> <!-- /titleStmt -->
            <xsl:choose>
                <xsl:when test="(Bibliografie != '') or (Aufführung != '') or (Zyklus != '')">
                    <xsl:element name="publicationStmt">
                        <!-- Bibliographischer Nachweis -->
                        <xsl:if test="Bibliografie !=''">
                            <xsl:element name="ab">
                                <xsl:attribute name="type" select="'Bibliografie'"/>
                                <xsl:value-of select="Bibliografie"/>
                            </xsl:element> <!-- /ab  -->
                        </xsl:if>
                        <!-- Uraufführung -->
                        <xsl:if test="Aufführung !=''">
                            <xsl:element name="ab">
                                <xsl:attribute name="type" select="'Auffuehrung'"/>
                                <xsl:value-of select="Aufführung"/>
                            </xsl:element> <!-- /ab  -->
                        </xsl:if>
                        <!-- Uraufführung -->
                        <xsl:if test="Zyklus !=''">
                            <xsl:element name="ab">
                                <xsl:attribute name="type" select="'Zyklus'"/>
                                <xsl:value-of select="Zyklus"/>
                            </xsl:element> <!-- /ab  -->
                        </xsl:if>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="publicationStmt">
                        <xsl:element name="p"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="Kommentare != ''">
                <xsl:element name="notesStmt">
                    <xsl:element name="note">
                        <xsl:value-of select="Kommentare"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
        </xsl:element> <!-- /biblFull -->
    </xsl:template>
    
</xsl:stylesheet>