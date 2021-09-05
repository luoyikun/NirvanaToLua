using System.Collections.Generic;
using System.Linq;
using Nirvana;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class CopyPasteComponent : EditorWindow
{
    public static List<Component> copiedCpts = new List<Component>();

    [MenuItem("Tools/UI Tools/Copy Components &C")]
    static void Copy()
    {
        copiedCpts = Selection.activeGameObject.GetComponents<Component>().ToList();
    }

    [MenuItem("Tools/UI Tools/Paste Components &V")]
    static void PasteComponents()
    {
        PasteComponents(copiedCpts.ToArray(), Selection.activeGameObject);
    }

    #region //复制组件时做一些判定
    static void PasteComponents(Component[] copiedCpts, GameObject targetGo)
    {
        RemoveThreeComponent(targetGo);
        Component[] targetCpts = targetGo.GetComponents<Component>();
        foreach (Component copiedCpt in copiedCpts)
        {
            UnityEditorInternal.ComponentUtility.CopyComponent(copiedCpt);

            bool isCptExist = false;
            foreach (var targetcpt in targetCpts)
            {
                if (targetcpt.GetType() == copiedCpt.GetType())
                {
                    if (targetcpt is Text)//如果为字体组件，复制的时候不改变文字内容
                    {
                        string content = ((Text)targetcpt).text;
                        UnityEditorInternal.ComponentUtility.PasteComponentValues(targetcpt);
                        ((Text)targetcpt).text = content;
                    }
                    else
                    {
                        UnityEditorInternal.ComponentUtility.PasteComponentValues(targetcpt);
                    }
                    isCptExist = true;
                    break;
                }
            }
            if (!isCptExist)
            {
                UnityEditorInternal.ComponentUtility.PasteComponentAsNew(targetGo);
            }
        }
    }

    /// <summary>
    /// 根据要求先移除与字体相关的三个组件
    /// </summary>
    /// <param name="go"></param>
    static void RemoveThreeComponent(GameObject go)
    {
        UIGradient uiGradient = go.GetComponent<UIGradient>();
        Shadow[] shadows = go.GetComponents<Shadow>();

        if (uiGradient != null)
        {
            DestroyImmediate(uiGradient);
        }
        if (shadows != null)
        {
            foreach (var shadow in shadows)
            {
                DestroyImmediate(shadow);
            }
        }
    } 
    #endregion
    
    #region 复制粘贴选中物体及子物体的组件
    [MenuItem("Tools/UI Tools/Copy With Child Components %&C")]
    static void CopyWithChildComponents()
    {
        GetAllComponent(Selection.activeGameObject, originNode);
    }

    [MenuItem("Tools/UI Tools/Psate With Child Components %&V")]
    static void PasteWithChildComponents()
    {
        PasteAllComponent(Selection.activeGameObject, originNode);
    }

    static Node originNode = new Node();

    public class Node
    {
        public GameObject gameObj;
        public List<Component> components;
        public List<Node> childrenNode;
    }

    static void GetAllComponent(GameObject gameObj, Node node)
    {
        node.gameObj = gameObj;
        node.components = new List<Component>();
        node.childrenNode = new List<Node>();

        var cpts = gameObj.GetComponents<Component>();
        foreach (var cpt in cpts)
        {
            node.components.Add(cpt);
        }

        foreach (Transform child in gameObj.transform)
        {
            Node childNode = new Node();
            GetAllComponent(child.gameObject, childNode);
            node.childrenNode.Add(childNode);
        }
    }

    static void PasteAllComponent(GameObject gameObj, Node node)
    {
        if (node.components != null)
        {
            PasteComponents(node.components.ToArray(), gameObj);
        }

        if (node.childrenNode != null)
        {
            List<Transform> children = new List<Transform>();
            foreach (Transform child in gameObj.transform)
            {
                children.Add(child);
            }

            for (int i = 0; i < node.childrenNode.Count; i++)
            {
                if (i <= children.Count)
                {
                    PasteAllComponent(children[i].gameObject, node.childrenNode[i]);
                }
            }
        }
    } 
    #endregion
    
    #region //测试时删除所有组件
    //[MenuItem("Tools/UI Tools/Clear With Child Components")]
    //static void ClearChildComponent()
    //{
    //    Component[] cpts = Selection.activeGameObject.GetComponentsInChildren<Component>(true);
    //    foreach (var cpt in cpts)
    //    {
    //        DestroyImmediate(cpt);
    //    }
    //}
    #endregion
}
