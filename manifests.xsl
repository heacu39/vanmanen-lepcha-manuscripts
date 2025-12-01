<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="ids" select="'L001, L003, L013, L023, L036, L047, L048, L072, L147, L152'"/>
    
    <xsl:template match="/">
        <collection>
            <xsl:for-each select="collection/manuscript[contains($ids, @id)]">
                <manuscript id="{@id}">
                    <xsl:copy-of select="json-to-xml(unparsed-text(@uri))"/>
                </manuscript>
            </xsl:for-each>
        </collection>
    </xsl:template>
    
</xsl:stylesheet>
