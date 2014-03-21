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

   <import href="sandcastle-md.xsl"/>
   
   <param name="source-dir" select="resolve-uri('.', static-base-uri())"/>
   <param name="output-dir" select="resolve-uri('markdown/', $source-dir)"/>
   
   <output method="text"/>

   <template name="main">

      <variable name="toc">
         <apply-templates select="doc(resolve-uri('Working/toc.xml', $source-dir))" mode="read-toc"/>
      </variable>

      <apply-templates select="$toc/*"/>
   </template>

   <template match="@*|node()" mode="read-toc">
      <copy>
         <apply-templates select="@*|node()" mode="#current"/>
      </copy>
   </template>

   <template match="topic" mode="read-toc">
      <param name="ns-segments-length" select="0" as="xs:integer" tunnel="yes"/>
      <param name="type-segments-length" select="0" as="xs:integer" tunnel="yes"/>
      
      <variable name="url" select="local:parse-id(@id, @file)"/>
      <variable name="file" select="tokenize(replace(replace(@file, '__', '_.'), '_([0-9]+)$', '.$1'), '_')"/>

      <choose>
         <when test="$url[1] = 'R'">
            <!-- Root namespace container -->

            <copy>
               <apply-templates select="@*" mode="#current"/>
               <attribute name="local:md-url" select="'README.md'" />
               <attribute name="local:html-url" select="concat(@file, '.htm')" />

               <apply-templates mode="#current">
                  <with-param name="ns-segments-length" select="$ns-segments-length" tunnel="yes"/>
               </apply-templates>
            </copy>
            
         </when>
         <when test="string-length($url[1]) eq 1">

            <variable name="is-ns" select="$url[1] eq 'N'"/>
            <variable name="is-type" select="$url[1] eq 'T'"/>

            <variable name="ns-parts" select="$url[position() gt 1][$is-ns or position() le $ns-segments-length]"/>
            <variable name="type-parts" select="$url[position() gt 1][position() gt count($ns-parts)][$is-type or position() le $type-segments-length]"/>
            
            <variable name="ns-dir" select="string-join($ns-parts, '.')"/>
            <variable name="type-dir" select="
               if (not(empty($type-parts))) then 
                  substring(@file, (3 + 1) + string-length($ns-dir), string-length(string-join($type-parts, '_')))
               else 
                  ()
            "/>

            <variable name="file-name" select="
               if ($is-ns or $is-type) then
                  'README'
               else
                  substring(@file, (3 + 2) + string-length($ns-dir) + string-length($type-dir))
            " />
            
            <variable name="output-url" select="string-join(($ns-dir, $type-dir, $file-name), '/')" />

            <copy>
               <apply-templates select="@*" mode="#current"/>
               <attribute name="local:md-url" select="concat($output-url, '.md')" />
               <attribute name="local:html-url" select="concat(@file, '.htm')" />
               
               <apply-templates mode="#current">
                  <with-param name="ns-segments-length" 
                     select="if ($is-ns) then count($ns-parts) else $ns-segments-length" 
                     tunnel="yes"/>

                  <with-param name="type-segments-length" 
                     select="if ($is-type) then count($type-parts) else $type-segments-length"
                     tunnel="yes"/>
               </apply-templates>
            </copy>
            
         </when>
         <otherwise>
            <copy>
               <apply-templates select="@*" mode="#current"/>
               <attribute name="local:html-url" select="concat(@file, '.htm')" />
               <attribute name="local:unused-topic" select="'1'"/>

               <apply-templates mode="#current">
                  <with-param name="ns-segments-length" select="$ns-segments-length" tunnel="yes"/>
               </apply-templates>
            </copy>
         </otherwise>      
      </choose>
   </template>

   <template match="topic[@local:unused-topic]">
      <apply-templates mode="#current"/>
   </template>

   <template match="topic">

      <variable name="source" select="doc(resolve-uri(@local:html-url, resolve-uri('html/', $source-dir)))"/>
      <variable name="output-uri" select="resolve-uri(@local:md-url, $output-dir)"/>
      
      <result-document href="{$output-uri}">
         <apply-templates select="$source">
            <with-param name="local:topic" select="." tunnel="yes"/>
            <with-param name="local:base-output-uri" select="$output-dir" tunnel="yes"/>
            <with-param name="local:output-uri" select="$output-uri" tunnel="yes"/>
         </apply-templates>
      </result-document>

      <value-of select="'Created ', @local:md-url, $local:line" separator=""/>

      <apply-templates/>
   </template>

   <function name="local:parse-id" as="xs:string+">
      <param name="id" as="item()"/>
      <param name="file" as="item()"/>

      <sequence select="tokenize($id, '[:\.]')"/>
   </function>
   
</stylesheet>
