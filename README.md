[sandcastle-md] — Your API reference on GitHub
==============================================
sandcastle-md converts your [SHFB]-generated HTML website to Markdown.

- Browse your API reference on GitHub.com or using any tool that supports Markdown
- Host your API reference on GitHub Pages, using your own layout and fully integrated with your site

Additionaly, sandcastle-md makes the following changes to SHFB's output:

- Transforms the flat topic file structure to a hierarchical, one directory per namespace/type
- Excludes topics that group members into categories e.g. Properties, Methods, Overloads, etc.

Project Settings
----------------
Open your SHFB project and make sure the following settings are in place:

* Build
  - Uncheck *Clean intermediate files after a succesful build*<br/> `<CleanIntermediates>False</CleanIntermediates>`
  - Uncheck *Indent rendered HTML*<br/> `<IndentHtml>False</IndentHtml>`
* Help File
  - Set *Topic file naming method* to **Member name**<br/> `<NamingMethod>MemberName</NamingMethod>`
  - Set *Presentation Style* to **VS2013**<br/> `<PresentationStyle>VS2013</PresentationStyle>`
  - Check *Include root namespace container* and set the title to something like **&lt;project name> Namespaces**<br/>  `<RootNamespaceContainer>True</RootNamespaceContainer>`<br/>`<RootNamespaceTitle>{Project Name} Namespaces</RootNamespaceTitle>`
* Help 1/Website
  - Set *Website SDK link type* to **Online links to MSDN help topics**

Converting to Markdown
----------------------
Build your SHFB project (if you haven't already):

```powershell
MSBuild.exe <your .shfbproj project>
```

Restore NuGet packages and build sandcastle-md:

```powershell
.\packages\restore.ps1
MSBuild.exe .\sandcastle-md.sln
```

Before executing it's recommended to clear any previous output, to make sure any deleted topics do not remain:

```powershell
rm <output path> -Recurse
```

Finally, execute:

```powershell
.\src\sandcastle-md\bin\Debug\sandcastle-md.exe <source website path> [output path]
```

Examples
--------
- [DbExtensions](https://github.com/maxtoroq/DbExtensions/tree/master/docs/api#readme) (GitHub.com)
- [DbExtensions](https://maxtoroq.github.io/DbExtensions/docs/api/) (GitHub Pages)
- [MvcCodeRouting](https://github.com/maxtoroq/MvcCodeRouting/tree/master/docs/api#readme)

[sandcastle-md]: https://github.com/maxtoroq/sandcastle-md
[SHFB]: https://github.com/EWSoftware/SHFB
