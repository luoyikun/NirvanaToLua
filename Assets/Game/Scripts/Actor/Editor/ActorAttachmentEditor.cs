//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using Nirvana.Editor;
using UnityEditor;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.UI;

/// <summary>
/// The editor for <see cref="ActorAttachment"/>
/// </summary>
[CustomEditor(typeof(ActorAttachment))]
public class ActorAttachmentEditor : Editor
{
    private static readonly string[] ProfList =
        new string[] { "男剑士", "男琴师", "女双剑", "女枪炮", "其他" };

    private SerializedProperty prof;
    private SerializedProperty attachPoints;
    private SerializedProperty testWeapon;
    private SerializedProperty testWeapon2;
    private SerializedProperty testMount;
    private SerializedProperty testWing;

    private GameObject weapon;
    private GameObject weapon2;
    private GameObject wing;
    private GameObject mount;

    private Canvas uiCanvas;
    private GameObject uiName;
    private GameObject uiTitle;
    private GameObject uiHP;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();

        int profIndex;
        switch (this.prof.intValue)
        {
        case 1001:
            profIndex = 0;
            break;
        case 1002:
            profIndex = 1;
            break;
        case 1003:
            profIndex = 2;
            break;
        case 1004:
            profIndex = 3;
            break;
        default:
            profIndex = 4;
            break;
        }
        profIndex = EditorGUILayout.Popup("职业", profIndex, ProfList);
        switch (profIndex)
        {
        case 0:
            this.prof.intValue = 1001;
            break;
        case 1:
            this.prof.intValue = 1002;
            break;
        case 2:
            this.prof.intValue = 1003;
            break;
        case 3:
            this.prof.intValue = 1004;
            break;
        default:
            this.prof.intValue = 0;
            break;
        }

        if (this.attachPoints.arraySize < 17)
        {
            this.attachPoints.arraySize = 17;
        }

        var uiPoint = this.attachPoints.GetArrayElementAtIndex(0);
        var buffPointTop = this.attachPoints.GetArrayElementAtIndex(1);
        var buffPointMiddle = this.attachPoints.GetArrayElementAtIndex(2);
        var buffPointBottom = this.attachPoints.GetArrayElementAtIndex(3);
        var hurtMiddlePoint = this.attachPoints.GetArrayElementAtIndex(4);
        var hurtRootPoint = this.attachPoints.GetArrayElementAtIndex(5);
        var weaponPoint1 = this.attachPoints.GetArrayElementAtIndex(6);
        var weaponPoint2 = this.attachPoints.GetArrayElementAtIndex(7);
        var mountPoint = this.attachPoints.GetArrayElementAtIndex(8);
        var wingPoint = this.attachPoints.GetArrayElementAtIndex(9);
		var baoGuadian = this.attachPoints.GetArrayElementAtIndex(10);
        var headPoint = this.attachPoints.GetArrayElementAtIndex(11);
        var touShiPoint = this.attachPoints.GetArrayElementAtIndex(12);
        var waistPoint = this.attachPoints.GetArrayElementAtIndex(13);
        var shouhuanPoint = this.attachPoints.GetArrayElementAtIndex(14);
        var tailPoint = this.attachPoints.GetArrayElementAtIndex(15);
        var rightHandPoint = this.attachPoints.GetArrayElementAtIndex(16);

        GUILayout.BeginHorizontal();
        GUILayout.Label("角色挂点:");
        if (GUILayout.Button("自动拾取"))
        {
            var attachment = this.target as ActorAttachment;
            var transform = attachment.transform;
            uiPoint.objectReferenceValue = transform.FindByName("ui", "UI_guadian");
            buffPointTop.objectReferenceValue = transform.FindByName("buff_top", "buff_up", "buff_upper");
            buffPointMiddle.objectReferenceValue = transform.FindByName("buff_middle", "buff_point");
            buffPointBottom.objectReferenceValue = transform.FindByName("buff_bottom", "buff_down", "buff_root");
            hurtMiddlePoint.objectReferenceValue = transform.FindByName("hurt_middle", "hurt_point", "buff_middle");
            hurtRootPoint.objectReferenceValue = transform.FindByName("hurt_buttom", "hurt_root", "buff_down");
            weaponPoint1.objectReferenceValue = transform.FindByName("weapon_point", "weapon_point1");
            weaponPoint2.objectReferenceValue = transform.FindByName("weapon_point2");
            mountPoint.objectReferenceValue = transform.FindByName("mount_point");
            wingPoint.objectReferenceValue = transform.FindByName("wing_point");
			baoGuadian.objectReferenceValue = transform.FindByName("bao_guadian");
            headPoint.objectReferenceValue = transform.FindByName("Bip001 Head");
            touShiPoint.objectReferenceValue = transform.FindByName("Bip001 Head");
            waistPoint.objectReferenceValue = transform.FindByName("Bip001 Spine");
            shouhuanPoint.objectReferenceValue = transform.FindByName("Bip001 L Hand");
            tailPoint.objectReferenceValue = transform.FindByName("Bip001 Pelvis");
            rightHandPoint.objectReferenceValue = transform.FindByName("Bip001 R Hand");
        }

        GUILayout.EndHorizontal();

        GUILayoutEx.BeginContents();
        EditorGUILayout.PropertyField(uiPoint, new GUIContent("UI挂点:"));
        EditorGUILayout.PropertyField(buffPointTop, new GUIContent("BUFF挂点上"));
        EditorGUILayout.PropertyField(buffPointMiddle, new GUIContent("BUFF挂点中"));
        EditorGUILayout.PropertyField(buffPointBottom, new GUIContent("BUFF挂点下"));
        EditorGUILayout.PropertyField(hurtMiddlePoint, new GUIContent("受击胸口挂点"));
        EditorGUILayout.PropertyField(hurtRootPoint, new GUIContent("受击脚底挂点"));
        EditorGUILayout.PropertyField(weaponPoint1, new GUIContent("武器挂点1"));
        EditorGUILayout.PropertyField(weaponPoint2, new GUIContent("武器挂点2"));
        EditorGUILayout.PropertyField(mountPoint, new GUIContent("坐骑挂点"));
        EditorGUILayout.PropertyField(wingPoint, new GUIContent("翅膀挂点"));
		EditorGUILayout.PropertyField(baoGuadian, new GUIContent("抱挂点"));
        EditorGUILayout.PropertyField(headPoint, new GUIContent("头部挂点"));
        EditorGUILayout.PropertyField(touShiPoint, new GUIContent("头饰挂点"));
        EditorGUILayout.PropertyField(waistPoint, new GUIContent("腰饰挂点"));
        EditorGUILayout.PropertyField(shouhuanPoint, new GUIContent("手环挂点"));
        EditorGUILayout.PropertyField(tailPoint, new GUIContent("尾巴挂点"));
        EditorGUILayout.PropertyField(rightHandPoint, new GUIContent("右手挂点"));
        GUILayoutEx.EndContents();

        GUILayout.Label("测试装备:");
        GUILayoutEx.BeginContents();
        if (weaponPoint1.objectReferenceValue != null)
        {
            EditorGUILayout.PropertyField(this.testWeapon);
        }

        if (weaponPoint2.objectReferenceValue != null)
        {
            EditorGUILayout.PropertyField(this.testWeapon2);
        }

        if (mountPoint.objectReferenceValue != null)
        {
            EditorGUILayout.PropertyField(this.testMount);
        }

        if (wingPoint.objectReferenceValue != null)
        {
            EditorGUILayout.PropertyField(this.testWing);
        }
        GUILayoutEx.EndContents();

        this.serializedObject.ApplyModifiedProperties();

        if (Application.isPlaying)
        {
            var attachment = this.target as ActorAttachment;
            if (GUILayout.Button("标准相机"))
            {
                var follow = Camera.main.GetOrAddComponent<CameraFollow>();
                follow.Target = attachment.transform;
                //follow.Offset = new Vector3(6.67f, 8.8f, 5.6f);
                //follow.Rotation = 145.0f;
                //follow.Pitch = 45.0f;
                follow.SyncRotation();
                follow.SyncImmediate();
            }

            GUILayout.BeginHorizontal();

            GUI.enabled = !attachment.TestWeapon.IsEmpty && 
                weaponPoint1.objectReferenceValue != null || 
                weaponPoint2.objectReferenceValue != null;
            if (this.weapon == null)
            {
                if (GUILayout.Button("装备武器"))
                {
                    this.ShowTestWeapon(attachment);
                }
            }
            else
            {
                if (GUILayout.Button("卸下武器"))
                {
                    this.HideTestWeapon();
                }
            }

            GUI.enabled = !attachment.TestMount.IsEmpty && 
                mountPoint.objectReferenceValue != null;
            if (!attachment.HasMount())
            {
                if (GUILayout.Button("装备坐骑"))
                {
                    this.ShowTestMount(attachment);
                }
            }
            else
            {
                if (GUILayout.Button("卸下坐骑"))
                {
                    this.HideTestMount(attachment);
                }
            }

            GUI.enabled = !attachment.TestWing.IsEmpty && 
                wingPoint.objectReferenceValue != null;
            if (this.wing == null)
            {
                if (GUILayout.Button("装备翅膀"))
                {
                    this.ShowTestWing(attachment);
                }
            }
            else
            {
                if (GUILayout.Button("卸下翅膀"))
                {
                    this.HideTestWing();
                }
            }

            GUI.enabled = true;
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUI.enabled = uiPoint.objectReferenceValue != null;
            if (this.uiName == null)
            {
                this.ShowUIName(uiPoint.objectReferenceValue as Transform);
            }
            else
            {
                this.HideUIName();
            }

            GUI.enabled = uiPoint.objectReferenceValue != null;
            if (this.uiTitle == null)
            {
                if (GUILayout.Button("显示称号"))
                {
                    this.ShowUITitle(uiPoint.objectReferenceValue as Transform);
                }
            }
            else
            {
                if (GUILayout.Button("隐藏称号"))
                {
                    this.HideUITitle();
                }
            }

            GUI.enabled = uiPoint.objectReferenceValue != null;
            if (this.uiHP == null)
            {
                if (GUILayout.Button("显示血条"))
                {
                    this.ShowUIHP(uiPoint.objectReferenceValue as Transform);
                }
            }
            else
            {
                if (GUILayout.Button("隐藏血条"))
                {
                    this.HideUIHP();
                }
            }

            GUI.enabled = uiPoint.objectReferenceValue != null;
            if (GUILayout.Button("飘字"))
            {
                this.ShowUIFloat(uiPoint.objectReferenceValue as Transform);
            }

            GUI.enabled = true;

            GUILayout.EndHorizontal();
        }
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        this.prof = this.serializedObject.FindProperty("prof");
        this.attachPoints = this.serializedObject.FindProperty("attachPoints");
        this.testWeapon = this.serializedObject.FindProperty("testWeapon");
        this.testWeapon2 = this.serializedObject.FindProperty("testWeapon2");
        this.testMount = this.serializedObject.FindProperty("testMount");
        this.testWing = this.serializedObject.FindProperty("testWing");
    }

    private Canvas GetTestCanvas()
    {
        if (this.uiCanvas == null)
        {
            var go = new GameObject("Canvas");
            this.uiCanvas = go.AddComponent<Canvas>();
            this.uiCanvas.renderMode = RenderMode.ScreenSpaceOverlay;
            var scaler = go.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            scaler.referenceResolution = new Vector2(1334, 896);
            go.AddComponent<ResolutionAdapter>();
        }

        return this.uiCanvas;
    }

    private void ShowUIName(Transform namePoint)
    {
        if (GUILayout.Button("显示名字"))
        {
            var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(
                "uis/views/healthbar", "SceneObjName");
            if (assetPaths.Length > 0)
            {
                var namePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPaths[0]);
                if (namePrefab != null)
                {
                    this.uiName = GameObject.Instantiate(namePrefab);
                    var canvas = this.GetTestCanvas();
                    this.uiName.transform.SetParent(canvas.transform, false);
                    var follow = this.uiName.GetOrAddComponent<UIFollowTarget>();
                    follow.Canvas = canvas;
                    follow.Target = namePoint;
                }
            }
        }
    }

    private void HideUIName()
    {
        if (GUILayout.Button("隐藏名字"))
        {
            GameObject.Destroy(this.uiName);
            this.uiName = null;
        }
    }

    private void ShowUITitle(Transform titlePoint)
    {
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(
            "effects/prefab/title_prefab", "Title_1000");
        if (assetPaths.Length > 0)
        {
            var titlePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPaths[0]);
            if (titlePrefab != null)
            {
                this.uiTitle = GameObject.Instantiate(titlePrefab);
                var canvas = this.GetTestCanvas();
                this.uiTitle.transform.SetParent(canvas.transform, false);
                var follow = this.uiTitle.GetOrAddComponent<UIFollowTarget>();
                follow.Canvas = canvas;
                follow.Target = titlePoint;
            }
        }
    }

    private void HideUITitle()
    {
        GameObject.Destroy(this.uiTitle);
        this.uiTitle = null;
    }

    private void ShowUIHP(Transform hpPoint)
    {
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(
            "uis/views/healthbar", "MonsterHP");
        if (assetPaths.Length > 0)
        {
            var hpPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPaths[0]);
            if (hpPrefab != null)
            {
                this.uiHP = GameObject.Instantiate(hpPrefab);
                var canvas = this.GetTestCanvas();
                this.uiHP.transform.SetParent(canvas.transform, false);
                var follow = this.uiHP.GetOrAddComponent<UIFollowTarget>();
                follow.Canvas = canvas;
                follow.Target = hpPoint;
            }
        }
    }

    private void HideUIHP()
    {
        GameObject.Destroy(this.uiHP);
        this.uiHP = null;
    }

    private void ShowUIFloat(Transform floatPoint)
    {
        var floatAssets = new string[] {
            "BeHurtLeft",
            "BeHurtRight",
            "BeCriticalLeft",
            "BeCriticalRight",
            "CriticalLeft",
            "CriticalRight",
            "HurtLeft",
            "HurtRight",
        };
        var assetName = floatAssets[Random.Range(0, floatAssets.Length)];
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(
            "uis/views/floatingtext", assetName);
        if (assetPaths.Length > 0)
        {
            var floatPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPaths[0]);
            if (floatPrefab != null)
            {
                var floatObj = GameObject.Instantiate(floatPrefab);
                var canvas = this.GetTestCanvas();
                floatObj.transform.SetParent(canvas.transform, false);
                floatObj.transform.position = UIFollowTarget.CalculateScreenPosition(
                    floatPoint.position, 
                    Camera.main, 
                    canvas, 
                    floatObj.transform.parent as RectTransform);
                var textObj = floatObj.transform.Find("Text");
                var text = textObj.GetComponent<Text>();
                text.text = Random.Range(1, 99999).ToString();
                var floatAnimator = floatObj.GetComponent<Animator>();
                floatAnimator.WaitEvent("exit", (param, stateInfo) => {
                    GameObject.Destroy(floatObj);
                });
            }
        }
    }

    private void ShowTestWeapon(ActorAttachment attachment)
    {
        Assert.IsTrue(Application.isPlaying);

        this.HideTestWeapon();
        if (!attachment.TestWeapon.IsEmpty)
        {
            var prefab = attachment.TestWeapon.LoadObject<GameObject>();
            var obj = GameObject.Instantiate(prefab);

            var point = attachment.GetAttachPoint(6);
            var attachObj = obj.GetComponent<AttachObject>();
            if (attachObj == null)
            {
                Debug.LogError("The weapon has no AttachObject.");
                GameObject.Destroy(obj);
            }
            else
            {
                attachObj.SetAttached(point);
                attachObj.SetTransform(attachment.Prof);

                this.weapon = obj;
            }
        }

        if (!attachment.TestWeapon2.IsEmpty)
        {
            var prefab = attachment.TestWeapon2.LoadObject<GameObject>();
            var obj = GameObject.Instantiate(prefab);

            var point = attachment.GetAttachPoint(7);
            var attachObj = obj.GetComponent<AttachObject>();
            if (attachObj == null)
            {
                Debug.LogError("The weapon has no AttachObject.");
                GameObject.Destroy(obj);
            }
            else
            {
                attachObj.SetAttached(point);
                attachObj.SetTransform(attachment.Prof);

                this.weapon2 = obj;
            }
        }
    }

    private void ShowTestWing(ActorAttachment attachment)
    {
        Assert.IsTrue(Application.isPlaying);
        if (attachment.TestWing.IsEmpty)
        {
            return;
        }

        this.HideTestWing();
        var prefab = attachment.TestWing.LoadObject<GameObject>();
        var obj = GameObject.Instantiate(prefab);

        var point = attachment.GetAttachPoint(9);
        var attachObj = obj.GetComponent<AttachObject>();
        if (attachObj == null)
        {
            Debug.LogError("The wing has no AttachObject.");
            GameObject.Destroy(obj);
            return;
        }

        attachObj.SetAttached(point);
        attachObj.SetTransform(attachment.Prof);

        this.wing = obj;
    }

    private void ShowTestMount(ActorAttachment attachment)
    {
        Assert.IsTrue(Application.isPlaying);
        if (attachment.TestMount.IsEmpty)
        {
            return;
        }

        this.HideTestMount(attachment);
        var prefab = attachment.TestMount.LoadObject<GameObject>();
        var obj = GameObject.Instantiate(prefab);
        attachment.AddMount(obj);

        var attachObj = obj.GetComponent<AttachObject>();
        if (attachObj != null)
        {
            attachObj.SetTransform(attachment.Prof);
        }

        this.mount = obj;
    }

    private void HideTestWeapon()
    {
        Assert.IsTrue(Application.isPlaying);
        if (this.weapon != null)
        {
            GameObject.Destroy(this.weapon);
            this.weapon = null;
        }

        if (this.weapon2 != null)
        {
            GameObject.Destroy(this.weapon2);
            this.weapon2 = null;
        }
    }

    private void HideTestMount(ActorAttachment attachment)
    {
        Assert.IsTrue(Application.isPlaying);
        if (this.mount != null)
        {
            attachment.RemoveMount();
            GameObject.Destroy(this.mount);
            this.mount = null;
        }
    }

    private void HideTestWing()
    {
        Assert.IsTrue(Application.isPlaying);
        if (this.wing != null)
        {
            GameObject.Destroy(this.wing);
            this.wing = null;
        }
    }
}
