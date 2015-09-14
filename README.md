[sandcastle-md](https://maxtoroq.github.io/sandcastle-md/) — Your API reference on GitHub
=========================================================================================
sandcastle-md converts your Sandcastle-generated HTML website to GitHub Flavored Markdown.

Prerequisites
-------------
It is assumed that you already have a working [Sandcastle](https://github.com/EWSoftware/SHFB) project. This tool has been tested with:

- [v2014.11.22.0](https://shfb.codeplex.com/releases/view/123728)
- [v2014.5.31.0](https://shfb.codeplex.com/releases/view/121365)
- [v2014.2.15.0 Beta](https://shfb.codeplex.com/releases/view/118566) (The [v2014.2.15](https://github.com/maxtoroq/sandcastle-md/tree/v2014.2.15) branch supports this version)

If you are using an older version, please upgrade. If you are using a newer version and find an issue please let me know on the issue tracker.

Project Settings
----------------
Open your Sandcastle project and make sure the following settings are in place:

* Build
  - Uncheck *Clean intermediate files after a succesful build*
  - Uncheck *Indent rendered HTML*
* Help File
  - Set *Topic file naming method* to **Member name**
  - Set *Presentation Style* to **VS2010**
  - Check *Include root namespace container* and set the title to something like **&lt;project name> Namespaces**
* Help 1/Website
  - Set *Website SDK link type* to **Online links to MSDN help topics**
* Plug-Ins
  - If your project depends on Microsoft products that are not part of the .NET Framework BCL (e.g. ASP.NET MVC) you need to configure the [Additional Reference Links](http://ewsoftware.github.io/SHFB/html/15b6b7be-3778-4487-b524-d558d02e6460.htm) plug-in, for more info see [this](http://stackoverflow.com/questions/9082149).

Converting to Markdown
----------------------
Build your Sandcastle project (if you haven't already):

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
- [DbExtensions](https://github.com/maxtoroq/DbExtensions/tree/master/docs/api#readme)
- [MvcAccount](https://github.com/maxtoroq/MvcAccount/tree/master/docs/api#readme)
- [MvcCodeRouting](https://github.com/maxtoroq/MvcCodeRouting/tree/master/docs/api#readme)
