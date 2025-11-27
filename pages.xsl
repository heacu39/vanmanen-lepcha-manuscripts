<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:json="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="collection/manuscript"/>
    </xsl:template>

    <xsl:template match="manuscript">
        <xsl:variable name="id" select="@id"/>

        <xsl:for-each select=".//json:array[@key = 'canvases']/json:map">
            <xsl:variable name="src">
                <xsl:text>transkribus/</xsl:text>
                <xsl:value-of select="$id"/>
                <xsl:text>/page/0</xsl:text>
                <xsl:value-of select="substring-after(json:string[@key = 'label'], '-')"/>
                <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:variable name="out">
                <xsl:text>pages/</xsl:text>
                <xsl:value-of select="$id"/>
                <xsl:text>/0</xsl:text>
                <xsl:value-of select="substring-after(json:string[@key = 'label'], '-')"/>
                <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:result-document href="{$out}" method="xml" indent="true">
                <xsl:apply-templates select="document($src)/*"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="TextLine">
        <xsl:variable name="words" select="tokenize(TextEquiv/Unicode/normalize-space(), '\s+')"/>
        <TextLine>
            <xsl:apply-templates select="@* | Coords | Baseline"/>
            <xsl:choose>
                <xsl:when test="count($words) = count(Word)">
                    <xsl:for-each select="Word">
                        <xsl:sort data-type="number">
                            <xsl:call-template name="getLeftX">
                                <xsl:with-param name="points" select="Coords/@points"/>
                            </xsl:call-template>
                        </xsl:sort>
                        <xsl:variable name="pos" select="position()"/>
                        <Word>
                            <xsl:copy-of select="@id"/>
                            <xsl:attribute name="custom">
                                <xsl:text>readingOrder {index:</xsl:text>
                                <xsl:value-of select="$pos"/>
                                <xsl:text>; oldindex:</xsl:text>
                                <xsl:value-of select="substring-after(@custom, 'index:')"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="Coords"/>
                            <TextEquiv>
                                <Unicode><xsl:value-of select="normalize-space($words[$pos])"
                                    /></Unicode>
                            </TextEquiv>
                        </Word>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <error data-line-words="{count($words)}" data-boxed-words="{count(Word)}">
                        <xsl:for-each select="$words">
                            <w><xsl:value-of select="."/></w>
                        </xsl:for-each>
                    </error>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="TextEquiv"/>
        </TextLine>s </xsl:template>

    <xsl:template name="getLeftX">
        <xsl:param name="points"/>
        <xsl:variable name="ascx">
            <xsl:for-each select="tokenize($points)">
                <xsl:sort select="number(substring-before(., ','))" data-type="number"/>
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="number(substring-before($ascx, ','))"/>
    </xsl:template>

</xsl:stylesheet>
