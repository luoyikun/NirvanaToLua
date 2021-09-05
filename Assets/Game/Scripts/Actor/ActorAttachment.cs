//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using LuaInterface;
using Nirvana;
using UnityEngine;

/// <summary>
/// The attachments for an actor.
/// </summary>
public sealed class ActorAttachment : MonoBehaviour
{
    private static readonly int AnimationIDStatus =
        Animator.StringToHash("status");
    private static readonly int AnimationIDSpeed =
        Animator.StringToHash("speed");
    private static readonly int AnimationIDMount =
       Animator.StringToHash("mount");

    [SerializeField]
    private int prof = 0;

    [SerializeField]
    private Transform[] attachPoints;


#if UNITY_EDITOR
    [NoToLua]
    public AssetID TestWeapon
    {
        get { return this.testWeapon; }
        set { this.testWeapon = value; }
    }

    [NoToLua]
    public AssetID TestWeapon2
    {
        get { return this.testWeapon2; }
        set { this.testWeapon2 = value; }
    }

    [NoToLua]
    public AssetID TestMount
    {
        get { return this.testMount; }
        set { this.testMount = value; }
    }

    [NoToLua]
    public AssetID TestWing
    {
        get { return this.testWing; }
        set { this.testWing = value; }
    }
#endif

//#if UNITY_EDITOR
    [SerializeField]
    [AssetType(typeof(GameObject))]
    private AssetID testWeapon;

    [SerializeField]
    [AssetType(typeof(GameObject))]
    private AssetID testWeapon2;

    [SerializeField]
    [AssetType(typeof(GameObject))]
    private AssetID testMount;

    [SerializeField]
    [AssetType(typeof(GameObject))]
    private AssetID testWing;
//#endif

    private Animator animator;
    private GameObject mount;
    private Animator mountAnimator;
    private Transform mountAttach;
    private Transform mountPoint;
    private int jumpState = 0;
    private Vector3 lastPos = Vector3.zero;
    private Vector3 targetPos = Vector3.zero;
    private bool enable = true;
    private Vector3 offSet = new Vector3(0f, 2.0f, 0f);
    private bool isFightMount = false;

    /// <summary>
    /// Gets the prof.
    /// </summary>
    public int Prof
    {
        get { return this.prof; }
    }

    /// <summary>
    /// Gets the attach point by index.
    /// </summary>
    public Transform GetAttachPoint(int index)
    {
        if (index < this.attachPoints.Length)
        {
            return this.attachPoints[index];
        }

        return this.transform;
    }

    /// <summary>
    /// Check whether this actor has mount.
    /// </summary>
    public bool HasMount()
    {
        return this.mount != null;
    }

    /// <summary>
    /// Gets the mount object.
    /// </summary>
    public GameObject GetMount()
    {
        return this.mount;
    }

    public void SetMountUpTriggerEnable(bool enable)
    {
        this.enable = enable;
    }

    /// <summary>
    /// Change the mount for the actor.
    /// </summary>
    public void AddMount(GameObject mount, string mountPoint = "mount_point")
    {
        if (this.mount != null)
        {
            this.RemoveMount();
        }
        this.mount = mount;
        this.mountAnimator = mount.GetComponent<Animator>();

        this.mountPoint = this.mount.transform.FindByName(mountPoint);
        if (this.mountPoint == null)
        {
            this.mountPoint = this.mount.transform;
        }

        if (this.attachPoints != null && this.attachPoints.Length >= 8)
        {
            this.mountAttach = this.attachPoints[8];
        }

        if (this.mountAttach == null)
        {
            this.mountAttach = this.transform;
        }
        this.lastPos = this.transform.localPosition;
        this.targetPos = this.offSet + this.mountPoint.transform.localPosition;
        this.mount.SetLayerRecursively(this.gameObject.layer);

        this.isFightMount = false;

        if (this.animator != null)
        {
            this.animator.SetBool(AnimationIDMount, true);
            if (this.enable)
            {
                //this.animator.SetTrigger("MountUp");
            }        
            this.animator.SetLayerWeight(2, 1.0f);
        }
    }

    public void AddFightMount(GameObject mount)
    {
        if (this.mount != null)
        {
            this.RemoveMount();
        }
        this.mount = mount;
        this.mountAnimator = mount.GetComponent<Animator>();

        this.mountPoint = this.mount.transform.FindByName("mount_point");
        if (this.mountPoint == null)
        {
            this.mountPoint = this.mount.transform;
        }

        if (this.attachPoints != null && this.attachPoints.Length >= 5)
        {
            this.mountAttach = this.attachPoints[5];
        }

        if (this.mountAttach == null)
        {
            this.mountAttach = this.transform;
        }
        this.lastPos = this.transform.localPosition;
        this.targetPos = this.transform.localPosition - this.mountAttach.transform.localPosition + this.mountPoint.transform.localPosition;
        this.mount.SetLayerRecursively(this.gameObject.layer);

        this.isFightMount = true;

        if (this.animator != null)
        {
            this.animator.SetBool(AnimationIDMount, true);
            if (this.enable)
            {
                //this.animator.SetTrigger("MountUp");
            }
            this.animator.SetLayerWeight(3, 1.0f);
        }
    }

    public void RemoveMount()
    {
        if (this.mount != null)
        {
            this.mount = null;

            this.lastPos = this.transform.localPosition;
            this.targetPos = Vector3.zero;

            this.transform.localPosition = Vector3.zero;
            this.transform.localRotation = Quaternion.identity;

            if (this.animator != null &&
                this.animator.isActiveAndEnabled &&
                this.animator.layerCount >= 2)
            {
                this.animator.SetBool(AnimationIDMount, false);
                if (this.enable)
                {
                    this.animator.SetTrigger("MountDown");
                } 
                this.animator.SetLayerWeight(2, 0.0f);
                this.animator.SetLayerWeight(3, 0.0f);
            }
        }
    }

    public void JumpUp(int i)
    {
        this.jumpState = i;
        if (this.jumpState == 0 && (this.mountPoint == null || this.mountAttach == null || this.mount == null))
        {
            this.transform.localPosition = Vector3.zero;
            this.transform.localRotation = Quaternion.identity;
        }
    }

#if UNITY_EDITOR
    [NoToLua]
    public void AutoPick()
    {
        if (this.attachPoints == null || this.attachPoints.Length < 12)
        {
            this.attachPoints = new Transform[12];
        }

        this.attachPoints[0] = this.transform.FindByName("ui", "UI_guadian");
        this.attachPoints[1] = this.transform.FindByName("buff_top", "buff_up", "buff_upper");
        this.attachPoints[2] = this.transform.FindByName("buff_middle", "buff_point");
        this.attachPoints[3] = this.transform.FindByName("buff_bottom", "buff_down", "buff_root");
        this.attachPoints[4] = this.transform.FindByName("hurt_middle", "hurt_point", "buff_middle");
        this.attachPoints[5] = this.transform.FindByName("hurt_buttom", "hurt_root", "buff_down");
        this.attachPoints[6] = this.transform.FindByName("weapon_point", "weapon_point1");
        this.attachPoints[7] = this.transform.FindByName("weapon_point2");
        this.attachPoints[8] = this.transform.FindByName("mount_point");
        this.attachPoints[9] = this.transform.FindByName("wing_point");
        this.attachPoints[10] = this.transform.FindByName("bao_guadian");
        this.attachPoints[11] = this.transform.FindByName("head_point");
    }
#endif

    private void Awake()
    {
        this.animator = this.GetComponent<Animator>();
    }

    private void Start()
    {
        if (this.attachPoints != null && this.attachPoints.Length >= 8)
        {
            var mountAttach = this.attachPoints[8];
            if (mountAttach != null)
            {
                this.offSet = this.transform.position - mountAttach.transform.position;
            }
        }
    }

    private void LateUpdate()
    {
        if (this.jumpState == 1)
        {
            this.transform.localPosition = Vector3.Lerp(this.transform.localPosition, this.targetPos, Time.deltaTime);
            this.transform.localPosition = new Vector3(this.transform.localPosition.x, this.lastPos.y, this.transform.localPosition.z);
        }
        else if (this.jumpState == 2)
        {
            this.transform.localPosition = Vector3.Lerp(this.transform.localPosition, this.targetPos, Time.deltaTime * 5);
        }
        else if (this.jumpState == 3)
        {
            this.transform.localPosition = this.targetPos;
        }
        if (this.mountPoint == null || this.mountAttach == null || this.mount == null || this.jumpState > 0)
        {
            this.jumpState = 0;
            return;
        }

        // 同步位置.
        var offset = this.transform.position - this.mountAttach.transform.position;

        if (!this.isFightMount)
        {
            this.transform.position = this.mountPoint.transform.position + offset;
        }
        else
        {
            this.transform.position = this.mountPoint.transform.position;
        }  

        // 同步动画.
        if (this.mountAnimator != null && this.animator != null)
        {
            if (this.isFightMount)
                return;

            this.mountAnimator.SetInteger(
                AnimationIDStatus,
                this.animator.GetInteger(AnimationIDStatus));
            this.mountAnimator.SetFloat(
                AnimationIDSpeed,
                this.animator.GetFloat(AnimationIDSpeed));
        }
    }
}
