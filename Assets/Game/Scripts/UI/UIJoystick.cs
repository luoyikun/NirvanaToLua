//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using HedgehogTeam.EasyTouch;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.SceneManagement;

public sealed class UIJoystick : MonoBehaviour
{
    [SerializeField]
    [Tooltip("摇杆最大半径, 以像素为单位")]
    private float radius = 80.0f;

    [SerializeField]
    [Tooltip("可显示物体的根节点")]
    private GameObject visibleRoot = null;

    [SerializeField]
    [Tooltip("移动的摇杆显示对象")]
    private RectTransform thumb = null;

    [SerializeField]
    [Tooltip("移动的摇杆背景")]
    private RectTransform bg = null;

    [SerializeField]
    [Tooltip("摇杆模式")]
    private JoystickMode mode = JoystickMode.Fixed;

    [SerializeField]
    [Tooltip("事件触发的间隔事件")]
    private float eventInterval = 0.1f;

    [SerializeField]
    [Tooltip("是否旋转背景图片")]
    private bool rotateBG = false;

    [SerializeField]
    [Tooltip("是否自动隐藏")]
    private bool isAutoFade = false;

    private Canvas canvas;
    private RectTransform thrumParent;
    private bool isTouched = false;
    private float lastEventTime = 0.0f;
    private Vector2 offset = Vector2.zero;
    private Vector2 localPos = Vector2.zero;
    private int fingerIndex = -1;

    public Action<float, float> OnDragBegin;
    public Action<float, float> OnDragUpdate;
    public Action<float, float> OnDragEnd;
    public Action<bool, int> OnIsTouched;

    /// <summary>
    /// The joystick mode.
    /// </summary>
    public enum JoystickMode
    {
        /// <summary>
        /// The fixed joystick stay in the fixed position of the screen.
        /// </summary>
        Fixed,

        /// <summary>
        /// The dynamic joystick show in any position when touched.
        /// </summary>
        Dynamic,
    }

    /// <summary>
    /// add joystick listener.
    /// </summary>
    public void AddDragBeginListener(Action<float, float> listener)
    {
        this.OnDragBegin += listener;
    }

    /// <summary>
    /// add joystick listener.
    /// </summary>
    public void AddDragUpdateListener(Action<float, float> listener)
    {
        this.OnDragUpdate += listener;
    }

    /// <summary>
    /// add joystick listener.
    /// </summary>
    public void AddDragEndListener(Action<float, float> listener)
    {
        this.OnDragEnd += listener;
    }

    public void AddIsTouchedListener(Action<bool, int> listener)
    {
        this.OnIsTouched += listener;
    }

    private void Awake()
    {
        this.canvas = this.GetComponentInParent<Canvas>();
        Assert.IsNotNull(this.canvas);

        if (this.thumb == null)
        {
            this.thumb = (RectTransform)gameObject.transform.Find("thumb");
        }

        Assert.IsNotNull(this.bg);

        if (this.bg == null)
        {
            this.bg = (RectTransform)gameObject.transform.Find("bg");
        }

        Assert.IsNotNull(this.bg);


        this.thrumParent = (RectTransform)this.thumb.parent;
        Assert.IsNotNull(this.thrumParent);

        if (JoystickMode.Dynamic == this.mode)
        {
            if (this.isAutoFade)
            {
                this.visibleRoot.SetActive(false);
                // this.bg.gameObject.SetActive(false);
            }
            //localPos.x = this.visibleRoot.transform.localPosition.x;
            //localPos.y = this.visibleRoot.transform.localPosition.y;
        }

        if (this.mode == JoystickMode.Fixed)
        {
            EasyTouch.On_TouchStart += this.OnDragBeginHandler;
            EasyTouch.On_TouchDown += this.OnDragHandler;
            EasyTouch.On_TouchUp += this.OnDragEndHandler;
        }
        else
        {
            EasyTouch.On_SwipeStart += this.OnDragBeginHandler;
            EasyTouch.On_Swipe += this.OnDragHandler;
            EasyTouch.On_SwipeEnd += this.OnDragEndHandler;
        }

        EasyTouch.On_Cancel += this.OnDragCancel;
        SceneManager.activeSceneChanged += this.OnChangeScene;
    }

    //awake的时候位置是不对的，所以在start里记录位置
    private void Start()
    {
        if (JoystickMode.Dynamic == this.mode)
        {
            localPos.x = this.visibleRoot.transform.localPosition.x;
            localPos.y = this.visibleRoot.transform.localPosition.y;
        }
    }

    private void OnDestroy()
    {
        if (this.mode == JoystickMode.Fixed)
        {
            EasyTouch.On_TouchStart -= this.OnDragBeginHandler;
            EasyTouch.On_TouchDown -= this.OnDragHandler;
            EasyTouch.On_TouchUp -= this.OnDragEndHandler;
        }
        else
        {
            EasyTouch.On_SwipeStart -= this.OnDragBeginHandler;
            EasyTouch.On_Swipe -= this.OnDragHandler;
            EasyTouch.On_SwipeEnd -= this.OnDragEndHandler;
        }

        EasyTouch.On_Cancel -= this.OnDragCancel;
        SceneManager.activeSceneChanged -= this.OnChangeScene;
    }

    private void Update()
    {
        if (this.isTouched)
        {
            if (Time.time >= this.lastEventTime + this.eventInterval)
            {
                this.lastEventTime = Time.time;
                if (this.OnDragUpdate != null)
                {
                    this.OnDragUpdate(this.offset.x, this.offset.y);
                }
            }
        }
    }

    private void LateUpdate()
    {
        if (!this.isTouched)
        {
            this.thumb.localPosition = Vector2.zero;
            if (this.rotateBG)
            {
                this.bg.transform.localEulerAngles = new Vector3(0, 0, 0);
            }
        }
    }

    private void OnDragBeginHandler(Gesture gesture)
    {
        if (this.thumb == null)
        {
            return;
        }

        if (this.isTouched && gesture.fingerIndex != this.fingerIndex)
        {
            return;
        }

        if (this.isAutoFade)
        {
            this.visibleRoot.SetActive(true);
            // this.bg.gameObject.SetActive(true);
        }

        if (this.isTouched)
        {
            if (this.OnDragEnd != null)
            {
                this.OnDragEnd(this.offset.x, this.offset.y);
            }

            this.offset = Vector2.zero;
        }

        if (this.mode == JoystickMode.Fixed)
        {
            Vector2 position;
            var rect = (RectTransform)this.visibleRoot.transform;
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(
                rect, gesture.startPosition, this.canvas.worldCamera, out position))
            {
                return;
            }

            if (!rect.rect.Contains(position))
            {
                return;
            }
        }
        else if (this.mode == JoystickMode.Dynamic)
        {
            Vector2 position;
            var parent = (RectTransform)this.visibleRoot.transform.parent;
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(
                parent, gesture.startPosition, this.canvas.worldCamera, out position))
            {
                return;
            }

            this.visibleRoot.transform.localPosition = position;
        }
        this.isTouched = true;
        this.fingerIndex = gesture.fingerIndex;
        if (null != this.OnIsTouched)
        {
            this.OnIsTouched(true, this.fingerIndex);
        }

        this.lastEventTime = Time.time;

        if (this.OnDragBegin != null)
        {
            this.OnDragBegin(this.offset.x, this.offset.y);
        }
    }

    private void OnDragHandler(Gesture gesture)
    {
        if (!this.isTouched || gesture.fingerIndex != this.fingerIndex)
        {
            return;
        }

        Vector2 localPointerPosition;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(
            this.thrumParent,
            gesture.position,
            this.canvas.worldCamera,
            out localPointerPosition))
        {
            this.thumb.localPosition = localPointerPosition;
            this.offset.x = localPointerPosition.x;
            this.offset.y = localPointerPosition.y;
            float magnitude = this.thumb.localPosition.magnitude;
            if (magnitude > this.radius)
            {
                float x = this.thumb.localPosition.x / magnitude * this.radius;
                float y = this.thumb.localPosition.y / magnitude * this.radius;
                this.thumb.localPosition = new Vector3(x, y, 0.0f);
                this.offset.x = x;
                this.offset.y = y;
            }
            if (this.rotateBG)
            {
                float angle = (float)(Math.Atan2(this.thumb.localPosition.y, this.thumb.localPosition.x) * 180 / Math.PI);
                this.bg.localEulerAngles = new Vector3(0, 0, angle + 90);
            }
        }
    }

    private void OnDragEndHandler(Gesture gesture)
    {
        if (!this.isTouched || gesture.fingerIndex != this.fingerIndex)
        {
            return;
        }

        if (this.OnDragEnd != null)
        {
            this.OnDragEnd(this.offset.x, this.offset.y);
        }

        this.isTouched = false;
        this.fingerIndex = -1;
        if (null != this.OnIsTouched)
        {
            this.OnIsTouched(false, -1);
        }
        this.offset = Vector2.zero;

        if (JoystickMode.Dynamic == this.mode)
        {
            if (this.isAutoFade)
            {
                this.visibleRoot.SetActive(false);
                // this.bg.gameObject.SetActive(false);
            }
            this.visibleRoot.transform.localPosition = localPos;
        }
    }

    private void OnDragCancel(Gesture gesture)
    {
        this.isTouched = false;
        this.fingerIndex = -1;
        if (null != this.OnIsTouched)
        {
            this.OnIsTouched(false, -1);
        }
        this.offset = Vector2.zero;

        if (JoystickMode.Dynamic == this.mode)
        {
            if (this.isAutoFade)
            {
                this.visibleRoot.SetActive(true);
                // this.bg.gameObject.SetActive(true);
            }
        }
    }

    private void OnChangeScene(Scene fron, Scene to)
    {
        if (!this.isTouched)
        {
            return;
        }

        this.isTouched = false;
        this.fingerIndex = -1;
        if (null != this.OnIsTouched)
        {
            this.OnIsTouched(false, -1);
        }
        this.offset = Vector2.zero;

        if (JoystickMode.Dynamic == this.mode)
        {
            if (this.isAutoFade)
            {
                this.visibleRoot.SetActive(false);
                // this.bg.gameObject.SetActive(false);
            }
            this.visibleRoot.transform.localPosition = localPos;
        }
    }
}
