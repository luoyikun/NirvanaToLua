using Game;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace AssetsCheck
{
    // 检查出没有静态引用并且没有标记动态引用的资源。包括prefab, mat, texture, textAsset
    class GameObjectAttachMissingChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Scenes/Map" };

        override public string GetErrorDesc()
        {
            return string.Format("GameObjectAttach里记录的guid与assetbundle名字不符，将导致资源丢失");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<UnityEngine.GameObject>(path);
                GameObjectAttach[] attachs = prefab.GetComponentsInChildren<GameObjectAttach>(true);
                foreach (var item in attachs)
                {
                    if (item.IsGameobjectMissing())
                    {
                        CheckItem check_item = new CheckItem(path, item.gameObject.name);
                        this.outputList.Add(check_item);
                    }
                }
            }

            string[] scene_guids = AssetDatabase.FindAssets("t:Scene", checkDirs);
            foreach (string guid in scene_guids)
            {
                string scene_path = AssetDatabase.GUIDToAssetPath(guid);
                Scene scene = EditorSceneManager.OpenScene(scene_path);
                if (scene.name.EndsWith("_Main"))
                {
                    GameObject[] root_objs = scene.GetRootGameObjects();
                    for (int i = 0; i < root_objs.Length; i++)
                    {
                        GameObjectAttach[] attachs = root_objs[i].GetComponentsInChildren<GameObjectAttach>(true);
                        foreach (var item in attachs)
                        {
                            if (item.IsGameobjectMissing())
                            {
                                CheckItem check_item = new CheckItem(scene_path, item.gameObject.name);
                                this.outputList.Add(check_item);
                            }
                        }
                    }
                }
            }



            //             string[] scene_guids = AssetDatabase.FindAssets("t:Scene", checkDirs);
            //             foreach (string guid in scene_guids)
            //             {
            //                 string scene_path = AssetDatabase.GUIDToAssetPath(guid);
            //                 Scene scene = EditorSceneManager.OpenScene(scene_path);
            //                 GameObject[] root_objs = scene.GetRootGameObjects();
            //                 for (int i = 0; i < root_objs.Length; i++)
            //                 {
            //                     SceneEffect[] attachs = root_objs[i].GetComponentsInChildren<SceneEffect>(true);
            //                     foreach (var item in attachs)
            //                     {
            //                         if (item.IsGameobjectMissing())
            //                         {
            //                             CheckItem check_item = new CheckItem(scene_path, item.gameObject.name);
            //                             this.outputList.Add(check_item);
            //                         }
            //                     }
            //                 }
            //             }
        }

        override protected void OnFix(string[] lines)
        {
            this.FixPrefabGameObjectAttach(lines);

            this.FixSceneGameObjectAttach(lines);

            //this.FixSceneLogicGameObjectAttach(lines);
        }

        private void FixPrefabGameObjectAttach(string[] lines)
        {
            foreach (var line in lines)
            {
                if (string.IsNullOrEmpty(line))
                {
                    continue;
                }

                string path = line.Split(' ')[0];
                string goName = line.Split(' ')[1];

                if (!path.EndsWith(".prefab"))
                {
                    continue;
                }

                GameObject prefab = AssetDatabase.LoadAssetAtPath<UnityEngine.GameObject>(path);
                if (null == prefab)
                {
                    continue;
                }

                GameObjectAttach[] attachs = prefab.GetComponentsInChildren<GameObjectAttach>(true);
                foreach (var item in attachs)
                {
                    item.RefreshAssetBundleName();
                    if (item.IsGameobjectMissing())
                    {
                        Debug.LogErrorFormat("预制体特效修复失败：{0} {1}", path, goName);
                    }
                    else
                    {
                        PrefabUtility.ResetToPrefabState(prefab);
                        PrefabUtility.SetPropertyModifications(prefab, new PropertyModification[] { });
                    }
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private void FixSceneGameObjectAttach(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                string spearator = "    ";
                string path = lines[i].Split(spearator.ToCharArray())[0];

                if (!path.EndsWith(".unity"))
                {
                    continue;
                }

                Scene scene = EditorSceneManager.OpenScene(path);
                if (null == scene)
                {
                    continue;
                }

                GameObject[] root_objs = scene.GetRootGameObjects();
                for (int j = 0; j < root_objs.Length; j++)
                {
                    var attachs = root_objs[j].GetComponentsInChildren<GameObjectAttach>(true);
                    foreach (var item in attachs)
                    {
                        item.RefreshAssetBundleName();
                        if (item.IsGameobjectMissing())
                        {
                            Debug.LogErrorFormat("场景特效修复失败：{0} {1}", path, item.gameObject.name);
                        }
                    }
                }

                EditorSceneManager.MarkSceneDirty(scene);
                EditorSceneManager.SaveScene(scene);
                EditorSceneManager.CloseScene(scene, true);
                AssetDatabase.SaveAssets();
            }
        }

        private void FixSceneLogicGameObjectAttach(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                string spearator = "    ";
                string path = lines[i].Split(spearator.ToCharArray())[0];

                if (!path.EndsWith(".unity"))
                {
                    continue;
                }

                Scene scene = EditorSceneManager.OpenScene(path);
                if (null == scene)
                {
                    continue;
                }

                GameObject[] root_objs = scene.GetRootGameObjects();
                for (int j = 0; j < root_objs.Length; j++)
                {
                    var attachs = root_objs[j].GetComponentsInChildren<SceneEffect>(true);
                    foreach (var item in attachs)
                    {
                        item.RefreshAssetBundleName();
                        if (item.IsGameobjectMissing())
                        {
                            Debug.LogErrorFormat("场景Logic特效修复失败：{0} {1}", path, item.gameObject.name);
                        }
                    }
                }

                EditorSceneManager.MarkSceneDirty(scene);
                EditorSceneManager.SaveScene(scene);
                EditorSceneManager.CloseScene(scene, true);
                AssetDatabase.SaveAssets();
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string gameobjectName;

            public CheckItem(string asset, string gameobjectName)
            {
                this.asset = asset;
                this.gameobjectName = gameobjectName;
            }

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0} {1}", asset, gameobjectName));
                return builder;
            }
        }
    }
}
