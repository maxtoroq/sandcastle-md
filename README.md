Convert your Sandcastle-generated HTML website to GitHub-friendly Markdown
==========================================================================

Prerequisites
-------------
It is assumed that you already have a working Sandcastle project. This tool has been tested with [v2014.2.15.0 Beta](https://shfb.codeplex.com/releases/view/118566) only. If you have an older version, please upgrade. If you have a newer version and something is not working please let me know on the issue tracker.

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
  - If your project depends on Microsoft products that are not part of the .NET Framework BCL (e.g. ASP.NET MVC) you need to configure the *Additional Reference Links* plug-in, for more info see [this](http://stackoverflow.com/questions/9082149).

Converting to Markdown
----------------------
1. Open the solution in Visual Studio 2013 and build to restore packages and compile the executable.
2. Execute `.\src\sandcastle-md\bin\Debug\sandcastle-md.exe <source website path> [output path]`. You can invoke this command from the Package Manager Console.

Examples
--------
- [MvcAccount](https://github.com/maxtoroq/MvcAccount/tree/master/docs/api)
- [DbExtensions](https://github.com/maxtoroq/DbExtensions/tree/master/docs/api)
