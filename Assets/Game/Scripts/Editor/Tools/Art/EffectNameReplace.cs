using UnityEngine;
using UnityEditor;

namespace art
{
    public class EffectNameReplace : EditorWindow
    {
        private Object targetFile;
        private string oldStr = string.Empty;
        private string newStr = string.Empty;
        private string prefix = string.Empty;

        [MenuItem("自定义工具/美术专用/特效替换名字", false, 110)]
        public static void ShowWindow()
        {
            EditorWindow window = EditorWindow.GetWindow(typeof(EffectNameReplace));
            window.titleContent = new GUIContent("EffectNameReplace");
        }

        private void OnGUI()
        {
            targetFile = EditorGUILayout.ObjectField("添加文件:", targetFile, typeof(Object), true) as Object;

            GUILayout.Label("输入要替换的字符串(只替换材质球和贴图):");
            GUILayout.BeginHorizontal();
            oldStr = GUILayout.TextField(oldStr);
            newStr = GUILayout.TextField(newStr);
            if (GUILayout.Button("开始替换", GUILayout.Width(100)))
            {
                StartReplace(string.Empty, oldStr, newStr);
            }
            GUILayout.EndHorizontal();

            GUILayout.Label("输入要增加的前缀字符串(只处理材质球和贴图):");
            GUILayout.BeginHorizontal();
            prefix = GUILayout.TextField(prefix);
            if (GUILayout.Button("增加前缀", GUILayout.Width(100)))
            {
                StartReplace(prefix, string.Empty, string.Empty);
            }
            GUILayout.EndHorizontal();
        }

        private void StartReplace(string prefix, string oldStr, string newStr)
        {
            if (null == targetFile)
            {
                this.ShowNotification(new GUIContent("请选择文件夹!"));
                return;
            }

            string[] checkDirs = new string[] { AssetDatabase.GetAssetPath(targetFile) };

            string[] guids = AssetDatabase.FindAssets("t:texture", checkDirs);
            foreach (var guid in guids)
            {
                ReName(AssetDatabase.GUIDToAssetPath(guid), prefix, oldStr, newStr);
            }

            guids = AssetDatabase.FindAssets("t:material", checkDirs);
            foreach (var guid in guids)
            {
                ReName(AssetDatabase.GUIDToAssetPath(guid), prefix, oldStr, newStr);
            }

            AssetDatabase.SaveAssets();
        }

        private void ReName(string path, string prefix, string oldStr, string newStr)
        {
            int index = path.LastIndexOf("/");
            string old_name = path.Substring(index + 1);
            string new_name = old_name;

            if (!string.IsNullOrEmpty(prefix) && !new_name.StartsWith(prefix))
            {
                new_name = prefix + old_name;
            }

            if (!string.IsNullOrEmpty(oldStr))
            {
                new_name = old_name.Replace(oldStr, newStr);
            }


            if (new_name != old_name)
            {
                AssetDatabase.RenameAsset(path, new_name);
            }
        }
    }
}
