using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Nirvana;
using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEngine;
using UnityEngine.UI;

#region//定义Json的类
[Serializable]
public class TextJsonData
{
    public string name;

    public string textFont;
    public string textFontStyle;
    public int textFontSize;
    public Vector4 textColor;

    public Vector4 shadowEffectColor;
    public Vector2 shadowEffectDistance;
    public bool shadowUseGraphicAlpha;

    public Vector4 outlineEffectColor;
    public Vector2 outlineEffectDistance;
    public bool outlineUseGraphicAlpha;

    public string gradientMode;
    public string gradientDirection;
    public string gradientColorMode;
    public Vector4 gradientColor1;
    public Vector4 gradientColor2;
    public bool gradientUseGraphicAlpha;
}

[Serializable]
public class TextJsonList
{
    public List<TextJsonData> inforList = new List<TextJsonData>();
}
#endregion

public class TextSet : EditorWindow
{
    [MenuItem("Tools/UI Tools/Set Text &S")]
    public static void ShowWindow()
    {
        GetWindow<TextSet>();
    }

    private string jsonPath;
    private GameObject selectGo;
    private GUIStyle guiStyle;        //OnGUI函数需要的标题格式
    private AnimBool fadeGroup;       //折叠动画
    private Vector2 scroll;           //滚动条
    protected string newModuleName;   //新模板的命名

    private Text textComponent;
    private UIGradient uiGradientComponent;
    private Outline outlineComponent;
    private Shadow shadowComponent;

    private TextJsonList jsonDataList;

    private bool canChangeFontSize = false;     //加载模板时是否改变FontSize

    void Awake()
    {
        guiStyle = new GUIStyle();
        guiStyle.normal.textColor = Color.white;
        guiStyle.fontStyle = FontStyle.BoldAndItalic;

        fadeGroup = new AnimBool();
        fadeGroup.valueChanged.AddListener(Repaint);

        jsonPath = jsonPath = Path.Combine(Application.dataPath, "../EditorJson/TextSet.json");
        ReadData();
    }

    void OnGUI()
    {
        selectGo = EditorGUILayout.ObjectField("要更换的字体", selectGo, typeof(GameObject), true, GUILayout.Width(500)) as GameObject;
        selectGo = Selection.activeGameObject;
        if (selectGo == null) return;

        if (CheckExist<Text>(selectGo))
        {
            EditorGUILayout.LabelField("Text", guiStyle);

            textComponent = SaveGetComponent<Text>(selectGo);
            textComponent.font = EditorGUILayout.ObjectField("Font:", textComponent.font, typeof(Font), true) as Font;
            textComponent.fontStyle = (FontStyle)EditorGUILayout.EnumPopup("Font Style:", textComponent.fontStyle);
            canChangeFontSize = GUILayout.Toggle(canChangeFontSize, "Can Change Font Size");
            if (canChangeFontSize)
            {
                textComponent.fontSize = EditorGUILayout.IntField("Font Size", textComponent.fontSize);
            }
            textComponent.color = EditorGUILayout.ColorField("Color", textComponent.color);
        }
        else
        {
            //为了使Help的窗口大小如下
            GUILayout.BeginArea(new Rect(0, 20, 480, 40));
            EditorGUILayout.HelpBox("Don't Find Text Component！！！", MessageType.Error, true);
            GUILayout.EndArea();
            GUILayout.Space(40);
        }

        fadeGroup.target = EditorGUILayout.Foldout(fadeGroup.target, "Other Component", true);

        if (CheckExist<UIGradient>(selectGo))
        {
            if (EditorGUILayout.BeginFadeGroup(fadeGroup.faded))
            {
                EditorGUILayout.LabelField("UIGradient", guiStyle);
                uiGradientComponent = SaveGetComponent<UIGradient>(selectGo);

                uiGradientComponent.GradientMode =
                    (UIGradient.GradientModeEnum)EditorGUILayout.EnumPopup("Gradient Mode",
                        uiGradientComponent.GradientMode);
                uiGradientComponent.GradientDirection =
                    (UIGradient.GradientDirectionEnum)EditorGUILayout.EnumPopup("Gradient Direction",
                        uiGradientComponent.GradientDirection);
                uiGradientComponent.ColorMode =
                    (UIGradient.ColorModeEnum)EditorGUILayout.EnumPopup("Color Mode",
                        uiGradientComponent.ColorMode);
                uiGradientComponent.Color1 = EditorGUILayout.ColorField("Vertex 1", uiGradientComponent.Color1);
                uiGradientComponent.Color2 = EditorGUILayout.ColorField("Vertex 2", uiGradientComponent.Color2);
                uiGradientComponent.UseGraphicAlpha = EditorGUILayout.Toggle("Use Graphic Alpha", uiGradientComponent.UseGraphicAlpha);
            }
            EditorGUILayout.EndFadeGroup();

            if (GUILayout.Button("移除UIGradient", GUILayout.Width(200)))
            {
                DestroyImmediate(selectGo.GetComponent<UIGradient>());
            }
        }
        else
        {
            if (GUILayout.Button("添加UIGradient", GUILayout.Width(200)))
            {
                selectGo.AddComponent<UIGradient>();
            }
        }

        if (CheckExist<Outline>(selectGo))
        {
            outlineComponent = SaveGetComponent<Outline>(selectGo);

            if (EditorGUILayout.BeginFadeGroup(fadeGroup.faded))
            {
                EditorGUILayout.LabelField("Outline", guiStyle);

                outlineComponent.effectColor =
                    EditorGUILayout.ColorField("Effect Color", outlineComponent.effectColor);
                outlineComponent.effectDistance =
                    EditorGUILayout.Vector2Field("Effect Distance", outlineComponent.effectDistance);
                outlineComponent.useGraphicAlpha =
                    EditorGUILayout.Toggle("Use Graphic Alpha", outlineComponent.useGraphicAlpha);
            }
            EditorGUILayout.EndFadeGroup();

            if (GUILayout.Button("移除Outline", GUILayout.Width(200)))
            {
                DestroyImmediate(outlineComponent);
            }
        }
        else
        {
            if (GUILayout.Button("添加Outline", GUILayout.Width(200)))
            {
                selectGo.AddComponent<Outline>();
            }
        }

        if (CheckExist<Shadow>(selectGo))
        {
            shadowComponent = SaveGetComponent<Shadow>(selectGo);

            if (EditorGUILayout.BeginFadeGroup(fadeGroup.faded))
            {
                EditorGUILayout.LabelField("Shadow", guiStyle);

                shadowComponent.effectColor =
                    EditorGUILayout.ColorField("Effect Color", shadowComponent.effectColor);
                shadowComponent.effectDistance =
                    EditorGUILayout.Vector2Field("Effect Distance", shadowComponent.effectDistance);
                shadowComponent.useGraphicAlpha =
                    EditorGUILayout.Toggle("Use Graphic Alpha", shadowComponent.useGraphicAlpha);
            }
            EditorGUILayout.EndFadeGroup();

            if (GUILayout.Button("移除Shadow", GUILayout.Width(200)))
            {
                DestroyImmediate(shadowComponent);
            }
        }
        else
        {
            if (GUILayout.Button("添加Shadow", GUILayout.Width(200)))
            {
                selectGo.AddComponent<Shadow>();
            }
        }

        EditorGUILayout.LabelField("Select Mode", guiStyle);

        EditorGUILayout.BeginHorizontal();
        { 
            if (GUILayout.Button("保存模板", GUILayout.Width(200)))
            {
                if (!string.IsNullOrEmpty(newModuleName))
                {
                    AddModule(newModuleName);
                }
            }
            newModuleName = EditorGUILayout.TextField(newModuleName, GUILayout.Width(270));
        }
        EditorGUILayout.EndHorizontal();

        scroll = EditorGUILayout.BeginScrollView(scroll);
        {
            for (int i = 0; i < jsonDataList.inforList.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                { 
                    GUI.skin.button.alignment = TextAnchor.LowerLeft;
                    if (GUILayout.Button(jsonDataList.inforList[i].name, GUILayout.Width(250)))
                    {
                        LoadModule(jsonDataList.inforList[i].name);
                    }
                    GUI.skin.button.alignment = TextAnchor.MiddleCenter;

                    if (GUILayout.Button("上移", GUILayout.Width(50)))
                    {
                        if (i > 0)
                        {
                            TextJsonData tmpdata = jsonDataList.inforList[i];
                            jsonDataList.inforList[i] = jsonDataList.inforList[i - 1];
                            jsonDataList.inforList[i - 1] = tmpdata;
                        }
                    }

                    if (GUILayout.Button("下移", GUILayout.Width(50)))
                    {
                        if (i < jsonDataList.inforList.Count - 1)
                        {
                            TextJsonData tmpdata = jsonDataList.inforList[i];
                            jsonDataList.inforList[i] = jsonDataList.inforList[i + 1];
                            jsonDataList.inforList[i + 1] = tmpdata;
                        }
                    }

                    if (GUILayout.Button("移除", GUILayout.Width(100)))
                    {
                        RemoveModule(jsonDataList.inforList[i].name);
                    }
                }
                EditorGUILayout.EndHorizontal();
            }
        }
        EditorGUILayout.EndScrollView();

        if (GUI.changed)
        {
            var jsonContents = JsonUtility.ToJson(jsonDataList);
            File.WriteAllText(jsonPath, jsonContents, Encoding.UTF8);
        }
    }
    
    void OnInspectorUpdate()
    {
        Repaint();
    }

    bool CheckExist<T>(GameObject go) where T : Component
    {
        if (typeof(T) == typeof(Shadow))
        {
            //因为Outline继承于Shadow，所以要确保获得的组件为Shadow
            Shadow[] shadows = selectGo.GetComponents<Shadow>();
            foreach (var shadow in shadows)
            {
                if (shadow.GetType() == typeof(Shadow))
                {
                    return true;
                }
            }
            return false;
        }
        else
        {
            return go.GetComponent<T>() != null;
        }
    }

    T SaveGetComponent<T>(GameObject go) where T : Component
    {
        T cpnt = go.GetComponent<T>();

        if (cpnt == null)
        {
            cpnt = go.AddComponent<T>();
        }
        else
        {
            if (typeof(T) == typeof(Shadow))
            {
                //因为Outline继承于Shadow，所以要确保获得的组件为Shadow
                Shadow[] shadows = selectGo.GetComponents<Shadow>();
                foreach (var shadow in shadows)
                {
                    if (shadow.GetType() == typeof(Shadow))
                    {
                        return shadow as T;
                    }
                }

                cpnt = go.AddComponent<T>();
            }
        }

        return cpnt;
    }

    private void ReadData()
    {
        if (!File.Exists(jsonPath))
        {
            File.Create(jsonPath).Dispose();
            AssetDatabase.Refresh();
        }
        string jsonContents = File.ReadAllText(jsonPath, Encoding.UTF8);

        jsonDataList = JsonUtility.FromJson<TextJsonList>(jsonContents) ?? new TextJsonList();
    }

    private string SearchThisCSharpDirectory(string className)
    {
        string[] ids = AssetDatabase.FindAssets("t:Script");
        string tmpath = null;
        foreach (var id in ids)
        {
            tmpath = AssetDatabase.GUIDToAssetPath(id);
            if (tmpath.Contains(this.GetType().ToString()))
            {
                tmpath = tmpath.Replace("cs", "json");
                return tmpath;
            }
        }
        return tmpath;
    }

    private void AddModule(string moduleName)
    {
        var tmpJsonData = GetJsonDataByObject(moduleName);
        for (int i = 0; i < jsonDataList.inforList.Count; i++)
        {
            if (jsonDataList.inforList[i].name == moduleName)
            {
                jsonDataList.inforList[i] = tmpJsonData;
                return;
            }
        }
        jsonDataList.inforList.Add(tmpJsonData);
    }

    private TextJsonData GetJsonDataByObject(string moduleName)
    {
        TextJsonData infor = new TextJsonData();
        infor.name = moduleName;

        if (CheckExist<Text>(selectGo))
        {
            textComponent = textComponent ?? SaveGetComponent<Text>(selectGo);
            infor.textFont = textComponent.font.ToString().Replace("(UnityEngine.Font)", "").Trim();
            infor.textFontStyle = textComponent.fontStyle.ToString();
            infor.textFontSize = textComponent.fontSize;
            infor.textColor = textComponent.color;
        }

        if (CheckExist<UIGradient>(selectGo))
        {
            uiGradientComponent = uiGradientComponent ?? SaveGetComponent<UIGradient>(selectGo);
            infor.gradientMode = uiGradientComponent.GradientMode.ToString();
            infor.gradientDirection = uiGradientComponent.GradientDirection.ToString();
            infor.gradientColorMode = uiGradientComponent.ColorMode.ToString();
            infor.gradientColor1 = uiGradientComponent.Color1;
            infor.gradientColor2 = uiGradientComponent.Color2;
            infor.gradientUseGraphicAlpha = uiGradientComponent.UseGraphicAlpha;
        }

        if (CheckExist<Outline>(selectGo))
        {
            outlineComponent = outlineComponent ?? SaveGetComponent<Outline>(selectGo);
            infor.outlineEffectColor = outlineComponent.effectColor;
            infor.outlineEffectDistance = outlineComponent.effectDistance;
            infor.outlineUseGraphicAlpha = outlineComponent.useGraphicAlpha;
        }

        if (CheckExist<Shadow>(selectGo))
        {
            Shadow[] shadows = selectGo.GetComponents<Shadow>();
            foreach (var shadow in shadows)
            {
                if (shadow.GetType() == typeof(Shadow))
                {
                    infor.shadowEffectColor = shadow.effectColor;
                    infor.shadowEffectDistance = shadow.effectDistance;
                    infor.shadowUseGraphicAlpha = shadow.useGraphicAlpha;
                }
            }

        }
        return infor;
    }

    private void LoadModule(string moduleName)
    {
        foreach (var infor in jsonDataList.inforList)
        {
            if (infor.name == moduleName)
            {
                var components = selectGo.GetComponents<Component>();
                Undo.RecordObjects(components, "SetTextValue");
                SetValueByJsonData(infor);
            }
        }
    }

    private void SetValueByJsonData(TextJsonData infor)
    {
        var isPrefab = PrefabUtility.GetPrefabType(selectGo);
        if (isPrefab == PrefabType.PrefabInstance)
        {
            PrefabUtility.DisconnectPrefabInstance(selectGo);
        }

        if (infor.shadowEffectColor != Vector4.zero)
        {
            shadowComponent = shadowComponent ?? SaveGetComponent<Shadow>(selectGo);
            shadowComponent.effectColor = infor.shadowEffectColor;
            shadowComponent.effectDistance = infor.shadowEffectDistance;
            shadowComponent.useGraphicAlpha = infor.shadowUseGraphicAlpha;

            while (UnityEditorInternal.ComponentUtility.MoveComponentUp(shadowComponent)) { }
        }
        else
        {
            DestroyImmediate(SaveGetComponent<Shadow>(selectGo));
        }

        if (infor.outlineEffectColor != Vector4.zero)
        {
            outlineComponent = outlineComponent ?? SaveGetComponent<Outline>(selectGo);

            outlineComponent.effectColor = infor.outlineEffectColor;
            outlineComponent.effectDistance = infor.outlineEffectDistance;
            outlineComponent.useGraphicAlpha = infor.outlineUseGraphicAlpha;

            while (UnityEditorInternal.ComponentUtility.MoveComponentUp(outlineComponent)) { }
        }
        else
        {
            DestroyImmediate(SaveGetComponent<Outline>(selectGo));
        }

        if (!string.IsNullOrEmpty(infor.gradientMode))
        {
            uiGradientComponent = uiGradientComponent ?? SaveGetComponent<UIGradient>(selectGo);
            uiGradientComponent.GradientMode =
                (UIGradient.GradientModeEnum)Enum.Parse(typeof(UIGradient.GradientModeEnum),
                    infor.gradientMode);
            uiGradientComponent.GradientDirection =
                (UIGradient.GradientDirectionEnum)Enum.Parse(typeof(UIGradient.GradientDirectionEnum),
                    infor.gradientDirection);
            uiGradientComponent.ColorMode =
                (UIGradient.ColorModeEnum)Enum.Parse(typeof(UIGradient.ColorModeEnum),
                    infor.gradientColorMode);
            uiGradientComponent.Color1 = infor.gradientColor1;
            uiGradientComponent.Color2 = infor.gradientColor2;
            uiGradientComponent.UseGraphicAlpha = infor.gradientUseGraphicAlpha;

            while (UnityEditorInternal.ComponentUtility.MoveComponentUp(uiGradientComponent)) { }
        }
        else
        {
            DestroyImmediate(selectGo.GetComponent<UIGradient>());
        }

        if (infor.textFont != null)
        {
            textComponent = textComponent ?? SaveGetComponent<Text>(selectGo);
            string[] fontIDs = AssetDatabase.FindAssets("t:Font");
            foreach (var fontID in fontIDs)
            {
                string fontPath = AssetDatabase.GUIDToAssetPath(fontID);
                if (fontPath.Contains(infor.textFont.Trim()))
                {
                    var asset = AssetDatabase.LoadAssetAtPath<Font>(fontPath);
                    textComponent.font = asset;
                    break;
                }
            }
            textComponent.fontStyle = (FontStyle)Enum.Parse(typeof(FontStyle), infor.textFontStyle);
            if (canChangeFontSize)
            {
                textComponent.fontSize = infor.textFontSize;
            }
            textComponent.color = infor.textColor;

            while (UnityEditorInternal.ComponentUtility.MoveComponentUp(textComponent)) { }
        }
    }

    private void RemoveModule(string moduleName)
    {
        for (int i = 0; i < jsonDataList.inforList.Count; i++)
        {
            if (jsonDataList.inforList[i].name == moduleName)
            {
                jsonDataList.inforList.RemoveAt(i);
                return;
            }
        }
    }

}