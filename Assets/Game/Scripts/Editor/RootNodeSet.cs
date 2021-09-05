using System.Collections.Generic;
using System.Text.RegularExpressions;
using Nirvana;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class RootNodeSet : EditorWindow
{
    [MenuItem("Tools/UI Tools/Root Node Set &1")]
    static void ShowWindow()
    {
        RootNodeSet window = GetWindow<RootNodeSet>("Root Node Set");
        window.Show();
    }

    private GameObject selectGo;
    private GUIStyle guiStyle;

    void Awake()
    {
        originNode = new Node();

        guiStyle = new GUIStyle();
        guiStyle.normal.textColor = Color.white;
        guiStyle.fontStyle = FontStyle.BoldAndItalic;
    }

    void OnGUI()
    {
        selectGo = EditorGUILayout.ObjectField("Root Node", selectGo, typeof(GameObject),
            true, GUILayout.Width(400)) as GameObject;
        selectGo = Selection.activeGameObject;

        if (selectGo == null)
        {
            return;
        }

        GUILayout.BeginArea(new Rect(0,20,400,40));

        EditorGUILayout.LabelField("Image Set", guiStyle);

        EditorGUILayout.BeginHorizontal();

        if (GUILayout.Button("Restore All Scale", GUILayout.Width(200)))
        {
            GetAllChild(selectGo, originNode);
            RestoreAllScale(originNode);
        }

        if (GUILayout.Button("Set All Native Size", GUILayout.Width(200)))
        {
            GetAllChild(selectGo, originNode);
            SetAllNativeSize(originNode);
        }

        EditorGUILayout.EndHorizontal();

        GUILayout.EndArea();

        GUILayout.Space(40);

        GUILayout.BeginArea(new Rect(0, 60, 400, 40));

        EditorGUILayout.LabelField("Text Set", guiStyle);

        EditorGUILayout.BeginHorizontal();

        if (GUILayout.Button("Set All Text Font", GUILayout.Width(200)))
        {
            GetAllChild(selectGo, originNode);
            SetAllTextFont(originNode);
        }

        if (GUILayout.Button("Set All Text Shadow", GUILayout.Width(200)))
        {
            GetAllChild(selectGo, originNode);
            SetAllTextShadow(originNode);
        }

        EditorGUILayout.EndHorizontal();

        GUILayout.EndArea();
    }

    public class Node
    {
        public GameObject gameObj;
        public List<Node> childNodeList;
    }
    
    private static Node originNode;

    private void GetAllChild(GameObject fatherGo, Node node)
    {
        node.gameObj = fatherGo;
        node.childNodeList = new List<Node>();

        foreach (Transform child in fatherGo.transform)
        {
            Node tmpNode = new Node();
            GetAllChild(child.gameObject, tmpNode);
            node.childNodeList.Add(tmpNode);
        }
    }

    private void RestoreAllScale(Node originNode)
    {
        if (originNode.gameObj != null)
        {
            RectTransform rectTf = originNode.gameObj.GetComponent<RectTransform>();
            if (rectTf != null && 
                Mathf.Abs(rectTf.localScale.x) != 1 ||
                Mathf.Abs(rectTf.localScale.x) != 1 || 
                Mathf.Abs(rectTf.localScale.z) != 1)
            {
                rectTf.localScale = Vector3.one;
            }
        }

        if (originNode.childNodeList != null)
        {
            foreach (var childNode in originNode.childNodeList)
            {
                RestoreAllScale(childNode);
            }
        }
    }

    private void SetAllNativeSize(Node originNode)
    {
        if (originNode.gameObj != null)
        {
            Image image = originNode.gameObj.GetComponent<Image>();
            if (image != null && image.sprite != null)
            {
                if (image.type != Image.Type.Sliced)
                {
                    image.SetNativeSize();
                    UIImageMirror mirror = originNode.gameObj.GetComponent<UIImageMirror>();
                    if (mirror != null)
                    {
                        switch (mirror.MirrorMode)
                        {
                            case UIImageMirror.MirrorModeType.Horizontal:
                                image.rectTransform.sizeDelta = new Vector2(
                                    image.rectTransform.sizeDelta.x * 2, image.rectTransform.sizeDelta.y);
                                break;
                            case UIImageMirror.MirrorModeType.Vertical:
                                image.rectTransform.sizeDelta = new Vector2(
                                    image.rectTransform.sizeDelta.x, image.rectTransform.sizeDelta.y * 2);
                                break;
                            case UIImageMirror.MirrorModeType.Quad:
                                image.rectTransform.sizeDelta *= 2;
                                break;
                        }
                    }
                }
                else
                {
                    Vector2 size = image.rectTransform.sizeDelta;

                    image.type = Image.Type.Simple;
                    image.SetNativeSize();
                    image.type = Image.Type.Sliced;

                    if (image.rectTransform.sizeDelta.x < size.x ||
                        image.rectTransform.sizeDelta.y < size.y)
                    {
                        image.type = Image.Type.Sliced;
                        image.rectTransform.sizeDelta = size;
                    }
                }
                
            }
        }

        if (originNode.childNodeList != null)
        {
            foreach (var childNode in originNode.childNodeList)
            {
                SetAllNativeSize(childNode);
            }
        }
    }

    private void SetAllTextFont(Node originNode)
    {
        if (originNode.gameObj != null)
        {
            Text text = originNode.gameObj.GetComponent<Text>();

            if (text != null)
            {
                string fontName = text.font.ToString().Replace("(UnityEngine.Font)", "").Trim();
                if (fontName == "Arial" || fontName == "SIMHEI")
                {
                    string[] fontIDs = AssetDatabase.FindAssets("t:Font");
                    foreach (var fontID in fontIDs)
                    {
                        string fontPath = AssetDatabase.GUIDToAssetPath(fontID);
                        if (Regex.IsMatch(fontPath, "HuaKangYuanTi"))
                        {
                            var asset = AssetDatabase.LoadAssetAtPath<Font>(fontPath);
                            text.font = asset;
                            break;
                        }
                    }
                }
            }

            if (originNode.childNodeList != null)
            {
                foreach (var childNode in originNode.childNodeList)
                {
                    SetAllTextFont(childNode);
                }
            }

        }
    }

    private void SetAllTextShadow(Node originNode)
    {
        if (originNode.gameObj != null)
        {
            Text text = originNode.gameObj.GetComponent<Text>();
            if (text != null)
            {
                var shadow = text.gameObject.GetComponent<Shadow>();
                var outline = text.gameObject.GetComponent<Outline>();
                var gradient = text.gameObject.GetComponent<Nirvana.UIGradient>();
                if (null == shadow && null == outline && null == gradient)
                {
                    text.gameObject.AddComponent<Shadow>();
                }
            }

            if (originNode.childNodeList != null)
            {
                foreach (var childNode in originNode.childNodeList)
                {
                    SetAllTextShadow(childNode);
                }
            }
        }
    }
}
