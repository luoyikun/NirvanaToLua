require("game/kuafu_liujie_battle/kuafu_liujie_data")
require("game/kuafu_liujie_battle/kuafu_liujie_view")
require("game/kuafu_liujie_battle/kuafu_liujie_scene_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view")
require("game/kuafu_liujie_battle/kuafu_liujie_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view_2")
require("game/kuafu_liujie_battle/kuafu_task_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_tips_reward_view")
require("game/kuafu_liujie_battle/kuafu_liujie_pre_view")
require("game/kuafu_liujie_battle/kuafu_liujie_battle_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_tj_fight_view")
require("game/kuafu_liujie_battle/kuafu_liujie_sw_fight_view")
require("game/kuafu_liujie_battle/kuafu_liujie_collect_taxes_view")
require("game/kuafu_liujie_battle/lianfuduocheng_first_view")

KuafuGuildBattleCtrl = KuafuGuildBattleCtrl or BaseClass(BaseController)

function KuafuGuildBattleCtrl:__init()
	if KuafuGuildBattleCtrl.Instance ~= nil then
		print_error("[KuafuGuildBattleCtrl] Attemp to create a singleton twice !")
	end
	KuafuGuildBattleCtrl.Instance = self

	self.view = KuafuGuildBattleView.New(ViewName.KuaFuBattle)
	self.first_view = LianFuDuoChengFirstView.New(ViewName.LianFuDuoChengFirstView)
	self.data = KuafuGuildBattleData.New()

	self.scene_panle = KuafuGuildBattleScenePanle.New(ViewName.KuaFuFightView)
	self.rank_view = KuafuTaskFollowView.New(ViewName.KuafuTaskView)
	self.rank_view_2 = KuafuGuildTaskDailyView.New(ViewName.DailyTaskView)
	self.record_view = KuafuGuildRecordView.New(ViewName.KuaFuRecordView)
	self.taxes_view = KuafuGuildCollectTaxesView.New(ViewName.KuafuGuildCollectTaxesView)

	self.task_record_view = KuafuTaskRecordView.New(ViewName.KuafuTaskRecordView)
	-- self.battle_record_view = KuafuGuildBattleRecordView.New(ViewName.KuafuTaskBattleRecordView)
	-- self.kuafu_liujie_tips = TipKfLiujieReward.New(ViewName.TipKfLiujieReward)
	self.pre_view = KuafuLiujiePreView.New(ViewName.KuaFuLiuJiePre)
	self.kuafu_boss_tj_view = KuaFuBossTjFightView.New(ViewName.KuaFuBossTjFightView)
	self.kuafu_boss_sw_view = KuaFuBossSwFightView.New(ViewName.KuaFuBossSwFightView)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:RegisterAllProtocols()
	self.remind_timestamp = 0
	self.kf_guild_battle_act_status = 0

	self:BindGlobalEvent(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoChange, self))
end

function KuafuGuildBattleCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	
	if self.first_view then
		self.first_view:DeleteMe()
		self.first_view = nil
	end
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.taxes_view then
		self.taxes_view:DeleteMe()
		self.taxes_view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.rank_view_2 then
		self.rank_view_2:DeleteMe()
		self.rank_view_2 = nil
	end

	if self.task_record_view then
		self.task_record_view:DeleteMe()
		self.task_record_view = nil
	end

	if self.battle_record_view then
		self.battle_record_view:DeleteMe()
		self.battle_record_view = nil
	end

	if self.record_view then
		self.record_view:DeleteMe()
		self.record_view = nil
	end

	if self.record_view then
		self.record_view:DeleteMe()
		self.record_view = nil
	end

	if self.scene_panle then
		self.scene_panle:DeleteMe()
		self.scene_panle = nil
	end

	if self.kuafu_boss_tj_view then
		self.kuafu_boss_tj_view:DeleteMe()
		self.kuafu_boss_tj_view = nil
	end

	if self.kuafu_boss_sw_view then
		self.kuafu_boss_sw_view:DeleteMe()
		self.kuafu_boss_sw_view = nil
	end

	KuafuGuildBattleCtrl.Instance = nil
	GlobalEventSystem:UnBind(self.main_ui_open)
	if self.remind_boss then
		GlobalTimerQuest:CancelQuest(self.remind_boss)
		self.remind_boss = nil
	end
	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)

	if self.clear_info_quest then
		GlobalTimerQuest:CancelQuest(self.clear_info_quest)
		self.clear_info_quest = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function KuafuGuildBattleCtrl:RemindBoss()
	local is_remind_time, time_index = self.data:IsInRemindTime()
	local open_level = OpenFunData.Instance:GetKuaFuBattleOpenLevel()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local scene_id = KuafuGuildBattleData.Instance:GetSceneIdByIndex()
	if is_remind_time and time_index ~= self.time_index then

		local call_func = function ()
			local born_x = 0
			local born_y = 0
			local scene_id = Scene.Instance:GetSceneId()
			if self.data:CheckOpen() and not self.data:IsLiuJieScene(scene_id) then
				ViewManager.Instance:Open(ViewName.KuaFuBattle,TabIndex.liujie_bossinfo)
			end
			if self.data:CheckOpen() and self.data:IsLiuJieScene(scene_id) then
				local boss_list = self.data:GetBossList()
				local data = boss_list[1]
				if boss_list then
					for i,v in ipairs(boss_list) do
						if v.scene_id == scene_id then
							data = v
							break
						end
					end
				end
				local list = KuafuGuildBattleData.Instance:GetBossCfg()
				if list then
					for k,v in pairs(list) do
						if v.boss_id == data.boss_id then
							born_x = v.born_x
							born_y = v.born_y
						end
					end
				end
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(scene_id, born_x, born_y, 10, 10)
			end
		end

		local is_show = ActivityData.Instance:GetRealOpenDay(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
		if is_show then
			TipsCtrl.Instance:OpenFocusBossTip(38000, call_func, false, false, false, true, false, false, "kf_battle_pre")
		end
		self.time_index = time_index
	end
end

function KuafuGuildBattleCtrl:ActivityCallBack(activity_type, status)
	if activity_type ~= ACTIVITY_TYPE.KF_GUILDBATTLE then
		return
	end

	if activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
		if nil ~= self.baite_complete_timer then
			GlobalTimerQuest:CancelQuest(self.baite_complete_timer)
			self.baite_complete_timer = nil
		end

		-- 这里会来很多次，不满足条件时，把拜谒面板刷隐藏掉
		if self.kf_guild_battle_act_status ~= ACTIVITY_STATUS.CLOSE 
			and status == ACTIVITY_STATUS.CLOSE 
			and not CrossServerData.Instance:GetIsReqDisconnecting() then
			self:OnBaiYeStart()
			self.baite_complete_timer = GlobalTimerQuest:AddRunQuest(function ()
				self:OnBaiYeComplete()
			end, 180)
		else
			self.rank_view:Flush("bai_ye_not_active")
		end
		self.kf_guild_battle_act_status = status

		-- if status == ACTIVITY_STATUS.CLOSE and not CrossServerData.Instance:GetIsReqDisconnecting() then
		-- 	print_error("=========ActivityCallBack22  ", activity_type, status)
		-- 	self:OnBaiYeStart()
		-- 	self.baite_complete_timer = GlobalTimerQuest:AddRunQuest(function ()
		-- 		self:OnBaiYeComplete()
		-- 	end, 180)
		-- end
	end

	local scene_id = Scene.Instance:GetSceneId()
	if KuafuGuildBattleData.Instance:IsLiuJieScene(scene_id) then
		self:CloseRankPanle()	
		self:OpenRankPanle()
	else
		self.if_baiye_ing = false
		self:CloseRankPanle()
	end

	if status == ACTIVITY_STATUS.CLOSE then
		if self.scene_panle:IsOpen() then
			self.scene_panle:Flush("clear")
		end
	end

	self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
end

function KuafuGuildBattleCtrl:RegisterAllProtocols()

	self:RegisterProtocol(SCCrossGuildBattleInfo, "OnCrossGuildBattleInfo")
	self:RegisterProtocol(SCCrossGuildBattleNotifyInfo, "OnCrossGuildBattleNotifyInfo")
	self:RegisterProtocol(SCCrossGuildBattleSceneInfo, "OnCrossGuildBattleSceneInfo")
	self:RegisterProtocol(SCCrossGuildBattleGetRankInfoResp, "OnCrossGuildBattleRankInfoResp")
	self:RegisterProtocol(SCCrossGuildBattleTaskInfo, "SCCrossGuildBattleTaskInfo")
	-- self:RegisterProtocol(SCMonsterGeneraterList, "SCMonsterGeneraterList")
	self:RegisterProtocol(SCCrossGuildBattleBossInfo, "SCCrossGuildBattleBossInfo")
	self:RegisterProtocol(SCCrossGuildBattleDropLog, "SCCrossGuildBattleDropLog")
	self:RegisterProtocol(SCCrossGuildBattleGetMonsterInfoResp, "SCCrossGuildBattleGetMonsterInfoResp")
	self:RegisterProtocol(SCCrossGuildBattleFlagInfo, "OnCrossGuildBattleFlagInfo")
	self:RegisterProtocol(SCCrossGuildBattleBossHurtInfo, "OnSCCrossGuildBattleBossHurtInfo")
	self:RegisterProtocol(SCCrossGuildBattleSceneGuilderNum, "OnSCCrossGuildBattleSceneGuilderNum")
	self:RegisterProtocol(CSCrossGuildBattleOperate)
	self:RegisterProtocol(CSCrossGuildBattleGetRankInfoReq)

	-- self:RegisterProtocol(CSCrossTianjiangOperatorReq)
	-- self:RegisterProtocol(CSCrossShenwuOperatorReq)
	-- self:RegisterProtocol(SCCrossTianjiangBossInfo, "OnCrossTianjiangBossInfo")
	-- self:RegisterProtocol(SCCrossTianjiangBossStatusInfo, "OnCrossTianjiangBossStatusInfo")
	-- self:RegisterProtocol(SCCrossShenwuBossInfo, "OnCrossShenwuBossInfo")
	-- self:RegisterProtocol(SCCrossShenwuBossStatusInfo, "OnCrossShenwuBossStatusInfo")
	-- self:RegisterProtocol(SCCrossTianjiangBossAngryInfo, "OnTianjiangBossAngryInfo")
	-- self:RegisterProtocol(SCCrossShenwuBossSceneInfo, "OnCrossShenwuBossSceneInfo")

	self:RegisterProtocol(SCCrossGuildBattleSpecialTimeNotice, "SCCrossGuildBattleSpecialTimeNotice")

	self.main_ui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

end


function KuafuGuildBattleCtrl:MainuiOpenCreate()
	self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	self:SendGuildBattleGetMonsterInfoReq()

	if self.remind_boss then
		GlobalTimerQuest:CancelQuest(self.remind_boss)
		self.remind_boss = nil
	end
	self.remind_boss = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.RemindBoss, self), 1)
	RemindManager.Instance:Fire(RemindName.ShowKfBattlePreRemind)
end


function KuafuGuildBattleCtrl:Open()
	self:SendGuildBattleGetRankInfoReq()
	self.view:Open()
end

function KuafuGuildBattleCtrl:OpenScenePanle()
	self.scene_panle:Open()
	self.scene_panle:Flush()
end

function KuafuGuildBattleCtrl:CloseScenePanle()
	self.scene_panle:Close()
end

function KuafuGuildBattleCtrl:GetIsBaiYe()
	if self.rank_view then
		return self.rank_view:GetIsBaiYe()
	end
	return false
end

function KuafuGuildBattleCtrl:OpenRankPanle()
	local active_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE)
	local act_is_ready = ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if active_open or act_is_ready then
		self.rank_view:Open()
	else
		self.need_open_rankview2 = true
		self:TryOpenRankView2()
	end
end

--baiye
--active swithch
function KuafuGuildBattleCtrl:OnBaiYeStart()
	if Scene.Instance:GetMainRole():IsDead() then
		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
		ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	end

	self.if_baiye_ing = true
	CityCombatData.Instance:ClearBaiYeInfo()
	self.rank_view:Flush("bai_ye")
end

function KuafuGuildBattleCtrl:OnBaiYeComplete()
	self.if_baiye_ing = false
	self.rank_view:Close()  --baiye
	self:TryOpenRankView2()
	Scene.Instance:ClearCgObj()	
end

function KuafuGuildBattleCtrl:TryOpenRankView2()
	if not self.if_baiye_ing and self.need_open_rankview2 then
		self.need_open_rankview2 = false
		self.rank_view:Close()  				-- baiye
		self.rank_view_2:Open() 				-- zhumo
	end
end

function KuafuGuildBattleCtrl:CloseRankPanle()
	if not self.if_baiye_ing then
		self.rank_view:Close()  --baiye
	end

	self.rank_view_2:Close()
end

function KuafuGuildBattleCtrl:OpenRecordPanle()
	self:SendGuildBattleGetRankInfoReq()
	self.record_view:Open()
end

function KuafuGuildBattleCtrl:SendGuildBattleGetRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleGetRankInfoReq)
	protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:SendCrossGuildBattleOperateReq(req_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleOperate)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:OnCrossGuildBattleInfo(protocol)
	self.data:SetGuildBattleInfo(protocol)
	self.view:Flush()
	if self.view.show_info_panel then
		self.view.show_info_panel:Flush()
	end

	if self.view.liujie_panel then
		self.view.liujie_panel:Flush()
	end

	if self.taxes_view then
		self.taxes_view:Flush()
	end

	if self.record_view:IsOpen() then
		self.record_view:Flush()
	end

	if self.clear_info_quest then
		GlobalTimerQuest:CancelQuest(self.clear_info_quest)
		self.clear_info_quest = nil
	end

	RemindManager.Instance:Fire(RemindName.ku_guild_battle)
	RemindManager.Instance:Fire(RemindName.ShowKfBattleRemind)
end

function KuafuGuildBattleCtrl:Flush()
	self.view:Flush()
end

function KuafuGuildBattleCtrl:OnCrossGuildBattleNotifyInfo(protocol)
	self.data:SetGuildBattleNotifyInfo(protocol)
	if protocol.notify_type == SC_CROSS_GUILDBATTLE_INFO_TYPE.SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SCORE then
		self.rank_view:Flush()
	end

	if protocol.notify_type == SC_CROSS_GUILDBATTLE_INFO_TYPE.SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SOS then
		local fbi_view = FuBenCtrl.Instance:GetFuBenIconView()
		if fbi_view then
			fbi_view:Flush()
		end
	end
	RemindManager.Instance:Fire(RemindName.ku_guild_battle)
end


function KuafuGuildBattleCtrl:OnCrossGuildBattleSceneInfo(protocol)
	-- self.data:SetGuildBattleSceneInfo(protocol)
	-- self.rank_view:Flush()
	local scene_id = protocol.scene_id
	local now_scene_id = Scene.Instance:GetSceneId()
	if scene_id == now_scene_id then
		self.data:SetGuildBattleSceneInfo(protocol)
		self.rank_view:Flush()
	end
	-- 刷新地图
	self.data:SetGuildBattleSceneMapInfo(protocol)

	if self.scene_panle:IsOpen() then
		self.scene_panle:Flush("occupy")
	end
	for i = 1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE do
		local monster_obj = Scene.Instance:GetMonsterList()[protocol.flag_list[i].monster_id]
		if nil ~= monster_obj then
			monster_obj:ReloadUIName()
		end
	end
end

function KuafuGuildBattleCtrl:OnCrossGuildBattleFlagInfo(protocol)
	-- 刷新地图
	self.data:SetGuildBattleEnterSceneInfo(protocol)
	if self.scene_panle then
		self.scene_panle:Flush("enter")
	end
end

function KuafuGuildBattleCtrl:OnSCCrossGuildBattleBossHurtInfo(protocol)
	if protocol.boss_id ~= 0 then
		self.data:SetGuildHurtRankInfo(protocol)
		self.rank_view_2:FlushRankView()
		local is_show = self.data:GetLiuJieBossHurtShow()
		if is_show then
			self.rank_view_2:SetIsLiuJieBossRange(true)
		end
		self.data:SetLiuJieBossHurtShow(false)
		if self.clear_info_quest then
			GlobalTimerQuest:CancelQuest(self.clear_info_quest)
			self.clear_info_quest = nil
		end

		self.clear_info_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.data:ClearGuildHurtRankInfo()
			self.rank_view_2:FlushRankView()
			self.clear_info_quest = nil
			self.rank_view_2:SetIsLiuJieBossRange(false)
			self.data:SetLiuJieBossHurtShow(true)
			end, 2)
	end
end

function KuafuGuildBattleCtrl:OnSCCrossGuildBattleSceneGuilderNum(protocol)
	self.data:SetCrossGuildBattleSceneGuilderNum(protocol)
	if self.scene_panle then
		self.scene_panle:Flush("menber_num")
	end
end

function KuafuGuildBattleCtrl:OnCrossGuildBattleRankInfoResp(protocol)
	self.info_type = protocol.info_type
	self.data:SetGuildBattleRankInfoResp(protocol)
	self.record_view:Flush()

	if self.info_type == 1 then
		self.show_activity_cg = true
		self.cg_act_list = TableCopy(protocol.cg_list)
		self.cg_count = protocol.count
		self.cg_complete_list = {}
		self.cur_nount = 0
		if self.cg_count > 0 then
			for k,v in pairs(self.cg_act_list) do
				CheckCtrl.Instance:SendCrossQueryRoleInfo(v.plat_type, v.uid)
			end
		else
			self.rank_view:SetBaiYeDownTime()
			self.rank_view:SetRemindBubbleActive()
			self:OpenRecordPanle()
			self.show_activity_cg = false
		end
	end
end

function KuafuGuildBattleCtrl:RoleInfoChange(role_id, role_info)
	if self.show_activity_cg and self.cg_act_list then
		local cg_role_list = KuafuGuildBattleData.Instance:GetCgRoleListData()
		for k,v in pairs(self.cg_act_list) do
			if nil == cg_role_list[k] and v.uid == role_id and role_info.plat_type == v.plat_type then
				cg_role_list[k] = TableCopy(role_info)
				self.cur_nount = self.cur_nount + 1
			end
		end

		if self.cur_nount >= self.cg_count then
			self.show_activity_cg = false
			local cg_bundle = "cg/w3_hd_liujie_zhuchangjing_prefab"
			local cg_asset = "W3_HD_Liujie_zhuchangjing_cg01"

			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.KF_GUILDBATTLE)
			local vo_list = {}
			for i = 1, 6 do
				if nil == cg_role_list[i] then
					vo_list[i] = TipsData.Instance:GetBorrowVo(nil)
				else
					vo_list[i] = TipsData.Instance:GetBorrowVo(cg_role_list[i])
				end

				if bai_ye_cfg then
					vo_list[i].pos_x = bai_ye_cfg["statue_pos_x" .. i] or 0
					vo_list[i].pos_y = bai_ye_cfg["statue_pos_y" .. i] or 0
				end
			end
			Scene.Instance:CreateCgObj(vo_list, function(index)
				if nil == self.cg_complete_list[index] then
					self.cg_complete_list[index] = index
				end
				if #self.cg_complete_list >= #vo_list then
					local scene_id = KuafuGuildBattleData.Instance:GetSceneIdByIndex()
					if not CgManager.Instance:IsCgIng() and EndPlayCgSceneId[Scene.Instance:GetSceneId()] then
						CgManager.Instance:Play(BaseCg.New(cg_bundle, cg_asset), function() 
							if Scene.Instance:GetSceneId() == scene_id then
				                Scene.Instance:ClearUnuseCgObj()
								 Scene.Instance:ResetCgObjListPos()
							else
				                Scene.Instance:ClearCgObj()
							end
							self.cg_act_list = {}
							self.cg_complete_list = {}
							self.cg_count = 0
							self.cur_nount = 0
							self.rank_view:SetBaiYeDownTime()
							self.rank_view:SetRemindBubbleActive()
							self:OpenRecordPanle()
						end)
					end
				end
			end)
		end
	end
end

function KuafuGuildBattleCtrl:FlushCgObjList()
	local cg_role_list = KuafuGuildBattleData.Instance:GetCgRoleListData()
	local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.KF_GUILDBATTLE)
	local vo_list = {}
	for i = 1, 6 do
		if nil == cg_role_list[i] then
			vo_list[i] = TipsData.Instance:GetBorrowVo(nil)
		else
			vo_list[i] = TipsData.Instance:GetBorrowVo(cg_role_list[i])
		end
		if bai_ye_cfg then
			vo_list[i].pos_x = bai_ye_cfg["statue_pos_x" .. i] or 0
			vo_list[i].pos_y = bai_ye_cfg["statue_pos_y" .. i] or 0
		end
	end
	local scene_id = KuafuGuildBattleData.Instance:GetSceneIdByIndex()
	if scene_id and Scene.Instance:GetSceneId() == scene_id and vo_list and next(vo_list) then
		Scene.Instance:CreateCgObj(vo_list, function(index)
			Scene.Instance:ClearUnuseCgObj()
			Scene.Instance:ResetCgObjListPos()
			self.rank_view:SetBaiYeDownTime()
		end)
	end
end

function KuafuGuildBattleCtrl:CheckKfGuildRemind(remind_id)
	local num = self.data:GetKfRewardNum()
	local guild_info = self.data:GetGuildBattleInfo()
	if num > 0 then
		return 1
	end
	for i,v in ipairs(guild_info.kf_battle_list) do
		if self.data:GetIsGuildOwn(v.index) and self.data:GetGuildRewardFlag(v.index) then
			return 1
		end
	end
	return 0
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleTaskInfo(protocol)
	self.data:SetGuildbattleTaskInfo(protocol)
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	self.view:Flush()
	self.task_record_view:Flush()
	self.view:FlushTaskInfoView()
	RemindManager.Instance:Fire(RemindName.ShowKfBattleRemind)
end

-- function KuafuGuildBattleCtrl:SCMonsterGeneraterList(protocol)
-- 	self.data:SetCrossGuildBattleMonsterInfo(protocol)
-- 	self.view:FlushBossInfoView()
-- end

function KuafuGuildBattleCtrl:CSReqMonsterGeneraterList(scene_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqMonsterGeneraterList)
	send_protocol.scene_id = scene_id or Scene.Instance:GetSceneId()
	send_protocol:EncodeAndSend()
end

-- function KuafuGuildBattleCtrl:OpenRewardTip(items,show_gray,ok_callback,show_button, title_id)
-- 	TipsCtrl.Instance.tips_kuafuliujie_reward_view:SetData(items,show_gray,ok_callback,show_button, title_id)
-- 	TipsCtrl.Instance.tips_kuafuliujie_reward_view:Open()
-- end

-- function KuafuGuildBattleCtrl:FlushRewardTip()
-- 	if TipsCtrl.Instance.tips_kuafuliujie_reward_view:IsOpen() then
-- 		TipsCtrl.Instance.tips_kuafuliujie_reward_view:Flush()
-- 	end
-- end

function KuafuGuildBattleCtrl:SCCrossGuildBattleBossInfo(protocol)
	if Scene.Instance:GetSceneType() == SceneType.CrossGuild and 
		protocol.scene_id ~= Scene.Instance:GetSceneId() then
		return
	end
	self.data:SetBossInfo(protocol)
	
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	if self.view.boss_info_panel then
		KuafuGuildBattleCtrl.Instance:SendGuildBattleGetMonsterInfoReq()
		self.view.boss_info_panel:Flush()
	end
end

function KuafuGuildBattleCtrl:GetIsFirstOpenPreView()
	if self.pre_view then
		return self.pre_view.is_first_open
	end
	return 0
end

--------------合w2的神武、天将boss---------------

function KuafuGuildBattleCtrl:SendCrossTianjiangOperatorReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTianjiangOperatorReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

-- 跨服神武boss请求
function KuafuGuildBattleCtrl:SendCrossShenWuOperatorReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossShenwuOperatorReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

--跨服天将boss信息
function KuafuGuildBattleCtrl:OnCrossTianjiangBossInfo(protocol)
	self.data:SetTianJiangBossEnterInfo(protocol.enter_info)
	self.view:Flush("tj_boss")
	RemindManager.Instance:Fire(RemindName.TianjiangRemind)
end

--跨服天将boss状态信息
function KuafuGuildBattleCtrl:OnCrossTianjiangBossStatusInfo(protocol)
	local monster_id, is_flush = self.data:IsTianJiangBossFlush(protocol)
	self.data:SetTianjiangBossStatusInfo(protocol)
	self.view:Flush("tj_boss")
	self.kuafu_boss_tj_view:Flush()

	-- local callback = function()
	-- 	ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_tj_boss)
	-- end

	-- if is_flush and OpenFunData.Instance:CheckIsHide("activity_tj_boss") then
	-- 	-- BossCtrl.Instance:SetOtherBossTips(monster_id, callback, nil, BOSS_ENTER_TYPE.CROSS_TIANJIANG_BOSS)
	-- 	TipsCtrl.Instance:OpenFocusBossTip(protocol.monster_id, callback, false, false, false, true, false, false, "kf_battle_pre")
	-- end
end

function KuafuGuildBattleCtrl:OnTianjiangBossAngryInfo(protocol)
	self.data:SetTianjiangBossAngryInfo(protocol)
	self.view:Flush("tj_boss")
	self.kuafu_boss_tj_view:Flush()
end
--跨服神武boss信息
function KuafuGuildBattleCtrl:OnCrossShenwuBossInfo(protocol)
	self.data:SetShenWuBosswearyInfo(protocol.weary_val_info)
	self.view:Flush("sw_boss")
	RemindManager.Instance:Fire(RemindName.ShenwuRemind)
end

function KuafuGuildBattleCtrl:OnCrossShenwuBossStatusInfo(protocol)
	self.data:SetShenWuBossStatusInfo(protocol)
	self.view:Flush("sw_boss")
	self.kuafu_boss_sw_view:Flush()
end

function KuafuGuildBattleCtrl:OnCrossShenwuBossSceneInfo(protocol)
	self.data:SetShenWuBossEndTime(protocol.act_end_timestamp)
	self.kuafu_boss_sw_view:Flush("exit_time")
end

function KuafuGuildBattleCtrl:FoucsSwBoss(protocol)
	local weary_info = self.data:GetShenWuBosswearyInfo()
	local other_cfg = self.data:GetShenWuBossOther()
	if weary_info and other_cfg and weary_info.weary_val_limit < other_cfg.weary_val_limit then
		local callback = function()
			ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_sw_boss)
		end
		if OpenFunData.Instance:CheckIsHide("activity_sw_boss") then
			TipsCtrl.Instance:OpenFocusBossTip(protocol.monster_id, callback, false, false, false, true, false, false, "kf_battle_pre")
			-- BossCtrl.Instance:SetOtherBossTips(protocol.monster_id, callback, nil, BOSS_ENTER_TYPE.CROSS_SHENWU_BOSS)
		end
	end
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleGetMonsterInfoResp(protocol)
	self.data:SetCrossGuildBattleMonsterInfo(protocol)
	self.view:FlushBossInfoView()
	RemindManager.Instance:Fire(RemindName.ShowKfBattleBossRemind)
end

function KuafuGuildBattleCtrl:FlushMvpName(param_t)
	if self.rank_view then
		self.rank_view:Flush(param_t)
	end
end

--------------合w2的神武、天将boss----END----------------

function KuafuGuildBattleCtrl:SCCrossGuildBattleSpecialTimeNotice(protocol)
	self.data:SetDoubleTimeData(protocol)
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	MainUICtrl.Instance:FlushView("flush_kuafu_liujie")
end

-- 发送查看掉落日志的请求
function KuafuGuildBattleCtrl:SendKuaFuLiuJieLogInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleDropLog)
	protocol:EncodeAndSend()
end

-- 数据下发的时候打开页面
function KuafuGuildBattleCtrl:SCCrossGuildBattleDropLog(protocol)
	self.data:SetKuaFuLiuJieLog(protocol)
	ViewManager.Instance:Open(ViewName.TipsLiuJieLogView)
end

-- 跨服六界精英怪
function KuafuGuildBattleCtrl:SendGuildBattleGetMonsterInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleGetMonsterInfoReq)
	protocol:EncodeAndSend()
end

-- 重置页面选择的旗帜Index
function KuafuGuildBattleCtrl:ResetSelcetedMonsterIndex()
	self.rank_view:ResetCurTaskMonsterID()
end