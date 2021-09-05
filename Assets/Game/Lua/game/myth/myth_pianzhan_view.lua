local SINGLE_LIST_ICON_COUNT = 4
local LIST_MAX_COUNT = 5
local ATTR_LIST_NUM = 5

MythPianZhangView = MythPianZhangView or BaseClass(BaseRender)

function MythPianZhangView:__init()
	self.now_fight_text = CommonDataManager.FightPower(self, self.node_list["NowPower"])
	self.next_fight_text = CommonDataManager.FightPower(self, self.node_list["NextPower"])
end

function MythPianZhangView:__delete()
	if self.myth_item_cell ~= nil then
		self.myth_item_cell:DeleteMe()
		self.myth_item_cell = nil 
	end

	for k,v in pairs(self.now_list) do
		v:DeleteMe()
	end
	self.now_list = {}

	for k,v in pairs(self.next_list) do
		v:DeleteMe()
	end
	self.next_list = {}
	self.eff_obj = nil
	self.item_cell_list = {}
	self.now_fight_text = nil
	self.next_fight_text = nil
end

--初始化滑动条
function MythPianZhangView:InitScroller()
	--当前属性
	self.nowattr_list_delegate = self.node_list["NowAttrContent"].list_simple_delegate
	self.nowattr_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNowAttrNumberOfCells, self)
	self.nowattr_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNowAtrrView, self)

	--下一阶属性
	self.next_attr_list_delegate = self.node_list["NextAttrContent"].list_simple_delegate
	self.next_attr_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNextAttrNumberOfCells, self)
	self.next_attr_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNextAtrrView, self)
end

function MythPianZhangView:UIsMove()
	local under_pos = self.node_list["Bottom"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["Bottom"], Vector3(under_pos.x, under_pos.y - 140, under_pos.z), 0.5)
	local right_pos = self.node_list["LeftBar"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["LeftBar"], Vector3(right_pos.x - 195, right_pos.y, right_pos.z), 0.5)
	local up_btn_pos = self.node_list["Middle"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["Middle"], Vector3(up_btn_pos.x, up_btn_pos.y - 140, up_btn_pos.z), 0.5)
	UITween.AlpahShowPanel(self.node_list["Middle"], true, 0.5)
	local top_pos = self.node_list["TipsBtn"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["TipsBtn"], Vector3(top_pos.x, top_pos.y + 240, top_pos.z), 0.5)
end

function MythPianZhangView:OpenCallBack()

end

function MythPianZhangView:LoadCallBack()
	self.index = 1
	self.list_index = 1
	self.item_cell_list = {}
	self.now_list = {}
	self.next_list = {}
	self.item_list = {}

	self.node_list["TipsBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["SelectedContentButton"].button:AddClickListener(BindTool.Bind(self.OnClickMyth, self))

	self.node_list["Arrow"]:SetActive(false)

	self.myth_item_cell = ItemCell.New()
	self.myth_item_cell:SetInstanceParent(self.node_list["StuffItem"])

	self.leftBarList = {}
	for i = 1, LIST_MAX_COUNT do
		self.leftBarList[i] = {}
		self.node_list["SelectBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end

	self:InitScroller()
	self:UpdateList()
	self:Flush()
end

function MythPianZhangView:UpdateList()
	self.node_list["SelectBtn" .. self.index].accordion_element.isOn = false
	self.node_list["List" .. self.index]:SetActive(false)
	local list = MythData.Instance:GetMythPianZhangType()
	local count = #list
	self.item_list = {}
	self.is_load = true
	for i = 1, count do
		if list[i] ~= nil then
			local name = list[i][1].chpater_name
			self.node_list["SelectBtn" .. i]:SetActive(true)
			self.node_list["SelectBtnText" .. i].text.text = name
			local list_count = #list[i]
			for i1 = 1, list_count do
				self:LoadCell(i, list[i][i1].chpater_id)
			end
		end
	end
	if count == LIST_MAX_COUNT then
		return
	end
	for i = count + 1, LIST_MAX_COUNT do
		self.node_list["SelectBtn" .. i]:SetActive(false)
	end
	self:Flush()
end

function MythPianZhangView:LoadCell(index, chapter_id)
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. chapter_id)
	res_async_loader:Load("uis/views/myth_prefab", "ChapterLeftItem", nil, function(prefab)

		if nil == prefab then
			return
		end
		local obj = ResMgr:Instantiate(prefab)
		local obj_transform = obj.transform
		obj_transform:SetParent(self.node_list["List" .. index].transform, false)

		local item_cell = ShenHuaItemCell.New(obj)
		item_cell:SetCallBack(BindTool.Bind(self.OnClickCallBcak, self))
		item_cell:SetIndex(chapter_id)
		item_cell:SetToggleGroup(self.node_list["ToggleGroup"].toggle_group)
		item_cell:SetToggle(self.index == chapter_id)

		local chapter_list = MythData.Instance:GetChapterListByIndex(chapter_id)
		if next(chapter_list) == nil then
			return
		end
		local level = chapter_list.level or 0
		if chapter_list.level == 0 then
			level = 1
		else
			level = level
		end
		local data = MythData.Instance:GetChapterCfg(chapter_id, level)
		item_cell:SetData(data)

		self.item_list[#self.item_list + 1] = obj_transform
		if self.item_cell_list[index] == nil then
			self.item_cell_list[index] = {}
		end
		local num = #self.item_cell_list[index] + 1
		self.item_cell_list[index][num] = item_cell

		self:CheckIsSelect()
		self:Flush()
	end)
end

function MythPianZhangView:CheckIsSelect()
	self.node_list["SelectBtn" .. self.index].accordion_element.isOn = false
	self.node_list["SelectBtn" .. self.index].accordion_element.isOn = true
end

function MythPianZhangView:SetSelectItem()
	if self.item_cell_list[self.list_index] == nil then
		return
	end
	local cell = self.item_cell_list[self.list_index][1]
	if cell == nil then
		return
	end
	local index = cell:GetIndex()
	cell:SetToggle(true)
	self.index = index
	self:Flush()
end

function MythPianZhangView:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
end

function MythPianZhangView:OnClickCallBcak(cell)
	if self.index == cell.index then
		return
	end
	self.index = cell.index
	self:Flush()
end

function MythPianZhangView:GetNowAttrNumberOfCells()
	return ATTR_LIST_NUM
end

function MythPianZhangView:RefreshNowAtrrView(cell,data_index)
	local index = data_index +1
    local attr_cell = self.now_list[cell]

    if nil == attr_cell then
        attr_cell = ShenHuaAttrCell.New(cell.gameObject)
        self.now_list[cell] = attr_cell
    end

	local chapter_list = MythData.Instance:GetChapterListByIndex(self.index)
	if next(chapter_list) == nil then
		return
	end
    local level = chapter_list.level or 0
    local max_level = MythData.Instance:GetPianZhangMaxLevelByIndex(self.index)
    if level == 0 then
    	self.node_list["NowAtrr"]:SetActive(false)
    	self.node_list["Arrow"]:SetActive(false)
		self.node_list["Bg1"]:SetActive(false)
    	self.node_list["Bg2"]:SetActive(true)
    else
    	self.node_list["NowAtrr"]:SetActive(true)
    	self.node_list["Bg1"]:SetActive(true)
		self.node_list["Bg2"]:SetActive(false)
    	self.node_list["TitleText1"].text.text = Language.ShenHua.AttrTitle[2]
    	if level == max_level then
    		self.node_list["Arrow"]:SetActive(false)
    		self.node_list["Bg1"]:SetActive(false)
    		self.node_list["Bg2"]:SetActive(true)
    	else
    		self.node_list["Arrow"]:SetActive(true)
    	end
    	local data = MythData.Instance:GetChapterNowAttr(self.index ,level)
    	self.now_list[cell]:SetData(data[index])
    end
end

function MythPianZhangView:GetNextAttrNumberOfCells()
	return ATTR_LIST_NUM
end

function MythPianZhangView:RefreshNextAtrrView(cell,data_index)
	local index = data_index +1
    local attr_cell = self.next_list[cell]

    if nil == attr_cell then
        attr_cell = ShenHuaAttrCell.New(cell.gameObject)
        self.next_list[cell] = attr_cell
    end

	local chapter_list = MythData.Instance:GetChapterListByIndex(self.index)
	if next(chapter_list) == nil then
		return
	end
    local level = chapter_list.level or 0
    level = level + 1
    local max_level = MythData.Instance:GetPianZhangMaxLevelByIndex(self.index)
    if level == max_level + 1 then
    	self.node_list["NextAtrr"]:SetActive(false)
    	self.node_list["Arrow"]:SetActive(false)
    else
    	self.node_list["NextAtrr"]:SetActive(true)
    	if level  == 1 then
    		self.node_list["TitleText2"].text.text = Language.ShenHua.AttrTitle[1]
    		self.node_list["Arrow"]:SetActive(false)
    	else
    		self.node_list["TitleText2"].text.text = Language.ShenHua.AttrTitle[3]
    		self.node_list["Arrow"]:SetActive(true)
    	end
    	local data = MythData.Instance:GetChapterNextAttr(self.index ,level)
    	self.next_list[cell]:SetData(data[index])
    end
end

function MythPianZhangView:FlushLeftList()
	for k,v in pairs(self.item_cell_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				local chapter_id = v1:GetChapterID()
				local chapter_list = MythData.Instance:GetChapterListByIndex(chapter_id)
				if next(chapter_list) == nil then
					return
				end
				local level = chapter_list.level or 0
				if chapter_list.level == 0 then
					level = 1
				else
					level = level
				end
				local data = MythData.Instance:GetChapterCfg(chapter_id, level)
				v1:SetData(data)
			end
		end
	end
	for i = 1, LIST_MAX_COUNT do
		self.node_list["BtnRightActive" .. i]:SetActive(self.list_index == i)
	end
end

function MythPianZhangView:FlushSelectBtnRed()
	local list = MythData.Instance:GetMythPianZhangType()
	local count = #list
	for i = 1, count do
		if list[i] ~= nil then
			if self.item_cell_list[i] then
				for k,v in pairs(self.item_cell_list[i]) do
					if v:GetIsShowRed() then
						self.node_list["RedPoint" .. i]:SetActive(true)
						break
					end
					self.node_list["RedPoint" .. i]:SetActive(false)
				end
			end
		end
	end
end

function MythPianZhangView:OnFlush()
	self:FlushLeftList()
	self:FlushSelectBtnRed()

	-- 刷新属性列表
	self.node_list["NowAttrContent"].scroller:RefreshAndReloadActiveCellViews(true)
	self.node_list["NextAttrContent"].scroller:RefreshAndReloadActiveCellViews(true)

	-- 根据等级获取配置表，判断是否已满级
	local chapter_cfg = {}
	local cur_level = MythData.Instance:GetPianZhangCurLevel(self.index)
	local max_level = MythData.Instance:GetPianZhangMaxLevelByIndex(self.index)
	if cur_level <= 0 then
		chapter_cfg = MythData.Instance:GetChapterCfg(self.index, cur_level + 1)
		UI:SetButtonEnabled(self.node_list["SelectedContentButton"], true)
		self.node_list["ButtonText"].text.text = Language.ShenHua.ActivePianZhang
	elseif cur_level >= max_level then
		chapter_cfg = MythData.Instance:GetChapterCfg(self.index, cur_level)
		UI:SetButtonEnabled(self.node_list["SelectedContentButton"], false)
		self.node_list["ButtonText"].text.text = Language.ShenHua.Manji
	else
		chapter_cfg = MythData.Instance:GetChapterCfg(self.index, cur_level + 1)
		UI:SetButtonEnabled(self.node_list["SelectedContentButton"], true)
		self.node_list["ButtonText"].text.text = Language.ShenHua.UpgradePianZhang
	end

	-- 篇章是否可激活
	local is_can_active, open_level = MythData.Instance:GetPianZhangIsCanActive(self.index)
	if is_can_active then
		self.node_list["OpenTips"]:SetActive(false)
	else
		self.node_list["OpenTips"]:SetActive(true)
		local chapter_name = MythData.Instance:GetPianZhangNameByIndex(self.index - 1)
		local chapter_quality = MythData.Instance:GetPianZhangQualityByIndex(self.index - 1)
		if chapter_quality > 0 then
			chapter_name = ToColorStr(chapter_name, SOUL_NAME_COLOR[chapter_quality])
			self.node_list["OpenTips"].text.text = string.format(Language.ShenHua.PianZhangOpenTextTips, chapter_name, open_level)
		end
	end

	-- 升级材料
	local stuff_item = chapter_cfg.stuff_id1
	local stuff_in_bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item.item_id)
	if stuff_in_bag_num >= chapter_cfg.stuff_id1.num then
		self.node_list["TextNum"].text.text = "<color='#00ff00'>"..stuff_in_bag_num.."</color>".." / "..stuff_item.num
	else
		self.node_list["TextNum"].text.text = "<color='#89F201'>"..stuff_in_bag_num.."</color>".." / "..stuff_item.num
	end
	if cur_level >= max_level then
		self.node_list["TextNum"].text.text = "<color=#ffffff>- / -</color>"
	end
	self.myth_item_cell:SetData({item_id = stuff_item.item_id})
	self.myth_item_cell:SetItemNumVisible(false)

	-- 战力
	local nowattr_value = MythData.Instance:GetNowAttrValue() or 0
	local nextattr_value = MythData.Instance:GeNextAttrValue() or 0
	if self.now_fight_text and self.now_fight_text.text then
		self.now_fight_text.text.text = nowattr_value
	end
	if self.next_fight_text and self.next_fight_text.text then
		self.next_fight_text.text.text = nextattr_value
	end

	local bundle, asset = ResPath.GetMythImg("myth_icon_"..(self.index))
	self.node_list["ItemCell"].image:LoadSprite(bundle, asset,function()
		self.node_list["ItemCell"].image:SetNativeSize()
	end)
	local effect_name = MythData.Instance:GetPianZhangEffectByIndex(self.index)
	if effect_name ~= "" and self.last_effect_index ~= self.index then
		self:LoadEffect(effect_name)
	end
end

function MythPianZhangView:LoadEffect(asset)
	if asset == nil or asset == "" then
		return
	end
	self.last_effect_index = self.index
	local bundle = "effects/prefab/ui_x/"..asset.."_prefab"
	self.eff_obj = self.node_list["EffectRoot"]
	local async_loader = AllocAsyncLoader(self, "buy_effect_loader")
	async_loader:SetParent(self.eff_obj.transform)
	async_loader:Load(bundle, asset, function(obj)
		if not IsNil(obj) then
			local transform = obj.transform
			transform.localScale = Vector3(1, 1, 1)
		end
	end)
end

function MythPianZhangView:OnClickMyth()
	MythCtrl.Instance:SendCSMythOpera(MYTH_OPERA_TYPE.MYTH_OPERA_TYPE_UPLEVEL,self.index)
	self:Flush()
end

function MythPianZhangView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(333)
end

----------------------------ItemCell-------------------------------
ShenHuaItemCell = ShenHuaItemCell or BaseClass(BaseCell)

function ShenHuaItemCell:__init(instance)
	self.is_show_red = false

	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["itemcell"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))
end

function ShenHuaItemCell:__delete()

end

function ShenHuaItemCell:OnFlush()
	if self.data == nil then 
		return
	end

	self.is_show_red = MythData.Instance:GetPianzhangItemRedPoint(self.index)
	self.node_list["RedPoint"]:SetActive(self.is_show_red)

	local bundle, asset = ResPath.GetItemIcon(MythData.Instance:GetPianZhangIconId(self.index))
	self.node_list["itemcell"].image:LoadSprite(bundle, asset)
	self.node_list["Name"].text.text = self.data.name

	local is_activite = MythData.Instance:GetPianZhangIsOpen(self.data.chpater_id)
	if is_activite then
		UI:SetGraphicGrey(self.node_list["itemcell"], false)
		local show_level = self.data.level - 1
		self.node_list["Level"].text.text = show_level..Language.ShenHua.Zhang
	else
		UI:SetGraphicGrey(self.node_list["itemcell"], true)
		self.node_list["Level"].text.text = ToColorStr(Language.ShenHua.NoActivite, TEXT_COLOR.RED)
	end
end

function ShenHuaItemCell:OnClick()
	self.call_back(self)
end

function ShenHuaItemCell:SetIndex(index)
	self.index = index
end

function ShenHuaItemCell:SetToggle(flag)
	self.node_list["Toggle"].toggle.isOn = flag
end

function ShenHuaItemCell:SetToggleGroup(toggle_group)
	self.node_list["Toggle"].toggle.group = toggle_group
end

function ShenHuaItemCell:SetCallBack(call_back)
	self.call_back = call_back
end

function ShenHuaItemCell:GetChapterID()
	if self.data == nil then
		return 0
	end

	return self.data.chpater_id or 0
end

function ShenHuaItemCell:GetIsShowRed()
	return self.is_show_red
end

function ShenHuaItemCell:OnClickTip()
	local attr_data = {}
	local lingwu_attr_data = {}
	local attr_list = CommonStruct.AttributeNoUnderline()
	local data = MythData.Instance:GetChpaterList()[self.index]
	local level = data.level
	local resonance_level = MythData.Instance:GetCurGongMingLevel(self.index)
	if level ~= 0 then
		local item_id = MythData.Instance:GetPianZhangItem(self.index)
		local name = MythData.Instance:GetChapterCfg(self.index,level).name
		local lingwu_level = MythData.Instance:GetLingWuLevelById(self.index)
		lingwu_attr_data = MythData.Instance:GetLingWuItemAttr(self.index, lingwu_level)
		local base_attr_data = MythData.Instance:GetChapterNowAttr(self.index, level)
		local gongming_total_attr_list = MythData.Instance:GetGongMingTotalAttr(self.index)
		local base_attr = {}
		local lingwu_attr = {}
		local gongming_attr = {}
		attr_data[1] = base_attr_data
		attr_data[2] = lingwu_attr_data
		attr_data[3] = gongming_total_attr_list
		attr_data.item_id = item_id
		for k,v in pairs(base_attr_data) do 
			base_attr[v.name] = v.value
		end
		base_attr = CommonDataManager.GetGoddessAttributteNoUnderline(base_attr)
		for k,v in pairs(lingwu_attr_data) do 
			lingwu_attr[v.name] = v.value
		end
		for k,v in pairs(gongming_total_attr_list) do 
			gongming_attr[v.name] = v.value
		end
		local attr1 = CommonDataManager.GetAttributteByClass(base_attr)
		local base_cap = CommonDataManager.GetCapabilityCalculation(attr1)
		local attr2 = CommonDataManager.GetAttributteByClass(gongming_attr)
		local gongming_cap = CommonDataManager.GetCapabilityCalculation(attr2)
		local all_cap = base_cap + gongming_cap
		attr_data.chapter_id = self.index
		attr_data.name = name
		attr_data.level = level
		attr_data.resonance_level = resonance_level
		attr_data.lingwu_level = lingwu_level
		attr_data.all_cap = all_cap

		MythCtrl.Instance:SetDataAndOepnEquipTip(attr_data,MythEquipTip.FromView.MythViewPianZhanView,nil,close_call_back)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenHua.PleasJiHuo)
	end
end

-----------------属性----------------------------
ShenHuaAttrCell = ShenHuaAttrCell or BaseClass(BaseCell)
function ShenHuaAttrCell:__init()

end

function ShenHuaAttrCell:__delete()

end

function ShenHuaAttrCell:OnFlush()
	if self.data == nil then
		self.node_list["ShenHuaAttrItem"]:SetActive(false)
		return
	end
	self.node_list["ShenHuaAttrItem"]:SetActive(true)
	local attr_name = Language.ShenHua.MythAttrNameNoUnderline[self.data.name]..":"
	local value_text = self.data.value
	if self.data.name == "per_pofang" or self.data.name == "per_mianshang" then
		value_text = value_text / 100
		value_text = value_text.."%"
	end
	self.node_list["AttrName"].text.text = string.format("%s <color=#89F201>%s</color>", attr_name, value_text)
end
