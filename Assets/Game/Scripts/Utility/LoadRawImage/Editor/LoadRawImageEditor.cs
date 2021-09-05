using UnityEngine;
using UnityEditor;
using System.IO;

namespace Game
{
    [CustomEditor(typeof(LoadRawImage))]
    public class LoadRawImageEditor : Editor
    {
        private Texture texture;

        private void OnEnable()
        {
            LoadRawImage self = target as LoadRawImage;

            if (string.IsNullOrEmpty(self.BundleName)|| string.IsNullOrEmpty(self.AssetName))
            {
                return;
            }

            texture = EditorResourceMgr.LoadObject(self.BundleName, self.AssetName, typeof(Texture)) as Texture;
        }

        public override void OnInspectorGUI()
        {
            LoadRawImage self = target as LoadRawImage;
            bool dirty = false;

            EditorGUI.BeginChangeCheck();

            texture = EditorGUILayout.ObjectField("Texture", texture, typeof(Object), false) as Texture;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(target, "Change LoadRawImage Asset");
                dirty = true;

                AssetImporter importer = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(texture));
                self.BundleName = importer.assetBundleName;
                self.AssetName = Path.GetFileName(importer.assetPath);

                self.UpdateAsset();
            }

            EditorGUI.indentLevel += 1;

            EditorGUILayout.LabelField("BundleName", self.BundleName);
            EditorGUILayout.LabelField("AssetName", self.AssetName);

            EditorGUI.indentLevel -= 1;

            self.AutoFitNativeSize = EditorGUILayout.Toggle("AutoFitNativeSize", self.AutoFitNativeSize);
            self.AutoUpdateAspectRatio = EditorGUILayout.Toggle("AutoUpdateAspectRatio", self.AutoUpdateAspectRatio);

            if (dirty || GUI.changed)
            {
                EditorUtility.SetDirty(self);
            }
        }
    }
}
