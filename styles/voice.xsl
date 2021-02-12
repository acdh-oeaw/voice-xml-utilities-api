<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:voice="http://www.univie.ac.at/voice/ns/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cq="http://www.univie.ac.at/voice/corpusquery" version="2.0" exclude-result-prefixes="#all">

<!-- <xsl:import href="common.xsl"/> -->
<!-- <xsl:import href="header.xsl"/> -->
  
<!--<xsl:preserve-space elements="tei:u tei:emph"/>-->

<xsl:param name="uelem">div</xsl:param>
<xsl:param name="upartelem">span</xsl:param>

<!-- common.xsl -->
<xsl:param name="regex"/>
<xsl:param name="tokensParam"/>
<xsl:param name="matchesParam"/>
<xsl:param name="uid_sel" select="()"/>
<!-- /common.xsl -->

<!-- header.xsl -->
<xsl:param name="headerWithoutDefLists">false</xsl:param>
<!-- /header.xsl -->


<xsl:variable name="line_no" as="xs:integer">1</xsl:variable>
<!-- <xsl:param name="uid_sel" select="()"/> -->


<!-- common.xsl -->
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
   
  <xsl:template match="/tei:u//text()">
<!--    <xsl:message>UTTERANCE TEXT()</xsl:message> -->
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



<!-- /common.xsl -->


<!-- header.xsl -->

  <xsl:template match="tei:teiHeader" name="teiHeader">
    <div class="header">
      <xsl:apply-templates/>
      <xsl:call-template name="makeHeaderNotes"/>
    </div>
  </xsl:template>


<xsl:template name="makeHeaderNotes">
    <xsl:if test="//tei:notesStmt/tei:note">
      <div class="notes">
	<h3>Event Description</h3>
	<xsl:for-each select="//tei:notesStmt/tei:note">
	  <div>
                        <xsl:value-of select="upper-case(substring(string(.),1,1))"/>
	    <xsl:value-of select="substring(string(.),2)"/>
	  </div>
	</xsl:for-each>
      </div>
    </xsl:if>
</xsl:template>

<xsl:template match="tei:titleStmt">
  <div class="title">
    <h1>Header:
    <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno"/>
  </h1>
    <xsl:apply-templates/>
  </div>
</xsl:template>


<xsl:template match="tei:titleStmt//tei:title">
  <h2>
            <xsl:value-of select="upper-case(substring(string(.),1,1))"/>
    <xsl:value-of select="substring(string(.),2)"/>
  </h2>
</xsl:template>

<!--

<xsl:template match="tei:title">
  <h2>
    <xsl:apply-templates/>
  </h2>
  <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[substring-before(substring-after(@xml:id,'_'),'_')='tn' and text()]">
    <div>
      <xsl:call-template name="note"/>
    </div>
  </xsl:for-each>
</xsl:template>

-->


<xsl:template match="tei:edition">
  <h3>
            <xsl:apply-templates/>
  </h3>
</xsl:template>


<xsl:template match="tei:recordingStmt">
  <div class="recording_stmt">
    <h3>Recording</h3>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="tei:settingDesc">
  <div class="setting_desc">
    <h3>Setting</h3>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="tei:textClass">
  <xsl:variable name="tc" select="."/>
  <div class="textClass">
    <h3>Text Classification</h3>
  <table class="textClass header">
    <xsl:for-each select="tokenize(normalize-space(tei:catRef[1]/@target),' ')">
      <tr>
                        <th>
                            <xsl:value-of select="id(substring-after(., '#'),$tc)/../tei:catDesc"/>: </th>
	<td>
                            <xsl:value-of select="id(substring-after(.,'#'),$tc)"/>
                        </td>
      </tr>
    </xsl:for-each>
  </table>
  </div>
</xsl:template>

<xsl:template match="tei:setting">
  <table class="setting header">
    <xsl:if test="tei:name[@type='country']">
      <tr>
                    <th>Country-Code: </th>
	<td>
                        <xsl:value-of select="tei:name[@type='country']"/>
                    </td>
      </tr>
    </xsl:if>
    <xsl:if test="tei:name[@type='city']">
      <tr>
                    <th>City: </th>
	<td>
                        <xsl:value-of select="tei:name[@type='city']"/>
                    </td>
      </tr>
    </xsl:if>
    <xsl:if test="tei:locale">
      <tr>
                    <th>Locale: </th>
	<td>
                        <xsl:apply-templates select="tei:locale"/>
                    </td>
      </tr>
    </xsl:if>
    <xsl:if test="tei:activity">
      <tr>
                    <th>Activity: </th>
	<td>
                        <xsl:apply-templates select="tei:activity"/>
                    </td>
      </tr>
    </xsl:if>
  </table>
</xsl:template>

<xsl:template match="tei:settingDesc/tei:activity">
  <div class="setting_part">
  <span class="pair_th">
    <xsl:text>Activity: </xsl:text>
  </span>
  <span class="pair_td">
    <xsl:apply-templates/>
  </span>
  </div>
</xsl:template>

<xsl:template match="tei:settingDesc/tei:locale">
  <div class="setting_part">
  <span class="pair_th">
    <xsl:text>Locale: </xsl:text>
  </span>
  <span class="pair_td">
    <xsl:apply-templates/>
  </span>
  </div>
</xsl:template>

<xsl:template match="tei:settingDesc/tei:name">
  <div class="setting_part">
  <xsl:choose>
                <xsl:when test="@type='country'">
      <span class="pair_th">Country: </span>
      <span class="pair_td">
	<xsl:apply-templates/>
      </span>
    </xsl:when>
    <xsl:when test="@type='city'">
      <span class="pair_th">City: </span>
      <span class="pair_td">
	<xsl:apply-templates/>
      </span>
    </xsl:when>
  </xsl:choose>
  </div>
</xsl:template>


<xsl:template match="tei:recording">
  <div class="recording">
    <table class="recording header">
      <tr>
                    <th>Duration: </th>
	<td>
                        <xsl:call-template name="extract_time">
	    <xsl:with-param name="w3time" select="@dur"/>
	  </xsl:call-template>
	  <xsl:apply-templates/>
	</td>
      </tr>
    </table>
  </div>
</xsl:template>



<xsl:template match="tei:recording/tei:date">
  <tr>
            <th>Date: </th>
    <td>
                <xsl:value-of select="."/>
            </td>
  </tr>
</xsl:template>

<xsl:template match="tei:recording/tei:equipment">
<tr>
            <th>Equipment: </th>
  <td>
                <xsl:value-of select="."/>
            </td>
</tr>
</xsl:template>

<xsl:template match="tei:recording/tei:respStmt[string(tei:resp)='recording']">
  <tr>
            <th>Recorded by:</th>
    <td>
                <xsl:value-of select="tei:name"/>
            </td>
  </tr>
</xsl:template>

<xsl:template match="tei:recording/tei:respStmt[not(string(tei:resp)='recording')]">
  <tr>
            <th>Responsibility: </th>
    <td>
                <xsl:apply-templates/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="tei:recording/tei:respStmt/tei:resp">
  <span class="resp">
    <xsl:apply-templates/>
    <xsl:text>: </xsl:text>
  </span>
</xsl:template>
<xsl:template match="tei:recording/tei:respStmt/tei:name">
  <span class="resp name">
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::tei:name">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
  </span>
</xsl:template>

<xsl:template match="tei:revisionDesc">
  <xsl:variable name="revDesc" select="."/>
  <div class="revision_desc">
    <h3>Creation History</h3>
    <table class="revision header">
	  <xsl:for-each select="tei:change">
		<xsl:sort select="@when" order="descending"/>
		<xsl:sort select="@who" order="ascending"/>
		<xsl:variable name="curCh" select="."/>
		<!-- use only the latest -->
			<xsl:apply-templates select="$curCh"/>			
	  </xsl:for-each>
    </table>
  </div>
</xsl:template>

<xsl:template match="tei:revisionDesc//tei:change">
  <xsl:choose>
            <xsl:when test="string(.)='finalized for publication'"/>
	<xsl:otherwise>
                <tr>
                    <th>
                        <xsl:value-of select="string(.)"/>: </th>
		<td>
                        <xsl:value-of select="@who"/>
                    </td>
	  </tr>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:respStmt"/>
<xsl:template match="tei:publicationStmt"/>
<xsl:template match="tei:principal"/>
<xsl:template match="tei:funder"/>
<xsl:template match="tei:encodingDesc"/>
<xsl:template match="tei:idno"/>
<xsl:template match="tei:notesStmt"/>
<xsl:template match="tei:scriptStmt"/>

<xsl:template match="tei:particDesc">
<div>
            <xsl:apply-templates/>
</div>
</xsl:template>


<xsl:template match="tei:relationGrp">
  <table class="relationgrp header">
    <xsl:apply-templates/>
  </table>
</xsl:template>

<xsl:template match="tei:relationGrp/tei:relation">
  <tr>
            <xsl:choose>
                <xsl:when test="@type='acquaintedness'">
	<th>Acquaintedness: </th>
      </xsl:when>
      <xsl:when test="@type='power'">
	<th>Power relations: </th>
      </xsl:when>
      <xsl:otherwise>
                    <th>
                        <xsl:value-of select="@type"/>: </th>
      </xsl:otherwise>
    </xsl:choose>
    <td>
                <xsl:choose>
                    <xsl:when test="ends-with(@name, '_unknown')">
		<xsl:text>unknown</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
                        <xsl:value-of select="translate(@name, '_', ' ')"/>
	  </xsl:otherwise>
	  </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template name="person_table_width">
  <xsl:variable name="n" as="element()+" select="//tei:listPerson[@type='identified']/tei:person"/>
  <xsl:variable name="base" as="xs:integer">1</xsl:variable>
  <xsl:variable name="role" as="xs:integer">
    <xsl:choose>
                <xsl:when test="$n/@role">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="occupation" as="xs:integer">
    <xsl:choose>
                <xsl:when test="$n/tei:occupation">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="sex" as="xs:integer">
    <xsl:choose>
                <xsl:when test="$n/tei:sex|$n/@sex">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="age" as="xs:integer">
    <xsl:choose>
                <xsl:when test="$n/@age|$n/tei:age">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="lang" as="xs:integer">
    <xsl:choose>
                <xsl:when test="$n/tei:langKnowledge/tei:langKnown[@level='L1']">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$base + $sex + $age + $lang + $occupation + $role"/>
</xsl:template>

<xsl:template match="tei:listPerson[@type='main']" priority="1">
    <h3>Speaker Information</h3>
    <table class="partic_desc header">
      <xsl:apply-templates/>
    </table>
</xsl:template>

<xsl:template match="tei:listPerson[child::*]">
  <xsl:variable name="tw" as="xs:integer">
    <xsl:call-template name="person_table_width"/>
  </xsl:variable>
    <tr>
            <th colspan="{$tw}" class="list_person_h">
	<xsl:choose>
                    <xsl:when test="@type='groups'"><!-- <xsl:text>Groups</xsl:text> --></xsl:when>
	  <xsl:when test="@type='identified'">
                        <xsl:text>Identified</xsl:text>
                    </xsl:when>
	  <xsl:when test="@type='not_identified'">
                        <xsl:text>Speakers Not Identified</xsl:text>
                    </xsl:when>
	  <xsl:when test="@type='main'">
	    <xsl:text>Speaker Information</xsl:text>
	  </xsl:when>
	  <xsl:when test="@type">
	    <xsl:value-of select="@type"/>
	  </xsl:when>
	  <xsl:otherwise>
                        <xsl:text>Other group</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </th>
    </tr>
    <xsl:choose>
            <xsl:when test="@type='identified'">
	<tr>
                    <th>ID</th>
	  <xsl:if test="tei:person/tei:sex|tei:person/@sex">
	    <th>Sex</th>
	  </xsl:if>
	  <xsl:if test="tei:person/tei:age|tei:person/@age">
	  <th>Age</th>
	  </xsl:if>
	  <xsl:if test="tei:person/tei:langKnowledge/tei:langKnown[@level='L1']">
	    <th>L1</th>
	  </xsl:if>
	  <xsl:if test="tei:person/@role">
	    <th>Role</th>
	  </xsl:if>
	  <xsl:if test="tei:person/tei:occupation">
	    <th>Occupation</th>
	  </xsl:if>
	</tr>
	<xsl:apply-templates>
                    <xsl:sort select="substring-after(@xml:id,'_S')" data-type="number"/>
	</xsl:apply-templates>
	  </xsl:when>
	  <xsl:when test="@type='not_identified'">
	<tr>
                    <td colspan="{$tw}">
	    <xsl:apply-templates/>
	  </td>
	</tr>
      </xsl:when>
      <xsl:otherwise>
                <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="tei:personGrp">
  <xsl:variable name="tw" as="xs:integer">
    <xsl:call-template name="person_table_width"/>
  </xsl:variable>
  <tr class="person">
    <th colspan="2">
      <xsl:choose>
                    <xsl:when test="@role='speakers'">
	  <xsl:text>Speakers: </xsl:text>
	</xsl:when>
	<xsl:when test="@role='audience'">
	  <xsl:text>Audience: </xsl:text>
	</xsl:when>
	<xsl:when test="@role='interactants'">
	  <xsl:text>Interactants: </xsl:text>
	</xsl:when>
	<xsl:otherwise>
                        <xsl:value-of select="@role"/>
	  <xsl:text>: </xsl:text>
	  <xsl:value-of select="@size"/>
	</xsl:otherwise>
      </xsl:choose>
    </th>
    <td colspan="{$tw - 2}">
      <xsl:choose>
                    <xsl:when test="@size">
	  <xsl:value-of select="@size"/>
	</xsl:when>
	<xsl:otherwise>
                        <xsl:text>unknown</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="tei:listPerson[@type='not_identified']/tei:person">
    <span class="sid" style="display: inline;">
	  <xsl:choose>
                <xsl:when test="@corresp">
		  <xsl:attribute name="title">
			<xsl:text>probably </xsl:text>
			<xsl:value-of select="substring-after(@corresp,'_')"/>
		  </xsl:attribute>
		</xsl:when>
		<xsl:when test="matches(@xml:id, 'SX-f$')">
		  <xsl:attribute name="title">
			<xsl:text>female speaker</xsl:text>
		  </xsl:attribute>
		</xsl:when>
		<xsl:when test="matches(@xml:id, 'SX-m$')">
		  <xsl:attribute name="title">
			<xsl:text>female speaker</xsl:text>
		  </xsl:attribute>
		</xsl:when>
		<xsl:when test="matches(@xml:id, 'SS$')">
		  <xsl:attribute name="title">
			<xsl:text>group of speakers</xsl:text>
		  </xsl:attribute>
		</xsl:when>
	  </xsl:choose>
      <xsl:value-of select="substring-after(@xml:id,'_')"/>
    </span>
    <xsl:if test="self::tei:person[following-sibling::tei:person]">
      <xsl:text>, </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="tei:person">
  <tr>
            <td>
                <span class="sid">
      <xsl:value-of select="substring-after(@xml:id,'_')"/>
    </span>
    </td>
    <xsl:if test="parent::tei:listPerson[@type='identified']">
      <!--	<xsl:apply-templates/> -->
	  <xsl:choose>
                    <xsl:when test="../tei:person/tei:sex">
		  <td class="person_property">
			<xsl:apply-templates select="tei:sex"/>
		  </td>
		</xsl:when>
		<xsl:when test="../tei:person/@sex">
		  <xsl:call-template name="sex">
			<xsl:with-param name="sex" select="@sex"/>
		  </xsl:call-template>
		</xsl:when>
	  </xsl:choose>
	  <xsl:choose>
                    <xsl:when test="../tei:person/tei:age">
		  <td class="person_property">
			<xsl:apply-templates select="tei:age"/>
		  </td>
		</xsl:when>
		<xsl:when test="../tei:person/@age">
		  <xsl:call-template name="age">
			<xsl:with-param name="age" select="@age"/>
		  </xsl:call-template>
		</xsl:when>
	  </xsl:choose>
      <xsl:if test="../tei:person/tei:langKnowledge/tei:langKnown[@level='L1']">
	<xsl:call-template name="l1s">
	  <xsl:with-param name="persnode" select="."/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="../tei:person/@role">
	<td>
                        <xsl:value-of select="@role"/>
	</td>
      </xsl:if>
      <xsl:if test="../tei:person/tei:occupation">
	<xsl:call-template name="occupation">
	  <xsl:with-param name="persnode" select="."/>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
  </tr>
</xsl:template>
<xsl:template name="l1s">
  <xsl:param name="persnode"/>
  <td class="person_property">
<!--    <xsl:text>L1: </xsl:text> -->
<!--      <xsl:text> </xsl:text> -->
      <xsl:for-each select="$persnode/tei:langKnowledge/tei:langKnown[@level='L1']">
	<xsl:value-of select="./@tag"/>
	<xsl:if test="following-sibling::tei:langKnown">
	  <xsl:text>, </xsl:text>
	</xsl:if>
      </xsl:for-each>
  </td>
</xsl:template>

<xsl:template name="sex">
  <xsl:param name="sex"/>
  <td class="person_property">
<!--    <span class="pair_th">
      <xsl:text>Gender: </xsl:text>
    </span> -->
      <xsl:choose>
                <xsl:when test="$sex = 1">
	  <xsl:text>male</xsl:text>
	</xsl:when>
	<xsl:when test="$sex = 2">
	  <xsl:text>female</xsl:text>
	</xsl:when>
	<xsl:otherwise>
                    <xsl:text>unknown</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
  </td>
</xsl:template>

<xsl:template name="age">
  <xsl:param name="age"/>
  <td class="person_property">
<!--    <span class="pair_th">
      <xsl:text>Age: </xsl:text>
    </span> -->
      <xsl:choose>
                <xsl:when test="$age = 1">
	  <xsl:text>17-24</xsl:text>
	</xsl:when>
	<xsl:when test="$age = 2">
	  <xsl:text>25-34</xsl:text>
	</xsl:when>
	<xsl:when test="$age = 3">
	  <xsl:text>35-49</xsl:text>
	</xsl:when>
	<xsl:when test="$age = 4">
	  <xsl:text>50+</xsl:text>
	</xsl:when>
	<xsl:when test="$age = 0">
	  <xsl:text>unknown</xsl:text>
	</xsl:when>
	<xsl:otherwise>
                    <xsl:text>N/A</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
  </td>
</xsl:template>

<xsl:template match="tei:person/tei:persName">
  <td>
            <xsl:text>Name: </xsl:text>
      <xsl:apply-templates/>
  </td>
</xsl:template>

<xsl:template match="tei:person/tei:occupation" name="occupation">
  <xsl:param name="persnode"/>
  <td>
<!--    <span class="pair_th">
      <xsl:text>Profession: </xsl:text>
    </span> -->
      <xsl:apply-templates select="$persnode/tei:occupation/child::node()"/>
      <xsl:if test="not($persnode/tei:occupation/child::node())">
	<xsl:text>&#160;</xsl:text>
      </xsl:if>
  </td>
</xsl:template>

<xsl:template name="note">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:bibl/tei:edition" priority="1">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:bibl/tei:title[@level='m']" priority="1">
  <span class="ref in">
            <xsl:apply-templates/>
        </span>
</xsl:template>

  <xsl:template match="tei:ref">
    <xsl:if test="not(ends-with(preceding-sibling::text()[1], '('))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
  <a>
            <xsl:attribute name="target">_blank</xsl:attribute>
    <xsl:if test="@target">
                <xsl:attribute name="href">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
            </xsl:if>
    <xsl:choose>
                <xsl:when test="*|text()">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@target">
	<xsl:value-of select="@target"/>
      </xsl:when>
      <xsl:otherwise>
                    <xsl:text>LINK</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </a>
    <xsl:if test="not(matches(following-sibling::text()[1], '^[.),;:]'))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
</xsl:template>



<!-- everything corpus-header related -->

<xsl:template match="*" mode="corpusHeader" priority="-0.4">
  <xsl:apply-templates mode="corpusHeader" select="*"/> <!-- ignore text() -->
</xsl:template>


<xsl:template match="/cq:corpusHeader/tei:teiHeader" name="corpusHeader">
  <div class="header" xml:space="preserve">
  <div class="title">
    <h1>
                    <xsl:value-of select="xs:string(.//tei:titleStmt/tei:title)"/>
	</h1>
      <xsl:if test=".//tei:editionStmt/tei:edition">
		<h2>
                        <xsl:value-of select="xs:string(.//tei:editionStmt/tei:edition)"/>
		</h2>
      </xsl:if>
    <xsl:if test=".//tei:principal">
      <h3>Project Director</h3>
      <ul>
                        <li>
                            <xsl:value-of select="xs:string(.//tei:principal)"/>
                        </li>
      </ul>
    </xsl:if>
    <xsl:if test=".//tei:titleStmt/tei:respStmt">
      <xsl:for-each select=".//tei:titleStmt/tei:respStmt/tei:resp">
		<xsl:variable name="resp" select="."/>
		<xsl:variable name="next" select="./following-sibling::tei:resp"/>
		<xsl:variable name="names" select="./following-sibling::tei:name"/>
		<h3>
                            <xsl:value-of select="xs:string($resp)"/>
                        </h3>
		<ul>
                            <xsl:for-each select="./following-sibling::tei:name">
			<li>
                                    <xsl:value-of select="xs:string(.)"/>
                                </li>
		  </xsl:for-each>
		</ul>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test=".//tei:funder">
      <h3>Project Funding</h3>
      <ul>
                        <li>
                            <xsl:value-of select="xs:string(.//tei:funder)"/>
                        </li>
	<xsl:if test=".//tei:note[matches(xs:string(@xml:id), 'funding$')]">
	  <li>
<!--	    <span class="listhead">Additional Funding</span> -->
<!--	    <ul> -->
	      <xsl:for-each select=".//tei:note[matches(xs:string(@xml:id), 'funding$')]">
			<xsl:value-of select="normalize-space(.)"/>
	      </xsl:for-each>
<!--	    </ul> -->
	  </li>
	</xsl:if>
      </ul>
    </xsl:if>
    <xsl:if test=".//tei:extent">
      <h3>Size</h3>
      <p>
                        <xsl:value-of select=".//tei:extent"/>
      </p>
    </xsl:if>
    <xsl:if test=".//tei:sourceDesc">
      <h3>Source Description</h3>
      <xsl:for-each select=".//tei:sourceDesc/tei:*[not(self::tei:scriptStmt|self::tei:listBibl)]">
		<xsl:apply-templates mode="corpusHeader" select="."/>
      </xsl:for-each>
    </xsl:if>
  </div>
  <xsl:if test=".//tei:publicationStmt">
    <h3>Publication Statement</h3>
    <xsl:apply-templates select=".//tei:publicationStmt" mode="corpusHeader"/>
  </xsl:if>

  <xsl:if test=".//tei:projectDesc">
    <h2>
                    <xsl:text>Project</xsl:text>
      <xsl:if test=".//tei:samplingDecl">
		<xsl:text> and Sampling Description</xsl:text>
      </xsl:if>
    </h2>
    <xsl:apply-templates select=".//tei:projectDesc|.//tei:samplingDecl" mode="corpusHeader"/>
  </xsl:if>

  <xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'domain']">
    <h3>Domains: definitions</h3>
	<dl>
                    <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id          = 'domain']"/>
	</dl>
  </xsl:if>

  <xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'spet']">
    <h3>Speech Event Types: definitions</h3>
	<dl>
                    <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id          = 'spet']"/>
	</dl>
  </xsl:if>

  <!-- FIXME is ignored, should be ignored, but why does it work? -->
  <xsl:if test="not(.//tei:classDecl//tei:category[@xml:id = 'domain' or @xml:id = 'spet'])">
    <h2>Taxonomy: definitions</h2>
	<dl>
                    <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl/tei:taxonomy/tei:category"/>
	</dl>
  </xsl:if>

  <xsl:if test=".//tei:editorialDecl/tei:normalization or .//tei:editorialDecl/tei:correction">
    <h2>Transcription</h2>
    <xsl:apply-templates mode="corpusHeader" select=".//tei:editorialDecl/tei:*[self::tei:normalization or self::tei:correction]"/>
  </xsl:if>

  <xsl:if test="$headerWithoutDefLists = 'false'">
  <xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'first_languages' or @xml:id = 'person_roles' or @xml:id = 'person_groups' or @xml:id='power_relations' or @xml:id='acquaintedness']">
    <h2>Speaker Information</h2>
	<xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'first_languages']">
	  <h3>First Languages</h3>
	  <dl>
                            <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id            = 'first_languages']"/>
	  </dl>
	</xsl:if>
	<xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'person_role']">
	  <h3>Person Roles: definitions</h3>
	  <dl>
                            <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id           = 'person_role']"/>
	  </dl>
	</xsl:if>
	<xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'person_groups']">
	  <h3>Person Groups: definitions</h3>
	  <dl>
                            <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id           = 'person_groups']"/>
	  </dl>
	</xsl:if>

	<xsl:if test=".//tei:particDesc/tei:listPerson[@type='unidentified']">
	  <h3> Speakers Not Identified</h3>
	  <dl class="speakers">
	  <xsl:apply-templates select=".//tei:particDesc/tei:listPerson[@type='unidentified']" mode="corpusHeader"/>
	  </dl>
	</xsl:if>

	<xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'power_relations']">
	  <h3>Power Relations: definitions</h3>
	  <dl>
                            <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id           = 'power_relations']"/>
	  </dl>
	</xsl:if>
	<xsl:if test=".//tei:classDecl//tei:category[@xml:id = 'acquaintedness']">
	  <h3>Acquaintedness: definitions</h3>
	  <dl>
                            <xsl:apply-templates mode="corpusHeader" select=".//tei:classDecl//tei:category[@xml:id           = 'acquaintedness']"/>
	  </dl>
	</xsl:if>
  </xsl:if>
  </xsl:if>
  </div>
</xsl:template>


<xsl:template match="tei:person|tei:personGrp" mode="corpusHeader">
  <dt>
            <xsl:choose>
                <xsl:when test="ends-with(@xml:id,'_unknown')">
		<xsl:text>unknown</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
                    <xsl:value-of select="@xml:id"/>: 
	  </xsl:otherwise>
	</xsl:choose>
  </dt>
  <dd>
            <xsl:value-of select=".//tei:p"/>
  </dd>
</xsl:template>

<xsl:template match="tei:bibl" mode="corpusHeader">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:category" mode="corpusHeader">
  <dl>
            <xsl:if test="tei:catDesc">
	<xsl:if test="parent::tei:category">
	  <dt>
                        <xsl:choose>
                            <xsl:when test="ends-with(@xml:id,'_unknown')">
			<xsl:text>unknown</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
                                <xsl:value-of select="replace(@xml:id,'_','&#160;')"/>
		  </xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@n">
		  <xsl:text> (</xsl:text>
		  <xsl:value-of select="@n"/>
		  <xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:text>: </xsl:text>
	  </dt>
	</xsl:if>
	<dd>
                    <xsl:apply-templates select="tei:catDesc" mode="corpusHeader"/>
	</dd>
  </xsl:if>
  <xsl:if test="tei:category">
	<dl>
                    <xsl:for-each select="tei:category">
		<xsl:apply-templates select="." mode="corpusHeader"/>
      </xsl:for-each>
	</dl>
  </xsl:if>
  </dl>
</xsl:template>

<xsl:template match="tei:catDesc" mode="corpusHeader">
  <xsl:apply-templates/>
</xsl:template>

  <xsl:template match="tei:emph" mode="corpusHeader">
    <xsl:if test="not(matches(preceding-sibling::text()[1], '[:(]$'))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
  <em>
            <xsl:apply-templates/>
        </em>
</xsl:template>

  <xsl:template match="tei:ref" mode="corpusHeader">
    <xsl:if test="not(ends-with(preceding-sibling::text()[1], '('))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
  <a>
            <xsl:attribute name="target">_blank</xsl:attribute>
    <xsl:if test="@target">
                <xsl:attribute name="href">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
            </xsl:if>
    <xsl:choose>
                <xsl:when test="*|text()">
	<xsl:apply-templates mode="corpusHeader"/>
      </xsl:when>
      <xsl:when test="@target">
	<xsl:value-of select="@target"/>
      </xsl:when>
      <xsl:otherwise>
                    <xsl:text>LINK</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </a>
    <xsl:if test="not(matches(following-sibling::text()[1], '^[.),;:]'))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="tei:p" mode="corpusHeader">
  <xsl:if test="ends-with(preceding-sibling::text()[1], ',')">
    <xsl:text xml:space="preserve"> </xsl:text>
  </xsl:if>
  <p>
            <xsl:apply-templates mode="corpusHeader"/>
        </p>
</xsl:template>

<xsl:template match="tei:p" mode="corpusHeaderPersonDesc">
  <dd>
            <xsl:apply-templates mode="corpusHeaderPersonDesc"/>
        </dd>
</xsl:template>

<xsl:template match="tei:publicationStmt/tei:publisher" mode="corpusHeader">
<!--  <h3>Publisher</h3> -->
  <p>
            <xsl:value-of select="."/>
        </p>
</xsl:template>

<xsl:template match="tei:publicationStmt/tei:address" mode="corpusHeader">
<!--  <h3>Address</h3> -->
  <p>
            <xsl:choose>
                <xsl:when test="./tei:addrLine">
	<xsl:for-each select="./tei:addrLine">
	  <xsl:value-of select="."/>
                        <br/>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
                    <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>


<xsl:template match="tei:list" mode="corpusHeader">
  <xsl:variable name="type">
    <xsl:choose>
                <xsl:when test="@type='numbered'">
	<xsl:text>ol</xsl:text>
      </xsl:when>
      <xsl:otherwise>
                    <xsl:text>ul</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
            <xsl:when test="@rend='p'">
	  <xsl:for-each select="tei:item">
		<p>
                        <xsl:apply-templates mode="corpusHeader"/>
                    </p>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
                <xsl:element name="{$type}">
		<xsl:for-each select="tei:item">
		  <li>
                            <xsl:apply-templates mode="corpusHeader"/>
                        </li>
		</xsl:for-each>
	  </xsl:element>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- /header.xsl -->


<xsl:template match="/tei:TEI">
  <!-- we have everything in text -->
  <xsl:apply-templates select=".//tei:titleStmt" mode="titletext"/>
  <xsl:apply-templates select="tei:text"/>
</xsl:template>


<xsl:template match="/tei:person|/tei:personGrp">
  <xsl:if test="./tei:p">
	<p>
                <xsl:apply-templates select="./tei:p"/>
	</p>
  </xsl:if>
  <table>
            <xsl:choose>
                <xsl:when test="tei:age">
		<tr>
                        <td>Age: </td>
		  <td>
                            <xsl:apply-templates select="tei:age"/>
		  </td>
		</tr>
	  </xsl:when>
	  <xsl:when test="@age">
		<tr>
                        <td>Age: </td>
		  <xsl:call-template name="age">
			<xsl:with-param name="age" select="@age"/>
		  </xsl:call-template>
		</tr>
	  </xsl:when>
	</xsl:choose>
  <xsl:choose>
                <xsl:when test="tei:sex">
	  <tr>
                        <td>Sex: </td>
		<td class="person_property">
		  <xsl:apply-templates select="tei:sex"/>
		</td>
	  </tr>
	</xsl:when>
	<xsl:when test="@sex">
	  <tr>
                        <td>Sex: </td>
		<xsl:call-template name="sex">
		  <xsl:with-param name="sex" select="@sex">
		  </xsl:with-param>
		</xsl:call-template>
	  </tr>
	</xsl:when>
  </xsl:choose>
  <xsl:if test="tei:langKnowledge/tei:langKnown[@level='L1']">
    <tr>
                    <td>L1: </td>
      <xsl:call-template name="l1s">
	<xsl:with-param name="persnode" select="."/>
      </xsl:call-template>
    </tr>
  </xsl:if>
  <xsl:if test="@role">
    <tr>
                    <td>Role: </td>
      <td>
                        <xsl:value-of select="@role"/>
                    </td>
    </tr>
  </xsl:if>
  <xsl:if test="@corresp|@xml:id">
	<tr>
                    <td>ID: </td>
	  <td>
                        <xsl:choose>
                            <xsl:when test="@corresp">
			<xsl:value-of select="substring-after(@corresp,'#')"/>
		  </xsl:when>
		  <xsl:when test="@xml:id">
			<xsl:value-of select="@xml:id"/>
		  </xsl:when>
		</xsl:choose>
	  </td>
	</tr>
  </xsl:if>
  </table>
</xsl:template>


<xsl:template match="tei:titleStmt" mode="titletext">
  <div class="title">
    <h1>Text:
    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno"/>
	</h1>
	<h2>
                <xsl:for-each select=".//tei:title">
		<xsl:value-of select="upper-case(substring(string(.),1,1))"/>
		<xsl:value-of select="substring(string(.),2)"/>
	  </xsl:for-each>
	</h2>

<!--  <xsl:apply-templates select=".//tei:title"/> -->
  </div>
</xsl:template>





<xsl:template match="tei:text"><xsl:text xml:space="preserve">
</xsl:text>
<!--  <div class="switches"> -->
<!--    Hide/Show: -->
<!--  </div> -->
  <div class="text">
    <xsl:apply-templates/><xsl:text xml:space="preserve">
</xsl:text>
  </div>
</xsl:template>

<!-- implement sequencial fetch for complete texts -->
<!-- <xsl:template match="/tei:TEI//tei:u" priority="1"> -->
<!--   <div class="u replace" id="{@xml:id}">.</div> -->
<!-- </xsl:template> -->

<xsl:template match="tei:u"><xsl:text xml:space="preserve">
</xsl:text>
<!--  <xsl:message>TEI:U</xsl:message> -->
  <xsl:variable name="uid" select="@xml:id"/>
  <xsl:variable name="line_no">
	<xsl:choose>
                <xsl:when test="/tei:TEI">
		<xsl:value-of select="substring-after(substring-after(@xml:id,'_'),'_')"/>
	  </xsl:when>
	  <xsl:otherwise>
                    <xsl:value-of select="replace(@xml:id, '_u_', ':')"/>
	  </xsl:otherwise>
	</xsl:choose>
  </xsl:variable>
  <xsl:variable name="sid_classes">
    <xsl:text>sid </xsl:text>
    <xsl:if test="not(starts-with($uid,'SX') or starts-with($uid, 'SS'))">
      <xsl:text>jslink </xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="u_classes">
	<xsl:text>u context </xsl:text>
	<xsl:if test="@xml:id = $uid_sel">
	  <xsl:text>selected </xsl:text>
	</xsl:if>
  </xsl:variable>
  <xsl:element name="{$uelem}">
	<xsl:attribute name="class">
                <xsl:value-of select="$u_classes"/>
            </xsl:attribute>
	<xsl:attribute name="id">
                <xsl:value-of select="$uid"/>
	</xsl:attribute>

	<xsl:element name="{$upartelem}">
	  <xsl:attribute name="class">ctx_activator jslink</xsl:attribute>
	  <xsl:text>▾</xsl:text>
	</xsl:element>
	<xsl:element name="{$upartelem}">
	  <xsl:attribute name="class">line_no</xsl:attribute>
<!--	  <xsl:value-of select="$uid_sel"/> -->
	  <xsl:value-of select="$line_no"/>
	</xsl:element>
	<xsl:element name="{$upartelem}">
	  <xsl:attribute name="class">
                    <xsl:value-of select="$sid_classes"/>
                </xsl:attribute>
	  <xsl:attribute name="id">
		<xsl:value-of select="concat('src_', $uid, '_', substring-after(@who,'#'))"/>
	  </xsl:attribute>
	  <xsl:value-of select="substring-after(./@who,'_')"/>
	  <xsl:text>: </xsl:text>
	</xsl:element>
	<xsl:element name="{$upartelem}">
	  <xsl:attribute name="class">utext</xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:element>
  </xsl:element>
</xsl:template>

<!--
<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>
-->

<xsl:template match="tei:supplied[@reason='anonymisation']">
  <span class="anonymisation">
  <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="tei:supplied[@reason='unintelligible']">
  <span class="unintelligible">
  <span class="un_tag">
                <xsl:text>&lt;un&gt;</xsl:text>
            </span>
  <xsl:apply-templates/>
  <xsl:apply-templates select="@voice:ipa"/>
  <span class="un_tag">
                <xsl:text>&lt;/un&gt;</xsl:text>
            </span>
  </span>
</xsl:template>


<xsl:template match="tei:incident">
  <span class="contextual_event">
    <xsl:text>{</xsl:text>
    <xsl:value-of select="normalize-space(@voice:desc)"/>
    <xsl:if test="./@dur">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="substring-before(substring-after(string(./@dur),'PT'),'S')"/>
      <xsl:text>)</xsl:text>
    </xsl:if>

    <xsl:text>}</xsl:text>
  </span>
</xsl:template>



<xsl:template match="tei:anchor[@type='other_continuation']">
  <span class="other_continuation">
    <xsl:if test="preceding::text()">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:text>=</xsl:text>
    <xsl:if test="following::text()">
      <xsl:text> </xsl:text>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="voice:pvc">
  <span class="pvc">
    <span class="pvc_tag">
      <xsl:text> &lt;pvc&gt; </xsl:text>
    </span>
    <xsl:apply-templates select="./text()|./*[not(./self::tei:seg[@type='ipa'])]"/>
    <xsl:if test="@comment">
      <xsl:text> {</xsl:text>
      <xsl:value-of select="@comment"/>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="tei:seg[@type='ipa']"/>
    <xsl:apply-templates select="@voice:ipa"/>
    <span class="pvc_tag">
      <xsl:text> &lt;/pvc&gt; </xsl:text> 
    </span>
  </span>
</xsl:template>

<xsl:template match="voice:to">
  <xsl:variable name="sid" select="substring-after(@who, '_')"/>
  <span class="to_tag">&lt;to <xsl:value-of select="$sid"/>&gt;</span>
  <xsl:apply-templates/>
  <span class="to_tag">&lt;/to <xsl:value-of select="$sid"/>&gt;</span>
</xsl:template>

<xsl:template match="tei:seg[@type='onomatopoeia']">
  <span class="ono">
    <span class="ono_tag">&lt;ono&gt;</span>
    <xsl:apply-templates/>
    <span class="ono_tag">&lt;/ono&gt;</span>
  </span>
</xsl:template>

<xsl:template match="tei:seg[@type='ipa']|@voice:ipa">
  <span class="ipa">
    <span class="ipa_tag">
      <xsl:text> &lt;ipa&gt; </xsl:text>
    </span>
      <xsl:value-of select="."/>
    <span class="ipa_tag">
      <xsl:text> &lt;/ipa&gt; </xsl:text>
    </span>
  </span>
</xsl:template>


<xsl:template match="tei:anchor[@type='marker']">
  <span class="marker">
    <xsl:text>&lt;!</xsl:text>
    <xsl:value-of select="@subtype"/>
    <xsl:text>&gt;</xsl:text>
  </span>
</xsl:template>

<xsl:template name="prematch">
  <xsl:apply-templates/>
</xsl:template>
<xsl:template name="postmatch">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:seg[@type = 'overlap']">
  <xsl:variable name="num">
  <xsl:call-template name="overlap_number">
    <xsl:with-param name="overlap" select="."/>
  </xsl:call-template>
  </xsl:variable>
  <span class="overlap"><!--  onclick="toggleClass('overlap_tag {$num}');"> -->
    <span class="overlap_tag">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="$num"/>
      <xsl:text>&gt;</xsl:text>
    </span>

    <xsl:apply-templates/>

    <span class="overlap_tag {$num}">
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="$num"/>
      <xsl:text>&gt;</xsl:text>
    </span>
  </span>
</xsl:template>

<xsl:template match="tei:unclear">
  <xsl:if test="starts-with((.//text())[1], ' ')">
	<xsl:text> </xsl:text>
  </xsl:if>
  <xsl:text>(</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>)</xsl:text>
  <xsl:if test="ends-with((.//text())[last()], ' ')">
	<xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template name="overlap_number">
  <xsl:param name="overlap"/>
  <xsl:variable name="num">
    <xsl:choose>
                <xsl:when test="$overlap/@n">
	<xsl:value-of select="$overlap/@n"/>
      </xsl:when>
      <xsl:when test="@synch">
	<xsl:value-of select="count(id(substring-after($overlap/@synch,'#'))/preceding::tei:seg[@type='overlap' and not(@synch)]) + 1"/>
<!-- 	<xsl:value-of select="count($overlap/preceding::tei:seg[@type='overlap' and not(@synch)])"/> -->
      </xsl:when>
      <xsl:otherwise>
                    <xsl:value-of select="count($overlap/preceding::tei:seg[@type='overlap' and not(@synch)]) + 1"/>
<!-- 	<xsl:value-of select="count($overlap/preceding::tei:seg[@type='overlap' and not(@synch)]) + 1"/> -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$num"/>
</xsl:template>

<xsl:template match="tei:pause">
  <span class="pause">
            <xsl:text> (</xsl:text>
  <xsl:choose>
                <xsl:when test="./@dur">
      <xsl:value-of select="substring-before(substring-after(string(./@dur),'PT'),'S')"/>
    </xsl:when>
    <xsl:otherwise>
                    <xsl:text>.</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>) </xsl:text>
        </span>
</xsl:template>

<xsl:template match="exist:match" priority="2">
  <span class="voice-match">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- <xsl:template match="tei:shift[@feature='voice' and @new='laugh']"> -->
<!--   <span class="laugh"> -->
<!--     <xsl:text><@></xsl:text> -->
<!--   </span> -->
<!-- </xsl:template> -->


<xsl:template match="tei:shift[not(@new='neutral') and @corresp]">
  <span class="smode">
    <xsl:text>&lt;</xsl:text>
    <xsl:call-template name="get_shift_name">
      <xsl:with-param name="newval" select="@new"/>
    </xsl:call-template>
    <xsl:text>&gt;</xsl:text>
  </span>
</xsl:template>

<xsl:template match="tei:shift[@new='neutral' and @corresp]">
  <span class="smode">
    <xsl:text>&lt;/</xsl:text>
    <xsl:call-template name="get_shift_name">
      <xsl:with-param name="newval">
	<xsl:value-of select="id(substring-after(@corresp,'#'))/@new"/>
      </xsl:with-param>
    </xsl:call-template>
  <xsl:text>&gt;</xsl:text>
  </span>
</xsl:template>

<xsl:template name="get_shift_name">
  <xsl:param name="newval"/>
  <xsl:choose>
            <xsl:when test="$newval='laugh'">
      <xsl:text>@</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='p'">
      <xsl:text>soft</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='l'">
      <xsl:text>slow</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='f'">
      <xsl:text>loud</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='whisp'">
      <xsl:text>whispering</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='sigh'">
      <xsl:text>sighing</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='phone'">
      <xsl:text>on phone</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='reading'">
      <xsl:text>reading</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='laugh'">
      <xsl:text>laugh</xsl:text>
    </xsl:when>
    <xsl:when test="$newval='a'">
      <xsl:text>fast</xsl:text>
    </xsl:when>
    <xsl:otherwise>
                <xsl:value-of select="$newval"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- FIXME change to neutral -->
<xsl:template match="tei:shift[@feature='voice' and @new='normal']">
  <span class="laugh">
    <xsl:text>&lt;/@&gt;</xsl:text>
  </span>
</xsl:template>

<!-- FIXME broken -->
<!-- <xsl:template match="tei:shift[@new='neutral']"> -->
<!--   <xsl:choose> -->
<!--     <xsl:when test="."> -->
<!--     </xsl:when> -->
<!--   </xsl:choose> -->
<!--   <span class="laugh"></<xsl:value-of select="@feature"/>></span> -->
<!-- </xsl:template> -->

  <xsl:template match="tei:emph">
    <xsl:if test="not(ends-with(preceding-sibling::text()[1], '('))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
  <span class="emph">
    <xsl:apply-templates/>
  </span>
    <xsl:if test="exists(following-sibling::text()[1]) and not(matches(following-sibling::text()[1], '^[.),;:]'))">
      <xsl:text xml:space="preserve"> </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="/tei:TEI//text()">
  <xsl:call-template name="textNodeCallback"/>
</xsl:template>

<xsl:template name="textNodeCallback">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="parent::tei:unclear"/>
    <xsl:when test="ancestor::tei:unclear">
	  <xsl:choose>
                    <xsl:when test="(ancestor::tei:unclear[1]//text())[1] is . and (ancestor::tei:unclear[1]//text())[last()] is .">
		  <xsl:value-of select="replace(replace(., '^ +', ''), ' +$', '')"/>
		  <!-- 	  <xsl:value-of select="replace(., ' +$', '')"/> -->
		</xsl:when>
		<xsl:when test="(ancestor::tei:unclear[1]//text())[1] is .">
		  <xsl:value-of select="replace(., '^ +', '')"/>
		</xsl:when>
		<!-- not 100% safe -->
		<xsl:when test="(ancestor::tei:unclear[1]//text())[last()] is .">
		  <xsl:value-of select="replace(., ' +$', '')"/>
		</xsl:when>
		<xsl:otherwise>
                        <xsl:value-of select="."/>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
  <xsl:when test="parent::tei:emph"/>
	<xsl:when test="ancestor::tei:emph">
	  <xsl:value-of select="upper-case(string(.))"/>
	</xsl:when>
    <xsl:when test="parent::tei:seg[@type = ('overlap')]"/>
    <xsl:when test="parent::tei:seg"><xsl:value-of select="."/></xsl:when>
    <xsl:when test="normalize-space(.) = ''"/>
	<xsl:otherwise>
                <xsl:value-of select="."/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>




<xsl:template match="tei:foreign">
  <span class="foreign">
    <xsl:if test="not(@voice:translation)">
      <xsl:attribute name="title" select="'translation not available'"/>      <xsl:attribute name="title" select="@voice:translation"/>
    </xsl:if>
    
    <span class="foreign_tag">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:value-of select="@xml:lang"/>
      <xsl:text>&gt;</xsl:text>
    </span>
    <xsl:apply-templates/>
    <xsl:if test="@voice:translation">
      <xsl:text> </xsl:text>
      <span class="translation">
	<xsl:text>{</xsl:text>
	<xsl:value-of select="@voice:translation"/>
	<xsl:text>}</xsl:text>
      </span>
      <xsl:text> </xsl:text>
    </xsl:if>
    <span class="foreign_tag">
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:value-of select="@xml:lang"/>
      <xsl:text>&gt;</xsl:text>
    </span>
  </span>
</xsl:template>

<xsl:template match="tei:c[@type = 'lengthening']">
<!--  <xsl:text>ː</xsl:text> -->
  <xsl:text>:</xsl:text>
</xsl:template>

<xsl:template match="tei:c[@type = 'intonation']">
  <xsl:choose>
            <xsl:when test="@function='fall'">.</xsl:when>
	<xsl:when test="@function='rise'">?</xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:w[@voice:mode='spelt']">
  <span class="spel_tag">
    <xsl:text>&lt;spel&gt;</xsl:text>
  </span>
  <xsl:apply-templates/>
  <span class="spel_tag">
    <xsl:text>&lt;/spel&gt;</xsl:text>
  </span>
</xsl:template>

<xsl:template match="tei:vocal">
  <span class="vocal">
    <xsl:choose>
                <xsl:when test="@voice:desc = 'laughing'">
	<xsl:text> </xsl:text>
	<xsl:for-each select="1 to @voice:syl">
	  <xsl:text>@</xsl:text>
	</xsl:for-each>
	<xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
                    <xsl:text>&lt;</xsl:text>
	<xsl:value-of select="@voice:desc"/>
	<xsl:text>&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="tei:gap[@reason='not_transcribed']">
  <div class="gap">
    <xsl:text>(gap </xsl:text>
    <xsl:call-template name="extract_time">
      <xsl:with-param name="w3time" select="@dur"/>
    </xsl:call-template>
    <xsl:text>) </xsl:text>
    <xsl:call-template name="gapdesc"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="tei:gap[@reason='not_recorded']">
  <div class="gap">
    <xsl:text>(nrec </xsl:text>
    <xsl:call-template name="extract_time">
      <xsl:with-param name="w3time" select="@dur"/>
    </xsl:call-template>
    <xsl:text>) </xsl:text>
    <xsl:call-template name="gapdesc"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template name="gapdesc">
  <span>
            <xsl:text>{</xsl:text>
    <xsl:value-of select="@voice:desc"/>
    <xsl:text>}</xsl:text>
  </span>
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


</xsl:stylesheet>