using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Nirvana;

public class CheckCollider : EditorWindow
{
    [MenuItem("自定义工具/检测碰撞体")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(CheckCollider), false, "检测胶囊体");
    }

    private UnityEngine.Object OnCheckFolder;               //检测模型文件夹目录
    private UnityEngine.Object OnCheckRoleFolder;           //检测角色文件夹目录
    private UnityEngine.Object OnCheckMonsterFolder;        //检测怪物文件夹目录
    private UnityEngine.Object OnCheckMingjiangFolder;      //检测名将文件夹目录
    private UnityEngine.Object OnCheckGatherFolder;         //检测采集物文件夹目录
    private UnityEngine.Object OnCheckNpcFolder;            //检测NPC文件夹目录

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

    // 增加rigidbody 删除多余的collider
    private void ChangeHandler(UnityEngine.Object OnCheckFolder)
    {
        if (!OnCheckFolder)
        {
            Debug.LogError("文件夹获取错误，请检查!");
            return;
        }
        string strCheckFolderPath = AssetDatabase.GetAssetPath(OnCheckFolder);
        string[] lsFiles = _GetFiles(strCheckFolderPath);
        foreach (var path in lsFiles)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                var colliders = prefab.transform.GetComponentsInChildren<Collider>(true);
                foreach (var collider in colliders)
                {
                    var m_collider = collider.GetComponent<Collider>();
                    var clickable = collider.GetComponent<Clickable>();

                    if (clickable && m_collider)
                    {
                        if (!collider.GetComponent<Rigidbody>())
                        {
                            var rigidbody = collider.gameObject.AddComponent<Rigidbody>();
                            rigidbody.isKinematic = true;
                        }
                    }
                    if (m_collider && !clickable)
                    {
                        DestroyImmediate(collider.gameObject, true);
                    }
                }

                var go = GameObject.Instantiate(prefab);
                PrefabUtility.ReplacePrefab(go, prefab);
                DestroyImmediate(go);
            }
            else
            {
                Debug.LogError("未知错误，无法找到prefab");
            }
        }
    }

    private int GetGroundMaskNum()
    {
        int num = 1 << 0 |
            1 << 4 |
            1 << 8 |
            1 << 11 |
            1 << 12 |
            1 << 14 |
            1 << 30;
        return num;
    }

    // 增加rigidbody 删除多余的collider
    private void ChangeSimpleShadowHandler(UnityEngine.Object OnCheckFolder)
    {
        if (!OnCheckFolder)
        {
            Debug.LogError("文件夹获取错误，请检查!");
            return;
        }
        string strCheckFolderPath = AssetDatabase.GetAssetPath(OnCheckFolder);
        string[] lsFiles = _GetFiles(strCheckFolderPath);
        foreach (var path in lsFiles)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                var m_prefab = prefab.GetComponent<SimpleShadow>();
                if (m_prefab)
                {
                    m_prefab.GroundMask = GetGroundMaskNum();

                    var go = GameObject.Instantiate(prefab);
                    PrefabUtility.ReplacePrefab(go, prefab);
                    DestroyImmediate(go);
                }
            }
            else
            {
                Debug.LogError("未知错误，无法找到prefab");
            }
        }
    }

    void OnGUI()
    {

        if (OnCheckFolder == null)
        {
            OnCheckFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors");
        }
        OnCheckFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Actors整个文件夹并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckFolder);
        }

        GUILayout.Space(10);
        if (GUILayout.Button("搜索GroundMask并修改", GUILayout.Width(300)))
        {
            this.ChangeSimpleShadowHandler(OnCheckFolder);
        }


        GUILayout.Space(30);


        if (OnCheckRoleFolder == null)
        {
            OnCheckRoleFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Role");
        }
        OnCheckRoleFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckRoleFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Role并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckRoleFolder);
        }


        if (OnCheckMonsterFolder == null)
        {
            OnCheckMonsterFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Monster");
        }
        OnCheckMonsterFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckMonsterFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Monster并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckMonsterFolder);
        }


        if (OnCheckMingjiangFolder == null)
        {
            OnCheckMingjiangFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Mingjiang");
        }
        OnCheckMingjiangFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckMingjiangFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Mingjiang并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckMingjiangFolder);
        }


        if (OnCheckGatherFolder == null)
        {
            OnCheckGatherFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Gather");
        }
        OnCheckGatherFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckGatherFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Gather并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckGatherFolder);
        }


        if (OnCheckNpcFolder == null)
        {
            OnCheckNpcFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/NPC");
        }
        OnCheckNpcFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckNpcFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索NPC并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckNpcFolder);
        }
    }
}
