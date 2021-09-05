require("game/kuafu_tuanzhan/kuafu_tuanzhan_data")
require("game/kuafu_tuanzhan/kuafu_tuanzhan_task_view")
require("game/kuafu_tuanzhan/kuafu_tuanzhan_rank_view")
require("game/kuafu_tuanzhan/kuafu_tuanzhan_reward_view")
require("game/kuafu_tuanzhan/kuafu_tuanzhan_round_reward_view")
KuaFuTuanZhanCtrl = KuaFuTuanZhanCtrl or BaseClass(BaseController)

function KuaFuTuanZhanCtrl:__init()
	if nil ~= KuaFuTuanZhanCtrl.Instance then
		print_error("[KuaFuTuanZhanCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuTuanZhanCtrl.Instance = self

	self.data = KuaFuTuanZhanData.New()
	self.task_view = KuaFuTuanZhanTaskView.New(ViewName.KuaFuTuanZhanTaskView)
	self.rank_view = KuaFuTuanZhanRankView.New(ViewName.KuaFuTuanZhanRankView)
	self.reward_view = KuaFuTuanZhanRewardView.New(ViewName.KuaFuTuanZhanRewardView)
	self.tuanzhan_round_reward_view = KuaFuTuanZhanRoundRewardView.New(ViewName.KuaFuTuanZhanRoundRewardView)
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self:RegisterAllProtocols()
	self.once_flush = true
end

function KuaFuTuanZhanCtrl:__delete()
	if nil ~= self.task_view then
		self.task_view:DeleteMe()
		self.task_view = nil
	end
	if nil ~= self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end
	if nil ~= self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if nil ~= self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	
	KuaFuTuanZhanCtrl.Instance = nil
end

function KuaFuTuanZhanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSNightFightEnterReq)
	self:RegisterProtocol(SCNightFightRoleInfo, "OnCrossNightFightRoleInfo")
	self:RegisterProtocol(SCNightFightRankInfo, "OnCrossNightFightRankInfo")
	self:RegisterProtocol(SCNightFightBossRankInfo, "OnSCNightFightBossRankInfo")
	self:RegisterProtocol(SCNightFightReward, "OnCrossNightFightReward")
	self:RegisterProtocol(SCNightFightRedSideListInfo, "OnCrossNightFightRedSideListInfo")
	self:RegisterProtocol(SCNightFightAllRoleScoreInfo, "OnCrossNightFightAllRoleScoreInfo")
	self:RegisterProtocol(SCNightFightTotalScoreRank, "OnSCNightFightTotalScoreRank")
	self:RegisterProtocol(SCNightFightPlayerPosi, "OnCrossNightFightPlayerPosi")
end

---------------合G21----- 跨服夜战云巅-------------------
function KuaFuTuanZhanCtrl:OnChangeScene()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.KF_NightFight then
		FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBossIcon, self, 1))
	end
end

function KuaFuTuanZhanCtrl:OnClickBossIcon()
	local info = self.data:GetRoleInfo()
	if nil == next(info) then return end

	local boss_id = self.data:GetBossID()

	local boss_flush_time = math.floor(info.next_flush_boss_time - TimeCtrl.Instance:GetServerTime())
	if boss_flush_time > 0 then return end

	local boss_id = self.data:GetBossID()
	local x, y = GuajiCtrl.Instance:GetMonsterPos(boss_id)
	if x and y then
		self:MoveToPosOperateFight(x, y)
	end
end

function KuaFuTuanZhanCtrl:MoveToPosOperateFight(x, y)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_id = KuaFuTuanZhanData.Instance:GetBossID()
	GuajiCtrl.Instance:CancelSelect()
	GuajiCtrl.Instance:ClearAllOperate()
	MoveCache.param1 = boss_id
	GuajiCache.monster_id = boss_id
	MoveCache.end_type = MoveEndType.FightByMonsterId

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
end

function KuaFuTuanZhanCtrl:SendNightFightEnterReq(opera_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNightFightEnterReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

-- 夜战王城人物信息
function KuaFuTuanZhanCtrl:OnCrossNightFightRoleInfo(protocol)
	self.data:SetRoleInfo(protocol)
	self.task_view:Flush("switch_time")
	FuBenCtrl.Instance:GetFuBenIconView():Flush()
	if protocol.is_finish == 1 then
		ViewManager.Instance:Open(ViewName.LuanDouFinishRewardView, nil, "nuzhan", {data = protocol.is_finish})
	end
end

-- 夜战王城积分排行信息
function KuaFuTuanZhanCtrl:OnCrossNightFightRankInfo(protocol)
	self.data:SetFightRankInfo(protocol.rank_info_list)
	self.task_view:Flush("flush_rank_list")
end

-- 夜战王城boss伤害排行信息
function KuaFuTuanZhanCtrl:OnSCNightFightBossRankInfo(protocol)
	self.data:SetBossRankInfo(protocol)
	self.task_view:Flush("flush_boss_rank_list")
end

function KuaFuTuanZhanCtrl:SetAllPlayerInfo()
	local info = self.data:GetFightRankInfo()
	for k , v in pairs(info) do 
		self:SetInfoSideBroadcast(v)
		self:SetInfoScoreBroadcast(v)
	end
end


-- 根据id设置人物头上显示的分数
function KuaFuTuanZhanCtrl:SetInfoScoreBroadcast(obj_data)
	local obj = Scene.Instance:GetObj(obj_data.obj_id)
	if obj then
		if obj:GetType() == SceneObjType.Role or obj:GetType() == SceneObjType.MainRole then
			obj:SetRoleScore(obj_data.score)
		end
	end
end

-- 根据id设置人物头上显示的阵营
function KuaFuTuanZhanCtrl:SetInfoSideBroadcast(obj_data)
	local obj = Scene.Instance:GetObj(obj_data.obj_id)
	if obj then
		if obj:GetType() == SceneObjType.Role or obj:GetType() == SceneObjType.MainRole then
			if obj:GetVo().special_param ~= obj_data.is_red_side then
				obj:SetAttr("special_param", obj_data.is_red_side)
			end
		end
	end
end



-- 夜战王城排名奖励信息
function KuaFuTuanZhanCtrl:OnCrossNightFightReward(protocol)
	self.data:SetFightReward(protocol)
	-- self.task_view:Flush("switch_time")
end

-- 夜战王城魔方人物obj_id列表
function KuaFuTuanZhanCtrl:OnCrossNightFightRedSideListInfo(protocol)
	self.data:SetNightFightRedSideListInfo(protocol)

	local main_role = Scene.Instance:GetMainRole()
	if main_role ~= nil then
		main_role.vo.obj_id = main_role:GetObjId()
		-- main_role:UpdateNameBoard()
	end

	local role_list = Scene.Instance:GetRoleList()
	for k ,v in pairs(role_list) do
		v.vo.obj_id = v:GetObjId()
		-- v:UpdateNameBoard()
	end
end

function KuaFuTuanZhanCtrl:OnCrossNightFightAllRoleScoreInfo()
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTuanzhanFetchReward)
	-- protocol:EncodeAndSend()
end

-- 乱斗战场人员积分信息
function KuaFuTuanZhanCtrl:OnSCNightFightTotalScoreRank(protocol)
	self.data:SetAllScoreRankInfo(protocol)
end

--返回榜首的位置
function KuaFuTuanZhanCtrl:OnCrossNightFightPlayerPosi(protocol)
	-- 如果第一名是自己
	local is_follow = true
	local info_list = KuaFuTuanZhanData.Instance:GetObjIDInfo() or {}
	local first_side = info_list[protocol.obj_id] and info_list[protocol.obj_id].is_red_side or -1
	local my_side = KuaFuTuanZhanData.Instance:GetRoleInfo().is_red_side

	if protocol.obj_id == Scene.Instance:GetMainRole():GetObjId() then
		SysMsgCtrl.Instance:ErrorRemind(Language.NightFight.YouAreFirst)
		is_follow = false
		GuajiCtrl.Instance:StopGuaji()
	elseif first_side == my_side then
		SysMsgCtrl.Instance:ErrorRemind(Language.NightFight.TheSameSide)
		is_follow = false
		GuajiCtrl.Instance:StopGuaji()
	end
	if is_follow then
		-- self.first_uuid = HotStringChatData.Instance:GetRankInfo().rank_list[1].uuid
		GuajiCtrl.Instance:CancelSelect()
		GuajiCtrl.Instance:ClearAllOperate()
		GuajiCtrl.Instance:StopGuaji()
	
		GuajiCache.monster_id = 0
		MoveCache.param1 = protocol.obj_id
		MoveCache.target_obj = Scene.Instance:GetObj(protocol.obj_id)
		GuajiCache.target_obj = Scene.Instance:GetObj(protocol.obj_id)
		MoveCache.end_type = MoveEndType.AttackTarget

		GuajiCtrl.Instance:OnSelectObj(Scene.Instance:GetObj(protocol.obj_id))
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), protocol.pos_x, protocol.pos_y, 3, 1)
	end
end

--请求榜首的信息
function KuaFuTuanZhanCtrl:SendFirstPos(opera_type, param1)
	self:SendFirstPosReq(opera_type, param1)
end

function KuaFuTuanZhanCtrl:SendFirstPosReq(opera_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNightFightEnterReq)
	protocol.opera_type = opera_type or 1
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

function KuaFuTuanZhanCtrl:OpenBattleAllReward()
	if self.tuanzhan_round_reward_view then
		self.tuanzhan_round_reward_view:Open()
		self.tuanzhan_round_reward_view:Flush()
	end
end


---------------合G21----- 跨服夜战云巅-----END-----------

----------------------- 跨服团战-------------------------

function KuaFuTuanZhanCtrl:SendGetCrossTuanzhanReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTuanzhanFetchReward)
	protocol:EncodeAndSend()
end

-- 比赛状态通知
function KuaFuTuanZhanCtrl:OnCrossTuanzhanStateNotify(protocol)
	self.data:SetActivityData(protocol)
	self.task_view:Flush("switch_time")
end

-- 玩家信息
function KuaFuTuanZhanCtrl:OnCrossTuanzhanPlayerInfo(protocol)
	if 1 == protocol.is_broacast then
		local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
		if nil ~= scene_obj and scene_obj:IsRole() then
			scene_obj:SetAttr("special_param", protocol.side * 10000 + protocol.kill_num)
			if scene_obj:IsMainRole() then
				self.data:SetPlayerInfo(protocol)
				self.task_view:Flush("personal")
			end
		end
	else
		Scene.Instance:GetMainRole():SetAttr("special_param", protocol.side * 10000 + protocol.kill_num)
		self.data:SetPlayerInfo(protocol)
		self.task_view:Flush("personal")
	end
end

-- 排名信息
function KuaFuTuanZhanCtrl:OnCrossTuanzhanRankInfo(protocol)
	self.data:SetCrossTuanZhanPlayerInfoScore(protocol)
	self.data:SetRankListInfo(protocol.rank_list)
	self.task_view:Flush("rank")
end

-- 阵营积分信息
function KuaFuTuanZhanCtrl:OnCrossTuanzhanSideInfo(protocol)
	self.data:SetCampInfo(protocol.side_score_list)
	self.task_view:Flush("camp")
end

-- 通天柱子信息
function KuaFuTuanZhanCtrl:OnCrossTuanzhanPillaInfo(protocol)
	self.data:SetPillarInfo(protocol.pilla_list)
	self.task_view:Flush("pillar")
end

-- 连杀信息变更
function KuaFuTuanZhanCtrl:OnCrossTuanzhanPlayerDurKillInfo(protocol)
	local mainrolevo = GameVoManager.Instance:GetMainRoleVo()
	local role = nil
	if mainrolevo.obj_id == protocol.obj_id then
		role = Scene.Instance:GetMainRole()
	else
		role = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	end
	if nil ~= role then
	end
end

-- 比赛结果通知
function KuaFuTuanZhanCtrl:OnCrossTuanzhanResultInfo(protocol)
	ViewManager.Instance:Open(ViewName.KuaFuTuanZhanRankView)
end

----------------------- 跨服团战--------END--------------