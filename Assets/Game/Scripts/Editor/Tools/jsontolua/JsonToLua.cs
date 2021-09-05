using System.Collections.Generic;
using System.IO;
using System.Text;
using Newtonsoft.Json;

class JsonToLua
{
    public static string Convert(string jsonStr)
    {
        var safeContents = jsonStr.Replace(" ", string.Empty);//去掉所有空格
        var jsonDataList = JsonObjToJsonData(safeContents);
        var sb = new StringBuilder();
        sb.AppendLine("return {");
        foreach (var jsonData in jsonDataList)
        {
            sb.AppendLine(ParseJsonData(jsonData));
        }
        sb.Append("}");
        return sb.ToString().Replace("null", "nil");
    }

    enum JsonType
    {
        Array,
        Object,
        Other,
    }

    class JsonData//将Josn中的键值对的形式对应起来
    {
        public JsonType Type;
        public string Key;
        public string Value;
        public int Layer;
        public List<JsonData> childList;//嵌套的数组或对象
    }

    private static List<JsonData> JsonObjToJsonData(string jsonStr, int layer = 1)
    {
        var jsonDataList = new List<JsonData>();

        var separatorIndex = jsonStr.IndexOf(':');//通过:取得所有对象
        while (separatorIndex >= 0)
        {
            var cutStr = jsonStr.Substring(0, separatorIndex);
            jsonStr = jsonStr.Substring(separatorIndex + 1);

            //拿到键
            var leftMarkIndex = cutStr.IndexOf('"');
            var rightMarkIndex = cutStr.IndexOf('"', leftMarkIndex + 1);
            var keyStr = cutStr.Substring(leftMarkIndex, rightMarkIndex - leftMarkIndex + 1);
            var jsonData = new JsonData { Layer = layer };
            jsonData.Key = keyStr.Replace("\"", string.Empty);

            //拿到值
            var headMark = jsonStr[0];//头标记决定值类型，'[','{',other
            switch (headMark)
            {
                case '['://值为数组
                    jsonData.Type = JsonType.Array;
                    jsonData.Value = GetMatchMarkStr(jsonStr, "[]");
                    jsonData.childList = JsonArrToJsonData(jsonData.Value, layer);
                    break;
                case '{'://值为对象
                    jsonData.Type = JsonType.Object;
                    jsonData.Value = GetMatchMarkStr(jsonStr, "{}");
                    jsonData.childList = JsonObjToJsonData(jsonData.Value, layer);
                    break;
                default://值为字符串，数字，布尔值，null
                    jsonData.Type = JsonType.Other;
                    jsonData.Value = GetStrByComma(jsonStr);
                    break;
            }
            jsonDataList.Add(jsonData);
            jsonStr = jsonStr.Substring(jsonData.Value.Length);
            separatorIndex = jsonStr.IndexOf(':');
        }
        return jsonDataList;
    }

    private static List<JsonData> JsonArrToJsonData(string jsonStr, int layer)
    {
        //数组值的列表
        var jsonItemList = new List<JsonData>();

        var headMark = jsonStr[1];//0索引为'['，所以1索引才是标识符
        if (headMark.Equals('['))//数组值为数组
        {
            while (jsonStr.IndexOf('[') > 0)
            {
                var itemStr = GetMatchMarkStr(jsonStr, "[]");
                var jsonData = new JsonData { Type = JsonType.Array, Value = itemStr, Layer = layer };
                jsonData.childList = JsonArrToJsonData(jsonData.Value, jsonData.Layer);
                jsonStr = jsonStr.Substring(itemStr.Length);
                jsonItemList.Add(jsonData);
            }
        }
        else if (headMark.Equals('{'))
        {
            while (jsonStr.IndexOf('{') > 0)//当数组值为对象
            {
                var itemStr = GetMatchMarkStr(jsonStr, "{}");
                var jsonData = new JsonData { Type = JsonType.Object, Value = itemStr, Layer = layer };
                jsonData.childList = JsonObjToJsonData(jsonData.Value, jsonData.Layer);
                jsonStr = jsonStr.Substring(itemStr.Length);
                jsonItemList.Add(jsonData);
            }
        }
        else//数组值为字符串，数字，布尔值，null
        {
            //可能为[]或者[1]只有一个值，索引不到','
            if (jsonStr.IndexOf(',') < 0)
            {
                var itemStr = GetMatchMarkStr(jsonStr, "[]");
                itemStr = itemStr.Substring(1, itemStr.Length - 2);
                if (!string.IsNullOrEmpty(itemStr))
                {
                    var jsonData = new JsonData { Type = JsonType.Other, Value = itemStr, Layer = layer };
                    jsonItemList.Add(jsonData);
                }
            }
            else
            {
                jsonStr.Substring(1);//去掉'['，让数组值的索引可以从0开始
                while (jsonStr.IndexOf(',') > 0)
                {
                    var itemStr = GetStrByComma(jsonStr);
                    var jsonData = new JsonData { Type = JsonType.Other, Value = itemStr, Layer = layer };
                    jsonStr = jsonStr.Substring(itemStr.Length);
                    jsonItemList.Add(jsonData);
                }
            }
        }
        return jsonItemList;
    }

    private static string ParseJsonData(JsonData jsonData)
    {
        #region 这是为了要求不生成AssetID空的结构体强行加的
        HandleAssetID(jsonData);
        #endregion
        var sb = new StringBuilder();
        var layer = jsonData.Layer;
        if (jsonData.Type == JsonType.Array || jsonData.Type == JsonType.Object)
        {
            if (jsonData.childList.Count >= 1)
            {
                if (string.IsNullOrEmpty(jsonData.Key))
                {
                    sb.AppendLine(Space(layer) + "{");
                }
                else
                {
                    sb.AppendLine(Space(layer) + jsonData.Key + " = {");
                }
                foreach (var item in jsonData.childList)
                {
                    item.Layer = layer + 1;
                    sb.AppendLine(ParseJsonData(item));
                }
                sb.Append(Space(layer) + "},");
            }
            else
            {
                sb.AppendLine(Space(layer) + jsonData.Key + " = {},");
            }
        }
        else
        {
            if (string.IsNullOrEmpty(jsonData.Key))
            {
                sb.Append(Space(layer) + jsonData.Value + ",");
            }
            else
            {
                sb.Append(Space(layer) + jsonData.Key + " = " + jsonData.Value + ",");
            }
        }
        return sb.ToString();
    }

    private static string GetMatchMarkStr(string contents, string mark)
    {
        var startMarkIndex = contents.IndexOf(mark[0]);
        var endMarkIndex = contents.IndexOf(mark[1], startMarkIndex);
        var checkIndex = contents.IndexOf(mark[0], startMarkIndex + 1, endMarkIndex - startMarkIndex);
        while (checkIndex >= 0)
        {
            endMarkIndex = contents.IndexOf(mark[1], endMarkIndex + 1);
            checkIndex = contents.IndexOf(mark[0], checkIndex + 1, endMarkIndex - checkIndex);
        }
        return contents.Substring(startMarkIndex, endMarkIndex - startMarkIndex + 1);
    }

    private static string GetStrByComma(string contents)
    {
        var endMarkIndex = contents.IndexOf(',');
        //如果索引到最后一个，则索引对象结束符号
        if (endMarkIndex < 0)
        {
            endMarkIndex = contents.IndexOf('}');
        }
        if (endMarkIndex < 0)
        {
            endMarkIndex = contents.IndexOf(']');
        }
        return contents.Substring(0, endMarkIndex);
    }

    static string Space(int layer)
    {
        var sb = new StringBuilder();
        for (int i = 0; i < layer; i++)
        {
            sb.Append("\t");
        }
        return sb.ToString();
    }

    private static void HandleAssetID(JsonData jsonData)
    {
        if (jsonData.Key != null)
        {
            if (jsonData.Key.Equals("beHurtEffecct")
                || jsonData.Key.Equals("Projectile")
                || jsonData.Key.Equals("HurtEffect")
                || jsonData.Key.Equals("HitEffect")
                || jsonData.Key.Equals("effectAsset")
                || jsonData.Key.Equals("soundAudioAsset")
                || jsonData.Key.Equals("footAsset")
                || jsonData.Key.Equals("footAudioAsset"))
            {
                if (jsonData.Value.Contains("\"IsEmpty\":true"))
                {
                    jsonData.Value = "{}";
                    jsonData.childList.Clear();
                }
                if (jsonData.Value.Contains("\"IsEmpty\":false"))
                {
                    var assetGUID = jsonData.childList.Find(childData => childData.Key.Equals("AssetGUID"));
                    var isEmpty = jsonData.childList.Find(childData => childData.Key.Equals("IsEmpty"));
                    jsonData.childList.Remove(assetGUID);
                    jsonData.childList.Remove(isEmpty);
                }
            }
        }
    }
}