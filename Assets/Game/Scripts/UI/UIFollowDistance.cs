using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIFollowDistance : MonoBehaviour {
    [SerializeField]
    private Transform targetTransform;
    [SerializeField]
    private float minDistance;
    [SerializeField]
    private float maxDistance;
    [SerializeField]
    private AnimationCurve curve = new AnimationCurve(new Keyframe(0f, 1f), new Keyframe(1f, 0f));

    private float sqrtMinDistance;
    private float sqrtMaxDistance;
    private float offset;
    private Vector3 lastTargetPos;
    private Vector3 lastCameraPos;
    private Canvas canvas;
    private int sortingOrderBegin;

    void Start()
    {
        this.sqrtMinDistance = this.minDistance * this.minDistance;
        this.sqrtMaxDistance = this.maxDistance * this.maxDistance;
        this.offset = this.maxDistance - this.minDistance;

        canvas = this.transform.GetComponent<Canvas>();
        Canvas parent_canvas = this.transform.parent.GetComponent<Canvas>();
        if (null!= parent_canvas) sortingOrderBegin = parent_canvas.sortingOrder;
    }

    void OnEnable()
    {
        this.UpdateScale();
    }

    void Update()
    {
        if (null != this.targetTransform && null != Camera.main)
        {
            if (this.lastTargetPos != this.targetTransform.position || this.lastCameraPos != Camera.main.transform.position)
            {
                this.lastTargetPos = this.targetTransform.position;
                this.lastCameraPos = Camera.main.transform.position;
                this.UpdateScale();
            }
        }
    }

    private void UpdateScale()
    {
        if (null != this.targetTransform && null != Camera.main)
        {
            float lastScale = this.transform.localScale.x;

            var sqrtDistance = (this.targetTransform.position - Camera.main.transform.position).sqrMagnitude;
            if (sqrtDistance > sqrtMaxDistance)
            {
                this.transform.localScale = Vector3.zero;
            }
            else if(!this.IsVisible())
            {
                this.transform.localScale = Vector3.zero;
            }
            else if (sqrtDistance <= this.sqrtMinDistance)
            {
                this.transform.localScale = Vector3.one;
            }
            else
            {
                var distance = Mathf.Sqrt(sqrtDistance) - this.minDistance;
                var scale = Mathf.Clamp(this.curve.Evaluate(distance / this.offset), 0f, 1f);
                this.transform.localScale = new Vector3(scale, scale, scale);
            }

            if (null != canvas && Mathf.Abs(this.transform.localScale.x - lastScale) >= 0.001f)
            {
                canvas.overrideSorting = true;
                canvas.sortingOrder = sortingOrderBegin + (int)(this.transform.localScale.x * 1000.0f);
            }
        }
    }

    // 是否在视野内
    private bool IsVisible()
    {
        var visible = true;
        if (null != this.targetTransform && null != Camera.main)
        {
            var vector = Camera.main.transform.position - this.targetTransform.position;
            if (Vector3.Dot(vector, Camera.main.transform.forward) > 0)
                visible = false;
        }
        return visible;
    }

    public float MinDistance
    {
        set
        {
            if (this.minDistance != value)
            {
                this.minDistance = value;
                this.sqrtMinDistance = this.minDistance * this.minDistance;
                this.offset = this.maxDistance - this.minDistance;
                this.UpdateScale();
            }
        }
        get { return this.minDistance; }
    }

    public float MaxDistance
    {
        set
        {
            if (this.maxDistance != value)
            {
                this.maxDistance = value;
                this.sqrtMaxDistance = this.maxDistance * this.maxDistance;
                this.offset = this.maxDistance - this.minDistance;
                this.UpdateScale();
            }
        }
        get { return this.maxDistance; }
    }

    public Transform TargetTransform
    {
        set
        {
            this.targetTransform = value;
            if (null != this.targetTransform)
            {
                this.lastTargetPos = this.targetTransform.position;
                this.UpdateScale();
            }
        }
        get { return this.targetTransform; }
    }
}
