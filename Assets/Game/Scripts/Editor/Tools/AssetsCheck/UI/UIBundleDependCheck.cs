using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Text;
using Nirvana;

namespace AssetsCheck
{
    // Ui bundle之间的依赖关系检查，理论上一个功能模块不应该去依赖账其他功能模块的资源
    class UIBundleDependCheck : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = {
            "Assets/Game/UIs/Views/MiscpreLoad",
        };

        // 排除依赖的目录 -- 这个是必须一样的AB名字(依赖于一些公共目录是正常的）
        private HashSet<string> excludeDependBudlesHashSet = new HashSet<string> {
            //"uis/images",
            //"uis/fonts",
            "uis/shared",
            "uis/widgets_prefab",
            "uis/ttf",
            "uis/animations",
            "uis/views/mainui/images_atlas",
            "uis/views/mainui/icon_atlas",
            "uis/views/miscpreload_prefab",
            "uis/views/miscpreload/images_atlas",
            "shaders",
            "foundation",
            "environments/shared",
        };

        // 排除依赖的目录(模糊搜索) -- 这个有相关的AB名字不需要完整的(依赖于一些公共目录是正常的）
        private List<string> ab_path = new List<string>{
            "uis/images",
            "uis/frameanim",
            //"uis/views/mainui/images",
            "uis/fonts",
            "uis/rawimages",
            "uis/views/commonwidgets",
        };

        // 是否输出详细的依赖信息
        private static bool isOutputDetailDependInfo = true;

        private Dictionary<string, string> cacheBundleNameDic = new Dictionary<string, string>();
        private Dictionary<string, List<DependItem>> bunldeDependDic = new Dictionary<string, List<DependItem>>();

        // 获得错误描述
        override public string GetErrorDesc()
        {
            return "模块与模块之间禁止互相引用资源";
        }

        override protected void OnCheck()
        {
            bunldeDependDic.Clear();
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);

            // 计算依赖
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                string bundle_name = this.GetBundleName(path);
                List<DependItem> depend_list;
                if (!bunldeDependDic.TryGetValue(bundle_name, out depend_list))
                {
                    depend_list = new List<DependItem>();
                    bunldeDependDic.Add(bundle_name, depend_list);
                }

                this.CalcStaticsDepend(path, depend_list);          // 计算Unity的静态依赖
                this.CalcDynamicDepend(path, depend_list);      // 计算动态依赖，如手动指定资源路径
            }

            // 输出依赖了其他模块的
            foreach (var kv in bunldeDependDic)
            {
                if (kv.Value.Count == 0)
                {
                    continue;
                }

                CheckItem item = new CheckItem();
                item.asset = kv.Key;
                item.dependItems = kv.Value.ToArray();
                this.outputList.Add(item);
            }
        }

        // 根据内容匹配出列表中的内容是否存在
        private bool GetMatching(string bundle_name)
        {
            var is_matching = false;
            foreach (var item in ab_path)
            {
                if (bundle_name.Contains(item))
                {
                    is_matching = true;
                    break;
                }
            }
            return is_matching;
        }

        private string GetReplaceData(string str)
        {
            var new_str = str.Replace("_prefab", "");
            new_str = new_str.Replace("/images/nopack_atlas", "");
            new_str = new_str.Replace("/images_atlas", "");
            new_str = new_str.Replace("_atlas", "");
            new_str = new_str.Replace("_images", "");
            return new_str;
        }

        private void CalcStaticsDepend(string path, List<DependItem> depend_list)
        {
            string bundle_name = this.GetBundleName(path);
            string[] depends = AssetDatabase.GetDependencies(path);
            for (int i = 0; i < depends.Length; i++)
            {
                string depend_bundle_name = this.GetBundleName(depends[i]);
                if (bundle_name != depend_bundle_name                                               // 相同的bundle排除
                    && !string.IsNullOrEmpty(depend_bundle_name)                                    // 没有指定bundle排除
                    && !excludeDependBudlesHashSet.Contains(depend_bundle_name)                     // 公共模块排除
                    && !GetMatching(depend_bundle_name)                                             // 公共模块排除 -- 这个取的是模糊的
                    && GetReplaceData(bundle_name) != GetReplaceData(depend_bundle_name)            // 自已模块下的排除
                    && bundle_name + "_images" != GetReplaceData(depend_bundle_name))               // 自已模块下的images排除
                {
                    DependItem depend_item = new DependItem();
                    depend_item.isStatics = true;
                    depend_item.bundleName = depend_bundle_name;
                    depend_item.assetPath = depends[i];
                    depend_item.ownerAsset = path;
                    depend_list.Add(depend_item);
                }
            }
        }

        private void CalcDynamicDepend(string path, List<DependItem> depend_list)
        {
            string bundle_name = this.GetBundleName(path);
            GameObject gamobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            UIVariableTable[] components = gamobj.GetComponentsInChildren<UIVariableTable>(true);
            
            for (int i = 0; i < components.Length; i++)
            {
                UIVariable[] variables = components[i].Variables;
                for (int j = 0; j < variables.Length; j++)
                {
                    UIVariable variable = variables[j];
                    if (variable.Type == UIVariableType.Asset)
                    {
                        AssetID asset = variable.GetAsset();
                        if (!string.IsNullOrEmpty(asset.BundleName)                                         // 手动指定了值 
                            && asset.BundleName != bundle_name                                              // 不属于同个assetbundle
                            && !excludeDependBudlesHashSet.Contains(asset.BundleName)                       // 公共模块排除
                            && !GetMatching(asset.BundleName)                                               // 公共模块排除 -- 这个取的是模糊的
                            && GetReplaceData(bundle_name) != GetReplaceData(asset.BundleName)              // 自已模块下的排除
                            && bundle_name + "_images" != GetReplaceData(asset.BundleName))                 // 自已模块下的prefab排除
                        {
                            DependItem depend_item = new DependItem();
                            depend_item.isStatics = false;
                            depend_item.bundleName = asset.BundleName;
                            depend_item.assetName = asset.AssetName;
                            depend_item.ownerPath = path + "@" + this.GetDynamicOwnerPath(components[i].gameObject);
                            depend_list.Add(depend_item);
                        }
                    }
                }
            }
        }

        private string GetDynamicOwnerPath(GameObject gameObject)
        {
            Transform tf = gameObject.transform;
            string path = "";
            while (tf)
            {
                path = tf.gameObject.name + (string.IsNullOrEmpty(path) ? path : "/" + path);
                tf = tf.parent;
            }

            return path;
        }

        private string GetBundleName(string path)
        {
            string bundle_name;
            if (!cacheBundleNameDic.TryGetValue(path,out bundle_name))
            {
                bundle_name = AssetImporter.GetAtPath(path).assetBundleName;
                cacheBundleNameDic.Add(path, bundle_name);
            }

            return bundle_name;
        }

        struct DependItem
        {
            public bool isStatics;                                  // 是否是静态引用
            public string bundleName;                               // 依赖的bundleName
            public string assetPath;                                // 依赖的是什么资源
            public string assetName;                                // 依赖的资源名
            public string ownerAsset;                               // 持有这个依赖项的是谁
            public string ownerPath;                                // 持有这个依赖项的路径
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public DependItem[] dependItems;

            public string MainKey
            {
                get { return this.asset; }
            }

            private void GetOutputGroup(Dictionary<string, List<DependItem>> bundle_dic)
            {
                for (int i = 0; i < dependItems.Length; i++)
                {
                    DependItem item = dependItems[i];

                    if (string.IsNullOrEmpty(item.bundleName))
                    {
                        continue;
                    }

                    List<DependItem> list;
                    if (!bundle_dic.TryGetValue(item.bundleName, out list))
                    {
                        list = new List<DependItem>();
                        bundle_dic.Add(item.bundleName, list);
                    }

                    list.Add(item);
                }
            }
            public StringBuilder Output()
            {
                Dictionary<string, List<DependItem>> bundle_dic = new Dictionary<string, List<DependItem>>();
                this.GetOutputGroup(bundle_dic);

                StringBuilder builder = new StringBuilder();
                builder.Append(asset + ":");

                foreach (var kv in bundle_dic)
                {
                    builder.Append(string.Format("\n     {0}", kv.Key));    // 依赖的AB包路径

                    if (isOutputDetailDependInfo)
                    {
                        List<DependItem> list = kv.Value;
                        for (int i = 0; i < list.Count; i++)                                // 依赖的AB包里的哪些文件
                        {
                            if (list[i].isStatics)
                            {
                                builder.Append(string.Format("\n        静态引用 ：{0} 被 {1} 依赖", list[i].assetPath, list[i].ownerAsset));
                            }
                            else
                            {
                                builder.Append(string.Format("\n        动态引用 ：在 {0} 指定使用 {1} 包里的 {2} 资源", list[i].ownerPath, list[i].bundleName, list[i].assetName));
                            }
                        }
                    }
                }
                
                return builder;
            }
        }
    }
}