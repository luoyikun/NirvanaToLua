using UnityEngine;
using UnityEditor;
using System.IO;

namespace Game
{
    [CustomEditor(typeof(GameObjectAttach))]
    public class GameObjectAttachNewEditor : Editor
    {
        private GameObject asset;

        private void OnEnable()
        {
            GameObjectAttach self = target as GameObjectAttach;

            if (string.IsNullOrEmpty(self.BundleName) || string.IsNullOrEmpty(self.AssetName))
            {
                return;
            }
     
            asset = EditorResourceMgr.LoadGameObject(self.BundleName, self.AssetName);
        }

        public override void OnInspectorGUI()
        {
            GameObjectAttach self = target as GameObjectAttach;
            bool dirty = false;

            EditorGUI.BeginChangeCheck();

            asset = EditorGUILayout.ObjectField("AttachObj", asset, typeof(GameObject), false) as GameObject;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(target, "Change GameObject Asset");
                dirty = true;

                string asset_path = AssetDatabase.GetAssetPath(asset);
                AssetImporter importer = AssetImporter.GetAtPath(asset_path);
                self.BundleName = importer.assetBundleName;
                self.AssetName = Path.GetFileName(importer.assetPath);
                self.AssetGuid = AssetDatabase.AssetPathToGUID(asset_path);

                var previewObj = self.GetComponent<Nirvana.PreviewObject>();
                if (previewObj)
                {
                    previewObj.SetPreview(Instantiate(asset));
                }
            }

            EditorGUI.indentLevel += 1;

            EditorGUILayout.LabelField("BundleName", self.BundleName);
            EditorGUILayout.LabelField("AssetName", self.AssetName);

            if (GUILayout.Button("根据GUID修复丢失的物体"))
            {
                self.RefreshAssetBundleName();
                asset = EditorResourceMgr.LoadGameObject(self.BundleName, self.AssetName);
            }

            EditorGUI.indentLevel -= 1;

            self.IsSyncLayer = EditorGUILayout.Toggle("IsSyncLayer", self.IsSyncLayer);

            if (dirty || GUI.changed)
            {
                EditorUtility.SetDirty(self);
            }
        }

    }
}
