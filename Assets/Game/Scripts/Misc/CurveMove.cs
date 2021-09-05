using System;
using System.Collections.Generic;
using UnityEngine;

public class CurveMove : MonoBehaviour
{
    [SerializeField]
    private AnimationCurve elasticX = AnimationCurve.Linear(0.0f, 0.0f, 1.0f, 1.0f);

    [SerializeField]
    private AnimationCurve elasticY = AnimationCurve.Linear(0.0f, 0.0f, 1.0f, 1.0f);

    [SerializeField]
    private AnimationCurve elasticZ = AnimationCurve.Linear(0.0f, 0.0f, 1.0f, 1.0f);

    private Vector3 startPos = Vector3.zero;
    private Vector3 distanceUnit = Vector3.zero;
    private float elapseTime = 0;
    private float totalTime = 0;
    private Action moveEndCallback = null;

    public void MoveTo(Vector3 target_local_pos, float total_time, Action move_end_callback)
    {
        Vector3 movement = target_local_pos - this.transform.localPosition;
        this.Move(new Vector3(movement.x, -movement.y, Math.Abs(movement.z)),
                     total_time, move_end_callback);
    }

    public void Move(Vector3 distance_unit, float total_time, Action move_end_callback)
    {
        this.startPos = this.transform.localPosition;

        this.distanceUnit = distance_unit;
        this.totalTime = total_time;
        this.moveEndCallback = move_end_callback;
        this.elapseTime = 0;
    }

    public bool IsMoveing()
    {
        return this.totalTime > 0;
    }

    public void StopMove()
    {
        this.totalTime = 0;
    }

    private void Update()
    {
        if (this.totalTime <= 0)
        {
            return;
        }

        this.elapseTime += Time.deltaTime;

        float eval = this.elapseTime / this.totalTime;
        Vector3 movement = new Vector3(
            this.distanceUnit.x * this.elasticX.Evaluate(eval),
            this.distanceUnit.y * this.elasticY.Evaluate(eval),
            this.distanceUnit.z * this.elasticZ.Evaluate(eval));

        this.transform.localPosition = this.startPos + movement;

        if (this.elapseTime >= this.totalTime)
        {
            this.totalTime = 0;
            this.elapseTime = 0;
            if (null != this.moveEndCallback)
            {
                this.moveEndCallback();
            }
        }
    }
}
