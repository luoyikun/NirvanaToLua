using System.Collections;
using System;
using UnityEngine;
using Nirvana;

public class ActorQingGong : MonoBehaviour {
    public static GridFindWay gridFindWay;
    private static int origin_x;
    private static int origin_y;
    private static int width;
    private static int height;

    // 滑翔前进速度
    public float forwardSpeed = 0f;
    public float m_GravityMultiplier = 1f;
    public float turnSpeed = 1000f;
    public float drag = 0f;
    public bool autoJump = false;

    private Rigidbody m_Rigidbody;
    private Action<QingGongState> stateCallBack;
    private bool m_IsGrounded = true;
    private float m_GroundCheckDistance = 0.3f;
    private QingGongState curState = QingGongState.None;
    private Vector3 inputDir = Vector3.zero;
    private AnimationCurve verticalCurve;
    private AnimationCurve horizonCurve;
    private float stuckTimer = 0f;
    private float timer = 0f;
    private bool isForceLand = false;
    private Vector3 lastValidPos;
    private float downTimer = 0f;
    private float lastFallingSpeed = 0f;
    private bool readyToGround = false;

    public void Clear()
    {
        this.stateCallBack = null;
    }

    // Update is called once per frame
    void FixedUpdate() {
        if (null == horizonCurve && null == verticalCurve && Math.Abs(M_Rigidbody.velocity.y) < 0.5f)
        {
            stuckTimer += Time.fixedDeltaTime;
            if (stuckTimer >= 1f)
            {
                m_IsGrounded = true;
                if (null != stateCallBack)
                {
                    if (!readyToGround)
                    {
                        readyToGround = true;
                        stateCallBack(QingGongState.ReadyToGround);
                    }
                    stateCallBack(QingGongState.OnGround);
                }
                return;
            }
        }

        if (curState == QingGongState.Down)
        {
            if (M_Rigidbody.velocity.y > lastFallingSpeed)
            {
                m_IsGrounded = true;
                if (null != stateCallBack)
                {
                    if (!readyToGround)
                    {
                        readyToGround = true;
                        stateCallBack(QingGongState.ReadyToGround);
                    }
                    stateCallBack(QingGongState.OnGround);
                }
                return;
            }
            lastFallingSpeed = M_Rigidbody.velocity.y;

            if (!Physics.Raycast(transform.position - (Vector3.up * 2f), Vector3.down, 1000f))
            {
                downTimer += Time.fixedDeltaTime;
            }
                
            if (downTimer > 3f)
            {
                transform.position = lastValidPos;
                m_IsGrounded = true;
                if (null != stateCallBack)
                {
                    if (!readyToGround)
                    {
                        readyToGround = true;
                        stateCallBack(QingGongState.ReadyToGround);
                    }
                    stateCallBack(QingGongState.OnGround);
                }
                return;
            }
        }

        CheckGroundStatus();

        if (!m_IsGrounded || null != verticalCurve || null != horizonCurve)
        {
            UpdateGravity();
            UpdateRotation();
            UpdateForwardSpeed();
            UpdateVerticalSpeed();
            UpdateState();
        }

    }

    private void OnEnable()
    {
        inputDir = Vector3.zero;
        curState = QingGongState.None;
        stuckTimer = 0f;
        downTimer = 0f;
        lastFallingSpeed = 0f;
        isForceLand = false;
        readyToGround = false;
        autoJump = false;
    }

    private void OnDisable()
    {
        if (this.m_Rigidbody)
            Destroy(m_Rigidbody);
    }

    private Rigidbody M_Rigidbody
    {
        get
        {
            if (null == m_Rigidbody)
            {
                m_Rigidbody = transform.GetOrAddComponent<Rigidbody>();
                m_Rigidbody.constraints = RigidbodyConstraints.FreezeRotation;
                m_Rigidbody.useGravity = false;
                m_Rigidbody.interpolation = RigidbodyInterpolation.Interpolate;
                m_Rigidbody.drag = drag;

                Collider collider = transform.GetComponentInChildren<Collider>();
                if (null != collider)
                {
                    PhysicMaterial pMat = new PhysicMaterial();
                    pMat.frictionCombine = PhysicMaterialCombine.Multiply;
                    pMat.bounceCombine = PhysicMaterialCombine.Multiply;
                    pMat.dynamicFriction = 0f;
                    pMat.staticFriction = 0f;
                    pMat.bounciness = 0f;
                    collider.material = pMat;
                }
                
            }
            return m_Rigidbody;
        }
    }

    public float Drag
    {
        set
        {
            if (drag != value)
            {
                drag = value;
                if (m_Rigidbody)
                    m_Rigidbody.drag = value;
            }
        }
        get
        {
            return drag;
        }
    }

    public void AddJumpForce(ActorQingGongObject qinggongObject, float progress = 0)
    {
        if (qinggongObject.EnableVerticalCurve)
        {
            verticalCurve = qinggongObject.VerticalCurve;
        }
        else
        {
            verticalCurve = null;
        }
        if (qinggongObject.EnableHorizonCurve)
        {
            inputDir = Vector3.zero;
            horizonCurve = qinggongObject.HorizonCurve;
        }
        else
        {
            horizonCurve = null;
        }

        timer = Time.fixedTime - qinggongObject.Time * progress;
        stuckTimer = 0f;
        lastFallingSpeed = 0f;
        readyToGround = false;

        curState = QingGongState.None;
        if (IsValidArea(transform.position))
        {
            lastValidPos = transform.position;
        }
    }

    public void ForceLanding()
    {
        if (!isForceLand)
        {
            isForceLand = true;
            verticalCurve = null;
            horizonCurve = null;
            float y = M_Rigidbody.velocity.y > -10f ? -10f : M_Rigidbody.velocity.y;
            M_Rigidbody.velocity = new Vector3(0f, y, 0f);
        }
        
    }

    // 调整滑翔时的运动方向
    public void AdjustMoveMent(float fx, float fy)
    {
        if (isForceLand)
            return;

        Vector3 direction = new Vector3(fx, 0f, fy);

        if (direction.sqrMagnitude > 1f)
            direction.Normalize();

        inputDir = direction;
    }

    public void SetStateChangeCallBack(Action<QingGongState> stateCallBack)
    {
        this.stateCallBack = stateCallBack;
    }

    private void UpdateGravity()
    {
        if (null != verticalCurve)
        {
            return;
        }

        Vector3 extraGravityForce = Physics.gravity * m_GravityMultiplier;
        if (isForceLand)
            extraGravityForce *= 4f;

        M_Rigidbody.AddForce(extraGravityForce);
    }

    private void UpdateState()
    {
        QingGongState oldState = curState;
        if (M_Rigidbody.velocity.y > 0f)
        {
            curState = QingGongState.Up;
        }
        else if (M_Rigidbody.velocity.y < 0f)
        {
            curState = QingGongState.Down;
        }

        if (oldState != curState)
        {
            if (null != stateCallBack)
            {
                stateCallBack(curState);
            }

            if (curState == QingGongState.Down)
            {
                downTimer = 0f;
            }
        }
    }

    private void UpdateRotation()
    {
        if (isForceLand)
            return;

        if (inputDir.sqrMagnitude > 0.01f)
        {
            var dir = transform.InverseTransformDirection(inputDir);
            var turnAmount = Mathf.Atan2(dir.x, dir.z);
            transform.Rotate(0, turnAmount * turnSpeed * Time.deltaTime, 0);
        }
    }

    private void UpdateForwardSpeed()
    {
        if (isForceLand)
            return;

        if (curState == QingGongState.Down)
        {
            Vector3 velocity = transform.forward * forwardSpeed;
            M_Rigidbody.velocity = new Vector3(velocity.x, M_Rigidbody.velocity.y, velocity.z);
        }

        // 预先计算出下一次位移是否会到达边界
        Vector3 moveMent = Time.fixedDeltaTime * M_Rigidbody.velocity;
        Vector3 dir = M_Rigidbody.velocity.normalized;
        float magnitude = moveMent.sqrMagnitude;
        float distance = 0f;
        bool isBorder = false;
        while (distance <= magnitude)
        {
            distance = Mathf.Min(magnitude, distance);
            isBorder = IsBorder(transform.position + distance * dir);
            distance += 0.5f;
            if (isBorder)
                break;
        }
        if (isBorder && !autoJump)
        {
            M_Rigidbody.velocity = new Vector3(0f, M_Rigidbody.velocity.y, 0f);
        }

        if ((autoJump ||!isBorder) && curState != QingGongState.Down && null != horizonCurve)
        {
            var curve = horizonCurve;
            float time = Time.fixedTime - timer;
            int length = curve.length;
            if (time >= curve.keys[length - 1].time)
            {
                time = curve.keys[length - 1].time;
                horizonCurve = null;
            }
            float forwardSpeed = curve.Evaluate(time);
            Vector3 velocity = transform.forward * forwardSpeed;
            M_Rigidbody.velocity = new Vector3(velocity.x, M_Rigidbody.velocity.y, velocity.z);
        }

        if (autoJump)
        {
            bool curPositionIsValid = IsValidArea(transform.position);
            bool nextPositionIsValid = IsValidArea(transform.position + moveMent);
            if (curPositionIsValid && !nextPositionIsValid)
            {
                StopForwardMove();
                autoJump = false;
            }
        }
    }

    private void UpdateVerticalSpeed()
    {
        if (null != verticalCurve)
        {
            var curve = verticalCurve;
            float time = Time.fixedTime - timer;
            int length = curve.length;
            if (time >= curve.keys[length - 1].time)
            {
                time = curve.keys[length - 1].time;
                verticalCurve = null;
            }
            float speed = curve.Evaluate(time);
            M_Rigidbody.velocity = new Vector3(M_Rigidbody.velocity.x, speed, M_Rigidbody.velocity.z);
        }
    }

    private void CheckGroundStatus()
    {
        float distance = readyToGround ? m_GroundCheckDistance : 3f;
        RaycastHit hitInfo;

        if (curState != QingGongState.Up && Physics.Raycast(transform.position + (Vector3.up * 0.1f), Vector3.down, out hitInfo, distance,
            ~(1 << GameLayers.Role | 1 << GameLayers.MainRole | 1 << GameLayers.Clickable)))
        {
            if (!readyToGround && null == verticalCurve)
            {
                readyToGround = true;
                if (null != stateCallBack)
                {
                    stateCallBack(QingGongState.ReadyToGround);
                }
            }
        }
        else
        {
            m_IsGrounded = false;
        }
    }   
    
    public static void SetLogicMap(int _origin_x, int _origin_y, int _width, int _height)
    {
        origin_x = _origin_x;
        origin_y = _origin_y;
        width = _width;
        height = _height;
    }

    private static Vector2 WorldToLogic(float x, float y)
    {
        float logic_x = (x - origin_x) / width;
        float logic_y = (y - origin_y) / height;
        return new Vector2(logic_x, logic_y);
    }

    private static bool IsBorder(Vector3 position)
    {
        Vector2 logicPos = WorldToLogic(position.x, position.z);
        if (null != gridFindWay)
        {
            return gridFindWay.IsBorder((int)logicPos.x, (int)logicPos.y);
        }
        return false;
    }

    public static bool IsValidArea(Vector3 position)
    {
        Vector2 logicPos = WorldToLogic(position.x, position.z);
        if (null != gridFindWay)
        {
            return !gridFindWay.IsBlock((int)logicPos.x, (int)logicPos.y);
        }
        return false;
    }

    public static bool IsTunnelArea(Vector3 position)
    {
        Vector2 logicPos = WorldToLogic(position.x, position.z);
        if (null != gridFindWay)
        {
            return gridFindWay.IsTunnelArea((int)logicPos.x, (int)logicPos.y);
        }
        return false;
    }

    public void StopForwardMove()
    {
        horizonCurve = null;
        forwardSpeed = 0f;
        M_Rigidbody.velocity = new Vector3(0f, M_Rigidbody.velocity.y, 0f);
    }
}

public enum QingGongState
{
    None, Up, Down, ReadyToGround,OnGround
}
