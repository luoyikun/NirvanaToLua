using UnityEngine;
using UnityEditor;

//绑定特性描述类
[CustomPropertyDrawer(typeof(ReNameAttribute))]
public class ReNameDrawer : PropertyDrawer
{
    private ReNameAttribute FLAttribute
    {
        //获取绘制的标签
        get
        {
            return (ReNameAttribute)attribute;
        }
    }
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        //重新绘制标签
        EditorGUI.PropertyField(position, property, new GUIContent(FLAttribute.label), true);
    }
}
