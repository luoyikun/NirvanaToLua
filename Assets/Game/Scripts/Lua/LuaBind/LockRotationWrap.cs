﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LockRotationWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LockRotation), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("SetParentTransform", SetParentTransform);
		L.RegFunction("SetOffY", SetOffY);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetParentTransform(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LockRotation obj = (LockRotation)ToLua.CheckObject<LockRotation>(L, 1);
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			obj.SetParentTransform(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetOffY(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LockRotation obj = (LockRotation)ToLua.CheckObject<LockRotation>(L, 1);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.SetOffY(arg0);
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
}
