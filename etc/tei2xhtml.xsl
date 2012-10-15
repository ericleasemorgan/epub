<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>

 <xsl:output 
  method='xml'
  omit-xml-declaration='no'
  indent='yes'
  doctype-public='-//W3C//DTD XHTML 1.1//EN' 
  doctype-system='http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' />
  
 <xsl:template match='TEI.2'>
  <html>
  <xsl:attribute name='xmlns'>http://www.w3.org/1999/xhtml</xsl:attribute>
  
   <head>
 
    <!-- title tag -->
    <title> 
     <xsl:value-of select='normalize-space(teiHeader/fileDesc/titleStmt/title)' /> / <xsl:value-of select='normalize-space(teiHeader/fileDesc/titleStmt/author)' />
    </title> 
   
  </head>
   
   <body>
        
    <!-- content -->
    <div class='content'>
    
    <!-- logo -->
    <img src='images/logo.gif' alt='logo' />
     <!-- title -->
     <h1><xsl:value-of select='normalize-space(teiHeader/fileDesc/titleStmt/title)' /></h1>
     
     <!-- do the heavy lifting -->
     <xsl:apply-templates/>   
   
    </div>
    
   </body>
   
  </html>
  
 </xsl:template>
 
 <!-- division #1 (div1) -->
 <xsl:template match="div1">
  <h1><xsl:value-of select='./head' /></h1>
  <xsl:apply-templates />
 </xsl:template>

 <!-- division #2 (div2) -->
 <xsl:template match="div2">
  <h2><xsl:value-of select='./head' /></h2>
  <xsl:apply-templates />
 </xsl:template>

 <!-- division #3 (div3) -->
 <xsl:template match="div3">
  <h3><xsl:value-of select='./head' /></h3>
  <xsl:apply-templates />
 </xsl:template>

 <!-- division #4 (div4) -->
 <xsl:template match="div4">
  <h4><xsl:value-of select='./head' /></h4>
  <xsl:apply-templates />
 </xsl:template>

 <!-- division #5 (div5) -->
 <xsl:template match="div5">
  <h5><xsl:value-of select='./head' /></h5>
  <xsl:apply-templates />
 </xsl:template>

 <!-- paragraph (p) -->
 <xsl:template match="p">
  <xsl:choose>
  <xsl:when test='./@rend = "right"'>
   <p style='text-align:right'><xsl:apply-templates /></p>
  </xsl:when>
  <xsl:when test='./@rend = "center"'>
   <p style='text-align:center'><xsl:apply-templates /></p>
  </xsl:when>
  <xsl:when test='./@rend = "fiction"'>
   <p class='fiction'><xsl:text>&#160;&#160;&#160;&#160;</xsl:text><xsl:apply-templates /></p>
  </xsl:when>
  <xsl:when test='./@rend = "pre"'>
   <pre><xsl:apply-templates /></pre>
  </xsl:when>
  <xsl:otherwise>
   <p><xsl:apply-templates /></p>
  </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- quote (quote) -->
 <xsl:template match="quote">
  <blockquote><xsl:apply-templates /></blockquote>
 </xsl:template>

 <!-- line group (lg) -->
 <xsl:template match="lg">
  <p><xsl:apply-templates /></p>
 </xsl:template>

 <!-- line (l) -->
 <xsl:template match="l">
  <xsl:apply-templates /><br />
 </xsl:template>


<!-- hypertext reference (xref) -->
 <xsl:template match="xref">
 <a><xsl:attribute name='href'><xsl:value-of select='./@url' /></xsl:attribute><xsl:apply-templates /></a>
 </xsl:template>

<!-- hypertext reference (xptr) -->
 <xsl:template match="xptr">
 <a><xsl:attribute name='href'><xsl:value-of select='./@url' /></xsl:attribute><xsl:value-of select='./@url' /></a>
 </xsl:template>
 
<!-- table (table) --> 
<xsl:template match="table">
	<xsl:choose>
		<xsl:when test='./@rend = "left"'>
			<table><xsl:apply-templates /></table>
		</xsl:when>
		<xsl:when test='./@rend = "right"'>
			<table><xsl:apply-templates /></table>
		</xsl:when>
		<xsl:when test='./@rend = "center"'>
			<table><xsl:apply-templates /></table>
		</xsl:when>
		<xsl:otherwise>
			<table><xsl:attribute name='border'>1</xsl:attribute><xsl:apply-templates /></table>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

 <!-- table row (row) -->
<xsl:template match="row">
	<xsl:choose>
		<xsl:when test='./@rend = "left"'>
<tr><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:attribute name='valign'><xsl:text>top</xsl:text></xsl:attribute><xsl:apply-templates /></tr>		</xsl:when>
		<xsl:when test='./@rend = "right"'>
<tr><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:attribute name='valign'><xsl:text>top</xsl:text></xsl:attribute><xsl:apply-templates /></tr>		</xsl:when>
		<xsl:when test='./@rend = "center"'>
<tr><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:attribute name='valign'><xsl:text>top</xsl:text></xsl:attribute><xsl:apply-templates /></tr>		</xsl:when>
		<xsl:when test='./@rend = "justify"'>
<tr><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:attribute name='valign'><xsl:text>top</xsl:text></xsl:attribute><xsl:apply-templates /></tr>		</xsl:when>
		<xsl:otherwise>
<tr><xsl:attribute name='valign'><xsl:text>top</xsl:text></xsl:attribute><xsl:apply-templates /></tr>		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


 <!-- table row (cell) -->
<xsl:template match="cell">
	<xsl:choose>
		<xsl:when test='./@rend = "left"'>
<td><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:apply-templates /></td>		</xsl:when>
		<xsl:when test='./@rend = "right"'>
<td><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:apply-templates /></td>		</xsl:when>
		<xsl:when test='./@rend = "center"'>
<td><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:apply-templates /></td>		</xsl:when>
		<xsl:when test='./@rend = "justify"'>
<td><xsl:attribute name='align'><xsl:value-of select='@rend' /></xsl:attribute><xsl:apply-templates /></td>		</xsl:when>
		<xsl:otherwise>
<td><xsl:apply-templates /></td>		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


 <!-- images (figure) -->
  <xsl:template match="figure">
  <img>
  	<xsl:attribute name='src'><xsl:value-of select='./@url' /></xsl:attribute>
  	<xsl:choose>
  	<xsl:when test='./figDesc'>
		<xsl:attribute name='alt'><xsl:value-of select='normalize-space(./figDesc)' /></xsl:attribute>
	</xsl:when>
  	<xsl:otherwise>
  			<xsl:attribute name='alt'><xsl:value-of select='./@url' /></xsl:attribute>
  	</xsl:otherwise>
  	</xsl:choose>
  	<xsl:choose>
  		<xsl:when test='./@rend = "top"'>
  		<xsl:attribute name='align'><xsl:value-of select='./@rend' /></xsl:attribute>
  		</xsl:when>
 		<xsl:when test='./@rend = "middle"'>
  		<xsl:attribute name='align'><xsl:value-of select='./@rend' /></xsl:attribute>
  		</xsl:when>
 		<xsl:when test='./@rend = "bottom"'>
  		<xsl:attribute name='align'><xsl:value-of select='./@rend' /></xsl:attribute>
  		</xsl:when>
 		<xsl:when test='./@rend = "left"'>
  		<xsl:attribute name='align'><xsl:value-of select='./@rend' /></xsl:attribute>
  		</xsl:when>
 		<xsl:when test='./@rend = "right"'>
  		<xsl:attribute name='align'><xsl:value-of select='./@rend' /></xsl:attribute>
  		</xsl:when>
  		<xsl:otherwise />
  	</xsl:choose>
  </img>
  <xsl:apply-templates/>
 </xsl:template>

<xsl:template match='lb'>
<br /><xsl:apply-templates />
</xsl:template>

<xsl:template match='figDesc'>
<span class='caption'><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match='lg'>
	<xsl:choose>
		<xsl:when test='./@rend="indent"'>
			<div class='lg_indent'>
				<xsl:apply-templates />
			</div>
		</xsl:when>
		<xsl:otherwise>
			<div class='lg'>
				<xsl:apply-templates />
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match='l'>
	<xsl:choose>
		<xsl:when test='./@rend="indent"'>
			<span class='line_indent'>
				<xsl:apply-templates />
			</span> 
		</xsl:when>
		<xsl:otherwise>
			<span class='line'>
				<xsl:apply-templates />
			</span> 
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- find and replace (from XSLT Cookbook by Sal Mangano, pg. 13 -->
<xsl:template name='search-and-replace'>
	<xsl:param name='input'/>
	<xsl:param name='search-string'/>
	<xsl:param name='replace-string'/>
	<xsl:choose>
		<xsl:when test='$search-string and contains($input,$search-string)'>
			<xsl:value-of select='substring-before($input,$search-string)'/>
			<xsl:value-of select='$replace-string'/>
			<xsl:call-template name='search-and-replace'>
				<xsl:with-param name='input' select='substring-after($input,$search-string)'/>
				<xsl:with-param name='search-string' select='$search-string'/>
				<xsl:with-param name='replace-string' select='$replace-string'/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select='$input'/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
 

<!-- lists -->
<!-- cool XPath expressions and logic by bodard gabriel <gabriel.bodard@kcl.ac.uk> -->
<xsl:template match="list[@type='gloss']">
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

<xsl:template match="list[@type='ordered']">
  <ol>
    <xsl:apply-templates/>
  </ol>
</xsl:template>

<xsl:template match="list[@type='bulleted']">
  <ul>
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<xsl:template match="label[parent::list[@type='gloss']]">
  <dt>
    <xsl:apply-templates/>
  </dt>
</xsl:template>

<xsl:template match="item[parent::list[@type='gloss']]">
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="item[parent::list[@type='bulleted']]">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<xsl:template match="item[parent::list[@type='ordered']]">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>


<xsl:template match='persName'>
<span class='persName'><xsl:apply-templates /></span>
</xsl:template>

 <!-- do nothing templates -->

 <!-- teiheader (do nothing) -->
 <xsl:template match="teiHeader" />
 
 <!-- head (head) -->
 <xsl:template match="head" />

</xsl:stylesheet>
