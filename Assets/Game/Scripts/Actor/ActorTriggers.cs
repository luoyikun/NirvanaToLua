//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;
using UnityEngine.Assertions;

/// <summary>
/// The trigger for animator.
/// </summary>
[RequireComponent(typeof(Animator))]
public sealed class ActorTriggers : MonoBehaviour, IActorTarget
{
    [SerializeField]
    private ActorTriggerEffect[] effects;

    [SerializeField]
    private ActorTriggerHalt[] halts;

    [SerializeField]
    private ActorTriggerSound[] sounds;

    [SerializeField]
    private ActorTriggerCameraShake[] cameraShakes;

    [SerializeField]
    private ActorTriggerCameraFOV[] cameraFOVs;

    [SerializeField]
    private ActorTriggerSceneFade[] sceneFades;

    [SerializeField]
    private ActorTriggerFootstep[] footsteps;

    private Animator animator;
    private bool enableEffect = true;
    private bool enableHalt = true;
    private bool enableCameraShake = true;
    private bool enableCamera = true;
    private bool enableSceneFade = true;
    private bool enableFootsteps = true;

    public ActorTriggerEffect[] Effects { get { return effects; } }

    public ActorTriggerHalt[] Halts { get { return halts; } }

    public ActorTriggerSound[] Sounds { get { return sounds; } }

    public ActorTriggerCameraShake[] CameraShakes { get { return cameraShakes; } }

    public ActorTriggerCameraFOV[] CameraFOVs { get { return cameraFOVs; } }

    public ActorTriggerSceneFade[] SceneFades { get { return sceneFades; } }

    public ActorTriggerFootstep[] FootSteps { get { return footsteps; } }

    /// <summary>
    /// Gets or sets the target of this actor.
    /// </summary>
    public Transform Target { get; set; }

    /// <summary>
    /// Gets or sets a value indicating whether enable the effect.
    /// </summary>
    public bool EnableEffect
    {
        get
        {
            return this.enableEffect;
        }

        set
        {
            if (this.enableEffect != value)
            {
                this.enableEffect = value;
                foreach (var effect in this.effects)
                {
                    effect.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable the halt.
    /// </summary>
    public bool EnableHalt
    {
        get
        {
            return this.enableHalt;
        }

        set
        {
            if (this.enableHalt != value)
            {
                this.enableHalt = value;
                foreach (var halt in this.halts)
                {
                    halt.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable the camera shake.
    /// </summary>
    public bool EnableCameraShake
    {
        get
        {
            return this.enableCameraShake;
        }

        set
        {
            if (this.enableCameraShake != value)
            {
                this.enableCameraShake = value;
                foreach (var cameraShakes in this.cameraShakes)
                {
                    cameraShakes.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable the camera.
    /// </summary>
    public bool EnableCameraFOV
    {
        get
        {
            return this.enableCamera;
        }

        set
        {
            if (this.enableCamera != value)
            {
                this.enableCamera = value;
                foreach (var cameraFOV in this.cameraFOVs)
                {
                    cameraFOV.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable the scene fade.
    /// </summary>
    public bool EnableSceneFade
    {
        get
        {
            return this.enableSceneFade;
        }

        set
        {
            if (this.enableSceneFade != value)
            {
                this.enableSceneFade = value;
                foreach (var sceneFade in this.sceneFades)
                {
                    sceneFade.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable the footsteps.
    /// </summary>
    public bool EnableFootsteps
    {
        get
        {
            return this.enableFootsteps;
        }

        set
        {
            if (this.enableFootsteps != value)
            {
                this.enableFootsteps = value;
                foreach (var footstep in this.footsteps)
                {
                    footstep.Enalbed = value;
                }
            }
        }
    }

    /// <summary>
    /// Stop all effects.
    /// </summary>
    public void StopEffects()
    {
        foreach (var effect in this.effects)
        {
            effect.StopEffects();
        }
    }

    private void Awake()
    {
        this.animator = this.GetComponent<Animator>();
        Assert.IsNotNull(this.animator);

        var dispatcher = this.GetOrAddComponent<AnimatorEventDispatcher>();

        if (this.effects != null)
        {
            foreach (var effect in this.effects)
            {
                effect.Init(this, dispatcher, this);
            }
        }

        if (this.halts != null)
        {
            foreach (var halt in this.halts)
            {
                halt.Init(this, dispatcher, this);
                halt.Enalbed = this.EnableHalt;
            }
        }

        if (this.sounds != null)
        {
            foreach (var sound in this.sounds)
            {
                sound.Init(this, dispatcher, this);
            }
        }

        if (this.cameraShakes != null)
        {
            foreach (var cameraShakes in this.cameraShakes)
            {
                cameraShakes.Init(this, dispatcher, this);
                cameraShakes.Enalbed = this.EnableCameraShake;
            }
        }

        if (this.cameraFOVs != null)
        {
            foreach (var cameraFOV in this.cameraFOVs)
            {
                cameraFOV.Init(this, dispatcher, this);
                cameraFOV.Enalbed = this.EnableCameraFOV;
            }
        }

        if (this.sceneFades != null)
        {
            foreach (var sceneFade in this.sceneFades)
            {
                sceneFade.Init(this, dispatcher, this);
                sceneFade.Enalbed = this.EnableSceneFade;
            }
        }

        if (this.footsteps != null)
        {
            foreach (var footstep in this.footsteps)
            {
                footstep.Init(this, dispatcher, this);
            }
        }
    }

    private void OnDisable()
    {
        foreach (var halt in this.halts)
        {
            halt.Reset();
        }
    }

    private void Update()
    {
        if (this.cameraFOVs != null)
        {
            foreach (var camera in this.cameraFOVs)
            {
                camera.Update();
            }
        }

        if (this.sceneFades != null)
        {
            foreach (var sceneFade in this.sceneFades)
            {
                sceneFade.Update();
            }
        }

        if (this.effects != null)
        {
            foreach (var effect in this.effects)
            {
                effect.Update();
            }
        }

        if (this.halts != null)
        {
            foreach (var halt in this.halts)
            {
                halt.Update();
            }
        }

        if (this.sounds != null)
        {
            foreach (var sound in this.sounds)
            {
                sound.Update();
            }
        }

        if (this.cameraShakes != null)
        {
            foreach (var cameraShakes in this.cameraShakes)
            {
                cameraShakes.Update();
            }
        }

        if (this.footsteps != null)
        {
            foreach (var footstep in this.footsteps)
            {
                footstep.Update();
            }
        }
    }
}
