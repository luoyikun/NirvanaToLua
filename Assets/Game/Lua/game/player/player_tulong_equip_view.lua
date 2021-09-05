TulongEquipView = TulongEquipView or BaseClass(BaseRender)
local TOGGLE_TL = 1
local TOGGLE_CS = 2
function TulongEquipView:__init(instance, parent_view)
	TulongEquipView.Instance = self
	
	self.parent_view = parent_view
	self.tab_index = TOGGLE_TL
	self.cur_select_index = 0
	self.equip_item_list = {}
	for i = 1, TulongEquipData.EQUIP_MAX_PART do
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self.node_list["Item"..i])
		self.equip_item_list[i]:SetToggleGroup(self.root_node.toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i - 1))
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == i - 1)
		self.equip_item_list[i]:SetInteractable(true)
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerNumberTxt"])
	self.cur_equip_item = ItemCell.New()
	self.cur_equip_item:SetInstanceParent(self.node_list["EquipItem"])

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self.node_list["ConsumeItem"])
	-- self:FlushRemind()

	self.attr_add_list = {}
	self.special_name_list = {}

	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelpBtn, self))
	-- self.node_list["Tab1"].toggle:AddClickListener(BindTool.Bind(self.OnClickTulong, self))
	-- self.node_list["Tab2"].toggle:AddClickListener(BindTool.Bind(self.OnClickChuanshi, self))
	-- self.node_list["EffectBtn"].button:AddClickListener(BindTool.Bind(self.OnClickEffectBtn, self))
	
end

function TulongEquipView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}
	self.parent_view = nil

	if self.consume_item then
		self.consume_item:DeleteMe()
		self.consume_item = nil
	end

	if self.cur_equip_item then
		self.cur_equip_item:DeleteMe()
		self.cur_equip_item = nil
	end

	self.fight_text = nil
end

function TulongEquipView:OpenCallBack(show_index)
	-- if show_index == TabIndex.role_chuanshi_equip then
	-- 	self.tab_index = TOGGLE_CS
	-- 	self.node_list["Tab2"].toggle.isOn = true
	-- else
	-- 	self.tab_index = TOGGLE_TL
	-- 	self.node_list["Tab1"].toggle.isOn = true
	-- end
	self:Flush()
end

function TulongEquipView:OnClickUpLevel()
	if self.tab_index == TOGGLE_TL then
		TulongEquipCtrl.Instance:SendTulongUpLevel(self.cur_select_index)
	elseif self.tab_index == TOGGLE_CS then
		TulongEquipCtrl.Instance:SendChuanshiUpLevel(self.cur_select_index)
	end
end

-- function TulongEquipView:OnClickTulong()
-- 	self.tab_index = TOGGLE_TL
-- 	self:DoPanelTweenPlay()
-- 	self:Flush()
-- end

-- function TulongEquipView:OnClickChuanshi()
-- 	self.tab_index = TOGGLE_CS
-- 	self:DoPanelTweenPlay()
-- 	self:Flush()
-- end

function TulongEquipView:OnClickEffectBtn()
	TipsCtrl.Instance:ShowTulongEffectView()
end

function TulongEquipView:OnClickHelpBtn()
	local tips_id = 234
	if self.tab_index == TOGGLE_CS then
		tips_id = 235
	end
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function TulongEquipView:OnClickItem(index)
	-- for k,v in pairs(self.equip_item_list) do
	-- 	v:ShowHighLight(index == self.cur_select_index)
	-- end
	self.cur_select_index = index
	self.equip_item_list[index + 1]:ShowHighLight(index == self.cur_select_index)
	self:FlushRightPanel()
end

function TulongEquipView:OnFlush(param_t)
	local show_index = PlayerCtrl.Instance.view:GetShowIndex()
	if show_index == TabIndex.role_chuanshi_equip then
		self.tab_index = TOGGLE_CS
	else
		self.tab_index = TOGGLE_TL
	end
	self:FlushLeftEquipList()
	self:FlushRightPanel()
	-- self:FlushRemind()
end

-- function TulongEquipView:FlushRemind()
-- 	self.node_list["Remind1"]:SetActive(TulongEquipData.Instance:GetShenEquipRemind() ~= 0)
-- 	self.node_list["Remind2"]:SetActive(TulongEquipData.Instance:GetCSShenEquipRemind() ~= 0)
-- end

local attr_extra_t = {"extra_gongji", "extra_fangyu", "extra_maxhp", }
local attr_special_t = {"pvp_shanghai_jianmian", "pvp_shanghai_jiacheng",}
function TulongEquipView:FlushRightPanel()
	-- self.node_list["NoteSpecialAttribute"]:SetActive(self.tab_index == TOGGLE_TL)
	-- self.node_list["DisplaySpecial"]:SetActive(not (self.tab_index == TOGGLE_TL))
	-- self.node_list["EffectBtn"]:SetActive(not (self.tab_index == TOGGLE_TL))
	self.node_list["TxtSpecialTitle"].text.text = Language.Role.TulongSpecialTitleName[1]
	local equip_info = TulongEquipData.Instance:GetEquipData(self.tab_index, self.cur_select_index)
	if nil == equip_info then return end
	local asset, bundle = TulongEquipData.Instance:GetTulongEquipIconRes(self.tab_index, self.cur_select_index)
	self.cur_equip_item.node_list["Icon"]:SetActive(true)
	self.cur_equip_item.node_list["Icon"].image:LoadSprite(asset, bundle)
	self.cur_equip_item:ShowStrengthLable(equip_info.level > 0)
	self.cur_equip_item:SetStrength(equip_info.level)
	local cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, self.cur_select_index, equip_info.level)
	local next_cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, self.cur_select_index, equip_info.level + 1)
	local color = math.ceil(equip_info.level / 5)
	color = color < 6 and color or 6
	color = color > 0 and color or 1
	local color_cfg = nil
	if self.tab_index == TOGGLE_CS  then
		local item_id  =  cfg and cfg.stuff_id or next_cfg.stuff_id
		 color_cfg = ItemData.Instance:GetItemConfig(item_id)
		if color_cfg == nil then
			return
		end
		color = color_cfg.color
	end
	self.cur_equip_item:SetQualityByColor(color > 0 and color or 1)
	self.cur_equip_item:ShowQuality(color > 0)
	self.cur_equip_item:SetIconGrayScale(equip_info.level <= 0)
	self.cur_equip_item:ShowExtremeEffect(false)
	if color == 5 and equip_info.level > 0 then
		self.cur_equip_item:ShowExtremeEffect(true, 6)
	elseif color == 6 and equip_info.level > 0 then
		self.cur_equip_item:ShowExtremeEffect(true, 10)
	end 

	local equip_cfg = TulongEquipData.Instance:GetTulongEquipCfg(self.tab_index, self.cur_select_index)
	local attr = CommonDataManager.GetAttributteByClass(cfg)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
	if not equip_cfg then return end

	local cap = cfg and CommonDataManager.GetCapabilityCalculation(cfg) or 0
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cap
	end
	
	self.node_list["TxtHPContentValue"].text.text = attr.max_hp
	self.node_list["TxtAtkContentValue"].text.text = attr.gong_ji
	self.node_list["TxtDefContentValue"].text.text = attr.fang_yu
	self.node_list["TxtMZContentValue"].text.text = attr.ming_zhong
	self.node_list["TxtSBContentValue"].text.text = attr.shan_bi
	self.node_list["TxtBJContentValue"].text.text = attr.bao_ji
	self.node_list["TxtJRContentValue"].text.text = attr.jian_ren

	if self.tab_index == TOGGLE_TL then
		self.node_list["NoteSpecialAttribute"]:SetActive(false)
		self.node_list["SpecialTitle"]:SetActive(false)
		self.node_list["Item"].transform:SetLocalPosition(5, -160, 0)
		self.node_list["BtnUp"].transform:SetLocalPosition(5, -271, 0)
	else
		self.node_list["NoteSpecialAttribute"]:SetActive(true)
		self.node_list["SpecialTitle"]:SetActive(true)
		
		self.node_list["Item"].transform:SetLocalPosition(-116, -270, 0)
		self.node_list["BtnUp"].transform:SetLocalPosition(34, -271, 0)
	end
	local name = nil ~= cfg and cfg.name or next_cfg.name
	if color == 7 then color = 6 end
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. name .. "</color>"
	self.node_list["TxtName"].text.text = name_str
	self.node_list["TxtLevel"].text.text = equip_info.level > 0 and  "+" .. equip_info.level or ""

	self.node_list["NoteHPContent"]:SetActive(attr.max_hp > 0 or next_attr.max_hp > 0)
	self.node_list["NoteAtkContent"]:SetActive(attr.gong_ji > 0 or next_attr.gong_ji > 0)
	self.node_list["NoteDefContent"]:SetActive(attr.fang_yu > 0 or next_attr.fang_yu > 0)
	self.node_list["NoteMZContent"]:SetActive(attr.ming_zhong > 0 or next_attr.ming_zhong > 0)
	self.node_list["NoteSBContent"]:SetActive(attr.shan_bi > 0 or next_attr.shan_bi > 0)
	self.node_list["NoteBJContent"]:SetActive(attr.bao_ji > 0 or next_attr.bao_ji > 0)
	self.node_list["NoteJRContent"]:SetActive(attr.jian_ren > 0 or next_attr.jian_ren > 0)

	local is_max_level = false
	local euqip_max_level = equip_cfg[#equip_cfg].level
	if euqip_max_level and equip_info.level >= euqip_max_level then
		is_max_level = true
	end

	local is_active = nil ~= next_cfg and not is_max_level
	self.node_list["NoteHPAddContent"]:SetActive(is_active)
	self.node_list["NoteAtktAddContent"]:SetActive(is_active)
	self.node_list["NoteDefAddContent"]:SetActive(is_active)
	self.node_list["NoteMZAddContent"]:SetActive(is_active)
	self.node_list["SBAddContent"]:SetActive(is_active)
	self.node_list["BJAddContent"]:SetActive(is_active)
	self.node_list["JRAddContent"]:SetActive(is_active)
	self.node_list["text_num"]:SetActive(not is_max_level)

	if is_max_level then
		self.node_list["TxtUpButton"].text.text = Language.Common.YiManJi
	end
	UI:SetGraphicGrey(self.node_list["BtnUp"], not is_max_level)
	UI:SetButtonEnabled(self.node_list["BtnUp"], not is_max_level)


	if self.tab_index == TOGGLE_TL then 		-- 屠龙面板属性
		for i = 1, 3 do
			local spec_key = attr_extra_t[i] or attr_extra_t[1]
			local cur_value = (cfg and cfg[spec_key] or 0)
			local dif, _ = TulongEquipData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, spec_key)
			if is_max_level then
				self.node_list["TxtAddContent" .. i].text.text = "(" .. equip_info.level .. "/" .. equip_info.level .. Language.Common.Ji ..")"
				self.node_list["NoteSpcAttr" .. i .. "AddContent"].transform:FindHard("up").gameObject:SetActive(false)
			else
				-- local dif = cfg and (next_cfg[spec_key] - cfg[spec_key]) or next_cfg[spec_key]
				local to_level = (math.floor(equip_info.level / 10) + 1) * 10
				local str = "<color=#89f201>".. dif .. "</color>" .. "(" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  "/" .. to_level .. Language.Common.Ji ..")"
				self.node_list["TxtAddContent" .. i].text.text = str
				self.node_list["NoteSpcAttr" .. i .. "AddContent"].transform:FindHard("up").gameObject:SetActive(true)
			end
			self.node_list["TxtContent" .. i].text.text = string.format(Language.Player.AttrName, Language.Role.TulongSpecialNameList[spec_key] or "", cur_value)
			self.node_list["SpcAttrContent" .. i]:SetActive(true)
		end
	elseif self.tab_index == TOGGLE_CS then     -- 弑神面板属性
		for i = 1, 2 do
			local spec_key = attr_special_t[i] or attr_special_t[1]
			local cur_value = (cfg and cfg[spec_key] or 0)
			local dif, _ = TulongEquipData.Instance:GetNextUpShishenAttr(self.cur_select_index, equip_info.level, spec_key)
			if cfg then
				if dif == 0 and cfg[spec_key] == 0 then
					self.node_list["SpcAttrContent" .. i]:SetActive(false)
				else
					self.node_list["SpcAttrContent" .. i]:SetActive(true)
				end
			else
				if dif == 0 then
					self.node_list["SpcAttrContent" .. i]:SetActive(false)
				else
					self.node_list["SpcAttrContent" .. i]:SetActive(true)
				end
			end

			if is_max_level then
				self.node_list["TxtAddContent" .. i].text.text = "(" .. equip_info.level .. "/" .. equip_info.level .. Language.Common.Ji ..")"
				self.node_list["NoteSpcAttr" .. i .. "AddContent"].transform:FindHard("up").gameObject:SetActive(false)
			else
				-- local dif = cfg and (next_cfg[spec_key] - cfg[spec_key]) or next_cfg[spec_key]
				local to_level = (math.floor(equip_info.level / 4) + 1) * 4
				local str = "<color=#89f201>".. dif / 100 .. "%</color>" .. "(" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  "/" .. to_level .. Language.Common.Ji ..")"
				self.node_list["TxtAddContent" .. i].text.text = str
				self.node_list["NoteSpcAttr" .. i .. "AddContent"].transform:FindHard("up").gameObject:SetActive(true)
			end
			self.node_list["TxtContent" .. i].text.text = string.format(Language.Role.TulongSpecialNameList[spec_key] or "", cur_value / 100)
		end	
		self.node_list["SpcAttrContent3"]:SetActive(false)
	end

	if nil == next_cfg then
		local data = {}
		data.item_id = cfg and cfg.stuff_id
		self.consume_item:SetData(data)
		self.node_list["BtnRemind"]:SetActive(false)
		return
	end

	local dif_attr = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	self.node_list["TxtHPContentUpvalue"].text.text = dif_attr.max_hp
	self.node_list["TxtAtkContentUpvalue"].text.text = dif_attr.gong_ji
	self.node_list["TxtDefContentUpvalue"].text.text = dif_attr.fang_yu
	self.node_list["TxtMZContentUpvalue"].text.text = dif_attr.ming_zhong
	self.node_list["TxtSBContentUpvalue"].text.text = dif_attr.shan_bi
	self.node_list["TxtBJContentUpvalue"].text.text = dif_attr.bao_ji
	self.node_list["TxtJRContentUpvalue"].text.text = dif_attr.jian_ren

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)
	local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	numcolor  = ToColorStr(num, txt_color)
	numcolor1 = ToColorStr(" / " .. next_cfg.stuff_num, TEXT_COLOR.GREEN_4)

	self.node_list["text_num"].text.text = numcolor .. numcolor1
	self.node_list["BtnRemind"]:SetActive(num >= next_cfg.stuff_num)
	--"<color=" .. txt_color .. ">" .. "(" .. num .. "/" .. next_cfg.stuff_num .. ")" .. "</color>"
	self.node_list["TxtUpButton"].text.text = equip_info.level > 0 and Language.Common.Up or Language.Common.Activate
end

function TulongEquipView:FlushLeftEquipList()
	for i = 1, TulongEquipData.EQUIP_MAX_PART do
		local index = i - 1
		if self.equip_item_list[i] then
			local asset, bundle = TulongEquipData.Instance:GetTulongEquipIconRes(self.tab_index, index)
			self.equip_item_list[i].node_list["Icon"]:SetActive(true)
			self.equip_item_list[i].node_list["Icon"].image:LoadSprite(asset, bundle)

			local equip_info = TulongEquipData.Instance:GetEquipData(self.tab_index, index)
			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)
			local cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, index, equip_info.level)
			local color = math.ceil(equip_info.level / 5)
			color = color < 6 and color or 6
			if self.tab_index == TOGGLE_CS then
				if cfg then
					local item_id  = cfg.stuff_id
					local color_cfg = ItemData.Instance:GetItemConfig(item_id)
					color = color_cfg.color or 0
				else
					color = 0
				end
			end
			self.equip_item_list[i]:SetQualityByColor(color > 0 and color or 1)
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)
			self.equip_item_list[i]:ShowExtremeEffect(false)
			if color == 5 and equip_info.level > 0 then
				self.equip_item_list[i]:ShowExtremeEffect(true, 6)
			elseif color == 6 and equip_info.level > 0 then
				self.equip_item_list[i]:ShowExtremeEffect(true, 10)
			end 

			local next_cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, index, equip_info.level + 1)
			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				self.node_list["Item".. i].transform.parent.transform:FindHard("Btn-Improve").gameObject:SetActive(num >= next_cfg.stuff_num)
			else
				self.node_list["Item".. i].transform.parent.transform:FindHard("Btn-Improve").gameObject:SetActive(false)
			end
		end
	end
	local capability = TulongEquipData.Instance:GetShenEquipTotalCapability(self.tab_index)
	
end

function TulongEquipView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightIcon"], PlayerData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["InfoView"], PlayerData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

