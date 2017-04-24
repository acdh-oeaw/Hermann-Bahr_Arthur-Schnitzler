<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:so="stackoverflow example" exclude-result-prefixes="so">
    <xsl:output indent="no" method="text" />
    <xsl:strip-space elements="*"/>
    <xsl:param name="list">
        <words>
            <word>
                <search> / </search>
                <replace>{\slashislash}</replace>
            </word>
            <word>
                <search>. 1.</search>
                <replace>.{\,}1.</replace>
            </word>
            <word>
                <search>. 10.</search>
                <replace>.{\,}10.</replace>
            </word>
            <word>
                <search>. 11.</search>
                <replace>.{\,}11.</replace>
            </word>
            <word>
                <search>. 12.</search>
                <replace>.{\,}12.</replace>
            </word>
            <word>
                <search>. 2.</search>
                <replace>.{\,}2.</replace>
            </word>
            <word>
                <search>. 3.</search>
                <replace>.{\,}3.</replace>
            </word>
            <word>
                <search>. 4.</search>
                <replace>.{\,}4.</replace>
            </word>
            <word>
                <search>. 5.</search>
                <replace>.{\,}5.</replace>
            </word>
            <word>
                <search>. 6.</search>
                <replace>.{\,}6.</replace>
            </word>
            <word>
                <search>. 7.</search>
                <replace>.{\,}7.</replace>
            </word>
            <word>
                <search>. 8.</search>
                <replace>.{\,}8.</replace>
            </word>
            <word>
                <search>. 9.</search>
                <replace>.{\,}9.</replace>
            </word>
            <word>
                <search>.–</search>
                <replace>{\dotdash}</replace>
            </word>
            <word>
                <search>,–</search>
                <replace>{\commadash}</replace>
            </word>
            <word>
                <search>;–</search>
                <replace>{\semicolondash}</replace>
            </word>
            <word>
                <search>!–</search>
                <replace>{\excdash}</replace>
            </word>
            <!--<word>
        <search>{–</search>
        <replace>bam!</replace>
      </word>-->
        </words>
    </xsl:param>
    
    <xsl:function name="so:escapeRegex">
        <xsl:param name="regex"/>
        <xsl:analyze-string select="$regex" regex="\.|\{{">
            <xsl:matching-substring>
                <xsl:value-of select="concat('\',.)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:template match="@*|*|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:variable name="search" select="so:escapeRegex(concat('(',string-join($list/words/word/search,'|'),')'))"/>
        <xsl:analyze-string select="." regex="{$search}">
            <xsl:matching-substring>
                <xsl:message>"<xsl:value-of select="."/>" matched <xsl:value-of select="$search"/></xsl:message>
                <xsl:value-of select="$list/words/word[search=current()]/replace"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>