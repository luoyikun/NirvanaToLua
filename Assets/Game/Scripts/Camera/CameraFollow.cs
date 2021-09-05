using UnityEngine;
using LuaInterface;
using DG.Tweening;

public class CameraFollow : MonoBehaviour
{
    [HideInInspector]
    [NoToLua]
    public Transform target;
    public Transform Target
    {
        set
        {
            target = value;
            MoveToTarget();
        }
        get
        {
            return target;
        }
    }

    [SerializeField]
    [Tooltip("Addition fov.")]
    private float fieldOfView = 45;

    [SerializeField]
    [Tooltip("The audio listener")]
    private AudioListener audioListener;

    [HideInInspector]
    public Vector3 TargetOffset = Vector3.zero;

    [HideInInspector]
    public float SmoothOffsetSpeed = 5;

    [HideInInspector]
    public bool AllowRotation = true;

    [HideInInspector]
    public bool IsChangeAngle = false;

    [HideInInspector]
    public bool AllowXRotation = true;

    [HideInInspector]
    public bool AllowYRotation = true;

    //     [HideInInspector]
    //     public Vector2 LockDefualAngle = new Vector2(45, 10);

    [HideInInspector]
    public Vector2 OriginAngle = new Vector2(45, 10);

    [HideInInspector]
    public Vector2 RotationSensitivity = new Vector2(5, 5);

    [HideInInspector]
    public float MinPitchAngle = 15;

    [HideInInspector]
    public float MaxPitchAngle = 55;

    [HideInInspector]
    public float MinYawAngle = -10;

    [HideInInspector]
    public float MaxYawAngle = 10;

    [HideInInspector]
    public float RotationSmoothing = 20;

    [HideInInspector]
    public bool AutoSmoothing = true;

    [HideInInspector]
    public bool AllowZoom = true;

    [HideInInspector]
    public float Distance = 9;

    [HideInInspector]
    public float MaxDistance = 13;

    [HideInInspector]
    public float MinDistance = 1;

    [HideInInspector]
    public float ZoomSmoothing = 10;

    public float autoRotationCD = 2f;
    public float autoRotationSpeedX = 30f;
    public float autoRotationSpeedY = 30f;
    public float bestRotationX = 105f;

    private bool autoRotation = false;
    private float autoRotationTime = 0f;

    private Transform cachedTransform;
    private Transform cameraTransform;

    private float oldDistance;
    private Quaternion oldRotation;
    private Vector2 angle;
    private Vector3 currentOffset;

    private Transform focalPoint;

    private Vector3 cameraLocalPosition = Vector3.zero;
    private Vector3 freeCameraLocalPosition = new Vector3(0, 0, -3);
    private float lastNor = 0f;
    private float lastAngle = 0f;
    private float lateCorrect = 0f;

    private bool stopCameraUpdate = false;

    public bool StopCameraUpdate
    {
        get { return this.stopCameraUpdate; }
        set { this.stopCameraUpdate = value; }
    }

    public AudioListener AudioListener
    {
        get
        {
            return audioListener;
        }
        set
        {
            audioListener = value;
        }
    }


    /// <summary>
    /// Gets or sets the filed of view.
    /// </summary>
    public float FieldOfView
    {
        get
        {
            return this.fieldOfView;
        }

        set
        {
            if (this.fieldOfView != value)
            {
                this.fieldOfView = value;
                this.SyncFieldOfView();
            }
        }
    }

    public void SyncFieldOfView()
    {
        Camera camera = this.GetComponentInChildren<Camera>();
        if (null != camera)
        {
            camera.fieldOfView = this.fieldOfView;
        }
    }

    public bool AutoRotation
    {
        get
        {
            return this.autoRotation;
        }
        set
        {
            if (this.autoRotation != value)
            {
                this.autoRotation = value;
                this.autoRotationTime = Time.realtimeSinceStartup + this.autoRotationCD;
            }
        }
    }

    /// <summary>
    /// Do animation.
    /// </summary>
    public Tweener DOFieldOfView(float endValue, float duration)
    {
        return DOTween.To(
            () => this.fieldOfView,
            v =>
            {
                this.fieldOfView = v;
                this.SyncFieldOfView();
            },
            endValue,
            duration);
    }

    private void Awake()
    {
        CreateFocalPoint();
    }

    private void OnDestroy()
    {
        if (focalPoint != null)
        {
            GameObject.Destroy(focalPoint.gameObject);
        }
    }

    private void Start()
    {
        oldDistance = Distance;
        cachedTransform = transform;

        angle = OriginAngle;
        Quaternion cameraRotation = Quaternion.Euler(angle.x, angle.y, 0);

        cachedTransform.position = focalPoint.position - cameraRotation * Vector3.forward * Distance;
        cachedTransform.LookAt(focalPoint.position, Vector3.up);

        oldRotation = cameraRotation;

        var camera = GetComponentInChildren<Camera>();
        if (camera)
        {
            cameraTransform = camera.transform;
            cameraLocalPosition = cameraTransform.localPosition;
        }
    }

    private void Update()
    {
        if (stopCameraUpdate)
        {
            return;
        }

        CameraCullObjMgr.Instance.UpdateCull();

        if (target == null)
        {
            return;
        }

        var targetTransform = target.transform;
        // var targetOffset = TargetOffset;

        // var offset = targetTransform.rotation * TargetOffset;
        var vector = this.target.position - this.transform.position;
        // currentOffset = Vector3.Lerp(currentOffset, offset, 5 * Time.deltaTime);
        // focalPoint.position = target.transform.position + TargetOffset;


        if (autoRotation)
        {
            if (AllowYRotation)
            {
                Vector3 normal = Vector3.Cross(this.target.forward, vector);
                var angle = Vector3.Dot(vector, this.target.forward);
                var need_ro = true;
                if (Mathf.Abs(normal.y) > 1 || (Mathf.Abs(normal.y) <= 1 && angle < 0))
                {
                    var x = normal.y < 0 ? 1f : -1f;
                    if (lastNor == 0)
                    {
                        lastNor = x;
                        lastAngle = angle;
                        lateCorrect = 0;
                    }
                    else
                    {
                        if (lastNor != x)
                        {
                            //lastNor = x;
                            if (Mathf.Abs(lastAngle - angle) <= 5)
                            {
                                lateCorrect += Time.deltaTime;
                                need_ro = false;

                                if (lateCorrect >= 1.5)
                                {
                                    lastNor = x;
                                    lastAngle = angle;
                                    need_ro = true;
                                }
                            }

                            else
                            {
                                lastNor = x;
                                lastAngle = angle;
                                lateCorrect = 0;
                            }
                        }
                        else
                            lastAngle = angle;
                    }
                    //x *= Time.deltaTime * 50f;
                    //this.Swipe (x, 0);

                    if (need_ro)
                    {
                        lateCorrect = 0;
                        x *= Time.deltaTime * 50f;
                        this.Swipe(x, 0);
                    }
                }
            }

            /*if (AllowXRotation)
			{
				var angle = Vector3.Dot(vector.normalized, this.target.up);
				angle = Mathf.Acos(angle) * Mathf.Rad2Deg;
				if (Mathf.Abs(angle - 120f) >1)
				{
					var x = angle > 120f ? 1f : -1f;
					x *= Time.deltaTime * 50f;
					this.Swipe(0, x);
				}
			}*/
        }

        else
        {
            lastNor = 0;
            lastAngle = 0;
            lateCorrect = 0;
        }
    }

    private void OnDisable()
    {
        var camera = GetComponentInChildren<Camera>();
        if (camera)
        {
            camera.transform.localPosition = this.freeCameraLocalPosition;
        }
        this.autoRotation = false;
    }

    private void LateUpdate()
    {
        if (stopCameraUpdate)
        {
            return;
        }

        if (target == null || focalPoint == null)
        {
            return;
        }

        focalPoint.position = target.transform.position + TargetOffset;

        this.UpdateCacheTransform();

        if (this.target != null && this.audioListener != null)
        {
            this.audioListener.transform.position = this.target.position;
        }
    }

    private void UpdateCacheTransform()
    {
        var targetQuat = Quaternion.Euler(angle.x, angle.y, 0);
        var nowQuat = Quaternion.Slerp(oldRotation, targetQuat, Time.deltaTime * RotationSmoothing * 0.5f);
        oldRotation = nowQuat;

        var currentDistance = (Distance - this.oldDistance) * Time.deltaTime * ZoomSmoothing * 0.5f + this.oldDistance;

        var diffTrans = nowQuat * Vector3.forward * currentDistance;

        var newCameraPos = focalPoint.position - diffTrans;

        var nowTargetPos = focalPoint.position;
        this.oldDistance = currentDistance;

        // 从摄象机位置垂直向上计算与地板的相交点
        RaycastHit hit;
        bool isHit = Physics.Raycast(new Vector3(newCameraPos.x, 1000, newCameraPos.z), Vector3.down, out hit, 2000, EditorSupport.LayerMask.Walkable);
        // 确保摄象机不会低于地板
        if (isHit && newCameraPos.y < hit.point.y + 1.5f)
        {
            newCameraPos.y = hit.point.y + 1.5f;
        }

        cachedTransform.position = newCameraPos;
        cachedTransform.LookAt(focalPoint.position);
    }

    // 注：通过该功能已屏掉上坡下坡功能
    public void SetIsFlyState(bool isFlyState)
    {
    }

    public void Swipe(float x, float y)
    {
        if (!AllowRotation)
        {
            return;
        }

        if (AllowXRotation)
        {
            var canRotation = true;
            if (angle.x - MinPitchAngle <= 0.1f)
            {
                if ((y > 0 && this.Distance - this.MinDistance > 0.01f) || (y < 0 && this.MaxDistance - this.Distance > 0.01f))
                {
                    canRotation = false;
                    this.Pinch(2 * y);
                }
            }
            if (canRotation)
            {
                angle.x += -y * RotationSensitivity.x * 0.1f;
                angle.x = Mathf.Clamp(angle.x, MinPitchAngle, MaxPitchAngle);
            }
        }

        if (AllowYRotation)
        {
            angle.y += x * RotationSensitivity.y * 0.1f;
            // angle.y = Mathf.Clamp(angle.y, OriginAngle.y + MinYawAngle, OriginAngle.y + MaxYawAngle);
        }
    }

    public void Pinch(float delta)
    {
        if (!AllowZoom)
        {
            return;
        }

        Distance = Distance + delta * -0.03f;
        Distance = Mathf.Clamp(Distance, MinDistance, MaxDistance);
    }

    public void SyncImmediate()
    {
        if (target == null)
        {
            return;
        }

        MoveToTarget();

        lastNor = 0;
        lastAngle = 0;
        lateCorrect = 0;
    }

    public void SyncRotation()
    {
        var targetQuat = Quaternion.Euler(angle.x, angle.y, 0);
        oldRotation = targetQuat;
    }

    public void ClampRotationAndDistance()
    {
        Distance = Mathf.Clamp(Distance, MinDistance, MaxDistance);
        angle.x = Mathf.Clamp(angle.x, MinPitchAngle, MaxPitchAngle);
        // angle.y = Mathf.Clamp(angle.y, OriginAngle.y + MinYawAngle, OriginAngle.y + MaxYawAngle);
    }

    public void CreateFocalPoint(GameObject focal_point = null)
    {
        if (null == focal_point)
        {
            GameObject go = new GameObject();
            go.name = "CamerafocalPoint";
            focalPoint = go.transform;
        }
        else
        {
            if (focalPoint)
            {
                Destroy(focalPoint.gameObject);
            }
            focalPoint = focal_point.transform;
        }

        MoveToTarget();
    }

    public void MoveToTarget()
    {
        if (target != null && focalPoint != null)
        {
            focalPoint.position = target.position + target.rotation * TargetOffset;
        }
    }

    public void ChangeAngle(Vector2 new_angle)
    {
        OriginAngle = new_angle;
        angle = OriginAngle;

        lastNor = 0;
        lastAngle = 0;
        lateCorrect = 0;
    }

    //     public void LockRotation(int is_lock_rotation)
    //     {
    //         if (is_lock_rotation == 1)
    //         {
    //             AllowRotation = false;
    //             this.ChanegeDefaultRotation();
    //         }
    //         else
    //         {
    //             AllowRotation = true;
    //             angle = OriginAngle;
    //         }
    //     }
    // 
    //     public void ChanegeDefaultRotation()
    //     {
    //         this.RotationSmoothing = 20;
    //         this.ZoomSmoothing = 10;
    //         this.MaxDistance = 13;
    //         this.MinDistance = 1;
    //         this.MinPitchAngle = 15;
    //         this.MaxPitchAngle = 55;
    //         this.Distance = 9;
    //         OriginAngle = LockDefualAngle;
    //         angle = OriginAngle;
    //     }

    public static CameraFollow Bind(GameObject go)
    {
        var CameraFollow2 = go.GetComponent<CameraFollow>() ?? go.AddComponent<CameraFollow>();
        return CameraFollow2;
    }
}
