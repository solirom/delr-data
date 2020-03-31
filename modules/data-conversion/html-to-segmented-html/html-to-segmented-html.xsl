<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs html" version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />   
    <xsl:variable name="paragraphs" select="/*//html:p"/>
    <xsl:variable name="delimiter-indexes" as="xs:integer+">
        <xsl:sequence select="0"/>
        <xsl:for-each select="$paragraphs[position() &lt; last()]">
            <xsl:if test="normalize-space(.) = ('&#160;', '')">
                <xsl:sequence select="position()"/>
            </xsl:if>        
        </xsl:for-each>    
        <xsl:choose>
            <xsl:when test="normalize-space($paragraphs[position() = last()]) = ('&#160;', '')" />
            <xsl:otherwise>
                <xsl:sequence select="position()"/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:variable>
    <xsl:variable name="delimiter-indexes-number" select="count($delimiter-indexes)"/>   
    <xsl:template match="/">
        <xsl:for-each select="1 to $delimiter-indexes-number -1">
            <xsl:variable name="i" select="position()"/>
            <xsl:variable name="start" select="$delimiter-indexes[$i] + 1" />
            <xsl:variable name="length" select="$delimiter-indexes[$i + 1] - $start" />
            <xsl:variable name="html-entry" select="subsequence($paragraphs, $start, $length)" />
            <xsl:if test="$html-entry/*">
                <xsl:variable name="uuid" select="1007 + $i"/>
                <xsl:variable name="headword-string" select="analyze-string(substring-before($html-entry/*[1]/string(), ' '), '\d*')"/>
                <xsl:variable name="headword" select="string-join($headword-string/non-match[. != ''])"/>
                <xsl:variable name="homonym-number" select="$headword-string/match[. != '']"/>
                <xsl:result-document href="{concat('html/', $uuid, '.html')}">
                    <article xmlns="http://www.w3.org/1999/xhtml" id="delr-{$uuid}">
                        <xsl:copy-of select="$html-entry" />
                    </article>
                </xsl:result-document>
                <xsl:result-document href="{concat('json/', $uuid, '.json')}">
                    <xsl:text>{</xsl:text>
                    <xsl:text>"l":"</xsl:text><xsl:value-of select="$headword"/><xsl:text>"</xsl:text>
                    <xsl:text>"s":"</xsl:text><xsl:value-of select="concat($headword, $homonym-number)"/><xsl:text>"</xsl:text>
                    <xsl:text>}</xsl:text>
                </xsl:result-document>                
            </xsl:if>            
        </xsl:for-each>        
    </xsl:template>
    
    <!--
  <xsl:for-each-group select="file" group-adjacent="@project">
    
    <xsl:for-each select="current-group()">
      <xsl:value-of select="@name"/>, <xsl:value-of select="@size"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>

    <xsl:text>
</xsl:text>
  </xsl:for-each-group>    
    
    -->

</xsl:stylesheet>
