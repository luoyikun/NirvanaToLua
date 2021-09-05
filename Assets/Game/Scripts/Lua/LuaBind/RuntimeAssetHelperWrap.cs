﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class RuntimeAssetHelperWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("RuntimeAssetHelper");
		L.RegFunction("InsureDirectory", InsureDirectory);
		L.RegFunction("WriteWebRequestData", WriteWebRequestData);
		L.RegFunction("TryWriteWebRequestData", TryWriteWebRequestData);
		L.RegFunction("IntToString", IntToString);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InsureDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			RuntimeAssetHelper.InsureDirectory(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteWebRequestData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			UnityEngine.Networking.UnityWebRequest arg1 = (UnityEngine.Networking.UnityWebRequest)ToLua.CheckObject<UnityEngine.Networking.UnityWebRequest>(L, 2);
			RuntimeAssetHelper.WriteWebRequestData(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryWriteWebRequestData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			UnityEngine.Networking.UnityWebRequest arg1 = (UnityEngine.Networking.UnityWebRequest)ToLua.CheckObject<UnityEngine.Networking.UnityWebRequest>(L, 2);
			bool o = RuntimeAssetHelper.TryWriteWebRequestData(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			string o = RuntimeAssetHelper.IntToString(arg0, arg1);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

