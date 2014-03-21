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

         var baseUri = new Uri(AppDomain.CurrentDomain.BaseDirectory, UriKind.Absolute);

         var exec = compiler.Compile(new Uri(baseUri, "sandcastle-md-all.xsl"));

         var transformer = exec.Load();
         transformer.InitialTemplate = new QName("main");
         transformer.SetParameter(new QName("source-dir"), new XdmAtomicValue(new Uri(baseUri, args[0])));

         if (args.Length > 1) {
            transformer.SetParameter(new QName("output-dir"), new XdmAtomicValue(new Uri(baseUri, args[1])));
         }

         var serializer = new Serializer();
         serializer.SetOutputWriter(Console.Out);

         transformer.Run(serializer);
      }
   }
}
