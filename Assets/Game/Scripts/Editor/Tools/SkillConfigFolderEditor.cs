using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class SkillConfigFolderEditor : EditorWindow {
    
    [MenuItem("自定义工具/技能配置编辑器配表")]
    static void ShowWindos()
    {
        GetWindow<SkillConfigFolderEditor>();
    }

    private Object folder;

    void OnGUI()
    {
        folder = EditorGUILayout.ObjectField("目标文件夹:", folder, typeof(Object), false);
        var dirPath = AssetDatabase.GetAssetPath(folder);
        if (dirPath.Contains("."))
        {
            EditorGUILayout.HelpBox("选择的可能不是一个文件夹，请确认", MessageType.Error);
        }

        if (GUILayout.Button("生成配表"))
        {
            var dir = new DirectoryInfo(dirPath);
            var files = dir.GetFiles("*.prefab", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                CreateSingleConfig(file);
            }
            AssetDatabase.Refresh();
            EditorUtility.DisplayDialog("Title", "生成完毕", "确认");
        }
    }

    private string jsonFolder = "../EditorJson/prefab_data/";
    private string saveFolder = "/Game/Lua/config/prefab_data/";

    private void CreateSingleConfig(FileInfo file)
    {
        var filePath = file.FullName.Replace("\\", "/");
        var fileName = file.Name.Split('.')[0];

        var actorList = GetActorList();

        var actorName = actorList.Find(name => filePath.Contains(name + "/"));

        var jsonSaveDir = Path.Combine(Application.dataPath, jsonFolder + "json/" + actorName);
        if (!Directory.Exists(jsonSaveDir))
        {
            Directory.CreateDirectory(jsonSaveDir);
            AssetDatabase.Refresh();
        }
        var jsonSavePath = jsonSaveDir + "/" + fileName + "_config.json";

        var luaSaveDir = Application.dataPath + saveFolder + "config/" + actorName;
        if (!Directory.Exists(luaSaveDir))
        {
            Directory.CreateDirectory(luaSaveDir);
            AssetDatabase.Refresh();
        }
        var luaSavePath = luaSaveDir + "/" + fileName + "_config.lua";

        var config = new PrefabDataConfig();
        var jsonStr = File.Exists(jsonSavePath) ? File.ReadAllText(jsonSavePath) : JsonConvert.SerializeObject(config);
        File.WriteAllText(jsonSavePath, jsonStr);
        var luaConfig = JsonToLua.Convert(jsonStr).Replace("[none]", string.Empty);
        File.WriteAllText(luaSavePath, luaConfig);
    }

    private string actorFolder = "Assets/Game/Actors";

    private List<string> GetActorList()
    {
        var actorList = new List<string>();
        var actorsDir = new DirectoryInfo(actorFolder);
        var dirs = actorsDir.GetDirectories();
        foreach (var dir in dirs)
        {
            actorList.Add(dir.Name);
        }
        return actorList;
    }
}
