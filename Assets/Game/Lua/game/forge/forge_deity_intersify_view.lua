-- 锻造 附灵（转职装强化）
ForgeDeityIntersify = ForgeDeityIntersify or BaseClass(BaseRender)

function ForgeDeityIntersify:__init(instance, parent_view)
	self.node_list["IntersifyBtn"].button:AddClickListener(BindTool.Bind(self.OnIntersifyBtn, self))
	self.node_list["AutoBtn"].button:AddClickListener(BindTool.Bind(self.OnAutoBtn, self))
	self.node_list["StopAutoBtn"].button:AddClickListener(BindTool.Bind(self.OnStopAutoBtn, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.material_cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["MaterialCell" .. i])
		self.material_cells[i] = cell
	end
end

function ForgeDeityIntersify:__delete()
	for k,v in pairs(self.material_cells) do
		v:DeleteMe()
	end
	self.material_cells = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.fight_text = nil
end

function ForgeDeityIntersify:ClickEquipListCallBack(index)
	self:OnStopAutoBtn()
	self.select_index = index
	self:Flush()
end

function ForgeDeityIntersify:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_deity_intersify)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	
	if self.select_index == nil then return end
	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)
	local fuling_info = ForgeData.Instance:GetFulingData(self.cell_data.index)
	local item_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
	if not item_cfg or not fuling_info then return end

	local fuling_cfg = ForgeData.Instance:GetFulingCfg(item_cfg.order)
	local material_cfg = ForgeData.Instance:GetFulingMaterial()
	if not fuling_cfg or not material_cfg then return end

	local is_max = 0
	local is_no_num = 0
	local attr_tab = {}
	for i, v in ipairs(material_cfg) do
		local max_val = v.add_attr_val * fuling_cfg.fuling_max_count
		local had_val = v.add_attr_val * fuling_info[i]
		self.node_list["ProgressText" .. i].text.text = had_val .. "/" .. max_val
		self.node_list["ProgressBG" .. i].slider.value = had_val / max_val
		attr_tab[v.add_attr_type] = had_val

		local item_cfg = ItemData.Instance:GetItemConfig(v.stuff_id)
		local num = ItemData.Instance:GetItemNumInBagById(v.stuff_id)
		self.material_cells[i]:SetData({item_id = v.stuff_id, num = num})
		self.node_list["MaterialName" .. i].text.text = item_cfg.name

		is_max = (max_val <= had_val)and (is_max + 1) or is_max
		is_no_num = (num <= 0) and (is_no_num + 1) or is_no_num
	end
	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_tab)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end

	is_no_num = is_no_num + is_max
	self.is_max_level = is_max == #material_cfg
	if self.is_max_level or (is_no_num ==  #material_cfg)then
		self:OnStopAutoBtn()
	end

	if self.is_max_level then
		UI:SetButtonEnabled(self.node_list["IntersifyBtn"], false)
		UI:SetGraphicGrey(self.node_list["IntersifyBtn"], true)

		self.node_list["AutoBtn"]:SetActive(false)
		self.node_list["IntersifyBtnText"].text.text = Language.Common.YiManJi
	else
		UI:SetButtonEnabled(self.node_list["IntersifyBtn"], not self.is_auto_intersify)
		UI:SetGraphicGrey(self.node_list["IntersifyBtn"], self.is_auto_intersify)

		self.node_list["AutoBtn"]:SetActive(not self.is_auto_intersify)
		self.node_list["IntersifyBtnText"].text.text = Language.Forge.FuLing
	end
end

-- 附灵
function ForgeDeityIntersify:OnIntersifyBtn()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	if self.is_max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.FulingMaxLevel)
		return
	end

	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_FULING, self.cell_data.index)
end

-- 一键附灵
function ForgeDeityIntersify:OnAutoBtn()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	
	if self.is_max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.FulingMaxLevel)
		return
	end

	local can_up_level = ForgeData.Instance:GetDeityIntersifyCanImprove(self.cell_data)
	if not can_up_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoEnoughMaterial)
		return
	end

	UI:SetButtonEnabled(self.node_list["IntersifyBtn"], false)
	UI:SetGraphicGrey(self.node_list["IntersifyBtn"], true)
	self.node_list["StopAutoBtn"]:SetActive(true)
	self.node_list["AutoBtn"]:SetActive(false)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.is_auto_intersify = true
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:AutoUpgrade()
	end, 0.2)
end

function ForgeDeityIntersify:AutoUpgrade()
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_FULING, self.cell_data.index)
end

-- 停止附灵
function ForgeDeityIntersify:OnStopAutoBtn()
	UI:SetButtonEnabled(self.node_list["IntersifyBtn"], true)
	UI:SetGraphicGrey(self.node_list["IntersifyBtn"], false)
	self.node_list["StopAutoBtn"]:SetActive(false)
	self.node_list["AutoBtn"]:SetActive(true)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.is_auto_intersify = false
end

function ForgeDeityIntersify:OnButtonHelp()
	local tips_id = 262
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end
