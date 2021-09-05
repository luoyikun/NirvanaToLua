//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections;
using Nirvana;
using UnityEngine;
using HedgehogTeam.EasyTouch;
using System.Collections.Generic;
using DG.Tweening;

/// <summary>
/// The scene driver used for test during edit the scene.
/// </summary>
public sealed class SceneDriver : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The actor asset.")]
    private AssetID actorAsset;

    [SerializeField]
    [Tooltip("The camera folllow.")]
    private CameraFollow cameraFollow;

    [SerializeField]
    private float minFlyOffset = 2f;

    [SerializeField]
    private float maxFlyHeight = 120f;
    private GameObject player;
    private Animator animator;
    private MoveableObject moveable;
    private Vector3 lastMousePosition;
    private float moveSpeed = 5.0f;
    private float curFlyHeight = 0f;
    private bool isFly = false;
    private bool isFlyUp = false;
    private bool isFlyDown = false;
    private GameObject wing;

    private void Awake()
    {
        if (GameRoot.Instance != null)
        {
            GameObject.Destroy(this.gameObject);
        }
        else
        {
            SceneOptimizeMgr.StaticBatch();
            this.InitActor();

            // this.StartCoroutine(this.InitActor());
        }
    }

    private void InitActor()
    {
        Instantiate(EditorResourceMgr.LoadGameObject("scenes_prefab", "CameraFollow.prefab"));

        T4MObjSC[] t4m = FindObjectsOfType<T4MObjSC>();
        foreach (T4MObjSC ot4mbj in t4m)
        {
            ot4mbj.Awake();
        }

        if (this.actorAsset.IsEmpty)
        {
            this.actorAsset = new AssetID("actors/role", "1001001.prefab");
        }

        this.player = Instantiate(EditorResourceMgr.LoadGameObject(this.actorAsset.BundleName, this.actorAsset.AssetName));

        this.player.SetLayerRecursively(GameLayers.Role);
        this.animator = this.player.GetComponent<Animator>();
        this.moveable = this.player.GetOrAddComponent<MoveableObject>();
        this.moveable.SetPosition(this.transform.position);
        this.curFlyHeight = this.moveable.Height(GameLayers.Walkable);
        this.moveable.SetMoveCallback(status =>
        {
            if (this.animator != null)
            {
                this.animator.SetInteger("status", 0);
            }
        });

        var follow = Camera.main.GetComponentInParent<CameraFollow>();
        if (follow != null)
        {
            follow.Target = this.player.transform;
            follow.SyncImmediate();

            cameraFollow = follow;
        }

        GameObject easyTouch = new GameObject("Easy Touch");
        easyTouch.AddComponent<HedgehogTeam.EasyTouch.EasyTouch>();

        EasyTouch.On_Swipe += OnSwipe;
        EasyTouch.On_Pinch += OnPinch;
        EasyTouch.On_SimpleTap += OnSimpleTap;
    }

    private void Update()
    {
        if (this.moveable == null)
        {
            return;
        }

        /*if (this.cameraFollow != null)
        {
            if (!Mathf.Approximately(Input.mouseScrollDelta.y, 0.0f))
            {
                //var offset = this.cameraFollow.Offset;
                //offset.y += Input.mouseScrollDelta.y;
                //this.cameraFollow.Offset = offset;
                this.cameraFollow.SyncImmediate();
            }

            if (Input.GetMouseButtonDown(1))
            {
                this.lastMousePosition = Input.mousePosition;
            }

            if (Input.GetMouseButton(1))
            {
                var mouseDelta = Input.mousePosition - this.lastMousePosition;
                if (!Mathf.Approximately(mouseDelta.x, 0.0f))
                {
                    //this.cameraFollow.Rotation += 0.2f * mouseDelta.x;
                    //this.cameraFollow.SyncRotation();
                    //this.cameraFollow.SyncImmediate();
                }

                this.lastMousePosition = Input.mousePosition;
            }
        }*/

        if (Input.GetKey(KeyCode.W))
        {
            this.OnJoystickUpdate(0, 1);
        }

        if (Input.GetKey(KeyCode.S))
        {
            this.OnJoystickUpdate(0, -1);
        }

        if (Input.GetKey(KeyCode.A))
        {
            this.OnJoystickUpdate(-1, 0);
        }

        if (Input.GetKey(KeyCode.D))
        {
            this.OnJoystickUpdate(1, 0);
        }
    }

    private void OnGUI()
    {
        GUI.Label(new Rect(5, 5, 100, 25), "Speed:");
        this.moveSpeed = GUI.HorizontalSlider(
            new Rect(50, 10, 100, 100), this.moveSpeed, 5.0f, 20.0f);
        GUI.Label(new Rect(5, 25, 100, 25), this.moveSpeed.ToString());
        this.DrawFly();
    }

    private void OnJoystickUpdate(float fx, float fy)
    {
        if (this.isFlyUp || this.isFlyDown)
        {
            return;
        }
        var dir = this.ActuallyMoveDir(fx, fy).normalized;
        var pos = this.player.transform.position;
        var target = new Vector3(
            pos.x + 8 * dir.x,
            pos.y,
            pos.z + 8 * dir.y);
        this.moveable.RotateTo(target, 10.0f);
        var height = this.moveable.Height(GameLayers.Walkable, target);
        if (height == float.NegativeInfinity)
        {
            return;
        }
        this.moveable.MoveTo(target, this.moveSpeed);
        if (this.animator != null)
        {
            this.animator.SetInteger("status", 1);
        }
    }

    private Vector2 ActuallyMoveDir(float fx, float fy)
    {
        var quat = new Quaternion();
        var screen_forward = new Vector3(0, 0, 1);
        var screen_input = new Vector3(fx, 0, fy);

        quat.SetFromToRotation(screen_forward, screen_input);
        quat.eulerAngles = new Vector3(
            quat.eulerAngles.x, quat.eulerAngles.y, 0);

        var camera_forward = Camera.main.transform.forward;
        camera_forward.y = 0;

        var move_dir = quat * camera_forward;

        return new Vector2(move_dir.x, move_dir.z);
    }

    private void OnSwipe(Gesture gesture)
    {
        if (this.cameraFollow != null)
        {
            var swipeVector = gesture.swipeVector;
            this.cameraFollow.Swipe(swipeVector.x, swipeVector.y);
        }
    }


    private void OnPinch(Gesture gesture)
    {
        if (this.cameraFollow != null)
        {
            this.cameraFollow.Pinch(gesture.deltaPinch);
        }
    }

    private void OnSimpleTap(Gesture gesture)
    {
        if (this.isFly || this.isFlyDown || this.isFlyUp)
            return;
        var ray = Camera.main.ScreenPointToRay(gesture.position);
        var sceneHits = Physics.RaycastAll(
            ray, Mathf.Infinity, 1 << GameLayers.Walkable);
        if (sceneHits.Length > 0)
        {
            var hit = sceneHits[0];
            this.moveable.RotateTo(hit.point, 10.0f);
            this.moveable.MoveTo(hit.point, this.moveSpeed);
            if (this.animator != null)
            {
                this.animator.SetInteger("status", 1);
            }
        }
    }

    private void DrawFly()
    {
        Rect ltArea = new Rect(0, Screen.height - 100, 100, 100);
        GUI.Box(ltArea, "");
        GUILayout.BeginArea(ltArea);
        GUILayout.Label("飞行切换：");
        if (GUILayout.Button("飞行"))
        {
            if (this.isFly)
                return;
            this.ShowWing();
            this.moveable.StopMove();
            this.isFly = true;
            this.isFlyUp = true;
            var tweener = this.player.transform.DOMoveY(this.curFlyHeight, 1f);
            tweener.onComplete = () => {
                this.moveable.IsFly = true;
                this.isFlyUp = false;
                this.moveSpeed = 15f;
            };
        }

        if (GUILayout.Button("降落"))
        {
            if (!this.isFly)
                return;
            var height = this.moveable.Height(GameLayers.Walkable);
            if (height == float.NegativeInfinity)
            {
                Debug.LogError("不能在不可行走区域停止飞行！");
                return;
            }
            this.moveable.StopMove();
            this.isFlyDown = true;
            var tweener = this.player.transform.DOMoveY(height, 1f);
            tweener.onComplete = () => {
                this.isFlyDown = false;
                this.isFly = false;
                this.moveable.IsFly = false;
                this.moveable.SetOffset(Vector3.zero);
                this.moveable.SetPosition(this.player.transform.position);
                this.RemoveWing();
                this.moveSpeed = 5f;
            };
        }
        GUILayout.EndArea();

        if (this.isFly && !this.isFlyUp)
        {
            Rect rtArea = new Rect(Screen.width - 100, Screen.height - 100, 100, 100);
            GUI.Box(rtArea, "");
            GUILayout.BeginArea(rtArea);
            GUILayout.Label("飞行高度：");
            if (GUILayout.Button("上升"))
            {
                if (this.curFlyHeight + 1f >= this.maxFlyHeight)
                    return;
                var tween = DOTween.To(() => this.curFlyHeight, x => { Debug.LogError("=====" + x); this.curFlyHeight = x; this.UpdateFlyHeight(this.curFlyHeight); }, this.curFlyHeight + 2f, 0.2f);
            }

            if (GUILayout.Button("下降"))
            {
                var groundHeight = this.moveable.Height(GameLayers.Walkable);
                if (this.curFlyHeight - 1f <= this.minFlyOffset + groundHeight)
                    return;
                var tween = DOTween.To(() => this.curFlyHeight, x => { this.curFlyHeight = x; this.UpdateFlyHeight(this.curFlyHeight); }, this.curFlyHeight - 2f, 0.2f);
            }
            GUILayout.EndArea();
        }
    }

    private void UpdateFlyHeight(float height)
    {
//         var groundHeight = this.moveable.Height(GameLayers.Walkable);
//         if (groundHeight == float.NegativeInfinity)
//             return;
//         var offset = height - groundHeight;
        this.moveable.SetFlyHeight = this.curFlyHeight;

    }

    private void ShowWing()
    {
#if UNITY_EDITOR
        if (this.wing)
            return;
        var attachment = this.player.GetComponent<ActorAttachment>();
        if (attachment.TestWing.IsEmpty)
        {
            return;
        }

        var prefab = attachment.TestWing.LoadObject<GameObject>();
        var obj = GameObject.Instantiate(prefab);
        this.wing = obj;

        var attachObj = obj.GetComponent<AttachObject>();
        if (attachObj != null)
        {
            attachObj.SetTransform(attachment.Prof);
            attachObj.SetAttached(attachment.GetAttachPoint(9));
        }
        if (this.animator)
        {
            this.animator.SetLayerWeight(1, 1f);
        }
#endif
    }

    private void RemoveWing()
    {
        if (this.wing)
        {
            GameObject.Destroy(this.wing);
            this.wing = null;
        }

        if (this.animator)
        {
            this.animator.SetLayerWeight(1, 0f);
        }
    }

//     private void LateUpdate()
//     {
//         if (!this.isFly || this.isFlyDown || this.isFlyUp)
//             return;
//         var groundHeight = this.moveable.Height(GameLayers.Walkable);
//         this.curFlyHeight = Mathf.Max(groundHeight + this.minFlyOffset, this.curFlyHeight);
//         this.UpdateFlyHeight(this.curFlyHeight);
//         this.cameraFollow.SyncImmediate();
//     }
}
