
using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Text.RegularExpressions;

namespace NewtonsoftJsonEx
{
	public static class JSon2Lua
	{
		public const string			LuaSuffix = ".lua";

		static Regex		ClassTypeRegex;
		static Regex		ArrayRegex;
		static Regex		PairRegex;
		static Regex		VectorRegex;

		static Regex		EmptyTableRegex;

		static JSon2Lua()
		{
			ClassTypeRegex = new Regex( @"^\s*""\$type""\s*:\s*""([^""\\]|\\.)*"",?\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase );
			ArrayRegex = new Regex( @"^(?<Indentation>\s*)(((?<Key>""[^""]+"")\s*:)?\s*((?<EmptyArray>\[\s*\]\s*(,\s*)?)|(?<ArrayBegin>\[\s*))|(?<ArrayEnd>\]\s*(,\s*)?))$", RegexOptions.Multiline );
			PairRegex = new Regex( @"^(?<Indentation>\s*)""(?<Key>(?<Index>\d+)|(?<VariableName>[a-zA-Z]+[\w\d_]*)|[^""]+)""\s*:\s*(?<Value>.+?)\s*((?<Comma>,)\s*)?$", RegexOptions.Multiline );
			VectorRegex = new Regex( @"\{\s*(\s*(?<Key>[xyzwargb])\s*=\s*(?<Value>(\+|\-)?\d+(\.\d+)?)(\s*,)?)+\s*\}", RegexOptions.Multiline );
			EmptyTableRegex = new Regex( @"(?<=[\r\n]|^)(?<Prefix>\s*(\[[^\]\r\n]+\]|\w+)\s*=\s*)?(\s*?(\{\s*\}|\[\s*\]|null)(\s*,)?)", RegexOptions.IgnoreCase );
        }

		/// <summary>
		/// 仅支持简单json格式
		/// </summary>
		public static string IndentedJSonString2Lua( string json, string emptyTable = null )
		{
			var			luastr = VectorRegex.Replace(
									PairRegex.Replace(
										ArrayRegex.Replace(
											ClassTypeRegex.Replace( json, string.Empty ),
											ArrayFormatReplace ),
										PairFormatReplace ),
									VectorFormatReplace );

			if( string.IsNullOrEmpty( emptyTable ) )
				return luastr;

			return EmptyTableRegex.Replace( luastr, match => EmptyTableReplace( match, emptyTable ) );
		}

		static string ArrayFormatReplace( Match match )
		{
			if( match.Groups[ "EmptyArray" ].Success )
			{
				if( match.Groups[ "Key" ].Success )
					return string.Format( @"{0}{1}: {{}},", match.Groups[ "Indentation" ].Value, match.Groups[ "Key" ].Value );		// 除[]括号外其余保持json格式
				else
					return string.Format( @"{0}{{}},", match.Groups[ "Indentation" ].Value );
			}
			else if( match.Groups[ "ArrayBegin" ].Success )
			{
				if( match.Groups[ "Key" ].Success )
					return string.Format( @"{0}{1}: {{", match.Groups[ "Indentation" ].Value, match.Groups[ "Key" ].Value );
				else
					return string.Format( @"{0}: {{", match.Groups[ "Indentation" ].Value, match.Groups[ "Key" ].Value );
			}
			else if( match.Groups[ "ArrayEnd" ].Success )
				return string.Format( "{0}}},", match.Groups[ "Indentation" ].Value );
			else
				throw new Exception( "不认识的匹配！" + match );
		}

		static string PairFormatReplace( Match match )
		{
			var			key = match.Groups[ "Index" ].Success ? string.Format( "[ {0} ]", match.Groups[ "Key" ].Value ) :
									match.Groups[ "VariableName" ].Success ? match.Groups[ "Key" ].Value :
									string.Format( @"[ ""{0}"" ]", match.Groups[ "Key" ].Value );

			return string.Format( @"{0}{1} = {2}{3}", match.Groups[ "Indentation" ].Value, key, match.Groups[ "Value" ].Value, match.Groups[ "Comma" ].Value );
		}

		static string VectorFormatReplace( Match matc )
		{
			var			keys = matc.Groups["Key"].Captures;
			var			values = matc.Groups["Value"].Captures;

			return "{ " + string.Join( ", ", Enumerable.Range( 0, keys.Count ).Select( i => values[ i ].Value ).ToArray() ) + " }";
		}

		static string EmptyTableReplace( Match match, string emptyTable )
		{
			return string.Format( @"{0}{1},", match.Groups[ "Prefix" ].Value, emptyTable );
		}
    }
}