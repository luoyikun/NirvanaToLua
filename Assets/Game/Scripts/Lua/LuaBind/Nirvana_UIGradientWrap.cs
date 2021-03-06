//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Nirvana_UIGradientWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Nirvana.UIGradient), typeof(UnityEngine.UI.BaseMeshEffect));
		L.RegFunction("ModifyMesh", ModifyMesh);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("GradientMode", get_GradientMode, set_GradientMode);
		L.RegVar("GradientDirection", get_GradientDirection, set_GradientDirection);
		L.RegVar("ColorMode", get_ColorMode, set_ColorMode);
		L.RegVar("Color1", get_Color1, set_Color1);
		L.RegVar("Color2", get_Color2, set_Color2);
		L.RegVar("UseGraphicAlpha", get_UseGraphicAlpha, set_UseGraphicAlpha);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ModifyMesh(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<UnityEngine.Mesh>(L, 2))
			{
				Nirvana.UIGradient obj = (Nirvana.UIGradient)ToLua.CheckObject(L, 1, typeof(Nirvana.UIGradient));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.ToObject(L, 2);
				obj.ModifyMesh(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<UnityEngine.UI.VertexHelper>(L, 2))
			{
				Nirvana.UIGradient obj = (Nirvana.UIGradient)ToLua.CheckObject(L, 1, typeof(Nirvana.UIGradient));
				UnityEngine.UI.VertexHelper arg0 = (UnityEngine.UI.VertexHelper)ToLua.ToObject(L, 2);
				obj.ModifyMesh(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: Nirvana.UIGradient.ModifyMesh");
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_GradientMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.GradientModeEnum ret = obj.GradientMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index GradientMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_GradientDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.GradientDirectionEnum ret = obj.GradientDirection;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index GradientDirection on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ColorMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.ColorModeEnum ret = obj.ColorMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ColorMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Color1(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			UnityEngine.Color ret = obj.Color1;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Color1 on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Color2(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			UnityEngine.Color ret = obj.Color2;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Color2 on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_UseGraphicAlpha(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			bool ret = obj.UseGraphicAlpha;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index UseGraphicAlpha on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_GradientMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.GradientModeEnum arg0 = (Nirvana.UIGradient.GradientModeEnum)ToLua.CheckObject(L, 2, typeof(Nirvana.UIGradient.GradientModeEnum));
			obj.GradientMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index GradientMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_GradientDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.GradientDirectionEnum arg0 = (Nirvana.UIGradient.GradientDirectionEnum)ToLua.CheckObject(L, 2, typeof(Nirvana.UIGradient.GradientDirectionEnum));
			obj.GradientDirection = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index GradientDirection on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ColorMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			Nirvana.UIGradient.ColorModeEnum arg0 = (Nirvana.UIGradient.ColorModeEnum)ToLua.CheckObject(L, 2, typeof(Nirvana.UIGradient.ColorModeEnum));
			obj.ColorMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ColorMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Color1(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.Color1 = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Color1 on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Color2(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.Color2 = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Color2 on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_UseGraphicAlpha(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Nirvana.UIGradient obj = (Nirvana.UIGradient)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.UseGraphicAlpha = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index UseGraphicAlpha on a nil value");
		}
	}
}

