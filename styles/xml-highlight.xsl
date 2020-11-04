<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cq="http://www.univie.ac.at/voice/corpusquery" version="1.0" exclude-result-prefixes="cq exist xsl">
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
    <xsl:template match="cq:hit">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="item">
        <div>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@num mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>uneven</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <div class="pos">
                <xsl:value-of select="@num"/>
            </div>
            <div class="item">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
<!--    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template> -->
    <xsl:template match="processing-instruction()">
        <dd>
            <font color="darkred">&lt;?<xsl:value-of select="."/>?&gt;</font>
        </dd>
    </xsl:template>
    <xsl:template match="comment()">
        <xsl:param name="is-top" select="'false'"/>
        <div class="xml-comment">
            &lt;-- <xsl:value-of select="."/> --&gt;
        </div>
    </xsl:template>
    <xsl:template match="@*">
        <span class="xml-attr">
            <span class="xml-attr-name" xml:space="preserve">
                <xsl:text> </xsl:text>
                <xsl:value-of select="name(.)"/>
        </span>
            <xsl:text>="</xsl:text>
            <span class="xml-attr-value">
                <xsl:value-of select="."/>
            </span>
            <xsl:text>"</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="tei:u//exist:match" priority="2">
        <span class="xml-match">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:u//*">
        <xsl:param name="is-top" select="'true'"/>
        <span class="xml-element">
            <span class="xml-element-tag">
                <xsl:text>&lt;</xsl:text>
            </span>
            <span class="xml-element-name">
                <xsl:value-of select="name()"/>
            </span>
            <xsl:call-template name="write-namespace-declarations">
                <xsl:with-param name="is-top" select="$is-top"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="count(node()) &gt; 0">
                    <span class="xml-element-tag">&gt;</span>
                    <xsl:apply-templates select="node() | comment()">
                        <xsl:with-param name="is-top" select="'false'"/>
                    </xsl:apply-templates>
                    <span class="xml-element-tag">&lt;/</span>
                    <span class="xml-element-name">
                        <xsl:value-of select="name()"/>
                    </span>
                    <span class="xml-element-tag">&gt;</span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="xml-element-tag">/&gt;</span>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    <xsl:template match="*">
        <xsl:param name="is-top" select="'true'"/>
        <div class="xml-element">
            <xsl:choose>
                <xsl:when test="self::tei:u">
                    <xsl:attribute name="class">xml-element u</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">xml-element</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <span class="xml-element-tag">
                <xsl:text>&lt;</xsl:text>
            </span>
            <span class="xml-element-name">
                <xsl:value-of select="name()"/>
            </span>
            <xsl:call-template name="write-namespace-declarations">
                <xsl:with-param name="is-top" select="$is-top"/>
            </xsl:call-template>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="count(node()) &gt; 0">
                    <span class="xml-element-tag">&gt;</span>
                    <xsl:choose>
                        <xsl:when test="self::tei:u">
                            <div class="xml-mixed">
                                <xsl:apply-templates select="node() | comment()">
                                    <xsl:with-param name="is-top" select="'false'"/>
                                </xsl:apply-templates>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="node() | comment()">
                                <xsl:with-param name="is-top" select="'false'"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                    <span class="xml-element-tag">&lt;/</span>
                    <span class="xml-element-name">
                        <xsl:value-of select="name()"/>
                    </span>
                    <span class="xml-element-tag">&gt;</span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="xml-element-tag">/&gt;</span>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    
    <!-- Output namespace declarations for the current element. -->
    <xsl:template name="write-namespace-declarations">
        <xsl:param name="is-top" select="'false'"/>
        <xsl:variable name="current" select="."/>
        <xsl:variable name="parent-nss" select="../namespace::*"/>
        <xsl:for-each select="namespace::*">
            <xsl:variable name="ns-prefix" select="name()"/>
            <xsl:variable name="ns-uri" select="string(.)"/>
            <xsl:if test="not(contains( ' xml ', concat(' ', $ns-prefix, ' '))) and ($is-top = 'true' or not($parent-nss[name() = $ns-prefix and string(.) = $ns-uri]))">
                <span class="xml-ns">
                <!-- This namespace node doesn't exist on the parent, at least not with that URI, so we need to add a declaration. -->
                    <xsl:choose>
                        <xsl:when test="$ns-prefix = ''">
                            <xsl:if test="$ns-uri != ''">
                                <span class="xml-attr-name" xml:space="preserve">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="'xmlns'"/>
                            </span>
                                <xsl:text>="</xsl:text>
                                <span class="xml-attr-value">
                                    <xsl:value-of select="$ns-uri"/>
                                    <xsl:text>"</xsl:text>
                                </span>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="xml-attr-name" xml:space="preserve">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="concat('xmlns:', $ns-prefix )"/>
                        </span>
                            <xsl:text>="</xsl:text>
                            <span class="xml-attr-value">
                                <xsl:value-of select="$ns-uri"/>
                                <xsl:text>"</xsl:text>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>