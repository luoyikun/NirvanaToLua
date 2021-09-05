using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;

public class BaseEditorWindow : EditorWindow
{
    protected static GameObject FindInScene(GameObject prefab, GameObject sceneObj)
    {

        var queue = new Queue<Transform>();
        queue.Enqueue(sceneObj.transform);
        while (queue.Count > 0)
        {
            var transform = queue.Dequeue();
            var prefabParent = PrefabUtility.GetPrefabParent(transform.gameObject);
            if (null != prefabParent && prefabParent == prefab)
            {
                return transform.gameObject;
            }
            for (int i = 0; i < transform.childCount; ++i)
            {
                var child = transform.GetChild(i);
                queue.Enqueue(child);
            }
        }
        return null;
    }

    protected static GameObject SearchInGameObject(GameObject root, GameObject target)
    {
        GameObject findObj = null;
        if (null == target.transform.parent)
        {
            findObj = root;
        }
        else
        {
            string path = target.name;
            while (target.transform.parent && target.transform.parent.parent)
            {
                target = target.transform.parent.gameObject;
                path = target.name + "/" + path;
            }
            var findTransform = root.transform.Find(path);
            if (null != findTransform)
                findObj = findTransform.gameObject;
        }
        return findObj;
    }

    protected static void PingObj(GameObject obj)
    {
        var root = obj;
        while (root.transform.parent)
        {
            root = root.transform.parent.gameObject;
        }

        var scene = SceneManager.GetActiveScene();
        var activeObjs = scene.GetRootGameObjects();
        GameObject activeObj = null;
        for (int j = 0; j < activeObjs.Length; ++j)
        {
            if (activeObj = FindInScene(root, activeObjs[j]))
            {
                break;
            }
        }
        if (null != activeObj)
        {
            var target = SearchInGameObject(activeObj, obj);
            EditorGUIUtility.PingObject(target);
        }
        else
        {
            EditorGUIUtility.PingObject(root);
        }
    }
}
