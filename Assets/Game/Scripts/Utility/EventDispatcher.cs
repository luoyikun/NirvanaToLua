using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using Nirvana;

public class EventDispatcher : MonoBehaviour
{
    public static EventDispatcher Instance;

    private List<Game.GameObjectAttach> enabledGameObjAttach = new List<Game.GameObjectAttach>();
    private List<Game.GameObjectAttach> disabledGameObjAttach = new List<Game.GameObjectAttach>();
    private List<int> destroyedGameObjAttach = new List<int>();

    private List<Game.LoadRawImage> enabledLoadRawImage = new List<Game.LoadRawImage>();
    private List<Game.LoadRawImage> disabledLoadRawImage = new List<Game.LoadRawImage>();
    private List<int> destroyedLoadRawImage = new List<int>();

    public LuaFunction EnableGameObjAttachFunc
    {
        get; set;
    }

    public LuaFunction DisableGameObjAttachFunc
    {
        get; set;
    }

    public LuaFunction DestroyGameObjAttachFunc
    {
        get; set;
    }

    public LuaFunction EnableLoadRawImageFunc
    {
        get; set;
    }

    public LuaFunction DisableLoadRawImageFunc
    {
        get; set;
    }

    public LuaFunction DestroyLoadRawImageFunc
    {
        get; set;
    }

    public LuaFunction ProjectileSingleEffectFunc
    {
        get; set;
    }

    public LuaFunction UIMouseClickEffectFunc
    {
        get; set;
    }    

    private void Awake()
    {
        Instance = this;
    }

    private void OnDestroy()
    {
        Instance = null;
    }

    private void Update()
    {
        if (disabledGameObjAttach.Count > 0 && DisableGameObjAttachFunc != null)
        {
            DisableGameObjAttachFunc.Call(disabledGameObjAttach);
            disabledGameObjAttach.Clear();
        }

        if (enabledGameObjAttach.Count > 0 && EnableGameObjAttachFunc != null)
        {
            EnableGameObjAttachFunc.Call(enabledGameObjAttach);
            enabledGameObjAttach.Clear();
        }

        if (destroyedGameObjAttach.Count > 0 && DestroyGameObjAttachFunc != null)
        {
            DestroyGameObjAttachFunc.Call(destroyedGameObjAttach);
            destroyedGameObjAttach.Clear();
        }

        if (disabledLoadRawImage.Count > 0 && DisableLoadRawImageFunc != null)
        {
            DisableLoadRawImageFunc.Call(disabledLoadRawImage);
            disabledLoadRawImage.Clear();
        }

        if (enabledLoadRawImage.Count > 0 && EnableLoadRawImageFunc != null)
        {
            EnableLoadRawImageFunc.Call(enabledLoadRawImage);
            enabledLoadRawImage.Clear();
        }

        if (destroyedLoadRawImage.Count > 0 && DestroyLoadRawImageFunc != null)
        {
            DestroyLoadRawImageFunc.Call(destroyedLoadRawImage);
            destroyedLoadRawImage.Clear();
        }
    }

    public void OnGameObjAttachEnable(Game.GameObjectAttach gameObjAttach)
    {
        enabledGameObjAttach.Add(gameObjAttach);
    }

    public void OnGameObjAttachDisable(Game.GameObjectAttach gameObjAttach)
    {
        disabledGameObjAttach.Add(gameObjAttach);
    }

    public void OnGameObjAttachDestroyed(Game.GameObjectAttach gameObjAttach)
    {
        destroyedGameObjAttach.Add(gameObjAttach.GetInstanceID());
    }

    public void OnLoadRawImageEnable(Game.LoadRawImage loadRawImage)
    {
        enabledLoadRawImage.Add(loadRawImage);
    }

    public void OnLoadRawImageDisable(Game.LoadRawImage loadRawImage)
    {
        disabledLoadRawImage.Add(loadRawImage);
    }

    public void OnLoadRawImageDestroy(Game.LoadRawImage loadRawImage)
    {
        destroyedLoadRawImage.Add(loadRawImage.GetInstanceID());
    }

    public void OnProjectileSingleEffect(EffectControl hitEffect, Vector3 position, Quaternion rotation, bool hit_effect_with_rotation, Vector3 source_scale, int layer)
    {
        ProjectileSingleEffectFunc.Call(hitEffect, position, rotation, hit_effect_with_rotation, source_scale, layer);
    }

    public void OnUIMouseClickEffect(GameObject effectInstance, GameObject[] effects, Canvas canvas, Transform mouse_click_transform)
    {
        UIMouseClickEffectFunc.Call(effectInstance, effects, canvas, mouse_click_transform);
    }    
}
