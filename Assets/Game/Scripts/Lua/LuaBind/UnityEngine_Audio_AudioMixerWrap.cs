﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_Audio_AudioMixerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Audio.AudioMixer), typeof(UnityEngine.Object));
		L.RegFunction("FindMatchingGroups", FindMatchingGroups);
		L.RegFunction("FindSnapshot", FindSnapshot);
		L.RegFunction("TransitionToSnapshots", TransitionToSnapshots);
		L.RegFunction("SetFloat", SetFloat);
		L.RegFunction("ClearFloat", ClearFloat);
		L.RegFunction("GetFloat", GetFloat);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("outputAudioMixerGroup", get_outputAudioMixerGroup, set_outputAudioMixerGroup);
		L.RegVar("updateMode", get_updateMode, set_updateMode);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindMatchingGroups(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Audio.AudioMixerGroup[] o = obj.FindMatchingGroups(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindSnapshot(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Audio.AudioMixerSnapshot o = obj.FindSnapshot(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TransitionToSnapshots(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			UnityEngine.Audio.AudioMixerSnapshot[] arg0 = ToLua.CheckObjectArray<UnityEngine.Audio.AudioMixerSnapshot>(L, 2);
			float[] arg1 = ToLua.CheckNumberArray<float>(L, 3);
			float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
			obj.TransitionToSnapshots(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetFloat(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			bool o = obj.SetFloat(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearFloat(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.ClearFloat(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFloat(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)ToLua.CheckObject<UnityEngine.Audio.AudioMixer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			float arg1;
			bool o = obj.GetFloat(arg0, out arg1);
			LuaDLL.lua_pushboolean(L, o);
			LuaDLL.lua_pushnumber(L, arg1);
			return 2;
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
	static int get_outputAudioMixerGroup(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)o;
			UnityEngine.Audio.AudioMixerGroup ret = obj.outputAudioMixerGroup;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index outputAudioMixerGroup on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_updateMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)o;
			UnityEngine.Audio.AudioMixerUpdateMode ret = obj.updateMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index updateMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_outputAudioMixerGroup(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)o;
			UnityEngine.Audio.AudioMixerGroup arg0 = (UnityEngine.Audio.AudioMixerGroup)ToLua.CheckObject<UnityEngine.Audio.AudioMixerGroup>(L, 2);
			obj.outputAudioMixerGroup = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index outputAudioMixerGroup on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_updateMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Audio.AudioMixer obj = (UnityEngine.Audio.AudioMixer)o;
			UnityEngine.Audio.AudioMixerUpdateMode arg0 = (UnityEngine.Audio.AudioMixerUpdateMode)ToLua.CheckObject(L, 2, typeof(UnityEngine.Audio.AudioMixerUpdateMode));
			obj.updateMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index updateMode on a nil value");
		}
	}
}

