//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;
using Nirvana;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

/// <summary>
/// The root of this scene, for logic data.
/// </summary>
[RequireComponent(typeof(SceneGridView))]
[ExecuteInEditMode]
public sealed class SceneLogic : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The ID of this scene.")]
    private int sceneID;

    [SerializeField]
    [Tooltip("The name of this scene.")]
    private string sceneName;

    [SerializeField]
    [Tooltip("The level limit to enter this level.")]
    private int levelLimit;

    [SerializeField]
    private bool isTax;

    [SerializeField]
    [Tooltip("Whether this scene is forbidden player kill player.")]
    private bool isForbidPK;

    [SerializeField]
    [Tooltip("The special logic type.")]
    [EnumLabel("Special Logic Type")]
    private SpecialLogicType specialLogicType;

    [SerializeField]
    [Tooltip("The scene timeout, used for instance.")]
    private int sceneTimeout;

    [SerializeField]
    [Tooltip("Whether kick out the players when timeout.")]
    private bool isTimeoutKick;

    [SerializeField]
    [Tooltip("The scene ID of town.")]
    private int townSceneID;

    [SerializeField]
    [Tooltip("The scene x of town.")]
    private int townSceneX;

    [SerializeField]
    [Tooltip("The scene y of town.")]
    private int townSceneY;

    [SerializeField]
    [Tooltip("Whether to skip loading.")]
    private bool skipLoading = false;

	[SerializeField]
	[Tooltip("显示天气效果")]
	private bool showWeather = false;
    /// <summary>
    /// The scene specify type.
    /// </summary>
    public enum SpecialLogicType
    {
        [EnumLabel("0:普通场景")]
        Common = 0,

        [EnumLabel("1:军团驻地")]
        GuildStation = 1,

        [EnumLabel("2:诛邪战场")]
        ZhuXie = 2,

        [EnumLabel("3:铜钱副本")]
        CoinFb = 3,

        [EnumLabel("4:经验副本")]
        ExpFb = 4,

        [EnumLabel("5:三界战场")]
        QunXianLuanDou = 5,

        [EnumLabel("6:塔防")]
        TowerDefend = 6,

        [EnumLabel("7:阶段副本")]
        PhaseFb = 7,

        [EnumLabel("8:攻城战")]
        GongChengZhan = 8,

        [EnumLabel("9:仙盟战")]
        XianMengzhan = 9,

        [EnumLabel("10:阵营驻地")]
        CampStation = 10,

        [EnumLabel("11:婚宴副本")]
        HunYanFb = 11,

        [EnumLabel("12:神兽禁地(全民boss)")]
        NationalBoss = 12,

        [EnumLabel("13:挑战副本 （爬塔）")]
        ChallengeFB = 13,

        [EnumLabel("14:仙盟神兽")]
        GuildMonster = 14,

        [EnumLabel("15:1v1")]
        Field1v1 = 15,

        [EnumLabel("16:剧情副本")]
        StoryFB = 16,

        [EnumLabel("17:多人副本")]
        TeamFB = 17,

        [EnumLabel("18:情缘副本")]
        QingYuanFB = 18,

        [EnumLabel("19:战神殿副本")]
        ZhanShenDianFB = 19,

        [EnumLabel("20:神魔之隙副本")]
        ShenMoZhiXiFB = 20,

        [EnumLabel("21:一战到底")]
        ChaosWar = 21,

        [EnumLabel("22:跨服帮派战")]
        Cross_Guildbattle = 22,

        [EnumLabel("23:仙盟秘境")]
        GuildMiJingFB = 23,

        [EnumLabel("24:五行打宝")]
        WuXingFB = 24,

        [EnumLabel("25:闭关之境")]
        TransferProfTask = 25,

        [EnumLabel("26:迷宫仙府")]
        MiGongXianFu = 26,

        [EnumLabel("27:无双副本")]
        Fb_Wushuang = 27,

        [EnumLabel("28:跨服荣誉殿堂")]
        Kf_Honorhalls = 28,

        [EnumLabel("29:跨服1v1")]
        Kf_OneVOne = 29,

        [EnumLabel("30:跨服3v3")]
        Kf_PVP = 30,

        [EnumLabel("32:仙盟Boss")]
        GuildBoss = 32,

        [EnumLabel("33:妖兽广场")]
        YaoShouPlaza = 33,

        [EnumLabel("34:锁妖塔")]
        SuoYaoTa = 34,

        [EnumLabel("35:水晶")]
        ShuiJing = 35,

        [EnumLabel("36:钟馗捉鬼")]
        ZhongKui = 36,

        [EnumLabel("37:师门高级夺宝")]
        CampGaojiDuobao = 37,

        [EnumLabel("38:跨服团战")]
        Kf_Teambattle = 38,

        [EnumLabel("39:跨服牧场")]
        FarmHunting = 39,

        [EnumLabel("40:VIP副本")]
        VipFB = 40,

        [EnumLabel("41:公会争霸")]
        GuildBattle = 41,

        [EnumLabel("42:答题副本")]
        DatiFb = 42,

        [EnumLabel("43:天降财宝")]
        Kf_TianJiangCaiBao = 43,

        [EnumLabel("44:跨服BOSS")]
        Kf_Boss = 44,

        [EnumLabel("45:温泉场景")]
        HotSpring = 45,

        [EnumLabel("46:王陵探险")]
        WangLingExplore = 46,

        [EnumLabel("47:跨服组队")]
        CrossTeamFB = 47,

        [EnumLabel("48:领土战")]
        TerritoryWar = 48,

        [EnumLabel("50:功能开启副本-坐骑")]
        FunOpenMountFB = 50,

        [EnumLabel("51:功能开启副本-羽翼")]
        FunOpenWingFB = 51,

        [EnumLabel("52:功能开启副本-精灵")]
        FunOpenJingLingFB = 52,

        [EnumLabel("53:跨服水晶幻境")]
        CrossCrystal = 53,

        [EnumLabel("54:引导副本")]
        GuideFb = 54,

        [EnumLabel("55:挂机塔")]
        RuneTower = 55,

        [EnumLabel("56:组队装备副本")]
        teamequipfb = 56,

        [EnumLabel("57:大富豪")]
        DaFuHao = 57,

        [EnumLabel("58:支线副本")]
        SCENE_TYPE_BRANCH_FB = 58,

        [EnumLabel("59:星座遗迹")]
        XingZuoYiJi = 59,

        [EnumLabel("60:推图副本")]
        TuiTuFb = 60,

        [EnumLabel("61:角斗场")]
        Fighting = 61,

        [EnumLabel("62:情缘圣地")]
        QingYuanShengDi = 62,

        [EnumLabel("63:勇士炼境")]
        Yongshilianjing = 63,

        [EnumLabel("64:武器材料副本")]
        WeaponMaterialsfb = 64,

        [EnumLabel("65:月黑风高 (珍宝秘境)")]
        zhenbaomijing = 65,

        [EnumLabel("66:宝宝BOSS")]
        babyBoss = 66,

        [EnumLabel("67:上古BOSS")]
        shangguboss = 67,

        [EnumLabel("68:防具材料副本")]
        ArmorDefensefb = 68,

        [EnumLabel("69:塔防副本")]
        Defensefb = 69,

        [EnumLabel("70:跨服钓鱼")]
        fishing = 70,

        [EnumLabel("71:跨服夜战皇城")]
        SCENE_TYPE_NIGHT_FIGHT_FB = 71,

        [EnumLabel("72:乱斗战场")]
        SCENE_TYPE_MESS_BATTLE_FB = 72,

        [EnumLabel("73:个人BOSS")]
        Personalboss = 73,

        [EnumLabel("74:仙盟答题")]
        SCENE_TYPE_GUILD_QUESTION = 74,

        [EnumLabel("75:转职心魔副本")]
        ZhuanZhiFb = 75,

        [EnumLabel("76:组队守护副本")]
        TeamDefensefb = 76,

        [EnumLabel("77:灵鲲之战")]
        SCENE_TYPE_CROSS_LIEKUN_FB = 77,

        [EnumLabel("78:组队爬塔副本")]
        TeamEquipfb = 78,

        [EnumLabel("79:吃鸡盛宴")]
        SCENE_TYPE_HOLIDAY_GUARD_FB = 79,

        [EnumLabel("80:跨服秘藏boss")]
        SCENE_TYPE_CROSS_MIZANG_BOSS = 80,

        [EnumLabel("81:跨服幽冥boss")]
        SCENE_TYPE_CROSS_YOUMING_BOSS = 81,

        [EnumLabel("82:神魔boss")]
        SCENE_TYPE_GODMAGIC_BOSS = 82,

        [EnumLabel("83:礼物收割")]
        SCENE_TYPE_GIFT_HARVEST = 83,

        [EnumLabel("84:跨服边境")]
        SCENE_TYPE_CROSS_BIANJINGZHIDI = 84,

        [EnumLabel("85:跨服论剑")]
        SCENE_TYPE_CROSS_LUNJIAN = 85,

        [EnumLabel("86:水晶护送")]
        SCENE_TYPE_CRYSTAL_ESCORT = 86,
        
        [EnumLabel("87:塔防测试审核")]
        SCENE_TYPE_TOWERDEFEND_TEST= 87,
    }

    /// <summary>
    /// Gets the scene ID.
    /// </summary>
    public int SceneID
    {
        get { return this.sceneID; }
    }

    /// <summary>
    /// Save this map data into lua file.
    /// </summary>
    public bool SaveSceneLua(string path, bool compress)
    {
        var gridView = this.GetComponent<SceneGridView>();
        if (gridView == null)
        {
            Debug.LogError("Can not find the SceneGridView component.");
            return false;
        }

        // 获取当前场景的名字和assetbundle.
        var scene = EditorSceneManager.GetActiveScene();
        if (null == scene || scene.name == string.Empty || scene.name == "main")
        {
            EditorUtility.DisplayDialog("生成失败", "请在对应场景下点生成，不要在main下", "确定");
            return false;
        }

        var bundleName = AssetImporter.GetAtPath(scene.path).assetBundleName;
        if (string.IsNullOrEmpty(bundleName))
        {
            EditorUtility.DisplayDialog("生成失败", "AssetBundleName没有设置", "确定");
            return false;
        }
        var assetName = Path.GetFileNameWithoutExtension(scene.path);
        if (string.IsNullOrEmpty(assetName))
        {
            EditorUtility.DisplayDialog("生成失败", "invalid assetName", "确定");
            return false;
        }
        // 组织Lua源文件.
        string format =
@"return {{
	id = {0},
	name = ""{1}"",
	scene_type = {2},
	bundle_name = ""{3}"",
	asset_name = ""{4}"",
	width = {5},
	height = {6},
	origin_x = {7},
	origin_y = {8},
	levellimit = {9},
    is_forbid_pk = {10},
    skip_loading = {11},
	show_weather = {12},
    scenex = {13},
    sceney = {14},
	npcs = {{{15}
	}},
	monsters = {{{16}
	}},
	doors = {{{17}
	}},
    gathers = {{{18}
	}},
    jumppoints = {{{19}
    }},
    fences = {{{20}
	}},
    effects = {{{21}
	}},
    mask = ""{22}"",
}}";

        var npcs = this.GetSceneNPCLua();
        var monsters = this.GetSceneMonsterLua();
        var doors = this.GetSceneDoorLua();
        var gathers = this.GetSceneGatherLua();
        var jumppoint = this.GetSceneJumppointLua();
        var fences = this.GetSceneFencesLua();
        var effects = this.GetSceneEffectLua();
        var mask = this.GetMapEncodedMask(gridView, compress);
        var sourceText = string.Format(
            format,
            this.sceneID,
            this.sceneName,
            (int)this.specialLogicType,
            bundleName,
            assetName,
            gridView.Row,
            gridView.Column,
            this.transform.position.x,
            this.transform.position.z,
            this.levelLimit,
            this.isForbidPK ? "1" : "0",
            this.skipLoading ? "1" : "0",
			this.showWeather ? "1" : "0",
            this.townSceneX,
            this.townSceneY,
            npcs,
            monsters,
            doors,
            gathers,
            jumppoint,
            fences,
            effects,
            mask);

        var fileStream = new FileStream(path, FileMode.Create);
        var writer = new StreamWriter(fileStream);
        writer.Write(sourceText);
        writer.Close();
        fileStream.Close();

        return true;
    }

    /// <summary>
    /// Save this map data into xml file.
    /// </summary>
    public void SaveMapXML(string path)
    {
        var gridView = this.GetComponent<SceneGridView>();
        if (gridView == null)
        {
            Debug.LogError("Can not find the SceneGridView component.");
            return;
        }

        var setting = new XmlWriterSettings();

        setting.Indent = true;
        setting.IndentChars = "\t";
        setting.NewLineChars = "\n";
        setting.NewLineHandling = NewLineHandling.Replace;

        using (var writer = XmlWriter.Create(path, setting))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("scene");

            writer.WriteElementString("id", this.sceneID.ToString());
            writer.WriteElementString("width", gridView.Row.ToString());
            writer.WriteElementString("height", gridView.Column.ToString());
            writer.WriteElementString("mask", this.GetMapMaskShrinked(gridView));

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    /// <summary>
    /// Save this scene data into xml file.
    /// </summary>
    public void SaveSceneXML(string path)
    {
        var setting = new XmlWriterSettings();

        setting.Indent = true;
        setting.IndentChars = "\t";
        setting.NewLineChars = "\n";
        setting.NewLineHandling = NewLineHandling.Replace;

        using (var writer = XmlWriter.Create(path, setting))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("scene");

            writer.WriteElementString("id", this.sceneID.ToString());
            writer.WriteElementString("name", this.sceneName);
            writer.WriteElementString("mapid", this.sceneID.ToString());

            writer.WriteElementString("levellimit", this.levelLimit.ToString());
            writer.WriteElementString("istax", this.isTax ? "1" : "0");
            writer.WriteElementString("is_forbid_pk", this.isForbidPK ? "1" : "0");
            writer.WriteElementString("speciallogic_type", ((int)this.specialLogicType).ToString());
            writer.WriteElementString("scene_timeout", this.sceneTimeout.ToString());
            writer.WriteElementString("is_timeout_kick", this.isTimeoutKick ? "1" : "0");

            writer.WriteStartElement("townpoint");
            writer.WriteElementString("sceneid", this.townSceneID.ToString());
            writer.WriteElementString("scenex", this.townSceneX.ToString());
            writer.WriteElementString("sceney", this.townSceneY.ToString());
            writer.WriteEndElement();

            writer.WriteStartElement("triggerareas");
            writer.WriteEndElement();

            writer.WriteStartElement("triggers");
            writer.WriteEndElement();

            this.SaveNPCs(writer);
            this.SaveMonsterPoints(writer);
            this.SaveDoorsPoints(writer);
            this.SaveGatherPointsPoints(writer);

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    /// <summary>
    /// Save this scene manager into xml file.
    /// </summary>
    public void SaveSceneManagerXML(string path)
    {
        var setting = new XmlWriterSettings();

        setting.Indent = true;
        setting.IndentChars = "\t";
        setting.NewLineChars = "\n";
        setting.NewLineHandling = NewLineHandling.Replace;

        var dir = Path.GetDirectoryName(path);
        var mapDir = Path.Combine(dir, "map");
        var sceneDir = Path.Combine(dir, "scene");
        var mapFiles = Directory.GetFiles(
            mapDir, "*.xml", SearchOption.TopDirectoryOnly);
        var sceneFiles = Directory.GetFiles(
            sceneDir, "*.xml", SearchOption.TopDirectoryOnly);

        var mapNameTable = new HashSet<string>();
        foreach (var file in mapFiles)
        {
            mapNameTable.Add(Path.GetFileName(file));
        }

        var sceneNameTable = new HashSet<string>();
        foreach (var file in sceneFiles)
        {
            sceneNameTable.Add(Path.GetFileName(file));
        }

        using (var writer = XmlWriter.Create(path, setting))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("scenemanager");

            writer.WriteStartElement("maps");
            foreach (var mapFile in mapFiles)
            {
                var fileName = Path.GetFileName(mapFile);
                if (!sceneNameTable.Contains(fileName))
                {
                    Debug.LogWarningFormat(
                        "The map file: {0} is not existed in scene files.",
                        fileName);
                    continue;
                }

                var uri1 = new Uri(mapFile);
                var uri2 = new Uri(dir + "/");
                var relativePath = uri2.MakeRelativeUri(uri1).OriginalString;

                writer.WriteStartElement("map");
                writer.WriteElementString("path", relativePath);
                writer.WriteEndElement();
            }

            writer.WriteEndElement();

            writer.WriteStartElement("scenes");
            foreach (var sceneFile in sceneFiles)
            {
                var fileName = Path.GetFileName(sceneFile);
                if (!mapNameTable.Contains(fileName))
                {
                    Debug.LogWarningFormat(
                        "The scene file: {0} is not existed in map files.",
                        fileName);
                    continue;
                }

                var sceneDoc = new XmlDocument();
                sceneDoc.Load(sceneFile);

                var sceneNode = sceneDoc.SelectSingleNode("scene");

                var nameNode = sceneNode.SelectSingleNode("name");
                var sceneName = nameNode.InnerText;

                var typeNode = sceneNode.SelectSingleNode("speciallogic_type");
                var sceneType = typeNode.InnerText;

                var uri1 = new Uri(sceneFile);
                var uri2 = new Uri(dir + "/");
                var relativePath = uri2.MakeRelativeUri(uri1).OriginalString;

                writer.WriteStartElement("scene");
                writer.WriteElementString("name", sceneName);
                writer.WriteElementString("path", relativePath);
                writer.WriteElementString("scene_type", sceneType);
                writer.WriteElementString("game_index", "0");
                writer.WriteEndElement();
            }

            writer.WriteEndElement();

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
    }

    public void SaveConfigMapLua(string path, string dirpath)
    {
        var gridView = this.GetComponent<SceneGridView>();
        if (gridView == null)
        {
            Debug.LogError("Can not find the SceneGridView component.");
            return;
        }

        var dir = Path.GetDirectoryName(dirpath);
        var sceneDir = Path.Combine(dir, "scene");
        var sceneFiles = Directory.GetFiles(
            sceneDir, "*.xml", SearchOption.TopDirectoryOnly);

        var sceneNameTable = new HashSet<string>();
        foreach (var file in sceneFiles)
        {
            sceneNameTable.Add(Path.GetFileName(file));
        }

        var sceneListBuilder = new StringBuilder();

        foreach (var sceneFile in sceneFiles)
        {
            var sceneDoc = new XmlDocument();
            sceneDoc.Load(sceneFile);

            var sceneNode = sceneDoc.SelectSingleNode("scene");

            var idNode = sceneNode.SelectSingleNode("id");
            var sceneId = idNode.InnerText;

            var nameNode = sceneNode.SelectSingleNode("name");
            var sceneName = nameNode.InnerText;

            var typeNode = sceneNode.SelectSingleNode("speciallogic_type");
            var sceneType = typeNode.InnerText;

            var listLua = string.Format(
               "\n\t[{0}] = {{id = {1}, resid = {2}, sceneType = {3}, res_x = {4}, res_y = {5}, name = \"{6}\"}},",
               sceneId,
               sceneId,
               sceneId,
               sceneType,
               0,
               0,
               sceneName);
            sceneListBuilder.Append(listLua);
        }

        var sceneListString = sceneListBuilder.ToString();

        var sourceText = string.Format("Config_scenelist = {{{0}}}", sceneListString);

        var fileStream = new FileStream(path, FileMode.Create);
        var writer = new StreamWriter(fileStream);
        writer.Write(sourceText);
        writer.Close();
        fileStream.Close();
    }

    private string GetSceneNPCLua()
    {
        var builder = new StringBuilder();
        var npcs = this.GetComponentsInChildren<SceneNPC>();
        foreach (var npc in npcs)
        {
            int x;
            int y;
            this.TransformWorldToLogic(npc.transform.position, out x, out y);
            float rotationY = npc.transform.eulerAngles.y;
            string paths = "";
            if (npc.IsWalking)
            {
                foreach (var path in npc.Paths)
                {
                    paths += string.Format("{{x={0}, y={1}}},", path.x, path.y);
                }
                paths = string.Format("{{{0}}}", paths);
            }
            else
            {
                paths = "{}";
            }
            var npcLua = string.Format("\n\t\t{{id={0}, x={1}, y={2}, rotation_y = {3}, is_walking = {4}, paths = {5}}},", npc.ID, x, y, rotationY, npc.IsWalking ? 1 : 0, paths);
            builder.Append(npcLua);
        }

        return builder.ToString();
    }

    private string GetSceneMonsterLua()
    {
        var builder = new StringBuilder();
        var monsters = this.GetComponentsInChildren<SceneMonsterPoint>();
        foreach (var monster in monsters)
        {
            int x;
            int y;
            this.TransformWorldToLogic(monster.transform.position, out x, out y);

            var monsterLua = string.Format("\n\t\t{{id={0}, x={1}, y={2}}},", monster.ID, x, y);
            builder.Append(monsterLua);
        }

        return builder.ToString();
    }

    private string GetSceneDoorLua()
    {
        var builder = new StringBuilder();
        var doors = this.GetComponentsInChildren<SceneDoor>();
        foreach (var door in doors)
        {
            int x;
            int y;
            this.TransformWorldToLogic(door.transform.position, out x, out y);

            var doorLua = string.Format(
                "\n\t\t{{id={0}, type={1}, level={2}, target_scene_id={3}, target_door_id={4}, offset={{{5}, {6}, {7}}}, rotation={{{8}, {9}, {10}}}, scale={{{11}, {12}, {13}}}, x={14}, y={15}}},",
                door.ID,
                door.DoorType,
                door.LimitLevel,
                door.TargetSceneID,
                door.TargetDoorID,
                door.Offset.x,
                door.Offset.y,
                door.Offset.z,
                door.Rotation.x,
                door.Rotation.y,
                door.Rotation.z,
                door.Scale.x,
                door.Scale.y,
                door.Scale.z,
                x,
                y);
            builder.Append(doorLua);
        }

        return builder.ToString();
    }

    private string GetSceneGatherLua()
    {
        var builder = new StringBuilder();
        var gathers = this.GetComponentsInChildren<SceneGatherPoint>();
        foreach (var gather in gathers)
        {
            int x;
            int y;
            this.TransformWorldToLogic(gather.transform.position, out x, out y);

            var doorLua = string.Format(
                "\n\t\t{{id={0}, x={1}, y={2}}},",
                gather.ID,
                x,
                y);
            builder.Append(doorLua);
        }

        return builder.ToString();
    }

    private string GetSceneJumppointLua()
    {
        var builder = new StringBuilder();
        var elements = this.GetComponentsInChildren<SceneJumpPoint>();
        foreach (var element in elements)
        {
            int x;
            int y;
            this.TransformWorldToLogic(element.transform.position, out x, out y);

            string cgs = "";
            if (element.PlayCG)
            {
                foreach (var cg in element.CGs)
                {
                    cgs += string.Format("{{prof={0},bundle_name=\"{1}\",asset_name=\"{2}\",position={{x={3},y={4}}},rotation={5}}},", cg.prof, cg.cgController.BundleName, 
                        cg.cgController.AssetName, cg.position.x, cg.position.y, cg.rotationY);
                }
                cgs = string.Format("{{{0}}}", cgs);
            }
            else
            {
                cgs = "{}";
            }

            var content = string.Format(
                "\n\t\t{{id={0}, target_id={1}, range={2}, x={3}, y={4}, jump_type={5}, air_craft_id={6}, is_show={7}, jump_speed={8}, jump_act={9},jump_tong_bu={10},jump_time={11},camera_fov={12},camera_rotation={13},offset={{{14},{15},{16}}},play_cg={17},cgs={18}}},",
                element.ID,
                element.TargetID,
                element.Range,
                x,
                y,
                element.JumpType,
                element.AirCraftId,
                element.IsShow,
                element.JumpSpeed,
                element.JumpAct,
                element.TongBu,
                element.JumpTime,
                element.JumpCameraFOV,
                element.JumpCameraRotation,
                element.Offset.x, element.Offset.y, element.Offset.z,
                element.PlayCG ? 1 : 0,
                cgs);

            builder.Append(content);
        }

        return builder.ToString();
    }

    private string GetSceneFencesLua()
    {
        var builder = new StringBuilder();
        var fences = this.GetComponentsInChildren<SceneFence>();
        foreach (var fence in fences)
        {
            int x;
            int y;
            this.TransformWorldToLogic(fence.transform.position, out x, out y);

            var fenceLua = string.Format(
                "\n\t\t{{id={0}, offset={{{1}, {2}, {3}}}, rotation={{{4}, {5}, {6}}}, scale={{{7}, {8}, {9}}}, x={10}, y={11}}},",
                fence.ID,
                fence.Offset.x,
                fence.Offset.y,
                fence.Offset.z,
                fence.Rotation.x,
                fence.Rotation.y,
                fence.Rotation.z,
                fence.Scale.x,
                fence.Scale.y,
                fence.Scale.z,
                x,
                y);
            builder.Append(fenceLua);
        }

        return builder.ToString();
    }

    private string GetSceneEffectLua()
    {
        var builder = new StringBuilder();
        var effects = this.GetComponentsInChildren<SceneEffect>();
        foreach (var effect in effects)
        {
            int x;
            int y;
            this.TransformWorldToLogic(effect.transform.position, out x, out y);

            var effectLua = string.Format(
                "\n\t\t{{bundle=\"{0}\", asset=\"{1}\", offset={{{2}, {3}, {4}}}, rotation={{{5}, {6}, {7}}}, scale={{{8}, {9}, {10}}}, x={11}, y={12}}},",
                effect.AssetID.BundleName,
                effect.AssetID.AssetName,
                effect.Offset.x,
                effect.Offset.y,
                effect.Offset.z,
                effect.Rotation.x,
                effect.Rotation.y,
                effect.Rotation.z,
                effect.Scale.x,
                effect.Scale.y,
                effect.Scale.z,
                x,
                y);
            builder.Append(effectLua);
        }

        return builder.ToString();
    }

    private string GetMapEncodedMask(SceneGridView gridView, bool compress)
    {
        if (compress)
        {
            var dataStream = new MemoryStream(gridView.Column * gridView.Row);
            for (int j = 0; j < gridView.Column; ++j)
            {
                for (int i = 0; i < gridView.Row; ++i)
                {
                    var cell = gridView.GetCell(i, j) as SceneCell;
                    dataStream.WriteByte((byte)cell.Ground);
                }
            }

            var compressStream = new MemoryStream();
            var encoder = new SevenZip.Compression.LZMA.Encoder();
            encoder.SetCoderProperties(
                new SevenZip.CoderPropID[] { SevenZip.CoderPropID.EndMarker },
                new object[] { true });
            dataStream.Position = 0;
            encoder.WriteCoderProperties(compressStream);
            encoder.Code(dataStream, compressStream, -1, -1, null);
            compressStream.Flush();

            var bytes = new byte[compressStream.Length];
            compressStream.Seek(0, SeekOrigin.Begin);
            compressStream.Read(bytes, 0, bytes.Length);
            var mask = Convert.ToBase64String(bytes);
            return mask;
        }
        else
        {
            var maskBuilder = new StringBuilder();
            for (int j = 0; j < gridView.Column; ++j)
            {
                for (int i = 0; i < gridView.Row; ++i)
                {
                    var cell = gridView.GetCell(i, j) as SceneCell;
                    maskBuilder.Append((int)cell.Ground);
                }
            }

            return maskBuilder.ToString();
        }
    }

    private string GetMapMaskShrinked(SceneGridView gridView)
    {
        // 先拷贝一份int数组的Mask出来.
        var cells = new int[gridView.Column * gridView.Row];
        for (int j = 0; j < gridView.Column; ++j)
        {
            for (int i = 0; i < gridView.Row; ++i)
            {
                var cell = gridView.GetCell(i, j) as SceneCell;
                cells[(i * gridView.Column) + j] = (int)cell.Ground;
            }
        }

        if (gridView.Column > 2 && gridView.Row > 2)
        {
            // 逐列缩小
            for (int j = 1; j < gridView.Column - 1; ++j)
            {
                for (int i = 1; i < gridView.Row - 1; ++i)
                {
                    var index = (i * gridView.Column) + j;
                    var cell = cells[index];
                    if (cell == (int)SceneCell.GroundType.Block || cell == (int)SceneCell.GroundType.ObstacleWay)
                    {
                        var cellNext = ((SceneCell)gridView.GetCell(i, j + 1)).Ground;
                        var cellPrev = ((SceneCell)gridView.GetCell(i, j - 1)).Ground;
                        if (cellNext != SceneCell.GroundType.Block && cellNext != SceneCell.GroundType.ObstacleWay)
                        {
                            cells[index] = (int)cellNext;
                        }
                        else if (cellPrev != SceneCell.GroundType.Block && cellPrev != SceneCell.GroundType.ObstacleWay)
                        {
                            cells[index] = (int)cellPrev;
                        }
                    }
                }
            }

            // 逐行缩小
            for (int i = 1; i < gridView.Row - 1; ++i)
            {
                for (int j = 1; j < gridView.Column - 1; ++j)
                {
                    var index = (i * gridView.Column) + j;
                    var cell = cells[index];
                    if (cell == (int)SceneCell.GroundType.Block || cell == (int)SceneCell.GroundType.ObstacleWay)
                    {
                        var cellNext = ((SceneCell)gridView.GetCell(i + 1, j)).Ground;
                        var cellPrev = ((SceneCell)gridView.GetCell(i - 1, j)).Ground;
                        if (cellNext != SceneCell.GroundType.Block && cellNext != SceneCell.GroundType.ObstacleWay)
                        {
                            cells[index] = (int)cellNext;
                        }
                        else if (cellPrev != SceneCell.GroundType.Block && cellPrev != SceneCell.GroundType.ObstacleWay)
                        {
                            cells[index] = (int)cellPrev;
                        }
                    }
                }
            }
        }

        // 写入缩小后的Mask.
        var maskBuilder = new StringBuilder();
        for (int j = 0; j < gridView.Column; ++j)
        {
            for (int i = 0; i < gridView.Row; ++i)
            {
                int mask = cells[(i * gridView.Column) + j];
                maskBuilder.Append(mask);
            }
        }

        return maskBuilder.ToString();
    }

    private void SaveNPCs(XmlWriter writer)
    {
        writer.WriteStartElement("npcs");

        var npcs = this.GetComponentsInChildren<SceneNPC>();
        foreach (var npc in npcs)
        {
            if (npc.IsWalking)
                continue;
            writer.WriteStartElement("npc");
            writer.WriteElementString("id", npc.ID.ToString());
            this.WritePosition(writer, npc.transform.position);
            writer.WriteEndElement();
        }

        writer.WriteEndElement();
    }

    private void SaveMonsterPoints(XmlWriter writer)
    {
        writer.WriteStartElement("monsterpoints");

        var monsterPoints = this.GetComponentsInChildren<SceneMonsterPoint>();
        foreach (var monsterPoint in monsterPoints)
        {
            writer.WriteStartElement("point");
            writer.WriteElementString("monsterid", monsterPoint.ID.ToString());
            writer.WriteElementString("interval", monsterPoint.Interval.ToString());
            writer.WriteElementString("num", monsterPoint.Num.ToString());
            writer.WriteElementString("histroytotalnum", monsterPoint.HistroyTotalNum.ToString());
            this.WritePosition(writer, monsterPoint.transform.position);
            writer.WriteEndElement();
        }

        writer.WriteEndElement();
    }

    private void SaveDoorsPoints(XmlWriter writer)
    {
        writer.WriteStartElement("doors");

        var doors = this.GetComponentsInChildren<SceneDoor>();
        foreach (var door in doors)
        {
            writer.WriteStartElement("door");
            writer.WriteElementString("id", door.ID.ToString());
            writer.WriteElementString("type", door.DoorType.ToString());
            writer.WriteElementString("level", door.LimitLevel.ToString());
            writer.WriteElementString("target_scene_id", door.TargetSceneID.ToString());
            writer.WriteElementString("target_door_id", door.TargetDoorID.ToString());
            this.WritePosition(writer, door.transform.position);
            writer.WriteEndElement();
        }

        writer.WriteEndElement();
    }

    private void SaveGatherPointsPoints(XmlWriter writer)
    {
        writer.WriteStartElement("gatherpoints");

        var gatherPoints = this.GetComponentsInChildren<SceneGatherPoint>();
        foreach (var gatherPoint in gatherPoints)
        {
            writer.WriteStartElement("gather");
            writer.WriteElementString("id", gatherPoint.ID.ToString());
            writer.WriteElementString("index", gatherPoint.Index.ToString());
            writer.WriteElementString("create_interval", gatherPoint.Interval.ToString());
            writer.WriteElementString("gather_time", gatherPoint.GatherTime.ToString());
            writer.WriteElementString("evil_add", gatherPoint.EvilAdd.ToString());
            writer.WriteElementString("disappear_after_gather", gatherPoint.DisappearAfterGather.ToString());
            this.WritePosition(writer, gatherPoint.transform.position);
            writer.WriteEndElement();
        }

        writer.WriteEndElement();
    }

    private void WritePosition(XmlWriter writer, Vector3 position)
    {
        int x;
        int y;
        this.TransformWorldToLogic(position, out x, out y);
        writer.WriteElementString("x", x.ToString());
        writer.WriteElementString("y", y.ToString());
    }

    public void TransformWorldToLogic(Vector3 position, out int x, out int y)
    {
        var pos = this.transform.position;

        float GridSize = 1.0f;
        SceneGridView scene_grid_view = this.gameObject.GetComponent<SceneGridView>();
        if (null != scene_grid_view)
        {
            GridSize = scene_grid_view.CellSize.x;
        }
        float GridSizeInverse = 1.0f / GridSize;

        x = (int)Mathf.Floor((position.x - pos.x) * GridSizeInverse);
        y = (int)Mathf.Floor((position.z - pos.z) * GridSizeInverse);
    }

    private void Update()
    {
        // Snap to grid.

        float GridSize = 1.0f;
        SceneGridView scene_grid_view = this.gameObject.GetComponent<SceneGridView>();
        if (null != scene_grid_view)
        {
            GridSize = scene_grid_view.CellSize.x;
        }
        float GridSizeInverse = 1.0f / GridSize;

        var x = Mathf.Floor(transform.position.x * GridSizeInverse) / GridSizeInverse;
        var y = transform.position.y;
        var z = Mathf.Floor(transform.position.z * GridSizeInverse) / GridSizeInverse;

        this.transform.position = new Vector3(x, y, z);
    }
}

#endif
