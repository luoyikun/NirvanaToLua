using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using System.Text;

namespace AssetsCheck
{
    // 美术在编辑场景时常犯的事
    // 1.用boxcollider时会使用cube+boxcollider的方式
    // 2.场景上的点光源没有设置editorOnly，没有设置baked模式

    class SceneEditChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Scenes/Map" };

        override public string GetErrorDesc()
        {
            return string.Format("1.boxcollider上面挂了多余的组件");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:scene", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.EndsWith("_Main.unity") || path.EndsWith("_Detail.unity"))
                {
                    Scene scene = EditorSceneManager.OpenScene(path);
                    CheckItem item = new CheckItem();
                    item.asset = path;

                    this.CheckSceneCollider(scene, ref item);
                    this.CheckLight(scene, ref item);
                    this.CheckLightmapping(scene, ref item);

                    if (item.invalidComponentCount > 0
                        || item.illegalLightCount > 0
                        || item.lightmappingCount > 0)
                    {
                        this.outputList.Add(item);
                    }

                    EditorSceneManager.CloseScene(scene, true);
                }
            }
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

                this.FixSceneCollider(scene);
                this.FixLight(scene);
                this.FixLightmapping(scene);

                EditorSceneManager.MarkSceneDirty(scene);
                EditorSceneManager.SaveScene(scene);
                EditorSceneManager.CloseScene(scene, true);
                AssetDatabase.SaveAssets();
            }
        }

        private void CheckSceneCollider(Scene scene, ref CheckItem checkItem)
        {
            GameObject[] root_objs = scene.GetRootGameObjects();
            for (int i = 0; i < root_objs.Length; i++)
            {
                var colliders = root_objs[i].GetComponentsInChildren<BoxCollider>(true);
                for (int j = 0; j < colliders.Length; j++)
                {
                    var components = colliders[j].GetComponents<Component>();
                    if (components.Length >= 3) // 只允许存在BoxCollider和Transform
                    {
                        checkItem.invalidComponentCount += components.Length - 2;
                    }
                }
            }
        }

        private void FixSceneCollider(Scene scene)
        {
            GameObject[] root_objs = scene.GetRootGameObjects();
            for (int i = 0; i < root_objs.Length; i++)
            {
                var colliders = root_objs[i].GetComponentsInChildren<BoxCollider>(true);
                for (int j = 0; j < colliders.Length; j++)
                {
                    var components = colliders[j].GetComponents<Component>();
                    foreach (var item in components)
                    {
                        if (item.GetType() != typeof(BoxCollider) && item.GetType() != typeof(Transform))
                        {
                            GameObject.DestroyImmediate(item, true);
                        }
                    }
                }
            }
        }

        private void CheckLight(Scene scene, ref CheckItem checkItem)
        {
            GameObject[] root_objs = scene.GetRootGameObjects();
            for (int i = 0; i < root_objs.Length; i++)
            {
                var lights = root_objs[i].GetComponentsInChildren<Light>(true);
                for (int j = 0; j < lights.Length; j++)
                {
                    Light light = lights[j];
                    if (!light.isBaked && light.type == LightType.Point)
                    {
                        if (light.gameObject.tag != "EditorOnly")
                        {
                            ++checkItem.illegalLightCount;
                        }
                    }
                }
            }
        }

        private void CheckLightmapping(Scene scene, ref CheckItem checkItem)
        {
            if (Lightmapping.realtimeGI)
            {
                ++checkItem.lightmappingCount;
            }
        }

        private void FixLight(Scene scene)
        {
            GameObject[] root_objs = scene.GetRootGameObjects();
            for (int i = 0; i < root_objs.Length; i++)
            {
                var lights = root_objs[i].GetComponentsInChildren<Light>(true);
                for (int j = 0; j < lights.Length; j++)
                {
                    Light light = lights[j];
                    if (!light.isBaked && light.type == LightType.Point)
                    {
                        light.gameObject.tag = "EditorOnly";
                    }
                }
            }
        }

        private void FixLightmapping(Scene scene)
        {
            if (Lightmapping.realtimeGI)
            {
                Lightmapping.realtimeGI = false;
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public int invalidComponentCount;
            public int illegalLightCount;
            public int lightmappingCount;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(this.asset);

                if (invalidComponentCount > 0)
                    builder.Append(string.Format("   invalidComponentCount={0}", invalidComponentCount));

                if (illegalLightCount > 0)
                    builder.Append(string.Format("   illegalLightCount={0}", illegalLightCount));

                if (lightmappingCount > 0)
                    builder.Append(string.Format("   lightmappingCount={0}", lightmappingCount));

                return builder;
            }
        }
    }
}
