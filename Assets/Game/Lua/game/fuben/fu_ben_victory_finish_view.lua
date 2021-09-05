FuBenVictoryFinishView = FuBenVictoryFinishView or BaseClass(BaseView)

function FuBenVictoryFinishView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "VictoryFinishView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = true							-- 是否点击其它地方要关闭界面
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end
	self.leave_time = 0
	self.btn_time = 5
	self.victory_items = {}
end

function FuBenVictoryFinishView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	-- for i = 1, 6 do
	-- 	local item_obj = self.node_list["VItem" .. i]
	-- 	local item_cell = ItemCell.New()
	-- 	item_cell:SetInstanceParent(self.node_list["VItem" .. i])
	-- 	self.victory_items[i] = {item_obj = item_obj, item_cell = item_cell}
	-- end
	self.victory_text = {}
	self.armor_func = nil
end

function FuBenVictoryFinishView:OpenCallBack()
	self.do_not_exit_fb = false
	self.node_list["EnterBtnText" ].text.text = Language.Common.Confirm
	-- self:Flush("finish")
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ExpFb then
		self:GetEndBtnTime()
	end
end

function FuBenVictoryFinishView:GetEndBtnTime(second)
		local diff_time = second or 5
		if self.count_down == nil then
			local function diff_time_func (elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				self.node_list["EnterBtnText" ].text.text = string.format(Language.Common.ConfirmEndTime, left_time)
				if left_time <= 0 then
					self.node_list["EnterBtnText" ].text.text = Language.Common.Confirm
					if self.count_down ~= nil then
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					FuBenCtrl.Instance:SendExitFBReq()
					self:Close()
				end
			end
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 1, diff_time_func)
		end
end

function FuBenVictoryFinishView:ReleaseCallBack()
	for k,v in pairs(self.victory_items) do
		v:DeleteMe()
	end
	self.victory_items = {}
	self.victory_text = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenVictoryFinishView:SetCloseCallBack(callback)
	self.close_callback = callback
end

function FuBenVictoryFinishView:CloseCallBack()
	if self.close_callback then
		self.close_callback()
		self.close_callback = nil
	end
	self.leave_time = 0
	if self.leave_timer then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenVictoryFinishView:OnClickClose()
	local scene_type = Scene.Instance:GetSceneType()
	if not self.do_not_exit_fb and scene_type ~= SceneType.QingYuanFB then
		-- if scene_type == SceneType.RuneTower then
		-- 	FuBenCtrl.Instance:SendEnterNextFBReq()
		-- else
			FuBenCtrl.Instance:SendExitFBReq()
		-- end
	end
	if scene_type == SceneType.PhaseFb or scene_type == SceneType.ExpFb then
		FuBenCtrl.Instance:SendExitFBReq()
		self:Close()
		return
	end
	if self.armor_func then
		self.armor_func()
		self:Close()
	else
		self:Close()
	end

		
end

function FuBenVictoryFinishView:OnFlush(param_t)
	self.node_list["ExpItems"]:SetActive(false)
	self.node_list["Frame"]:SetActive(false)
	self.node_list["Frame2"]:SetActive(false)
	self.node_list["Frame3"]:SetActive(false)
	for k, v in pairs(param_t) do
		if k == "finish" or k == "reward" then
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end

			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime()
			self:SetCloseCallBack(v.close_callback)
			if k == "reward" then
				self.do_not_exit_fb = true
			end
		elseif k == "finishout" then
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end

			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime(10)
			self:SetCloseCallBack(v.close_callback)
		elseif k == "expfinish" then
			self:FulshExpFinish(v.data)
			self.node_list["ExpItems"]:SetActive(true)
			self:GetEndBtnTime()
		elseif k == "expexip" then
			self:FulshExpFinish(v.data)
			self.node_list["ExpItems"]:SetActive(true)
			self:GetEndBtnTime(10)
		elseif k == "qingyuanfb" then							--情缘副本双倍经验按钮
			local fb_info = MarriageData.Instance:GetQingYuanFB()
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

			if not next(fb_info) then return end
			
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end

			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end

			self:SetCloseCallBack(v.close_callback)

			self.node_list["Tworeward"]:SetActive(true)
			self.node_list["Tworeward"].button:AddClickListener(function ()
				local cfg = MarriageData.Instance:GetMarriageConditions()
				local gold_need = cfg ~= nil and cfg.lover_fb_double_reward_need_gold or 0
				local function ok_callback()
					MarriageCtrl.Instance:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BUY_DOUBLE_REWARD)
					local gold_num = PlayerData.Instance.role_vo["gold"] or 0
					if gold_num < gold_need then
						TipsCtrl.Instance:ShowLackDiamondView()
						-- UI:SetButtonEnabled(self.node_list["Tworeward"], false)
						return
					end
					-- UI:SetButtonEnabled(self.node_list["Tworeward"], false)
					for k1,v1 in pairs(v.data) do
						v1.num = v1.num * 2
					end
					for i = 1, #v.data do
						if i <= 8 then
							if self.victory_items and self.victory_items[i] then
								self.victory_items[i]:SetData(v.data[i])
							end
						end
					end
					self.node_list["Tworeward"]:SetActive(false)
					self.node_list["Double"]:SetActive(true)
				end
				local des = string.format(Language.Common.CostGoldBuyTip, gold_need)
				TipsCtrl.Instance:ShowCommonAutoView("qing_yuan_fuben", des, ok_callback)
			end)
			if fb_info.male_is_buy == 1 and main_role_vo.sex == 1 then
				-- UI:SetButtonEnabled(self.node_list["Tworeward"], false)
				self.node_list["Tworeward"]:SetActive(false)
				self.node_list["Double"]:SetActive(true)
			elseif fb_info.female_is_buy == 1 and main_role_vo.sex == 0 then
				-- UI:SetButtonEnabled(self.node_list["Tworeward"], false)
				self.node_list["Tworeward"]:SetActive(false)
				self.node_list["Double"]:SetActive(true)
			else
				-- UI:SetButtonEnabled(self.node_list["Tworeward"], true)
				self.node_list["Tworeward"]:SetActive(true)
				self.node_list["Double"]:SetActive(false)
			end
		elseif k == "armor_result" then
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end
			self.node_list["Frame"]:SetActive(true)
			if v.time then
				self.node_list["TxtTime"].text.text = v.time
			end
			if v.num then
				self.node_list["TxtNum"].text.text = v.num
			end
			if v.func then
				self.armor_func = v.func
			end
			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime()
		elseif k == "team_result" then
			self.node_list["Frame2"]:SetActive(true)
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end
			if v.time then
				self.node_list["TxtTeam"].text.text = v.time
			end
			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime()
		elseif k == "no_result" then
			self.node_list["Frame3"]:SetActive(true)
			self.node_list["Items"]:SetActive(false)
			if v.time then
				self.node_list["TxtTime3"].text.text = v.time
			end
			self:GetEndBtnTime(10)
		elseif k == "team_reward_result" then
			for i = 1, #v.data do
				if i <= 8 then
					self.node_list["VItem" .. i]:SetActive(false)
				end
			end
			self.node_list["Items"]:SetActive(true)
			if v.data ~= nil then
				for i = 1, #v.data do
					if i <= 8 then
						local item_cell = ItemCell.New()
						item_cell:SetInstanceParent(self.node_list["VItem" .. i])
						self.node_list["VItem" .. i]:SetActive(true)
						item_cell:SetData(v.data[i])
						self.victory_items[i] = item_cell
					end
				end
			end
		end
	end
end

function FuBenVictoryFinishView:LeaveUpdate()
	if self.leave_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	else
		self.leave_time = self.leave_time - 0.3
	end
	if self.victory_items[self.index] then
		self.victory_items[self.index]:SetParentActive(true)
		self:PlayEffect(self.index)
		self.index = self.index + 1
	end
end

function FuBenVictoryFinishView:FulshExpFinish(data)
	if data == nil or data == "" then return end

	-- self.node_list["TextVictory"].text.text = string.format(Language.DailyTaskFb.GetExpText, CommonDataManager.ConverNum(data[1]))
	self.node_list["TextVictory"].text.text = CommonDataManager.ConverNum(data[1])
	self.node_list["TextKillNum"].text.text = string.format(Language.DailyTaskFb.KillMonster, data[2])
	self.node_list["TextRecord"].text.text = data[3]
	self.node_list["Record"]:SetActive(data[3] > 0)
	self.node_list["ImgRecord"]:SetActive(data[3] > 0)
	if data[3] <= 0 then
		local pos = self.node_list["ExpItems"].transform.position
		self.node_list["ExpItems"].transform.position = Vector3(pos.x + 6, pos.y, pos.z)
	end
end

function FuBenVictoryFinishView:PlayEffect(index)
	local canvas = self.node_list["VItem" .. index].transform:GetComponentInParent(typeof(UnityEngine.Canvas))
	if canvas == nil then return end
	
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
	EffectManager.Instance:PlayAtTransform(
		bundle_name,
		asset_name,
		self.node_list["VItem" .. index].transform,
		1.0,Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(0.5, 0.5, 0.5))
end