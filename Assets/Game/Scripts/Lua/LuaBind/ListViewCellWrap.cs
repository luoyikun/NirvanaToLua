//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ListViewCellWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ListViewCell), typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView));
		L.RegFunction("RefreshCellView", RefreshCellView);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("refreshCell", get_refreshCell, set_refreshCell);
		L.RegFunction("RefreshCell", ListViewCell_RefreshCell);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RefreshCellView(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ListViewCell obj = (ListViewCell)ToLua.CheckObject(L, 1, typeof(ListViewCell));
			obj.RefreshCellView();
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
	static int get_refreshCell(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ListViewCell obj = (ListViewCell)o;
			ListViewCell.RefreshCell ret = obj.refreshCell;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index refreshCell on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_refreshCell(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ListViewCell obj = (ListViewCell)o;
			ListViewCell.RefreshCell arg0 = (ListViewCell.RefreshCell)ToLua.CheckDelegate<ListViewCell.RefreshCell>(L, 2);
			obj.refreshCell = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index refreshCell on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ListViewCell_RefreshCell(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);

			if (count == 1)
			{
				Delegate arg1 = DelegateTraits<ListViewCell.RefreshCell>.Create(func);
				ToLua.Push(L, arg1);
			}
			else
			{
				LuaTable self = ToLua.CheckLuaTable(L, 2);
				Delegate arg1 = DelegateTraits<ListViewCell.RefreshCell>.Create(func, self);
				ToLua.Push(L, arg1);
			}
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

