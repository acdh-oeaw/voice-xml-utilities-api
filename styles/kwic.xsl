<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:voice="http://www.univie.ac.at/voice/ns/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cq="http://www.univie.ac.at/voice/corpusquery" version="2.0">
    <xsl:preserve-space elements="tei:u tei:emph"/>

<!-- <xsl:import href="common/common.xsl"/> -->
    <xsl:param name="regex"/>
    <xsl:param name="tokensParam"/>
    <xsl:param name="matchesParam"/>
    <xsl:param name="uid_sel" select="()"/>
    <xsl:template name="get-boundaries">
        <xsl:param name="matches"/>
        <xsl:param name="tokens"/>
        <xsl:param name="cur" select="1"/>
        <xsl:param name="prestr" select="$tokens[$cur]"/>
        <xsl:param name="matchcnt" select="count($matches)"/>
        <xsl:variable name="prelen" select="string-length($prestr)"/>
<!--	<xsl:message>GET BOUNDARIES</xsl:message> -->
<!--	<xsl:message>cur: <xsl:value-of select="$cur"/></xsl:message> -->
        <cq:boundary>
            <cq:start>
                <xsl:value-of select="$prelen + 1"/>
            </cq:start>
<!--	  <xsl:message>prelen: <xsl:value-of select="$prelen + 1"/></xsl:message> -->
            <cq:stop>
                <xsl:value-of select="$prelen + string-length($matches[$cur])"/>
            </cq:stop>
<!--	  <xsl:message>post '<xsl:value-of select="$matches[$cur]"/>': <xsl:value-of select="$prelen + string-length($matches[$cur])"/></xsl:message> -->
        </cq:boundary>
        <xsl:if test="$cur lt $matchcnt">
            <xsl:call-template name="get-boundaries">
		<!-- FIXME: just pass prelen itself! -->
                <xsl:with-param name="prestr" select="concat($prestr, $matches[$cur], $tokens[$cur + 1])"/>
                <xsl:with-param name="matches" select="$matches"/>
                <xsl:with-param name="tokens" select="$tokens"/>
                <xsl:with-param name="cur" select="$cur + 1"/>
                <xsl:with-param name="matchcnt" select="$matchcnt"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="chunkHighlightTxt">
        <xsl:param name="boundaries"/>
        <xsl:param name="str"/>
        <xsl:param name="offset"/>
        <xsl:param name="cur" select="1"/>
        <xsl:variable name="startoffset" select="$offset"/>
        <xsl:variable name="endoffset" select="($offset + string-length($str)) - 1"/>
        <xsl:variable name="num" select="count($boundaries/cq:boundary)"/>
        <xsl:variable name="curbound" select="$boundaries/cq:boundary[$cur]"/>
	
	<!--	<xsl:message>str: '<xsl:value-of select="$str"/>'</xsl:message> -->
	<!--	<xsl:message>offset: '<xsl:value-of select="$offset"/>'</xsl:message> -->
	<!--	<xsl:message>endoffset: '<xsl:value-of select="$endoffset"/>'</xsl:message> -->
	
	<!-- <xsl:message>CURBOUND <xsl:value-of select="concat(xs:string($curbound/cq:start), ':', xs:string($curbound/cq:stop))"/> OFFSET <xsl:value-of select="concat(xs:string($startoffset), ':', xs:string($endoffset))"/> STR '<xsl:value-of select="$str"/></xsl:message> -->
        <xsl:choose>
            <xsl:when test="(         xs:integer($startoffset) lt xs:integer($curbound/cq:start)         and xs:integer($endoffset) ge xs:integer($curbound/cq:start)       )          or        (         xs:integer($startoffset) le xs:integer($curbound/cq:stop)        and       xs:integer($endoffset) gt xs:integer($curbound/cq:stop)          )">
<!--	  <xsl:variable name="chopstart" select="string-length(substring-before(xs:string(.), $str))"/> -->
<!--	  <xsl:variable name="chopend" select="string-length(substring-after(xs:string(.), $str))"/> -->
<!--	  <xsl:variable name="prematch" select="substring($str,1 ,($curbound/cq:start - $startoffset - $chopstart))"/> -->
                <xsl:variable name="prematch" select="substring($str,1 ,($curbound/cq:start - $startoffset))"/>
                <xsl:value-of select="$prematch"/>
<!--	  <xsl:message>prematch: '<xsl:value-of select="$prematch"/>'</xsl:message> -->
<!--  <xsl:variable name="match" select="substring($str,$curbound/cq:start - $startoffset - $chopstart + 1, ($curbound/cq:stop - $curbound/cq:start - $chopend + $chopstart) + 1)"/> -->
                <xsl:variable name="match" select="substring($str,$curbound/cq:start - $startoffset + 1, ($curbound/cq:stop - $curbound/cq:start ) + 1)"/>
                <span class="voice-match">
                    <xsl:value-of select="$match"/>
<!--		<xsl:message>match: '<xsl:value-of select="$match"/>'</xsl:message> -->
                </span>
<!--	  <xsl:variable name="incoffset" select="($curbound/cq:stop - $curbound/cq:start) + ($curbound/cq:start - $startoffset) + $chopend + $chopstart + 1"/> -->
                <xsl:variable name="incoffset" select="($curbound/cq:stop - $curbound/cq:start) + ($curbound/cq:start - $startoffset) + 1"/>
                <xsl:call-template name="chunkHighlightTxt">
                    <xsl:with-param name="boundaries" select="$boundaries"/>
                    <xsl:with-param name="str" select="substring($str, $incoffset + 1)"/>
                    <xsl:with-param name="offset" select="$startoffset + $incoffset"/>
                    <xsl:with-param name="cur" select="$cur + 1"/>
                </xsl:call-template>
            </xsl:when>

	  <!-- overarching match -->
            <xsl:when test="xs:integer($startoffset) ge xs:integer($curbound/cq:start)        and        xs:integer($endoffset) le xs:integer($curbound/cq:stop)        ">
                <span class="voice-match">
                    <xsl:call-template name="textNodeCallback"/>
                </span>
            </xsl:when>
            <xsl:when test="$cur le $num">
                <xsl:call-template name="chunkHighlightTxt">
                    <xsl:with-param name="boundaries" select="$boundaries"/>
                    <xsl:with-param name="str" select="$str"/>
                    <xsl:with-param name="offset" select="$startoffset"/>
                    <xsl:with-param name="cur" select="$cur + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$cur eq ($num + 1)">
<!--		<xsl:message>postmatch: '<xsl:value-of select="substring($str,1)"/>'</xsl:message> -->
                <xsl:value-of select="substring($str,1)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="textNodeCallback">
        <xsl:param name="node" select="."/>
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="/tei:u//text()">
        <xsl:choose>
            <xsl:when test="$regex">
                <xsl:variable name="curtxt">
                    <xsl:call-template name="textNodeCallback"/>
                </xsl:variable>
                <xsl:variable name="ut" select="xs:string(./ancestor::tei:u)"/>
                <xsl:variable name="pre" select="string-join(preceding::text(),'')"/>
                <xsl:variable name="precnt" select="string-length($pre)"/>
                <xsl:variable name="post" select="string-join(following::text(),'')"/>
                <xsl:variable name="postcnt" select="string-length($post)"/>
                <xsl:variable name="endcnt" select="$precnt + string-length($curtxt)"/>
                <xsl:variable name="tokens" select="tokenize($tokensParam, '__CQ_SPLIT_HERE__')"/>
                <xsl:variable name="tokcnt" select="count($tokens)"/>
<!--		<xsl:message>TOKEN: <xsl:value-of select="$tokens"/></xsl:message> -->
<!--		<xsl:message>TOKCNT: <xsl:value-of select="$tokcnt"/></xsl:message> -->
		
<!--		<xsl:message>HAVE REGEX TESTING NODE '<xsl:value-of select="$curtxt/>' WITH REGEX '<xsl:value-of select="$regex"/>'</xsl:message> -->
<!-- 		<xsl:message>precnt: <xsl:value-of select="$precnt"/></xsl:message> -->
<!--		<xsl:message>postcnt: <xsl:value-of select="$postcnt"/></xsl:message> -->
                <xsl:variable name="matches" select="tokenize($matchesParam, '__CQ_SPLIT_HERE__')"/>
<!--		<xsl:message>MATCHES: <xsl:value-of select="$matches"/></xsl:message> -->
<!--		<xsl:message>MATCHCNT: <xsl:value-of select="count($matches)"/></xsl:message> -->
                <xsl:variable name="boundaries">
                    <xsl:call-template name="get-boundaries">
                        <xsl:with-param name="matches" select="$matches"/>
                        <xsl:with-param name="tokens" select="$tokens"/>
                    </xsl:call-template>
                </xsl:variable>

		  <!-- complete -->
                <xsl:call-template name="chunkHighlightTxt">
                    <xsl:with-param name="boundaries" select="$boundaries"/>
                    <xsl:with-param name="offset" select="$precnt + 1"/>
                    <xsl:with-param name="str" select="$curtxt"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="textNodeCallback"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="extract_time">
        <xsl:param name="w3time" required="yes"/>
        <xsl:variable name="h">
            <xsl:value-of select="substring-before(substring-after($w3time, 'T'),'H')"/>
        </xsl:variable>
        <xsl:variable name="m">
            <xsl:value-of select="substring-before(substring-after(substring-after($w3time, 'T'),'H'),'M')"/>
        </xsl:variable>
        <xsl:variable name="s">
            <xsl:value-of select="substring-before(substring-after(substring-after(substring-after($w3time, 'T'),'H'),'M'),'S')"/>
        </xsl:variable>
        <xsl:value-of select="$h"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$m"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$s"/>
    </xsl:template>


<!-- END <xsl:import href="common/common.xsl"/> -->
    <xsl:param name="range" as="xs:integer">100</xsl:param>
    <xsl:variable name="line_no" as="xs:integer">1</xsl:variable>


<!-- tei:u is the main entry point -->
    <xsl:template match="/tei:u">
        <xsl:choose>
            <xsl:when test="$regex">
                <xsl:variable name="ut" select="xs:string(.)"/>
                <xsl:variable name="tokens" select="tokenize($tokensParam,'__CQ_SPLIT_HERE__')"/>
                <xsl:variable name="tokcnt" select="count($tokens)"/>
                <xsl:variable name="matches" select="tokenize($matchesParam, '__CQ_SPLIT_HERE__')"/>
                <xsl:variable name="boundaries">
                    <xsl:call-template name="get-boundaries">
                        <xsl:with-param name="matches" select="$matches"/>
                        <xsl:with-param name="tokens" select="$tokens"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="1 to (count($matches))">
                    <xsl:variable name="i" select="."/>
                    <xsl:variable name="precomplete">
<!--			<xsl:message> selecting boundary from 1 to <xsl:value-of select="$boundaries/cq:boundary[$i]/cq:start"/></xsl:message> -->
                        <xsl:value-of select="substring($ut, ($boundaries/cq:boundary[$i]/cq:start - $range div 2) + 1, $range div 2 - 1)"/>
<!-- 			<xsl:value-of select="substring($ut, 1, $boundaries/cq:boundary[$i]/cq:start - 1)"/> -->
                    </xsl:variable>
                    <xsl:variable name="postcomplete">
<!--			<xsl:message> selecting boundary from <xsl:value-of select="$boundaries/cq:boundary[$i]/cq:start"/> to end</xsl:message> -->
                        <xsl:value-of select="substring($ut, $boundaries/cq:boundary[$i]/cq:stop + 1, $range div 2 - 1)"/>
                    </xsl:variable>
                    <div class="kwic line">
                        <xsl:choose>
                            <xsl:when test="xs:integer($boundaries/cq:boundary[$i]/cq:start) gt 1 and string-length($precomplete) gt 0">
                                <span class="pre">
                                    <xsl:value-of select="$precomplete"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:comment>prematch</xsl:comment>
                            </xsl:otherwise>
                        </xsl:choose>
                        <span class="voice-match">
                            <xsl:value-of select="$matches[$i]"/>
                        </span>
                        <xsl:choose>
                            <xsl:when test="string-length($postcomplete) gt 0">
                                <span class="post">
                                    <xsl:value-of select="$postcomplete"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:comment>prematch</xsl:comment>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
<!--	  <xsl:message>NO REGEX!</xsl:message> -->
                <xsl:apply-templates mode="findmatch"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="cq:hit">
        <xsl:apply-templates mode="findmatch"/>
    </xsl:template>
    <xsl:template match="tei:TEI|tei:teiHeader">
        <h1>This style is not applicable to corpus <xsl:choose>
                <xsl:when test="self::tei:teiHeader">header</xsl:when>
                <xsl:otherwise>text</xsl:otherwise>
            </xsl:choose>s, please select 'voice'</h1>
    </xsl:template>
    <xsl:template match="text()" mode="findmatch"/>
    <xsl:template match="exist:match" mode="findmatch">
        <div class="kwic line">
            <span class="kwic pre">
                <xsl:comment> </xsl:comment>
                <xsl:variable name="s">
                    <xsl:value-of select="./preceding::text()"/>
                </xsl:variable>
                <xsl:if test="$range div 2 - string-length($s) &gt; 0">
                    <xsl:for-each select="1 to ($range div 2 - string-length($s))">
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:if>
                <xsl:value-of select="substring($s,string-length($s) - $range div 2, $range div 2 + 1)"/>
            </span>
            <span class="kwic match">
                <xsl:comment> </xsl:comment>
                <xsl:apply-templates/>
            </span>
            <span class="kwic post">
                <xsl:comment> </xsl:comment>
                <xsl:variable name="s">
                    <xsl:value-of select="./following::text()"/>
                </xsl:variable>
                <xsl:value-of select="substring($s,1, $range div 2)"/>
            </span>
        </div>
    </xsl:template>
</xsl:stylesheet>