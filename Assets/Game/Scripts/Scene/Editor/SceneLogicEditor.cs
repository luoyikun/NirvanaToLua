//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.IO;
using Nirvana.Editor;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using System;
using System.Diagnostics;

/// <summary>
/// The editor for <see cref="SceneLogic"/>
/// </summary>
[CustomEditor(typeof(SceneLogic))]
public class SceneLogicEditor : Editor
{
    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        if (SceneGridEditor.IsPainting)
        {
            return;
        }

        this.DrawDefaultInspector();

        var logic = this.target as SceneLogic;
        if (logic.gameObject.tag != "EditorOnly")
        {
            logic.gameObject.tag = "EditorOnly";
        }

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Create NPC"))
        {
            this.CreateNPC(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        if (GUILayout.Button("Create Monster"))
        {
            this.CreateMonster(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Create Door"))
        {
            this.CreateDoor(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        if (GUILayout.Button("Create Gather"))
        {
            this.CreateGather(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Create JumpPoint"))
        {
            this.CreateJumpPoint(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        if (GUILayout.Button("Create ScenePoint"))
        {
            this.CreateScenePoint(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

//         if (GUILayout.Button("Create Fence"))
//         {
//             this.CreateFence(logic);
//             EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
//         }

        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Create Effect"))
        {
            this.CreateEffect(logic);
            EditorSceneManager.MarkSceneDirty(logic.gameObject.scene);
        }

        GUILayout.EndHorizontal();

        EditorGUILayout.Space();
        if (GUILayout.Button("Save Scene Lua"))
        {
            this.SaveSceneLua(logic);
        }

        if (GUILayout.Button("Save Scene XML"))
        {
            this.SaveSceneXML(logic);
        }

        if (GUILayout.Button("Save Map XML"))
        {
            this.SaveMapXML(logic);
        }

        if (GUILayout.Button("Flush SceneManager XML"))
        {
            this.SaveSceneManagerXML(logic);
        }

        if (GUILayout.Button("Flush ConfigMap Lua"))
        {
            this.SaveConfigMapLua(logic);
        }

        if (GUILayout.Button("Save Scene Robot"))
        {
            this.SaveSceneRobotLua(logic);
        }

        if (GUILayout.Button("Save Scene Point"))
        {
            this.SaveScenePointsTxt(logic);
        }
    }

    private void CreateNPC(SceneLogic logic)
    {
        var go = new GameObject("NPC", typeof(SceneNPC));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Blue);
        this.PlaceObject(go);
    }

    private void CreateMonster(SceneLogic logic)
    {
        var go = new GameObject("Monster", typeof(SceneMonsterPoint));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Red);
        this.PlaceObject(go);
    }

    private void CreateDoor(SceneLogic logic)
    {
        var go = new GameObject("Door", typeof(SceneDoor));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Orange);
        this.PlaceObject(go);
    }

    private void CreateGather(SceneLogic logic)
    {
        var go = new GameObject("Gather", typeof(SceneGatherPoint));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Gray);
        this.PlaceObject(go);
    }

    private void CreateJumpPoint(SceneLogic logic)
    {
        var go = new GameObject("JumpPoint", typeof(SceneJumpPoint));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Teal);
        this.PlaceObject(go);
    }

    private void CreateScenePoint(SceneLogic logic)
    {
        Transform transform = logic.transform.Find("ScenePoints");
        if (null == transform)
        {
            var scene_points_go = new GameObject("ScenePoints");
            transform = scene_points_go.transform;
            transform.SetParent(logic.transform, false);
        }

        var go = new GameObject("ScenePoint", typeof(ScenePoint));
        go.transform.SetParent(transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Yellow);
        this.PlaceObject(go);
    }

    private void CreateFence(SceneLogic logic)
    {
        var go = new GameObject("Fence", typeof(SceneFence));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Yellow);
        this.PlaceObject(go);
    }

    private void CreateEffect(SceneLogic logic)
    {
        var go = new GameObject("Effect", typeof(SceneEffect));
        go.transform.SetParent(logic.transform, false);
        go.SendMessage("OnValidate");
        IconManager.SetIcon(go, IconManager.LabelIcon.Purple);
        this.PlaceObject(go);
    }

    private void PlaceObject(GameObject go)
    {
        //Selection.activeObject = go;
        var camera = SceneView.lastActiveSceneView.camera;
        var ray = new Ray(camera.transform.position, camera.transform.forward);
        var hits = Physics.RaycastAll(ray, Mathf.Infinity);
        if (hits.Length > 0)
        {
            go.transform.position = hits[0].point;
        }
    }

    private void SaveSceneLua(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/Game/Lua/config/scenes/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            "scene_" + logic.SceneID.ToString(),
            "lua");
        if (!string.IsNullOrEmpty(filePath))
        {
            if (!logic.SaveSceneLua(filePath, true))
            {
                WindowsMessageBox.MessageBox(IntPtr.Zero, "请检查场景", "非法操作", 0);
            }
        }
    }

    private void SaveSceneRobotLua(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/../Robot/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            "scene_" + logic.SceneID.ToString(),
            "lua");
        if (!string.IsNullOrEmpty(filePath))
        {
            logic.SaveSceneLua(filePath, false);
        }
    }

   private void SaveScenePointsTxt(SceneLogic logic)
    {
        Transform points_transform = logic.transform.Find("ScenePoints");
        if (null == points_transform)
        {
            return;
        }

        ScenePoint[] points = points_transform.GetComponentsInChildren<ScenePoint>();
        string[] lines = new string[points.Length];
        for (int i = 0; i < points.Length; i++)
        {
            Vector3 pos = points[i].transform.position;
            int x = 0;
            int y = 0;
            logic.TransformWorldToLogic(pos, out x, out y);
            lines[i] = string.Format("{0},{1}", x, y);
        }

        string path = Path.Combine(Application.dataPath, "../Temp/ScenePoints.txt");
        File.WriteAllLines(path, lines);
        Process Pnotepad = new Process();
        Pnotepad.StartInfo.FileName = path;
        Pnotepad.Start();
    }

    private void SaveSceneXML(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/../Config/Scene/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            logic.SceneID.ToString(),
            "xml");
        if (!string.IsNullOrEmpty(filePath))
        {
            logic.SaveSceneXML(filePath);
        }
    }

    private void SaveMapXML(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/../Config/Map/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            logic.SceneID.ToString(),
            "xml");
        if (!string.IsNullOrEmpty(filePath))
        {
            logic.SaveMapXML(filePath);
        }
    }

    private void SaveSceneManagerXML(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/../Config/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            "scenemanager",
            "xml");
        if (!string.IsNullOrEmpty(filePath))
        {
            logic.SaveSceneManagerXML(filePath);
        }
    }

    private void SaveConfigMapLua(SceneLogic logic)
    {
        var defaultPath = Application.dataPath + "/../Assets/Game/Lua/config/";
        defaultPath = Path.GetFullPath(defaultPath);
        if (!Directory.Exists(defaultPath))
        {
            Directory.CreateDirectory(defaultPath);
        }

        var filePath = EditorUtility.SaveFilePanel(
            "Save File...",
            defaultPath,
            "config_map",
            "lua");
        if (!string.IsNullOrEmpty(filePath))
        {
            var dirpath = Application.dataPath + "/../Config/";
            logic.SaveConfigMapLua(filePath, dirpath);
        }
    }
}
