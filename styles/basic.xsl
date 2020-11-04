<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:voice="http://www.univie.ac.at/voice/ns/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cq="http://www.univie.ac.at/voice/corpusquery" version="2.0">
    <xsl:template match="tei:u">
        <div class="u">U: <xsl:value-of select="@xml:id"/>
        </div>
    </xsl:template>
</xsl:stylesheet>