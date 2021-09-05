//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using LuaInterface;

#if UNITY_EDITOR

/// <summary>
/// The config manager used to load config in lua file.
/// </summary>
public sealed class ConfigManager
{
    private static ConfigManager instance;
    private LuaState luaState;
    private LuaTable monsterConfig;
    private LuaTable npcConfig;
    private LuaTable gatherConfig;

    private ConfigManager()
    {
        // Create the lua resource loader.
        new LuaResLoader();

        // Initialize the lua virtual machine.
        this.luaState = new LuaState();
        this.luaState.Start();
        this.luaState.OpenLibs(LuaDLL.luaopen_struct);
        LuaBinder.Bind(this.luaState);

        // Load config file.
        this.luaState.DoString("monster_cfg = require(\"config/auto_new/monster_auto\")");
        this.luaState.DoString("npc_cfg = require(\"config/auto_new/npc_auto\")");
        this.luaState.DoString("gather_cfg = require(\"config/auto_new/gather_auto\")");
        this.monsterConfig = this.luaState.GetTable("monster_cfg.monster_list");
        this.npcConfig = this.luaState.GetTable("npc_cfg.npc_list");
        this.gatherConfig = this.luaState.GetTable("gather_cfg.gather_list");
    }

    /// <summary>
    /// Gets the singleton instance.
    /// </summary>
    public static ConfigManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new ConfigManager();
            }

            return instance;
        }
    }

    /// <summary>
    /// Gets the monster resource ID.
    /// </summary>
    public int GetMonsterResID(int id)
    {
        var config = (LuaTable)this.monsterConfig[id];
        if (config != null)
        {
            var value = config["resid"];
            if (value != null)
            {
                return (int)(double)value;
            }

            return -1;
        }
        else
        {
            return -1;
        }
    }

    /// <summary>
    /// Gets the NPC resource ID.
    /// </summary>
    public int GetNPCResID(int id)
    {
        var config = (LuaTable)this.npcConfig[id];
        if (config != null)
        {
            var value = config["resid"];
            if (value != null)
            {
                return (int)(double)value;
            }

            return -1;
        }
        else
        {
            return -1;
        }
    }

    /// <summary>
    /// Gets the gather resource ID.
    /// </summary>
    public int GetGatherResID(int id)
    {
        var config = (LuaTable)this.gatherConfig[id];
        if (config != null)
        {
            var value = config["resid"];
            if (value != null)
            {
                return (int)(double)value;
            }

            return -1;
        }
        else
        {
            return -1;
        }
    }
}

#endif
