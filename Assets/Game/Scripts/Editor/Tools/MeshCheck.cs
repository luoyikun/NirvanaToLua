using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class CheckMesh : EditorWindow
{
    private GameObject targetModel;
    private bool showPrefabMesh = false;
    private int modelTriangles = 0;
    //private int ModelMeshShinnerCount = 0;
    //private int ModelMeshCount = 0;

    private Object targetFile;
    private int MeshCount;
    private bool startCheck;

    private Vector2 m_v2ScrollPos;
    private List<objList> fbxObj = new List<objList>();
    private class objList
    {
        public GameObject ObjItem1 { get; set; }

        public int ObjMeshCount { get; set; }
    }
    /// <summary>
    /// 获取文件
    /// </summary>
    /// <param name="path"></param>
    /// <param name="recursive"></param>
    /// <returns></returns>
    private string[] GetFiles(string path, bool recursive = true)
    {
        List<string> withExtensions = new List<string>() { ".fbx" };

        var resultList = new List<string>();
        string[] files = Directory.GetFiles(path, "*.fbx", SearchOption.AllDirectories);
        foreach (var strPath in files)
        {
            resultList.Add(strPath.Replace('\\', '/'));
        }

        return resultList.ToArray();
    }
    /// <summary>
    /// 开始检测
    /// </summary>
    private void StartCheck()
    {
        fbxObj.Clear();
        string strCheckFolderPath = AssetDatabase.GetAssetPath(targetFile);
        //string[] lsFiles = GetFiles(strCheckFolderPath);
        var assetGuids = AssetDatabase.FindAssets("t:model", new string[] { strCheckFolderPath });
        foreach (var guid in assetGuids)
        {
            var strFbsFile = AssetDatabase.GUIDToAssetPath(guid);
            int meshCount = 0;
            GameObject Obj = AssetDatabase.LoadAssetAtPath<GameObject>(strFbsFile);
            GameObject ObjIns = Instantiate(Obj);
            SkinnedMeshRenderer[] tempMeshShinner = ObjIns.GetComponentsInChildren<SkinnedMeshRenderer>();
            MeshFilter[] tempMeshFilter = ObjIns.GetComponentsInChildren<MeshFilter>();

            for (int i = 0; i < tempMeshShinner.Length; i++)
            {
                Mesh needMesh = tempMeshShinner[i].sharedMesh;
                meshCount += needMesh.triangles.Length / 3;
            }
            for (int i = 0; i < tempMeshFilter.Length; i++)
            {
                Mesh needMesh = tempMeshFilter[i].transform.GetComponent<MeshFilter>().sharedMesh;
                if (needMesh)
                {
                    meshCount += needMesh.triangles.Length / 3 ;
                }

            }
            if (meshCount >= MeshCount)
            {
                objList listObj = new objList();
                listObj.ObjItem1 = Obj;
                listObj.ObjMeshCount = meshCount;
                fbxObj.Add(listObj);
            }
            DestroyImmediate(ObjIns);
        }
    }
    [MenuItem("自定义工具/资源搜索工具/Mesh搜索")]
    static void Init()
    {
        var window = GetWindow(typeof(CheckMesh));
        window.Show();
    }
    /// <summary>
    /// GUI布局
    /// </summary>
    void OnGUI()
    {
        targetModel = EditorGUILayout.ObjectField("检测模型面数：", targetModel, typeof(GameObject), false) as GameObject;
        if (GUILayout.Button("检测"))
        {
            showPrefabMesh = true;
            modelTriangles = 0;
            GameObject modelInstantiate = Instantiate(targetModel);
            MeshFilter[] tempMeshFilter = modelInstantiate.GetComponentsInChildren<MeshFilter>();
            SkinnedMeshRenderer[] tempMeshShinner = modelInstantiate.GetComponentsInChildren<SkinnedMeshRenderer>();

            for(int i = 0; i < tempMeshFilter.Length; i++)
            {
                Mesh meshFilter = tempMeshFilter[i].transform.GetComponent<MeshFilter>().sharedMesh;
                if(null != meshFilter)
                {
                    modelTriangles += (meshFilter.triangles.Length / 3);
                }
            }

            for (int i = 0; i < tempMeshShinner.Length; i++)
            {
                Mesh skinnerSharedMesh = tempMeshShinner[i].sharedMesh;
                if (null != skinnerSharedMesh)
                {
                    modelTriangles += (skinnerSharedMesh.triangles.Length / 3);
                }
            }

            DestroyImmediate(modelInstantiate);
        }
        if (showPrefabMesh && null != targetModel)
        {
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("模型面数:" + modelTriangles);
            GUILayout.EndHorizontal();
            GUILayout.Space(15);
        }



        GUILayout.BeginVertical();
        if (targetFile == null)
        {
            targetFile = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Game");
        }
        targetFile = EditorGUILayout.ObjectField("添加文件:", targetFile, typeof(Object), true) as Object;
        EditorGUILayout.Space();
        if (GUILayout.Button("开始检测",GUILayout.Width(180)))
        {
            if (targetFile)
            {
                StartCheck();
            }
            else
            {
                Debug.LogError("文件未添加");
            }
        }
        MeshCount = EditorGUILayout.IntField("检索面数", MeshCount, GUILayout.Width(200));
        if (fbxObj.Count > 0)
        {
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("序号", GUILayout.Width(30));
            EditorGUILayout.LabelField("对象", GUILayout.Width(100));
            EditorGUILayout.LabelField("面数", GUILayout.Width(50));
            GUILayout.EndHorizontal();
            m_v2ScrollPos = EditorGUILayout.BeginScrollView(m_v2ScrollPos, GUILayout.Width(450), GUILayout.Height(600));
            for (var nIdx = 0; nIdx < fbxObj.Count; ++nIdx)
            {
                GUILayout.BeginHorizontal();
                var obj = fbxObj[nIdx].ObjItem1;
                var objMesh = fbxObj[nIdx].ObjMeshCount;
                EditorGUILayout.LabelField((nIdx + 1).ToString(), GUILayout.Width(30));
                EditorGUILayout.ObjectField(obj, typeof(GameObject), false, GUILayout.Width(300));
                EditorGUILayout.LabelField(objMesh.ToString(), GUILayout.Width(50));
                GUILayout.EndHorizontal();
                EditorGUILayout.Space();
            }
            EditorGUILayout.EndScrollView();
        }
        GUILayout.EndVertical();

    }
    void OnInspectorUpdate() //更新  
    {
        Repaint();  //重新绘制  
    }
}