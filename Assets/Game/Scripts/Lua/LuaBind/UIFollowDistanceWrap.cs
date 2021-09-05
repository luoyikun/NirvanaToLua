﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UIFollowDistanceWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UIFollowDistance), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("MinDistance", get_MinDistance, set_MinDistance);
		L.RegVar("MaxDistance", get_MaxDistance, set_MaxDistance);
		L.RegVar("TargetTransform", get_TargetTransform, set_TargetTransform);
		L.EndClass();
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
	static int get_MinDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			float ret = obj.MinDistance;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index MinDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MaxDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			float ret = obj.MaxDistance;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index MaxDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TargetTransform(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			UnityEngine.Transform ret = obj.TargetTransform;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TargetTransform on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_MinDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.MinDistance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index MinDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_MaxDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.MaxDistance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index MaxDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_TargetTransform(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIFollowDistance obj = (UIFollowDistance)o;
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			obj.TargetTransform = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TargetTransform on a nil value");
		}
	}
}
