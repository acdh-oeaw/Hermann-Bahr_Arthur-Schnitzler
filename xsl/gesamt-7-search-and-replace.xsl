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
                <search>0. 1</search>
                <replace>0.{\,}1</replace>
            </word>
            <word>
                <search>1. 1</search>
                <replace>1.{\,}1</replace>
            </word>
            <word>
                <search>2. 1</search>
                <replace>2.{\,}1</replace>
            </word>
            <word>
                <search>3. 1</search>
                <replace>3.{\,}1</replace>
            </word>
            <word>
                <search>4. 1</search>
                <replace>4.{\,}1</replace>
            </word>
            <word>
                <search>5. 1</search>
                <replace>5.{\,}1</replace>
            </word>
            <word>
                <search>6. 1</search>
                <replace>6.{\,}1</replace>
            </word>
            <word>
                <search>7. 1</search>
                <replace>7.{\,}1</replace>
            </word>
            <word>
                <search>8. 1</search>
                <replace>8.{\,}1</replace>
            </word>
            <word>
                <search>9. 1</search>
                <replace>9.{\,}1</replace>
            </word>
            <word>
                <search>0. 2</search>
                <replace>0.{\,}2</replace>
            </word>
            <word>
                <search>1. 2</search>
                <replace>1.{\,}2</replace>
            </word>
            <word>
                <search>2. 2</search>
                <replace>2.{\,}2</replace>
            </word>
            <word>
                <search>3. 2</search>
                <replace>3.{\,}2</replace>
            </word>
            <word>
                <search>4. 2</search>
                <replace>4.{\,}2</replace>
            </word>
            <word>
                <search>5. 2</search>
                <replace>5.{\,}2</replace>
            </word>
            <word>
                <search>6. 2</search>
                <replace>6.{\,}2</replace>
            </word>
            <word>
                <search>7. 2</search>
                <replace>7.{\,}2</replace>
            </word>
            <word>
                <search>8. 2</search>
                <replace>8.{\,}2</replace>
            </word>
            <word>
                <search>9. 2</search>
                <replace>9.{\,}2</replace>
            </word>
            <word>
                <search>0. 3</search>
                <replace>0.{\,}3</replace>
            </word>
            <word>
                <search>1. 3</search>
                <replace>1.{\,}3</replace>
            </word>
            <word>
                <search>2. 3</search>
                <replace>2.{\,}3</replace>
            </word>
            <word>
                <search>3. 3</search>
                <replace>3.{\,}3</replace>
            </word>
            <word>
                <search>4. 3</search>
                <replace>4.{\,}3</replace>
            </word>
            <word>
                <search>5. 3</search>
                <replace>5.{\,}3</replace>
            </word>
            <word>
                <search>6. 3</search>
                <replace>6.{\,}3</replace>
            </word>
            <word>
                <search>7. 3</search>
                <replace>7.{\,}3</replace>
            </word>
            <word>
                <search>8. 2</search>
                <replace>8.{\,}3</replace>
            </word>
            <word>
                <search>9. 2</search>
                <replace>9.{\,}3</replace>
            </word>
            <word>
                <search>0. 4</search>
                <replace>0.{\,}4</replace>
            </word>
            <word>
                <search>1. 4</search>
                <replace>1.{\,}4</replace>
            </word>
            <word>
                <search>2. 4</search>
                <replace>2.{\,}4</replace>
            </word>
            <word>
                <search>3. 4</search>
                <replace>3.{\,}4</replace>
            </word>
            <word>
                <search>4. 4</search>
                <replace>4.{\,}4</replace>
            </word>
            <word>
                <search>5. 4</search>
                <replace>5.{\,}4</replace>
            </word>
            <word>
                <search>6. 4</search>
                <replace>6.{\,}4</replace>
            </word>
            <word>
                <search>7. 4</search>
                <replace>7.{\,}4</replace>
            </word>
            <word>
                <search>8. 4</search>
                <replace>8.{\,}4</replace>
            </word>
            <word>
                <search>9. 4</search>
                <replace>9.{\,}4</replace>
            </word>
            <word>
                <search>0. 5</search>
                <replace>0.{\,}5</replace>
            </word>
            <word>
                <search>1. 5</search>
                <replace>1.{\,}5</replace>
            </word>
            <word>
                <search>2. 5</search>
                <replace>2.{\,}5</replace>
            </word>
            <word>
                <search>3. 5</search>
                <replace>3.{\,}5</replace>
            </word>
            <word>
                <search>4. 5</search>
                <replace>4.{\,}5</replace>
            </word>
            <word>
                <search>5. 5</search>
                <replace>5.{\,}5</replace>
            </word>
            <word>
                <search>6. 5</search>
                <replace>6.{\,}5</replace>
            </word>
            <word>
                <search>7. 5</search>
                <replace>7.{\,}5</replace>
            </word>
            <word>
                <search>8. 5</search>
                <replace>8.{\,}5</replace>
            </word>
            <word>
                <search>9. 5</search>
                <replace>9.{\,}5</replace>
            </word>
            <word>
                <search>0. 6</search>
                <replace>0.{\,}6</replace>
            </word>
            <word>
                <search>1. 6</search>
                <replace>1.{\,}6</replace>
            </word>
            <word>
                <search>2. 6</search>
                <replace>2.{\,}6</replace>
            </word>
            <word>
                <search>3. 6</search>
                <replace>3.{\,}6</replace>
            </word>
            <word>
                <search>4. 6</search>
                <replace>4.{\,}6</replace>
            </word>
            <word>
                <search>5. 6</search>
                <replace>5.{\,}6</replace>
            </word>
            <word>
                <search>6. 6</search>
                <replace>6.{\,}6</replace>
            </word>
            <word>
                <search>7. 6</search>
                <replace>7.{\,}6</replace>
            </word>
            <word>
                <search>8. 6</search>
                <replace>8.{\,}6</replace>
            </word>
            <word>
                <search>9. 6</search>
                <replace>9.{\,}6</replace>
            </word>
            <word>
                <search>0. 7</search>
                <replace>0.{\,}7</replace>
            </word>
            <word>
                <search>1. 7</search>
                <replace>1.{\,}7</replace>
            </word>
            <word>
                <search>2. 7</search>
                <replace>2.{\,}7</replace>
            </word>
            <word>
                <search>3. 7</search>
                <replace>3.{\,}7</replace>
            </word>
            <word>
                <search>4. 7</search>
                <replace>4.{\,}7</replace>
            </word>
            <word>
                <search>5. 7</search>
                <replace>5.{\,}7</replace>
            </word>
            <word>
                <search>6. 7</search>
                <replace>6.{\,}7</replace>
            </word>
            <word>
                <search>7. 7</search>
                <replace>7.{\,}7</replace>
            </word>
            <word>
                <search>8. 7</search>
                <replace>8.{\,}7</replace>
            </word>
            <word>
                <search>9. 7</search>
                <replace>9.{\,}7</replace>
            </word>
            <word>
                <search>0. 8</search>
                <replace>0.{\,}8</replace>
            </word>
            <word>
                <search>1. 8</search>
                <replace>1.{\,}8</replace>
            </word>
            <word>
                <search>2. 8</search>
                <replace>2.{\,}8</replace>
            </word>
            <word>
                <search>3. 8</search>
                <replace>3.{\,}8</replace>
            </word>
            <word>
                <search>4. 8</search>
                <replace>4.{\,}8</replace>
            </word>
            <word>
                <search>5. 8</search>
                <replace>5.{\,}8</replace>
            </word>
            <word>
                <search>6. 8</search>
                <replace>6.{\,}8</replace>
            </word>
            <word>
                <search>7. 8</search>
                <replace>7.{\,}8</replace>
            </word>
            <word>
                <search>8. 8</search>
                <replace>8.{\,}8</replace>
            </word>
            <word>
                <search>9. 8</search>
                <replace>9.{\,}8</replace>
            </word>
            <word>
                <search>0. 9</search>
                <replace>0.{\,}9</replace>
            </word>
            <word>
                <search>1. 9</search>
                <replace>1.{\,}9</replace>
            </word>
            <word>
                <search>2. 9</search>
                <replace>2.{\,}9</replace>
            </word>
            <word>
                <search>3. 9</search>
                <replace>3.{\,}9</replace>
            </word>
            <word>
                <search>4. 9</search>
                <replace>4.{\,}9</replace>
            </word>
            <word>
                <search>5. 9</search>
                <replace>5.{\,}9</replace>
            </word>
            <word>
                <search>6. 9</search>
                <replace>6.{\,}9</replace>
            </word>
            <word>
                <search>7. 9</search>
                <replace>7.{\,}9</replace>
            </word>
            <word>
                <search>8. 9</search>
                <replace>8.{\,}9</replace>
            </word>
            <word>
                <search>9. 9</search>
                <replace>9.{\,}9</replace>
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
            <word>
                <search> H. B.</search>
                <replace> H.\,B.</replace>
            </word>
            <word>
                <search> A. S.</search>
                <replace> A.\,S.</replace>
            </word>
            <word>
                <search>. Jh.</search>
                <replace>.\,Jh.</replace>
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