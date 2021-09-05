
using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Linq;

namespace NewtonsoftJsonEx
{
	public class ContractResolverFilter : DefaultContractResolver
	{
		public delegate void PropertiesFilterDelegate( ref IList<JsonProperty> list );

		public event PropertiesFilterDelegate	PropertiesFilterEvent;

		protected override IList<JsonProperty> CreateProperties( Type type, MemberSerialization memberSerialization )
		{
			var			list = base.CreateProperties( type, memberSerialization );

			if( PropertiesFilterEvent != null )
				PropertiesFilterEvent( ref list );

            return list;
        }
	}

	public static class JsonHelper
	{
		public static JsonSerializerSettings	IndentedAndAutoNameHandling
		{
			get
			{
				return new JsonSerializerSettings()
				{
					Formatting = Formatting.Indented,
					TypeNameHandling = TypeNameHandling.Auto,
					ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
				};
			}
		}

		public static JsonSerializerSettings IndentedAndAllNameHandling
		{
			get
			{
				return new JsonSerializerSettings()
				{
					Formatting = Formatting.Indented,
					TypeNameHandling = TypeNameHandling.All,
					ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
				};
			}
		}
	}
    public class EditorOnlySerializeFieldAttribute : Attribute { }

    public static class JSONEditorHelper {

        public static readonly JsonSerializerSettings JsonSerializerSettings;
        public static readonly JsonSerializerSettings JsonFullSerializerSettings;

        public static readonly JsonSerializerSettings RTJsonSerializerSettings;

        static JSONEditorHelper() {
            var setting = JsonHelper.IndentedAndAutoNameHandling;
            var filter = new ContractResolverFilter();

            filter.PropertiesFilterEvent += IgnoreNonWritable;
            setting.ContractResolver = filter;

            JsonSerializerSettings = setting;

            var fullsetting = JsonHelper.IndentedAndAllNameHandling;

            fullsetting.ContractResolver = filter;

            JsonFullSerializerSettings = fullsetting;

            var rtSetting = JsonHelper.IndentedAndAutoNameHandling;
            var rtFilter = new ContractResolverFilter();

            rtFilter.PropertiesFilterEvent += RuntimePropertyFilter;
            rtSetting.ContractResolver = rtFilter;

            RTJsonSerializerSettings = rtSetting;
        }

        public static void IgnoreNonWritable(ref IList<JsonProperty> list) {
            for (var i = list.Count - 1; i >= 0; --i)
                if (!list[i].Writable)
                    list.RemoveAt(i);
        }
        public static void RuntimePropertyFilter(ref IList<JsonProperty> list) {
            IgnoreNonWritable(ref list);
            for (var i = list.Count - 1; i >= 0; --i)
                if (list[i].AttributeProvider
                               .GetAttributes(true)
                                .Any(attribute => attribute is EditorOnlySerializeFieldAttribute))
                    list.RemoveAt(i);
        }
    }
}