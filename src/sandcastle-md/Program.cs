using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Saxon.Api;

namespace sandcastle_md {

   class Program {

      static void Main(string[] args) {

         var proc = new Processor();
         proc.RegisterExtensionFunction(new MakeRelativeUriExtensionFunction());

         var compiler = proc.NewXsltCompiler();

         var currentDir = Environment.CurrentDirectory;

         if (currentDir.Last() != Path.DirectorySeparatorChar) {
            currentDir += Path.DirectorySeparatorChar;
         }

         var inputDir = args[0];

         if (inputDir.Last() != Path.DirectorySeparatorChar) {
            inputDir += Path.DirectorySeparatorChar;
         }

         var baseUri = new Uri(AppDomain.CurrentDomain.BaseDirectory, UriKind.Absolute);
         var callerBaseUri = new Uri(currentDir, UriKind.Absolute);
         var sourceUri = new Uri(callerBaseUri, inputDir);

         var outputDir = (args.Length > 1) ? args[1] : null;

         var optionalParams = args.Skip(2).ToArray();
         var removeAssemblyName = optionalParams.Any(p => p == "--remove-assembly-name");
         var removeAssemblyFileName = optionalParams.Any(p => p == "--remove-assembly-file-name");
         var removeAssemblyVersion = optionalParams.Any(p => p == "--remove-assembly-version");
         var excludeIcons = optionalParams.Any(p => p == "--exclude-icons");

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
         transformer.SetParameter(new QName("remove-assembly-name"), new XdmAtomicValue(removeAssemblyName));
         transformer.SetParameter(new QName("remove-assembly-file-name"), new XdmAtomicValue(removeAssemblyFileName));
         transformer.SetParameter(new QName("remove-assembly-version"), new XdmAtomicValue(removeAssemblyVersion));
         transformer.SetParameter(new QName("exclude-icons"), new XdmAtomicValue(excludeIcons));

         var serializer = new Serializer();
         serializer.SetOutputWriter(Console.Out);

         transformer.Run(serializer);

         if (excludeIcons) {
            return;
         }

         var iconsSourceUri = new Uri(sourceUri, "icons");
         var iconsNewUri = new Uri(new Uri(baseUri, "../../"), "icons");
         var iconsDestUri = new Uri(outputUri, "icons");

         var iconsSourceDir = new DirectoryInfo(iconsSourceUri.LocalPath);
         var iconsNewDir = new DirectoryInfo(iconsNewUri.LocalPath);
         DirectoryInfo iconsDestDir;

         if (!Directory.Exists(iconsDestUri.LocalPath)) {
            iconsDestDir = Directory.CreateDirectory(iconsDestUri.LocalPath);
         } else {
            iconsDestDir = new DirectoryInfo(iconsDestUri.LocalPath);
         }

         var icons = new HashSet<string>(File.ReadAllLines(new Uri(baseUri, "icons.txt").LocalPath), StringComparer.OrdinalIgnoreCase);

         foreach (var iconFile in iconsSourceDir.GetFiles()) {

            if (icons.Contains(iconFile.Name)) {
               iconFile.CopyTo(Path.Combine(iconsDestDir.FullName, iconFile.Name), overwrite: true);
            }
         }

         foreach (var iconFile in iconsNewDir.GetFiles()) {
            iconFile.CopyTo(Path.Combine(iconsDestDir.FullName, iconFile.Name), overwrite: true);
         }
      }
   }
}
