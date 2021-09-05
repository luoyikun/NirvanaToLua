using UnityEngine;
using UnityEditor;
using AssetsCheck;
using UnityEngine.UI;
using Nirvana;
using System.Text;

namespace AssetsCheck
{
    public class UIRawimageChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };
        private string[] rawImagesDirs = { "Assets/Game/UIs/RawImages" };

        // 获得错误描述
        override public string GetErrorDesc()
        {
            return "Rawimages文件夹里的不能被prefab直接引用";
        }

        override protected void OnCheck()
        {
            AssetRefrence.Build("t:prefab", checkDirs);
            string[] guids = AssetDatabase.FindAssets("t:texture", rawImagesDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (AssetRefrence.IsBeRefed(path))
                {
                    CheckItem item = new CheckItem();
                    item.asset = path;
                    item.refAssets = AssetRefrence.GetRefAssets(path);
                    this.outputList.Add(item);
                }
            }
        }

        private string GetObjectPath(GameObject gameObject)
        {
            Transform tf = gameObject.transform;
            string path = "";
            while (tf)
            {
                path = tf.gameObject.name + "/" + path;
                tf = tf.parent;
            }

            return path;
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string[] refAssets;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   {1}", asset, refAssets[0]));
                return builder;
            }
        }
    }
}