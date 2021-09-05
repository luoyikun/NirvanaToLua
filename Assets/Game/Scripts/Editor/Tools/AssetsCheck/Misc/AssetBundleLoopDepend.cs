using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using System.Text;

namespace AssetsCheck
{
    class AssetBundleDependNode
    {
        public string headNodeName;
        public string nodeName;
        public AssetBundleDependNode parentNode;
    }

    public class AssetBundleLoopDepend : BaseChecker
    {
        override public string GetErrorDesc()
        {
            return string.Format("AssetBundle禁止互相依赖");
        }

        override protected void OnCheck()
        {
            string assetBundlePath = Path.Combine(Application.dataPath, "../../AssetBundleDev/Android/AssetBundle");
            var manifest_path = Path.GetFullPath(Path.Combine(assetBundlePath, "AssetBundle"));
            if (!File.Exists(manifest_path))
            {
                return;
            }

            var manifestData = File.ReadAllBytes(manifest_path);
            var manifestBundle = AssetBundle.LoadFromMemory(manifestData);
            AssetBundleManifest manifest = manifestBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
            try
            {
                string[] assetbundles = manifest.GetAllAssetBundles();
                for (int i = 0; i < assetbundles.Length; i++)
                {
                    AssetBundleDependNode node = new AssetBundleDependNode();
                    node.headNodeName = assetbundles[i];
                    node.nodeName = assetbundles[i];

                    List<AssetBundleDependNode> loop_list = new List<AssetBundleDependNode>();
                    this.CalcLoopDepend(manifest, node, loop_list);
                    if (loop_list.Count > 0)
                    {
                        CheckItem item = new CheckItem();
                        item.asset = assetbundles[i];
                        item.loopList = loop_list;
                        this.outputList.Add(item);
                    }
                }
            }
            catch (System.Exception)
            {
                throw;
            }
            finally
            {
                manifestBundle.Unload(true);
            }
        }

        // 计算出从到回到头部的依赖路径，并加入循环列表
        private void CalcLoopDepend(AssetBundleManifest manifest, AssetBundleDependNode node, List<AssetBundleDependNode> loopList)
        {
            string[] depends = manifest.GetDirectDependencies(node.nodeName);
            for (int i = 0; i < depends.Length; i++)
            {
                AssetBundleDependNode child_node = new AssetBundleDependNode();
                child_node.nodeName = depends[i];
                child_node.headNodeName = node.headNodeName;
                child_node.parentNode = node;

                if (NameIsInParent(depends[i], node))  // 检测依赖项是否已在node的依赖路径上了,则不在进行往下依赖计算
                {
                    if (child_node.nodeName == child_node.headNodeName)
                    {
                        loopList.Add(child_node);
                    }
                }
                else
                {
                    CalcLoopDepend(manifest, child_node, loopList);
                }
            }
        }

        private bool NameIsInParent(string nodeName, AssetBundleDependNode node)
        {
            node = node.parentNode;

            while (null != node)
            {
                if (node.nodeName == nodeName)
                {
                    return true;
                }

                node = node.parentNode;
            }

            return false;
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public List<AssetBundleDependNode> loopList;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder path_builder = new StringBuilder();

                for (int i = 0; i < loopList.Count; i++)
                {
                    Queue<string> queue = new Queue<string>();
                    AssetBundleDependNode node = loopList[i].parentNode;
                    while (null != node)
                    {
                        queue.Enqueue(node.nodeName);
                        node = node.parentNode;
                    }

                    while(queue.Count > 0)
                    {
                        path_builder.Append(string.Format("    {0}", queue.Dequeue()));
                        path_builder.Append("\n");
                    }
                }

                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0} 依赖路径：\n{1}", asset, path_builder.ToString()));
                return builder;
            }
        }
    }
}
 