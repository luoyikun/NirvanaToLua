//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Nirvana_AudioPlayerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("AudioPlayer");
		L.RegFunction("Play", Play);
		L.RegFunction("Stop", Stop);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Play(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				Nirvana.AudioPlayer.Play(arg0);
				return 0;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.Action arg1 = (System.Action)ToLua.CheckDelegate<System.Action>(L, 2);
				Nirvana.AudioPlayer.Play(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: Nirvana.AudioPlayer.Play");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Stop(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			Nirvana.AudioPlayer.Stop();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

