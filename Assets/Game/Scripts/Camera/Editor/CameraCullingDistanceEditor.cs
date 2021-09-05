using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CameraCullingDistance))]
public class CameraCullingDistanceEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        CameraCullingDistance self = (CameraCullingDistance)target;

        for (int i = 0; i < 32; ++i)
        {
            string layerName = LayerMask.LayerToName(i);
            if (layerName.Length > 0)
            {
                float distance = 0;
                for (int j = 0; j < self.CullDistances.Count; ++j)
                {
                    CameraLayerInfo info = self.CullDistances[j];
                    if (info.layer == i)
                    {
                        distance = info.distance;
                    }
                }

                EditorGUI.BeginChangeCheck();
                distance = EditorGUILayout.FloatField(layerName, distance);
                if (EditorGUI.EndChangeCheck())
                {
                    self.SetDistance(i, distance);
                }
            }
        }

        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            EditorUtility.SetDirty(self);
        }
    }
}
