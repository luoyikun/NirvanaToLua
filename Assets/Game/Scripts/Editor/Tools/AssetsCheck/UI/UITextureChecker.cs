using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // 检查UI纹理图的合理性及导入的设置
    class UITextureChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views",
                                        "Assets/Game/UIs/Images2",
                                        "Assets/Game/UIs/Images3"};

        // 指定单张纹理的大小
        private int maxSpriteWidth = 512;
        private int maxSpriteHeight = 256;

        override public string GetErrorDesc()
        {
            return string.Format("每个Ui上占用的纹理不能超过{0}x{1};", this.maxSpriteWidth, this.maxSpriteHeight) +
                    string.Format("纹理参数设置检查不通过");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:texture", checkDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                var texture = AssetDatabase.LoadAssetAtPath<Texture>(asset_path);
                TextureImporter importer = AssetImporter.GetAtPath(asset_path) as TextureImporter;

                CheckItem item = new CheckItem();
                item.asset = asset_path;

                int flag = 0;
                flag = this.CheckSize(texture, importer, ref item) ? flag : (flag << 1) | 1;
                flag = this.CheckPackingTag(texture, importer, ref item) ? flag : (flag << 1) | 1;
                flag = this.CheckMipMaps(texture, importer, ref item) ? flag : (flag << 1) | 1;
                flag = this.CheckRadable(texture, importer, ref item) ? flag : (flag << 1) | 1;

                if (flag > 0)
                {
                    this.outputList.Add(item);
                }
            }
        }

        private bool CheckSize(Texture texture, TextureImporter importer , ref CheckItem checkItem)
        {
            checkItem.width = texture.width;
            checkItem.height = texture.height;
            checkItem.isVailidSize = checkItem.width * checkItem.height < this.maxSpriteWidth * this.maxSpriteHeight;
            return checkItem.isVailidSize;
        }

        private bool CheckPackingTag(Texture texture, TextureImporter importer, ref CheckItem checkItem)
        {
            checkItem.isPackingTag = !string.IsNullOrEmpty(importer.spritePackingTag);
            return checkItem.isPackingTag;
        }

        private bool CheckMipMaps(Texture texture, TextureImporter importer, ref CheckItem checkItem)
        {
            checkItem.isMipMaps = importer.mipmapEnabled;
            return !checkItem.isMipMaps;
        }

        private bool CheckRadable(Texture texture, TextureImporter importer, ref CheckItem checkItem)
        {
            checkItem.isReadable = importer.isReadable;
            return !checkItem.isReadable;
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public int width;
            public int height;
            public bool isVailidSize;
            public bool isPackingTag;
            public bool isMipMaps;
            public bool isReadable;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);
                if (!isVailidSize) builder.Append(string.Format("   size={0}x{1}", width, height));
                if (!isPackingTag) builder.Append("   packing=false");
                if (isMipMaps) builder.Append("   mipmaps=true");
                if (isReadable) builder.Append("   readable=true");

                return builder;
            }
        }
    }
}
