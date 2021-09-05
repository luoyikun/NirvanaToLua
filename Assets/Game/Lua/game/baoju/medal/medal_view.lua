MedalView = MedalView or BaseClass(BaseRender)

local EFFECT_CD = 1
local ListViewDelegate = ListViewDelegate

local OrderTable = {
	[1] = "mount_attr_add",
	[2] = "wing_attr_add",
	[3] = "halo_attr_add",
}

function MedalView:__init()
	self.effect_cd = 0
	self.old_index = -1
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.medal_max_level = MedalData.Instance:GetMaxLevel()

	self.icon_cell = {}
	self.attr_cell = {}
	self.attr_list = {}
	self.medal_total_data = MedalData.Instance:GetMedalSuitCfg()

	MedalCtrl.Instance:RegisterView(self)
	local child_number = self.node_list["ObjGroup"].transform.childCount
	local count = 1
	local data = self:GetAttrListData()
	for i = 0, child_number - 1 do
		local obj = self.node_list["ObjGroup"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			self.attr_list[count] = MedalAttrText.New(obj)
			if data[count] then
				self.attr_list[count]:SetData(data[count])
			else
				self.attr_list[count]:SetActive(false)
			end
			count = count + 1
		end
	end

	self.medal_data = MedalData.Instance:GetMedalInfo()
	for i = 1, 6 do
		self.icon_cell[i] = MedalScrollIconCell.New(self.node_list["IconBG"..i])
		self.icon_cell[i]:SetParentView(self)
		self.icon_cell[i]:SetData(self.medal_data[i])
		self.icon_cell[i]:SetToggleGroup(self.node_list["EquipToggleGroup"].toggle_group)
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self:NewInitData()
	
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnUpdataBtnClick, self))
	self.node_list["BtnTotalAttr"].button:AddClickListener(BindTool.Bind(self.OnBtnTotalAttr, self))
end

function MedalView:CloseCallBack()
	if self.delay_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function MedalView:SelectIcon()
	for i = 1, 6 do
		if self.node_list["IconBG" .. i].toggle.isOn then
			self.now_data = self.medal_data[i]
		end
	end
	for k, v in pairs(self.medal_data) do
		if v.can_upgrade and not self.now_data.can_upgrade then
			self.now_data = v
			self.node_list["IconBG" .. k].toggle.isOn = true
			break
		end
	end
	self:ClickMedal(self.now_data)
end
--点击勋章刷新数据
function MedalView:ClickMedal(data, is_by_click)
	if is_by_click and nil == self.delay_timer and data.id ~= self.id_cache then
	 	self.id_cache = data.id
		self.node_list["TotalPanel"]:SetActive(false)
		self.node_list["TotaAttrBg"].animator:SetTrigger("IsPlayAni")
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DelayTimer, self), 0.4)
	elseif is_by_click and data.id ~= self.id_cache then
		self.id_cache = data.id
		self.node_list["TotaAttrBg"].animator:SetTrigger("IsReset")
		if self.delay_timer ~= nil then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
		end
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DelayTimer, self), 0.4)
	end

	self.now_data = data
	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.now_data.id, self.now_data.level) or {}
	local next_cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.now_data.id, self.now_data.level + 1) or {}
	-- local cur_jie = MedalData.Instance:GetCurActiveJie()
	-- if self.selet_data_index <= cur_jie then
	-- 	self:FlushEffect()
	-- end
	self.node_list["TxtMedalName"].text.text = cfg.xunzhang_name

	--升级所需道具
	local itemData = {item_id = cfg.uplevel_stuff_id}
	self.item:SetData(itemData)

	--升级所需道具数量
	local had_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
	local uplevel_stuff_num = next_cfg and next_cfg.uplevel_stuff_num or 0
	had_num = had_num >= uplevel_stuff_num and ToColorStr(had_num, "#89F201") or ToColorStr(had_num, COLOR.RED)
	self.node_list["TxtItemNumber"].text.text = had_num.." / "..uplevel_stuff_num

	if cfg.level < 1 then
		cfg = next_cfg
	end
	--基础属性
	local attrs = CommonDataManager.GetAttributteByClass(cfg)
	local sort_attrs = CommonDataManager.GetOrderAttributte(attrs)

	local count = 1
	-- local isShowAttr5 = false

	for i = 1, 5 do
		self.node_list["TxtAttr" .. i]:SetActive(false)
	end

	for k, v in pairs(sort_attrs) do
		if v.value > 0 then
			local chs_attr_name = ToColorStr(CommonDataManager.GetAttrName(v.key) .. ' :', TEXT_COLOR.WHITE)
			local value = 0
			if self.now_data.level > 0 then
				value = v.value
			end
			local attr_value = ToColorStr('  '..value, TEXT_COLOR.WHITE)
			self.node_list["TxtAttr" .. count].text.text = chs_attr_name..attr_value
			self.node_list["TxtAttr" .. count]:SetActive(true)
			count = count + 1
		end
	end

	for k,v in pairs(cfg) do
		if type(v) == "number" and v > 0 then
			if string.sub(k, 1, 3) == 'per' then
				if cfg.level >= 1 then
					-- isShowAttr5 = true
					self.node_list["TxtAttr" .. count].text.text = ToColorStr(Language.BaoJu.MedalAttrToChs[k]..'：', TEXT_COLOR.WHITE)..(v / 100).."%"
					self.node_list["TxtAttr" .. count]:SetActive(true)
				end
			end
		end
	end
	-- self.node_list["TxtAttr5"]:SetActive(isShowAttr5)

	--战力
	if self.fight_text and self.fight_text.text then
		if self.now_data.level < 1 then
			self.fight_text.text.text = 0
		else
			local power = CommonDataManager.GetCapability(attrs)
			self.fight_text.text.text = power
		end
	end
	self:FlushProgressSlider()
end

function MedalView:DelayTimer()
	self.node_list["TotalPanel"]:SetActive(true)
	if self.delay_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function MedalView:PlayEffect()
	local res_id = self.selet_data_index
	local bundle_name, asset_name = ResPath.GetMedalEffect(res_id)
	-- self.node_list["EffectIcon"]:ChangeAsset(bundle_name, asset_name)
end

function MedalView:OnUpdataBtnClick()
	local next_cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.now_data.id, self.now_data.level + 1)
	if next_cfg == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.MaxLevel)
	else
		local stuff_cfg = ItemData.Instance:GetItemConfig(next_cfg.uplevel_stuff_id)
		if stuff_cfg ~= nil then
			local had_num = ItemData.Instance:GetItemNumInBagById(next_cfg.uplevel_stuff_id)
			if had_num >= next_cfg.uplevel_stuff_num then
				local flag = 0
				MedalCtrl.Instance:SendMedalUpgrade(self.now_data.id, flag)
				AudioService.Instance:PlayAdvancedAudio()
			else
				TipsCtrl.Instance:ShowItemGetWayView(next_cfg.uplevel_stuff_id)
			end
		end
	end
end

function MedalView:OnBtnTotalAttr()
	local attr_tab = CommonStruct.AttributeNoUnderline()
	for k, v in pairs(self.medal_data) do
		local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(v.id, v.level) or {}
		if cfg then
			local temp_attr = CommonDataManager.GetAttributteNoUnderline(cfg)
			attr_tab = CommonDataManager.AddAttributeAttrNoUnderLine(attr_tab, temp_attr)
		end
	end
	TipsCtrl.Instance:OpenEquipAttrTipsView("medal_attr", attr_tab)
end

function MedalView:GetAttrListData()
	local arrt_data = {}
	local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local current_data = self.medal_total_data[current_data_index]
	local current_total_level = MedalData.Instance:GetMedalTotalLevel()
	if current_data == nil then
		current_data = {
		total_level=0,
		mount_attr_add=0,
		wing_attr_add=0,
		halo_attr_add=0,
		magic_bow_attr_add=0,
		magic_wing_attr_add=0,
	}
	end
	local count = 1
	for k,v in ipairs(OrderTable) do
		local data = {}
		data.name = Language.BaoJu.AdvanceAttr[v]
		data.icon = Language.BaoJu.IconName[v]
		data.value = current_data[v]
		if current_data.total_level <= current_total_level and self.medal_total_data[current_data_index + 1] then
			data.next_value = self.medal_total_data[current_data_index + 1][v]
		else
			data.next_value = nil
		end
		table.insert(arrt_data, data)
		count = count + 1
	end
	return arrt_data
end

--升级后刷新数据
function MedalView:NewFlushNowData()
	local medal_data = MedalData.Instance:GetMedalInfo()
	self.now_data = medal_data[self.now_data.id + 1]
	self:ClickMedal(self.now_data)
	-- self:FlushEffect()
	self.icon_cell[self.now_data.id + 1]:SetData(self.now_data)
	self:FlushProgressSlider()
	self:NewInitData()
end

function MedalView:FlushProgressSlider()
	local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local next_total_level = 0
	self.medal_total_data = MedalData.Instance:GetMedalSuitCfg()
	if self.medal_total_data[current_data_index + 1] then
		if MedalData.Instance:GetMedalIsOneJie() then
			next_total_level = self.medal_total_data[current_data_index + 1].total_level
		else
			next_total_level = self.medal_total_data[1].total_level
		end
	end
	local current_total_level = MedalData.Instance:GetMedalTotalLevel()

	if current_total_level < self.medal_max_level and current_total_level and next_total_level then
		self.node_list["TxtProcessLeft"].text.text = current_total_level .. '/' .. next_total_level
	else
		self.node_list["TxtProcessLeft"].text.text = Language.Common.YiMan
		self.node_list["TxtItemNumber"].text.text = Language.Common.MaxLevelDesc
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"], false)
	end
	self.node_list["SliderProcess"].slider.value = current_total_level / next_total_level
	local child_number = self.node_list["ObjGroup"].transform.childCount
	local data = self:GetAttrListData()
	local count = 1
	for i = 0, child_number - 1 do
		if data[count] then
			self.attr_list[count]:SetData(data[count])
		else
			self.attr_list[count]:SetActive(false)
		end
		count = count + 1
	end
end

--初始化数据
function MedalView:NewInitData()
	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index < 1 then
		self.selet_data_index = 1
	elseif self.selet_data_index >= #self.medal_total_data then
		self.selet_data_index = #self.medal_total_data
	else
		self.selet_data_index = self.selet_data_index + 1
	end
	self:PlayEffect()

	local next_data = self.medal_total_data[self.selet_data_index]
	self.node_list["TxtLevel"].text.text = next_data.total_level
	self.node_list["TxtName"].text.text = next_data.name
	self.node_list["TxtRank"].text.text = Language.Common.NumToChs[self.selet_data_index]
	-- local bundle, asset = ResPath.GetGongXunRes("badge_" .. self.selet_data_index)
	-- self.node_list["ClassImg"].image:LoadSprite(bundle,asset)
	-- self.node_list["ClassImg"].image:SetNativeSize()
end

function MedalView:__delete()
	if MedalCtrl.Instance ~= nil then
		MedalCtrl.Instance:UnRegisterView()
	end

	if self.medalModel then
		self.medalModel:DeleteMe()
		self.medalModel = nil
	end

	self.old_index = -1

	for i,v in ipairs(self.icon_cell) do
		v:DeleteMe()
	end
	self.icon_cell = {}
	if self.item ~= nil then
		self.item:DeleteMe()
	end

	if self.delay_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	self.fight_text = nil
end

function MedalView:SetMedalModelData(index)
	if self.old_index == index then return end
	self.old_index = index
	local res_id = MedalData.Instance:GetMedalResId(index)
	local bubble, asset = ResPath.GetMedalModel(res_id)
	self.medalModel:SetMainAsset(bubble, asset)
end
-- 结束
function MedalView:OnClickHelp()
	local tips_id = 21    -- 勋章tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MedalView:OpenCallBack()
	self.is_frist = true
	self:IsRedPointShow()
	self:FlushProgressSlider()
end

function MedalView:IsRedPointShow()
	for k,v in pairs(self.medal_data) do
		if v.can_upgrade == true then
			self.icon_cell[v.id+1].show_red_point:SetActive(true)
		else
			self.icon_cell[v.id+1].show_red_point:SetActive(false)
		end
	end
end

function MedalView:ShowCurrentIcon()
	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index <= 0 then
		self.selet_data_index = 1
	end
end

---------------MedalAttrText		勋章属性文本
MedalAttrText = MedalAttrText or BaseClass(BaseCell)

function MedalAttrText:__init()

end

function MedalAttrText:__delete()
	
end

function MedalAttrText:OnFlush()
	self:SetActive(true)
	self.node_list["TxtName"].text.text = self.data.name ..':'
	self.node_list["TxtCurrentValue"].text.text = '+' .. (self.data.value/100) .. '%'

	if self.data.next_value ~= nil then
		if MedalData.Instance:GetMedalIsOneJie() then
			local next_add_value = self.data.next_value/100 - self.data.value/100
			self.node_list["TxtNextValue"].text.text = '+' .. next_add_value .. '%'
		else
			self.node_list["TxtCurrentValue"].text.text = '+'..(0)..'%'
			self.node_list["TxtNextValue"].text.text = '+'..(self.data.next_value/100)..'%'
		end
	else
		if MedalData.Instance:GetMedalIsOneJie() then
			self.node_list["TxtNextValue"].text.text = '0%'
		else
			self.node_list["TxtCurrentValue"].text.text = '+' .. (0)..'%'
			self.node_list["TxtNextValue"].text.text = '+' .. (self.data.value/100) .. '%'
		end
	end
end

------------------------------------------------IconCell-------------------------------------------------
MedalScrollIconCell = MedalScrollIconCell or BaseClass(BaseCell)

function MedalScrollIconCell:__init()
	self.name = self.node_list["TxtName"]
	self.show_red_point = self.node_list["ImgRedPoint"]
	self.node_list["PanelIconBG1"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MedalScrollIconCell:__delete()
	self.name = nil
	self.show_red_point = nil
end

function MedalScrollIconCell:Flush()
	if self.data then
		local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level)
		self.node_list["TxtName"].text.text = "Lv."..cfg.level
	end
end

function MedalScrollIconCell:OnClick()
	self.parent_view:ClickMedal(self.data, true)
end

function MedalScrollIconCell:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end

function MedalScrollIconCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function MedalScrollIconCell:SetParentView(parent_view)
	self.parent_view = parent_view
end