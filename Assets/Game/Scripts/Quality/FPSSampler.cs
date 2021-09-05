//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// This is used to sample the FPS.
/// </summary>
public sealed class FPSSampler : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The statistics period time of sample.")]
    private float samplePeriod = 60.0f;

    [SerializeField]
    [Tooltip("The threshold for delta time avoid spike when the loading time.")]
    private float thresholdDeltaTime = 0.1f;

    private float sampleTimeLeft;
    private float sampleAccumTime;
    private int sampleFrameCount;

    /// <summary>
    /// Gets or sets the sample period.
    /// </summary>
    public float SamplePeriod
    {
        get { return this.samplePeriod; }
        set { this.samplePeriod = value; }
    }

    /// <summary>
    /// Gets or sets the threshold for delta time.
    /// </summary>
    public float ThresholdDeltaTime
    {
        get { return this.thresholdDeltaTime; }
        set { this.thresholdDeltaTime = value; }
    }

    /// <summary>
    /// The FPS sample event.
    /// </summary>
    public event Action<int> FPSEvent;

    private void Awake()
    {
        this.sampleTimeLeft = this.samplePeriod;
        this.sampleAccumTime = 0.0f;
        this.sampleFrameCount = 0;
    }

    private void Update()
    {
        // Calculate sample FPS.
        var deltaTime = Mathf.Min(Time.unscaledDeltaTime, this.thresholdDeltaTime);
        this.sampleTimeLeft -= deltaTime;
        this.sampleAccumTime += deltaTime;
        ++this.sampleFrameCount;

        if (this.sampleTimeLeft <= 0.0f)
        {
            // Calculate the fps and notify this sample.
            if (this.FPSEvent != null)
            {
                var fps = Mathf.RoundToInt(
                    this.sampleFrameCount / this.sampleAccumTime);
                this.FPSEvent(fps);
            }

            // Reset for the next period.
            this.sampleTimeLeft = this.samplePeriod;
            this.sampleAccumTime = 0.0f;
            this.sampleFrameCount = 0;
        }
    }
}
