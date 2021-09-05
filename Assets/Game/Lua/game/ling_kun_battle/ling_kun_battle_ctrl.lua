require("game/ling_kun_battle/ling_kun_battle_scene_view")
require("game/ling_kun_battle/ling_kun_battle_detail_view")
require("game/ling_kun_battle/ling_kun_battle_boss_view")
require("game/ling_kun_battle/ling_kun_battle_data")
LingKunBattleCtrl = LingKunBattleCtrl or  BaseClass(BaseController)

function LingKunBattleCtrl:__init()
	if LingKunBattleCtrl.Instance ~= nil then
		print_error("[LingKunBattleCtrl] attempt to create singleton twice!")
		return
	end

	self.is_first = true

	LingKunBattleCtrl.Instance = self
	self.data = LingKunBattleData.New()
	self.detail_view = LingKunBattleDetailView.New(ViewName.LingKunBattleDetailView)
	self.scene_view = LingKunBattleSceneView.New(ViewName.LingKunBattleSceneView)
	self.boss_view = LingKunBattleBossView.New(ViewName.LingKunBattleBossView)
	self:RegisterAllProtocols()
end

function LingKunBattleCtrl:GetView()
	return self.view
end

function LingKunBattleCtrl:OpenScenePanel()
	self.scene_view:Open()
end

function LingKunBattleCtrl:CloseScenePanel()
	self.scene_view:Close()
end


function LingKunBattleCtrl:__delete()

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.detail_view then
		self.detail_view:DeleteMe()
		self.detail_view = nil
	end

	if self.scene_view then
		self.scene_view:DeleteMe()
		self.scene_view = nil
	end

	if self.boss_view then
		self.boss_view:DeleteMe()
		self.boss_view = nil
	end

	if self.clear_info_quest then
		GlobalTimerQuest:CancelQuest(self.clear_info_quest)
		self.clear_info_quest = nil
	end

	LingKunBattleCtrl.Instance = nil
end

function LingKunBattleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossLieKunFBSceneInfo, "OnCrossLieKunFBSceneInfo")
	self:RegisterProtocol(SCCrossLieKunFBGuildMsgInfo, "OnCrossLieKunFBGuildMsgInfo")
	self:RegisterProtocol(SCCrossLieKunFBPlayerInfo, "OnCrossLieKunFBPlayerInfo")
	self:RegisterProtocol(SCCrossLieKunFBBossHurtInfo, "OnCrossLieKunFBBossHurtInfo")
	self:RegisterProtocol(CSCrossLieKunFBReq)
end

function LingKunBattleCtrl:OnCrossLieKunFBSceneInfo(protocol)
	self.data:SetLingKunFBSceneinfo(protocol)
	self:OnBossDpsInfo(protocol)
	self.scene_view:Flush()
end

function LingKunBattleCtrl:OnBossDpsInfo(protocol)
	-- for i = 1 , GameEnum.LIEKUN_ZONE_TYPE_COUNT do
	-- 	local guild_name = GuildData.Instance:GetGuildNameByGuild(protocol.guild_id[i])
	-- 	if protocol.boss_list[i].boss_id ~= 0 then
	-- 		local monster_obj = Scene.Instance:GetObj(protocol.boss_list[i].boss_obj_id)
	-- 		if monster_obj and monster_obj.SetDpsTargetName then
	-- 			monster_obj:SetDpsTargetName(guild_name)
	-- 		end
	-- 	end
	-- end
end

function LingKunBattleCtrl:OnCrossLieKunFBBossHurtInfo(protocol)
	if protocol.boss_id ~= 0 then
		self.data:SetCrossLieKunFBBossHurtInfo(protocol)
		if self.scene_view then
			self.scene_view:FlushHurtRankList()
		end

		local is_show = self.data:GetLingKunBossHurtShow()
		if is_show then
			self.scene_view:SetIsLingKunBossRange(true)
		end
		self.data:SetLingKunBossHurtShow(false)
		if self.clear_info_quest then
			GlobalTimerQuest:CancelQuest(self.clear_info_quest)
			self.clear_info_quest = nil
		end

		self.clear_info_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.data:ClearGuildHurtRankInfo()
			self.scene_view:FlushHurtRankList()
			if self.clear_info_quest then
				GlobalTimerQuest:CancelQuest(self.clear_info_quest)
				self.clear_info_quest = nil
			end
			self.scene_view:SetIsLingKunBossRange(false)
			self.data:SetLingKunBossHurtShow(true)
			end, 2)
	end
end

function LingKunBattleCtrl:OnCrossLieKunFBGuildMsgInfo(protocol)
	self.data:SetLingKunFBGuildMsgInfo(protocol)
	self.scene_view:FlushCellList()
end

function LingKunBattleCtrl:OnCrossLieKunFBPlayerInfo(protocol)
	self.data:SetLingKunFBPlayerInfo(protocol)
	self.detail_view:Flush()
end

-- 玩家信息请求
function LingKunBattleCtrl:SendLingKunOperate()
	local player_guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	LingKunBattleCtrl.SendLingKunReq(LingKunBattleData.OPERA.LIEKUNFB_TYPE_GET_PLAYER_INFO, 0, player_guild_id)
end

-- 发送协议
function LingKunBattleCtrl.SendLingKunReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossLieKunFBReq)
	protocol.opera_type = opera_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end