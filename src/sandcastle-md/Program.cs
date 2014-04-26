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
         string inputDir = args[0];
         string outputDir = args[1];

         if (currentDir.Last() != Path.DirectorySeparatorChar) {
            currentDir += Path.DirectorySeparatorChar;
         }

         if (inputDir.Last() != Path.DirectorySeparatorChar) {
            inputDir += Path.DirectorySeparatorChar;
         }

         if (outputDir.Last() != Path.DirectorySeparatorChar) {
            outputDir += Path.DirectorySeparatorChar;
         }

         var baseUri = new Uri(AppDomain.CurrentDomain.BaseDirectory, UriKind.Absolute);
         var callerBaseUri = new Uri(currentDir, UriKind.Absolute);

         var exec = compiler.Compile(new Uri(baseUri, "sandcastle-md-all.xsl"));

         var transformer = exec.Load();
         transformer.InitialTemplate = new QName("main");
         transformer.SetParameter(new QName("source-dir"), new XdmAtomicValue(new Uri(callerBaseUri, inputDir)));

         if (args.Length > 1) {
            transformer.SetParameter(new QName("output-dir"), new XdmAtomicValue(new Uri(callerBaseUri, outputDir)));
         }

         var serializer = new Serializer();
         serializer.SetOutputWriter(Console.Out);

         transformer.Run(serializer);
      }
   }
}
