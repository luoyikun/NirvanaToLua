using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // 检查UI纹理的打包图集大小
    class UIAtlasChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs"};

        // 图集的最大大小
        private int maxAltasWidth = 1024;
        private int maxAltasHeight = 1024;

        override public string GetErrorDesc()
        {
            return string.Format("打包的图集大小不能超过{0}x{1}", maxAltasWidth, maxAltasHeight);
        }

        override protected void OnCheck()
        {
            AtlasPacker packer = new AtlasPacker();
            packer.StartPack(checkDirs);

            Dictionary<string, AltasPackRecordItem> recordDic = new Dictionary<string, AltasPackRecordItem>();
            packer.ReadRecods(recordDic);

            foreach (var kv in recordDic)
            {
                if (kv.Value.altasWidth >= maxAltasWidth && kv.Value.altasHeight >= maxAltasHeight)
                {
                    CheckItem item = new CheckItem();
                    item.packingTag = kv.Value.packTag;
                    item.atlasWidth = kv.Value.altasWidth;
                    item.atlasHeight = kv.Value.altasHeight;
                    this.outputList.Add(item);
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string packingTag;
            public int atlasWidth;
            public int atlasHeight;

            public string MainKey
            {
                get { return this.packingTag; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   size={1}x{2}",
                                packingTag,
                                atlasWidth,
                                atlasHeight));
                return builder;
            }
        }
    }
}
