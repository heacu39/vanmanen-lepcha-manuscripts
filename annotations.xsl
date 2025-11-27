<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:json="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:output method="text" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="collection/manuscript"/>
    </xsl:template>

    <xsl:template match="manuscript">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="manifest" select="concat('m', substring-before(substring-after(json:map/json:string[@key = '@id'], 'iiif_manifest/item:'), '/'))"/>

        <xsl:for-each select=".//json:array[@key = 'canvases']/json:map">
            <xsl:variable name="canvas" select="json:string[@key = '@id']"/>

            <xsl:variable name="src">
                <xsl:text>pages/</xsl:text>
                <xsl:value-of select="$id"/>
                <xsl:text>/0</xsl:text>
                <xsl:value-of select="substring-after(json:string[@key = 'label'], '-')"/>
                <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:variable name="out">
                <xsl:text>annotations/</xsl:text>
                <xsl:value-of select="$id"/>
                <xsl:text>/0</xsl:text>
                <xsl:value-of select="substring-after(json:string[@key = 'label'], '-')"/>
                <xsl:text>.json</xsl:text>
            </xsl:variable>
            <xsl:apply-templates select="document($src)/*">
                <xsl:with-param name="out" select="$out"/>
                <xsl:with-param name="manifest" select="$manifest"/>
                <xsl:with-param name="canvas" select="$canvas"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="PcGts">
        <xsl:param name="out"/>
        <xsl:param name="manifest"/>
        <xsl:param name="canvas"/>

        <xsl:if test="Page/TextRegion/TextLine">
            <xsl:result-document href="{$out}" method="text" indent="true">
                <xsl:variable name="map" as="element(json:map)">
                    <json:map>
                        <json:string key="manifest">
                            <xsl:value-of select="$manifest"/>
                        </json:string>
                        <json:string key="canvas">
                            <xsl:value-of select="$canvas"/>
                        </json:string>
                        <json:string key="page">
                            <xsl:for-each select="//TextLine">
                                <xsl:value-of select="./TextEquiv/Unicode"/>
                                <xsl:text> &lt;BR&gt; </xsl:text>
                            </xsl:for-each>
                        </json:string>
                        <json:array key="annotations">
                            <xsl:apply-templates select="//TextLine">
                                <xsl:with-param name="manifest" select="$manifest"/>
                                <xsl:with-param name="canvas" select="$canvas"/>
                            </xsl:apply-templates>
                        </json:array>
                    </json:map>
                </xsl:variable>
                <xsl:value-of select="xml-to-json($map)"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TextLine">
        <xsl:param name="manifest"/>
        <xsl:param name="canvas"/>

        <xsl:call-template name="ngrams">
            <xsl:with-param name="manifest" select="$manifest"/>
            <xsl:with-param name="canvas" select="$canvas"/>
            <xsl:with-param name="line" select="position()"/>
            <xsl:with-param name="word" select="Word"/>
            <xsl:with-param name="length" select="count(Word)"/>
            <xsl:with-param name="offset" select="1"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ngrams">
        <xsl:param name="manifest"/>
        <xsl:param name="canvas"/>
        <xsl:param name="line"/>
        <xsl:param name="word"/>
        <xsl:param name="length"/>
        <xsl:param name="offset"/>

        <xsl:choose>
            <xsl:when test="$offset &lt;= count($word) - $length + 1">
                <json:map>
                    <json:string key="manifest">
                        <xsl:value-of select="$manifest"/>
                    </json:string>
                    <json:string key="canvas">
                        <xsl:value-of select="$canvas"/>
                    </json:string>
                    <json:string key="line">
                        <xsl:value-of select="$line"/>
                    </json:string>
                    <xsl:variable name="edge">
                        <xsl:if test="$offset = 1">
                            <xsl:text>left </xsl:text>
                        </xsl:if>
                        <xsl:if test="$offset + $length - 1 = count($word)">
                            <xsl:text>right</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:if test="not($edge = '')">
                        <json:string key="edge">
                            <xsl:value-of select="json:normalize-space($edge)"/>
                        </json:string>
                    </xsl:if>
                    <json:map key="annotation">
                        <json:string key="id">
                            <xsl:value-of select="$canvas"/>
                            <xsl:text>/annotation/r</xsl:text>
                            <xsl:value-of select="$line"/>
                            <xsl:text>o</xsl:text>
                            <xsl:value-of select="$offset"/>
                            <xsl:text>l</xsl:text>
                            <xsl:value-of select="$length"/>
                        </json:string>
                        <json:string key="type">Annotation</json:string>
                        <json:string key="motivation">supplementing</json:string>
                        <json:map key="body">
                            <json:string key="value">
                                <xsl:value-of
                                    select="string-join($word[position() &gt;= $offset and position() &lt; $offset + $length]/TextEquiv/Unicode, '')"
                                />
                            </json:string>
                            <json:string key="type">TextualBody</json:string>
                        </json:map>
                        <json:string key="target">
                            <xsl:value-of select="$canvas"/>
                            <xsl:text>#xywh=</xsl:text>
                            <xsl:call-template name="xywh">
                                <xsl:with-param name="points"
                                    select="string-join($word[position() &gt;= $offset and position() &lt; $offset + $length]/Coords/@points, ' ')"
                                />
                            </xsl:call-template>
                        </json:string>
                    </json:map>
                </json:map>
                <xsl:call-template name="ngrams">
                    <xsl:with-param name="manifest" select="$manifest"/>
                    <xsl:with-param name="canvas" select="$canvas"/>
                    <xsl:with-param name="line" select="$line"/>
                    <xsl:with-param name="word" select="$word"/>
                    <xsl:with-param name="length" select="$length"/>
                    <xsl:with-param name="offset" select="$offset + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$length > 1">
                    <xsl:call-template name="ngrams">
                        <xsl:with-param name="manifest" select="$manifest"/>
                        <xsl:with-param name="canvas" select="$canvas"/>
                        <xsl:with-param name="line" select="$line"/>
                        <xsl:with-param name="word" select="$word"/>
                        <xsl:with-param name="length" select="$length - 1"/>
                        <xsl:with-param name="offset" select="1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="xywh">
        <xsl:param name="points"/>

        <xsl:variable name="ascx">
            <xsl:for-each select="tokenize($points)">
                <xsl:sort select="number(substring-before(., ','))" data-type="number"/>
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="x1" select="number(substring-before($ascx, ','))"/>

        <xsl:variable name="ascy">
            <xsl:for-each select="tokenize($points)">
                <xsl:sort select="number(substring-after(., ','))" data-type="number"/>
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="y1" select="number(substring-after(substring-before($ascy, ' '), ','))"/>

        <xsl:variable name="descx">
            <xsl:for-each select="tokenize($points)">
                <xsl:sort select="number(substring-before(., ','))" data-type="number"
                    order="descending"/>
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="x2" select="number(substring-before($descx, ','))"/>

        <xsl:variable name="descy">
            <xsl:for-each select="tokenize($points)">
                <xsl:sort select="number(substring-after(., ','))" data-type="number"
                    order="descending"/>
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="y2" select="number(substring-after(substring-before($descy, ' '), ','))"/>

        <xsl:value-of select="$x1"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$y1"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$x2 - $x1"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$y2 - $y1"/>
    </xsl:template>

    <xsl:template name="substring-after-last">
        <xsl:param name="string"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($string, $delimiter)">
                <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
