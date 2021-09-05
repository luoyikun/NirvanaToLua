using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;

namespace art
{
    public class ActorAllChangeScale : EditorWindow
    {
        private UnityEngine.Object changeFolder;                           //人物模型
        private string changeScaleX = "1";
        private string changeScaleY = "1";
        private string changeScaleZ = "1";

        [MenuItem("自定义工具/资源修改/资源大小批量修改")]
        public static void ShowWindow()
        {
            EditorWindow window = EditorWindow.GetWindow(typeof(ActorAllChangeScale));
            window.titleContent = new GUIContent("资源大小批量修改");
        }

        private void OnGUI()
        {
            if (changeFolder == null)
            {
                changeFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Role");
            }
            changeFolder = EditorGUILayout.ObjectField("拖入更换资源目录", changeFolder, typeof(Object), false) as Object;

            GUILayout.Label("输入要替换sacle:");
            GUILayout.BeginHorizontal();
            GUILayout.Label("X:", GUILayout.Width(20));
            changeScaleX = GUILayout.TextField(changeScaleX);
            GUILayout.Label("Y:", GUILayout.Width(20));
            changeScaleY = GUILayout.TextField(changeScaleY);
            GUILayout.Label("Z:", GUILayout.Width(20));
            changeScaleZ = GUILayout.TextField(changeScaleZ);
            GUILayout.EndHorizontal();

            if (GUILayout.Button("修改文件夹下scale", GUILayout.Width(200)))
            {
                StartChangeScale(changeScaleX, changeScaleY, changeScaleZ);
            }
        }

        private void StartChangeScale(string changeScaleX, string changeScaleY, string changeScaleZ)
        {
            if (null == changeFolder)
            {
                this.ShowNotification(new GUIContent("请选择文件!"));
                return;
            }

            var dir = AssetDatabase.GetAssetPath(changeFolder);
            var guids = AssetDatabase.FindAssets("t:prefab", new string[] { dir });
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);

                if (Regex.IsMatch(gameObj.name, @"^[+-]?\d*[.]?\d*$"))
                {
                    ChangeActorScale(gameObj, changeScaleX, changeScaleY, changeScaleZ);
                }
            }
        }

        private void ChangeActorScale(GameObject changeObj, string changeScaleX, string changeScaleY, string changeScaleZ)
        {
            var gameObj = PrefabUtility.InstantiatePrefab(changeObj) as GameObject;
            var childs = gameObj.GetComponentsInChildren<Transform>();
            int childnum = 0;
            Transform changeChild = null;
            foreach (var child in childs)
            {
                if (child.transform.parent == gameObj.transform)
                {
                    changeChild = child;
                    childnum++;
                }
            }
            if (childnum == 1 && changeChild != null)
            {
                changeChild.transform.localScale = new Vector3(float.Parse(changeScaleX), float.Parse(changeScaleY), float.Parse(changeScaleZ));
                PrefabUtility.ReplacePrefab(gameObj, changeObj);
                DestroyImmediate(gameObj);
                return;
            }

            GameObject new_prefab = new GameObject();
            new_prefab.name = "GameObject";
            new_prefab.transform.SetParent(gameObj.transform, false);

            foreach (var child in childs)
            {
                if (child.name != "GameObject")
                {
                    child.transform.SetParent(new_prefab.transform, false);
                }
            }
            AnimatorUtility.DeoptimizeTransformHierarchy(gameObj);

            new_prefab.transform.localScale = new Vector3(float.Parse(changeScaleX), float.Parse(changeScaleY), float.Parse(changeScaleZ));
            PrefabUtility.ReplacePrefab(gameObj, changeObj);
            DestroyImmediate(gameObj);
        }
    }
}
