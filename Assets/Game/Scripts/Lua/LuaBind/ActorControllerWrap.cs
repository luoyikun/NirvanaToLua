﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ActorControllerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ActorController), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("EnableEffect", EnableEffect);
		L.RegFunction("EnableHalt", EnableHalt);
		L.RegFunction("EnableCameraShake", EnableCameraShake);
		L.RegFunction("EnableCameraFOV", EnableCameraFOV);
		L.RegFunction("EnableSceneFade", EnableSceneFade);
		L.RegFunction("EnableFootsteps", EnableFootsteps);
		L.RegFunction("StopEffects", StopEffects);
		L.RegFunction("Blink", Blink);
		L.RegFunction("PlayProjectile", PlayProjectile);
		L.RegFunction("PlayHurtShow", PlayHurtShow);
		L.RegFunction("PlayHurt", PlayHurt);
		L.RegFunction("PlayBeHurt", PlayBeHurt);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("beHurtEffecct", get_beHurtEffecct, set_beHurtEffecct);
		L.RegVar("beHurtPosition", get_beHurtPosition, set_beHurtPosition);
		L.RegVar("beHurtAttach", get_beHurtAttach, set_beHurtAttach);
		L.RegVar("Projectiles", get_Projectiles, null);
		L.RegVar("Hurts", get_Hurts, null);
		L.RegVar("Target", get_Target, set_Target);
		L.RegVar("IsMainRole", get_IsMainRole, set_IsMainRole);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableEffect(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableEffect(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableHalt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableHalt(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableCameraShake(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableCameraShake(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableCameraFOV(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableCameraFOV(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableSceneFade(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableSceneFade(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableFootsteps(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableFootsteps(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopEffects(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			obj.StopEffects();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Blink(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			obj.Blink();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayProjectile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Transform arg1 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 3);
			UnityEngine.Transform arg2 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 4);
			System.Action arg3 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 5);
			obj.PlayProjectile(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayHurtShow(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Transform arg1 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 3);
			UnityEngine.Transform arg2 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 4);
			System.Action arg3 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 5);
			obj.PlayHurtShow(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayHurt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<float> arg1 = (System.Action<float>)ToLua.CheckDelegate<System.Action<float>>(L, 3);
			obj.PlayHurt(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayBeHurt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ActorController obj = (ActorController)ToLua.CheckObject(L, 1, typeof(ActorController));
			obj.PlayBeHurt();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_beHurtEffecct(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			Nirvana.AssetID ret = obj.beHurtEffecct;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtEffecct on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_beHurtPosition(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			UnityEngine.Transform ret = obj.beHurtPosition;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtPosition on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_beHurtAttach(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			bool ret = obj.beHurtAttach;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtAttach on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Projectiles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			ActorController.ProjectileData[] ret = obj.Projectiles;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Projectiles on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Hurts(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			ActorController.HurtData[] ret = obj.Hurts;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Hurts on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			UnityEngine.Transform ret = obj.Target;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Target on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsMainRole(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			bool ret = obj.IsMainRole;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index IsMainRole on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_beHurtEffecct(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			Nirvana.AssetID arg0 = StackTraits<Nirvana.AssetID>.Check(L, 2);
			obj.beHurtEffecct = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtEffecct on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_beHurtPosition(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			obj.beHurtPosition = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtPosition on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_beHurtAttach(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.beHurtAttach = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index beHurtAttach on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			obj.Target = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Target on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_IsMainRole(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ActorController obj = (ActorController)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.IsMainRole = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index IsMainRole on a nil value");
		}
	}
}
