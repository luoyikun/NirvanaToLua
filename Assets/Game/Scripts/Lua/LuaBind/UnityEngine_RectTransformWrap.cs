﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using DG.Tweening;
using Nirvana;
using LuaInterface;

public class UnityEngine_RectTransformWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.RectTransform), typeof(UnityEngine.Transform));
		L.RegFunction("GetLocalCorners", GetLocalCorners);
		L.RegFunction("GetWorldCorners", GetWorldCorners);
		L.RegFunction("SetInsetAndSizeFromParentEdge", SetInsetAndSizeFromParentEdge);
		L.RegFunction("SetSizeWithCurrentAnchors", SetSizeWithCurrentAnchors);
		L.RegFunction("ForceUpdateRectTransforms", ForceUpdateRectTransforms);
		L.RegFunction("DOJumpAnchorPos", DOJumpAnchorPos);
		L.RegFunction("DOShakeAnchorPos", DOShakeAnchorPos);
		L.RegFunction("DOPunchAnchorPos", DOPunchAnchorPos);
		L.RegFunction("DOSizeDelta", DOSizeDelta);
		L.RegFunction("DOPivotY", DOPivotY);
		L.RegFunction("DOPivotX", DOPivotX);
		L.RegFunction("DOPivot", DOPivot);
		L.RegFunction("DOAnchorMin", DOAnchorMin);
		L.RegFunction("DOAnchorMax", DOAnchorMax);
		L.RegFunction("DOAnchorPos3D", DOAnchorPos3D);
		L.RegFunction("DOAnchorPosY", DOAnchorPosY);
		L.RegFunction("DOAnchorPosX", DOAnchorPosX);
		L.RegFunction("DOAnchorPos", DOAnchorPos);
		L.RegFunction("GetWorldCenterZ", GetWorldCenterZ);
		L.RegFunction("GetWorldCenterY", GetWorldCenterY);
		L.RegFunction("GetWorldCenterX", GetWorldCenterX);
		L.RegFunction("GetWorldCenter", GetWorldCenter);
		L.RegFunction("New", _CreateUnityEngine_RectTransform);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("rect", get_rect, null);
		L.RegVar("anchorMin", get_anchorMin, set_anchorMin);
		L.RegVar("anchorMax", get_anchorMax, set_anchorMax);
		L.RegVar("anchoredPosition3D", get_anchoredPosition3D, set_anchoredPosition3D);
		L.RegVar("anchoredPosition", get_anchoredPosition, set_anchoredPosition);
		L.RegVar("sizeDelta", get_sizeDelta, set_sizeDelta);
		L.RegVar("pivot", get_pivot, set_pivot);
		L.RegVar("offsetMin", get_offsetMin, set_offsetMin);
		L.RegVar("offsetMax", get_offsetMax, set_offsetMax);
		L.RegVar("reapplyDrivenProperties", get_reapplyDrivenProperties, set_reapplyDrivenProperties);
		L.RegFunction("ReapplyDrivenProperties", UnityEngine_RectTransform_ReapplyDrivenProperties);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_RectTransform(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.RectTransform obj = new UnityEngine.RectTransform();
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.RectTransform.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLocalCorners(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
                UnityEngine.Vector3[] arg0 = new UnityEngine.Vector3[4];
                obj.GetLocalCorners(arg0);
                ToLua.Push(L, arg0);
                return 1;
            }
			else if (count == 2)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 2);
				obj.GetLocalCorners(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.GetLocalCorners");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCorners(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
                UnityEngine.Vector3[] arg0 = new UnityEngine.Vector3[4];
                obj.GetWorldCorners(arg0);
                ToLua.Push(L, arg0);
                return 1;
            }
			else if (count == 2)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 2);
				obj.GetWorldCorners(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.GetWorldCorners");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetInsetAndSizeFromParentEdge(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			UnityEngine.RectTransform.Edge arg0 = (UnityEngine.RectTransform.Edge)ToLua.CheckObject(L, 2, typeof(UnityEngine.RectTransform.Edge));
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
			obj.SetInsetAndSizeFromParentEdge(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSizeWithCurrentAnchors(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			UnityEngine.RectTransform.Axis arg0 = (UnityEngine.RectTransform.Axis)ToLua.CheckObject(L, 2, typeof(UnityEngine.RectTransform.Axis));
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			obj.SetSizeWithCurrentAnchors(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ForceUpdateRectTransforms(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			obj.ForceUpdateRectTransforms();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOJumpAnchorPos(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 5)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
				float arg3 = (float)LuaDLL.luaL_checknumber(L, 5);
				DG.Tweening.Sequence o = obj.DOJumpAnchorPos(arg0, arg1, arg2, arg3);
				ToLua.PushSealed(L, o);
				return 1;
			}
			else if (count == 6)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
				float arg3 = (float)LuaDLL.luaL_checknumber(L, 5);
				bool arg4 = LuaDLL.luaL_checkboolean(L, 6);
				DG.Tweening.Sequence o = obj.DOJumpAnchorPos(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushSealed(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOJumpAnchorPos");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOShakeAnchorPos(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes<UnityEngine.Vector2>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes<float>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes<float, int>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes<UnityEngine.Vector2, int>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 5 && TypeChecker.CheckTypes<float, int, float>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 5 && TypeChecker.CheckTypes<UnityEngine.Vector2, int, float>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 6 && TypeChecker.CheckTypes<UnityEngine.Vector2, int, float, bool>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				bool arg4 = LuaDLL.lua_toboolean(L, 6);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 6 && TypeChecker.CheckTypes<float, int, float, bool>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				bool arg4 = LuaDLL.lua_toboolean(L, 6);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 7 && TypeChecker.CheckTypes<UnityEngine.Vector2, int, float, bool, bool>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				bool arg4 = LuaDLL.lua_toboolean(L, 6);
				bool arg5 = LuaDLL.lua_toboolean(L, 7);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3, arg4, arg5);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 7 && TypeChecker.CheckTypes<float, int, float, bool, bool>(L, 3))
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				bool arg4 = LuaDLL.lua_toboolean(L, 6);
				bool arg5 = LuaDLL.lua_toboolean(L, 7);
				DG.Tweening.Tweener o = obj.DOShakeAnchorPos(arg0, arg1, arg2, arg3, arg4, arg5);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOShakeAnchorPos");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOPunchAnchorPos(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOPunchAnchorPos(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
				DG.Tweening.Tweener o = obj.DOPunchAnchorPos(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 5)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
				float arg3 = (float)LuaDLL.luaL_checknumber(L, 5);
				DG.Tweening.Tweener o = obj.DOPunchAnchorPos(arg0, arg1, arg2, arg3);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 6)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
				float arg3 = (float)LuaDLL.luaL_checknumber(L, 5);
				bool arg4 = LuaDLL.luaL_checkboolean(L, 6);
				DG.Tweening.Tweener o = obj.DOPunchAnchorPos(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOPunchAnchorPos");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOSizeDelta(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOSizeDelta(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOSizeDelta(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOSizeDelta");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOPivotY(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			DG.Tweening.Tweener o = obj.DOPivotY(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOPivotX(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			DG.Tweening.Tweener o = obj.DOPivotX(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOPivot(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			DG.Tweening.Tweener o = obj.DOPivot(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorMin(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorMin(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorMin(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorMin");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorMax(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorMax(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorMax(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorMax");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorPos3D(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorPos3D(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorPos3D(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorPos3D");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorPosY(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorPosY(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorPosY(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorPosY");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorPosX(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorPosX(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorPosX(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorPosX");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DOAnchorPos(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				DG.Tweening.Tweener o = obj.DOAnchorPos(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4)
			{
				UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
				UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				DG.Tweening.Tweener o = obj.DOAnchorPos(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.RectTransform.DOAnchorPos");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCenterZ(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			float o = obj.GetWorldCenterZ();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCenterY(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			float o = obj.GetWorldCenterY();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCenterX(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			float o = obj.GetWorldCenterX();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCenter(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)ToLua.CheckObject(L, 1, typeof(UnityEngine.RectTransform));
			UnityEngine.Vector3 o = obj.GetWorldCenter();
			ToLua.Push(L, o);
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
	static int get_rect(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Rect ret = obj.rect;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rect on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_anchorMin(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.anchorMin;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchorMin on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_anchorMax(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.anchorMax;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchorMax on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_anchoredPosition3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector3 ret = obj.anchoredPosition3D;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchoredPosition3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_anchoredPosition(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.anchoredPosition;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchoredPosition on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sizeDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.sizeDelta;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sizeDelta on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pivot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.pivot;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pivot on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_offsetMin(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.offsetMin;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index offsetMin on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_offsetMax(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 ret = obj.offsetMax;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index offsetMax on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_reapplyDrivenProperties(IntPtr L)
	{
		ToLua.Push(L, new EventObject(typeof(UnityEngine.RectTransform.ReapplyDrivenProperties)));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_anchorMin(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.anchorMin = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchorMin on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_anchorMax(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.anchorMax = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchorMax on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_anchoredPosition3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.anchoredPosition3D = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchoredPosition3D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_anchoredPosition(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.anchoredPosition = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index anchoredPosition on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sizeDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.sizeDelta = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sizeDelta on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pivot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.pivot = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pivot on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_offsetMin(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.offsetMin = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index offsetMin on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_offsetMax(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RectTransform obj = (UnityEngine.RectTransform)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.offsetMax = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index offsetMax on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_reapplyDrivenProperties(IntPtr L)
	{
		try
		{
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'UnityEngine.RectTransform.reapplyDrivenProperties' can only appear on the left hand side of += or -= when used outside of the type 'UnityEngine.RectTransform'");
			}

			if (arg0.op == EventOp.Add)
			{
				UnityEngine.RectTransform.ReapplyDrivenProperties ev = (UnityEngine.RectTransform.ReapplyDrivenProperties)arg0.func;
				UnityEngine.RectTransform.reapplyDrivenProperties += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				UnityEngine.RectTransform.ReapplyDrivenProperties ev = (UnityEngine.RectTransform.ReapplyDrivenProperties)arg0.func;
				UnityEngine.RectTransform.reapplyDrivenProperties -= ev;
			}

			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnityEngine_RectTransform_ReapplyDrivenProperties(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);

			if (count == 1)
			{
				Delegate arg1 = DelegateTraits<UnityEngine.RectTransform.ReapplyDrivenProperties>.Create(func);
				ToLua.Push(L, arg1);
			}
			else
			{
				LuaTable self = ToLua.CheckLuaTable(L, 2);
				Delegate arg1 = DelegateTraits<UnityEngine.RectTransform.ReapplyDrivenProperties>.Create(func, self);
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

