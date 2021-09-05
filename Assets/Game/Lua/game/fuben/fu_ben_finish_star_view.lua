FuBenFinishStarView = FuBenFinishStarView or BaseClass(BaseView)

function FuBenFinishStarView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "VictoryFinishViewWithStar"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end
	self.leave_time = 0
	self.is_modal = true
	self.is_any_click_close = true
end

function FuBenFinishStarView:LoadCallBack()
	self.root_node:AddComponent(typeof(UnityEngine.CanvasGroup))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.victory_items = {}
	self.effect_items = {}
	for i = 1, 6 do
		local item_obj = self.node_list["VItem" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["VItem"..i])
		self.victory_items[i - 1] = {item_obj = item_obj, item_cell = item_cell}
		self.effect_items[i - 1] = item_cell
	end
	self.star_list = {}
	self.star_num = 0
	self.sure_func = nil
	self.effect_num = 1
end

function FuBenFinishStarView:OpenCallBack()
	self.node_list["EnterBtnText"].text.text = Language.Common.Confirm
	self:Flush("finish")
	self.effect_num = 1
end

function FuBenFinishStarView:ReleaseCallBack()
	for k,v in pairs(self.victory_items) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	for k,v in pairs(self.star_list) do
		v = nil
	end

	if self.star_timer_reqest then
		GlobalTimerQuest:CancelQuest(self.star_timer_reqest)
		self.star_timer_reqest = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.victory_items = {}
	self.victory_text = nil
	self.enter_text = nil
	self.star_num = 0
end

function FuBenFinishStarView:SetCloseCallBack(callback)
	self.close_callback = callback
end

function FuBenFinishStarView:CloseCallBack()
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

	if self.star_timer_reqest then
		GlobalTimerQuest:CancelQuest(self.star_timer_reqest)
		self.star_timer_reqest = nil
	end
end

function FuBenFinishStarView:OnClickClose()
	FuBenCtrl.Instance:SendExitFBReq()
	if self.sure_func then
		self.sure_func()
		self:Close()
	else
		self:Close()
	end
end

function FuBenFinishStarView:OnFlush(param_t)
	for i = 1, 3 do
		self.node_list["Effect" ..i]:SetActive(false)
		self.node_list["Star" .. i]:SetActive(false)
	end
	for k, v in pairs(param_t) do
		if k == "finish" then
			self.node_list["TxtReward"]:SetActive(false)
			self.node_list["TxtFuben"]:SetActive(true)
			if v.data ~= nil then
				for i, j in pairs(self.victory_items) do
					if v.data[i] then
						j.item_cell:SetData(v.data[i])
						j.item_obj:SetActive(true)
						self.effect_num = i
					else
						j.item_obj:SetActive(false)
					end
				end
			end
			if v.pass_time then
				local str_pass = string.format(Language.Mount.ShowGreenStr, TimeUtil.FormatSecond(v.pass_time, 4))
				self.node_list["TextVictory"]:SetActive(true)
				self.node_list["TextVictory"].text.text = string.format(Language.Dungeon.TipTime, str_pass)
			else
				self.node_list["TextVictory"]:SetActive(false)
			end
			if v.star then
				self.star_num = v.star
				-- self:StartPlayEffect()
				self:PlayHasStar()
			end
			if v.func then
				self.sure_func = v.func
			end
			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime()
		elseif k == "shouhu_finsh" then
			self.node_list["TxtFuben"]:SetActive(true)
			self.node_list["TxtReward"]:SetActive(true)
			self.node_list["TextVictory"]:SetActive(false)
			if v.data ~= nil then
				for i, j in pairs(self.victory_items) do
					if v.data[i + 1] then
						j.item_cell:SetData(v.data[i + 1])
						j.item_obj:SetActive(true)
						self.effect_num = i
					else
						j.item_obj:SetActive(false)
					end
				end
			end
			if v.star then
				self.star_num = v.star
				self:PlayHasStar()
			end
			if v.func then
				self.sure_func = v.func
			end
			if self.leave_timer == nil then
				self.leave_time = 5
				self.index = 1

				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 0.3)
			end
			self:GetEndBtnTime()
		end
	end
end

function FuBenFinishStarView:PlayHasStar()
	local pos = {}
	local time = 0
	for i = 1, 3 do
		local now_pos = {}
		self.node_list["Star" .. i].transform.localScale = Vector3(1, 1, 1)
		now_pos.x, now_pos.y = self.node_list["Star" .. i].transform.localScale.x, self.node_list["Star" .. i].transform.localScale.y
		table.insert(pos, now_pos)
		self.node_list["Star" .. i].transform.localScale = Vector3(5, 5, 5)
	end
	local one_first = true
	local second_first = true
	local third_first = true
	self.star_timer_reqest = GlobalTimerQuest:AddRunQuest(function()
		if time < 0.4 then
			if one_first then
				one_first = false
				local tween1 = self.node_list["Star1"].transform:DORotate(Vector3(0, 0, -360 * 4), 0.4, DG.Tweening.RotateMode.FastBeyond360)
				local tween_1 = self.node_list["Star1"].transform:DOScale(Vector3(pos[3].x, pos[3].y, 0), 0.4)
				UITween.MoveShowPanel(self.node_list["Star1"].transform, Vector3(400, 350, 0), 0.4)
				self.node_list["Star1"]:SetActive(1 <= self.star_num)
			end
		elseif time >= 0.4 and time < 0.8 then
			if second_first then
				second_first = false
				self.node_list["Effect1"]:SetActive(true)
				local tween2 = self.node_list["Star2"].transform:DORotate(Vector3(0, 0, -360 * 4), 0.4, DG.Tweening.RotateMode.FastBeyond360)
				local tween_2 = self.node_list["Star2"].transform:DOScale(Vector3(pos[3].x, pos[3].y, 0), 0.4)
				UITween.MoveShowPanel(self.node_list["Star2"].transform, Vector3(466.4, 336.1, 0), 0.4)
				self.node_list["Star2"]:SetActive(2 <= self.star_num)
			end
		elseif time >= 0.8 and time < 1.2 then
			if third_first then
				third_first = false
				self.node_list["Effect2"]:SetActive(true)
				local tween3 = self.node_list["Star3"].transform:DORotate(Vector3(0, 0, -360 * 4), 0.4, DG.Tweening.RotateMode.FastBeyond360)
				local tween_3 = self.node_list["Star3"].transform:DOScale(Vector3(pos[3].x, pos[3].y, 0), 0.4)
				UITween.MoveShowPanel(self.node_list["Star3"].transform, Vector3(571.7, 317, 0), 0.4)
				self.node_list["Star3"]:SetActive(3 <= self.star_num)
			end
		elseif time >= 1.2 then
			self.node_list["Effect3"]:SetActive(true)
		end

		if time > 1.5 then
			for i = 1,3 do
				self.node_list["Effect" .. i]:SetActive(false)
			end
			if self.star_timer_reqest then
				GlobalTimerQuest:CancelQuest(self.star_timer_reqest)
				self.star_timer_reqest = nil
			end
		end
		time = time + 0.1
	end, 0.1)
end

function FuBenFinishStarView:LoadEffect(item_num, group_cell, obj)
	if not obj then
		return
	end
	local transform = obj.transform
	transform:SetParent(group_cell[item_num].transform, false)
	local function Free()
		if IsNil(obj) then
			return
		end
        ResPoolMgr:Release(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end

function FuBenFinishStarView:GetEndBtnTime()
		local diff_time = 5
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

function FuBenFinishStarView:LeaveUpdate()
	if self.leave_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	else
		self.leave_time = self.leave_time - 0.3
	end

	if self.effect_items[self.index] and self.effect_num >= self.index then
		self.effect_items[self.index]:SetParentActive(true)
		self:PlayEffect(self.index)
		self.index = self.index + 1
	end
end

function FuBenFinishStarView:PlayEffect(index)
	local canvas = self.node_list["VItem" .. index].transform:GetComponentInParent(typeof(UnityEngine.Canvas))
	if canvas == nil then return end
	
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
	EffectManager.Instance:PlayAtTransform(
		bundle_name,
		asset_name,
		self.node_list["VItem" .. index].transform,
		1.0,Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(0.5, 0.5, 0.5))
end