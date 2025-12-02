<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:json="http://www.w3.org/2005/xpath-functions" 
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="text" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="collection/manuscript"/>
    </xsl:template>
    
    <xsl:template match="manuscript">
        <xsl:variable name="xml" as="element(json:map)">
            <xsl:copy-of select="json:map"/>
        </xsl:variable>
        
        <xsl:variable name="file">
            <xsl:text>iiif-manifests/m</xsl:text>
            <xsl:value-of select="substring-before(substring-after(json:map/json:string[@key='@id'], 'item:'), '/')"/>
        </xsl:variable>

        <xsl:result-document href="{$file}" method="text" indent="true">
            <xsl:value-of select="xml-to-json($xml)"/>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>