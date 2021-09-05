using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Nirvana;
using System.Text;
using System.Text.RegularExpressions;
using System;
using System.Linq;
using UnityEngine.UI;

enum VARIABLE_VALUE_TYPE
{
    STRING = 1,
    BOOL = 2,
    FLOAT = 3,
    ASSET = 4
}

enum VARIABLE_BIND_TYPE
{
    NONE = 0,
    BIND_ACTIVE = 1,
    BIND_ATTACH = 2,
    BIND_COLOR = 3,
    BIND_DROPDOWN = 4,
    BIND_GRAY = 5,
    BIND_IMAGE = 6,
    BIND_IMAGE_BOOL = 7,
    BIND_INTERRACTABLE = 8,
    BIND_RAWIMAGE = 9,
    BIND_RAWIMAGE_URL = 10,
    BIND_SLIDER = 11,
    BIND_TEXT = 12,
    BIND_TOGGLE = 13,
}

enum EVENT_BIND_TYPE
{
    NONE = 0,
    BIND_CLICK = 1,
    BIND_DROPDOWN = 2,
    BIND_INPUTFIELD_VALUE = 3,
    BIND_INPUTFIELD_END = 4,
    BIND_INPUTFIELDKEY = 5,
    BIND_PRESSDOWN = 6,
    BIND_PRESSUP = 7,
    BIND_SLIDER = 8,
    BIND_TOGGLE = 9,
    BIND_TOUCH_UP = 10,
    BIND_TOUCH_DOWN = 11,
}

public class CsharpTableEditor : Editor
{
    #region 路径配置
    private static string UI_Path = "/Game/Uis/Views";
    private static string LUA_CONFIG_PATH = "/Game/Lua/gameui/variable/";
    #endregion

    #region 生成配置相关
    [MenuItem("Tools/TableTools/OneKeyEditorVariable", false)]
    public static void EditorAllVariable()
    {
        var dirPath = Application.dataPath + UI_Path;
        var dirInfo = new DirectoryInfo(dirPath);
        //----------Add------------
        //EditorProgressBar.ShowWindow(GetPrefabNumber(dirInfo));
        //----------End------------
        var dirs = dirInfo.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var dir in dirs)
            {
                DoEditorConfigSingleFolder(dir);
            }
        }

        var files = dirInfo.GetFiles("*.prefab");
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                if (!CheckIsCompleted(file.FullName))
                {
                    DoEditorConfigSingleFile(file);
                    AddCompleteFile(file.FullName);
                }
            }
        }

        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("提示", "生成UI Variable完成", "确定");
    }

    [MenuItem("Assets/Tools/TableTools/SingleEditorVariable", false, 135)]
    public static void EditorSingleVariable()
    {
        var go = Selection.activeGameObject;
        if (go == null)
        {
            EditorUtility.DisplayDialog("错误操作", "请选择UI Prefab", "确定");
            return;
        }
        string result = AssetDatabase.GetAssetPath(go);
        RebulidTable(go);

        DoSelectSinglePrefab(go, result);

        Selection.activeGameObject = null;
        AssetDatabase.Refresh();
        //dddd
    }

    private static void DoEditorConfigSingleFolder(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.prefab");
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                if (!CheckIsCompleted(file.FullName))
                {
                    DoEditorConfigSingleFile(file);
                    AddCompleteFile(file.FullName);
                }
            }
        }

        var dirs = dir.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var di in dirs)
            {
                DoEditorConfigSingleFolder(di);
            }
        }
    }

    private static void DoEditorConfigSingleFile(FileInfo file)
    {
        var filePath = file.FullName;
        filePath = filePath.Replace("\\", "/");
        var loadPath = filePath;
        var luaFilePath = filePath;
        var idx = luaFilePath.IndexOf("Views/");
        var titleName = string.Empty;
        if (idx != -1)
        {
            luaFilePath = luaFilePath.Substring(idx);
            luaFilePath = luaFilePath.Replace("Views/", string.Empty);
            titleName = luaFilePath;
            titleName = titleName.Replace(".prefab", string.Empty);
            luaFilePath = luaFilePath.Replace("/", "_");
            luaFilePath = luaFilePath.Replace(".prefab", "_var.lua");
        }
        luaFilePath = Application.dataPath + LUA_CONFIG_PATH + luaFilePath;
        luaFilePath = luaFilePath.ToLower();
        if (File.Exists(luaFilePath))
        {
            File.Delete(luaFilePath);
        }

        idx = loadPath.IndexOf("Assets/");
        if (idx != -1)
        {
            loadPath = loadPath.Substring(idx);
        }
        var go = AssetDatabase.LoadAssetAtPath(loadPath, typeof(GameObject)) as GameObject;
        if (go != null)
        {
            RebulidTable(go);
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("-- " + titleName + " --");
            sb.AppendLine("return {");
            DoSingleTrans(go.transform, sb, go.name, titleName);
            sb.AppendLine("}");

            WriteConfigToLua(sb, luaFilePath);

            //AssetDatabase.SaveAssets();
            //AssetDatabase.Refresh();
        }
    }

    private static void DoSelectSinglePrefab(GameObject go, string path)
    {
        var luaFilePath = path;
        var idx = luaFilePath.IndexOf("Views/");
        var titleName = string.Empty;
        if (idx != -1)
        {
            luaFilePath = luaFilePath.Substring(idx);
            luaFilePath = luaFilePath.Replace("Views/", string.Empty);
            titleName = luaFilePath;
            titleName = titleName.Replace(".prefab", string.Empty);
            luaFilePath = luaFilePath.Replace("/", "_");
            luaFilePath = luaFilePath.Replace(".prefab", "_var.lua");
        }
        luaFilePath = Application.dataPath + LUA_CONFIG_PATH + luaFilePath;
        luaFilePath = luaFilePath.ToLower();
        if (File.Exists(luaFilePath))
        {
            File.Delete(luaFilePath);
        }

        StringBuilder sb = new StringBuilder();
        var prefabName = go.name;
        sb.AppendLine("-- " + titleName + " --");
        sb.AppendLine("return {");
        DoSingleTrans(go.transform, sb, prefabName, titleName);
        sb.AppendLine("}");

        WriteConfigToLua(sb, luaFilePath);

        AssetDatabase.SaveAssets();
    }

    private static void DoSingleTrans(Transform trans, StringBuilder sb, string prefabName, string titleName)
    {
        var go = trans.gameObject;
        var uiVariableTable = go.GetComponent<UIVariableTable>();
        var uiEventTable = go.GetComponent<UIEventTable>();
        if (uiVariableTable != null || uiEventTable != null)
        {
            Dictionary<string, GameObject> nameDic = new Dictionary<string, GameObject>();
            var uiNameTable = go.GetOrAddComponent<UINameTable>();
            var nl = uiNameTable.binds;
            foreach (var bp in nl)
            {
                if (!bp.Name.Contains("/"))
                {
                    nameDic.Add(bp.Name, bp.Widget);
                }
            }
            // uiNameTable.binds = new List<UINameTable.BindPair>();
            // }

            sb.AppendLine("--Node name :" + go.name + " --");
            var nodePath = GetNodePath(go.transform, prefabName);
            sb.AppendLine("--self.ui_variables_path = {\"" + titleName + "\", \"" + nodePath + "\"}");
            sb.AppendLine("\t[\"" + nodePath + "\"] = {");

            if (uiEventTable != null)
            {
                sb.AppendLine("\t\tEvent = {");
                var eventContent = string.Empty;
                if (uiEventTable.Events.Length > 0)
                {
                    var eventList = uiEventTable.Events;
                    int eventCount = eventList.Length;
                    int idx = 1;
                    foreach (var it in eventList)
                    {
                        var singleEventStr = DoSingleEvnt(it, uiEventTable, nameDic, prefabName);
                        if (!string.IsNullOrEmpty(singleEventStr))
                        {
                            if (idx != eventCount)
                            {
                                singleEventStr += "\n";
                            }
                            eventContent += singleEventStr;
                        }
                        idx++;
                    }
                }
                sb.AppendLine(eventContent);
                sb.AppendLine("\t\t},");//event end
                sb.AppendLine(string.Empty);
            }

            if (uiVariableTable != null)
            {
                sb.AppendLine("\t\tVariable = {");
                var variables = uiVariableTable.Variables;
                if (variables.Length > 0)
                {
                    foreach (var variable in variables)
                    {
                        DoSingleVariable(variable, sb, nameDic, prefabName);
                    }
                }
                sb.AppendLine("\t\t},");//variable end
            }

            sb.AppendLine("\t},");//node end

            if (nameDic.Count > 0)
            {
                uiNameTable.binds = new List<UINameTable.BindPair>(nameDic.Count);
                foreach (var kv in nameDic)
                {
                    UINameTable.BindPair bindPair = new UINameTable.BindPair();
                    bindPair.Name = kv.Key;
                    bindPair.Widget = kv.Value;
                    uiNameTable.binds.Add(bindPair);
                }
            }
        }

        for (int i = 0, n = trans.childCount; i < n; i++)
        {
            var t = trans.GetChild(i);
            DoSingleTrans(t, sb, prefabName, titleName);
        }
    }

    private static string DoSingleEvnt(string etName, UIEventTable uet, Dictionary<string, GameObject> dic, string prefabName)
    {
        ICollection<Component> list = uet.FindReferenced(etName);
        if (list != null && list.Count > 0)
        {
            string contentStr = "\t\t\t" + etName + " = {\n";
            string codeString = "";
            var count = 0;
            foreach (var it in list)
            {
                var bindTargetName = it.gameObject.name;
                GameObject dgo = null;
                if (dic.TryGetValue(bindTargetName, out dgo))
                {
                    if (dgo != it.gameObject)
                    {
                        var key = string.Empty;
                        var hasSameGO = FindNameDicSameGameObject(it.gameObject, dic, ref key);
                        if (hasSameGO == false)
                        {
                            var fullName = GetNodePath(it.gameObject.transform, prefabName);
                            fullName = CheckSameName(dic, fullName);
                            dic.Add(fullName, it.gameObject);

                            contentStr += DoSingleEvntGo(it.gameObject, fullName, etName, prefabName);
                            codeString += CodeSingleEvntGo(it.gameObject, fullName, etName);
                        }
                        else
                        {
                            contentStr += DoSingleEvntGo(it.gameObject, key, etName, prefabName);
                            codeString += CodeSingleEvntGo(it.gameObject, key, etName);
                        }
                    }
                    else
                    {
                        contentStr += DoSingleEvntGo(it.gameObject, bindTargetName, etName, prefabName);
                        codeString += CodeSingleEvntGo(it.gameObject, bindTargetName, etName);
                    }
                }
                else
                {
                    var key = string.Empty;
                    var hasSameGO = FindNameDicSameGameObject(it.gameObject, dic, ref key);
                    if (hasSameGO == false)
                    {
                        var fullName = GetNodePath(it.gameObject.transform, prefabName);
                        fullName = CheckSameName(dic, fullName);
                        dic.Add(fullName, it.gameObject);

                        key = fullName;
                    }

                    contentStr += DoSingleEvntGo(it.gameObject, key, etName, prefabName);
                    codeString += CodeSingleEvntGo(it.gameObject, key, etName);
                }

                count++;

                var str = count < list.Count ? "\n" : "},\n";
                contentStr += str;
            }

            contentStr += "\t\t\t\t--[[\n";
            contentStr += codeString;
            contentStr += "\t\t\t\t]]";

            return contentStr;
        }
        return string.Empty;
    }

    private static string DoSingleEvntGo(GameObject go, string key, string etName, string prefabName)
    {
        var events = go.GetComponentsInChildren<UIEventBind>(true);
        var str = string.Empty;

        if (events != null)
        {
            var bind_type = GetEventBindType(events, etName);
            str = "\t\t\t\t{name = \"" + key + "\", " + "event_type = " + Convert.ToUInt32(bind_type).ToString() + "},";
        }

        if (key.Contains("/") || key.Contains("(") || key.Contains(")") || key.Contains(" ") || key.Contains("-") || key.Contains("  "))
        {
            Debug.LogError(prefabName + " -> Event ObjName: " + key);
        }
        return str;
    }

    private static string CodeSingleEvntGo(GameObject go, string key, string etName)
    {
        var events = go.GetComponentsInChildren<UIEventBind>(true);
        var str = string.Empty;
        if (events != null)
        {
            var bind_type = GetEventBindType(events, etName);
            var codeStr = "\t\t\t\t\t";
            switch (bind_type)
            {
                case EVENT_BIND_TYPE.BIND_CLICK:
                    if (go.GetComponent<Button>())
                    {
                        codeStr += "self.node_list[\"" + key + "\"].button:AddClickListener(BindTool.Bind(self." + etName + ", self))";
                    }
                    else if (go.GetComponent<Toggle>())
                    {
                        codeStr += "self.node_list[\"" + key + "\"].toggle:AddClickListener(BindTool.Bind(self." + etName + ", self))";
                    }
                    else
                    {
                        codeStr += "self.node_list[\"" + key + "\"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self." + etName + ", self))";
                    }
                    break;

                case EVENT_BIND_TYPE.BIND_DROPDOWN:
                    codeStr += "self.node_list[\"" + key + "\"].dropdown.onValueChanged:AddListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_INPUTFIELD_VALUE:
                    codeStr += "self.node_list[\"" + key + "\"].input_field.onValueChanged:AddListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_INPUTFIELD_END:
                    codeStr += "self.node_list[\"" + key + "\"].input_field.onEndEdit:AddListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_INPUTFIELDKEY:
                    codeStr += "No function ! no suport ! please delete you code!";
                    break;

                case EVENT_BIND_TYPE.BIND_PRESSDOWN:
                    codeStr += "self.node_list[\"" + key + "\"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_PRESSUP:
                    codeStr += "self.node_list[\"" + key + "\"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_SLIDER:
                    codeStr += "self.node_list[\"" + key + "\"].slider.onValueChanged:AddListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_TOGGLE:
                    codeStr += "self.node_list[\"" + key + "\"].toggle.onValueChanged:AddListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_TOUCH_UP:
                    codeStr += "self.node_list[\"" + key + "\"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self." + etName + ", self))";
                    break;

                case EVENT_BIND_TYPE.BIND_TOUCH_DOWN:
                    codeStr += "self.node_list[\"" + key + "\"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self." + etName + ", self))";
                    break;

            }
            str = codeStr + "\n";
        }
        return str;
    }

    private static void RebulidTable(GameObject go)
    {
        var components = go.GetComponentsInChildren<UIVariableBind>(true);
        foreach (var component in components)
        {
            if (!component.binded)
            {
                component.binded = true;
                component.RefreshVariableTable();
                component.BindVariables();
            }
        }

        var ebList = go.GetComponentsInChildren<UIEventBind>(true).ToList();
        if (ebList.Count > 0)
        {
            foreach (var it in ebList)
            {
                it.RefreshBind();
            }
        }
    }

    private static string GetNodePath(Transform nodeTrans, string prefabName)
    {
        var result = nodeTrans.gameObject.name;
        if (result == prefabName)
        {
            return result;
        }
        Transform parentTrans = nodeTrans.parent;
        if (parentTrans != null)
        {
            result = result.Insert(0, parentTrans.gameObject.name + "/");
            if (parentTrans.gameObject.name != prefabName)
            {
                while (true)
                {
                    parentTrans = parentTrans.parent;
                    if (parentTrans != null)
                    {
                        result = result.Insert(0, parentTrans.gameObject.name + "/");
                        if (parentTrans.gameObject.name == prefabName)
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
        return result;
    }

    private static void DoSingleVariable(UIVariable uv, StringBuilder sb, Dictionary<string, GameObject> nd, string prefabName)
    {
        if (uv.Binds.Count == 0)
        {
            return;
        }
        sb.Append("\t\t\t" + uv.Name + " = {");
        var contentStr = string.Empty;
        var codeString = string.Empty;
        var vt = GetVariableValueType(uv.Type);
        contentStr += "value_type = " + vt + ", ";
        contentStr += GetVariableValueStringByVariable(uv);
        contentStr += DoVariableBinds(uv.Binds, nd, prefabName, ref codeString);
        sb.AppendLine(contentStr + "},");
       
        sb.AppendLine("\t\t\t\t--[[");
        sb.AppendLine(codeString + "\t\t\t\t]]");
        sb.AppendLine(string.Empty);
    }

    private static void WriteConfigToLua(StringBuilder sb, string configPath)
    {
        if (sb.ToString().Contains("["))
        {
            File.WriteAllText(configPath, sb.ToString(), Encoding.UTF8);
        }
    }

    private static string GetVariableValueStringByVariable(UIVariable uv)
    {
        var vt = uv.Type;
        var result = string.Empty;
        switch (vt)
        {
            case UIVariableType.Asset:
                var assetID = uv.GetAsset();
                result = "value = {\"" + assetID.BundleName + "\" , \"" + assetID.AssetName + "\"}";
                break;
            case UIVariableType.Integer:
            case UIVariableType.String:
                result = "value = \"" + uv.ValueObject + "\"";
                break;
            case UIVariableType.Boolean:
                var b = (bool)uv.ValueObject;
                var str = b == true ? "true" : "false";
                result = "value = " + str;
                break;
            case UIVariableType.Float:
                result = "value = " + (float)uv.ValueObject;
                break;
        }
        return result + ",";
    }

    private static string GetVariableValueType(UIVariableType vt)
    {
        uint result = 0;
        switch (vt)
        {
            case UIVariableType.Asset:
                result = (uint)VARIABLE_VALUE_TYPE.ASSET;
                break;
            case UIVariableType.Integer:
            case UIVariableType.String:
                result = (uint)VARIABLE_VALUE_TYPE.STRING;
                break;
            case UIVariableType.Boolean:
                result = (uint)VARIABLE_VALUE_TYPE.BOOL;
                break;
            case UIVariableType.Float:
                result = (uint)VARIABLE_VALUE_TYPE.FLOAT;
                break;
        }
        return result.ToString();
    }

    private static string DoVariableBinds(ICollection<UIVariableBind> binds, Dictionary<string, GameObject> nd, string prefabName, ref string codeString)
    {
        var result = string.Empty;
        if (binds.Count > 0)
        {
            result += " obj_list = {\n";
            string pathName = string.Empty;
            string tableString = string.Empty;
            var idx = 1;
            var count = binds.Count;
            foreach (var vb in binds)
            {
                string codeStr = string.Empty;
                DoSingleVariableBind(vb, ref tableString, ref pathName, prefabName, nd, ref codeStr);

                if (pathName.Contains("/") || pathName.Contains("(") || pathName.Contains(")") || pathName.Contains(" ") || pathName.Contains("-") || pathName.Contains("  "))
                {
                    Debug.LogError(prefabName + " -> Variable ObjName: " + pathName);
                }

                result += "\t\t\t\t{name = \"" + pathName + "\"," + tableString + "},";
                if (idx != count)
                {
                    result += "\n";
                }

                codeString += codeStr;

                idx++;
                pathName = string.Empty;
                tableString = string.Empty;
            }
            result += "},";
        }
        return result;
    }

    private static bool FindNameDicSameGameObject(GameObject go, Dictionary<string, GameObject> dic, ref string key)
    {
        foreach (var kv in dic)
        {
            if (kv.Value == go)
            {
                key = kv.Key;
                return true;
            }
        }
        return false;
    }

    private static void DoSingleVariableBind(UIVariableBind bind, ref string tableString, ref string pathName, string prefabName, Dictionary<string, GameObject> nd, ref string codeStr)
    {
        var go = bind.gameObject;
        Transform parentTrans = go.transform.parent;
        pathName = go.name;
        if (parentTrans != null)
        {
            pathName = pathName.Insert(0, parentTrans.gameObject.name + "/");
            if (parentTrans.gameObject.name != prefabName)
            {
                while (true)
                {
                    parentTrans = parentTrans.parent;
                    if (parentTrans != null)
                    {
                        pathName = pathName.Insert(0, parentTrans.gameObject.name + "/");
                        if (parentTrans.gameObject.name == prefabName)
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }

        if (!string.IsNullOrEmpty(pathName))
        {
            string key = string.Empty;
            var hasSameGO = FindNameDicSameGameObject(bind.gameObject, nd, ref key);
            if (hasSameGO == false)
            {
                pathName = CheckSameName(nd, pathName);
                nd.Add(pathName, bind.gameObject);
            }
            else
            {
                pathName = key;
            }
        }

        VARIABLE_BIND_TYPE bindType = GetBindType(bind);
        tableString = " bind_type = " + (uint)bindType + ", ";
        switch (bindType)
        {
            case VARIABLE_BIND_TYPE.BIND_ACTIVE:
                tableString += GetBindUIVariableBindActiveString(bind as UIVariableBindActive, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_ATTACH:
                GetBindUIVariableBindAttachString(bind as UIVariableBindAttach, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_COLOR:
                tableString += GetUIVariableBindColorString(bind as UIVariableBindColor, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_DROPDOWN:
                GetUIVariableBindDrapdownString(bind as UIVariableBindDrapdown, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_GRAY:
                tableString += GetUIVariableBindGrayString(bind as UIVariableBindGray, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_IMAGE:
                tableString += GetBindUIVariableBindImageString(bind as UIVariableBindImage, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_IMAGE_BOOL:
                tableString += GetBindUIVariableBindImageBoolString(bind as UIVariableBindImageBool, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_INTERRACTABLE:
                tableString += GetUIVariableBindInteractableString(bind as UIVariableBindInteractable, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_RAWIMAGE:
                tableString += GetUIVariableBindRawImageString(bind as UIVariableBindRawImage, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_RAWIMAGE_URL:
                tableString += GetUIVariableBindRawImageURLString(bind as UIVariableBindRawImageURL, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_SLIDER:
                tableString += GetUIVariableBindSliderString(bind as UIVariableBindSlider, pathName, ref codeStr);
                break;

            case VARIABLE_BIND_TYPE.BIND_TOGGLE:
                tableString += GetUIVariableBindToggleString(bind as UIVariableBindToggle, pathName, ref codeStr);
                break;
            case VARIABLE_BIND_TYPE.BIND_TEXT:
                tableString += "text = \"" + GetBindTextString(bind as UIVariableBindText, pathName, ref codeStr) + "\",";
                break;
        }
    }

    private static VARIABLE_BIND_TYPE GetBindType(UIVariableBind bind)
    {
        if (bind as UIVariableBindActive)
        {
            return VARIABLE_BIND_TYPE.BIND_ACTIVE;
        }

        if (bind as UIVariableBindAttach)
        {
            return VARIABLE_BIND_TYPE.BIND_ATTACH;
        }

        if (bind as UIVariableBindColor)
        {
            return VARIABLE_BIND_TYPE.BIND_COLOR;
        }

        if (bind as UIVariableBindDrapdown)
        {
            return VARIABLE_BIND_TYPE.BIND_DROPDOWN;
        }

        if (bind as UIVariableBindGray)
        {
            return VARIABLE_BIND_TYPE.BIND_GRAY;
        }

        if (bind as UIVariableBindImage)
        {
            return VARIABLE_BIND_TYPE.BIND_IMAGE;
        }

        if (bind as UIVariableBindImageBool)
        {
            return VARIABLE_BIND_TYPE.BIND_IMAGE_BOOL;
        }

        if (bind as UIVariableBindInteractable)
        {
            return VARIABLE_BIND_TYPE.BIND_INTERRACTABLE;
        }

        if (bind as UIVariableBindRawImage)
        {
            return VARIABLE_BIND_TYPE.BIND_RAWIMAGE;
        }

        if (bind as UIVariableBindRawImageURL)
        {
            return VARIABLE_BIND_TYPE.BIND_RAWIMAGE_URL;
        }

        if (bind as UIVariableBindSlider)
        {
            return VARIABLE_BIND_TYPE.BIND_SLIDER;
        }

        if (bind as UIVariableBindText)
        {
            return VARIABLE_BIND_TYPE.BIND_TEXT;
        }

        if (bind as UIVariableBindToggle)
        {
            return VARIABLE_BIND_TYPE.BIND_TOGGLE;
        }

        return VARIABLE_BIND_TYPE.NONE;
    }

    private static EVENT_BIND_TYPE GetEventBindType(UIEventBind[] events, string etName)
    {
        foreach (var bind in events)
        {
            if (bind as UIEventBindClick)
            {
                UIEventBindClick realBind = (UIEventBindClick)bind;
                if (realBind.eventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_CLICK;
                }
            }

            if (bind as UIEventBindDropdown)
            {
                UIEventBindDropdown realBind = (UIEventBindDropdown)bind;
                if (realBind.valueChangedEventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_DROPDOWN;
                }
            }

            if (bind as UIEventBindInputField)
            {
                UIEventBindInputField realBind = (UIEventBindInputField)bind;
                if (realBind.valueChangedEventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_INPUTFIELD_VALUE;
                }
                else if (realBind.endEditEventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_INPUTFIELD_END; ;
                }
            }

            if (bind as UIEventBindInputFieldKey)
            {
                UIEventBindInputFieldKey realBind = (UIEventBindInputFieldKey)bind;
                var keyEvents = realBind.keyEvents;
                foreach (var keyEv in realBind.keyEvents)
                {
                    if (keyEv.eventName == etName)
                    {
                        return EVENT_BIND_TYPE.BIND_INPUTFIELDKEY;
                    }
                }
            }

            if (bind as UIEventBindPressDown)
            {
                UIEventBindPressDown realBind = (UIEventBindPressDown)bind;
                if (realBind.eventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_PRESSDOWN;
                }
            }

            if (bind as UIEventBindPressUp)
            {
                UIEventBindPressUp realBind = (UIEventBindPressUp)bind;
                if (realBind.eventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_PRESSUP;
                }
            }

            if (bind as UIEventBindSlider)
            {
                UIEventBindSlider realBind = (UIEventBindSlider)bind;
                if (realBind.eventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_SLIDER;
                }
            }

            if (bind as UIEventBindToggle)
            {
                UIEventBindToggle realBind = (UIEventBindToggle)bind;
                if (realBind.eventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_TOGGLE;
                }
            }

            if (bind as UIEventBindTouch)
            {
                UIEventBindTouch realBind = (UIEventBindTouch)bind;
                if (realBind.downEventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_TOUCH_DOWN;
                }
                else if (realBind.upEventName == etName)
                {
                    return EVENT_BIND_TYPE.BIND_TOUCH_UP;
                }
            }
        }

        return EVENT_BIND_TYPE.NONE;
    }

    private static string GetBindTextString(UIVariableBindText bt, string pathName, ref string code)
    {
        var result = string.Empty;
        result = bt.Format;
        var codeClip = bt.Format;
        var targets = bt.paramBinds;

        Dictionary<string, int> dic = new Dictionary<string, int>();
        if (targets.Length > 0)
        {
            for (int i = 0, n = targets.Length; i < n; i++)
            {
                var s = "{" + i + "}";
                if (result.Contains(s))
                {
                    int index = result.IndexOf(s);
                    dic.Add(targets[i], index);

                    result = result.Replace(s, "{" + targets[i] + "}");
                    codeClip = codeClip.Replace(s, "%s");
                }
            }
        }
        result = result.Replace("\n", "\\n");

        var codeParam = string.Empty;
        Dictionary<string, int> dic_sort = dic.OrderBy(o => o.Value).ToDictionary(p => p.Key, o => o.Value);
        var max_count = dic_sort.Keys.Count;
        var count = 0;
        foreach (var item in dic_sort)
        {
            var pading = string.Empty;
            if (count ++ < dic_sort.Keys.Count - 1) pading = ", ";

            codeParam += item.Key + pading;
        }

        if (codeClip.Length > 0)
        {
            code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].text.text = string.format(\"" + codeClip + "\", " + codeParam + ")\n";
        }
        else
        {
            code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].text.text = " + targets[0] + "\n";
        }

        return result;
    }

    private static string GetBindUIVariableBindImageString(UIVariableBindImage image, string pathName, ref string code)
    {
        var result = string.Empty;
        result += "auto_fit_size = " + (image.autoFitNativeSize == true ? "true" : "false") +
            ", " + "auto_disable = " + (image.autoDisable == true ? "true" : "false") + "," +
            " fill_bind = \"" + image.fillAmountBind + "\",";

        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].image:LoadSprite(bundle, asset .. \".png\")\n";

        return result;
    }

    private static string GetBindUIVariableBindImageBoolString(UIVariableBindImageBool image, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)image.booleanLogic + ", " + "param_list = {";
        var vrs = image.variables;
        var count = image.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = image.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "},";

        code += "\t\t\t\t\tlocal is_on = " + codeClip + "\n";
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].image:LoadSprite(bundle, asset .. \".png\")\n";

        return result;
    }

    private static string GetBindUIVariableBindActiveString(UIVariableBindActive ba, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)ba.booleanLogic + ", " + "param_list = {";
        var vrs = ba.variables;
        var count = ba.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = ba.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "},";
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"]:SetActive(" + codeClip + ")\n";

        return result;
    }

    private static string GetBindUIVariableBindAttachString(UIVariableBindAttach ba, string pathName, ref string code)
    {
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].game_obj_attach.Asset = AssetID(bundle, asset)\n";
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].game_obj_attach:ChangeAsset()\n";

        var result = string.Empty;
        return result;
    }

    private static string GetUIVariableBindColorString(UIVariableBindColor bc, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)bc.booleanLogic + ", " + "param_list = {";
        var vrs = bc.variables;
        var count = bc.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = bc.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "}, ";
        Color onColor = bc.enabledColor;
        Color offColor = bc.disabledColor;
        result += "on_color = {r = " + onColor.r + ", g = " + onColor.g + ", b = " + onColor.b + ", a = " + onColor.a + "}, " +
                  "off_color = {r = " + offColor.r + ", g = " + offColor.g + ", b = " + offColor.b + ", a = " + offColor.a + "},";

        code += "\t\t\t\t\tlocal is_on = " + codeClip + "\n";
        code += "\t\t\t\t\tlocal color = is_on and Color(" + onColor.r + ", " + onColor.g + ", " + onColor.b + ", " + onColor.a + ")" + " or " + "Color(" + offColor.r + ", " + offColor.g + ", " + offColor.b + ", " + offColor.a + ")\n";
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].graphic.color = color\n";

        return result;
    }

    private static string GetUIVariableBindDrapdownString(UIVariableBindDrapdown bd, string pathName, ref string code)
    {
        var result = string.Empty;
        return result;
    }

    private static string GetUIVariableBindGrayString(UIVariableBindGray bg, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)bg.booleanLogic + ", " + "param_list = {";
        var vrs = bg.variables;
        var count = bg.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = bg.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "},";

        codeClip = "not (" + codeClip + ")";
        code += "\t\t\t\t\tUI:SetGraphicGrey(self.node_list[\"" + pathName + "\"], " + codeClip + ")\n";

        return result;
    }

    private static string GetUIVariableBindInteractableString(UIVariableBindInteractable bi, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)bi.booleanLogic + ", " + " param_list = {";
        var vrs = bi.variables;
        var count = bi.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = bi.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "},";

        code += "\t\t\t\t\tUI:SetButtonEnabled(self.node_list[\"" + pathName + "\"], " + codeClip + ")\n";

        return result;
    }

    private static string GetUIVariableBindRawImageString(UIVariableBindRawImage bri, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "auto_fit_size = " + (bri.autoFitNativeSize == true ? "true" : "false") + "," +
                 " is_sync = " + (bri.isSync == true ? "true" : "false") + "," +
                 " is_realtime_unload = " + (bri.isRealtimeUnload == true ? "true" : "false");

        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].raw_image:LoadSprite(bundle, asset)\n";

        return result;
    }

    private static string GetUIVariableBindRawImageURLString(UIVariableBindRawImageURL bri, string pathName, ref string code)
    {
        var result = string.Empty;

        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].raw_image:LoadSprite(url, function ()\n";
        code += "\t\t\t\t\tend)\n";

        return result;
    }

    private static string GetUIVariableBindSliderString(UIVariableBindSlider bs, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "tween_speed = " + bs.TweenSpeed + ", " + "tween_type = " + (uint)bs.tweenType + ",";

        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].slider.value = value\n";

        return result;
    }

    private static string GetUIVariableBindToggleString(UIVariableBindToggle bt, string pathName, ref string code)
    {
        var result = string.Empty;
        result = "bool_logic = " + (uint)bt.booleanLogic + ", " + "param_list = {";
        var vrs = bt.variables;
        var count = bt.variables.Length;
        var codeClip = string.Empty;
        for (int i = 0, n = count; i < n; i++)
        {
            var vr = vrs[i];
            result += vr.VariableName + " = " + (vr.reverse == true ? "true" : "false") + ((i < count - 1) ? ", " : string.Empty);

            var logicStr = string.Empty;
            if (i < count - 1) logicStr = bt.booleanLogic == UIVariableBindBool.BooleanLogic.And ? " and " : " or ";

            var reservStr = vr.VariableName;
            if (vr.reverse)
            {
                reservStr = "not " + reservStr;
                if (count > 1)
                {
                    reservStr = "(" + reservStr + ")";
                }
            }
            codeClip += reservStr + logicStr;
        }
        result += "},";
        code += "\t\t\t\t\tself.node_list[\"" + pathName + "\"].toggle.isOn = " + codeClip + "\n";

        return result;
    }

    private static string schedule = @"/Game/Lua/gameui/variable/schedule.txt";
    private static string explain = "已替换文件数： ";
    static bool CheckIsCompleted(string file)
    {
        string scheduleFullPath = Application.dataPath + schedule;

        if (!File.Exists(scheduleFullPath))
        {
            var o = File.Create(scheduleFullPath);
            o.Close();
        }

        StreamReader sr = new StreamReader(scheduleFullPath);

        string line = sr.ReadLine();
        while (line != null)
        {
            if (line.Equals(file))
            {
                sr.Dispose();
                return true;
            }
            line = sr.ReadLine();
        }

        sr.Dispose();
        return false;
    }

    static void AddCompleteFile(string file)
    {
        string scheduleFullPath = Application.dataPath + schedule;
        StreamReader sr = new StreamReader(scheduleFullPath);
        int num = 0;

        string firstLine = sr.ReadLine();

        if (string.IsNullOrEmpty(firstLine))
        {
            num = 1;
        }
        else
        {
            Match match = Regex.Match(firstLine, @"\d+");
            num = Convert.ToInt32(match.Value) + 1;
        }
        firstLine = explain + num + "\n";
        string content = sr.ReadToEnd();
        sr.Dispose();

        content = firstLine + content + "\n" + file;

        File.WriteAllText(scheduleFullPath, content, Encoding.UTF8);
        //为进度条赋值
        //EditorProgressBar.Progress = num;
        //Debug.Log("AddCompleteFile " + num);
    }

    static string CheckSameName(Dictionary<string, GameObject> dic, string name)
    {
        if (dic.ContainsKey(name))
        {
            string newName = string.Empty;
            string lastChar = name[name.Length - 1].ToString();
            if (Regex.IsMatch(lastChar, @"\d"))
            {
                int index = Convert.ToInt32(lastChar) + 1;
                newName = name.Replace(lastChar, index.ToString());
            }
            else
            {
                newName = name + "1";
            }
            name = CheckSameName(dic, newName);
        }
        return name;
    }

    static int GetPrefabNumber(DirectoryInfo dir)
    {
        int num = 0;
        var files = dir.GetFiles("*.prefab");
        if (files.Length > 0)
        {
            num += files.Length;
        }

        var dirs = dir.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var di in dirs)
            {
                num += GetPrefabNumber(di);
            }
        }
        return num;
    }
    #endregion

    #region 一键删除所有的配置文件
    [MenuItem("Tools/TableTools/DeleteAllUIVariableConfig", false)]
    public static void DeleteAllUiVariableConfig()
    {
        var dirPath = Application.dataPath + LUA_CONFIG_PATH;
        var dirInfo = new DirectoryInfo(dirPath);
        var dirs = dirInfo.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var dir in dirs)
            {
                DoDeleteConfigForFolder(dir);
            }
        }

        var files = dirInfo.GetFiles();
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                File.Delete(file.FullName);
                File.Delete(file.FullName + ".meta");
            }
        }
        AssetDatabase.Refresh();
    }

    private static void DoDeleteConfigForFolder(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.lua");
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                File.Delete(file.FullName);
                File.Delete(file.FullName + ".meta");
            }
        }

        var dirs = dir.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var di in dirs)
            {
                DoDeleteConfigForFolder(di);
            }
        }
    }
    #endregion

    #region 移除组件相关
    [MenuItem("Tools/TableTools/OneKeyRemoveComponents", false)]
    public static void RemoveAllPrefabComponents()
    {
        var dirPath = Application.dataPath + UI_Path;
        var dirInfo = new DirectoryInfo(dirPath);
        var dirs = dirInfo.GetDirectories();

        var files = dirInfo.GetFiles("*.prefab");
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                DoRemoveSingleFile(file);
            }
        }

        if (dirs.Length > 0)
        {
            foreach (var dir in dirs)
            {
                DoRemoveSingleFolder(dir);
            }
        }

        EditorUtility.DisplayDialog("提示", "移除完成", "确定");
    }

    [MenuItem("Assets/Tools/TableTools/RemoveComponents", false, 135)]
    public static void RemoveSinglePrefabComponents()
    {
        var go = Selection.activeGameObject;
        if (go == null)
        {
            EditorUtility.DisplayDialog("错误操作", "请选择UI Prefab", "确定");
            return;
        }
        //RebulidTable(go);
        RemoveComponentFromTrans(go.transform);

        UIVariableBind[] uiVariableBinds = go.GetComponentsInChildren<UIVariableBind>(true);
        foreach (var bind in uiVariableBinds)
        {
            DestroyImmediate(bind);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 处理移除脚步单个文件夹逻辑
    /// </summary>
    /// <param name="dir"></param>
    private static void DoRemoveSingleFolder(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.prefab");
        foreach (var file in files)
        {
            DoRemoveSingleFile(file);
        }

        var dirs = dir.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var di in dirs)
            {
                DoRemoveSingleFolder(di);
            }
        }
    }

    private static void DoRemoveSingleFile(FileInfo file)
    {
        var filePath = file.FullName;
        filePath = filePath.Replace("\\", "/");
        var idx = filePath.IndexOf("Assets/");
        if (idx != -1)
        {
            filePath = filePath.Substring(idx);
        }
        var go = AssetDatabase.LoadAssetAtPath(filePath, typeof(GameObject)) as GameObject;
        if (go != null)
        {
            RebulidTable(go);
            RemoveComponentFromTrans(go.transform);
        }
    }


    private static List<UIEventBind> CachedRemoveEventBind = new List<UIEventBind>();
    private static List<UIVariableBind> CachedRemoveVariableBind = new List<UIVariableBind>();
    private static void RemoveComponentFromTrans(Transform trans)
    {
        //         CachedRemoveEventBind.Clear();
        //         CachedRemoveVariableBind.Clear();
        //         var et = trans.GetComponent<UIEventTable>();
        //         if (et != null)
        //         {
        //             if (et.Events.Length > 0)
        //             {
        //                 var enList = et.Events;
        //                 foreach (var en in enList)
        //                 {
        //                     var ebList = et.FindReferenced(en);
        //                     //-------------------Add-----------------------
        //                     if (ebList == null)
        //                     {
        //                         Debug.LogError(trans.gameObject + "---" + en + " Event not Bind!!!");
        //                     }
        //                     //--------------------End----------------------
        //                     if (ebList != null && ebList.Count > 0)
        //                     {
        //                         foreach (var it in ebList)
        //                         {
        //                             var ueb = it as UIEventBind;
        //                             if(!CachedRemoveEventBind.Contains(ueb))
        //                             {
        //                                 CachedRemoveEventBind.Add(ueb);
        //                             }
        //                         }
        //                     }
        //                 }
        //             }
        //             DestroyImmediate(et, true);
        //         }
        // 
        //         if (CachedRemoveEventBind.Count > 0)
        //         {
        //             foreach (var it in CachedRemoveEventBind)
        //             {
        //                 if (CheckCanAddButton(it.gameObject, it))
        //                 {
        //                     RemoveButtonEx(it.transform);
        //                 }
        //                 DestroyImmediate(it, true);
        //             }
        //             CachedRemoveEventBind.Clear();
        //         }
        // 
        //         var vt = trans.GetComponent<UIVariableTable>();
        //         if (vt != null)
        //         {
        //             if (vt.Variables.Length > 0)
        //             {
        //                 var vList = vt.Variables;
        //                 foreach (var v in vList)
        //                 {
        //                     if (v.Binds.Count > 0)
        //                     {
        //                         var bList = v.Binds;
        //                         foreach (var vb in bList)
        //                         {
        //                             CachedRemoveVariableBind.Add(vb);
        //                         }
        //                     }
        //                 }
        //             }
        // 
        //             DestroyImmediate(vt, true);
        //         }
        // 
        //         if (CachedRemoveVariableBind.Count > 0)
        //         {
        //             foreach (var it in CachedRemoveVariableBind)
        //             {
        //                 DestroyImmediate(it, true);
        //             }
        //         }

        var ev_tb = trans.GetComponent<UIEventTable>();
        if (ev_tb != null)
        {
            DestroyImmediate(ev_tb, true);
        }

        var var_tb = trans.GetComponent<UIVariableTable>();
        if (var_tb != null)
        {
            DestroyImmediate(var_tb, true);
        }

        var ev_bind = trans.GetComponent<UIEventBind>();
        if (ev_bind != null)
        {
            DestroyImmediate(ev_bind, true);
        }

        var var_bind = trans.GetComponent<UIVariableBind>();
        if (var_bind != null)
        {
            DestroyImmediate(var_bind, true);
        }

        var nested = trans.GetComponent<NestedPrefab>();
        if (nested != null)
        {
            DestroyImmediate(nested, true);
        }

        //--------------------Add----------------------
        UIVariableBindGray uiGray = trans.GetComponent<UIVariableBindGray>();
        if (uiGray != null)
        {
            DestroyImmediate(uiGray, true);
        }

        UIGrayscale uiGrayscale = trans.GetComponent<UIGrayscale>();
        if (uiGrayscale != null)
        {
            DestroyImmediate(uiGrayscale, true);
        }

        UIMaterialEffect uiMaterialEffect = trans.GetComponent<UIMaterialEffect>();
        if (uiMaterialEffect != null)
        {
            DestroyImmediate(uiMaterialEffect, true);
        }
        //---------------------End----------------------

        if (trans.childCount > 0)
        {
            for (int i = 0, n = trans.childCount; i < n; i++)
            {
                RemoveComponentFromTrans(trans.GetChild(i));
            }
        }
    }

    private static void RemoveButtonEx(Transform trans)
    {
        //移除按钮相关脚本
        var vbi = trans.GetComponent<UIVariableBindInteractable>();
        if (vbi != null)
        {
            DestroyImmediate(vbi, true);
        }

        var bT = trans.GetComponent<ButtonTransition>();
        if (bT != null)
        {
            DestroyImmediate(bT, true);
        }

        var bEx = trans.GetComponent<ButtonEx>();
        if (bEx != null)
        {
            DestroyImmediate(bEx, true);
        }

        var grayBind = trans.GetComponent<UIVariableBindGray>();
        if (grayBind != null)
        {
            DestroyImmediate(grayBind, true);
        }

        var grayScale = trans.GetComponent<UIGrayscale>();
        if (grayScale != null)
        {
            DestroyImmediate(grayScale, true);
        }

        var materialEffect = trans.GetComponent<UIMaterialEffect>();
        if (materialEffect != null)
        {
            DestroyImmediate(materialEffect, true);
        }



        var b = trans.GetComponent<Button>();
        if (b == null)
        {
            trans.gameObject.AddComponent<Button>();
        }
    }

    private static bool CheckCanAddButton(GameObject go, UIEventBind eb)
    {
        if (eb == null)
        {
            return false;
        }

        if ((eb as UIEventBindClick) == false)
        {
            return false;
        }

        var toggle = go.GetComponent<Toggle>();
        if (toggle != null)
        {
            return false;
        }
        return true;
    }
    #endregion
}
