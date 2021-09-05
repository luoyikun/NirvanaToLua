﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class CurveMoveWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(CurveMove), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("MoveTo", MoveTo);
		L.RegFunction("Move", Move);
		L.RegFunction("IsMoveing", IsMoveing);
		L.RegFunction("StopMove", StopMove);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MoveTo(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			CurveMove obj = (CurveMove)ToLua.CheckObject<CurveMove>(L, 1);
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			System.Action arg2 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 4);
			obj.MoveTo(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Move(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			CurveMove obj = (CurveMove)ToLua.CheckObject<CurveMove>(L, 1);
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			System.Action arg2 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 4);
			obj.Move(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsMoveing(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			CurveMove obj = (CurveMove)ToLua.CheckObject<CurveMove>(L, 1);
			bool o = obj.IsMoveing();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopMove(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			CurveMove obj = (CurveMove)ToLua.CheckObject<CurveMove>(L, 1);
			obj.StopMove();
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

