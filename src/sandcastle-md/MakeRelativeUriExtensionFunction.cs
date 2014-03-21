using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Saxon.Api;

namespace sandcastle_md {
   
   class MakeRelativeUriExtensionFunction : ExtensionFunctionDefinition {

      readonly QName _FunctionName = new QName("http://maxtoroq.github.io/sandcastle-md", "make-relative-uri");
      readonly XdmSequenceType _ResultType = new XdmSequenceType(XdmAtomicType.BuiltInAtomicType(QName.XS_ANYURI), ' ');

      readonly XdmSequenceType[] _ArgumentTypes = new XdmSequenceType[] { 
         new XdmSequenceType(XdmAtomicType.BuiltInAtomicType(QName.XS_ANYURI), ' '),
         new XdmSequenceType(XdmAtomicType.BuiltInAtomicType(QName.XS_ANYURI), ' ')
      };

      public override XdmSequenceType[] ArgumentTypes {
         get { return _ArgumentTypes; }
      }

      public override QName FunctionName {
         get { return _FunctionName; }
      }
      
      public override int MaximumNumberOfArguments {
         get { return 2; }
      }

      public override int MinimumNumberOfArguments {
         get { return 2; }
      }

      public override XdmSequenceType ResultType(XdmSequenceType[] ArgumentTypes) {
         return _ResultType;
      }

      public override ExtensionFunctionCall MakeFunctionCall() {
         return new FunctionCall();
      }

      class FunctionCall : ExtensionFunctionCall {

         public override IXdmEnumerator Call(IXdmEnumerator[] arguments, DynamicContext context) {

            IXdmEnumerator first = arguments[0];
            IXdmEnumerator second = arguments[1];

            first.MoveNext();
            second.MoveNext();

            Uri firstUri = (Uri)((XdmAtomicValue)first.Current).Value;
            Uri secondUri = (Uri)((XdmAtomicValue)second.Current).Value;

            return (IXdmEnumerator)new XdmAtomicValue(
               firstUri.MakeRelativeUri(secondUri)
            ).GetEnumerator();
         }
      }
   }
}
