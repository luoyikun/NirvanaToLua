﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaUInt64Wrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaUInt64), typeof(System.Object));
		L.RegFunction("Make", Make);
		L.RegFunction("FromString", FromString);
		L.RegFunction("And", And);
		L.RegFunction("Or", Or);
		L.RegFunction("Xor", Xor);
		L.RegFunction("FromDouble", FromDouble);
		L.RegFunction("ToDouble", ToDouble);
		L.RegFunction("ToString", ToString);
		L.RegFunction("UInt64ToBytes", UInt64ToBytes);
		L.RegFunction("BytesToUInt64", BytesToUInt64);
		L.RegFunction("LongLongToLuaNumber", LongLongToLuaNumber);
		L.RegFunction("New", _CreateLuaUInt64);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaUInt64(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				LuaUInt64 obj = new LuaUInt64();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaUInt64.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Make(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 1);
			uint arg1 = (uint)LuaDLL.luaL_checknumber(L, 2);
			byte[] o = LuaUInt64.Make(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			byte[] o = LuaUInt64.FromString(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int And(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
			byte[] arg1 = ToLua.CheckByteBuffer(L, 2);
			byte[] o = LuaUInt64.And(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Or(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
			byte[] arg1 = ToLua.CheckByteBuffer(L, 2);
			byte[] o = LuaUInt64.Or(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Xor(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
			byte[] arg1 = ToLua.CheckByteBuffer(L, 2);
			byte[] o = LuaUInt64.Xor(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromDouble(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			byte[] o = LuaUInt64.FromDouble(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToDouble(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
			double o = LuaUInt64.ToDouble(arg0);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes<LuaUInt64>(L, 1))
			{
				LuaUInt64 obj = (LuaUInt64)ToLua.ToObject(L, 1);
				string o = obj.ToString();
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 1 && TypeChecker.CheckTypes<byte[]>(L, 1))
			{
				byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
				string o = LuaUInt64.ToString(arg0);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaUInt64.ToString");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UInt64ToBytes(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ulong arg0 = LuaDLL.tolua_checkuint64(L, 1);
			byte[] o = LuaUInt64.UInt64ToBytes(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BytesToUInt64(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			byte[] arg0 = ToLua.CheckByteBuffer(L, 1);
			ulong o = LuaUInt64.BytesToUInt64(arg0);
			LuaDLL.tolua_pushuint64(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LongLongToLuaNumber(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 1);
			uint arg1 = (uint)LuaDLL.luaL_checknumber(L, 2);
			double o = LuaUInt64.LongLongToLuaNumber(arg0, arg1);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

