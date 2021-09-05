require("game/element_battle/element_battle_data")
require("game/element_battle/element_battle_fight_view")

ElementBattleCtrl = ElementBattleCtrl or  BaseClass(BaseController)

function ElementBattleCtrl:__init()
	if ElementBattleCtrl.Instance ~= nil then
		print_error("[ElementBattleCtrl] attempt to create singleton twice!")
		return
	end
	ElementBattleCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = ElementBattleData.New()
	self.element_fight_veiw = ElementBattleFightView.New(ViewName.ElementBattleFightView)

	self:BindGlobalEvent(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoChange, self))

end

function ElementBattleCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.element_fight_veiw ~= nil then
		self.element_fight_veiw:DeleteMe()
		self.element_fight_veiw = nil
	end

	ElementBattleCtrl.Instance = nil

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function ElementBattleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQunXianLuanDouUserInfo, "OnQunXianLuanDouUserInfo")
	self:RegisterProtocol(SCQunXianLuanDouRankInfo, "OnQunXianLuanDouRankInfo")
	self:RegisterProtocol(SCQunXianLuanDouSideInfo, "OnQunXianLuanDouSideInfo")
	self:RegisterProtocol(SCQunxianluandouLianzhanChange, "OnQunxianluandouLianzhanChange")
end

function ElementBattleCtrl:OnQunXianLuanDouUserInfo(protocol) 			--三界战场 用户信息
	self.data:SetBaseInfo(protocol.data)
	local special_param = ElementBattleData.GetKillToSpecial(protocol.data.side, protocol.data.lianzhan)
	Scene.Instance:GetMainRole():SetAttr("special_param", special_param)
	self.element_fight_veiw:Flush("info")
	-- 结束
	if protocol.data.notify_reason ~= QUNXIANLUANDOU_NOTIFY_REASON.REASON_DEFAULT then
		local flag = protocol.data.notify_reason == QUNXIANLUANDOU_NOTIFY_REASON.REASON_WIN and 1 or 0
		local score = ElementBattleData.Instance:GetRoleScore() or 0
		local rewards = ElementBattleData.Instance:GetFinishReward(score, flag) or {}
		self.temp_list = {reward_list = {}}
		for i = 1, 5 do
			local item = rewards.reward_item[i]
			if item and item.item_id > 0 then
				table.insert(self.temp_list.reward_list, item)
			end
		end

		if not ViewManager.Instance:IsOpen(ViewName.BeherrscherShowView) then
			ViewManager.Instance:Open(ViewName.BeherrscherShowView)
			GuajiCtrl.SetMoveValid(false)
			GuajiCtrl.SetAtkValid(false)
			Scene.Instance:GetMainRole():StopMove()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end

		if Scene.Instance:GetMainRole():IsDead() then
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
		end


		self.is_create_list = true
		self.end_count = 0
		self.role_list = {}
		self.end_complete_list = {}

		self.cur_count = protocol.cur_count
		self.data:SetFirstRankUidList(protocol.first_rank_uid)
		if self.cur_count > 0 then
			for i,v in ipairs(protocol.first_rank_uid) do
				if v > 0 then
					CheckCtrl.Instance:SendQueryRoleInfoReq(v)
				end
			end
		else
			self.element_fight_veiw:SetBaiYeDownTime()
			self.element_fight_veiw:Flush("bai_ye")
			self.element_fight_veiw:SetRemindBubbleActive()
		end
		
		
		-- if self.delay_timer then
		-- 	GlobalTimerQuest:CancelQuest(self.delay_timer)
		-- 	self.delay_timer = nil
		-- end

		-- self.delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		-- 	if ViewManager.Instance:IsOpen(ViewName.BeherrscherShowView) then
		-- 		ViewManager.Instance:Close(ViewName.BeherrscherShowView)
		-- 	end
		-- 	if Scene.Instance:GetSceneId() == 1201 then -- 判断是否在三界争锋场景
		-- 		self:ExitSceneReq()
		-- 	end
		-- end, 10)
	end
end

function ElementBattleCtrl:GetIsBaiYe()
	if self.element_fight_veiw then
		return self.element_fight_veiw:GetIsBaiYe()
	end
	return false
end

function ElementBattleCtrl:RoleInfoChange(role_id, role_info)
	if self.is_create_list then
		self.first_rank_uid_list = ElementBattleData.Instance:GetFirstRankUidList()
		local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.QUNXIANLUANDOU)

		for i,v in ipairs(self.first_rank_uid_list) do
			if nil == self.role_list[i] and v > 0 and v == role_id then
				self.role_list[i] = TipsData.Instance:GetBorrowVo(role_info)
				if bai_ye_cfg then
					self.role_list[i].pos_x = bai_ye_cfg["statue_pos_x" .. i] or 0
					self.role_list[i].pos_y = bai_ye_cfg["statue_pos_y" .. i] or 0
				end
				self.end_count = self.end_count + 1
			end
		end
		if self.end_count >= self.cur_count then
			self.is_create_list = false
			Scene.Instance:CreateCgObj(self.role_list, function(index)
				if nil == self.end_complete_list[index] then
					self.end_complete_list[index] = index
				end
				if #self.end_complete_list >= #self.role_list then
					Scene.Instance:ClearUnuseCgObj()
					Scene.Instance:ResetCgObjListPos()

					self.role_list = {}
					self.end_complete_list = {}
					self.end_count = 0
					self.element_fight_veiw:SetBaiYeDownTime()
					self.element_fight_veiw:Flush("bai_ye")
					self.element_fight_veiw:SetRemindBubbleActive()
				end
			end)
		end
	end
end

function ElementBattleCtrl:OnQunXianLuanDouRankInfo(protocol) 			--三界战场 排行榜信息
	self.data:SetRankInfo(protocol.data)
	self.element_fight_veiw:Flush("rank")
end

function ElementBattleCtrl:OnQunXianLuanDouSideInfo(protocol) 			--三界战场 阵营信息
	self.data:SetSideInfo(protocol.data)
	self.element_fight_veiw:Flush("info")
end

function ElementBattleCtrl:OnQunxianluandouLianzhanChange(protocol) 		--
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= obj then
		local side = ElementBattleData.GetSpecialToSide(obj:GetVo().special_param)
		obj:SetAttr("special_param", ElementBattleData.GetKillToSpecial(side, protocol.lianzhan))
	end
end

function ElementBattleCtrl:ExitSceneReq()
	FuBenCtrl.Instance:SendExitFBReq()
	if self.temp_list then
		TipsCtrl.Instance:OpenActivityRewardTip(self.temp_list)
	end
end

function ElementBattleCtrl:FlushByYeView()
	if self.element_fight_veiw then
		self.element_fight_veiw:Flush("bai_ye")
	end
end