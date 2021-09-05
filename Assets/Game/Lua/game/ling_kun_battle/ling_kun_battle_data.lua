LingKunBattleData = LingKunBattleData or BaseClass()
LingKunBattleData.OPERA =
{
	LIEKUNFB_TYPE_GET_PLAYER_INFO = 0,-- 得到玩家id
	LIEKUNFB_TYPE_MAX,
}

function LingKunBattleData:__init()
	if LingKunBattleData.Instance then
		print_error("[LingKunBattleData] Attempt to create singleton twice!")
		return
	end
	LingKunBattleData.Instance = self

	self.scene_info = {}
	self.scene_info.zone = 0
	self.scene_info.is_main_live_flag = 0
	self.scene_info.boss_list = {}
	self.scene_info.guild_id = {}
	self.scene_info.boss_next_flush_timestamp = {}
	self.lingkun_boss_hurt_info = {}
	self.lingkun_boss_hurt_show = true

	self.guild_info = {}
	self.guild_info.zone = 0
	self.guild_info.boss_type = 0
	self.guild_info.pos_x = 0
	self.guild_info.pos_y = 0
	self.guild_info.role_name = ""

	self.player_info = {}
	self.player_info.is_enter_main_zone = 0
	self.player_info.role_num = {}
	for i = 1 , GameEnum.LIEKUN_ZONE_TYPE_COUNT do
		self.player_info.role_num[i] = 0		-- 区域玩家人数
	end

	self.cross_liekun_auto = ConfigManager.Instance:GetAutoConfig("cross_liekun_auto")

end

function LingKunBattleData:__delete()
	LingKunBattleData.Instance = nil

	self.scene_info = {}
	self.guild_info = {}
end

function LingKunBattleData:SetLingKunFBSceneinfo(protocol)
	self.scene_info.zone = protocol.zone or 0
	self.scene_info.boss_list = protocol.boss_list or {}
	self.scene_info.guild_id = protocol.guild_id or {}
	self.scene_info.boss_next_flush_timestamp = protocol.boss_next_flush_timestamp or {}
end

function LingKunBattleData:GetLingKunFBSceneinfo()
	return self.scene_info
end

function LingKunBattleData:SetLingKunFBGuildMsgInfo(protocol)
	self.guild_info.zone = protocol.zone or 0
	self.guild_info.is_main_live_flag = protocol.is_main_live_flag
end

function LingKunBattleData:GetLingKunFBGuildMsgInfo()
	return self.guild_info
end

function LingKunBattleData:SetLingKunFBPlayerInfo(protocol)
	self.player_info.is_enter_main_zone = protocol.is_enter_main_zone
	self.player_info.role_num = protocol.role_num
end

function LingKunBattleData:GetLingKunFBPlayerInfo()
	return self.player_info
end


function LingKunBattleData:GetBossInfomationCfg()
	local boss_cfg = self.cross_liekun_auto.cross_boss_information
	return boss_cfg
end

function LingKunBattleData:GetBossZonePosCfg(zone_index)
	local boss_cfg = self.cross_liekun_auto.zone[zone_index + 1]
	return boss_cfg
end

function LingKunBattleData:GetBossCfg()
	local boss_cfg = self.cross_liekun_auto
	return boss_cfg
end

function LingKunBattleData:GetEnterLimitTime()
	local other_cfg = self.cross_liekun_auto.other
	return other_cfg[1].enter_time_limit_s
end


function LingKunBattleData:GetRewardCfg(index)
	local item_list = {}
	local select_index = index or 1
	local boss_cfg = self.cross_liekun_auto.cross_boss_information
	local reward_list = Split(boss_cfg[select_index].drop_item_list or "", "|")
	
	if next(reward_list) then 
		for k , v in pairs(reward_list) do
			item_list[k] = {item_id = tonumber(v)}
		end

	end
	return item_list
end

function LingKunBattleData:IsDoorClose()
	local end_time = ActivityData.Instance:GetActivityResidueTime(3087)
	local FinalTime = TimeUtil.Format2TableDHMS(end_time)
	if FinalTime.min < 15 then
		return true
	end
	return false
end

function LingKunBattleData:GetMonsterID(index)
	local select_index = index or 1
	local boss_cfg = self.cross_liekun_auto.cross_boss_information
	local boss_id = boss_cfg[select_index].boss_id

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local monster_res_id = monster_cfg[boss_id].resid or 3014001

	return monster_res_id
end

function LingKunBattleData:GetMonsterIDInCfg(index)
	local select_index = index or 1
	local boss_cfg = self.cross_liekun_auto.cross_boss_information
	local boss_id = 0
	if boss_cfg then
		boss_id = boss_cfg[select_index] and boss_cfg[select_index].boss_id or 0
	end

	return boss_id
end

function LingKunBattleData:SetCrossLieKunFBBossHurtInfo(protocol)
	self.lingkun_boss_hurt_info = protocol
	if self.lingkun_boss_hurt_info.own_guild_rank then
		self.lingkun_boss_hurt_info.own_guild_rank = self.lingkun_boss_hurt_info.own_guild_rank + 1
	end
end

function LingKunBattleData:GetCrossLieKunFBBossHurtInfo()
	return self.lingkun_boss_hurt_info
end

function LingKunBattleData:SetLingKunBossHurtShow(enble)
	self.lingkun_boss_hurt_show = enble
end

function LingKunBattleData:GetLingKunBossHurtShow()
	return self.lingkun_boss_hurt_show
end

function LingKunBattleData:ClearGuildHurtRankInfo()
	if self.lingkun_boss_hurt_info and next(self.lingkun_boss_hurt_info) ~= nil then
		self.lingkun_boss_hurt_info.hurt_list = {}
		self.lingkun_boss_hurt_info.boss_id = 0
		self.lingkun_boss_hurt_info.own_guild_rank = 0
		self.lingkun_boss_hurt_info.own_guild_hurt = 0
	end
end