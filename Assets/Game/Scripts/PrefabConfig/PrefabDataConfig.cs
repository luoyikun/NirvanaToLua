using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Nirvana;


public class PrefabDataConfig
{
    #region ActorController

    public ActorControllerData actorController = new ActorControllerData();

    public class ActorControllerData
    {
        public List<ProjectileData> projectiles = new List<ProjectileData>();

        public List<HurtData> hurts = new List<HurtData>();

        public AssetID beHurtEffecct = new AssetID("", "");

        public string hurtEffectName = string.Empty;

        public string beHurtNodeName = string.Empty;

        public bool beHurtAttach = false;

        public float hurtEffectFreeDelay = 0;

        public List<QualityCtrlData> QualityCtrlList = new List<QualityCtrlData>();
    }

    public class ProjectileData
    {
        public string Action = string.Empty;

        public HurtPositionEnum HurtPosition = 0;

        public AssetID Projectile = new AssetID("", "");

        public string ProjectilGoName = string.Empty;

        public string FromPosHierarchyPath = string.Empty;

        public float DelayProjectileEff = 0;

        public float DeleProjectileDelay = 0;

        public string ProjectilNodeHierarchyPath = string.Empty;

        public string ProjectileBtnName = string.Empty;
    }

    public class HurtData
    {
        public string Action = string.Empty;

        public AssetID HurtEffect = new AssetID("", "");

        public string HurtEffectGoName = string.Empty;

        public HurtPositionEnum HurtPosition = 0; 

        public HurtRotationEnum HurtRotation = 0;

        public int HitCount = 0;

        public float HitInterval = 0;

        public float HurtFreeDelay = 0;

        public float HitFreeDelay = 0;

        public float DelayHurtEffect = 0;

        public float DelayHitEffect = 0;

        public AssetID HitEffect = new AssetID("", "");

        public string HitEffectGoName = string.Empty;

        public HurtPositionEnum HitPosition = 0;

        public HurtRotationEnum HitRotation = 0;

        public string HurtBtnName = string.Empty;
    }

    public enum HurtPositionEnum
    {
        Root,
        HurtPoint,
    }

    public enum HurtRotationEnum
    {
        Target,
        HitDirection,
    }
    
    #endregion

    #region ActorTriggers

    public ActorTriggersData actorTriggers = new ActorTriggersData();

    public class ActorTriggersData
    {
        public List<TriggerEffect> effects = new List<TriggerEffect>();

        public List<TriggerHalt> halts = new List<TriggerHalt>();

        public List<TriggerSound> sounds = new List<TriggerSound>();

        public List<CameraShakeData> cameraShakes = new List<CameraShakeData>();

        public List<CameraFOV> cameraFOVs = new List<CameraFOV>();

        public List<SceneFade> sceneFades = new List<SceneFade>();

        public List<FootStep> footsteps = new List<FootStep>();
    }
    
    #region Effect

    public class TriggerEffect
    {
        public string triggerEventName = string.Empty;
        public float triggerDelay = 0;
        public float triggerFreeDelay = 0;
        public string effectGoName = string.Empty;
        public AssetID effectAsset = new AssetID("", "");
        public bool playerAtTarget = false;
        public string referenceNodeHierarchyPath = string.Empty;
        public bool isAttach = false;
        public bool isRotation = false;
        public string triggerStopEvent = string.Empty;
        public string effectBtnName = string.Empty;
    }
    #endregion

    #region Halt

    public class TriggerHalt
    {
        public string haltBtnName = string.Empty;
        public string haltEventName = string.Empty;
        public float haltDelay = 0;
        public float haltContinueTime = 0;
    }

    #endregion

    #region Sound
    public class TriggerSound
    {
        public string soundEventName = string.Empty;
        public float soundDelay = 0;
        public AssetID soundAudioAsset = new AssetID("", "");
        public string soundAudioGoName = string.Empty;
        public bool soundIsMainRole = false;
    }
    #endregion

    #region CameraShakeData
    public class CameraShakeData
    {

        public string CameraShakeBtnName = string.Empty;
        public string eventName = string.Empty;
        public int numberOfShakes = 2;
        public float distance = 0.05f;
        public float speed = 0.50f;
        public float delay = 0.20f;
        public float decay = 0.00f;
    }

    public class Vector3Data
    {
        public float x = 0;
        public float y = 0;
        public float z = 0;
    }
    #endregion
    
    #region CameraFOV
    public class CameraFOV
    {
        public string fovEventName = string.Empty;

        public float fovDelay = 0;

        public float fovFiledOfView = 0;

        public float duration = 0;
    }
    
    #endregion

    #region SceneFade
    public class SceneFade
    {
        public string fadeEventName = string.Empty;

        public float fadeDelay = 0;

        public FadeColor fadeColor;

        public float fadeIn = 0;

        public float fadeHold = 0;

        public float fadeOut = 0;
    }

    public class FadeColor
    {
        public float colorR = 0;

        public float colorG = 0;

        public float colorB = 0;

        public float colorA = 0;
    }
    #endregion

    #region FootStep
    public class FootStep
    {
        public string footStepEventName = string.Empty;

        public float footStepDelay = 0;

        public string footNodeHierarchyPath = string.Empty;

        public Footprint footprint;

        public EffectControl footStepDust;

        public AssetID footAsset;

        public string footAssetGoName = string.Empty;

        public AssetID footAudioAsset;

        public string footAudioName = string.Empty;
    }

    #endregion

    #endregion

    #region ActorBlinker

    public ActorBlinkerData actorBlinker = new ActorBlinkerData();

    public class ActorBlinkerData
    {
        public float blinkFadeIn = 0;

        public float blinkFadeHold = 0;

        public float blinkFadeOut = 0;
    }
    #endregion

    #region TimeLine
    public List<TimeLineData> TimeLineList = new List<TimeLineData>();

    public class TimeLineData
    {
        public string TimeLineEvent = string.Empty;

        public float NormalizedTime = 0;

        public string TimeLineBtnName = string.Empty;
    }
    #endregion

    #region QualityCtrl
    public class QualityCtrlData
    {
        public string GameObjectName = "";
        public int QualityLevel = 0;
    }
    #endregion
    
}
