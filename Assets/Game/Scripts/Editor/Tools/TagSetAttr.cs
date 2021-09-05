using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

public class TagSetAttr : EditorWindow {


    [MenuItem("自定义工具/美术专用/场景编辑")]
    private static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(TagSetAttr), false, "场景编辑");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(150, 200);
    }

    private int chooseTag = 0;
    private bool isStaticBathcing = true;
    private bool receiveShadows = false;
    private bool castShadows = false;
    private bool isAddMesh = false;
    private Color boxColliderColor = Color.black;
    private Object setObject;
    private Object sceneObject;
    private Object sceneLightObject;
    private List<NoBakedLight> noBackLights = new List<NoBakedLight>();
    private Vector2 scrollPos;

    private class NoBakedLight
    {
        public Scene LightInScene;
        public GameObject LightObj;
    }

    private void OnGUI()
    {
        if(GUILayout.Button("设置当前场景的静态批属性"))
        {
            SetMapStaticBatchingAttr();
        }

        EditorGUILayout.BeginHorizontal();
        receiveShadows = EditorGUILayout.Toggle("Receive Shadow: ", receiveShadows);
        if (GUILayout.Button("设置当前场景的Receive Shadows属性"))
        {
            SetCurrMapShadowAttr();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        castShadows = EditorGUILayout.Toggle("CastShadows: ", castShadows);
        if (GUILayout.Button("设置Cast Shadows"))
        {
            SetCurrMapCastShadowAttr();
        }
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(15);
        EditorGUILayout.BeginHorizontal();
        boxColliderColor = EditorGUILayout.ColorField(boxColliderColor);
        if (GUILayout.Button("设置颜色"))
        {
            SetBoxColliderColor();
        }
        if (GUILayout.Button("添加BoxCollider颜色"))
        {
            AddBoxColliderColor();
        }
        if (GUILayout.Button("删除脚本"))
        {
            DeleteDrawColorScript();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("添加Mesh"))
        {
            AddMeshComponent();
        }
        if (GUILayout.Button("删除脚本"))
        {
            DeleteDrawColorScript();
        }
        EditorGUILayout.EndHorizontal();
    }

    private void SetMapStaticBatchingAttr()
    {
        GameObject normal = GameObject.Find("Normal");
        if (null != normal)
        {
            normal.tag = "Untagged";
            GameObjectUtility.SetStaticEditorFlags(normal, ~StaticEditorFlags.BatchingStatic);

            Transform[] normalObjs = normal.GetComponentsInChildren<Transform>();
            foreach (Transform obj in normalObjs)
            {
                GameObjectUtility.SetStaticEditorFlags(obj.gameObject, ~StaticEditorFlags.BatchingStatic);
            }

            this.SetModelReadable(normal, false);
        }

        GameObject staticBatching = GameObject.Find("BatchingStatic");
        if (null != staticBatching)
        {
            staticBatching.tag = "StaticBatching";
            GameObjectUtility.SetStaticEditorFlags(staticBatching, ~StaticEditorFlags.BatchingStatic);

            Transform[] batchObjs = staticBatching.GetComponentsInChildren<Transform>();
            foreach (Transform obj in batchObjs)
            {
                GameObjectUtility.SetStaticEditorFlags(obj.gameObject, ~StaticEditorFlags.BatchingStatic);
            }

            this.SetModelReadable(staticBatching, true);
        }

        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
    }

    private void SetModelReadable(GameObject rootObj, bool isReadable)
    {
        MeshFilter[] meshFilters = rootObj.GetComponentsInChildren<MeshFilter>();

        string sceneName = SceneManager.GetActiveScene().name;
        int last_index = sceneName.LastIndexOf("_Main");
        if (last_index <= 0)
        {
            Debug.LogErrorFormat("场景名字不符合规范，要以_Main结尾");
            return;
        }

        sceneName = sceneName.Substring(0, last_index);
        HashSet<string> hashSet = new HashSet<string>();
        for (int i = 0; i < meshFilters.Length; i++)
        {
            if (null == meshFilters[i].sharedMesh)
            {
                Debug.LogFormat("没有指定网格： {0}", meshFilters[i].gameObject.name);
                continue;
            }
            string modelPath = AssetDatabase.GetAssetPath(meshFilters[i].sharedMesh.GetInstanceID());
            if (string.IsNullOrEmpty(modelPath))
            {
                Debug.LogFormat("没有找到对应的模型： {0}", meshFilters[i].sharedMesh.name);
                continue;
            }

            if (hashSet.Contains(modelPath))
            {
                continue;
            }

            hashSet.Add(modelPath);
            ModelImporter modelImporter = AssetImporter.GetAtPath(modelPath) as ModelImporter;
            if (modelImporter.isReadable != isReadable)
            {
                ImporterUtils.SetLabel(modelPath, ImporterUtils.ReadableLabel);
                modelImporter.isReadable = isReadable;
                modelImporter.SaveAndReimport();
            }
        }
    }

    private void SetCurrMapShadowAttr()
    {
        GameObject normal = GameObject.Find("Models");
        MeshRenderer[] Objs = normal.GetComponentsInChildren<MeshRenderer>();
        foreach(MeshRenderer Obj in Objs)
        {

            MeshRenderer meshRenderer = Obj.GetComponent<MeshRenderer>();
            if (meshRenderer.tag == "Shadow tag" || receiveShadows)
            {
                meshRenderer.receiveShadows = true;
            }
            else
            {
                meshRenderer.receiveShadows = false;
            }
        }
        EditorSceneManager.MarkAllScenesDirty();
        EditorSceneManager.SaveOpenScenes();
    }

    private void SetCurrMapCastShadowAttr()
    {
        GameObject normal = GameObject.Find("Models");
        MeshRenderer[] Objs = normal.GetComponentsInChildren<MeshRenderer>();
        foreach (MeshRenderer Obj in Objs)
        {
            MeshRenderer meshRenderer = Obj.GetComponent<MeshRenderer>();
            if (castShadows)
            {
                meshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            }
            else
            {
                meshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            }
        }
        EditorSceneManager.MarkAllScenesDirty();
        EditorSceneManager.SaveOpenScenes();
    }

    private void SetBoxColliderColor()
    {
        DrawColorBoxColider[] Objs = GameObject.FindObjectsOfType<DrawColorBoxColider>();
        foreach(DrawColorBoxColider obj in Objs)
        {
            obj.Color = boxColliderColor;
        }
    }

    private void AddBoxColliderColor()
    {
        Transform[] Objs = GameObject.FindObjectsOfType<Transform>();
        foreach(Transform obj in Objs)
        {
            if(obj.name.Contains("Cube"))
            {
                MeshFilter meshFilter = obj.gameObject.GetComponent<MeshFilter>();
                MeshRenderer meshRenderer = obj.gameObject.GetComponent<MeshRenderer>();
                if (null != meshFilter)
                {
                    DestroyImmediate(meshFilter);
                }
                if (null != meshRenderer)
                {
                    DestroyImmediate(meshRenderer);
                }
                obj.gameObject.AddComponent<DrawColorBoxColider>();
            }
        }
        EditorSceneManager.MarkAllScenesDirty();
        EditorSceneManager.SaveOpenScenes();
    }

    private void DeleteDrawColorScript()
    {
        Transform[] Objs = GameObject.FindObjectsOfType<Transform>();
        foreach (Transform obj in Objs)
        {
            if (obj.name.Contains("Cube"))
            {
                MeshFilter meshFilter = obj.gameObject.GetComponent<MeshFilter>();
                MeshRenderer meshRenderer = obj.gameObject.GetComponent<MeshRenderer>();
                DrawColorBoxColider drawColorBoxColider = obj.gameObject.GetComponent<DrawColorBoxColider>();
                if (null != meshFilter)
                {
                    DestroyImmediate(meshFilter);
                }
                if (null != meshRenderer)
                {
                    DestroyImmediate(meshRenderer);
                }
                if (null != drawColorBoxColider)
                {
                    DestroyImmediate(drawColorBoxColider);
                }
            }
        }
        EditorSceneManager.MarkAllScenesDirty();
        EditorSceneManager.SaveOpenScenes();
    }

    private void AddMeshComponent()
    {
        Transform[] Objs = GameObject.FindObjectsOfType<Transform>();
        GameObject tempCube = GameObject.CreatePrimitive(PrimitiveType.Cube);

        foreach (Transform obj in Objs)
        {
            if (obj.name.Contains("Cube"))
            {
                MeshFilter meshFilter = obj.gameObject.GetComponent<MeshFilter>();
                MeshRenderer meshRenderer = obj.gameObject.GetComponent<MeshRenderer>();
                if (null == meshFilter)
                {
                    MeshFilter tempMeshFilter = obj.gameObject.AddComponent<MeshFilter>();
                    tempMeshFilter.sharedMesh = tempCube.GetComponent<MeshFilter>().sharedMesh;
                }
                if (null == meshRenderer)
                {
                    MeshRenderer tempMeshRenderer = obj.gameObject.AddComponent<MeshRenderer>();
                    tempMeshRenderer.sharedMaterial = tempCube.GetComponent<MeshRenderer>().sharedMaterial;
                }
            }
        }
        DestroyImmediate(tempCube);
        EditorSceneManager.MarkAllScenesDirty();
        EditorSceneManager.SaveOpenScenes();
    }

    private void SetMapShadowAttr(GameObject obj)
    {
        MeshRenderer meshRenderer = obj.GetComponent<MeshRenderer>();
        if(null == meshRenderer) { return; }

        if(obj.tag == "Shadow tag")
        {
            meshRenderer.receiveShadows = true;
        }
        else
        {
            meshRenderer.receiveShadows = false;
        }
        
    }
    
    private string[] _GetFiles(string path, bool recursive = true)
    {
        List<string> withExtensions = new List<string>() { ".prefab" };

        var resultList = new List<string>();
        string[] files = Directory.GetFiles(path, "*.*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);

        foreach (var strPath in files)
        {
            if (withExtensions.Contains(Path.GetExtension(strPath).ToLower()))
            {
                resultList.Add(strPath.Replace('\\', '/'));
            }
        }
        return resultList.ToArray();
    }
}
