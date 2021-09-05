using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Game;
using System.IO;
using Nirvana;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

public class GetAssetResource : EditorWindow
{

    [MenuItem("自定义工具/技术专用/保存AssetBundle")]
    private static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(GetAssetResource), false, "保存资源路径和名称");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(150, 200);
    }

    struct AssetCarry
    {
        public string name;
        public string prafabPath;
        public string assetNmae;
        public string bundleName;
    }
    List<AssetCarry> SaveCarry = new List<AssetCarry>();

    private Object Field;
    private string[] checkPath = { "Assets/Game/UIs" };

    private string fontFilePath = "F:/game/SvarText.txt";

    private void OnGUI()
    {
        Field = EditorGUILayout.ObjectField(Field, typeof(Object), false);
        if(GUILayout.Button("查找保存预制体"))
        {
            this.CheckPrefab();
        }

        if (GUILayout.Button("读取预制体修改保存"))
        {
            this.ModifyAttachPrefab();
        }

        if (GUILayout.Button("查找保存场景"))
        {
            this.CheckScenePrefab();
        }

        if (GUILayout.Button("读取场景修改保存"))
        {
            this.ModifyAttachScenes();
        }
    }

    private void CheckPrefab()
    {

        SaveCarry.Clear();
        //string[] Guids = AssetDatabase.FindAssets("t:Prefab", new string[] checkPath);
        string fieldPath = AssetDatabase.GetAssetPath(Field);
        string[] Guids = AssetDatabase.FindAssets("t:Prefab", new string[] { fieldPath });
        foreach (string guid in Guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
            var attachComponents = go.GetComponentsInChildren<GameObjectAttach>(true);
            foreach (var component in attachComponents)
            {
                AssetCarry componet;
                componet.name = component.name;
                componet.prafabPath = assetPath;
                componet.assetNmae = component.AssetName;
                componet.bundleName = component.BundleName;
                SaveCarry.Add(componet);
            }
        }

        if (!File.Exists(fontFilePath))
        {
            File.Create(fontFilePath).Dispose();
        }
        string saveText = "";
        foreach (AssetCarry carry in SaveCarry)
        {
            saveText = saveText + carry.prafabPath + "|" + carry.name + "|" + carry.assetNmae + "|" + carry.bundleName + "\r\n";
        }
        File.WriteAllText(fontFilePath, saveText);
    }

    private void CheckScenePrefab()
    {

        SaveCarry.Clear();
        //string[] Guids = AssetDatabase.FindAssets("t:Prefab", new string[] checkPath);
        string fieldPath = AssetDatabase.GetAssetPath(Field);
        string[] Guids = AssetDatabase.FindAssets("t:Scene", new string[] { fieldPath });
        foreach (string guid in Guids)
        {
            string scenePath = AssetDatabase.GUIDToAssetPath(guid);
            Scene scene = EditorSceneManager.OpenScene(scenePath);
            if (scene.name.EndsWith("_Main"))
            {
                GameObject[] gos = (GameObject[])FindObjectsOfType(typeof(GameObject));
                foreach (var go in gos)
                {
                    var component = go.GetComponent<GameObjectAttach>();
                    if (component != null)
                    {
                        AssetCarry componet;
                        componet.name = component.name;
                        componet.prafabPath = scenePath;
                        componet.assetNmae = component.AssetName;
                        componet.bundleName = component.BundleName;
                        SaveCarry.Add(componet);
                    }
                }
            }
        }

        if (!File.Exists(fontFilePath))
        {
            File.Create(fontFilePath).Dispose();
        }
        string saveText = "";
        foreach (AssetCarry carry in SaveCarry)
        {
            saveText = saveText + carry.prafabPath + "|" + carry.name + "|" + carry.assetNmae + "|" + carry.bundleName + "\r\n";
        }
        File.WriteAllText(fontFilePath, saveText);
    }

    private void ModifyAttachPrefab()
    {
        if (!File.Exists(fontFilePath))
        {
            return;
        }

        string read_text = File.ReadAllText(fontFilePath);
        string[] str_array = read_text.Split(new string[] { "\r\n" }, System.StringSplitOptions.None);


        foreach (var str in str_array)
        {
            if (str == "" || str == null) { break; }
            string[] componet_array = str.Split('|');
            string asset_path = componet_array[0];
            string obj_name = componet_array[1];
            string asset_name = componet_array[2];
            string bundle_name = componet_array[3];

            if (asset_path == "" || asset_name == "" || bundle_name == "") { break; }

            GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(asset_path);
            var attachComponents = go.GetComponentsInChildren<GameObjectAttach>(true);
            bool isSucc = false;
            foreach (var component in attachComponents)
            {
                if (component.name == obj_name && component.AssetName == asset_name && component.BundleName == bundle_name)
                {
                    //self = component;
                    var asset = EditorResourceMgr.LoadGameObject(bundle_name, asset_name);
                    if (asset != null)
                    {
                        AssetID asset_id;
                        asset_id.BundleName = bundle_name;
                        asset_id.AssetName = asset_name;
                        string load_asset_path = AssetDatabase.GetAssetPath(asset);
                        asset_id.AssetGUID = AssetDatabase.AssetPathToGUID(load_asset_path);
                        component.Asset = asset_id;
                        isSucc = true;
                        //EditorUtility.SetDirty(component);
                    }
                }
            }

            if (isSucc)
            {
                PrefabUtility.ResetToPrefabState(go);
                PrefabUtility.SetPropertyModifications(go, new PropertyModification[] { });
            }
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }



    private void ModifyAttachScenes()
    {
        if (!File.Exists(fontFilePath))
        {
            return;
        }

        string read_text = File.ReadAllText(fontFilePath);
        string[] str_array = read_text.Split(new string[] { "\r\n" }, System.StringSplitOptions.None);

        foreach (var str in str_array)
        {
            if (str == "" || str == null) { break; }
            string[] componet_array = str.Split('|');
            string scene_path = componet_array[0];
            string obj_name = componet_array[1];
            string asset_name = componet_array[2];
            string bundle_name = componet_array[3];

            if (scene_path == "" || asset_name == "" || bundle_name == "") { break; }

            bool isSucc = false;
            Scene scene = EditorSceneManager.OpenScene(scene_path);
            GameObject[] gos = (GameObject[])FindObjectsOfType(typeof(GameObject));
            foreach (var go in gos)
            {
                var component = go.GetComponent<GameObjectAttach>();
                if (component != null && component.name == obj_name && component.AssetName == asset_name && component.BundleName == bundle_name)
                {
                    var asset = EditorResourceMgr.LoadGameObject(bundle_name, asset_name);
                    if (asset != null)
                    {
                        AssetID asset_id;
                        asset_id.BundleName = bundle_name;
                        asset_id.AssetName = asset_name;
                        string load_asset_path = AssetDatabase.GetAssetPath(asset);
                        asset_id.AssetGUID = AssetDatabase.AssetPathToGUID(load_asset_path);
                        component.Asset = asset_id;
                        isSucc = true;
                    }
                }
            }

            if (isSucc)
            {
                EditorSceneManager.MarkAllScenesDirty();
                EditorSceneManager.SaveOpenScenes();
            }
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
