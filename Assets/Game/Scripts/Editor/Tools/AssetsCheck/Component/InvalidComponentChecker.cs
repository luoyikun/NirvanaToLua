using Nirvana;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace AssetsCheck
{
    // 检查出禁用和失效的组件
    class InvalidComponentChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };

        override public string GetErrorDesc()
        {
            return string.Format("用了已经被禁用的组件");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (null == prefab)
                {
                    continue;
                }

                List<string> list = new List<string>();
                // 加载图片资源不能再用同步加载
//                 if (prefab.GetComponentsInChildren<LoadRawImageSync>(true).Length > 0)
//                 {
//                     list.Add("LoadRawImageSync");
//                 }

                if (list.Count > 0)
                {
                    CheckItem check_item = new CheckItem();
                    check_item.asset = path;
                    check_item.invalidComponentList = list;
                    this.outputList.Add(check_item);
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public List<string> invalidComponentList;

            public string MainKey
            {
                get { return string.Format("{0}", asset); }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   components={1}",
                                asset,
                                string.Join(",", this.invalidComponentList.ToArray())));
                return builder;
            }
        }
    }
}
