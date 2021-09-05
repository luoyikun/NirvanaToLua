TipPaTaRewardView = TipPaTaRewardView or BaseClass(BaseView)
function TipPaTaRewardView:__init()
	self.ui_config = {{"uis/views/tips/patatips_prefab", "PaTaTipsViewWithReward"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function TipPaTaRewardView:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	for k,v in pairs(self.victory_items) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.victory_items = {}
end

function TipPaTaRewardView:LoadCallBack()
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnOkClick, self))

	self.victory_items = {}
	for i = 1, 7 do
		local item_obj = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.victory_items[i] = {item_obj = item_obj, item_cell = item_cell}
	end
end

function TipPaTaRewardView:OpenCallBack()
	self.is_not_reach_power = false
	self:Flush()
end

function TipPaTaRewardView:CloseCallBack()
	self.no_func = nil
	self.ok_func = nil
	self.data = nil
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipPaTaRewardView:OnFlush()
	local tower_fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	if fuben_cfg and tower_fb_info and fuben_cfg[tower_fb_info.fb_today_layer + 1] then
		if capability < fuben_cfg[tower_fb_info.fb_today_layer + 1].capability then
			self.is_not_reach_power = true
		else
			self.is_not_reach_power = false
		end
	end
	self:CalTime()
	if self.data then
		for i, j in pairs(self.victory_items) do
			if self.data[i] then
				j.item_cell:SetData(self.data[i])
				j.item_obj:SetActive(true)
				self:PlayEffect(i)
			else
				j.item_obj:SetActive(false)
			end
		end
	end
	self.node_list["TxtCancelBtn"].text.text = self.is_not_reach_power and Language.FuBen.Continue or Language.Common.Cancel
end

function TipPaTaRewardView:OnCloseClick()
	if self.is_not_reach_power then
		if self.ok_func then
			self.ok_func()
		end
	else
		if self.no_func then
			self.no_func()
		end
	end
	self:Close()
end

function TipPaTaRewardView:SetNoCallback(func)
	self.no_func = func
end

function TipPaTaRewardView:SetOKCallback(func)
	self.ok_func = func
end

function TipPaTaRewardView:SetDataList(data)
	self.data = data
end

function TipPaTaRewardView:SetData()
	self:Flush()
end

function TipPaTaRewardView:OnOkClick()
	if self.is_not_reach_power then
		if self.no_func then
			self.no_func()
		end
	else
		if self.ok_func then
			self.ok_func()
		end
	end
	self:Close()
end

function TipPaTaRewardView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:OnOkClick()
			self.cal_time_quest = nil
		else
			if self.is_not_reach_power then
				self.node_list["TxtDescText"].text.text = string.format(Language.Common.GetAndOut, math.floor(timer_cal))
			else
				self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxt, math.floor(timer_cal))
			end
		end
	end, 0)
end

function TipPaTaRewardView:PlayEffect(index)
	local canvas = self.node_list["Item" .. index].transform:GetComponentInParent(typeof(UnityEngine.Canvas))
	if canvas == nil then return end
	
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
	EffectManager.Instance:PlayAtTransform(
		bundle_name,
		asset_name,
		self.node_list["Item" .. index].transform,
		1.0,Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(0.5, 0.5, 0.5))
end



