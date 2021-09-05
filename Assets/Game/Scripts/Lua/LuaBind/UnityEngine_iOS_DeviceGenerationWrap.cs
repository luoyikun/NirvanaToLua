﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

#if UNITY_IOS
public class UnityEngine_iOS_DeviceGenerationWrap
{
	public static void Register(LuaState L)
	{
		L.BeginEnum(typeof(UnityEngine.iOS.DeviceGeneration));
		L.RegVar("Unknown", get_Unknown, null);
		L.RegVar("iPhone", get_iPhone, null);
		L.RegVar("iPhone3G", get_iPhone3G, null);
		L.RegVar("iPhone3GS", get_iPhone3GS, null);
		L.RegVar("iPodTouch1Gen", get_iPodTouch1Gen, null);
		L.RegVar("iPodTouch2Gen", get_iPodTouch2Gen, null);
		L.RegVar("iPodTouch3Gen", get_iPodTouch3Gen, null);
		L.RegVar("iPad1Gen", get_iPad1Gen, null);
		L.RegVar("iPhone4", get_iPhone4, null);
		L.RegVar("iPodTouch4Gen", get_iPodTouch4Gen, null);
		L.RegVar("iPad2Gen", get_iPad2Gen, null);
		L.RegVar("iPhone4S", get_iPhone4S, null);
		L.RegVar("iPad3Gen", get_iPad3Gen, null);
		L.RegVar("iPhone5", get_iPhone5, null);
		L.RegVar("iPodTouch5Gen", get_iPodTouch5Gen, null);
		L.RegVar("iPadMini1Gen", get_iPadMini1Gen, null);
		L.RegVar("iPad4Gen", get_iPad4Gen, null);
		L.RegVar("iPhone5C", get_iPhone5C, null);
		L.RegVar("iPhone5S", get_iPhone5S, null);
		L.RegVar("iPadAir1", get_iPadAir1, null);
		L.RegVar("iPadMini2Gen", get_iPadMini2Gen, null);
		L.RegVar("iPhone6", get_iPhone6, null);
		L.RegVar("iPhone6Plus", get_iPhone6Plus, null);
		L.RegVar("iPadMini3Gen", get_iPadMini3Gen, null);
		L.RegVar("iPadAir2", get_iPadAir2, null);
		L.RegVar("iPhone6S", get_iPhone6S, null);
		L.RegVar("iPhone6SPlus", get_iPhone6SPlus, null);
		L.RegVar("iPadPro1Gen", get_iPadPro1Gen, null);
		L.RegVar("iPadMini4Gen", get_iPadMini4Gen, null);
		L.RegVar("iPhoneSE1Gen", get_iPhoneSE1Gen, null);
		L.RegVar("iPadPro10Inch1Gen", get_iPadPro10Inch1Gen, null);
		L.RegVar("iPhone7", get_iPhone7, null);
		L.RegVar("iPhone7Plus", get_iPhone7Plus, null);
		L.RegVar("iPodTouch6Gen", get_iPodTouch6Gen, null);
		L.RegVar("iPad5Gen", get_iPad5Gen, null);
		L.RegVar("iPadPro2Gen", get_iPadPro2Gen, null);
		L.RegVar("iPadPro10Inch2Gen", get_iPadPro10Inch2Gen, null);
		L.RegVar("iPhone8", get_iPhone8, null);
		L.RegVar("iPhone8Plus", get_iPhone8Plus, null);
		L.RegVar("iPhoneX", get_iPhoneX, null);
		L.RegVar("iPhoneUnknown", get_iPhoneUnknown, null);
		L.RegVar("iPadUnknown", get_iPadUnknown, null);
		L.RegVar("iPodTouchUnknown", get_iPodTouchUnknown, null);
		L.RegFunction("IntToEnum", IntToEnum);
		L.EndEnum();
		TypeTraits<UnityEngine.iOS.DeviceGeneration>.Check = CheckType;
		StackTraits<UnityEngine.iOS.DeviceGeneration>.Push = Push;
	}

	static void Push(IntPtr L, UnityEngine.iOS.DeviceGeneration arg)
	{
		ToLua.Push(L, arg);
	}

	static bool CheckType(IntPtr L, int pos)
	{
		return TypeChecker.CheckEnumType(typeof(UnityEngine.iOS.DeviceGeneration), L, pos);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Unknown(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.Unknown);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone3G(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone3G);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone3GS(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone3GS);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch2Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch2Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch3Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch3Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPad1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPad1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone4(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone4);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch4Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch4Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPad2Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPad2Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone4S(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone4S);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPad3Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPad3Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone5(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone5);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch5Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch5Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadMini1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadMini1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPad4Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPad4Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone5C(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone5C);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone5S(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone5S);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadAir1(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadAir1);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadMini2Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadMini2Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone6(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone6);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone6Plus(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone6Plus);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadMini3Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadMini3Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadAir2(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadAir2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone6S(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone6S);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone6SPlus(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone6SPlus);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadPro1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadPro1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadMini4Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadMini4Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhoneSE1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhoneSE1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadPro10Inch1Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadPro10Inch1Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone7(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone7);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone7Plus(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone7Plus);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouch6Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouch6Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPad5Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPad5Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadPro2Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadPro2Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadPro10Inch2Gen(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadPro10Inch2Gen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone8(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone8);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhone8Plus(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhone8Plus);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhoneX(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhoneX);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPhoneUnknown(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPhoneUnknown);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPadUnknown(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPadUnknown);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iPodTouchUnknown(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.iOS.DeviceGeneration.iPodTouchUnknown);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToEnum(IntPtr L)
	{
		int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
		UnityEngine.iOS.DeviceGeneration o = (UnityEngine.iOS.DeviceGeneration)arg0;
		ToLua.Push(L, o);
		return 1;
	}
}

#endif