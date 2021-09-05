require("game/luandou_battle/luandou_battle_data")
require("game/luandou_battle/luandou_battle_view")
require("game/luandou_battle/tips_luandou_battle_reward")
require("game/luandou_battle/luandou_allreward_view")
require("game/luandou_battle/luandou_battle_rank_list")
require("game/luandou_battle/luandou_finish_reward_view")
require("game/luandou_battle/luandou_reward_view")

LuanDouBattleCtrl = LuanDouBattleCtrl or BaseClass(BaseController)
function LuanDouBattleCtrl:__init()
	if LuanDouBattleCtrl.Instance ~= nil then
		print_error("[LuanDouBattleCtrl] attempt to create singleton twice!")
		return
	end
	LuanDouBattleCtrl.Instance = self

	self.data = LuanDouBattleData.New()
	self.view = LuanDouBattleView.New(ViewName.LuanDouBattleView)
	self.luandou_battle_reward_tips = LuanDouRewardView.New(ViewName.LuanDouRewardView)
	self.luandou_allreward_view = LuanDouAllRewardView.New(ViewName.LuanDouBattleAllRewardView)
	self.luandou_finish_reward_view = LuanDouFinishRewardView.New(ViewName.LuanDouFinishRewardView)
	self.luandou_battle_reward = LuanDouBattleRewardView.New(ViewName.LuanDouBattleRewardView)
	self.luandou_hurt_rank_view = LuanDouRankList.New()
	self:RegisterAllProtocals()
	self.role_info_list = {}
end

function LuanDouBattleCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.luandou_battle_reward_tips then
		self.luandou_battle_reward_tips:DeleteMe()
		self.luandou_battle_reward_tips = nil
	end

	if self.luandou_battle_reward then
		self.luandou_battle_reward:DeleteMe()
		self.luandou_battle_reward = nil
	end

	if self.luandou_hurt_rank_view then
		self.luandou_hurt_rank_view:DeleteMe()
		self.luandou_hurt_rank_view = nil
	end

	if self.luandou_allreward_view then
		self.luandou_allreward_view:DeleteMe()
		self.luandou_allreward_view = nil
	end

	if self.luandou_finish_reward_view then
		self.luandou_finish_reward_view:DeleteMe()
		self.luandou_finish_reward_view = nil
	end

	LuanDouBattleCtrl.Instance = nil
end

function LuanDouBattleCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCMessBattleRoleInfo, "OnMessBattleRoleInfo")
	self:RegisterProtocol(SCMessBattleRankInfo, "OnMessBattleRankInfo")
	self:RegisterProtocol(SCMessBattleReward, "OnMessBattleReward")
	self:RegisterProtocol(SCMessBattleHurtRankInfo, "OnMessBattleHurtRankInfo")
	self:RegisterProtocol(SCMessBattleToalScoreRank, "SCMessBattleRoleTotalScore")
	self:RegisterProtocol(SCMessBattleAllRoleScoreInfo, "OnMessBattleAllRoleScoreInfo")
	self:RegisterProtocol(CSMessBattleEnterReq)
end

function LuanDouBattleCtrl:OnMessBattleRoleInfo(protocol)
	FuBenCtrl.Instance:FlushLuanDouHP()
	self.data:SetRoleInfo(protocol)
	self.view:FlushRoleInfo()

	if protocol.is_finish == 1 then
		ViewManager.Instance:Open(ViewName.LuanDouFinishRewardView, nil, "luandou",{data = protocol.is_finish})
	end	
end

function LuanDouBattleCtrl:OnMessBattleRankInfo(protocol)
	self.data:SetJiFenRankInfo(protocol)
	self.view:Flush("person_score")
end

function LuanDouBattleCtrl:OnMessBattleReward(protocol)
	self.data:SetBattleReward(protocol)
	-- if self.luandou_battle_reward_tips then
	-- 	local data = LuanDouBattleData.Instance:GetAllRankReward()
	-- 	if data then
	-- 		local num = #data
	-- 		if num > 0 then
	-- 			self.luandou_battle_reward_tips:Open()
	-- 			self.luandou_battle_reward_tips:SetData(data[num].reward_item)
	-- 			self.luandou_battle_reward_tips:Flush()
	-- 		end
	-- 	end
	-- end
end

function LuanDouBattleCtrl:ShowLuanDouRewardTips(data)
	if nil == data then return end
	if self.luandou_battle_reward_tips then
		local num = #data
		if num > 0 then
			self.luandou_battle_reward_tips:Open()
			self.luandou_battle_reward_tips:SetData(data[num].reward_item)
			self.luandou_battle_reward_tips:Flush()
		end
	end
end

function LuanDouBattleCtrl:OnMessBattleHurtRankInfo(protocol)
	self.data:SetHurtRankInfo(protocol)
	--self.view:Flush("hurt")
	-- self.view:FlushRank()
end

function LuanDouBattleCtrl:SCMessBattleRoleTotalScore(protocol)
	self.data:SetAllJiFenRankInfo(protocol)
	self.view:Flush("all_score")
end

function LuanDouBattleCtrl:OnMessBattleAllRoleScoreInfo(protocol)
	self.score_rank = protocol.role_info_list
	table.sort(self.score_rank, SortTools.KeyUpperSorter("score"))
	for k ,v in pairs(self.score_rank) do 
		self:SetInfoScore(v)
	end
	self.view:Flush("all_score")
end

-- 根据id设置人物头上显示的分数
function LuanDouBattleCtrl:SetInfoScore(obj_data)
	local obj = Scene.Instance:GetObj(obj_data.obj_id)
	if obj then
		if obj:GetType() == SceneObjType.Role or obj:GetType() == SceneObjType.MainRole then
			obj:SetRoleScore(obj_data.score)
		end
	end
end

function LuanDouBattleCtrl:SendMessBattleEnterReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMessBattleEnterReq)
	send_protocol:EncodeAndSend()
end

function LuanDouBattleCtrl:OpenLuandouBattleAllReward()
	if self.luandou_allreward_view then
		self.luandou_allreward_view:Open()
		self.luandou_allreward_view:Flush()
	end
end

function LuanDouBattleCtrl:OpenLuanDouHurtRank()
	if self.luandou_hurt_rank_view then
		self.luandou_hurt_rank_view:Open()
		self.luandou_hurt_rank_view:Flush()
	end
end
