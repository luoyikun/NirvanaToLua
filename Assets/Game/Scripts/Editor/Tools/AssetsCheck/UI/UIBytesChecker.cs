using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // UI目录下有多余的bytes文件
    class UIBytesChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views",
                                       "Assets/Game/UIs/Images2",
                                       "Assets/Game/UIs/Images3",
                                       "Assets/Game/UIs/Images4"};

        override public string GetErrorDesc()
        {
            return string.Format("有bytes资源图片需处理");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:textasset", checkDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);

                CheckItem item = new CheckItem();
                item.asset = asset_path;
                this.outputList.Add(item);
            }
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
