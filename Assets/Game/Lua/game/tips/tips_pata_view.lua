TipPaTaView = TipPaTaView or BaseClass(BaseView)
function TipPaTaView:__init()
	self.ui_config = {{"uis/views/tips/patatips_prefab", "PaTaTipsView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.item_list = {}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipPaTaView:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipPaTaView:LoadCallBack()
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnOkClick, self))
	self.victory_items = {}
	for i = 1, 7 do
		local item_obj = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.victory_items[i] = item_cell
	end
end

function TipPaTaView:OpenCallBack()
	FuBenData.Instance:SetIsCanOpenJieSuo(false)
	self.is_not_reach_power = false
	self:Flush()
end

function TipPaTaView:CloseCallBack()
	self.no_func = nil
	self.ok_func = nil
	self.item_list = {}
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipPaTaView:OnFlush()
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	if tower_fb_info and fuben_cfg and fuben_cfg[tower_fb_info.today_level + 1] then
		if capability < fuben_cfg[tower_fb_info.today_level + 1].capability then
			self.is_not_reach_power = true
		else
			self.is_not_reach_power = false
		end
	end
	self:CalTime()
	if self.item_list and next(self.item_list) ~= nil then
		for i, v in ipairs(self.victory_items) do
			if self.item_list[i - 1] then
				v:SetData(self.item_list[i - 1])
				self.node_list["Item" .. i]:SetActive(true)
			else
				self.node_list["Item" .. i]:SetActive(false)
			end
		end
	end
	self.node_list["BtnCancelTxt"].text.text = self.is_not_reach_power and Language.FuBen.Continue or Language.Common.Cancel
end

function TipPaTaView:OnCloseClick()
	if self.is_not_reach_power then
		if self.ok_func then
			if self:GetIsCanShow() then
				FuBenData.Instance:SetIsCanOpenJieSuo(true)
			end
			self.ok_func()
		end
	else
		if self.no_func ~= nil then
			self.no_func()
		end
	end
	self:Close()
end

function TipPaTaView:SetNoCallback(func)
	self.no_func = func
end

function TipPaTaView:SetOKCallback(func)
	self.ok_func = func
end

function TipPaTaView:SetItemReward(item_list)
	self.item_list = item_list
end

function TipPaTaView:SetData()
	self:Flush()
end

function TipPaTaView:OnOkClick()
	if self.is_not_reach_power then
		if self.no_func then
			self.no_func()
		end
	else
		if self.ok_func then
			if self:GetIsCanShow() then
				FuBenData.Instance:SetIsCanOpenJieSuo(true)
			end
			self.ok_func()
		end
	end
	self:Close()
end

function TipPaTaView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:OnOkClick()
			self.cal_time_quest = nil
		else
			if self.is_not_reach_power then
				self.node_list["Btntxt"].text.text = string.format(Language.Common.GetAndOut, math.floor(timer_cal))
			else
				self.node_list["Btntxt"].text.text = string.format(Language.Common.ConfirmEndTime, math.floor(timer_cal))
			end
		end
	end, 0)
end

function TipPaTaView:GetIsCanShow()
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local mojie_cfg = FuBenData.Instance:GetTowerMojieCfg()
	local is_show = false
	if tower_fb_info and tower_fb_info.today_level then
		if mojie_cfg and mojie_cfg.active_cfg then
			for k,v in pairs(mojie_cfg.active_cfg) do 
				if tower_fb_info.today_level + 1 == v.pata_layer then
					is_show = true
				end
			end
		end
	end
	return is_show
end



