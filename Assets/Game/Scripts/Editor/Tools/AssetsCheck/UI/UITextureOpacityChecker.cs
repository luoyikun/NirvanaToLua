using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // 检查切的图的合理性
    class UITextureOpacityChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views",
                                        "Assets/Game/UIs/Images2",
                                        "Assets/Game/UIs/Images3",
                                        "Assets/Game/UIs/Images4"};

        // 要检查的最小-最大文件分辨率（太小和太大都没有检查的必要）
        private int minSize = 256 * 128;
        private int maxSize = 512 * 1024;

        // 不透明度低于占比多少则认为是切得不好的
        private float minOpacityRate = 0.2f;

        override public string GetErrorDesc()
        {
            return string.Format("切的图不合理，不透明度占比不能低于{0}%;", Convert.ToInt32(this.minOpacityRate * 100));
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:sprite", checkDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(asset_path);

                if (sprite.texture.width * sprite.texture.height >= minSize &&
                    sprite.texture.width * sprite.texture.height <= maxSize)
                {
                    TextureImporter importer = AssetImporter.GetAtPath(asset_path) as TextureImporter;
                    importer.isReadable = true;
                    importer.SaveAndReimport();
                    Color32[] colors = sprite.texture.GetPixels32();
                    int total_len = colors.Length;
                    int opacity_len = 0;
                    for (int i = 0; i < total_len; i++)
                    {
                        if (colors[i].a > 0)
                        {
                            ++opacity_len;
                        }
                    }

                    importer.isReadable = false;
                    importer.SaveAndReimport();

                    float rate = opacity_len * 1.0f / total_len;
                    if (rate <= minOpacityRate)
                    {
                        CheckItem item = new CheckItem();
                        item.asset = asset_path;
                        item.opacityRate = rate;
                        this.outputList.Add(item);
                    }
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public float opacityRate;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   opacityRate={1}%",
                                asset,
                                Convert.ToInt32(opacityRate * 100)));
                return builder;
            }
        }
    }
}
