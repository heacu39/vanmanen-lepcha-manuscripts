<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:json="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:template match="/">
        <xsl:call-template name="writecollection">
            <xsl:with-param name="coll" select="collection"/>
            <xsl:with-param name="mode" select="'word'"/>
        </xsl:call-template>
        <xsl:call-template name="writecollection">
            <xsl:with-param name="coll" select="collection"/>
            <xsl:with-param name="mode" select="'line'"/>
        </xsl:call-template>

        <xsl:apply-templates select="collection/manuscript"/>
    </xsl:template>

    <xsl:template match="manuscript">
        <xsl:call-template name="writemanifest">
            <xsl:with-param name="ms" select="."/>
            <xsl:with-param name="mode" select="'word'"/>
        </xsl:call-template>
        <xsl:call-template name="writemanifest">
            <xsl:with-param name="ms" select="."/>
            <xsl:with-param name="mode" select="'line'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="writecollection">
        <xsl:param name="coll"/>
        <xsl:param name="mode"/>
        
        <xsl:variable name="xml" as="element(json:map)">
            <json:map>
                <json:string key="@context"
                    >http://iiif.io/api/presentation/2/context.json</json:string>
                <json:string key="@id">
                    <xsl:text>https://raw.githubusercontent.com/heacu39/vanmanen-lepcha-manuscripts/refs/heads/main/iiif-manifests/cs1</xsl:text>
                    <xsl:value-of select="$mode"/>
                    <xsl:text>/collection</xsl:text>
                </json:string>
                <json:string key="@type">sc:Collection</json:string>
                <json:string key="label">Van Manen Lepcha Collection</json:string>
                <json:string key="viewingHint">top</json:string>
                <json:string key="attribution">Leiden University Library</json:string>
                <json:map key="service">
                    <json:string key="@context"
                        >http://iiif.io/api/search/1/context.json</json:string>
                    <json:string key="@id">
                        <xsl:text>https://fleiden-u6old.ondigitalocean.app/cs1</xsl:text>
                        <xsl:value-of select="$mode"/>
                        <xsl:text>/collection</xsl:text>
                    </json:string>
                    <json:string key="profile">http://iiif.io/api/search/1/search</json:string>
                </json:map>
                <json:array key="manifests">
                    <xsl:for-each select="$coll/manuscript">
                        <xsl:variable name="id">
                            <xsl:value-of
                                select="substring-before(substring-after(json:map/json:string[@key = '@id'], 'item:'), '/')"
                            />
                        </xsl:variable>
                        <json:map>
                            <json:string key="@id">
                                <xsl:text>https://raw.githubusercontent.com/heacu39/vanmanen-lepcha-manuscripts/refs/heads/main/iiif-manifests/cs1</xsl:text>
                                <xsl:value-of select="$mode"/>
                                <xsl:text>/m</xsl:text>
                                <xsl:value-of select="$id"/>
                            </json:string>
                            <json:string key="@type">sc:Manifest</json:string>
                            <json:string key="label">
                                <xsl:value-of select="json:map/json:string[@key = 'label']"/>
                            </json:string>
                        </json:map>
                    </xsl:for-each>
                </json:array>
            </json:map>
        </xsl:variable>
        
        <xsl:variable name="path">
            <xsl:text>iiif-manifests/cs1</xsl:text>
            <xsl:value-of select="$mode"/>
            <xsl:text>/collection</xsl:text>
        </xsl:variable>
        
        <xsl:result-document href="{$path}" method="text">
            <xsl:value-of select="
                xml-to-json($xml, map {
                'indent': true(),
                'escaped': false()
                })"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="writemanifest">
        <xsl:param name="ms"/>
        <xsl:param name="mode"/>
        
        <xsl:variable name="id">
            <xsl:value-of
                select="substring-before(substring-after($ms/json:map/json:string[@key = '@id'], 'item:'), '/')"
            />
        </xsl:variable>
        
        <xsl:variable name="xml" as="element(json:map)">
            <xsl:apply-templates select="$ms/json:map">
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:variable name="path">
            <xsl:text>iiif-manifests/cs1</xsl:text>
            <xsl:value-of select="$mode"/>
            <xsl:text>/m</xsl:text>
            <xsl:value-of select="$id"/>
        </xsl:variable>
        
        <xsl:result-document href="{$path}" method="text">
            <xsl:value-of select="
                xml-to-json($xml, map {
                'indent': true(),
                'escaped': false()
                })"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:param name="mode"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@* | node()">
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="json:string[@key = '@id'][following-sibling::json:string[@key = '@type'] = 'sc:Manifest']">
        <xsl:param name="mode"/>
        
        <xsl:variable name="id">
            <xsl:value-of select="substring-before(substring-after(., 'item:'), '/')"/>
        </xsl:variable>

        <json:map key="service">
            <json:string key="@context">http://iiif.io/api/search/1/context.json</json:string>
            <json:string key="@id">
                <xsl:text>https://fleiden-u6old.ondigitalocean.app/cs1</xsl:text>
                <xsl:value-of select="$mode"/>
                <xsl:text>/search/m</xsl:text>
                <xsl:value-of select="$id"/>
            </json:string>
            <json:string key="@profile">http://iiif.io/api/search/1/search</json:string>
        </json:map>

        <json:string key="@id">
            <xsl:text>https://raw.githubusercontent.com/heacu39/vanmanen-lepcha-manuscripts/refs/heads/main/iiif-manifests/cs1</xsl:text>
            <xsl:value-of select="$mode"/>
            <xsl:text>/m</xsl:text>
            <xsl:value-of select="$id"/>
        </json:string>
    </xsl:template>

</xsl:stylesheet>
