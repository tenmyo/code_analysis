<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="Shift_JIS" />

  <xsl:param name="delim" select="'&#x09;'" />
  <xsl:param name="break" select="'&#x0D;&#x0A;'" />
  
  <xsl:template match="/doxygen">
    <xsl:text>#src_id</xsl:text><xsl:value-of select="$delim" />
    <xsl:text>dst_id</xsl:text><xsl:value-of select="$break" />
    <xsl:for-each select="//memberdef[@kind=&quot;function&quot;]/references">
      <xsl:value-of select="../@id" /><xsl:value-of select="$delim" />
      <xsl:value-of select="./@refid" /><xsl:value-of select="$break" />
    </xsl:for-each>
    <xsl:for-each select="//memberdef[@kind=&quot;function&quot;]/referencedby">
      <xsl:value-of select="./@refid" /><xsl:value-of select="$delim" />
      <xsl:value-of select="../@id" /><xsl:value-of select="$break" />
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
