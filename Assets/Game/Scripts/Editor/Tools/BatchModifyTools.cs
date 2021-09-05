using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using Game;
using Nirvana;
using System.IO;

public class BatchModifyTools : BaseEditorWindow
{
    private List<GameObject> list = new List<GameObject>();
    private Vector2 scrollerPos = new Vector2();
    private Object selectObj;
    private bool skipHideObject = false;

    [MenuItem("自定义工具/批量修改工具")]

    private static void ShowWindow()
    {
        EditorWindow.GetWindow<BatchModifyTools>(false, "批量修改工具");
    }

    private void OnGUI()
    {
        this.skipHideObject = EditorGUILayout.Toggle("跳过隐藏的Object", this.skipHideObject);
        if (GUILayout.Button("查找错误的模态背景"))
        {
            this.list.Clear();
            this.Search();
        }

        if (GUILayout.Button("删除错误的模态背景"))
        {
            this.DestroyErrorMask();
        }

        if (GUILayout.Button("查找U3dDisplay摄像机"))
        {
            this.list.Clear();
            this.SearchCamera();
        }

        if (GUILayout.Button("修改U3dDisplay摄像机参数"))
        {
            this.ModifyCameraParam();
        }

        if (GUILayout.Button("搜索 gameobjattach IsSyncLayer"))
        {
            this.list.Clear();
            this.SearchAttach();
        }

        if (GUILayout.Button("修改 gameobjattach IsSyncLayer"))
        {
            this.ModifyAttach();
        }

        if (GUILayout.Button("搜索 Accordion"))
        {
            this.list.Clear();
            this.SearchAccordion();
        }

        if (GUILayout.Button("修改 Accordion"))
        {
            this.ModifyAccordion();
        }

        if (GUILayout.Button("搜索 ResolutionAdapter"))
        {
            this.list.Clear();
            this.SearchResolutionAdapter();
        }

        if (GUILayout.Button("修改 ResolutionAdapter"))
        {
            this.ModifyResolutionAdapter();
        }

        if (GUILayout.Button("查找 未取整的RectTransform"))
        {
            this.SearchRectTransform();
        }

        if (GUILayout.Button("修改 给RectTransform取整"))
        {
            this.ModifyRectTransform();
        }

        if (GUILayout.Button("查找 RawImage"))
        {
            this.SearchRawImage();
        }

        if (GUILayout.Button("给 RawImage 删除 LoadRawImage"))
        {
            this.ModifyRawImage();
        }

        if (GUILayout.Button("查找localScele非1的actor"))
        {
            this.SearchWrongActor();
        }

        this.scrollerPos = EditorGUILayout.BeginScrollView(this.scrollerPos);
        var count = this.list.Count;
        if (count > 0)
        {
            EditorGUILayout.TextArea("数量: " + count);
        }
        foreach (var obj in this.list)
        {
            var style = EditorStyles.textField;
            if (obj == this.selectObj)
                style = EditorStyles.whiteLabel;
            if (GUILayout.Button(obj.name, style))
            {
                this.selectObj = obj;
                PingObj(obj);
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void Search()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.Check(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void DestroyErrorMask()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            this.list.Clear();
            this.Check(obj);

            foreach (var image in list)
            {
                DestroyImmediate(image.gameObject, true);
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void Check(GameObject obj)
    {
        var images = obj.GetComponentsInChildren<Image>(!this.skipHideObject);
        foreach (var image in images)
        {
            if (CheckMaskNode(image))
            {
                list.Add(image.gameObject);
            }
        }
    }

    private static bool CheckMaskNode(Image image)
    {
        var instanceID = image.GetInstanceID();
        if (instanceID == 0)
            return false;
        Button btn = image.gameObject.GetComponent<Button>();
        if (image.color.r == 0 && image.color.g == 0 && image.color.b == 0 && image.color.a != 0 && null != btn)
        {
            return true;
        }
        return false;
    }

    private void SearchCamera()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckCamera(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyCameraParam()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            this.list.Clear();
            this.CheckCamera(obj);

            foreach (var camera_l in list)
            {
                Nirvana.CameraEnvLighting light = camera_l.GetComponent<Nirvana.CameraEnvLighting>();
                if (null != light)
                {
                    DestroyImmediate(light, true);

                    var new_light = camera_l.AddComponent<Nirvana.CameraEnvLighting>();
                    new_light.AmbientIntensity = 1;
                    new_light.AmbientSkyColor = new Color(1.0f, 1.0f, 1.0f, 0.0f);
                    new_light.AmbientEquatorColor = new Color(1.0f, 1.0f, 1.0f, 0.0f);
                    new_light.AmbientGroundColor = new Color(188 / 255.0f, 188 / 255.0f, 188 / 255.0f, 0.0f);

                    Cubemap ToonShade = (Cubemap)AssetDatabase.LoadAssetAtPath("Assets/T4M/Shaders/Sources/toony lighting.psd", typeof(Cubemap));
                    new_light.CustomReflection = ToonShade;
                    new_light.ReflectionIntensity = 1;
                }

                PostEffects post_effect = camera_l.GetComponent<PostEffects>();
                if (null != post_effect)
                {
                    DestroyImmediate(post_effect, true);

                    PostEffects new_post_effect = camera_l.AddComponent<PostEffects>();
                    new_post_effect.EnableBloom = true;
                    new_post_effect.enabled = true;
//                     new_post_effect.bloomIntensity = 0.6f;
//                     new_post_effect.bloomThreshold = 0.78f;
//                     new_post_effect.bloomThresholdColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
//                     new_post_effect.bloomBlurSpread = 2.9f;
                }
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckCamera(GameObject obj)
    {
        var components = obj.GetComponentsInChildren<Nirvana.UI3DDisplayCamera>(!this.skipHideObject);
        foreach (var component in components)
        {
            Nirvana.UI3DDisplayCamera ca = component as Nirvana.UI3DDisplayCamera;
            if (null != ca)
            {
                list.Add(component.gameObject);
            }
        }
    }

    private void SearchAttach()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs", "Assets/Game/Actors", "Assets/Game/Effects" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckAttach(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyAttach()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs", "Assets/Game/Actors", "Assets/Game/Effects" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            list.Clear();
            this.CheckAttach(obj);

            foreach (var camera_l in list)
            {
                GameObjectAttach aobj = camera_l.GetComponent<GameObjectAttach>();
                if (null != aobj)
                {
                    string BundleName = aobj.BundleName;
                    string AssetName = aobj.AssetName;

                    DestroyImmediate(aobj, true);

                    var new_compent = camera_l.AddComponent<GameObjectAttach>();
                    new_compent.IsSyncLayer = true;
                    new_compent.BundleName = BundleName;
                    new_compent.AssetName = AssetName;
                }
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }

            EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckAttach(GameObject obj)
    {
        GameObjectAttach[] components = obj.GetComponentsInChildren<GameObjectAttach>(true);
        foreach (GameObjectAttach component in components)
        {
            if (null != component && component.IsSyncLayer == false)
            {
                list.Add(component.gameObject);
            }
        }
    }

    private void SearchAccordion()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckAccordion(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyAccordion()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            list.Clear();
            this.CheckAccordion(obj);

            foreach (var acc in list)
            {
                Accordion aobj = acc.GetComponent<Accordion>();
                if (null != aobj)
                {
                    DestroyImmediate(aobj, true);

                    var new_compent = acc.AddComponent<Accordion>();
                    new_compent.TransitionType = Accordion.Transition.Tween;
                    new_compent.TransitionDuration = 0.1f;
                }
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }

            EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckAccordion(GameObject obj)
    {
        Accordion[] components = obj.GetComponentsInChildren<Accordion>(true);
        foreach (Accordion component in components)
        {
            if (null != component)
            {
                list.Add(component.gameObject);
            }
        }
    }

    private void SearchResolutionAdapter()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (path.Contains("CommonWidgets"))
            {
                continue;
            }

            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckResolutionAdapter(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyResolutionAdapter()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (path.Contains("CommonWidgets"))
            {
                continue;
            }

            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            list.Clear();
            this.CheckResolutionAdapter(obj);

            foreach (var acc in list)
            {
                ResolutionAdapter res_ad = acc.GetComponent<ResolutionAdapter>();
                if (null != res_ad)
                {
                    DestroyImmediate(res_ad, true);

                    CanvasScaler canvas_scaler = acc.GetComponent<CanvasScaler>();
                    if (null != canvas_scaler)
                    {
                        DestroyImmediate(canvas_scaler, true);
                    }
                }
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }

            EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckResolutionAdapter(GameObject obj)
    {
        ResolutionAdapter[] components = obj.GetComponentsInChildren<ResolutionAdapter>(true);
        foreach (ResolutionAdapter component in components)
        {
            if (null != component)
            {
                list.Add(component.gameObject);
            }
        }
    }

    private void SearchRectTransform()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckRectTransform(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyRectTransform()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            list.Clear();
            this.CheckRectTransform(obj);

            foreach (var acc in list)
            {
                RectTransform rect = acc.GetComponent<RectTransform>();

                float new_x = (float)System.Math.Floor(rect.anchoredPosition.x);
                float new_y = (float)System.Math.Floor(rect.anchoredPosition.y);

                rect.anchoredPosition = new Vector2(new_x, new_y);

                float new_w = (float)System.Math.Floor(rect.sizeDelta.x);
                float new_h = (float)System.Math.Floor(rect.sizeDelta.y);

                rect.sizeDelta = new Vector2(new_w, new_h);
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }

            EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckRectTransform(GameObject obj)
    {
        RectTransform[] components = obj.GetComponentsInChildren<RectTransform>(true);
        foreach (RectTransform rect in components)
        {
            if (null != rect)
            {
                float new_x = (float)System.Math.Floor(rect.anchoredPosition.x);
                float new_y = (float)System.Math.Floor(rect.anchoredPosition.y);

                float new_w = (float)System.Math.Floor(rect.sizeDelta.x);
                float new_h = (float)System.Math.Floor(rect.sizeDelta.y);

                if (new_x != rect.anchoredPosition.x || new_y != rect.anchoredPosition.y || new_w != rect.sizeDelta.x || new_h != rect.sizeDelta.y)
                {
                    list.Add(rect.gameObject);
                }
            }
        }
    }

    private void SearchRawImage()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckRawImage(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void ModifyRawImage()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            list.Clear();
            this.CheckRawImage(obj);

            foreach (var acc in list)
            {
                RawImage raw = acc.GetComponent<RawImage>();
                if (null != raw)
                {
                    LoadRawImage rawex = acc.GetOrAddComponent<LoadRawImage>();
                    if (null != rawex)
                    {
                        Texture2D texture = EditorResourceMgr.LoadObject(rawex.BundleName, rawex.AssetName, typeof(Texture2D)) as Texture2D;
                        if (null != texture)
                        {
                            raw.texture = texture;
                        }
                        DestroyImmediate(rawex, true);
                    }
                }
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }

            EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
        }

        EditorUtility.ClearProgressBar();
    }

    private void CheckRawImage(GameObject obj)
    {
        LoadRawImage[] components = obj.GetComponentsInChildren<LoadRawImage>(true);
        foreach (LoadRawImage raw in components)
        {
            if (null != raw)
            {
                list.Add(raw.gameObject);
            }
        }
    }

    private void SearchWrongActor()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/Actors" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.CheckWrongActor(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void CheckWrongActor(GameObject obj)
    {
        if (obj.name.ToUpper() != obj.name.ToLower())
            return;

        if (obj.transform.localScale.x != 1.0f || obj.transform.localScale.y != 1.0f || obj.transform.localScale.z != 1.0f)
        {
            list.Add(obj.gameObject);
        }
    }
}

