using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Threading;
using UnityEngine.SceneManagement;
using System;
using UnityEngine.UI;

/// <summary>
/// 查找组件，用于批量修改组件的操作
/// </summary>

public class FindComponent : EditorWindow
{
    MonoScript targetScript;
    string targetTag;
    Vector2 scrollPos = new Vector2(0, 0);
    bool cancel = false;

    GameObject selectTargetGameObject;
    GameObject hightLightTarget;

    Dictionary<GameObject, GameObject> FindDictionary = new Dictionary<GameObject, GameObject>();
    Dictionary<GameObject, bool> ToggleList = new Dictionary<GameObject, bool>();

    [MenuItem("自定义工具/查找组件引用")]
    static void Init()
    {
        FindComponent myWindow = (FindComponent)EditorWindow.GetWindow(typeof(FindComponent), false, "查找组件引用");//创建窗口
        myWindow.Show();//展示
    }

    void Awake()
    {
        //ulong a = 1;
        //ulong b = 1;

        //for (int i = 3; i <= 100; i++)
        //{
        //    b = a + b;
        //    a = b - a;
        //    Debug.LogError(b);

        //}
        //Debug.LogError("加载");
    }

    void Start()
    {
        //Debug.LogError("开始");
    }

    //获取场景上存在的所有用户自定义的prefab实例
    List<GameObject> GetRealPreafabList()
    {
        List<GameObject> realPreafabList = new List<GameObject>();

        //获取当前激活的场景.
        Scene scene = SceneManager.GetActiveScene();
        //获取场景上所有父级的GameObject.
        var objs = scene.GetRootGameObjects();

        foreach (var obj in objs)
        {
            if (PrefabUtility.GetPrefabType(obj) == PrefabType.PrefabInstance)
            {
                //找到了直接添加到表里，不再继续通过该节点深入查找
                realPreafabList.Add(obj);
            }
            else
            {
                Queue<GameObject> queue = new Queue<GameObject>();
                queue.Enqueue(obj);
                while (queue.Count > 0)
                {
                    bool is_add = false;
                    var new_obj = queue.Dequeue();
                    if (PrefabUtility.GetPrefabType(new_obj) == PrefabType.PrefabInstance)
                    {
                        realPreafabList.Add(new_obj);
                        is_add = true;
                    }
                    if (!is_add)
                    {
                        for (int i = 0; i < new_obj.transform.childCount; ++i)
                        {
                            var child = new_obj.transform.GetChild(i);
                            queue.Enqueue(child.gameObject);
                        }
                    }
                }
            }
        }

        //Debug.LogError(realPreafabList.Count);
        return realPreafabList;
    }

    void OnGUI()
    {
        EditorGUILayout.Space();
        targetScript = EditorGUILayout.ObjectField("添加组件:", targetScript, typeof(MonoScript), true) as MonoScript;

        #region 忽略列表
        #endregion

        #region 生成tag列表
        //targetTag = EditorGUILayout.TagField("1111", targetTag);
        #endregion

        #region 生成自定义下拉菜单列表
        //index = EditorGUILayout.Popup("菜单列表：", index, popupList);
        #endregion

        #region 打开通知的方法
        //GUILayout.Space(20);
        //if (GUILayout.Button("打开通知"))
        //{
        //    this.ShowNotification(new GUIContent("This is a Notification"));
        //}

        //if (GUILayout.Button("关闭通知"))
        //{
        //    this.RemoveNotification();
        //}
        #endregion

        #region 文本框显示鼠标在窗口的位置
        //EditorGUILayout.LabelField("鼠标在窗口的位置", Event.current.mousePosition.ToString());
        #endregion

        GUILayout.Space(20);
        EditorGUILayout.BeginHorizontal();
        #region 批量查找
        if (GUILayout.Button("开始查找"))
        {
            if (targetScript == null)
            {
                this.ShowNotification(new GUIContent("请放入组件!!!!"));
                //StartTimers();
            }
            else
            {
                FindDictionary.Clear();
                this.Repaint();
                FindAllQuote();
            }
        }
        #endregion

        #region 批量删除
        if (GUILayout.Button("批量删除"))
        {
            if (targetScript == null)
            {
                this.ShowNotification(new GUIContent("请放入组件!!!!"));
            }
            else
            {
                AllDelete();
            }
        }
        #endregion
        EditorGUILayout.EndHorizontal();

        #region 查找结果
        if (FindDictionary != null && FindDictionary.Count > 0)
        {
            int times = 0;
            GUILayout.Space(20);
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
            foreach (var dic in FindDictionary)
            {
                string str = dic.Value.name;
                if (dic.Key != dic.Value)
                {
                    str = str + " 的 " + dic.Key.name;
                }
                #region 点击对应的标签后触发
                var editorStyle = EditorStyles.helpBox;
                if (hightLightTarget != null && hightLightTarget == dic.Key)
                {
                    editorStyle = EditorStyles.objectFieldThumb;
                    //str = str + "    (当前选择!!!!!)";
                }
                if (GUILayout.Button(str, editorStyle, GUILayout.Height(20f)))
                {
                    var realPreafabList = GetRealPreafabList();

                    selectTargetGameObject = null;
                    hightLightTarget = null;
                    #region 查找场景中符合的prefab
                    foreach (var realPrefab in realPreafabList)
                    {
                        //获取场景上这个prefab在project中的原始prefab
                        var target = PrefabUtility.GetPrefabParent(realPrefab);
                        if (target != null && target == dic.Value)
                        {
                            var target_obj = dic.Key;
                            string path = target_obj.name;
                            Transform newTransForm = target_obj.transform;
                            while (newTransForm.parent != null && newTransForm.parent.parent != null)
                            {
                                //获取这个节点在prefab上的路径（不包括root节点）
                                newTransForm = newTransForm.parent;
                                path = string.Format("{0}/{1}", newTransForm.name, path);
                            }
                            if (path != target_obj.name || newTransForm.parent != null)
                            {
                                selectTargetGameObject = realPrefab.transform.Find(path).gameObject;
                            }
                            else
                            {
                                selectTargetGameObject = realPrefab;
                            }
                            break;
                        }
                    }
                    #endregion
                    if (selectTargetGameObject == null)
                    {
                        //直接获取资源目录中的prefab
                        selectTargetGameObject = dic.Value;
                    }
                    //根据Object指引对应的位置
                    EditorGUIUtility.PingObject(selectTargetGameObject);
                    Selection.activeObject = selectTargetGameObject;
                    hightLightTarget = dic.Key;
                }
                #endregion
                GUILayout.Space(10);
                times++;
            }
            EditorGUILayout.EndScrollView();
        }
        #endregion
    }

    void FindAllQuote()
    {
        var assets = AssetDatabase.FindAssets("t:prefab", new string[] { "Assets/Game/UIs", "Assets/Game/Actors", "Assets/Game/Effects" });
        int startIndex = 0;
        int max_length = assets.Length;

        for (int i = startIndex; i < max_length; i++)
        {
            var guid = assets[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                var components = prefab.transform.GetComponentsInChildren(targetScript.GetClass(), true);
                foreach (var component in components)
                {
                    FindDictionary.Add(component.gameObject, prefab.gameObject);
                }
            }
            else
            {
                Debug.LogError("未知错误，无法找到prefab");
            }

            cancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", path, (float)i / (float)max_length);
            if (cancel)
            {
                break;
            }
        }
        EditorUtility.ClearProgressBar();
        this.Repaint();
    }

    void AllDelete()
    {
        var assets = AssetDatabase.FindAssets("t:prefab", new string[] { "Assets/Game/UIs", "Assets/Game/Actors", "Assets/Game/Effects" });
        int startIndex = 0;
        int max_length = assets.Length;

        for (int i = startIndex; i < max_length; i++)
        {
            var guid = assets[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                var components = prefab.transform.GetComponentsInChildren(targetScript.GetClass(), true);
                foreach (var component in components)
                {
                    Game.LoadRawImage loadimg = component as Game.LoadRawImage;
                    if (null != loadimg)    // LoadRawImage 特殊处理 把texture重新赋值
                    {
                        Texture2D texture = EditorResourceMgr.LoadObject(loadimg.BundleName, loadimg.AssetName, typeof(Texture2D)) as Texture2D;
                        RawImage rawimg = loadimg.gameObject.GetComponent<RawImage>();
                        rawimg.texture = texture;
                    }

                    FindDictionary.Remove(component.gameObject);
                    DestroyImmediate(component, true);
                }
            }
            else
            {
                Debug.LogError("未知错误，无法找到prefab");
            }
            cancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", path, i / (max_length * 1.0f));
            if (cancel)
            {
                break;
            }
        }
        EditorUtility.ClearProgressBar();
        AssetDatabase.SaveAssets();
        this.Repaint();
    }

    void StartTimers()
    {
        var threadTimer = new Timer(new TimerCallback((object value) => {Debug.LogError("!!!!!!!!!!!!!!"); this.RemoveNotification(); }), null, Timeout.Infinite, 1000);
        threadTimer.Change(0, 1000);

        //UnityEditor.EditorGUIUtility.PingObject
        //AssetDatabase.GetAssetPath(object:GetIn)


        //UnityEditor.PrefabUtility.GetPrefabParent
        //UnityEditor.PrefabUtility.GetPrefabObject()

        //Scene scene;
        //var objs = scene.GetRootGameObjects();
    }

    void OnInspectorUpdate()
    {
        //Debug.LogError("面板实时刷新");
    }

    void OnProjectChange()
    {
        //Debug.LogError("当Project视图中的资源发生改变时调用一次");
    }

    void OnFocus()
    {
        //Debug.LogError("当窗口获得焦点时调用一次");
    }

    void OnLostFocus()
    {
        //Debug.LogError("当窗口丢失焦点时调用一次");
    }

    void OnHierarchyChange()
    {
        //Debug.LogError("当Hierarchy视图中的任何对象发生改变时调用一次");
    }
}