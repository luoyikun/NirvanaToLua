using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine.UI;

[CustomEditor(typeof(ChangeText))]
public class ChangeTextEditor : Editor
{
    private SerializedProperty checkColor;
    private SerializedProperty changeColor;
    private SerializedProperty oldColor;
    private SerializedProperty newColor;

    private SerializedProperty checkFont;
    private SerializedProperty changeFont;
    private SerializedProperty newFont;
    private SerializedProperty oldFont;

    private SerializedProperty checkSize;
    private SerializedProperty changeSize;
    private SerializedProperty newSize;
    private SerializedProperty oldSize;

    private SerializedProperty changeShadow;
    private SerializedProperty checkShadow;
    private SerializedProperty shadowEffectColor;
    private SerializedProperty shadowEffectDistanceX;
    private SerializedProperty shadowEffectDistanceY;
    private SerializedProperty shadowUseAlpha;

    private SerializedProperty changeOutline;
    private SerializedProperty checkOutline;
    private SerializedProperty outlineEffectColor;
    private SerializedProperty outlineEffectDistanceX;
    private SerializedProperty outlineEffectDistanceY;
    private SerializedProperty outlineUseAlpha;

    private static List<GameObject> list = new List<GameObject>();
    private static Vector2 scrollerPos;
    private void OnEnable()
    {
        this.checkColor = this.serializedObject.FindProperty("checkColor");
        this.changeColor = this.serializedObject.FindProperty("changeColor");
        this.oldColor = this.serializedObject.FindProperty("oldColor");
        this.newColor = this.serializedObject.FindProperty("newColor");

        this.checkFont = this.serializedObject.FindProperty("checkFont");
        this.changeFont = this.serializedObject.FindProperty("changeFont");
        this.oldFont = this.serializedObject.FindProperty("oldFont");
        this.newFont = this.serializedObject.FindProperty("newFont");

        this.checkSize = this.serializedObject.FindProperty("checkSize");
        this.changeSize = this.serializedObject.FindProperty("changeSize");
        this.newSize = this.serializedObject.FindProperty("newSize");
        this.oldSize = this.serializedObject.FindProperty("oldSize");


        this.changeShadow = this.serializedObject.FindProperty("changeShadow");
        this.checkShadow = this.serializedObject.FindProperty("checkShadow");
        this.shadowEffectColor = this.serializedObject.FindProperty("shadowEffectColor");
        this.shadowEffectDistanceX = this.serializedObject.FindProperty("shadowEffectDistanceX");
        this.shadowEffectDistanceY = this.serializedObject.FindProperty("shadowEffectDistanceY");
        this.shadowUseAlpha = this.serializedObject.FindProperty("shadowUseAlpha");

        this.changeOutline = this.serializedObject.FindProperty("changeOutline");
        this.checkOutline = this.serializedObject.FindProperty("checkOutline");
        this.outlineEffectColor = this.serializedObject.FindProperty("outlineEffectColor");
        this.outlineEffectDistanceX = this.serializedObject.FindProperty("outlineEffectDistanceX");
        this.outlineEffectDistanceY = this.serializedObject.FindProperty("outlineEffectDistanceY");
        this.outlineUseAlpha = this.serializedObject.FindProperty("outlineUseAlpha");
    }

    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();

        this.checkColor.boolValue = GUILayout.Toggle(this.checkColor.boolValue, new GUIContent("CheckColor:"), EditorStyles.foldout);
        if (this.checkColor.boolValue)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            this.changeColor.intValue = EditorGUILayout.IntPopup(this.changeColor.intValue, new string[] { "CheckColor", "NotCare" }, new int[] { 0, 1 });
            if (this.changeColor.intValue == 0)
            {
                EditorGUILayout.PropertyField(this.oldColor, new GUIContent("OldColor:"));
                EditorGUILayout.PropertyField(this.newColor, new GUIContent("NewColor:"));
            }
            GUILayout.EndVertical();
        }
           
        this.checkFont.boolValue = GUILayout.Toggle(this.checkFont.boolValue, new GUIContent("CheckFont:"), EditorStyles.foldout);
        if (this.checkFont.boolValue)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            this.changeFont.intValue = EditorGUILayout.IntPopup(this.changeFont.intValue, new string[] { "CheckFont", "NotCare" }, new int[] { 0, 1 });
            if (this.changeFont.intValue == 0)
            {
                EditorGUILayout.PropertyField(this.oldFont, new GUIContent("OldFont:"));
                EditorGUILayout.PropertyField(this.newFont, new GUIContent("NewFont:"));
            }
            GUILayout.EndVertical();
        }

        this.checkSize.boolValue = GUILayout.Toggle(this.checkSize.boolValue, new GUIContent("CheckSize:"), EditorStyles.foldout);
        if (this.checkSize.boolValue)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            this.changeSize.intValue = EditorGUILayout.IntPopup(this.changeSize.intValue, new string[] { "CheckSize", "NotCare" }, new int[] { 0, 1 });
            if (this.changeSize.intValue == 0)
            {
                EditorGUILayout.PropertyField(this.oldSize, new GUIContent("OldSize:"));
                EditorGUILayout.PropertyField(this.newSize, new GUIContent("NewSize:"));
            }
            GUILayout.EndVertical();
        }

        this.checkShadow.boolValue = GUILayout.Toggle(this.checkShadow.boolValue, new GUIContent("ChangeShadow:"), EditorStyles.foldout);
        if (this.checkShadow.boolValue)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            this.changeShadow.intValue = EditorGUILayout.IntPopup(this.changeShadow.intValue, new string[] {"AddShadow", "RemoveShadow", "NotCare" }, new int[] { 0, 1, 2 });
            if (this.changeShadow.intValue == 0)
            {
                EditorGUILayout.PropertyField(this.shadowEffectColor, new GUIContent("EffectColor:"));
                EditorGUILayout.PropertyField(this.shadowEffectDistanceX, new GUIContent("EffectDistanceX:"));
                EditorGUILayout.PropertyField(this.shadowEffectDistanceY, new GUIContent("EffectDistanceY:"));
                EditorGUILayout.PropertyField(this.shadowUseAlpha, new GUIContent("UseAlpha:"));
            }
            GUILayout.EndVertical();
        }

        this.checkOutline.boolValue = GUILayout.Toggle(this.checkOutline.boolValue, new GUIContent("ChangeOutline:"), EditorStyles.foldout);
        if (this.checkOutline.boolValue)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            this.changeOutline.intValue = EditorGUILayout.IntPopup(this.changeOutline.intValue, new string[] { "AddOutline", "RemoveOutline", "NotCare" }, new int[] { 0, 1, 2 });
            if (this.changeOutline.intValue == 0)
            {
                EditorGUILayout.PropertyField(this.outlineEffectColor, new GUIContent("EffectColor:"));
                EditorGUILayout.PropertyField(this.outlineEffectDistanceX, new GUIContent("EffectDistanceX:"));
                EditorGUILayout.PropertyField(this.outlineEffectDistanceY, new GUIContent("EffectDistanceY:"));
                EditorGUILayout.PropertyField(this.outlineUseAlpha, new GUIContent("UseAlpha:"));
            }
            GUILayout.EndVertical();
        }
        this.serializedObject.ApplyModifiedProperties();
        GUILayout.Space(10);
        if (GUILayout.Button("替换"))
        {
            this.ChangeText();
        }
        if (list.Count > 0)
        {
            GUILayout.Label("修改数量：" + list.Count.ToString());
            scrollerPos = EditorGUILayout.BeginScrollView(scrollerPos, EditorStyles.textField, GUILayout.Height(200));
            foreach(var obj in list)
            {
                EditorGUILayout.ObjectField("成功修改的Text：", obj, typeof(GameObject));
            }
            EditorGUILayout.EndScrollView();
        }
    }

    private void ChangeText()
    {
        list.Clear();
        GameObject[] gameObjects = Selection.gameObjects;
        if (gameObjects == null || gameObjects.Length == 0)
        {
            Debug.LogError("No Select!!");
            return;
        }
        var changeText = this.target as ChangeText;
        foreach (var go in gameObjects)
        {
            var texts = go.GetComponentsInChildren<Text>(true);
            foreach (var text in texts)
            {
                if (changeText.Change(text.gameObject))
                    list.Add(text.gameObject);
            }
        }
    }
}
