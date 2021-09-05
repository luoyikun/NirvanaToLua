using UnityEngine;

[CreateAssetMenu(
        fileName = "QingGongObject",
        menuName = "Actor/QingGongObject")]
public class ActorQingGongObject : ScriptableObject {
    [SerializeField]
    private AnimationCurve verticalCurve;
    [SerializeField]
    private AnimationCurve horizonCurve;
    [SerializeField]
    private bool enableVerticalCurve = false;
    [SerializeField]
    private bool enableHorizonCurve = false;

    private float time = 0;

    public AnimationCurve VerticalCurve
    {
        get
        {
            return this.verticalCurve;
        }
    }

    public AnimationCurve HorizonCurve
    {
        get
        {
            return this.horizonCurve;
        }
    }

    public bool EnableVerticalCurve
    {
        get
        {
            return this.enableVerticalCurve;
        }
    }

    public bool EnableHorizonCurve
    {
        get
        {
            return this.enableHorizonCurve;
        }
    }

    public float Time
    {
        get
        {
            if (time == 0)
            {
                float time1 = 0;
                float time2 = 0;

                if (enableHorizonCurve)
                {
                    int length = horizonCurve.length;
                    time1 = horizonCurve.keys[length - 1].time;
                }

                if (enableVerticalCurve)
                {
                    int length = verticalCurve.length;
                    time2 = verticalCurve.keys[length - 1].time;
                }

                time = time1 > time2 ? time1 : time2;
            }

            return time;
        }
    }
}
