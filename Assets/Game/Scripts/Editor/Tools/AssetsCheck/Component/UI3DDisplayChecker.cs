using Nirvana;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    class UI3DDisplayChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };

        private int maxResolutionX = 1200;
        private int maxResolutionY = 800;

        override public string GetErrorDesc()
        {
            return string.Format("UI3DDisplayChecker的分辨率大小不能超过{0}x{1}", maxResolutionX, maxResolutionY);
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

                UI3DDisplay[] components = prefab.GetComponentsInChildren<UI3DDisplay>(true);
                for (int i = 0; i < components.Length; i++)
                {
//                     if (components[i].ResolutionX > this.maxResolutionX || components[i].ResolutionY > this.maxResolutionY)
//                     {
//                         CheckItem check_item = new CheckItem();
//                         check_item.asset = path;
//                         check_item.width = components[i].ResolutionX;
//                         check_item.height = components[i].ResolutionY;
//                         this.outputList.Add(check_item);
//                     }
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public int width;
            public int height;

            public string MainKey
            {
                get { return string.Format("{0}", asset); }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   size={1}x{2}",
                                this.asset,
                                this.width,
                                this.height));
                return builder;
            }
        }
    }
}
