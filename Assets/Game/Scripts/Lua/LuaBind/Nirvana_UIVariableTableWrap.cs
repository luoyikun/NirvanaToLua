//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Nirvana_UIVariableTableWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Nirvana.UIVariableTable), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("FindVariable", FindVariable);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("variables", get_variables, set_variables);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindVariable(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Nirvana.UIVariableTable obj = (Nirvana.UIVariableTable)ToLua.CheckObject(L, 1, typeof(Nirvana.UIVariableTable));
			string arg0 = ToLua.CheckString(L, 2);
			Nirvana.UIVariable o = obj.FindVariable(arg0);
			ToLua.PushSealed(L, o);
			return 1;
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
	static int get_variables(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIVariableTable obj = (Nirvana.UIVariableTable)o;
			Nirvana.UIVariable[] ret = obj.variables;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index variables on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_variables(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIVariableTable obj = (Nirvana.UIVariableTable)o;
			Nirvana.UIVariable[] arg0 = ToLua.CheckObjectArray<Nirvana.UIVariable>(L, 2);
			obj.variables = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index variables on a nil value");
		}
	}
}

