using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using Nirvana;
using UnityEngine.Assertions;
using UnityEngine.Rendering.PostProcessing;
using System.Text.RegularExpressions;

namespace art
{
    public class ActorChangeTranform : EditorWindow
    {
        private static readonly string[] actorList =
        new string[] { "羽翼", "头部", "面饰", "腰饰"};
        private static readonly int[] actorPointList =
        new int[] { 9, 11, 12, 13};
        private int actorIndex;

        private UnityEngine.GameObject roleGameObj;                            //人物模型
        private UnityEngine.GameObject selectedGameObj;                        //保存人物显示模型
        private UnityEngine.Object actorFolder;                                //资源模型文件
        private UnityEngine.GameObject actorGameObj;                           //当前修改资源模型
        private UnityEngine.GameObject showActor;                              //资源模型
        private Vector2 actorShowScroll;
        private Vector2 actorChangeScroll;

        private List<GameObject> actorObjectList = new List<GameObject>();
        private Dictionary<string, AttachObject.PhysiqueConfig[]> saveActorObjectList = new Dictionary<string, AttachObject.PhysiqueConfig[]>();
        private Dictionary<string, GameObject> saveActorObject = new Dictionary<string, GameObject>();

        [MenuItem("自定义工具/资源修改/资源位置大小修改")]
        public static void ShowWindow()
        {
            EditorWindow window = EditorWindow.GetWindow(typeof(ActorChangeTranform));
            window.titleContent = new GUIContent("资源位置大小修改");
        }

        private void OnGUI()
        {
            GUILayout.BeginHorizontal();
            roleGameObj = EditorGUILayout.ObjectField("拖入展示角色", roleGameObj, typeof(GameObject), false) as GameObject;
            if (GUILayout.Button("创建角色", GUILayout.Width(100)))
            {
                StartGameToChange();
            }
            GUILayout.EndHorizontal();
            EditorGUILayout.Space();

            actorIndex = EditorGUILayout.Popup("挂点类型", actorIndex, actorList);
            GUILayout.BeginHorizontal();
            if (actorFolder == null)
            {
                actorFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/Actors/Wing");
            }
            actorFolder = EditorGUILayout.ObjectField("拖入资源目录", actorFolder, typeof(Object), false) as Object;
            if (GUILayout.Button("输出所有资源", GUILayout.Width(100)))
            {
                OnExportActor();
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            actorGameObj = EditorGUILayout.ObjectField("当前修改的资源", actorGameObj, typeof(GameObject), false) as GameObject;
            if (GUILayout.Button("保存修改", GUILayout.Width(100)))
            {
                StartSaveActor();
            }
            GUILayout.EndHorizontal();
            if (GUILayout.Button("修改所有保存", GUILayout.Width(120)))
            {
                StartSaveAllChangeActor();
            }
            EditorGUILayout.Space();


            if (actorObjectList.Count > 0)
            {
                GUILayout.Label("所有资源：");
                actorShowScroll = EditorGUILayout.BeginScrollView(actorShowScroll, EditorStyles.textField, GUILayout.Height(280));
                for (var nIdx = 0; nIdx < actorObjectList.Count ; ++ nIdx)
                {
                    var obj1 = actorObjectList[nIdx];
                    GUILayout.BeginHorizontal();
                    
                    EditorGUILayout.ObjectField(obj1, typeof(GameObject), false, GUILayout.Width(200));
                    if (GUILayout.Button("选中", GUILayout.Width(60)))
                    {
                        SelectedActor(obj1);
                    }
                    if (GUILayout.Button("保存", GUILayout.Width(60)))
                    {
                        SaveActor(obj1);
                    }
                    GUILayout.EndHorizontal();
                }
                EditorGUILayout.EndScrollView();
            }

            if (saveActorObject.Count > 0)
            {
                GUILayout.Label("已经修改保存的资源：");
                actorChangeScroll = EditorGUILayout.BeginScrollView(actorChangeScroll, EditorStyles.textField, GUILayout.Height(280));

                foreach (var item in saveActorObject)
                {
                    GameObject obj = saveActorObject[item.Key];
                    GUILayout.BeginHorizontal();
                    if (saveActorObjectList[item.Key] != null)
                    {
                        EditorGUILayout.ObjectField(obj, typeof(GameObject), false, GUILayout.Width(200));
                        if (GUILayout.Button("删除", GUILayout.Width(60)))
                        {
                            DelectedActor(item.Key);
                        }
                        if (GUILayout.Button("替换", GUILayout.Width(60)))
                        {
                            ReplaceActor(item.Key);
                        }
                        GUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
            }
        }

        private void StartSaveActor()
        {
            if (null == actorGameObj)
            {
                this.ShowNotification(new GUIContent("未选择文件!"));
                return;
            }

            SaveActor(actorGameObj);
        }

        private void StartSaveAllChangeActor()
        {
            if (Application.isPlaying)
            {
                this.ShowNotification(new GUIContent("请关闭游戏再替换!"));
                return;
            }
            foreach (var item in saveActorObject)
            {
                if (saveActorObjectList[item.Key] != null)
                {
                    ReplaceActor(item.Key);
                }
            }
        }

        private void OnExportActor()
        {
            if (null == actorFolder)
            {
                this.ShowNotification(new GUIContent("请选择文件!"));
                return;
            }
            actorObjectList.Clear();
            var dir = AssetDatabase.GetAssetPath(actorFolder);
            var guids = AssetDatabase.FindAssets("t:prefab", new string[] { dir });
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (Regex.IsMatch(gameObj.name, @"^[+-]?\d*[.]?\d*$"))
                {
                    actorObjectList.Add(gameObj);
                }
            }
        }

        private void StartGameToChange()
        {
            if (null == roleGameObj)
            {
                this.ShowNotification(new GUIContent("请选择文件!"));
                return;
            }
            if (this.selectedGameObj != null)
            {
                DestroyImmediate(this.selectedGameObj);
            }
            this.selectedGameObj = PrefabUtility.InstantiatePrefab(roleGameObj) as GameObject;
            
            //Application.Quit();
        }

        private void SelectedActor(GameObject gameObj)
        {
            if(null == this.selectedGameObj || gameObj == null)
            {
                this.ShowNotification(new GUIContent("请选择文件!"));
                return;
            }
            var actorAttachMent = this.selectedGameObj.GetOrAddComponent<ActorAttachment>();
            this.actorGameObj = gameObj;
            ShowTestActor(actorAttachMent, gameObj);

            Selection.activeGameObject = this.showActor;
        }

        private void ShowTestActor(ActorAttachment attachment, GameObject gameObj)
        {
            Assert.IsTrue(Application.isPlaying);
            if (!Application.isPlaying)
            {
                return;
            }
            this.HideTestActor();
            var obj = GameObject.Instantiate(gameObj);

            int pointIndex = actorPointList[actorIndex];
            var point = attachment.GetAttachPoint(pointIndex);
            var attachObj = obj.GetComponent<AttachObject>();
            if (attachObj == null)
            {
                Debug.LogError("The actor has no AttachObject.");
                GameObject.Destroy(obj);
                return;
            }

            attachObj.SetAttached(point);
            attachObj.SetTransform(attachment.Prof);

            this.showActor = obj;
        }

        private void HideTestActor()
        {
            Assert.IsTrue(Application.isPlaying);
            if (this.showActor != null)
            {
                GameObject.Destroy(this.showActor);
                this.showActor = null;
            }
        }

        private void SaveActor(GameObject gameObj)
        {
            if (this.showActor != null)
            {
                AttachObject actorAttach = this.showActor.GetOrAddComponent<AttachObject>();
                if (actorAttach.GetPhysiqueConfig() != null)
                {
                    saveActorObjectList[gameObj.name] = actorAttach.GetPhysiqueConfig();
                    saveActorObject[gameObj.name] = gameObj; 
                    this.ShowNotification(new GUIContent("保存文件成功!" + gameObj.name));
                }
            }
        }

        private void ReplaceActor(string selestedKey)
        {
            GameObject changeObj = saveActorObject[selestedKey];
            AttachObject.PhysiqueConfig[] new_phy = saveActorObjectList[selestedKey];

            if (new_phy == null || changeObj == null)
            {
                return;
            }
            ReplaceOneActor(changeObj, new_phy, selestedKey);
        }

        private void ReplaceOneActor(GameObject gameObj, AttachObject.PhysiqueConfig[] new_phy, string selestedKey)
        {
            if (Application.isPlaying)
            {
                this.ShowNotification(new GUIContent("请关闭游戏再替换!"));
                return;
            }

            var actorObj = PrefabUtility.InstantiatePrefab(gameObj) as GameObject;
            actorObj.GetOrAddComponent<AttachObject>().ChangeTransformAllProf(new_phy);
            PrefabUtility.ReplacePrefab(actorObj, actorGameObj);
            DestroyImmediate(actorObj);
            this.ShowNotification(new GUIContent("替换成功：" + gameObj.name));
            DelectedActor(selestedKey);
        }

        private void DelectedActor(string selestedKey)
        {
            if (saveActorObjectList[selestedKey] != null)
            {
                saveActorObjectList.Remove(selestedKey);
            }
            if (saveActorObject[selestedKey] != null)
            {
                saveActorObject.Remove(selestedKey);
            }
        }
    }
}
