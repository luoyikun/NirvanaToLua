using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Text;
using Nirvana;

namespace AssetsCheck
{
    class EffectDependUIResChecker : BaseChecker
    {
        private string UiDir = "Assets/Game/UIs/Views";

        // 指定要检查的文件夹
        private string[] checkDirs = {
            "Assets/Game/Effects2",
        };

        // 获得错误描述
        override public string GetErrorDesc()
        {
            return "特效里禁止直接用UI里的文件";
        }

        // 是否输出详细的依赖信息
        private static bool isOutputDetailDependInfo = true;

        private Dictionary<string, string> cacheBundleNameDic = new Dictionary<string, string>();

        override protected void OnCheck()
        {
            CalcDepend(AssetDatabase.FindAssets("t:prefab", checkDirs));
            CalcDepend(AssetDatabase.FindAssets("t:material", checkDirs));
        }

        private void CalcDepend(string[] guids)
        {
            // 计算依赖
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                string[] depends = AssetDatabase.GetDependencies(path);
                for (int i = 0; i < depends.Length; i++)
                {
                    if (depends[i].StartsWith(UiDir))
                    {
                        CheckItem check_item = new CheckItem();
                        check_item.asset = path;
                        check_item.dependAsset = depends[i];
                        this.outputList.Add(check_item);
                    }
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string dependAsset;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0} {1}", asset, dependAsset));

                return builder;
            }
        }
    }
}