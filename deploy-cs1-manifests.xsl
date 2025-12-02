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
        
        <xsl:variable name="cs1">
            <xsl:text>iiif-manifests/cs1/m</xsl:text>
            <xsl:value-of select="$id"/>
        </xsl:variable>

        <xsl:result-document href="{$cs1}" method="text">
            <xsl:value-of select="xml-to-json($xml, map {'indent': true(), 'escaped': false() })"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="json:string[@key='@id'][following-sibling::json:string[@key='@type'] = 'sc:Manifest']">
        <xsl:variable name="id">
            <xsl:value-of select="substring-before(substring-after(., 'item:'), '/')"/>
        </xsl:variable>
        
        <json:map key="service">
            <json:string key="@context">http://iiif.io/api/search/1/context.json</json:string>
            <json:string key="@id">
                <xsl:text>https://fleiden-u6old.ondigitalocean.app/cs1/search/m</xsl:text>
                <xsl:value-of select="$id"/>
            </json:string>
            <json:string key="@profile">http://iiif.io/api/search/1/search</json:string>
        </json:map>
        
        <json:string key="@id">
            <xsl:text>https://raw.githubusercontent.com/heacu39/vanmanen-lepcha-manuscripts/refs/heads/main/iiif-manifests/cs1/m</xsl:text>
            <xsl:value-of select="$id"/>
        </json:string>
    </xsl:template>
    
</xsl:stylesheet>



