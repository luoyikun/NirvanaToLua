#if !UNITY_5_4_OR_NEWER
using UnityEngine;
using UnityEditor;

namespace UiParticles
{
    [CustomPropertyDrawer(typeof(UiParticleMinMaxCurve))]
    public class UiParticleMinMaxCurveDrawer : PropertyDrawer
    {
        private bool _isOn = false;



        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {

            EditorGUI.BeginProperty(position, label, property);


            Rect drawRect = position;
            drawRect.height = EditorGUIUtility.singleLineHeight;

            _isOn = EditorGUI.Foldout(drawRect, _isOn, label);

            if (_isOn)
            {

                var indent = EditorGUI.indentLevel;
                EditorGUI.indentLevel = 1;


                var curveModePropertie = property.FindPropertyRelative("CurveMode");
                var particleSystemCurveMode = (ParticleSystemCurveMode) curveModePropertie.enumValueIndex;

                drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;

                EditorGUI.PropertyField(drawRect, curveModePropertie, new GUIContent("MinMax Curve Mode"));

                switch (particleSystemCurveMode)
                {
                    case ParticleSystemCurveMode.Constant:
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MinConst"),
                            new GUIContent("Const"));

                        break;
                    case ParticleSystemCurveMode.Curve:
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MinCurve"),
                            new GUIContent("Curve"));
                        break;
                    case ParticleSystemCurveMode.TwoCurves:
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MinCurve"),
                            new GUIContent("Min"));
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MaxCurve"),
                            new GUIContent("Max"));
                        break;
                    case ParticleSystemCurveMode.TwoConstants:
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MinConst"),
                            new GUIContent("Min"));
                        drawRect.y += EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
                        EditorGUI.PropertyField(drawRect, property.FindPropertyRelative("MaxConst"),
                            new GUIContent("Max"));
                        break;
                }

                // Set indent back to what it was
                EditorGUI.indentLevel = indent;
            }

            EditorGUI.EndProperty();
        }



        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            if (!_isOn)
                return EditorGUIUtility.singleLineHeight;
            var curveModePropertie = property.FindPropertyRelative("CurveMode");
            var particleSystemCurveMode = (ParticleSystemCurveMode) curveModePropertie.enumValueIndex;
            switch (particleSystemCurveMode)
            {
                case ParticleSystemCurveMode.Constant:
                    return 3 * EditorGUIUtility.singleLineHeight + 2 * EditorGUIUtility.standardVerticalSpacing;
                    break;
                case ParticleSystemCurveMode.Curve:
                    return 3 * EditorGUIUtility.singleLineHeight + 2 * EditorGUIUtility.standardVerticalSpacing;
                    break;
                case ParticleSystemCurveMode.TwoCurves:
                    return 4 * EditorGUIUtility.singleLineHeight + 3 * EditorGUIUtility.standardVerticalSpacing;
                    break;
                case ParticleSystemCurveMode.TwoConstants:
                    return 4 * EditorGUIUtility.singleLineHeight + 3 * EditorGUIUtility.standardVerticalSpacing;
                    break;
            }

            return 0;
        }
    }
}
#endif
