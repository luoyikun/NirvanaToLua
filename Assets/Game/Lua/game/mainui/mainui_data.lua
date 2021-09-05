MainUIData = MainUIData or BaseClass()

MainUIData.IsFightState = false
MainUIData.IsSetCameraZoom = true
MainUIData.UserOperation = false

MainUIData.RemindingName = {
	Player = 1,
	Baoju = 2,
	Forge = 3,
	Advance = 4,
	Goddress = 5,
	Guild = 6,
	Scoiety = 7,
	Marriage = 8,
	Rank = 9,
	Compose = 10,
	Market = 11,
	Spirit = 12,
	FuBenMulti = 13,
	FuBenSingle = 14,
	BattleField = 15,
	ActivityHall = 16,
	TreasureHunt = 17,
	NewServer = 18,
	Welfare = 19,
	Echange = 20,
	Shop = 21,
	Setting = 22,
	Church = 23,
	Auto = 24,
	Package = 25,
	Deposit = 26,
	Vip = 27,
	XiuLuoTower = 28,
	TreasureBowl = 29,
	TombExplore = 30,
	CityCombat = 31,
	Daily_Charge = 32,
	Invest = 33,
	Rebate = 34,
	HuanJing_XunBao = 35,
	Seven_Login_Redpt = 36,
	Show_Seven_Login = 37,
	First_Charge = 38,
	Cross_Hot_Spring = 39,
	Big_Rich = 40,
	Question = 41,
	Double_Escort = 42,
	Cross_One_Vs_One = 43,
	Clash_Territory = 44,
	Guild_Battle = 45,
	Fall_Money = 46,
	Element_Battle = 47,
	Boss = 48,
	Collection_Redpt = 49,
	Show_Collection = 50,
	Show_Reincarnation = 51,
	Reincarnation_Redpt = 52,
	GuildMijing = 53,
	GuildBonfire = 54,
	GuildBoss = 55,
	Pet = 56,
	MagicWeapon = 57,
	CrossCrystal = 58,
	show_invest_icon = 59,
	MarryMe = 60,
	ExpRefine = 61,
	MolongMibao = 62,
	ActHongBao = 63,
	Show_Leiji_ChongZhi = 64,
	BiPin = 65,
	Boss_View = 66,
	Member_repdt = 67,
	ZeroGift = 68,
	YiZhanDaoDi = 69,
	JinYinTa = 70,
	ZhenBaoGe = 71,
	ZhuanZhuanLe = 72,
	ZhenBaoGe2 = 73,
	CrossTuanZhan = 74,
	CrossFarmHunting = 75,
	KFDarkNight = 76,
	Fishing = 77,
	KFNightFight = 78,
	LoopCharge2 =79,
}

function MainUIData:__init()
	if MainUIData.Instance ~= nil then
		print_error("[MainUIData] attempt to create singleton twice!")
		return
	end
	MainUIData.Instance = self
end

function MainUIData:__delete()
	MainUIData.Instance = nil
end

function MainUIData.IsInDabaoScene()
	local scene_id = Scene.Instance:GetSceneId()
	return 9000 <= scene_id and scene_id <= 9009
end

function MainUIData.IsInBossHomeScene()
	local scene_id = Scene.Instance:GetSceneId()
	return 300 <= scene_id and scene_id <= 309
end

-- 阵营普通夺宝
function MainUIData.IsInCampDuobaoScene()
	local scene_id = Scene.Instance:GetSceneId()
	local nor_boss_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").normalduobao
	for k,v in pairs(nor_boss_cfg) do
		if scene_id == v.sceneid then
			return true
		end
	end
	return false
end

-- 阵营雕像场景
function MainUIData.IsInCampStatueoScene(scene_id)
	scene_id = scene_id or Scene.Instance:GetSceneId()
	local camp_other_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
	for i = 1, 3 do
		if scene_id == camp_other_cfg["dx_sceneid" .. i] then
			return true
		end
	end
	return false
end

--BOSS洞窟
function MainUIData:IsInBossCave()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id >= 130 and scene_id <= 139 then
		return true
	end
	return false
end

-- 这些图标80级以前主界面不显示红点
local LOW_LEVEL_HIDE_RED_REMIND_LIST = {
	[RemindName.Goddess_Ground] = true,
	[RemindName.Forge] = true,
	[RemindName.PlayerView] = true,
	[RemindName.Compose] = true,
	[RemindName.Scoiety] = true,
	[RemindName.Guild] = true,
	[RemindName.MarryGroup] = true,
	[RemindName.ShenGe] = true,
	[RemindName.SuitCollection] = true,
	[ViewName.Rune] = true,
	[RemindName.Advance] = true,
	[RemindName.Spirit] = true,
	[RemindName.DisCount] = true,
}

function MainUIData.GetIsShowLevelRed(name)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if LOW_LEVEL_HIDE_RED_REMIND_LIST[name] then
		if role_level < COMMON_CONSTS.REMIND_LEVEL then
			return false
		end
	end
	return true
end

local STRENGTH_ICON_LIST = {
	[Language.Mainui.Pata] = {
		name = Language.Mainui.Pata,
		callback = function ()
			ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_tower)
		end,
		remind = 0
	},

	[Language.Mainui.OnlineReward] = {
		name = Language.Mainui.OnlineReward,
		callback = function ()
			ViewManager.Instance:Open(ViewName.OnLineReward)
		end,
		remind = 0
	},

	[Language.Mainui.RuneTower] = {
		name = Language.Mainui.RuneTower,
		callback = function ()
			ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
		end,
		remind = 0
	},

	[Language.Mainui.TuHaoJin] = {
		name = Language.Mainui.TuHaoJin,
		callback = function ()
			ViewManager.Instance:Open(ViewName.CoolChat, TabIndex.gold_text)
		end,
		remind = 0
	},

	[Language.Role.TiHuanZhuangBei] = {
		name = Language.Role.TiHuanZhuangBei,
		callback = function ()
			ViewManager.Instance:Open(ViewName.PackageView)
		end,
		remind = 0
	},

	[Language.Mainui.FuBenQuality] = {
		name = Language.Mainui.FuBenQuality,
		callback = function()
			local capability = GameVoManager.Instance:GetMainRoleVo().capability or 0
			PlayerPrefsUtil.SetInt("fubenquality_remind", capability)
			ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_quality)
		end,
		remind = 0
	},

	[Language.Mainui.PushSpeFb] = {
		name = Language.Mainui.PushSpeFb,
		callback = function ()
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_push_special)
		end,
		remind = 0
	},
}

--变强按钮
function MainUIData:GetStrengthButtonList()
	local data = {}
	-- 爬塔
	if FuBenData.Instance:PowerTowerCanChallange() then
		table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.Pata])
	end
	-- local reward_data, is_all_get = WelfareData.Instance:GetOnlineReward()
	-- if not is_all_get then
	-- 	table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.OnlineReward])
	-- end

	if GuaJiTaData.Instance:RuneTowerCanChallange() then
		table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.RuneTower])
	end

	-- if CoolChatData.Instance:GetCoolChatRedPoint() then
	-- 	table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.TuHaoJin])
	-- end

	if PackageData.Instance:CheckBagBatterEquip() ~= 0 then
		table.insert(data, STRENGTH_ICON_LIST[Language.Role.TiHuanZhuangBei])
	end

	if FuBenData.Instance:CheckIsOpenFubenQuality() then
		table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.FuBenQuality])
	end

	-- if FuBenData.Instance:GetIsCanPushCommonFb(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD) then
	-- 	table.insert(data, STRENGTH_ICON_LIST[Language.Mainui.PushSpeFb])
	-- end
	return data
end

function MainUIData:SetTaskData(data)
	self.task_data = data
end

function MainUIData:GetTaskData()
	return self.task_data or {}
end

function MainUIData:SetSkillData(skill_data)
	self.skill_data = skill_data
end

function MainUIData:GetSkillData()
	return self.skill_data or {}
end

function MainUIData:GetSkillIndexBySkillId(skill_id)
	if skill_id and self.skill_data then
		for k,v in pairs(self.skill_data) do
			if skill_id == v.skill_id then
				return k
			end
		end
	end
	return 0
end

function MainUIData:SetSkillRestTimeData(skill_rest_time_data)
	self.skill_rest_data = {}
	self.skill_rest_data = skill_rest_time_data
end

function MainUIData:GetSkillRestTimeData()
	return self.skill_rest_data or {}
end