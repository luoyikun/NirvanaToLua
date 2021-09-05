using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace BatchAssets
{
    // 美术在导出模型时，有很多挂点是没有用的。但有些挂点却是有用的，跟美术沟通，有用挂点的名字。
    // 再使用该脚本进行一健清理
    public class BatchAnimatorOptimize
    {
        // 指定要检查的文件夹
        private static string[] checkDirs = { "Assets/Game/Actors/Wing/8001" };

        private static string[] searchPatterns = new string[] {
            "buff_.*",
            "hurt_.*",
            "_.*point",
            "ui",
            "guadian",
        };


        [MenuItem("自定义工具/资源批量处理/优化动画（去掉无用节点）")]
        public static void Process()
        {
            Debug.Log("开始批量处理");
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (null == gameobj.GetComponentInChildren<Animator>(true))
                {
                    continue;
                }

                string[] exposed_transforms = new string[] { };
                SearchExposed(gameobj.transform, ref exposed_transforms);

                if (exposed_transforms.Length > 0)
                {
                    AnimatorUtility.OptimizeTransformHierarchy(gameobj, exposed_transforms);
                }
            }

            Debug.Log("处理完成");
        }

        private static void SearchExposed(Transform root, ref string[] exposedTransforms)
        {
            var pathStack = new List<string>();
            for (int i = 0; i < searchPatterns.Length; ++i)
            {
                if (string.IsNullOrEmpty(searchPatterns[i]))
                {
                    continue;
                }

                var regex = new Regex(searchPatterns[i]);
                SearchExposed(pathStack, root, regex, ref exposedTransforms);
                pathStack.Clear();
            }
        }

        private static void SearchExposed(List<string> pathStack, Transform transform, System.Text.RegularExpressions.Regex regex, ref string[] exposedTransforms)
        {
            pathStack.Add(transform.name);
            var pathBuilder = new StringBuilder();
            for (int i = 0; i < pathStack.Count; ++i)
            {
                pathBuilder.Append(pathStack[i]);
                if (i < pathStack.Count - 1)
                {
                    pathBuilder.Append('/');
                }
            }

            var path = pathBuilder.ToString();
            if (regex.IsMatch(path))
            {
                AddExposedTransform(path, ref exposedTransforms);
            }

            foreach (Transform child in transform)
            {
                SearchExposed(pathStack, child, regex, ref exposedTransforms);
            }

            pathStack.RemoveAt(pathStack.Count - 1);
        }

        private static void AddExposedTransform(string value, ref string[] exposedTransforms)
        {
            foreach (var stringValue in exposedTransforms)
            {
                if (stringValue == value)
                {
                    return;
                }
            }

            ArrayUtility.Add(ref exposedTransforms, value);
        }
    }
}
