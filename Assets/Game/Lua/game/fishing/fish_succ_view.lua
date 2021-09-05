-- CrossFishingView = CrossFishingView or BaseClass(BaseView)

function CrossFishingView:InitFishSucc()
	self.succ_panel_count_down = nil

	self.check_event_result_type = 0			-- 如果是宝箱才使用1 其他全部是0不赠送
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function CrossFishingView:DeleteFishSucc()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.icon_time_quest then
		GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	end
	self.icon_time_quest = nil
end

function CrossFishingView:FlushFishSucc()
	local result_info = CrossFishingData.Instance:GetFishingCheckEventResult()

	if result_info.event_type ~= FISHING_EVENT_TYPE.EVENT_TYPE_NOTICE then
		self:ReleaseTimer()
		self.check_event_result_type = result_info.event_type
		local result_image = ""
		local event_image = ""
		-- local auto_fish = CrossFishingData.Instance:GetAutoFishing()
		if result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_GET_FISH then					--钓鱼
			-- self.is_open_fish_succ = true
			local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(result_info.param1)
			if fish_cfg then
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				local score_num = fish_cfg.score * result_info.param2
				-- if self.node_list["TxtFishSucc"] then
				-- 	self.node_list["TxtFishSucc"].text.text = string.format(Language.Fishing.LabelFishSucc, result_info.param2, fish_cfg.name, score_num)
				if result_info.param1 >= 4 then
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelFishingXiYou, main_role_vo.name, fish_cfg.name))
				end

				-- if auto_fish == 1 then
				-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.AutoFish[1], result_info.param2, fish_cfg.name))
				-- 	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT, self.check_event_result_type)
				-- 	return
				-- end
				-- result_image = "fish_" .. result_info.param1
				-- -- local bundle, asset = ResPath.GetFishingRes(result_image)
				-- local bundle, asset = ResPath.GetFishingRes(result_image)
				-- self.node_list["ImgFish"].image:LoadSprite(bundle, asset, function()
				-- 	self.node_list["ImgFish"].image:SetNativeSize()
				-- end) 
				-- self.node_list["ImgFish"]:SetActive(true)
				-- self.node_list["ItemCell"]:SetActive(false)
				FishingCtrl.Instance:ShowTipsFishSuccView(result_info.param1, result_info.param2)
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelFishSucc, result_info.param2, fish_cfg.name, score_num))
				-- end
			end

			--没有鱼事件
			local fishing_status = CrossFishingData.Instance:GetAutoFishing()
			if 0 == result_info.param_1 and 1 == fishing_status then
				FishingCtrl.Instance:SendFishing(0)
			end
			-- self.node_list["PanelReward"]:SetActive(true)

		elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUWANG or
		 result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUCHA 
		 or result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_OIL then					--钓法宝
		 	self:CloseEventPanel()
		 -- 	self.node_list["ImgFisher"]:SetActive(true)
		 -- 	self.node_list["ImgQiPao"]:SetActive(true)
			-- self.node_list["TxtEvent2"].text.text = string.format(Language.Fishing.LabelGetGear, result_info.param2, Language.Fishing.LabelGear[result_info.param1])
			-- event_image = "gear_" .. result_info.param1

			-- local data = CrossFishingData.Instance:GetFishingOtherCfg()
			-- if nil == data then
			-- 	self.node_list["TxtEvent1"].text.text = ""
			-- else
			-- 	self.node_list["TxtEvent1"].text.text = data.fisher_text
			-- end
			-- local bundle, asset = ResPath.GetFishingRes(event_image)
			-- self.node_list["ImgEvent"].image:LoadSprite(bundle, asset)
			-- if auto_fish == 1 then
			-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.AutoFish[2], Language.Fishing.LabelGear[result_info.param1]))
			-- 	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT, self.check_event_result_type)
			-- 	return
			-- end
			self:SetEventCountDonw()
			if result_info.param1 ~= 2 then
				FishingCtrl.Instance:ShowTipsFishSuccView(nil, 0, true)
			else
				FishingCtrl.Instance:ShowTipsFishSuccView(nil, 0, true, nil, nil, nil, true)
			end
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelGetGear, result_info.param2, Language.Fishing.LabelGear[result_info.param1]))
		elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_ROBBER then					--钓强盗
			self:CloseEventPanel()
			-- self.node_list["ImgRobber"]:SetActive(true)
			-- self.node_list["ImgQiPao"]:SetActive(true)
			local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(result_info.param1)
			if fish_cfg then
			-- if fish_cfg then 
			-- 	self.node_list["TxtEvent2"].text.text = string.format(Language.Fishing.LabelRobber, result_info.param2, fish_cfg.name)
			-- 	self.node_list["ImgEvent"]:SetActive(true)
			-- 	event_image = "fish_" .. result_info.param1
			-- else
			-- 	self.node_list["ImgEvent"]:SetActive(false)
			-- 	self.node_list["TxtEvent2"].text.text = Language.Fishing.LabelRobberFaiure
			-- end
			
			-- local data = CrossFishingData.Instance:GetFishingOtherCfg()
			-- if nil ~= fish_cfg and nil ~= data then
			-- 	self.node_list["TxtEvent1"].text.text = data.robber_text
			-- else
			-- 	self.node_list["TxtEvent1"].text.text = ""
			-- end
			
			-- local bundle, asset = ResPath.GetFishingRes(event_image)

			-- self.node_list["ImgEvent"].image:LoadSprite(bundle, asset)
				-- if auto_fish == 1 then
				-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.AutoFish[3], result_info.param2, fish_cfg.name))
				-- 	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT, self.check_event_result_type)
				-- 	return
				-- end
				self:SetEventCountDonw()
				FishingCtrl.Instance:ShowTipsFishSuccView(nil, 0, false, true)
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelRobber, result_info.param2, fish_cfg.name))
			end
		end

		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT, self.check_event_result_type)
		-- 设置倒计时关闭面板
		self:SetCloseSuccTime()
	else
		local is_pass_time = CrossFishingData.Instance:GetIsPassTime()
		if is_pass_time then
			CrossFishingData.Instance:SetIsPassTime(false)
			self.node_list["RemindTips"]:SetActive(result_info.param1 == 1)
			if self.show_delay_timer then
				GlobalTimerQuest:CancelQuest(self.show_delay_timer)
				self.show_delay_timer = nil
			end
			if nil == self.show_delay_timer then
				self.show_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
					self.node_list["RemindTips"]:SetActive(false)
				end,3)
			end

			if self.pass_delay_timer then
				GlobalTimerQuest:CancelQuest(self.pass_delay_timer)
				self.pass_delay_timer = nil
			end
			if nil == self.pass_delay_timer then
				self.pass_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
					CrossFishingData.Instance:SetIsPassTime(true)
					if self.pass_delay_timer then
						GlobalTimerQuest:CancelQuest(self.pass_delay_timer)
						self.pass_delay_timer = nil
					end
				end,10)
			end
		end
	end
end

function CrossFishingView:FlushFishSteal()
	local steal_result = CrossFishingData.Instance:GetFishingStealResult()
	self:ReleaseTimer()
	-- self.icon_time_quest = GlobalTimerQuest:AddDelayTimer(function()
	-- 	self.node_list["PanelReward"]:SetActive(true)
	-- end, 0.5)
	if steal_result then
		-- local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(steal_result.fish_type)
		-- if fish_cfg then
		-- 	local score_num = fish_cfg.score * steal_result.fish_num
		-- 	if self.node_list["TxtFishSucc"] then
		-- 		if steal_result.is_succ == 1 then
		-- 			self.node_list["TxtFishSucc"].text.text = string.format(Language.Fishing.LabelFishSteal, steal_result.fish_num, fish_cfg.name, score_num)
		-- 		end
		-- 	end
		-- end

		-- if self.node_list["ImgFish"].image then
		-- 	local bundle, asset = ResPath.GetFishingRes("fish_" .. steal_result.fish_type)
		-- 	-- local bundle, asset = ResPath.GetFishingRes("fish_" .. steal_result.fish_type)
		-- 	self.node_list["ImgFish"]:SetActive(true)
		-- 	self.node_list["ImgFish"].image:LoadSprite(bundle, asset, function()
		-- 		self.node_list["ImgFish"].image:SetNativeSize()
		-- 	end)
		-- end

		FishingCtrl.Instance:ShowTipsFishSuccView(steal_result.fish_type, steal_result.fish_num, nil, nil,nil, true)
	end

	self:SetCloseSuccTime()
end

function CrossFishingView:FlushUseGear()
	local use_gear_info = CrossFishingData.Instance:GetFishingGearUseResult()
	local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(use_gear_info.param1)
	self:SetCloseSuccTime()
	if fish_cfg then
		if self.node_list["TxtFishSucc"] then
			if use_gear_info.gear_type == FISHING_GEAR.FISHING_GEAR_OIL then
				self.node_list["PanelReward"]:SetActive(true)
				self.node_list["TxtFishSucc"].text.text = Language.Fishing.LabelUseOil
				if self.node_list["ImgFish"].image then
					local bundle, asset = ResPath.GetFishingRes("gear_2")
					self.node_list["ImgFish"]:SetActive(true)
					self.node_list["ImgFish"].image:LoadSprite(bundle, asset)
				end
				return
			-- else
			-- 	self.node_list["TxtFishSucc"].text.text = string.format(Language.Fishing.LabelUseGear, Language.Fishing.LabelGear[use_gear_info.gear_type], use_gear_info.param2, fish_cfg.name)
			end
		end
	end
	-- if self.node_list["ImgFish"].image then
	-- 	local bundle, asset = ResPath.GetFishingRes("fish_" .. use_gear_info.param1)
	-- 	self.node_list["ImgFish"]:SetActive(true)
	-- 	self.node_list["ImgFish"].image:LoadSprite(bundle, asset, function()
	-- 		self.node_list["ImgFish"].image:SetNativeSize()
	-- 	end)
	-- end
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelUseGear, Language.Fishing.LabelGear[use_gear_info.gear_type], use_gear_info.param2, fish_cfg.name))
	FishingCtrl.Instance:ShowTipsFishSuccView(use_gear_info.param1, use_gear_info.param2)
end

function CrossFishingView:FlushFishResult()
	local cofirm_result = CrossFishingData.Instance:GetFishingConfirmResult()
	if cofirm_result.confirm_type == FISHING_EVENT_TYPE.EVENT_TYPE_TREASURE then				--钓宝箱
		local name = ItemData.Instance:GetItemName(cofirm_result.short_param_1)
		-- local auto_fish = CrossFishingData.Instance:GetAutoFishing()
		-- if self.node_list["TxtFishSucc"] then
		-- 	local name = ItemData.Instance:GetItemName(cofirm_result.short_param_1)
		-- 	self.node_list["TxtFishSucc"].text.text = string.format(Language.Fishing.LabelOldBox, name, cofirm_result.param_2)
		-- end
		-- self.item_cell:SetData({item_id = cofirm_result.short_param_1, num = cofirm_result.param_2, is_bind = cofirm_result.param_3})
		-- self.node_list["ImgFish"]:SetActive(false)
		-- self.node_list["ItemCell"]:SetActive(true)
		-- self.node_list["PanelReward"]:SetActive(true)
		-- if auto_fish == 1 then
		-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.AutoFish[4], name, cofirm_result.param_2))
		-- 	return
		-- end
		FishingCtrl.Instance:ShowTipsFishSuccView(nil, 0, false, false, true)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelOldBox, name, cofirm_result.param_2))
	end
end

-- 刷新前释放计时器，奖励面板置为不显示
function CrossFishingView:ReleaseTimer()
	if self.icon_time_quest then
		GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	end
	self.icon_time_quest = nil
	self.node_list["PanelReward"]:SetActive(false)
	self.node_list["ItemCell"]:SetActive(false)
end

function CrossFishingView:CloseEventPanel()
	self.node_list["ImgFisher"]:SetActive(false)
	self.node_list["ImgRobber"]:SetActive(false)
	self.node_list["ImgQiPao"]:SetActive(false)
end

function CrossFishingView:SetEventCountDonw()
	self:RemoveEventCountDown()

	local total_time = 8
	local event = function(elapse_time, total_time)
		local left_time = math.floor(total_time - elapse_time + 0.5)
		if left_time <= 0 then
			self:CloseEventPanel()
			CountDown.Instance:RemoveCountDown(self.succ_event_count_down)
			self.succ_event_count_down = nil
			return
		end
	end

	event(0, total_time)
	self.succ_event_count_down = CountDown.Instance:AddCountDown(total_time, 0.5, event)
end

function CrossFishingView:RemoveEventCountDown()
	if self.succ_event_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.succ_event_count_down)
		self.succ_event_count_down = nil
	end
end

-- 设置关闭成功界面倒计时
function CrossFishingView:SetCloseSuccTime()
	if self.succ_panel_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.succ_panel_count_down)
		self.succ_panel_count_down = nil
	end

	if self.succ_panel_count_down == nil then
		local count_down_time = 2
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(count_down_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["PanelReward"]:SetActive(false)
				self.node_list["ItemCell"]:SetActive(false)
				local auto_fish = CrossFishingData.Instance:GetAutoFishing()
				if auto_fish == 1 then
					ViewManager.Instance:Close(ViewName.TipsFishingSuccView)
				end
				if self.succ_panel_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.succ_panel_count_down)
					self.succ_panel_count_down = nil
				end
				return
			end
		end

		diff_time_func(0, count_down_time)
		self.succ_panel_count_down = CountDown.Instance:AddCountDown(count_down_time, 0.5, diff_time_func)
	end
end