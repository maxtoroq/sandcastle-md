<?xml version="1.0" encoding="utf-8"?>
<!--
 Copyright 2014 Max Toro Q.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<stylesheet version="2.0"
   xmlns="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:local="http://maxtoroq.github.io/sandcastle-md"
   exclude-result-prefixes="#all">

   <param name="source-dir" select="resolve-uri('.', static-base-uri())"/>
   <param name="output-dir" select="resolve-uri('markdown/', $source-dir)"/>
   <param name="icons-source-dir" select="resolve-uri('icons/', $source-dir)"/>
   <param name="icons-output-dir" select="resolve-uri('_icons/', $output-dir)"/>
   
   <param name="new-line" select="'&#13;&#10;'"/>
   <param name="default-code-lang" select="'csharp'"/>
   <param name="remove-assembly-version" select="true()"/>
   <param name="rewrite-msdn-domain" select="true()"/>
   
   <variable name="local:line-break" select="concat('  ', $new-line)"/>

   <output method="text"/>

   <template match="text()" mode="#all" priority="-100"/>
   <template match="script" mode="#all"/>

   <template match="/">
      <param name="local:topic" tunnel="yes"/>
      <param name="local:output-uri" select="resolve-uri($local:topic/@local:md-url, $output-dir)" as="xs:anyURI" tunnel="yes"/>
      
      <variable name="code-lang" select="((.//*[local:has-class(., 'OH_CodeSnippetContainerTabActive')])[1]/normalize-space(), $default-code-lang)[1]"/>
      
      <variable name="sanitized">
         <apply-templates mode="local:identity-sanitize">
            <with-param name="local:code-lang" select="$code-lang" tunnel="yes"/>
         </apply-templates>
      </variable>
      
      <apply-templates select="$sanitized" mode="local:sanitized">
         <with-param name="local:input-uri" select="base-uri()" tunnel="yes"/>
         <with-param name="local:output-uri" select="$local:output-uri" tunnel="yes"/>
         <with-param name="local:code-lang" select="$code-lang" tunnel="yes"/>
      </apply-templates>
   </template>

   <template match="@*|node()" mode="local:identity-sanitize">
      <copy>
         <apply-templates select="@*|node()" mode="#current"/>
      </copy>
   </template>

   <template match="*[* and not(self::pre or @xml:space='preserve') and not(text()[normalize-space()])]/text()" mode="local:identity-sanitize">
      <!-- Remove insignificant whitespace -->
   </template>

   <template match="div[not(normalize-space())]" mode="local:identity-sanitize"/>

   <template match="div[@id='enumerationSection']" mode="local:identity-sanitize">
      <!-- Unwrap -->
      <apply-templates mode="#current"/>
   </template>

   <template match="text()[matches(., ' Version:')]" mode="local:identity-sanitize">
      <if test="$remove-assembly-version and preceding-sibling::strong[normalize-space() eq 'Assembly:']">
         <value-of select="replace(., ' Version:.+$', '')"/>
      </if>
   </template>
      
   <template match="/" mode="local:sanitized">

      <variable name="links" as="element()*">
         <apply-templates select="." mode="local:get-links"/>
      </variable>

      <apply-templates mode="local:page">
         <with-param name="local:links" select="$links" tunnel="yes"/>
      </apply-templates>

      <for-each select="$links">
         <value-of select="$new-line"/>
         <value-of select="'[', @index, ']', ': '" separator=""/>
         <value-of select="(@new-href, @href)[1]"/>
         <if test="@title/normalize-space()">
            <text> </text>
            <value-of select="'&quot;', @title, '&quot;'" separator=""/>
         </if>
      </for-each>
   
   </template>

   <template match="/|node()" mode="local:get-links">
      <param name="local:topic" tunnel="yes"/>
      <param name="local:input-uri" tunnel="yes"/>
      <param name="local:output-uri" tunnel="yes"/>
      
      <variable name="links" as="element()*">
         <for-each-group select=".//a[local:valid-link(.)]" group-by="@href">
            <variable name="href" select="current-grouping-key()"/>
            <variable name="ref-topic" select="root($local:topic)//topic[@local:html-url=$href]"/>

            <choose>
               <when test="$ref-topic">
                  <if test="not($ref-topic/@local:unused-topic)">
                     <element name="l" namespace="">
                        <attribute name="href" select="$href"/>
                        <attribute name="new-href" select="local:make-relative-uri($local:output-uri, resolve-uri($ref-topic/@local:md-url, $output-dir))"/>
                     </element>
                  </if>
               </when>
               <otherwise>
                  <element name="l" namespace="">
                     <attribute name="href" select="$href"/>
                     <choose>
                        <when test="$rewrite-msdn-domain and matches($href, '^http://msdn2\.microsoft\.com/')">
                           <attribute name="new-href" select="replace($href, '^http://msdn2', 'http://msdn')"/>
                        </when>
                        <when test="$href eq '#fullInheritance'">
                           <attribute name="new-href" select="'#inheritance-hierarchy-continued'"/>
                        </when>
                     </choose>
                     <attribute name="title" select="@title"/>
                  </element>
               </otherwise>
            </choose>
         </for-each-group>
      </variable>
      
      <variable name="images" as="element()*">
         <variable name="base-uri" select="document-uri(root())"/>
         <for-each-group select=".//img" group-by="@src">
            <variable name="src" select="current-grouping-key()"/>
            <variable name="same-alt" select="count(distinct-values(current-group()/@alt)) eq 1"/>
            <variable name="alt" select="@alt"/>
            <variable name="relative-to-icons-uri" select="local:make-relative-uri($icons-source-dir, resolve-uri($src, $local:input-uri))"/>
            <variable name="is-icon" select="not(contains($relative-to-icons-uri, '/'))"/>
            
            <element name="l" namespace="">
               <attribute name="href" select="$src"/>
               <attribute name="title" select="@title"/>
               <if test="$same-alt 
                  and normalize-space($alt)
                  and not($alt castable as xs:integer)">
                  
                  <attribute name="index" select="$alt"/>
                  <attribute name="alt" select="$alt"/>
               </if>
               <if test="$is-icon">
                  <attribute name="new-href" select="local:make-relative-uri($local:output-uri, resolve-uri($relative-to-icons-uri, $icons-output-dir))"/>
               </if>
            </element>
         </for-each-group>
      </variable>
      
      <for-each select="$links, $images[not(@index)]">
         <copy>
            <copy-of select="@*"/>
            <attribute name="index" select="position()"/>
         </copy>
      </for-each>
      
      <sequence select="$images[@index]"/>
         
   </template>
      
   <template match="span[@id and not(normalize-space()) and following-sibling::*[1][self::script and matches(string(), 'AddLanguageSpecificTextSet\(')]]" mode="local:identity-sanitize">
      <param name="local:code-lang" tunnel="yes"/>
      
      <variable name="script" select="following-sibling::script[1]"/>
      <variable name="string" select="substring-before(substring-after($script, '&quot;'), '&quot;')"/>
      <variable name="params" select="tokenize(substring-after($string, '?'), '\|')"/>
      <variable name="selected-param" select="$params[substring-before(., '=') = (local:code-lang-short($local:code-lang), 'nu')][1]"/>
      <value-of select="substring-after($selected-param, '=')"/>
   </template>
      
   <template match="td[local:has-class(., 'OH_tdTitleColumn')]" mode="local:page">
      <call-template name="local:md-h1"/>
   </template>

   <template match="div[@id='mainBody']" mode="local:page">
      <for-each select="(.//*[local:has-class(., 'OH_CollapsibleAreaRegion')])[1]">
         <apply-templates select="preceding-sibling::node()" mode="local:text"/>

         <for-each-group select="., following-sibling::node()" group-starting-with="*[local:has-class(., 'OH_CollapsibleAreaRegion')]">
            <value-of select="$new-line"/>
            <apply-templates select="." mode="local:region-title"/>
            <apply-templates select="current-group()[position() gt 1]" mode="local:text"/>
         </for-each-group>
      </for-each>
   </template>

   <template match="div[@id='mainBody']/div[local:has-class(., 'summary')]" mode="local:text">
      <next-match/>
      <value-of select="$new-line"/>
   </template>

   <template match="div[local:has-class(., 'OH_regiontitle')]" mode="local:region-title">
      <call-template name="local:md-h2"/>
   </template>

   <template match="div[local:has-class(., 'OH_regiontitle') and normalize-space() eq 'Inheritance Hierarchy' and parent::*[@id='fullInheritance']]" mode="local:region-title">
      <call-template name="local:md-h2">
         <with-param name="content" select="'Inheritance Hierarchy (Continued)'"/>
      </call-template>
   </template>

   <template match="p[normalize-space()]" mode="local:text">
      <if test="preceding-sibling::node()[1][self::text()]">
         <value-of select="$new-line"/>
      </if>
      <value-of select="$new-line"/>
      <apply-templates mode="#current"/>
      <value-of select="$new-line"/>
   </template>

   <template match="p[not(normalize-space())]" mode="local:text">
      <if test="preceding-sibling::*[1][not(self::br or local:is-block-element(.))]">
         <value-of select="$new-line"/>
      </if>
      <value-of select="$new-line"/>
   </template>

   <template match="div[local:has-class(., 'OH_CodeSnippetContainer')]" mode="local:text">
      <param name="local:code-lang" tunnel="yes"/>
      
      <value-of select="$new-line"/>
      <text>```</text>
      <value-of select="local:code-lang-github($local:code-lang)"/>
      <value-of select="$new-line"/>
      <value-of select="(.//*[local:has-class(., 'OH_CodeSnippetContainerCode')])[1]/string()"/>
      <value-of select="$new-line"/>
      <text>```</text>
      <value-of select="$new-line"/>
   </template>
   
   <template match="table" mode="local:text">
      <param name="local:skip-cols" select="
         if ((.//th)[1][local:has-class(., 'ps_iconColumn')]) then 
         (if (every $cell in ..//tr/td[1] satisfies $cell[not(.//* or normalize-space())]) then 1 else 0)
         else 0
      " tunnel="yes"/>
      
      <value-of select="$new-line"/>

      <variable name="normalized-table" as="element()">
         <call-template name="local:table-data-to-md">
            <with-param name="skip-cols" select="$local:skip-cols"/>
         </call-template>
      </variable>
      
      <variable name="head-row" select="$normalized-table/thead/tr[1]"/>
      <variable name="headers" select="$head-row/*"/>
      <variable name="rows" select="$normalized-table/tbody/tr[not(. is $head-row)]"/>

      <variable name="col-widths" as="element()*">
         <for-each select="1 to count($headers)">
            <element name="c" namespace="">
               <attribute name="width">
                  <for-each select="($headers[current()], $rows/*[current()])">
                     <sort select="string-length(normalize-space())" order="descending"/>
                     <if test="position() eq 1">
                        <sequence select="string-length(normalize-space())"/>
                     </if>
                  </for-each>
               </attribute>
            </element>
         </for-each>
      </variable>

      <for-each select="$head-row, $rows">
         <variable name="r" select="."/>
         <variable name="r-pos" select="position()"/>

         <if test="$r-pos gt 1">
            <value-of select="$new-line"/>
         </if>
         
         <for-each select="1 to count($headers)">
            <variable name="i" select="."/>
            <variable name="width" select="$col-widths[$i]/@width" as="xs:integer"/>
            <variable name="text" select="$r/*[$i]/string()"/>
            
            <if test="$i gt 1">
               <text>| </text>
            </if>
            <value-of select="$text"/>
            <value-of select="string-join(for $c in (1 to ($width - string-length($text))) return ' ', '')"/>
            <text> </text>
         </for-each>

         <if test="$r-pos eq 1">
            <value-of select="$new-line"/>

            <for-each select="1 to count($headers)">
               <variable name="i" select="."/>
               <variable name="width" select="$col-widths[$i]/@width" as="xs:integer"/>

               <if test="$i gt 1">
                  <text>| </text>
               </if>
               <value-of select="string-join(for $c in (1 to $width) return '-', '')"/>
               <text> </text>
            </for-each>
         </if>
         
      </for-each>
      
      <value-of select="$new-line"/>
   
   </template>

   <template match="table//font[@color]" mode="local:text">
      <!-- Obsolete warning -->
      <next-match/>
      <text> </text>
   </template>
      
   <template match="dl" mode="local:text">
      <for-each-group select="*" group-starting-with="dt">
         <for-each select="current-group()[1]">
            <call-template name="local:md-h5"/>
         </for-each>
         <apply-templates select="current-group()[position() gt 1]" mode="local:text"/>
         <value-of select="$new-line"/>
      </for-each-group>
   </template>
   
   <template match="div[local:has-class(., 'seeAlsoStyle')]" mode="local:text">
      
      <variable name="result" as="item()*">
         <apply-templates mode="#current"/>
      </variable>
      
      <sequence select="$result"/>

      <if test="$result">
         <value-of select="$local:line-break"/>
      </if>
   
   </template>

   <template match="a[local:valid-link(.)]" mode="local:text">
      <param name="local:links" tunnel="yes"/>
      
      <variable name="index" select="$local:links[@href=current()/@href]/@index"/>

      <if test="$index">
         <text>[</text>
         <next-match/>
         <text>][</text>
         <value-of select="$index"/>
         <text>]</text>
      </if>
   </template>

   <template match="a[not(local:valid-link(.))]" mode="local:text"/>

   <template match="img[@alt/normalize-space()]" mode="local:text">
      <param name="local:links" tunnel="yes"/>
      
      <variable name="links" select="$local:links[@href = current()/@src]"/>
      <variable name="index" select="($links[@alt = current()/@alt], $links[not(@alt)])[1]/@index"/>

      <if test="$index">
         <text>![</text>
         <value-of select="$index"/>
         <text>]</text>
      </if>
   </template>
      
   <template match="img[not(@alt/normalize-space())]" mode="local:text">
      <param name="local:links" tunnel="yes"/>
      
      <variable name="index" select="$local:links[@href = current()/@src and not(@alt)]/@index"/>

      <if test="$index">
         <text>![][</text>
         <value-of select="$index"/>
         <text>]</text>
      </if>
   </template>
   
   <template match="span[local:has-class(., 'selflink')]" mode="local:text">
      <value-of select="'**', normalize-space(), '**'" separator=""/>
   </template>

   <template match="span[local:has-class(., 'code')]" mode="local:text">
      <text>`</text>
      <value-of select="string()"/>
      <text>`</text>
   </template>

   <template match="span[local:has-class(., 'parameter')]" mode="local:text">
      <text>*</text>
      <next-match/>
      <text>*</text>
   </template>

   <template match="br" mode="local:text">
      <value-of select="$local:line-break"/>
   </template>

   <template match="h4" mode="local:text">
      <call-template name="local:md-h4">
         <with-param name="content">
            <next-match/>
         </with-param>
      </call-template>
   </template>
   
   <template match="b[normalize-space()]|strong[normalize-space()]" mode="local:text">
      <text>**</text>
      <apply-templates mode="#current"/>
      <text>**</text>
   </template>

   <template match="text()" mode="local:text">

      <if test="count(preceding-sibling::node()) gt 0 and matches(., '^[\s\n]+')">
         <text> </text>
      </if>

      <value-of select="replace(normalize-space(), '&lt;', '&amp;lt;')"/>

      <if test="count(following-sibling::node()) gt 0 and matches(., '[\s\n]+$')">
         <text> </text>
      </if>

   </template>
   
   <!-- Helpers -->

   <template name="local:md-h1">
      <param name="content">
         <apply-templates select="." mode="local:text"/>
      </param>

      <variable name="title" select="string($content)"/>
      
      <value-of select="$title"/>
      <value-of select="$new-line"/>
      <value-of select="string-join(for $c in (1 to string-length($title)) return '=', '')"/>
      <value-of select="$new-line"/>
   </template>

   <template name="local:md-h2">
      <param name="content">
         <apply-templates select="." mode="local:text"/>
      </param>

      <variable name="title" select="string($content)"/>
      
      <value-of select="$new-line"/>
      <value-of select="$title"/>
      <value-of select="$new-line"/>
      <value-of select="string-join(for $c in (1 to string-length($title)) return '-', '')"/>
      <value-of select="$new-line"/>
   </template>

   <template name="local:md-h3">
      <param name="content">
         <apply-templates select="." mode="local:text"/>
      </param>
      
      <value-of select="$new-line"/>
      <text>### </text>
      <value-of select="$content"/>
      <value-of select="$new-line"/>
   </template>

   <template name="local:md-h4">
      <param name="content">
         <apply-templates select="." mode="local:text"/>
      </param>
      
      <value-of select="$new-line"/>
      <text>#### </text>
      <value-of select="$content"/>
      <value-of select="$new-line"/>
   </template>

   <template name="local:md-h5">
      <param name="content">
         <apply-templates select="." mode="local:text"/>
      </param>

      <value-of select="$new-line"/>
      <text>##### </text>
      <value-of select="$content"/>
      <value-of select="$new-line"/>
   </template>
   
   <template name="local:table-data-to-md">
      <param name="skip-cols" select="0"/>
      
      <element name="table" namespace="">
         <variable name="head-row" select="(thead, tbody, .)[1]/tr[1]"/>
         <variable name="rows" select="(tbody, .)[1]/tr[not(. is $head-row)]"/>

         <element name="thead" namespace="">
            <element name="tr" namespace="">
               <for-each select="$head-row/*[position() gt $skip-cols]">
                  <element name="th" namespace="">
                     <apply-templates select="." mode="local:text"/>
                  </element>
               </for-each>
            </element>
         </element>

         <element name="tbody" namespace="">
            <for-each select="$rows">
               <element name="tr" namespace="">
                  <for-each select="*[position() gt $skip-cols]">
                     <element name="td" namespace="">
                        <apply-templates select="." mode="local:text"/>
                     </element>
                  </for-each>
               </element>
            </for-each>
         </element>
      </element>
   </template>

   <function name="local:valid-link" as="xs:boolean">
      <param name="el" as="element()" />

      <sequence select="boolean($el/self::a[@href and (@href = '#fullInheritance' or (every $s in ('#', 'mailto:') satisfies not(starts-with(@href, $s))))])"/>
   </function>
      
   <function name="local:has-class" as="xs:boolean">
      <param name="el" as="element()" />
      <param name="class-name" as="item()" />

      <sequence select="$el/@class and tokenize(upper-case(normalize-space($el/@class)), ' ') = upper-case(string($class-name))" />
   </function>

   <function name="local:has-rel" as="xs:boolean">
      <param name="el" as="element()" />
      <param name="rel" as="item()" />

      <sequence select="$el/@rel and tokenize(upper-case(normalize-space($el/@rel)), ' ') = upper-case(string($rel))" />
   </function>
   
   <function name="local:code-lang-github" as="xs:string">
      <param name="lang" as="item()"/>

      <variable name="lang-lower" select="lower-case($lang)"/>
         
      <choose>
         <when test="$lang-lower = ('c#', 'cs')">
            <sequence select="'csharp'"/>
         </when>
         <when test="$lang-lower = ('f#', 'fs')">
            <sequence select="'fsharp'"/>
         </when>
         <when test="$lang-lower = 'c++'">
            <sequence select="'cpp'"/>
         </when>
         <otherwise>
            <sequence select="$lang"/>
         </otherwise>
      </choose>
   </function>
   
   <function name="local:code-lang-short" as="xs:string">
      <param name="lang" as="item()"/>

      <variable name="lang-lower" select="lower-case($lang)"/>
         
      <choose>
         <when test="$lang-lower = ('c#', 'csharp')">
            <sequence select="'cs'"/>
         </when>
         <when test="$lang-lower = ('f#', 'fsharp')">
            <sequence select="'fs'"/>
         </when>
         <when test="$lang-lower = 'c++'">
            <sequence select="'cpp'"/>
         </when>
         <otherwise>
            <sequence select="$lang"/>
         </otherwise>
      </choose>
   </function>

   <function name="local:is-block-element" as="xs:boolean">
      <param name="el" as="element()"/>

      <sequence select="name($el) = ('address', 'article', 'aside', 'audio', 'blockquote', 'canvas', 'div', 'dl', 'fieldset', 'figcaption', 'figure', 'footer', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'header', 'hgroup', 'hr', 'noscript', 'ol', 'output', 'p', 'pre', 'section', 'table', 'ul', 'video')"/>
   </function>
   
</stylesheet>
