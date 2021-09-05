TipsShortCutEquipView = TipsShortCutEquipView or BaseClass(BaseView)
local FIX_TIME = 10
local AUTO_EQUIP_LEVEL = 130
function TipsShortCutEquipView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "ShortcutEquip"}}
	self.sure_call_back = nil
	self.play_audio = true
	self.is_async_load = true
	self.is_auto_equip = false
	self.vew_cache_time = ViewCacheTime.NORMAL
	self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
	self.view_layer = UiLayer.Pop
	self.item_list = {}
end

function TipsShortCutEquipView:__delete()

end

function TipsShortCutEquipView:ReleaseCallBack()
	if self.equip_item ~= nil then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
	self.fight_text = nil
	if TipsCtrl and TipsCtrl.Instance then
		TipsCtrl.Instance:SetShortcutEquipIsopen(false)
	end
end

function TipsShortCutEquipView:LoadCallBack()
	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.CloseOnClick, self))
	self.node_list["BtnEquip"].button:AddClickListener(BindTool.Bind(self.EquipOnClick, self))
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_item:SetFromView(TipsFormDef.QUICK_EQUIP)
	self.equip_item:SetShowUpArrow(false)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtEquipPower"], "FightPower3")
end

function TipsShortCutEquipView:OpenCallBack()
	TipsCtrl.Instance:SetShortcutEquipIsopen(true)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self:Flush()
end

function TipsShortCutEquipView:CloseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	end
	self.item_list = {}

	TipsCtrl.Instance:ShowGetNewView()
end

function TipsShortCutEquipView:SetItemId(item_id, index)
	for k, v in pairs(self.item_list) do
		if item_id == v.item_id then
			return
		end

		local temp_v_item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local temp_v_equip_index = EquipData.Instance:GetEquipIndexByType(temp_v_item_cfg.sub_type)

		local temp_item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local temp_equip_index = EquipData.Instance:GetEquipIndexByType(temp_item_cfg.sub_type)

		if temp_v_equip_index == temp_equip_index then
			local temp_v_data = ItemData.Instance:GetGridData(v.index)
			local temp_data = ItemData.Instance:GetGridData(index)

			if EquipData.Instance:GetEquipCapacityPower(temp_v_data) >= EquipData.Instance:GetEquipCapacityPower(temp_data) then
				return
			end
		end
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local equip_cfg = ItemData.Instance:GetItemConfig(item_id)
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if equip_cfg == nil then
		return
	end

	if EquipData.IsLittlePetEqType(equip_cfg.sub_type) or EquipData.IsLittlePetToyType(equip_cfg.sub_type) or EquipData.IsShengXiaoEqType(equip_cfg.sub_type) 
		or EquipData.IsLongQiEqType(equip_cfg.sub_type) or EquipData.IsJinglingSoul(equip_cfg.sub_type) or  EquipData.IsBianShenEquipType(equip_cfg.sub_type) then
		return
	end

	-- 斗气装备
	if DouQiData.Instance:IsDouqiEqupi(item_id) then
		local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
		local douqi_equip_cfg = DouQiData.Instance:GetDouqiEquipCfg(item_id)
		if not douqi_info or not douqi_equip_cfg then return end

		if douqi_info.douqi_grade < douqi_equip_cfg.order then return end
	end

	if main_vo.level < equip_cfg.limit_level then
		return
	end

	if equip_cfg.limit_prof ~= 5 and equip_cfg.limit_prof ~= base_prof then
		return
	end

	if equip_cfg.limit_sex ~= 2 and equip_cfg.limit_sex ~= GameVoManager.Instance:GetMainRoleVo().sex then
		return
	end


	if EquipData.Instance:IsZhuanzhiEquipType(equip_cfg.sub_type) then
		local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
		local zhuanzhi_equip_cfg = ForgeData.Instance:GetZhuanzhiEquipInfo(equip_index, equip_cfg.order)
		if zhuanzhi_equip_cfg then
			if not (ForgeData.Instance:GetZhiZunEquipCfg(item_id) or ForgeData.Instance:GetSpecialEquipCfg(item_id)) and zhuan < zhuanzhi_equip_cfg.role_need_min_prof_level then
				return
			end
		else
			return
		end
	end

	if not EquipData.Instance:CheckIsAutoEquip(item_id, index) then
		return
	end
	if not self:IsOpen() then
		self.item_id = item_id
		self.index = index
	end
	
	local temp_item = {}
	temp_item.item_id = item_id
	temp_item.index = index
	table.insert(self.item_list, temp_item)

	self:Open()
end

function TipsShortCutEquipView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num, param_change)
	-- if self.item_list[1] ~= nil and item_id == self.item_list[1].item_id and param_change then
	-- 	self.item_list[1].index = index
	-- 	self:Flush()
	-- elseif self.item_list[1] ~= nil and index == self.item_list[1].index and item_id ~= self.item_list[1].item_id then
	-- 	print_warning("--------Close")
	-- 	self:Close()
	-- else
	-- 	self:Flush()
	-- end
end

function TipsShortCutEquipView:OnFlush()
	self.is_auto_equip = false
	if self.item_list[1] == nil then
		self:Close()
		return
	end
	local item_cfg =ItemData.Instance:GetItemConfig(self.item_list[1].item_id)
	local equip_data, power = self:GetBestPowerEequip(self.item_list[1].item_id)

	if equip_data == nil or not next(equip_data) or (power and power <= 0) then
		self:Close()
		return
	end

	self.equip_item:SetData(equip_data)
	self.node_list["TxtEquipName"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = string.format("%s", power)
	end
	local delay_time = FIX_TIME
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		delay_time = delay_time - UnityEngine.Time.deltaTime
		if delay_time > 0 then
			local time = math.floor(delay_time)
			if time >= 0 then
				local time_str = string.format(Language.Common.AutoEquip, time)
				self.node_list["TxtCalTime"].text.text = time_str
			end
		else
			self.is_auto_equip = true
			self:EquipOnClick()
		end
	end, 0)
end

function TipsShortCutEquipView:GetItemInfoByID(item_id)
	return ItemData.Instance:GetItemConfig(item_id)
end

function TipsShortCutEquipView:CloseOnClick()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.item_list[1] == nil then
		self:Close()
		return
	end
	local equip_cfg = ItemData.Instance:GetItemConfig(self.item_list[1].item_id)
	if main_role_vo.level <= AUTO_EQUIP_LEVEL and not EquipData.Instance:IsZhuanzhiEquipType(equip_cfg.sub_type) then
		self.is_auto_equip = true
		self:EquipOnClick()
		return
	end
	table.remove(self.item_list, 1)
	self:Flush()
end

function TipsShortCutEquipView:EquipOnClick()
	if self.sure_call_back ~= nil then
		self.sure_call_back()
	end

	if not self.item_list[1] or not self.item_list[1].item_id then
		self:Close()
		return
	end

	--装备物品
	local equip_cfg = ItemData.Instance:GetItemConfig(self.item_list[1].item_id)
	local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)

	local equip_data, power = self:GetBestPowerEequip(self.item_list[1].item_id)
	if equip_data == nil or not next(equip_data) or (power and power <= 0) then
		self:Close()
		return
	end

	local function view_operate()
		table.remove(self.item_list, 1)
		if self.item_list[1] ~= nil then
			self:Flush()
		else
			self:Close()
		end		
	end

	if self.item_list[1].item_id == 12100 and MarriageData.Instance:GetRingHadActive() then
		-- 结婚戒指
		local item = MarriageData.Instance.decompose_item
		if item == nil then
			return
		end
		local describe = string.format(Language.Marriage.Ring_Fenjie, item.num)
		local fun = function()
			PackageCtrl.Instance:SendDiscardItem(self.item_list[1].index, 1, self.item_list[1].item_id, 1, 1)
			view_operate()
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, describe, fun, nil, nil, nil, nil, nil, true, false)
	elseif EquipData.IsXiaoguiEqType(equip_cfg.sub_type) then
		if EquipData.IsBetterExchangeXiaoGui(self.item_list[1]) then
			PackageCtrl.Instance:SendUseItem(self.item_list[1].index, 1, equip_index, equip_cfg.need_gold)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Tip.BetterEquipXiaogui)
		end
		view_operate()
	else
		PackageCtrl.Instance:SendUseItem(equip_data.index, 1, equip_index, equip_cfg.need_gold)
		view_operate()
	end
end

-- 获得最高战力装备
function TipsShortCutEquipView:GetBestPowerEequip(item_id)
	local equip_list = ItemData.Instance:GetItems(item_id)
	local power = 0
	local choose_equip = {}
	for k, v in pairs(equip_list) do
		local equip_power = EquipData.Instance:GetEquipCapacityPower(v)
		if equip_power and power < equip_power then
			power = equip_power
			choose_equip = v
		end
	end

	return choose_equip, power
end