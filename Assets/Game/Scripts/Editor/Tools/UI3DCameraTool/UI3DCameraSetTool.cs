using System;
using Nirvana;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

public class UI3DCameraSetTool : EditorWindow
{
    [MenuItem("自定义工具/摄像机/UI 3D Camera Set")]
    static void ShowWindow()
    {
        var window = GetWindow<UI3DCameraSetTool>();
        window.minSize = new Vector2(600, 300);
    }

    private string jsonPath;
    private string luaPath;

    private UI3DCameraScriptable ui3DCameraConfig;      //ScriptableObject类
    private GameObject selectGo;                        //被选中的游戏物体
    private GUIStyle guiStyle;                          //标题格式
    private Vector2 scroll;                             //滚动条
    private string addModuleName;
    private string addSizeName;
    private int windowID;

    void Awake()
    {
        jsonPath = Path.Combine(Application.dataPath, "../EditorJson/UI3DCameraSetTool.json");
        luaPath = Path.Combine(Application.dataPath, "Game/Lua/gameui/widgets/role_model_camera_set.lua");

        guiStyle = new GUIStyle();
        guiStyle.normal.textColor = Color.white;
        guiStyle.fontStyle = FontStyle.BoldAndItalic;

        ReadData();
    }

    private void ReadData()
    {
        if (!File.Exists(jsonPath))
        {
            File.Create(jsonPath).Dispose();
        }
        ui3DCameraConfig = ScriptableObject.CreateInstance<UI3DCameraScriptable>();
        var jsonData = File.ReadAllText(jsonPath);
        JsonUtility.FromJsonOverwrite(jsonData, ui3DCameraConfig);
    }

    void OnGUI()
    {
        selectGo = EditorGUILayout.ObjectField("选中的物体：", selectGo, typeof(GameObject), true) as GameObject;
        selectGo = Selection.activeGameObject;

        if (selectGo == null || !selectGo.GetComponent<UI3DDisplayCamera>())
        {
            GUILayout.BeginArea(new Rect(0, 20, 600, 40));
            {
                EditorGUILayout.HelpBox("Not Contains UI3DDisplayCamera Component", MessageType.Error);
            }
            GUILayout.EndArea();
            return;
        }

        EditorGUILayout.BeginHorizontal();
        {
            addSizeName = EditorGUILayout.TextField(addSizeName);
            if (GUILayout.Button("添加相机规格"))
            {
                var cameraSize = new CameraSize { Name = addSizeName };
                var isExist = false;
                foreach (var size in ui3DCameraConfig.sizeList)
                {
                    if (size.Name == addSizeName)
                    {
                        EditorUtility.DisplayDialog("Error", "已存在相同相机规格命名，请勿重复命名！！", "确定");
                        isExist = true;
                    }
                }
                if (!isExist)
                {
                    ui3DCameraConfig.sizeList.Add(cameraSize);
                }
            }
            if (GUILayout.Button("导出为Lua配置", GUILayout.Width(100)))
            {
                OutputLuaConfig();
            }
        }
        EditorGUILayout.EndHorizontal();

        if (ui3DCameraConfig.sizeList.Count <= 0)
        {
            return;
        }

        for (int i = 0; i < ui3DCameraConfig.sizeList.Count; i++)
        {
            var sizeName = ui3DCameraConfig.sizeList[i].Name;
            if (GUILayout.Button(sizeName, GUILayout.Width(200)))
            {
                windowID = i;
            }
        }

        BeginWindows();
        {
            GUILayout.Window(windowID, new Rect(220, 45, 400, 400), CameraWindow, "");
        }
        EndWindows();
    }

    private void CameraWindow(int id)
    {
        var cameraSize = ui3DCameraConfig.sizeList[id];

        EditorGUILayout.BeginHorizontal();
        {
            cameraSize.Name = EditorGUILayout.TextField("按钮名称", cameraSize.Name);
            if (GUILayout.Button("删除按钮", GUILayout.Width(100)))
            {
                ui3DCameraConfig.sizeList.RemoveAt(id);
                windowID = Mathf.Clamp(windowID - 1, 0, windowID);
            }
            if (GUILayout.Button("设置为所有模板", GUILayout.Width(100)))
            {
                var tmpModuleList = cameraSize.moduleList;
                foreach (var singleSize in ui3DCameraConfig.sizeList)
                {
                    var curNameList = GetNameList(singleSize.moduleList);
                    foreach (var setModule in tmpModuleList)
                    {
                        if (curNameList.Contains(setModule.Name))
                        {
                            continue;
                        }

                        var tmpModule = new CameraModule { Name = setModule.Name };
                        singleSize.moduleList.Add(tmpModule);
                    }
                }
                EditorUtility.DisplayDialog("", "设置成功！！", "确定");
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        EditorGUILayout.LabelField("Select Mode", guiStyle);

        EditorGUILayout.BeginHorizontal();
        {
            if (GUILayout.Button("保存模板", GUILayout.Width(200)))
            {
                SaveModule(cameraSize, addModuleName);
            }
            addModuleName = EditorGUILayout.TextField(addModuleName, GUILayout.Width(270));
        }
        EditorGUILayout.EndHorizontal();

        
        var moduleList = cameraSize.moduleList;

        scroll = EditorGUILayout.BeginScrollView(scroll);
        {
            var textAnchor = GUI.skin.button.alignment;
            for (int i = 0; i < moduleList.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                {
                    GUI.skin.button.alignment = TextAnchor.LowerLeft;
                    if (GUILayout.Button(moduleList[i].Name, GUILayout.Width(250)))
                    {
                        selectGo.transform.localPosition = moduleList[i].Postion;
                        selectGo.transform.localEulerAngles = moduleList[i].EulerAngles;
                        var camera = selectGo.GetComponent<Camera>();
                        camera.fieldOfView = moduleList[i].FieldOfView;
                    }

                    GUI.skin.button.alignment = TextAnchor.MiddleCenter;
                    if (GUILayout.Button("上移", GUILayout.Width(50)))
                    {
                        if (i >= 1)
                        {
                            var temp = moduleList[i];
                            moduleList[i] = moduleList[i - 1];
                            moduleList[i - 1] = temp;
                        }
                    }


                    if (GUILayout.Button("下移", GUILayout.Width(50)))
                    {
                        if (i <= moduleList.Count - 2)
                        {
                            var temp = moduleList[i];
                            moduleList[i] = moduleList[i + 1];
                            moduleList[i + 1] = temp;
                        }
                    }

                    if (GUILayout.Button("修改", GUILayout.Width(50)))
                    {
                        var camera = selectGo.GetComponent<Camera>();
                        moduleList[i].Postion = selectGo.transform.localPosition;
                        moduleList[i].EulerAngles = selectGo.transform.localEulerAngles;
                        moduleList[i].FieldOfView = camera.fieldOfView;
                        EditorUtility.DisplayDialog("", "修改成功！！", "确定");
                    }

                    if (GUILayout.Button("移除", GUILayout.Width(50)))
                    {
                        moduleList.RemoveAt(i);
                    }
                }
                EditorGUILayout.EndHorizontal();
            }

            GUI.skin.button.alignment = textAnchor;
        }
        EditorGUILayout.EndScrollView();
    }

    void OnInspectorUpdate()
    {
        this.Repaint();
    }

    void OnDestroy()
    {
        var JsonData = JsonUtility.ToJson(ui3DCameraConfig);
        File.WriteAllText(jsonPath, JsonData);
    }

    private void SaveModule(CameraSize cameraSize, string name)
    {
        var camera = selectGo.GetComponent<Camera>();
        var addModule = new CameraModule
        {
            Name = name,
            Postion = selectGo.transform.localPosition,
            EulerAngles = selectGo.transform.localEulerAngles,
            FieldOfView = camera.fieldOfView
        };

        foreach (var module in cameraSize.moduleList)
        {
            if (module.Name == name)
            {
                EditorUtility.DisplayDialog("Error", "已存在相同模板名，请勿重复命名！！", "确定");
                return;
            }
        }
        cameraSize.moduleList.Add(addModule);
    }

    private List<string> GetNameList(List<CameraModule> modules)
    {
        List<string> nameList = new List<string>();
        foreach (var module in modules)
        {
            nameList.Add(module.Name);
        }
        return nameList;
    }

    private string GetScriptPathByName(string scriptName)
    {
        string[] guids = AssetDatabase.FindAssets("t:script");
        string scriptPath = string.Empty;
        foreach (var guid in guids)
        {
            scriptPath = AssetDatabase.GUIDToAssetPath(guid);
            var splits = scriptPath.Split('/');
            var scriptNameSuffix = splits[splits.Length - 1];//取得完整脚本名
            var scriptNameNotSuffix = scriptNameSuffix.Split('.')[0];//去掉后缀
            if (scriptNameNotSuffix == scriptName)
            {
                return scriptPath;
            }
        }
        throw new Exception("Couldn't Find This Script");
    }

    public void OutputLuaConfig()
    {
        var sb = new StringBuilder();

        sb.AppendLine("--本文件通过工具生成（自定义工具 / 摄像机 / UI 3D Camera Set）");
        sb.AppendLine();

        {//生成 MODEL_CAMERA_TYPE 部分的代码块
            sb.AppendLine("MODEL_CAMERA_TYPE = {");
            for (int i = 0; i < ui3DCameraConfig.sizeList.Count; i++)
            {
                sb.Append("\t");
                sb.Append(ui3DCameraConfig.sizeList[i].Name);
                sb.Append(" = ");
                sb.Append(i);
                sb.Append(",");
                sb.Append("\r\n");
            }
            sb.AppendLine("}");
        }//生成 MODEL_CAMERA_TYPE 部分的代码块

        {//生成 MODEL_CAMERA_SETTING 部分的代码块
            sb.AppendLine();
            sb.AppendLine("MODEL_CAMERA_SETTING = {");
            for (int i = 0; i < ui3DCameraConfig.sizeList.Count; i++)
            {
                sb.Append("\t");
                sb.Append("[MODEL_CAMERA_TYPE.");
                sb.Append(ui3DCameraConfig.sizeList[i].Name);
                sb.Append("] = {");
                sb.Append("\r\n");

                var moduleList = ui3DCameraConfig.sizeList[i].moduleList;
                for (int j = 0; j < moduleList.Count; j++)
                {
                    sb.Append("\t\t");
                    sb.Append("[\"");
                    sb.Append(moduleList[j].Name);
                    sb.Append("\"]");
                    sb.Append(" = {position = Vector3");
                    sb.Append(moduleList[j].Postion);
                    sb.Append(", rotation = Quaternion.Euler");
                    sb.Append(moduleList[j].EulerAngles);
//                     sb.Append(", fieldOfView = ");
//                     sb.Append(moduleList[j].FieldOfView);
                    sb.Append("},");
                    sb.Append("\r\n");
                }
                sb.Append("\t},\r\n");
            }
            sb.Append("}");
        }//生成 MODEL_CAMERA_SETTING 部分的代码块

        File.WriteAllText(luaPath, sb.ToString());
        EditorUtility.DisplayDialog("", "已导出Lua配置:Assets\\Game\\Lua\\gameui\\widgets\\role_model_camera_set.lua", "确定");
    }
}