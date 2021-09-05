using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    class ActorReceivedShadowChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Actors" };

        override public string GetErrorDesc()
        {
            return string.Format("角色模型相关的不应该接收阴影，费性能");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                var components = gameobj.GetComponentsInChildren<Renderer>(true);
                for (int i = 0; i < components.Length; i++)
                {
                    if (components[i].receiveShadows)
                    {
                        CheckItem item = new CheckItem();
                        item.asset = path;
                        this.outputList.Add(item);
                    }
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

                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(lines[i]);
                if (null == gameobj)
                {
                    continue;
                }

                var components = gameobj.GetComponentsInChildren<Renderer>(true);
                for (int j = 0; j < components.Length; j++)
                {
                    if (components[j].receiveShadows)
                    {
                        components[j].receiveShadows = false;
                        PrefabUtility.ResetToPrefabState(gameobj);
                        PrefabUtility.SetPropertyModifications(gameobj, new PropertyModification[] { });
                    }
                }
            }

            AssetDatabase.SaveAssets();
        }

        struct CheckItem : ICheckItem
        {
            public string asset;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);
                return builder;
            }
        }
    }
}
