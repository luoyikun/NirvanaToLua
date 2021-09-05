//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// The moveable object is used to control the actor movement for lua script.
/// </summary>
public sealed class MoveableObject : MonoBehaviour
{
    private static RaycastHit[] hits = new RaycastHit[8];

    private bool rotating;
    private Quaternion rotateTarget;
    private float rotateSpeed;
    private Action<int> rotateCallback;

    private bool moving;
    private Vector3 moveTarget;
    private float moveSpeed;
    private Action<int> moveCallback;
    private Vector3 offset;
    private bool checkWater = false;
    private float waterHeight = 0f;
    private bool isInWater = false;
    private Action<bool> enterWaterCallBack;

    private bool isFly = false;
    private Vector3 fly_offset;
    private float flyHeight = 0f;
    private float min_fly_height = 2f;
    private float max_fly_height = 120f;

    public bool enableQingGong = false;
    public bool checkBuilding = false;
    public static float heightDifference =1f;
    private float jumpHorizonSpeed = 5f;
    private bool isSimpleJump = false;
    private bool isOnGround = true;
    private ActorQingGong qingGong;
    private Action<QingGongState> stateCallBack;

    private int lastCalcRaycastLayerMask = -1;
    private Vector3 lastCalcRaycastPosition = Vector3.zero;
    private float lastCalcRaycastHeight = 0;
    private bool isRaycastOptimize = false;

    public void Clear()
    {
        isRaycastOptimize = false;
        lastCalcRaycastLayerMask = -1;
        lastCalcRaycastHeight = 0;
        this.rotateCallback = null;
        this.moveCallback = null;
        this.enterWaterCallBack = null;
        this.stateCallBack = null;

        if (null != this.qingGong)
        {
            this.qingGong.Clear();
        }
    }

    public void SetIsRaycastOptimize(bool isRaycastOptimize)
    {
        this.isRaycastOptimize = isRaycastOptimize;
    }

    private ActorQingGong QingGong
    {
        get
        {
            if (null == this.qingGong)
            {
                this.qingGong = this.gameObject.AddComponent<ActorQingGong>();
                this.qingGong.enabled = false;
                this.qingGong.SetStateChangeCallBack(this.QingGongStateChanged);
            }
            return this.qingGong;
        }
    }

    public bool IsOnGround
    {
        private set
        {
            if (value != this.isOnGround)
            {
                if (!value)
                {
                    this.StopMove();
                    this.StopRotate();
                }
                this.isOnGround = value;
            }
        }
        get
        {
            return this.isOnGround;
        }
    }

    public float JumpHorizonSpeed
    {
        get
        {
            return this.jumpHorizonSpeed;
        }
        set
        {
            this.jumpHorizonSpeed = value;
            if (enableQingGong)
                this.QingGong.forwardSpeed = value;
        }
    }

    public Vector3 FixToGround(Vector3 position)
    {
        bool isInWater = false;
        float height = float.NegativeInfinity;
        float hight_groud;

        if (enableQingGong)
        {
            hight_groud = GetNearestHeight(position);
        }
        else if (checkBuilding)
        {
            hight_groud = HeightByMask(1 << GameLayers.Walkable | 1 << GameLayers.SmallBuilding | 1 << GameLayers.BigBuilding, position);
        }
        else
        {
            hight_groud = Height(GameLayers.Walkable, position);
        }

        if (this.checkWater)
        {
            float hight_water = Height(GameLayers.Water, position);

            if (hight_water - hight_groud > this.waterHeight)
            {
                height = hight_water;
                isInWater = true;
            }
            else
            {
                height = hight_groud;
            }
            if (null != this.enterWaterCallBack)
            {
                if (this.isInWater != isInWater)
                    this.enterWaterCallBack(isInWater);
            }
            this.isInWater = isInWater;
        }
        else
        {
            height = hight_groud;
        }

        if (height > float.NegativeInfinity)
        {
            return new Vector3(position.x, height, position.z);
        }
        else
        {
            return position;
        }
    }

    /// <summary>
    /// Set the callback to receive the rotate event.
    /// </summary>
    public void SetRotateCallback(Action<int> rotateCallback)
    {
        this.rotateCallback = rotateCallback;
    }

    /// <summary>
    /// Set the callback to receive the move event.
    /// </summary>
    public void SetMoveCallback(Action<int> moveCallback)
    {
        this.moveCallback = moveCallback;
    }

    /// <summary>
    /// Set the position offset.
    /// </summary>
    public void SetOffset(Vector3 offset)
    {
        this.offset = offset;

        if (!this.isOnGround)
        {
            return;
        }

        this.transform.position = FixToGround(this.transform.position) + this.offset + this.fly_offset;
    }


    /// <summary>
    /// Set the position fly offset.
    /// </summary>
    public void SetFlyOffset(Vector3 fly_offset)
    {
        this.fly_offset = fly_offset;
        this.transform.position = FixToGround(this.transform.position) + this.offset + this.fly_offset;
    }

    /// <summary>
    /// Set the position of this object and fix to ground.
    /// </summary>
    public void SetPosition(float x, float y, float z)
    {
        this.SetPosition(new Vector3(x, y, z));
    }

    /// <summary>
    /// Set the position of this object and fix to ground.
    /// </summary>
    public void SetPosition(Vector3 position)
    {
        if (!this.isOnGround)
        {
            return;
        }

        //this.transform.position = position;
        this.transform.position = FixToGround(position) + this.offset + this.fly_offset;
    }

    /// <summary>
    /// Set the rotation of this object and fix to ground.
    /// </summary>
    public void SetRotation(float x, float y, float z)
    {
        this.SetRotation(Quaternion.Euler(x, y, z));
    }

    /// <summary>
    /// Set the rotation of this object and fix to ground.
    /// </summary>
    public void SetRotation(Quaternion rotation)
    {
        this.transform.rotation = rotation;
    }

    public void SetRotationOffset(float x, float y, float z)
    {
        this.SetRotationOffset(new Vector3(x, y, z));
    }

    public void SetRotationOffset(Vector3 offset)
    {
        var rotation = this.transform.eulerAngles + offset;
        this.transform.rotation = Quaternion.Euler(rotation);
    }

    public void SetRotationX(float x)
    {
        var rotation = new Vector3(x, this.transform.eulerAngles.y, 0);
        this.transform.rotation = Quaternion.Euler(rotation);
    }

    /// <summary>
    /// Rotate to the target direction by specify rotate speed.
    /// </summary>
    public void RotateTo(float x, float y, float z, float speed)
    {
        this.RotateTo(new Vector3(x, y, z), speed);
    }

    /// <summary>
    /// Rotate to the target direction by specify rotate speed.
    /// </summary>
    public void RotateTo(Vector3 target, float speed)
    {
        if (!this.isOnGround)
        {
            return;
        }

        var offset = target - transform.position;
        offset.y = 0;
        if (offset.sqrMagnitude > float.Epsilon)
        {
            this.rotateTarget = Quaternion.LookRotation(offset);
            this.rotateSpeed = speed;
            this.rotating = true;
        }
    }

    /// <summary>
    /// Stop the rotate.
    /// </summary>
    public void StopRotate()
    {
        this.rotating = false;
        if (this.rotateCallback != null)
        {
            this.rotateCallback(0);
        }
    }

    /// <summary>
    /// Move to specify position at specify speed.
    /// </summary>
    public void MoveTo(float x, float y, float z, float speed)
    {
        this.MoveTo(new Vector3(x, y, z), speed);
    }

    /// <summary>
    /// Move to specify position at specify speed.
    /// </summary>
    public void MoveTo(Vector3 target, float speed)
    {
        if (!this.isOnGround)
        {
            return;
        }

        this.moveTarget = target;
        this.moveSpeed = speed;
        this.moving = true;
    }

    /// <summary>
    /// Stop moving.
    /// </summary>
    public void StopMove()
    {
        this.moving = false;
        if (this.moveCallback != null)
        {
            this.moveCallback(0);
        }
    }

    private void Update()
    {
        if (!this.isOnGround)
        {
            return;
        }

        if (this.moving && this.rotating)
        {
            var position = this.DoPosition(this.transform.position);
            var rotation = this.DoRotation(this.transform.rotation);
            this.transform.SetPositionAndRotation(position, rotation);
        }
        else if (this.moving)
        {
            var position = this.DoPosition(this.transform.position);
            this.transform.position = position;
        }
        else if (this.rotating)
        {
            var rotation = this.DoRotation(this.transform.rotation);
            this.transform.rotation = rotation;
        }
    }

    private void FixedUpdate()
    {
        if (!this.IsOnGround && this.isSimpleJump)
        {
            Vector3 dir = this.moveTarget - this.transform.position;
            dir.y = 0;
            dir.Normalize();
            this.AdjustMoveMent(dir.x, dir.z);
        }
    }

    private void LateUpdate()
    {
        if (this.isFly && this.flyHeight > 0)
        {
            var groundHeight = this.Height(GameLayers.Walkable);
            if (groundHeight == float.NegativeInfinity)
            {
                return;
            }
            this.flyHeight = Mathf.Max(groundHeight + this.min_fly_height, this.flyHeight);
            var curr_fly_height = this.flyHeight - groundHeight;
            this.SetFlyOffset(new Vector3(0, curr_fly_height, 0));
        }
    }

    private Vector3 DoPosition(Vector3 position)
    {
        var offset = this.moveTarget - position;
        offset.y = 0;
        var movement = offset.normalized * Time.unscaledDeltaTime * this.moveSpeed;
        if (movement.sqrMagnitude >= offset.sqrMagnitude)
        {
            position = this.moveTarget;
            this.moving = false;
            if (this.moveCallback != null)
            {
                this.moveCallback(1);
            }
        }
        else
        {
            position += movement;
        }

        Vector3 newPosition;
        if (enableQingGong)
        {
            float height = GetNearestHeight(position);
            newPosition = new Vector3(position.x, height, position.z);

            if (transform.position.y - height > heightDifference)
            {
                IsOnGround = false;
                QingGong.enabled = true;
                newPosition = new Vector3(position.x, transform.position.y, position.z);
            }
            else if (height - transform.position.y > heightDifference)
            {
                newPosition = transform.position;
                this.moving = false;
                if (this.moveCallback != null)
                {
                    this.moveCallback(2);
                }
            }
        }
        else
        {
            newPosition = FixToGround(position);
        }

        return newPosition + this.offset + fly_offset;
    }

    private Quaternion DoRotation(Quaternion rotation)
    {
        rotation = Quaternion.Slerp(
            rotation,
            this.rotateTarget,
            Time.unscaledDeltaTime * this.rotateSpeed);

        var angle = Quaternion.Angle(rotation, this.rotateTarget);
        if (angle < 0.01f)
        {
            rotation = this.rotateTarget;
            this.rotating = false;
            if (this.rotateCallback != null)
            {
                this.rotateCallback(1);
            }
        }

        return rotation;
    }

    public float Height(int layer, Vector3 position = new Vector3())
    {
        int layerMask = 1 << layer;
        return HeightByMask(layerMask, position);
    }

    private float HeightByMask(int layerMask, Vector3 position)
    {
        if (position.Equals(Vector3.zero))
        {
            position = this.gameObject.transform.position;
        }
    
        // 因为碰撞器在场景中是固定不变的，因此 角色位置不变，则不需要重新计算
        if (this.isRaycastOptimize && layerMask == lastCalcRaycastLayerMask && lastCalcRaycastPosition.Equals(position))
        {
            return lastCalcRaycastHeight;
        }

        float height = float.NegativeInfinity;
        var ray = new Ray(position + (10000.0f * Vector3.up), Vector3.down);
        var count = Physics.RaycastNonAlloc(ray, hits, float.PositiveInfinity, layerMask);
        bool isHit = false;
        if (count > 0 && count <= hits.Length)
        {
            for (int i = 0; i < count; ++i)
            {
                var hit = hits[i];
                if (height < hit.point.y)
                {
                    height = hit.point.y;
                    isHit = true;
                }
            }
        }

        if (isHit)
        {
            lastCalcRaycastLayerMask = layerMask;
            lastCalcRaycastPosition = position;
            lastCalcRaycastHeight = height;
        }

        return height;
    }

    /// <summary>
    /// 设置当前飞行高度
    /// </summary>
    public float SetFlyHeight
    {
        get { return this.flyHeight; }
        set { this.flyHeight = value; }
    }

    /// <summary>
    /// 最小飞行高度
    /// </summary>
    public float MinFlyHeight
    {
        get { return this.min_fly_height; }
        set { this.min_fly_height = value; }
    }

    /// <summary>
    /// 最大飞行高度
    /// </summary>
    public float MaxFlyHeight
    {
        get { return this.max_fly_height; }
        set { this.max_fly_height = value; }
    }

    public bool IsFly
    {
        get { return this.isFly; }
        set
        {
            if (value)
            {
                this.flyHeight = this.min_fly_height + this.Height(GameLayers.Walkable);
            }
            else
            {
                this.flyHeight = 0f;
                this.SetFlyOffset(Vector3.zero);
            }
            this.isFly = value;
        }
    }

    public bool CheckWater
    {
        get { return this.checkWater; }
        set
        {
            var oldValue = this.checkWater;
            this.checkWater = value;
            if (oldValue != value)
            {
                this.transform.position = FixToGround(this.transform.position) + this.offset + this.fly_offset;
            }
        }
    }

    public float WaterHeight
    {
        get { return this.waterHeight; }
        set
        {
            var oldValue = this.waterHeight;
            this.waterHeight = value;
            if (checkWater && oldValue != value)
            {
                this.transform.position = FixToGround(this.transform.position) + this.offset + this.fly_offset;
            }
        }
    }

    public bool IsInWater
    {
        get { return this.isInWater; }
    }

    public void SetEnterWaterCallBack(Action<bool> callBack)
    {
        this.enterWaterCallBack = callBack;
        if (null != callBack)
        {
            callBack(this.isInWater);
        }
    }

    private void QingGongStateChanged(QingGongState state)
    {
        if (state == QingGongState.OnGround)
        {
            IsOnGround = true;
            this.QingGong.enabled = false;
        }
        else
        {
            IsOnGround = false;
        }

        if (null != this.stateCallBack)
        {
            this.stateCallBack(state);
        }
    }

    public void SetStateChangeCallBack(Action<QingGongState> stateCallBack)
    {
        this.stateCallBack = stateCallBack;
    }

    public void Jump(ActorQingGongObject qinggongObject)
    {
        if (!enableQingGong)
            return;

        this.isSimpleJump = false;
        this.QingGong.enabled = true;
        this.QingGong.autoJump = false;
        this.QingGong.forwardSpeed = this.jumpHorizonSpeed;
        this.QingGong.AddJumpForce(qinggongObject);
    }

    public void SimpleJump(ActorQingGongObject qinggongObject, Vector3 target, bool autoJump = false)
    {
        if (!enableQingGong)
            return;

        this.moveTarget = target;
        this.isSimpleJump = true;
        this.QingGong.enabled = true;
        this.QingGong.autoJump = autoJump;
        this.QingGong.forwardSpeed = this.jumpHorizonSpeed;
        this.QingGong.AddJumpForce(qinggongObject);
    }

    public void ForceLanding()
    {
        if (enableQingGong)
        {
            if (QingGong.enabled)
            {
                QingGong.ForceLanding();
            }
        }
    }
    public void AdjustMoveMent(float fx, float fy)
    {
        if (!enableQingGong || this.IsOnGround)
            return;

        this.QingGong.AdjustMoveMent(fx, fy);
    }

    public void SetQingGongTarget(Vector3 target)
    {
        if (!enableQingGong || !isSimpleJump)
            return;

        this.moveTarget = target;
    }

    public void SetGravityMultiplier(float multiplier)
    {
        if (!enableQingGong)
            return;

        this.QingGong.m_GravityMultiplier = multiplier;
    }

    public static void SetGridFindWay(GridFindWay gridFindWay)
    {
        ActorQingGong.gridFindWay = gridFindWay;
    }

    public static void SetLogicMap(int origin_x, int origin_y, int width, int height)
    {
        ActorQingGong.SetLogicMap(origin_x, origin_y, width, height);
    }

    private bool IsTunnelArea(Vector3 position)
    {
        if (enableQingGong)
        {
            return ActorQingGong.IsTunnelArea(position);
        }

        return false;
    }

    private float GetNearestHeight(Vector3 position)
    {
        float height;
        float groundHeight = Height(GameLayers.Walkable, position);
        groundHeight = groundHeight == float.NegativeInfinity ? transform.position.y : groundHeight;

        int layerMask = 1 << GameLayers.BigBuilding | 1 << GameLayers.SmallBuilding;
        float roofHeight = HeightByMask(layerMask, position);
        roofHeight = roofHeight == float.NegativeInfinity ? groundHeight : roofHeight;

        bool nextPosIsTunnelArea = IsTunnelArea(position);
        if (nextPosIsTunnelArea)
        {
            float difference_1 = Math.Abs(transform.position.y - roofHeight);
            float difference_2 = Math.Abs(transform.position.y - groundHeight);
            height = difference_1 <= difference_2 ? roofHeight : groundHeight;
        }
        else
        {
            height = roofHeight >= groundHeight ? roofHeight : groundHeight;
        }
        return height;
    }

    public void SetDrag(float drag)
    {
        if (!enableQingGong)
            return;

        this.QingGong.Drag = drag;
    }

    public void JumpFormAir(float height, Vector3 target, ActorQingGongObject qinggongObject, float progress = 0)
    {
        if (!enableQingGong)
            return;

        float groundHeight = Height(GameLayers.Walkable, transform.position);
        transform.position = new Vector3(transform.position.x, height, transform.position.z);

        target.y = transform.position.y;
        transform.LookAt(target);
        moveTarget = target;
        isSimpleJump = true;
        QingGong.enabled = true;
        QingGong.forwardSpeed = this.jumpHorizonSpeed;
        this.QingGong.AddJumpForce(qinggongObject, progress);
        IsOnGround = false;
    }
}
