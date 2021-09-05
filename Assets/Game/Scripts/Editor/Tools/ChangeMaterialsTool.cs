using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

public class ChangeMaterialsTool : EditorWindow
{
    private int _folderCount = 0;

    private List<Object> _folderList = new List<Object>();
    private List<string> _folderPathList = new List<string>();

    private HashSet<Material> _uiMaterialList = new HashSet<Material>();   //UI上使用的特效
    private HashSet<Material> _sceneMaterialList = new HashSet<Material>();

    private Object _sceneMaterialFolder;
    private Object _materialFolder;
    private Object _changeShaderFolder;
    private Object _checkMaterialFolder;

    private int _selectShaderIdx = 0;

    private readonly string _uiMaterialPath = "Assets/Game/Effects/UIMaterials";
    private readonly string _sceneMaterialPath = "Assets/Game/Effects/Prefab";
    private readonly string[] _shanderNames = { "Game/Particle" , "Game/UIParticle" };

    [MenuItem("自定义工具/设置场景或UI材质")]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(ChangeMaterialsTool), false, "设置场景或UI材质");
    }

    public void OnGUI()
    {
        if (GUILayout.Button("添加需要替换资源的路径"))
        {
            _folderCount++;
            _folderList.Add(null);
            _folderPathList.Add(string.Empty);
        }

        if (GUILayout.Button("删除需要替换资源的路径"))
        {
            if (_folderCount > 0)
            {
                _folderCount--;
                _folderList.RemoveAt(_folderCount);
                _folderPathList.RemoveAt(_folderCount);
            }
        }

        if (!Directory.Exists(_uiMaterialPath))
        {
            Directory.CreateDirectory(_uiMaterialPath);
        }

        for (int i = 0; i < _folderCount; i++)
        {
            _folderList[i] = EditorGUILayout.ObjectField("需要替换资源的路径", _folderList[i], typeof(Object), false);
            _folderPathList[i] = AssetDatabase.GetAssetPath(_folderList[i]);
        }

        GUILayout.Space(10);
        if (_sceneMaterialFolder == null)
        {
            var folder = AssetDatabase.LoadAssetAtPath<Object>(_sceneMaterialPath);
            _sceneMaterialFolder = EditorGUILayout.ObjectField("对比路径", folder, typeof(Object), false);
        }
        else
        {
            _sceneMaterialFolder = EditorGUILayout.ObjectField("对比路径", _sceneMaterialFolder, typeof(Object), false);
        }

        if (_materialFolder == null)
        {
            var folder = AssetDatabase.LoadAssetAtPath<Object>(_uiMaterialPath);
            _materialFolder = EditorGUILayout.ObjectField("保存新资源路径", folder, typeof(Object), false);
        }
        else
        {
            _materialFolder = EditorGUILayout.ObjectField("保存新资源路径", _materialFolder, typeof(Object), false);
        }



        if (GUILayout.Button("一键替换"))
        {
            if (_sceneMaterialFolder == null)
            {
                Debug.Log("缺少对比的路径");
                return;
            }

            if (_materialFolder == null)
            {
                Debug.Log("缺少保存文件的路径");
            }

            bool b = false;
            for (int i = 0; i < _folderList.Count; i++)
            {
                if (_folderList[i] != null)
                {
                    b = true;
                    break;
                }
            }

            if (_folderList.Count == 0 || b == false)
            {
                Debug.Log("缺少需替换资源的路径");
                return;
            }

            GetUIMaterils();
            GetSceneEffectList();
            CreateMaterial();
            ChangeUIMaterial();
        }

        GUILayout.Space(20);
        GUILayout.Label("----------替换UI使用材质使用的Shader----------");
        ChangeShader();

        GUILayout.Space(20);
        GUILayout.Label("----------检查Material的Cull Mode----------");
        CheckMaterialMode();
    }

    private void GetUIMaterils()
    {
        var foldStrs = new string[_folderList.Count];
        for (int i = 0; i < _folderList.Count; ++i)
        {
            foldStrs[i] = AssetDatabase.GetAssetPath(_folderList[i]);
        }
        int count = 0;
        var fileGuids = AssetDatabase.FindAssets("t:prefab", foldStrs);
        foreach (var guid in fileGuids)
        {
            var goPath = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(goPath);
            if (prefab != null)
            {
                GetChildTransform(prefab.transform, _uiMaterialList);
            }
            EditorUtility.DisplayProgressBar("检查UI材质", string.Format("{0}/{1} {2}", count, fileGuids.Length, goPath), (float)count / fileGuids.Length);
            count++;
        }
        EditorUtility.ClearProgressBar();
    }

    private void GetSceneEffectList()
    {
        var path = AssetDatabase.GetAssetPath(_sceneMaterialFolder);
        var guids = AssetDatabase.FindAssets("t:prefab", new string[] { path });
        int count = 0;
        string goPath = "";
        bool b = true;
        GameObject prefab = null;
        foreach (var guid in guids)
        {
            goPath = AssetDatabase.GUIDToAssetPath(guid);
            for (int i = 0; i < _folderPathList.Count; i++)
            {
                if (goPath.StartsWith(_folderPathList[i]))
                {
                    b = false;
                    break;
                }
            }

            if (b)
            {
                prefab = AssetDatabase.LoadAssetAtPath<GameObject>(goPath);
                if (prefab != null)
                {
                    GetChildTransform(prefab.transform, _sceneMaterialList);
                }
            }
            b = true;
            EditorUtility.DisplayProgressBar("检查场景材质", string.Format("{0}/{1} {2}", count, guids.Length, goPath), (float)count / guids.Length);
            count++;
        }

        EditorUtility.ClearProgressBar();
    }

    private void GetChildTransform(Transform transform, HashSet<Material> list)
    {
        var particles = transform.GetComponentsInChildren<UiParticles.UiParticles>();
        foreach (var particle in particles)
        {
            if (!list.Contains(particle.material))
            {
                list.Add(particle.material);
            }
        }

        var particleSystems = transform.GetComponentsInChildren<ParticleSystem>();
        foreach (var system in particleSystems)
        {
            var render = system.GetComponent<ParticleSystemRenderer>();
            if (render != null && render.sharedMaterial != null)
            {
                if (!list.Contains(render.sharedMaterial))
                {
                    list.Add(render.sharedMaterial);
                }
            }
        }
    }

    //如果该材质在UI中也有使用的话则创建一个Material
    private void CreateMaterial()
    {
        var path = "";
        Material material = null;
        var shader = Shader.Find("Game/UIParticle");
        foreach (var m in _sceneMaterialList)
        {
            if (_uiMaterialList.Contains(m))
            {
                path = Path.Combine(_uiMaterialPath, "UI" + m.name + ".mat");
                if (!File.Exists(path))
                {
                    material = new Material(m);
                    material.shader = shader;
                    AssetDatabase.CreateAsset(material, path);
                }
            }
        }
    }

    private void ChangeUIMaterial()
    {
        var folders = new string[_folderList.Count];
        for (int i = 0; i < _folderList.Count; i++)
        {
            folders[i] = AssetDatabase.GetAssetPath(_folderList[i]);
        }

        var guids = AssetDatabase.FindAssets("t:prefab", folders);
        int count = 0;
        string goPath = "";
        GameObject prefab = null;
        var shader = Shader.Find("Game/UIParticle");
        foreach (var guid in guids)
        {
            goPath = AssetDatabase.GUIDToAssetPath(guid);
            prefab = AssetDatabase.LoadAssetAtPath<GameObject>(goPath);
            if (prefab != null)
            {
                ChangeUIMaterials(prefab, shader);
            }
            EditorUtility.DisplayProgressBar("替换UI材质", string.Format("{0}/{1} {2}", count, guids.Length, goPath), (float)count / guids.Length);
            count++;
        }
        EditorUtility.ClearProgressBar();
    }

    private void ChangeUIMaterials(GameObject obj, Shader shader)
    {
        var particles = obj.transform.GetComponentsInChildren<UiParticles.UiParticles>();
        foreach (var particle in particles)
        {
            if (_sceneMaterialList.Contains(particle.material))
            {
                var asset = AssetDatabase.LoadAssetAtPath<Material>(string.Format("{0}/{1}.mat",
                    _uiMaterialPath, string.Format("UI{0}", particle.material.name)));
                particle.material = asset;
                particle.material.shader = shader;
            }
            else
            {
                particle.material.shader = shader;
            }
        }

        Material material = null;
        string path = "";
        var particleSystems = obj.transform.GetComponentsInChildren<ParticleSystem>();
        foreach (var system in particleSystems)
        {
            var render = system.GetComponent<ParticleSystemRenderer>();
            if (render != null && render.sharedMaterial != null)
            {
                material = render.sharedMaterial;
                if (_sceneMaterialList.Contains(render.sharedMaterial))
                {
                    path = string.Format("{0}/{1}.mat", _uiMaterialPath, string.Format("UI{0}", material.name));
                    render.sharedMaterial = AssetDatabase.LoadAssetAtPath<Material>(path);
                    render.sharedMaterial.shader = shader;
                }
                else
                {
                    render.sharedMaterial.shader = shader;
                }
            }
        }

        var newprefab = GameObject.Instantiate(obj);
        PrefabUtility.ReplacePrefab(newprefab, obj, ReplacePrefabOptions.ConnectToPrefab);
        GameObject.DestroyImmediate(newprefab);
    }

    #region ChangeUIMaterialShader
    private void ChangeShader()
    {
        _changeShaderFolder = EditorGUILayout.ObjectField("需要替换shader的路径", _changeShaderFolder, typeof(Object), false);
        if (_changeShaderFolder != null)
        {
            _selectShaderIdx = EditorGUILayout.Popup("选择shander", _selectShaderIdx, _shanderNames);
            if (GUILayout.Button("替换UI使用材质的Shader"))
            {
                var shader = Shader.Find(_shanderNames[_selectShaderIdx]);
                if (shader == null)
                {
                    Debug.LogError(string.Format("找不到要替换的{0},请检查", _shanderNames[_selectShaderIdx]));
                    return;
                }

                var path = AssetDatabase.GetAssetPath(_changeShaderFolder);
                var guids = AssetDatabase.FindAssets("t:prefab", new string[] { path });

                foreach (var guid in guids)
                {
                    var goPath = AssetDatabase.GUIDToAssetPath(guid);
                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(goPath);
                    if (prefab != null)
                    {
                        ChangeUIMaterialShader(prefab, shader);
                    }
                }
            }
        }
    }

    private void ChangeUIMaterialShader(GameObject obj, Shader shader)
    {
        var particles = obj.transform.GetComponentsInChildren<UiParticles.UiParticles>();
        foreach (var particle in particles)
        {
            particle.material.shader = shader;
        }

        var particleSystems = obj.transform.GetComponentsInChildren<ParticleSystem>();
        foreach (var particle in particleSystems)
        {
            var render = particle.GetComponent<ParticleSystemRenderer>();
            if (render != null && render.sharedMaterial != null)
            {
                render.sharedMaterial.shader = shader;
            }
        }

        var newprefab = GameObject.Instantiate(obj);
        PrefabUtility.ReplacePrefab(newprefab, obj, ReplacePrefabOptions.ConnectToPrefab);
        GameObject.DestroyImmediate(newprefab);
    }
    #endregion


    #region 模型的Cull Mode
    private void CheckMaterialMode()
    {
        _checkMaterialFolder = EditorGUILayout.ObjectField(_checkMaterialFolder, typeof(Object), false);
        if (GUILayout.Button("Check Material"))
        {
            if (null == _checkMaterialFolder) { return; }

            if (_checkMaterialFolder.GetType().ToString() == "UnityEditor.DefaultAsset")
            {
                string folderPath = AssetDatabase.GetAssetPath(_checkMaterialFolder);
                string[] guids = AssetDatabase.FindAssets("t:material", new string[] { folderPath });
                foreach (string guid in guids)
                {
                    string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                    Material material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                    SetMaterialCullMode(material);
                }
            }
            else
            {
                SetMaterialCullMode(_checkMaterialFolder as Material);
            }
        }
        AssetDatabase.SaveAssets();
    }

    private void SetMaterialCullMode(Material material)
    {
        float cullMode = material.GetFloat("_CullMode");
        float renderMode = material.GetFloat("_RenderingMode");
        if (cullMode == (float)CullMode.Off && renderMode == 0)
        {
            material.SetFloat("_CullMode", (float)CullMode.Back);
        }
    }
    #endregion
}
