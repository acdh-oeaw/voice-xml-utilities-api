<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:voice="http://www.univie.ac.at/voice/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cq="http://www.univie.ac.at/voice/corpusquery" xmlns:exslt="http://exslt.org/common" version="2.0">
    <xsl:param name="headerWithoutDefLists">false</xsl:param>
    <xsl:template match="tei:teiHeader" name="teiHeader">
        <div class="header">
            <xsl:apply-templates/>
            <xsl:call-template name="makeHeaderNotes"/>
        </div>
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
    </xsl:template>



<!-- everything corpus-header related -->
    <xsl:template match="*" mode="corpusHeader" priority="-0.4">
        <xsl:apply-templates mode="corpusHeader" select="*"/> <!-- ignore text() -->
    </xsl:template>
    <xsl:template match="/cq:corpusHeader/tei:teiHeader" name="corpusHeader">
        <div class="header">
            <div class="title">
                <h1>
                    <xsl:value-of select="xs:string(.//tei:titleStmt/tei:title)"/>
                </h1>
                <xsl:if test=".//tei:editionStmt/tei:edition">
                    <h2>
                        <xsl:value-of select="replace(xs:string(.//tei:editionStmt/tei:edition), 'XML', 'Online')"/>
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
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="tei:ref" mode="corpusHeader">
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
    </xsl:template>
    <xsl:template match="tei:p" mode="corpusHeader">
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
</xsl:stylesheet>