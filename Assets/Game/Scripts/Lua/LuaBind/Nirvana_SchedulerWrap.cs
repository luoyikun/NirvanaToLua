//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Nirvana_SchedulerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Nirvana.Scheduler), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Clear", Clear);
		L.RegFunction("AddFrameListener", AddFrameListener);
		L.RegFunction("RemoveFrameListener", RemoveFrameListener);
		L.RegFunction("RunCoroutine", RunCoroutine);
		L.RegFunction("StopShcCoroutine", StopShcCoroutine);
		L.RegFunction("PostTask", PostTask);
		L.RegFunction("Delay", Delay);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			Nirvana.Scheduler.Clear();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddFrameListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Action arg0 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 1);
			System.Collections.Generic.LinkedListNode<System.Action> o = Nirvana.Scheduler.AddFrameListener(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveFrameListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Collections.Generic.LinkedListNode<System.Action> arg0 = (System.Collections.Generic.LinkedListNode<System.Action>)ToLua.CheckObject(L, 1, typeof(System.Collections.Generic.LinkedListNode<System.Action>));
			Nirvana.Scheduler.RemoveFrameListener(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RunCoroutine(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Collections.IEnumerator arg0 = ToLua.CheckIter(L, 1);
			UnityEngine.Coroutine o = Nirvana.Scheduler.RunCoroutine(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopShcCoroutine(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Coroutine arg0 = (UnityEngine.Coroutine)ToLua.CheckObject(L, 1, typeof(UnityEngine.Coroutine));
			Nirvana.Scheduler.StopShcCoroutine(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PostTask(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Action arg0 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 1);
			Nirvana.Scheduler.PostTask(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Delay(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				System.Action arg0 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 1);
				Nirvana.Scheduler.Delay(arg0);
				return 0;
			}
			else if (count == 2)
			{
				System.Action arg0 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 1);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 2);
				Nirvana.Scheduler.Delay(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: Nirvana.Scheduler.Delay");
			}
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

