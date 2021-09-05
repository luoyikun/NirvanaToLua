using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

namespace BnH {
    public class MemoryCheck : EditorWindow {
        private abstract class ImporterHelpr
        {
            public abstract AssetImporter GetImporter(string path);
            public abstract bool isReadable(AssetImporter importer);
        }

        private class TextureImporterHelper : ImporterHelpr
        {
            public override AssetImporter GetImporter(string path)
            {
                return AssetImporter.GetAtPath(path) as TextureImporter;  
            }

            public override bool isReadable(AssetImporter importer)
            {
                TextureImporter mi = importer as TextureImporter;
                if (mi != null)
                {
                    return mi.isReadable;
                }

                return false;
            }
        }

        private class ModelImporterHelper : ImporterHelpr
        {
            public override AssetImporter GetImporter(string path)
            {
                return AssetImporter.GetAtPath(path) as ModelImporter;  
            }

            public override bool isReadable(AssetImporter importer)
            {
                ModelImporter mi = importer as ModelImporter;
                if (mi != null)
                {
                    return mi.isReadable;
                }

                return false;
            }
        }

        private Object _checkFolder;
        private float _totalMemory = 0;
        private string _totalMemoryLabel;
        private Vector2 _scrollPos;
        private Dictionary<Object, float> _objects = new Dictionary<Object, float>();

        private TextureImporterHelper textureImporterHelper = new TextureImporterHelper();
        private ModelImporterHelper modelImporterHelper = new ModelImporterHelper();

        [MenuItem("Tools/资源检查工具/内存检查/目录内存检查")]
        public static void ShowWindow() {
            EditorWindow.GetWindow<MemoryCheck>("内存检查");
        }

        private void OnGUI() {
            GUILayout.BeginVertical();

            EditorGUI.BeginChangeCheck();
            _checkFolder = EditorGUILayout.ObjectField("拖入搜索目录", _checkFolder, typeof(Object), false);
            if (EditorGUI.EndChangeCheck()) {
                _objects.Clear();
                _totalMemory = 0.0f;
                _totalMemoryLabel = "0kb";
            }

            GUILayout.Space(20);

            GUILayout.BeginHorizontal();

            if (GUILayout.Button("检查贴图内存占用", GUILayout.Width(200))) {
                _CheckTextureMemory();
            }

            if (GUILayout.Button("检查Mesh内存占用", GUILayout.Width(200))) {
                _CheckModelMemory();
            }

            /*if (GUILayout.Button("检查prefab内存占用", GUILayout.Width(200))) {
            }*/

            GUILayout.EndHorizontal();

            GUILayout.Space(20);

            EditorGUILayout.LabelField("总内存占用", _totalMemoryLabel);

            GUILayout.Space(20);

            using (new EditorGUILayoutScrollView(ref _scrollPos, false, true, GUILayout.Height(600), GUILayout.MaxHeight(600))) {

                foreach (var obj in _objects.Keys) {

                    GUILayout.BeginHorizontal();

                    EditorGUILayout.ObjectField(obj, typeof(Object), false);

                    float memory = _objects[obj];
                    string msg;
                    if (memory > 1024) {
                        msg = (memory / 1024.0f) + "M";
                    } else {
                        msg = memory + "K";
                    }

                    EditorGUILayout.LabelField(msg);

                    GUILayout.EndHorizontal();
                }
            }

            GUILayout.EndVertical();
        }

        private void _CheckTextureMemory()
        {
            _CheckMemory(textureImporterHelper);
        }

        private void _CheckModelMemory()
        {
            _CheckMemory(modelImporterHelper);
        }

        private void _CheckMemory(ImporterHelpr importerHelper) {
            if (_checkFolder == null) {
                return ;
            }

            _objects.Clear();
            _totalMemory = 0;

            string folder = AssetDatabase.GetAssetPath(_checkFolder);

            string []files = Directory.GetFiles(folder, "*.*", SearchOption.AllDirectories);

            foreach (var file in files) {
                //TextureImporter importer = AssetImporter.GetAtPath(file) as TextureImporter;
                var importer = importerHelper.GetImporter(file);

                if (importer != null) {
                    Object asset = AssetDatabase.LoadAssetAtPath<Object>(file);
                    float memory = UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(asset) / 1024.0f;

                    if (!importerHelper.isReadable(importer)) {
                        memory /= 2.0f;
                    }

                    _objects.Add(asset, memory);

                    _totalMemory += memory;
                }
            }

            _UpdateTotalMemory();
        }

        private void _UpdateTotalMemory() {
            if (_totalMemory > 1024) {
                _totalMemoryLabel = (_totalMemory / 1024.0f) + "M";
            } else {
                _totalMemoryLabel = _totalMemory + "K";
            }
        }
    }
}