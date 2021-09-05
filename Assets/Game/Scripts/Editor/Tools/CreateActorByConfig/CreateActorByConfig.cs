using System;
using System.Collections.Generic;
using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class CreateActorByConfig : EditorWindow
{
    [MenuItem("自定义工具/资源导入工具/资源导入工具 2018.8 &Q")]
    public static void ShowWindow()
    {
        EditorWindow window = GetWindow(typeof(CreateActorByConfig), false, "资源导入工具");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(150, 200);
        window.Show();
    }

    private Dictionary<string, ActorCreater> actorCreaterDict = new Dictionary<string, ActorCreater>();
    private Object modelFolder;
    private Object modelFBX;
    void Awake()
    {
        actorCreaterDict["BaoJu"] = new BaoJuCreater();
        actorCreaterDict["FightMount"] = new FightMountCreater();
        actorCreaterDict["Hunqi"] = new HunqiCreater();
        actorCreaterDict["Huoban"] = new HuobanCreater();
        actorCreaterDict["Monster"] = new MonsterCreater();
        actorCreaterDict["Mount"] = new MountCreater();
        actorCreaterDict["NPC"] = new NPCCreater();
        actorCreaterDict["PiFeng"] = new PiFengCreater();
        actorCreaterDict["Role"] = new RoleCreater();
        actorCreaterDict["Spirit"] = new SpiritCreater();
        actorCreaterDict["Wing"] = new WingCreater();
        actorCreaterDict["Shengqi"] = new ShengQiCreater();
        actorCreaterDict["Gather"] = new GatherCreater();
        actorCreaterDict["Mingjiang"] = new MingjiangCreater();

        SelectFolderHelp();
    }

    void OnGUI()
    {
        modelFolder = EditorGUILayout.ObjectField("生成资源的文件夹: ", modelFolder, typeof(Object), true);
        
        if (modelFolder == null)
        {
            return;
        }

        EditorGUILayout.Space();

        if (GUILayout.Button("生成预制体"))
        {
            var stt = Selection.activeObject.ToString();
            if (stt.Contains("Title"))
            {
                CreateTitlePrefab();
                return;
            }

            AddSufFBXName();

            var modelFolderPath = AssetDatabase.GetAssetPath(modelFolder);
            var dir = new DirectoryInfo(modelFolderPath);

            ActorCreater actorCreater;
            if (actorCreaterDict.ContainsKey(dir.Parent.Name))
            {
                actorCreater = actorCreaterDict[dir.Parent.Name];
            }
            else//Role的层级结构比较特殊，加一个处理
            {
                try
                {
                    actorCreater = actorCreaterDict[dir.Parent.Parent.Name];
                }
                catch (Exception e)
                {
                    EditorUtility.DisplayDialog("", "选中的模型没有对应的处理类，请选择正确的模型，或通知程序扩展类", "");
                    return;
                }
            }

            var savePrefabPath = string.Empty;
            var modelPrefab = actorCreater.CreatePrefab(dir, out savePrefabPath);

            var modelAnimator = modelPrefab.GetOrAddComponent<Animator>();
            var createController = actorCreater.CreateAnimatorOverrideController(dir);
            modelAnimator.runtimeAnimatorController = createController;

            actorCreater.AddComponentsByConfig(modelPrefab);
            string[] checkDirs = { dir.ToString() };
            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
                var modelRenderer = modelPrefab.GetComponentInChildren<SkinnedMeshRenderer>();
                modelRenderer.sharedMaterial = material;
            }

            PrefabUtility.CreatePrefab(savePrefabPath, modelPrefab);
            DestroyImmediate(modelPrefab);
            this.Close();
        }
    }

    private void CreateTitlePrefab()
    {
        var modelFolderPath = AssetDatabase.GetAssetPath(modelFolder);
        var dir = new DirectoryInfo(modelFolderPath);

        var title_m = EditorResourceMgr.LoadGameObject("effects/prefab/title_prefab", "Title_1001.prefab");
        GameObject mPrefab = Instantiate(title_m);

        var selectobj = Selection.activeObject;
        mPrefab.name = selectobj.name;

        var img = mPrefab.GetComponentInChildren<UnityEngine.UI.Image>(true);
        var img_path = AssetDatabase.GetAssetPath(selectobj);
        Sprite new_sprite = AssetDatabase.LoadAssetAtPath<Sprite>(img_path);
        img.sprite = new_sprite;

        var eff_path = AssetDatabase.GetAssetPath(title_m);
        var folderPath = Directory.GetParent(eff_path).FullName;
        folderPath = Path.Combine(folderPath, selectobj.name + ".prefab");
        var safeFolderPath = folderPath.Replace("\\", "/");
        int index = safeFolderPath.IndexOf("Assets/");
        safeFolderPath = safeFolderPath.Substring(index);

        PrefabUtility.CreatePrefab(safeFolderPath, mPrefab);
        DestroyImmediate(mPrefab);
        this.Close();
    }

    private void SelectFolderHelp()
    {
        modelFBX = Selection.activeObject;
        
        var modelFBXPath = AssetDatabase.GetAssetPath(modelFBX);
        var folderPath = Directory.GetParent(modelFBXPath).FullName;
        var safeFolderPath = folderPath.Replace("\\", "/");
        int index = safeFolderPath.IndexOf("Assets/");
        safeFolderPath = safeFolderPath.Substring(index);
        modelFolder = AssetDatabase.LoadAssetAtPath<Object>(safeFolderPath);
    }

    private void AddSufFBXName()
    {
        var obj = Selection.activeObject;
        var sufName = modelFolder.name;
        if (sufName.Contains("_model"))
        {
            return;
        }
        else
        {
            sufName = sufName + "_model.FBX";
        }
        var assetPath = AssetDatabase.GetAssetPath(obj);
        var dirPath = Directory.GetParent(assetPath);
        var fbxFile = new FileInfo(assetPath);
        var destFileName = dirPath + "/" + sufName;
        fbxFile.MoveTo(destFileName);
        AssetDatabase.Refresh();
    }
}