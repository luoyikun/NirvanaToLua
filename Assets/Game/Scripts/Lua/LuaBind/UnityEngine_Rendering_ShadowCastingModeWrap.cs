﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_Rendering_ShadowCastingModeWrap
{
	public static void Register(LuaState L)
	{
		L.BeginEnum(typeof(UnityEngine.Rendering.ShadowCastingMode));
		L.RegVar("Off", get_Off, null);
		L.RegVar("On", get_On, null);
		L.RegVar("TwoSided", get_TwoSided, null);
		L.RegVar("ShadowsOnly", get_ShadowsOnly, null);
		L.RegFunction("IntToEnum", IntToEnum);
		L.EndEnum();
		TypeTraits<UnityEngine.Rendering.ShadowCastingMode>.Check = CheckType;
		StackTraits<UnityEngine.Rendering.ShadowCastingMode>.Push = Push;
	}

	static void Push(IntPtr L, UnityEngine.Rendering.ShadowCastingMode arg)
	{
		ToLua.Push(L, arg);
	}

	static bool CheckType(IntPtr L, int pos)
	{
		return TypeChecker.CheckEnumType(typeof(UnityEngine.Rendering.ShadowCastingMode), L, pos);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Off(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.Rendering.ShadowCastingMode.Off);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_On(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.Rendering.ShadowCastingMode.On);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TwoSided(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.Rendering.ShadowCastingMode.TwoSided);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ShadowsOnly(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToEnum(IntPtr L)
	{
		int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
		UnityEngine.Rendering.ShadowCastingMode o = (UnityEngine.Rendering.ShadowCastingMode)arg0;
		ToLua.Push(L, o);
		return 1;
	}
}
