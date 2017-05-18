<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- IdentityTransform -->
    <xsl:template xmlns="http://www.tei-c.org/ns/1.0" match="/ | @* | node() | comment()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template xmlns="http://www.tei-c.org/ns/1.0" match="tei:author[ancestor::tei:text]">
        <xsl:variable name="key" select="substring-after(@ref,'#')"/>
        <xsl:element name="author">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="doc('Personen.xml')//tei:person[@xml:id eq $key]/tei:persName"/>
        </xsl:element> <!-- /author -->
    </xsl:template>
    
</xsl:stylesheet>