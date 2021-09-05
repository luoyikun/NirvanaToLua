using UnityEngine;
using UnityEditor;
using System.Text;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

namespace AssetsCheck
{
    class SceneBatchChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Scenes/Map" };

        override public string GetErrorDesc()
        {
            return string.Format("场景中的合批模型没有指定readable。将会导致游戏中静态合批失败");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:scene", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.EndsWith("_Main.unity"))
                {
                    Scene scene = EditorSceneManager.OpenScene(path);

                    bool isError = false;
                    GameObject staticBatching = GameObject.Find("BatchingStatic");
                    if (null == staticBatching)
                    {
                        isError = true;
                    }

                    if (!isError && !this.CheckModelReadable(staticBatching))
                    {
                        isError = true;
                    }

                    GameObject[] rootObjs = scene.GetRootGameObjects();
                    for (int i = 0; i < rootObjs.Length; i++)
                    {
                        MeshCollider[] colliders = rootObjs[i].GetComponentsInChildren<MeshCollider>();
                        foreach (var collider in colliders)
                        {

                            if (!isError && !this.CheckModelReadable(collider.gameObject))
                            {
                                isError = true;
                            }
                        }
                    }

                    if (isError)
                    {
                        CheckItem checkItem = new CheckItem();
                        checkItem.asset = path;
                        this.outputList.Add(checkItem);
                    }

                    EditorSceneManager.CloseScene(scene, true);
                }
            }
        }

        private bool CheckColliderModelReadable(GameObject rootObj)
        {
            MeshCollider[] colliders = rootObj.GetComponentsInChildren<MeshCollider>();
            for (int i = 0; i < colliders.Length; i++)
            {
                MeshFilter meshFilter = colliders[i].GetComponent<MeshFilter>();
                if (null == meshFilter.sharedMesh)
                {
                    Debug.LogFormat("没有指定网格： {0}", meshFilter.gameObject.name);
                    continue;
                }
                string modelPath = AssetDatabase.GetAssetPath(meshFilter.sharedMesh.GetInstanceID());
                if (string.IsNullOrEmpty(modelPath))
                {
                    Debug.LogFormat("没有找到对应的模型： {0}", meshFilter.sharedMesh.name);
                    continue;
                }

                ModelImporter modelImporter = AssetImporter.GetAtPath(modelPath) as ModelImporter;
                if (!modelImporter.isReadable)
                {
                    return false;
                }
            }

            return true;
        }

        private bool CheckModelReadable(GameObject rootObj)
        {
            MeshFilter[] meshFilters = rootObj.GetComponentsInChildren<MeshFilter>();

            string sceneName = SceneManager.GetActiveScene().name;
            int last_index = sceneName.LastIndexOf("_Main");
            if (last_index <= 0)
            {
                Debug.LogErrorFormat("场景名字不符合规范，要以_Main结尾");
                return false;
            }

            sceneName = sceneName.Substring(0, last_index);
            HashSet<string> hashSet = new HashSet<string>();
            for (int i = 0; i < meshFilters.Length; i++)
            {
                if (null == meshFilters[i].sharedMesh)
                {
                    Debug.LogFormat("没有指定网格： {0}", meshFilters[i].gameObject.name);
                    continue;
                }
                string modelPath = AssetDatabase.GetAssetPath(meshFilters[i].sharedMesh.GetInstanceID());
                if (string.IsNullOrEmpty(modelPath))
                {
                    Debug.LogFormat("没有找到对应的模型： {0}", meshFilters[i].sharedMesh.name);
                    continue;
                }

                if (hashSet.Contains(modelPath))
                {
                    continue;
                }

                hashSet.Add(modelPath);
                ModelImporter modelImporter = AssetImporter.GetAtPath(modelPath) as ModelImporter;
                if (!modelImporter.isReadable)
                {
                    return false;
                }
            }

            return true;
        }


        override protected void OnFix(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                string spearator = "    ";
                string path = lines[i].Split(spearator.ToCharArray())[0];
                Scene scene = EditorSceneManager.OpenScene(path);
                if (null == scene)
                {
                    continue;
                }

                GameObject staticBatching = GameObject.Find("BatchingStatic");
                if (null != staticBatching)
                {
                    SetModelReadable(staticBatching, true);
                }

                EditorSceneManager.MarkSceneDirty(scene);
                EditorSceneManager.SaveScene(scene);
                EditorSceneManager.CloseScene(scene, true);
                AssetDatabase.SaveAssets();
            }
        }

        public void SetModelReadable(GameObject rootObj, bool isReadable)
        {
            MeshFilter[] meshFilters = rootObj.GetComponentsInChildren<MeshFilter>();

            string sceneName = SceneManager.GetActiveScene().name;
            int last_index = sceneName.LastIndexOf("_Main");
            if (last_index <= 0)
            {
                Debug.LogErrorFormat("场景名字不符合规范，要以_Main结尾");
                return;
            }

            sceneName = sceneName.Substring(0, last_index);
            HashSet<string> hashSet = new HashSet<string>();
            for (int i = 0; i < meshFilters.Length; i++)
            {
                if (null == meshFilters[i].sharedMesh)
                {
                    Debug.LogFormat("没有指定网格： {0}", meshFilters[i].gameObject.name);
                    continue;
                }
                string modelPath = AssetDatabase.GetAssetPath(meshFilters[i].sharedMesh.GetInstanceID());
                if (string.IsNullOrEmpty(modelPath))
                {
                    Debug.LogFormat("没有找到对应的模型： {0}", meshFilters[i].sharedMesh.name);
                    continue;
                }

                if (hashSet.Contains(modelPath))
                {
                    continue;
                }

                hashSet.Add(modelPath);
                ModelImporter modelImporter = AssetImporter.GetAtPath(modelPath) as ModelImporter;
                if (modelImporter.isReadable != isReadable)
                {
                    ImporterUtils.SetLabel(modelPath, ImporterUtils.ReadableLabel);
                    modelImporter.isReadable = isReadable;
                    modelImporter.SaveAndReimport();
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;

            public CheckItem(string asset)
            {
                this.asset = asset;
            }

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(this.asset);
                return builder;
            }
        }
    }
}
