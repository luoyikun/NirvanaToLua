FuBenFinishStarNextView = FuBenFinishStarNextView or BaseClass(BaseView)

function FuBenFinishStarNextView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "VictoryStarView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end
	self.leave_time = 0
end

function FuBenFinishStarNextView:LoadCallBack()
	self.root_node:AddComponent(typeof(UnityEngine.CanvasGroup))
	self.node_list["ButtonExit"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["ButtonContinue"].button:AddClickListener(BindTool.Bind(self.OnOkClick, self))
	self.victory_items = {}
	for i = 1, 6 do
		local item_obj = self.node_list["VItem" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["VItem" .. i])
		self.victory_items[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end

	self.star_list = {}
	for i = 1, 3 do
		self.star_list[i]= self.node_list["Star" .. i]
	end
	self.star_num = 0
end

function FuBenFinishStarNextView:OpenCallBack()
	self:Flush("finish")
end

function FuBenFinishStarNextView:SetNoCallback(func)
	self.no_func = func
end

function FuBenFinishStarNextView:SetOKCallback(func)
	self.ok_func = func
end


function FuBenFinishStarNextView:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
	for k,v in pairs(self.victory_items) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	for k,v in pairs(self.star_list) do
		v = nil
	end
	self.victory_items = {}
	self.victory_text = nil
	self.enter_text = nil
	self.desc_text = nil
	self.star_num = 0
end

function FuBenFinishStarNextView:CloseCallBack()
	self.no_func = nil
	self.ok_func = nil

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	self.leave_time = 0
	if self.leave_timer then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	end
end

function FuBenFinishStarNextView:OnClickClose()
	FuBenCtrl.Instance:SendExitFBReq()
	self:Close()
end


function FuBenFinishStarNextView:OnOkClick()
	if self.ok_func then
		self.ok_func()
	end
	self:Close()
end

function FuBenFinishStarNextView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:OnOkClick()
			self.cal_time_quest = nil
		else
			self.node_list["TextCountdown"].text.text = string.format(Language.FuBen.AutoAttack, math.floor(timer_cal))
		end
	end, 0)
end

function FuBenFinishStarNextView:OnFlush(param_t)
	self:CalTime()
	for k, v in pairs(param_t) do
		if k == "finish" then
			if v.data ~= nil then
				for i, j in pairs(self.victory_items) do
					if v.data[i] then
						j.item_cell:SetData(v.data[i])
						j.item_obj:SetActive(true)
					else
						j.item_obj:SetActive(false)
					end
				end
			end
			if v.pass_time then
				local str_pass = string.format(Language.Mount.ShowGreenStr, TimeUtil.FormatSecond(v.pass_time, 4))
				self.node_list["TextVictory"].text.text = string.format(Language.Dungeon.TipTime, str_pass)
			end
			if v.star then
				self.star_num = v.star
				self:StartPlayEffect()
			end
		end
	end
end

function FuBenFinishStarNextView:StartPlayEffect()
	self.root_node:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
	local count = self.star_num
	for i = 1, 3 do
		self.node_list["Star" .. i].canvas_group.alpha = 0
	end
	--创建计时器分步显示item
	self.step = 0
	self.play_count_down = CountDown.Instance:AddCountDown(2, 0.5, BindTool.Bind(self.PlayTime, self, self.star_list, count))
end

function FuBenFinishStarNextView:PlayTime(group_cell, count, elapse_time, total_time)
	if self.step >= count or elapse_time >= total_time then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		for i = 1, 3 do
			self.node_list["Star" .. i].canvas_group.alpha = 1
			UI:SetGraphicGrey(self.node_list["Star" .. i], false)
		end
		if self.star_num < 3 then
			for i = self.star_num + 1, 3 do
				UI:SetGraphicGrey(self.node_list["Star" .. i], true)
			end
		end
		return
	end
	self.step = self.step + 1

	local item_num = self.step
	local bundle_name, asset_name = ResPath.GetMiscEffect("UI_choujiang")
	ResPoolMgr:GetDynamicObjAsync(bundle_name, asset_name, BindTool.Bind(self.LoadEffect, self, item_num, group_cell))
	group_cell[self.step].canvas_group.alpha = 1
end

function FuBenFinishStarNextView:LoadEffect(item_num, group_cell, obj)
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
