using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    class UIEffectTextureChecker : BaseChecker
    {
        // 指定要检查的特效文件夹
        private string[] checkDirs = { "Assets/Game/Effects2/Textures" };

        // 指定要搜索引用的文件夹
        private string[] searchDirs = { "Assets/Game"};

        override public string GetErrorDesc()
        {
            return string.Format("特效纹理只用于UI特效，却开启了mipmap");
        }

        override protected void OnCheck()
        {
            AssetRefrence.Build("t:prefab", searchDirs);

            string[] guids = AssetDatabase.FindAssets("t:texture", checkDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                string[] ref_assets = AssetRefrence.GetRefAssets(asset_path);
                int ref_prefab_count = 0;
                int ref_ui_prefab_count = 0;

                for (int i = 0; i < ref_assets.Length; i++)
                {
                    GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(ref_assets[i]);
                    if (null != go)
                    {
                        ++ref_prefab_count;
                        if (go.GetComponentsInChildren<RectTransform>(true).Length > 0)
                        {
                            ++ref_ui_prefab_count;
                        }
                    }
                }

                // 所有引用该资源的prefab都是有RectTransform的，则认为是UI类的特效资源
                if (ref_prefab_count > 0 && ref_prefab_count == ref_ui_prefab_count)
                {
                    TextureImporter importer = TextureImporter.GetAtPath(asset_path) as TextureImporter;
                    if (null != importer && importer.mipmapEnabled)
                    {
                        CheckItem item = new CheckItem(asset_path);
                        this.outputList.Add(item);
                    }
                }
            }
        }

        override protected void OnFix(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (!string.IsNullOrEmpty(lines[i]))
                {
                    TextureImporter importer = TextureImporter.GetAtPath(lines[i]) as TextureImporter;
                    if (null != importer)
                    {
                        importer.mipmapEnabled = false;
                        importer.SaveAndReimport();
                    }
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
                builder.Append(asset);
                return builder;
            }
        }
    }
}
