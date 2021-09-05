﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ListViewPageScroll2Wrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ListViewPageScroll2), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("JumpToPage", JumpToPage);
		L.RegFunction("JumpToPageImmidate", JumpToPageImmidate);
		L.RegFunction("JumpToPageImmidateWithoutToggle", JumpToPageImmidateWithoutToggle);
		L.RegFunction("GetNowPage", GetNowPage);
		L.RegFunction("SetPageCellNumBer", SetPageCellNumBer);
		L.RegFunction("SetPageCount", SetPageCount);
		L.RegFunction("OnBeginDrag", OnBeginDrag);
		L.RegFunction("OnEndDrag", OnEndDrag);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("JumpToPageEvent", get_JumpToPageEvent, set_JumpToPageEvent);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int JumpToPage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.JumpToPage(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int JumpToPageImmidate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.JumpToPageImmidate(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int JumpToPageImmidateWithoutToggle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.JumpToPageImmidateWithoutToggle(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetNowPage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int o = obj.GetNowPage();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPageCellNumBer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetPageCellNumBer(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPageCount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetPageCount(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnBeginDrag(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			UnityEngine.EventSystems.PointerEventData arg0 = (UnityEngine.EventSystems.PointerEventData)ToLua.CheckObject<UnityEngine.EventSystems.PointerEventData>(L, 2);
			obj.OnBeginDrag(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnEndDrag(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			UnityEngine.EventSystems.PointerEventData arg0 = (UnityEngine.EventSystems.PointerEventData)ToLua.CheckObject<UnityEngine.EventSystems.PointerEventData>(L, 2);
			obj.OnEndDrag(arg0);
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_JumpToPageEvent(IntPtr L)
	{
		ToLua.Push(L, new EventObject(typeof(System.Action)));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_JumpToPageEvent(IntPtr L)
	{
		try
		{
			ListViewPageScroll2 obj = (ListViewPageScroll2)ToLua.CheckObject(L, 1, typeof(ListViewPageScroll2));
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'ListViewPageScroll2.JumpToPageEvent' can only appear on the left hand side of += or -= when used outside of the type 'ListViewPageScroll2'");
			}

			if (arg0.op == EventOp.Add)
			{
				System.Action ev = (System.Action)arg0.func;
				obj.JumpToPageEvent += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				System.Action ev = (System.Action)arg0.func;
				obj.JumpToPageEvent -= ev;
			}

			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
