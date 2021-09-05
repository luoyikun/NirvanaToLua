using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

internal class SelectionHelper
{
    private static string selectObjPath;
    private static GameObject selectPrefab;

    [InitializeOnLoadMethod]
    private static void Start()
    {
        //在Hierarchy面板按空格键相当于开关GameObject
        EditorApplication.hierarchyWindowItemOnGUI += HierarchyWindowItemOnGUI;

        //在Project面板按空格键相当于Show In Explorer
        EditorApplication.projectWindowItemOnGUI += ProjectWindowItemOnGUI;
    }

    private static void ProjectWindowItemOnGUI(string guid, Rect selectionRect)
    {
        if (Event.current.type == EventType.KeyDown
            && Event.current.keyCode == KeyCode.Space
            && selectionRect.Contains(Event.current.mousePosition))
        {
            string strPath = AssetDatabase.GUIDToAssetPath(guid);

            if (Path.GetExtension(strPath) == string.Empty) //文件夹
            {
                Process.Start(Path.GetFullPath(strPath));
            }
            else //文件
            {
                Process.Start("explorer.exe", "/select," + Path.GetFullPath(strPath));
            }

            Event.current.Use();
        }
    }

    private static void HierarchyWindowItemOnGUI(int instanceID, Rect selectionRect)
    {
        Event e = Event.current;
        if (e.type == EventType.KeyDown)
        {
            switch (e.keyCode)
            {
                case KeyCode.Space:
                    ToggleGameObjcetActiveSelf();
                    e.Use();
                    break;
                case KeyCode.F1:
                    SaveActiveObject();
                    e.Use();
                    break;
            }
        }
        else if(e.type == EventType.MouseDown && e.button == 2)
        {
            SetAllActive();
            e.Use();
        }
    }

    internal static void ToggleGameObjcetActiveSelf()
    {
        Undo.RecordObjects(Selection.gameObjects, "Active");
        foreach (var go in Selection.gameObjects)
        {
            go.SetActive(!go.activeSelf);
        }
    }
    
    //按鼠标中键，将Root节点下的所有子物体显示出来
    static void SetAllActive()
    {
        var children = Selection.activeGameObject.GetComponentsInChildren<Transform>(true);
        foreach (var child in children)
        {
            var gameObj = child.gameObject;
            Undo.RecordObject(gameObj, "SetActive");
            gameObj.SetActive(true);
        }
    }

    private static void SaveActiveObject()
    {
        if (EditorApplication.isPlaying)
        {
            var instanceID = GetInstanceID(Selection.activeGameObject);
            selectPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GetAssetPath(instanceID));
            if (null != selectPrefab)
            {
                GameRoot.ShowMessage("保存成功", 1f);
            }
            else
            {
                GameRoot.ShowMessage("保存失败", 1f);
            }
        }
        else
        {
            JumpSelectObject();
        }
    }

    private static int GetInstanceID(GameObject go)
    {
        if (null == go)
        {
            selectObjPath = string.Empty;
            selectPrefab = null;
            return 0;
        }
       
        var instanceID = EditorResourceMgr.GetOriginalInstanceId(go);

        Stack<string> stack = new Stack<string>();
        while (0 == instanceID && go.transform.parent)
        {
            stack.Push(go.name);
            go = go.transform.parent.gameObject;
            instanceID = EditorResourceMgr.GetOriginalInstanceId(go);
        }

        if (stack.Count > 0)
        {
            selectObjPath = stack.Pop();
        }

        while (stack.Count > 0)
        {
            selectObjPath += "/" + stack.Pop();
        }
        return instanceID;
    }

    private static void JumpSelectObject()
    {
        if (null != selectPrefab)
        {
            var prefab = InstantiatePrefab();
            var target = prefab.transform.Find(selectObjPath);
            EditorGUIUtility.PingObject(target);
        }
    }

    private static GameObject InstantiatePrefab()
    {
        var scene = SceneManager.GetActiveScene();
        var activeObjs = scene.GetRootGameObjects();
        foreach (var obj in activeObjs)
        {
            var prefabParent = PrefabUtility.GetPrefabParent(obj);
            if (prefabParent == selectPrefab)
                return obj;
        }

        var prefab = PrefabUtility.InstantiatePrefab(selectPrefab) as GameObject;
        return prefab;
    }
}