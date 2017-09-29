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
            <word>
                <search> S. 1</search>
                <replace> S.\,1</replace>
            </word>
            <word>
                <search> S. 2</search>
                <replace> S.\,2</replace>
            </word>
            <word>
                <search> S. 3</search>
                <replace> S.\,3</replace>
            </word>
            <word>
                <search> S. 4</search>
                <replace> S.\,4</replace>
            </word>
            <word>
                <search> S. 5</search>
                <replace> S.\,5</replace>
            </word>
            <word>
                <search> S. 6</search>
                <replace> S.\,6</replace>
            </word>
            <word>
                <search> S. 7</search>
                <replace> S.\,7</replace>
            </word>
            <word>
                <search> S. 8</search>
                <replace> S.\,8</replace>
            </word>
            <word>
                <search> S. 9</search>
                <replace> S.\,9</replace>
            </word>
            <word>
                <search> Jg. 1</search>
                <replace> Jg.\,1</replace>
            </word>
            <word>
                <search> Jg. 2</search>
                <replace> Jg.\,2</replace>
            </word>
            <word>
                <search> Jg. 3</search>
                <replace> Jg.\,3</replace>
            </word>
            <word>
                <search> Jg. 4</search>
                <replace> Jg.\,4</replace>
            </word>
            <word>
                <search> Jg. 5</search>
                <replace> Jg.\,5</replace>
            </word>
            <word>
                <search> Jg. 6</search>
                <replace> Jg.\,6</replace>
            </word>
            <word>
                <search> Jg. 7</search>
                <replace> Jg.\,7</replace>
            </word>
            <word>
                <search> Jg. 8</search>
                <replace> Jg.\,8</replace>
            </word>
            <word>
                <search> Jg. 9</search>
                <replace> Jg.\,9</replace>
            </word>
            <word>
                <search>1 Bl.</search>
                <replace>1\,Bl.</replace>
            </word>
            <word>
                <search>2 Bl.</search>
                <replace>2\,Bl.</replace>
            </word>
            <word>
                <search>3 Bl.</search>
                <replace>3\,Bl.</replace>
            </word>
            <word>
                <search>4 Bl.</search>
                <replace>4\,Bl.</replace>
            </word>
            <word>
                <search>5 Bl.</search>
                <replace>5\,Bl.</replace>
            </word>
            <word>
                <search>6 Bl.</search>
                <replace>6\,Bl.</replace>
            </word>
            <word>
                <search>7 Bl.</search>
                <replace>7\,Bl.</replace>
            </word>
            <word>
                <search>8 Bl.</search>
                <replace>8\,Bl.</replace>
            </word>
            <word>
                <search>9 Bl.</search>
                <replace>9\,Bl.</replace>
            </word>
            <word>
                <search>0 Bl.</search>
                <replace>0\,Bl.</replace>
            </word>
            <word>
                <search> Nr. 1</search>
                <replace> Nr.\,1</replace>
            </word>
            <word>
                <search> Nr. 2</search>
                <replace> Nr.\,2</replace>
            </word>
            <word>
                <search> Nr. 3</search>
                <replace> Nr.\,3</replace>
            </word>
            <word>
                <search> Nr. 4</search>
                <replace> Nr.\,4</replace>
            </word>
            <word>
                <search> Nr. 5</search>
                <replace> Nr.\,5</replace>
            </word>
            <word>
                <search> Nr. 6</search>
                <replace> Nr.\,6</replace>
            </word>
            <word>
                <search> Nr. 7</search>
                <replace> Nr.\,7</replace>
            </word>
            <word>
                <search> Nr. 8</search>
                <replace> Nr.\,8</replace>
            </word>
            <word>
                <search> Nr. 9</search>
                <replace> Nr.\,9</replace>
            </word>
            <word>
                <search>Bd. 1</search>
                <replace>Bd.\,1</replace>
            </word>
            <word>
                <search>Bd. 2</search>
                <replace>Bd.\,2</replace>
            </word>
            <word>
                <search>Bd. 3</search>
                <replace>Bd.\,3</replace>
            </word>
            <word>
                <search>Bd. 4</search>
                <replace>Bd.\,4</replace>
            </word>
            <word>
                <search>Bd. 5</search>
                <replace>Bd.\,5</replace>
            </word>
            <word>
                <search>Bd. 6</search>
                <replace>Bd.\,6</replace>
            </word>
            <word>
                <search>Bd. 7</search>
                <replace>Bd.\,7</replace>
            </word>
            <word>
                <search>Bd. 8</search>
                <replace>Bd.\,8</replace>
            </word>
            <word>
                <search>Bd. 9</search>
                <replace>Bd.\,9</replace>
            </word>
            <word>
                <search> H. 1</search>
                <replace> H.\,1</replace>
            </word>
            <word>
                <search> H. 2</search>
                <replace> H.\,2</replace>
            </word>
            <word>
                <search> H. 3</search>
                <replace> H.\,3</replace>
            </word>
            <word>
                <search> H. 4</search>
                <replace> H.\,4</replace>
            </word>
            <word>
                <search> H. 5</search>
                <replace> H.\,5</replace>
            </word>
            <word>
                <search> H. 6</search>
                <replace> H.\,6</replace>
            </word>
            <word>
                <search> H. 7</search>
                <replace> H.\,7</replace>
            </word>
            <word>
                <search> H. 8</search>
                <replace> H.\,8</replace>
            </word>
            <word>
                <search> H. 9</search>
                <replace> H.\,9</replace>
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