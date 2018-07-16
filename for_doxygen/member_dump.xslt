<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="Shift_JIS" />

  <xsl:param name="delim" select="'&#x09;'" />
  <xsl:param name="break" select="'&#x0D;&#x0A;'" />
  
  <xsl:template match="/doxygen">
    <xsl:text>#id</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>kind</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>static</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>name</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>file</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>line</xsl:text><xsl:value-of select="$break" />
    <xsl:for-each select="//memberdef">
      <xsl:value-of select="./@id" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./@kind" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./@static" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./name" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./location/@file" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./location/@line" /><xsl:value-of select="$break" />
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
