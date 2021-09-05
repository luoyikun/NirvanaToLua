MojieView = MojieView or BaseClass(BaseView)

local PASSIVE_TYPE = 73
local MOVE_TIME = 0.5
local MAX_LEVEL = 10

local SKILL_EFFECT = {
	[1] = "Buff_zhuahen_UI",
	[2] = "BUFF_bianji_UI",
	[3] = "BUFF_wudi_UI",
	[4] = "BUFF_fuhuo_UI",
}

local MOJIE_EFFECT_2 = {
	[1] = "Item_26700",
	[2] = "Item_26701",
	[3] = "Item_26702",
	[4] = "Item_26703",
}

local MOJIE_EFFECT = {
	[1] = "Item_26700_01",
	[2] = "Item_26701_01",
	[3] = "Item_26702_01",
	[4] = "Item_26703_01",
}

local MOJIE_GET = {
	[1] = TabIndex.treasure_choujiang,
	[2] = TabIndex.treasure_choujiang2,
	[3] = TabIndex.treasure_choujiang3,
	-- [4] = TabIndex.treasure_choujiang4,
}

function MojieView:__init()
	self.ui_config = {
		{"uis/views/player_prefab", "BaseMoJiePanel"},
		{"uis/views/player_prefab", "MojieView"},
	}

	self.skill_id = 0
	self.skill_level = 0
	self.toggles = {}
	self.level_t = {}
	self.mojie_gray_t = {}
	self.is_modal = true
	self.play_audio = true
end

function MojieView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(801 , -23 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["LeftPanel"], Vector3(-571 , -38 , 0 ) , MOVE_TIME)
end

function MojieView:__delete()

end

function MojieView:ReleaseCallBack()
	self.fight_text = nil
	
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	self.toggles = nil
	self.level_t = nil
	self.mojie_gray_t = nil
	self.red_point_list = nil
	self.ring_index = 1

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.skill_effect then
		self.skill_effect:DeleteMe()
		self.skill_effect = nil
	end

end

function MojieView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function MojieView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:UIsMove()
	self.ring_index = tonumber(MojieData.Instance:GetRingIndex()) or 1

	local bundle, asset = ResPath.GetTitleEffect(MOJIE_EFFECT_2[self.ring_index])
	self.node_list["MoJieEffect2"]:ChangeAsset(bundle, asset)
	local bundle, asset = ResPath.GetTitleEffect(MOJIE_EFFECT[self.ring_index])
	self.node_list["MoJieEffect"]:ChangeAsset(bundle, asset)
end

function MojieView:LoadCallBack()

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPowerNum"])

	self.toggles = {}
	self.level_t = {}
	self.mojie_gray_t = {}
	self.red_point_list = {}


	self.attr_t = {}
	self.attr_t_n = {}
	for i = 1, 5 do
		local attr = self.node_list["Attr" .. i]
		if attr then
			table.insert(self.attr_t, attr)
		end
		attr = self.node_list["NextAttr" .. i]
		if attr then
			table.insert(self.attr_t_n,  attr)
		end
	end
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["Stuff"])

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGoGet"].button:AddClickListener(BindTool.Bind(self.OnGotoGet, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnUpGrade, self))
	self.node_list["Skill3"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	-- local start_pos4 = Vector3(0 , 0 , 0)
	-- local end_pos4 = Vector3(0 , 30 , 0)
	-- UITween.MoveLoop(self.node_list["RingIcon1"], start_pos4, end_pos4, 1)

	local start_pos4 = Vector3(0 , 0 , 0)
	local end_pos4 = Vector3(0 , 30 , 0)
	UITween.MoveLoop(self.node_list["MoJieEffect"], start_pos4, end_pos4, 1)


	self.skill_effect = RoleModel.New()
	self.skill_effect:SetDisplay(self.node_list["SkillEffect"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.node_list["SkillEffect"]:SetActive(false)
end


function MojieView:OnFlush()
	self.ring_index = tonumber(MojieData.Instance:GetRingIndex()) or 1

	local ring_level, skill_level = MojieData.Instance:GetMojieLevel(self.ring_index - 1)
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level)

	local n_ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level + 1)
	if nil == ring_cfg then return end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["BtnGoGet"]:SetActive(ring_cfg.open_xunbao <= main_vo.level)

	local ring_attr = CommonDataManager.GetAttributteByClass(ring_cfg)

	local n_ring_attr = CommonDataManager.GetAttributteByClass(n_ring_cfg or ring_cfg)
	local mojie_level = (MojieData.Instance:GetMojieLevel(self.ring_index - 1) or 0)
	local count = 1
	for i, v in ipairs(MojieData.Attr) do
		if self.attr_t[count] and Language.Common.AttrName[v] and ring_attr[v] and (ring_attr[v] > 0) or (ring_attr[v] == 0 and n_ring_attr[v] and n_ring_attr[v] > 0) then
			if string.find(v, "per") or v == "pvp_jianshang" then
				self.attr_t[count].text.text = Language.Common.AttrName[v] .. "："
				local attr = ring_attr[v] and ring_attr[v] / 100 or 0
				local attr_n = n_ring_attr[v] and n_ring_attr[v] / 100 or 0
				self.node_list["AttrValue" .. count].text.text = (ring_attr[v] and ring_attr[v] / 100 or 0) .. "%"
				self.attr_t_n[count].text.text = (attr_n - attr)  .. "%"
				self.node_list["NextNode" .. count]:SetActive(not(mojie_level == MAX_LEVEL) and (attr_n ~= attr))
			else
				local attr = ring_attr[v] or 0
				local attr_n = n_ring_attr[v] or 0
				self.attr_t[count].text.text = Language.Common.AttrName[v] .. "："
				self.node_list["AttrValue" .. count].text.text = (ring_attr[v] or 0)
				self.attr_t_n[count].text.text = (attr_n - attr)
				self.node_list["NextNode" .. count]:SetActive(not(mojie_level == MAX_LEVEL) and (attr_n ~= attr))
			end
			self.attr_t_n[count]:SetActive(true)
			count = count + 1
		end
	end
	for i = count, 5 do
		self.attr_t[i]:SetActive(false)
	end

	if self.fight_text and self.fight_text.text then
		if mojie_level == 0 then
			local attr_no_parcet_list = CommonDataManager.GetAttributteNoParcent(n_ring_attr)
			self.fight_text.text.text = CommonDataManager.GetCapability(attr_no_parcet_list)
		else
			local attr_no_parcet_list = CommonDataManager.GetAttributteNoParcent(ring_attr)
			self.fight_text.text.text = CommonDataManager.GetCapability(attr_no_parcet_list)
		end
	end

	self.node_list["Name"].text.text = ring_cfg.mojie_name

	self:FlushItemMojie()
	local has_stuff = ItemData.Instance:GetItemNumInBagById(ring_cfg.up_level_stuff_id)
	local is_enable = n_ring_cfg and has_stuff >= ring_cfg.up_level_stuff_num or false
	UI:SetButtonEnabled(self.node_list["BtnUpGrade"], is_enable)

	self.node_list["CellItem"]:SetActive(n_ring_cfg ~= nil)
	local has_skill_mjlevel, has_skill_slevel, skill_id, mojie_name =  MojieData.Instance:GetMojieOpenLevel(self.ring_index - 1)
	local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
	self.skill_id = skill_id
	self.skill_level = skill_level
	if nil ~= skill_cfg then
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetRoleSkillIcon(skill_cfg.skill_icon))
	end
	if skill_level < has_skill_slevel then
		self.node_list["TxtSkill3"].text.text = string.format(Language.Mojie.MojieSkillOpen, has_skill_slevel)
		--self.node_list["TxtSkill3"]:SetActive(true)
		UI:SetGraphicGrey(self.node_list["ImgIcon"], true)
	else
		--self.node_list["TxtSkill3"]:SetActive(false)
		UI:SetGraphicGrey(self.node_list["ImgIcon"], false)

	end
	
	self.node_list["TxtBtnUpGrade"].text.text = (n_ring_cfg == nil and Language.Common.MaxLv or (ring_level > 0 and Language.Common.Up or Language.Common.Activate))

	self.node_list["TxtName1"]:SetActive(not (mojie_level == 0))
	self.node_list["TxtName1"].text.text = "Lv." .. mojie_level
	self.node_list["RedPoint1"]:SetActive(MojieData.Instance:IsShowMojieRedPoint(self.ring_index - 1))
	self.node_list["RemindBtnUpGrade"]:SetActive(MojieData.Instance:IsShowMojieRedPoint(self.ring_index - 1))
	self.node_list["Effect"]:SetActive(MojieData.Instance:IsShowMojieRedPoint(self.ring_index - 1))
	local bundle, asset = ResPath.GetItemIcon(MojieData.ITEM_ID_T[self.ring_index - 1])
	self.node_list["RingIcon1"].image:LoadSprite(bundle, asset,
		function ()
			self.node_list["RingIcon1"].image:SetNativeSize()
		end
		)

	-- local skill_type = skill_id ~= PASSIVE_TYPE and Language.Common.ZhuDongSkill or Language.Common.BeiDongSkill
	self.node_list["SkillType"].text.text = skill_cfg.skill_name
	self.node_list["TxtSkilldesc"].text.text = Language.Mojie.SkillDesc[self.ring_index]

end

function MojieView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	--self:FlushItemMojie()
	self:Flush()
end

function MojieView:FlushItemMojie()
	local ring_level, skill_level = MojieData.Instance:GetMojieLevel(self.ring_index - 1)
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level)
	if ring_cfg then
		local has_stuff = ItemData.Instance:GetItemNumInBagById(ring_cfg.up_level_stuff_id)
		local stuff_format = "<color=#%s>%d</color><color=#b7d3f9> / %d</color>"
		local stuff_color = has_stuff < ring_cfg.up_level_stuff_num and "F9463B" or "89F201"
		self.node_list["ItemNumber"].text.text = string.format(stuff_format, stuff_color, has_stuff, ring_cfg.up_level_stuff_num)
		self.stuff_cell:SetData({item_id = ring_cfg.up_level_stuff_id, num = 1, is_bind = 0})
	end
end

function MojieView:OnGotoGet()
	ViewManager.Instance:Open(ViewName.Treasure, MOJIE_GET[self.ring_index])
end

function MojieView:OnUpGrade()
	MojieCtrl.SendMojieUplevelReq(self.ring_index - 1)
end

function MojieView:OnClickSkill()
	local level = self.skill_level == 0 and 1 or self.skill_level
	TipsCtrl.Instance:ShowSkillViewSpecial(self.skill_id, level, self.skill_level > 0)
end

function MojieView:OnClickHelp()
	local tip_id = 5
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end
