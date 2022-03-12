using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Saxon.Api;

namespace sandcastle_md {

   class Program {

      static void Main(string[] args) {

         var proc = new Processor();
         proc.RegisterExtensionFunction(new MakeRelativeUriExtensionFunction());

         var compiler = proc.NewXsltCompiler();

         string currentDir = Environment.CurrentDirectory;

         if (currentDir.Last() != Path.DirectorySeparatorChar) {
            currentDir += Path.DirectorySeparatorChar;
         }

         string inputDir = args[0];

         if (inputDir.Last() != Path.DirectorySeparatorChar) {
            inputDir += Path.DirectorySeparatorChar;
         }

         var baseUri = new Uri(AppDomain.CurrentDomain.BaseDirectory, UriKind.Absolute);
         var callerBaseUri = new Uri(currentDir, UriKind.Absolute);
         var sourceUri = new Uri(callerBaseUri, inputDir);

         string outputDir = (args.Length > 1) ? args[1] : null;

         if (outputDir != null
            && outputDir.Last() != Path.DirectorySeparatorChar) {

            outputDir += Path.DirectorySeparatorChar;
         }

         var outputUri = (outputDir != null) ?
            new Uri(callerBaseUri, outputDir)
            : new Uri(sourceUri, "markdown/");

         var exec = compiler.Compile(new Uri(baseUri, "sandcastle-md-all.xsl"));

         var transformer = exec.Load();
         transformer.InitialTemplate = new QName("main");
         transformer.SetParameter(new QName("source-dir"), new XdmAtomicValue(sourceUri));
         transformer.SetParameter(new QName("output-dir"), new XdmAtomicValue(outputUri));

         var serializer = new Serializer();
         serializer.SetOutputWriter(Console.Out);

         transformer.Run(serializer);

         var iconsSourceUri = new Uri(sourceUri, "icons");
         var iconsDestUri = new Uri(outputUri, "icons");

         DirectoryInfo iconsSourceDir = new DirectoryInfo(iconsSourceUri.LocalPath);
         DirectoryInfo iconsDestDir;

         if (!Directory.Exists(iconsDestUri.LocalPath)) {
            iconsDestDir = Directory.CreateDirectory(iconsDestUri.LocalPath);
         } else {
            iconsDestDir = new DirectoryInfo(iconsDestUri.LocalPath);
         }

         var icons = new HashSet<string>(File.ReadAllLines(new Uri(baseUri, "icons.txt").LocalPath), StringComparer.OrdinalIgnoreCase);

         foreach (FileInfo iconFile in iconsSourceDir.GetFiles()) {

            if (icons.Contains(iconFile.Name)) {
               iconFile.CopyTo(Path.Combine(iconsDestDir.FullName, iconFile.Name), overwrite: true);
            }
         }
      }
   }
}
