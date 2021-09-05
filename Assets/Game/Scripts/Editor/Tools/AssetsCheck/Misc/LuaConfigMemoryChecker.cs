using LuaInterface;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // 检查单个Lua配置的内存和文件大小
    class LuaConfigMemoryChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Lua/config/auto_new"};

        // 每个配置文件件不能超过1M
        private int maxMemKb = 1024;

        override public string GetErrorDesc()
        {
            return string.Format("每个Lua配置的内存占用不能超过{0}MB", maxMemKb / 1024);
        }

        override protected void OnCheck()
        {
            LuaState lua_state = new LuaState();
            lua_state.Start();
            lua_state.OpenLibs(LuaDLL.luaopen_struct);
            LuaLog.OpenLibs(lua_state);

            lua_state.LuaSetTop(0);
            LuaBinder.Bind(lua_state);
            DelegateFactory.Init();

            List<string> files = new List<string>();
            for (int i = 0; i < checkDirs.Length; i++)
            {
                char[] split = checkDirs[i].ToCharArray();
                AssetFileUtil.GetAllFileInDir(checkDirs[i], files, ".lua");
                for (int j = 0; j < files.Count; j++)
                {
                    string path = files[j].Replace('\\', '/');
                    try
                    {
                        CheckItem item = new CheckItem();
                        FileInfo file_info = new FileInfo(path);

                        lua_state.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
                        int mem1 = lua_state.LuaGC(LuaGCOptions.LUA_GCCOUNT);

                        LuaTable lua_table = lua_state.DoFile<LuaTable>(path);
                        lua_table.AddRef();

                        lua_state.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
                        int add_mem = lua_state.LuaGC(LuaGCOptions.LUA_GCCOUNT) - mem1;
                        if (add_mem > maxMemKb)
                        {
                            item.asset = file_info.Name;
                            item.mem = add_mem;
                            this.outputList.Add(item);
                        }

                        lua_table.Dispose();
                    }
                    catch (LuaException exp)
                    {
                        Debug.LogErrorFormat("{0}, {1}", path, exp.Message);
                    }
                }
            }

            lua_state.Dispose();
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public int mem;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                float mem_mb = mem * 1.0f / 1000;
                builder.Append(string.Format("{0}   mem = {1}MB", asset, mem_mb));
                return builder;
            }
        }
    }
}
