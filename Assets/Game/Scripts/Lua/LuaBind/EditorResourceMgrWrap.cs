﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class EditorResourceMgrWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("EditorResourceMgr");
		L.RegFunction("LoadGameObject", LoadGameObject);
		L.RegFunction("LoadObject", LoadObject);
		L.RegFunction("LoadLevelSync", LoadLevelSync);
		L.RegFunction("LoadLevelAsync", LoadLevelAsync);
		L.RegFunction("CacheOrginalInstanceMapping", CacheOrginalInstanceMapping);
		L.RegFunction("SweepOriginalInstanceIdMap", SweepOriginalInstanceIdMap);
		L.RegFunction("GetAssetPath", GetAssetPath);
		L.RegFunction("OutputAssetPathMap", OutputAssetPathMap);
		L.RegFunction("IsCanLoadAssetInGameObj", IsCanLoadAssetInGameObj);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadGameObject(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			UnityEngine.GameObject o = EditorResourceMgr.LoadGameObject(arg0, arg1);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadObject(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			System.Type arg2 = ToLua.CheckMonoType(L, 3);
			UnityEngine.Object o = EditorResourceMgr.LoadObject(arg0, arg1, arg2);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadLevelSync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			UnityEngine.SceneManagement.LoadSceneMode arg2 = (UnityEngine.SceneManagement.LoadSceneMode)ToLua.CheckObject(L, 3, typeof(UnityEngine.SceneManagement.LoadSceneMode));
			bool o = EditorResourceMgr.LoadLevelSync(arg0, arg1, arg2);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadLevelAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			UnityEngine.SceneManagement.LoadSceneMode arg2 = (UnityEngine.SceneManagement.LoadSceneMode)ToLua.CheckObject(L, 3, typeof(UnityEngine.SceneManagement.LoadSceneMode));
			UnityEngine.AsyncOperation o = EditorResourceMgr.LoadLevelAsync(arg0, arg1, arg2);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CacheOrginalInstanceMapping(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 1, typeof(UnityEngine.GameObject));
			UnityEngine.GameObject arg1 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			EditorResourceMgr.CacheOrginalInstanceMapping(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SweepOriginalInstanceIdMap(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			EditorResourceMgr.SweepOriginalInstanceIdMap();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAssetPath(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.CheckObject<UnityEngine.Object>(L, 1);
			string o = EditorResourceMgr.GetAssetPath(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OutputAssetPathMap(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			EditorResourceMgr.OutputAssetPathMap();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsCanLoadAssetInGameObj(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 1, typeof(UnityEngine.GameObject));
			string arg1 = ToLua.CheckString(L, 2);
			string arg2 = ToLua.CheckString(L, 3);
			bool o = EditorResourceMgr.IsCanLoadAssetInGameObj(arg0, arg1, arg2);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
