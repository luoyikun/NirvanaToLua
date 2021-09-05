﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Nirvana_InstantiateQueueWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Nirvana.InstantiateQueue), typeof(System.Object));
		L.RegFunction("New", _CreateNirvana_InstantiateQueue);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("Global", get_Global, set_Global);
		L.RegVar("InstantiateCountPerFrame", get_InstantiateCountPerFrame, set_InstantiateCountPerFrame);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateNirvana_InstantiateQueue(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				Nirvana.InstantiateQueue obj = new Nirvana.InstantiateQueue();
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: Nirvana.InstantiateQueue.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Global(IntPtr L)
	{
		try
		{
			ToLua.PushSealed(L, Nirvana.InstantiateQueue.Global);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_InstantiateCountPerFrame(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.InstantiateQueue obj = (Nirvana.InstantiateQueue)o;
			int ret = obj.InstantiateCountPerFrame;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index InstantiateCountPerFrame on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Global(IntPtr L)
	{
		try
		{
			Nirvana.InstantiateQueue arg0 = (Nirvana.InstantiateQueue)ToLua.CheckObject(L, 2, typeof(Nirvana.InstantiateQueue));
			Nirvana.InstantiateQueue.Global = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_InstantiateCountPerFrame(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.InstantiateQueue obj = (Nirvana.InstantiateQueue)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.InstantiateCountPerFrame = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index InstantiateCountPerFrame on a nil value");
		}
	}
}
