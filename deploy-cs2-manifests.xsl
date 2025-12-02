<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:json="http://www.w3.org/2005/xpath-functions" 
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:template match="/">
        <xsl:apply-templates select="collection/manuscript"/>
    </xsl:template>
    
    <xsl:template match="manuscript">
        <xsl:variable name="xml" as="element(json:map)">
            <xsl:apply-templates select="json:map"/>
        </xsl:variable>
        
        <xsl:variable name="id">
            <xsl:value-of select="substring-before(substring-after(json:map/json:string[@key='@id'], 'item:'), '/')"/>
        </xsl:variable>
        
        <xsl:variable name="cs2">
            <xsl:text>iiif-manifests/cs2/m</xsl:text>
            <xsl:value-of select="$id"/>
        </xsl:variable>
        
        <xsl:result-document href="{$cs2}" method="text">
            <xsl:value-of select="xml-to-json($xml, map {'indent': true(), 'escaped': false() })"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="json:string[@key='@id'][following-sibling::json:string[@key='@type']]">
        <json:string key="@id">
            <xsl:text>https://raw.githubusercontent.com/heacu39/vanmanen-lepcha-manuscripts/refs/heads/main/iiif-manifests/cs2/m</xsl:text>
            <xsl:value-of select="substring-before(substring-after(., 'item:'), '/')"/>
        </json:string>
    </xsl:template>
</xsl:stylesheet>



