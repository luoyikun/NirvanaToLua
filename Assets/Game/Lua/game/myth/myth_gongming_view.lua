local IconCount = 4
local LIST_MAX_COUNT = 5
local ATTR_LIST_NUM = 4
MythGongMingView = MythGongMingView or BaseClass(BaseRender)

function MythGongMingView:__init(instance, mother_view)
	
end

function MythGongMingView:__delete()
	self.cur_fight_power = nil
	if self.stuff_item ~= nil then
		self.stuff_item:DeleteMe()
		self.stuff_item = nil 
	end

	for k,v in pairs(self.now_attr_gongming_list) do
		v:DeleteMe()
	end
	self.now_attr_gongming_list = {}

	for k,v in pairs(self.next_attr_gongming_list) do
		v:DeleteMe()
	end
	self.next_attr_gongming_list = {}

	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	self.eff_obj = nil

	self.item_cell_list = {}

	self.now_fight_text = nil
	self.next_fight_text = nil
end

function MythGongMingView:UIsMove()
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

--初始化滑动条
function MythGongMingView:InitScroller()
 	-- 转转盘
	for i = 1, 3 do
		self.scroller_list[i] = {}
		self.scroller_list[i].cell = ShenHuaScroller.New(self.node_list["Scroller" .. i])
		self.scroller_list[i].cell:SetParentIndex(self.index)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
	end

	-- 当前共鸣属性
	self.now_attr_gongming_list = {}
	self.now_attr_gongming = self.node_list["NowAttrContent"]
	self.now_attr_gongming_delegate = self.now_attr_gongming.list_simple_delegate
    self.now_attr_gongming_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNowAttrGongmingNumberOfCells, self)
    self.now_attr_gongming_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNowAttrGongmingrView, self)

    -- 下卷共鸣属性
    self.next_attr_gongming_list = {}
	self.next_attr_gongming = self.node_list["NextAttrContent"]
	self.next_attr_gongming_delegate = self.next_attr_gongming.list_simple_delegate
    self.next_attr_gongming_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNextAttrGongmingNumberOfCells, self)
    self.next_attr_gongming_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNextAttrGongmingrView, self)
end

function MythGongMingView:OpenCallBack()
	self:Flush()
end

function MythGongMingView:LoadCallBack()
	self.scroller_list = {}
	self.index = 1
	self.roll = false
	self.is_onclick = false
	self.lock_list = MythData.Instance:GetGongMingLockList(self.index)

	self.node_list["TipsBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["ButtonGongMing"].button:AddClickListener(BindTool.Bind(self.OnClickGongMing, self))

	self.stuff_item = ItemCell.New()
	self.stuff_item:SetInstanceParent(self.node_list["StuffItem"])

	self.leftBarList = {}
	self.item_list = {}
	self.item_cell_list = {}
	for i = 1, LIST_MAX_COUNT do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = self.node_list["SelectBtn" .. i]
		self.leftBarList[i].list = self.node_list["List" .. i]
		self.leftBarList[i].btn_text = self.node_list["SelectBtnText" .. i]
		self.leftBarList[i].red_state = self.node_list["RedPoint" .. i]
		self.node_list["SelectBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end

	self.now_fight_text = CommonDataManager.FightPower(self, self.node_list["NowPower"])
	self.next_fight_text = CommonDataManager.FightPower(self, self.node_list["NextPower"])

	self:InitScroller()
	self:Flush()

	self.list_index = 1
	self:UpdateList()
end

function MythGongMingView:UpdateList()
	self.leftBarList[self.index].select_btn.accordion_element.isOn = false
	self.leftBarList[self.index].list:SetActive(false)
	local list = MythData.Instance:GetMythPianZhangType()
	local count = #list
	self.item_list = {}
	self.is_load = true
	for i = 1, count do
		if list[i] ~= nil then
			local name = list[i][1].chpater_name
			self.leftBarList[i].select_btn:SetActive(true)
			self.leftBarList[i].btn_text.text.text = name
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
		self.leftBarList[i].select_btn:SetActive(false)
	end
	self:Flush()
end

function MythGongMingView:LoadCell(index, chapter_id)
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. chapter_id)
	res_async_loader:Load("uis/views/myth_prefab", "ChapterLeftItem", nil, function(prefab)
		if nil == prefab then
			return
		end
		local obj = ResMgr:Instantiate(prefab)
		local obj_transform = obj.transform
		obj_transform:SetParent(self.leftBarList[index].list.transform, false)

		local item_cell = GongMingItemCell.New(obj)
		item_cell:SetCallBack(BindTool.Bind(self.OnClickCallBcak, self))
		item_cell:SetIndex(chapter_id)
		item_cell:SetToggleGroup(self.node_list["ToggleGroup"].toggle_group)
		item_cell:SetToggle(self.index == chapter_id)
		item_cell:Flush()

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

function MythGongMingView:CheckIsSelect()
	self.leftBarList[self.index].select_btn.accordion_element.isOn = false
	self.leftBarList[self.index].select_btn.accordion_element.isOn = true
end

function MythGongMingView:SetSelectItem()
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

function MythGongMingView:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
end

function MythGongMingView:OnClickCallBcak(cell)
	if self.index == cell.index then
		return
	end
	self.index = cell.index
	self:Flush()
end

-- 当前共鸣属性列表
function MythGongMingView:GetNowAttrGongmingNumberOfCells()
	return ATTR_LIST_NUM
end

function MythGongMingView:RefreshNowAttrGongmingrView(cell,data_index)
	local index = data_index +1
	local attr_cell = self.now_attr_gongming_list[cell]

	if nil == attr_cell then
		attr_cell = AttrGongmingrCell.New(cell.gameObject)
		self.now_attr_gongming_list[cell] = attr_cell
	end
	local level = MythData.Instance:GetCurGongMingLevel(self.index)
	if level <= 0 then
		level = 1
	end
	local gongming_attr = MythData.Instance:GetGongMingTotalAttrByLevel(self.index, level - 1)
	self.now_attr_gongming_list[cell]:SetIndex(index)

	local data = {
		lock_list = self.lock_list,
		attr_list = gongming_attr[index],
	}
	self.now_attr_gongming_list[cell]:SetData(data)
end

-- 下卷共鸣属性列表
function MythGongMingView:GetNextAttrGongmingNumberOfCells()
	return ATTR_LIST_NUM
end

function MythGongMingView:RefreshNextAttrGongmingrView(cell,data_index)
	local index = data_index +1
    local attr_cell = self.next_attr_gongming_list[cell]

    if nil == attr_cell then
        attr_cell = AttrGongmingrCell.New(cell.gameObject)
        self.next_attr_gongming_list[cell] = attr_cell
    end

    local level = MythData.Instance:GetCurGongMingLevel(self.index)
    if level <= 0 then
    	level = 1
    end
    local gongming_attr = MythData.Instance:GetGongMingTotalAttrByLevel(self.index, level)
    self.next_attr_gongming_list[cell]:SetIndex(index + ATTR_LIST_NUM)

    local data = {
    	lock_list = self.lock_list,
    	attr_list = gongming_attr[index],
	}
    self.next_attr_gongming_list[cell]:SetData(data)
end

-- 开始转动
function MythGongMingView:StartRoll(info_list)
	self.info_list = info_list
	self.is_rolling = true
	local index1 = 1
	local index2 = 1
	local index3 = 1
	for k,v in ipairs(self.info_list) do 
		if k == 1 then
			index1 = v
		elseif k == 2 then
			index2 = v
		elseif k == 3 then
			index3 = v
		end
	end
	--0.5秒出结果
	local lock1 = self.lock_list[1]
	local lock2 = self.lock_list[2]
	local lock3 = self.lock_list[3]
	--3个都没锁
	if not lock1 and not lock2 and not lock3 then
		self.scroller_list[1].cell:StartScoller(0.5, index1,1)
		self.scroller_list[2].cell:StartScoller(1, index2,2)
		self.scroller_list[3].cell:StartScoller(1.5, index3,3)
	--一个图标0.5出结果
	elseif lock2 and lock3 then
		self.scroller_list[1].cell:StartScoller(0.5, index1,1)
	elseif lock1 and lock3 then
		self.scroller_list[2].cell:StartScoller(0.5, index2,2)
	elseif lock1 and lock2 then
		self.scroller_list[3].cell:StartScoller(0.5, index3,3)
	--两个图标
	elseif lock2 and not lock1 and not lock3 then
		self.scroller_list[1].cell:StartScoller(0.5, index1,1)
		self.scroller_list[3].cell:StartScoller(1, index3,3)
	elseif lock3 and not lock2 and not lock1 then
		self.scroller_list[1].cell:StartScoller(0.5, index1,1)
		self.scroller_list[2].cell:StartScoller(1, index2,2)
	elseif lock1 and not lock2 and not lock3 then
		self.scroller_list[2].cell:StartScoller(0.5, index2,2)
		self.scroller_list[3].cell:StartScoller(1, index3,3)
	end

	self.has_set_trigger = true
	self.complete_list = {}

end

function MythGongMingView:FlushLeftList()
	for k,v in pairs(self.item_cell_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				v1:Flush()
			end
		end
	end
	for i = 1, LIST_MAX_COUNT do
		self.node_list["BtnRightActive" .. i]:SetActive(self.list_index == i)
	end
end

function MythGongMingView:FlushSelectBtnRed()
	local list = MythData.Instance:GetMythPianZhangType()
	local count = #list
	for i = 1, count do
		if list[i] ~= nil then
			if self.item_cell_list[i] then
				for k,v in pairs(self.item_cell_list[i]) do
					if v:GetIsShowRed() then
						self.leftBarList[i].red_state:SetActive(true)
						break
					end
					self.leftBarList[i].red_state:SetActive(false)
				end
			end
		end
	end
end

function MythGongMingView:OnFlush(param)
	self.lock_list = MythData.Instance:GetGongMingLockList(self.index)
	self:FlushLeftList()
	self:FlushSelectBtnRed()

	local chapter_cfg = MythData.Instance:GetChapterListByIndex(self.index)
	if next(chapter_cfg) == nil then
		return
	end
	local resonance_list = chapter_cfg.resonance_list
	if resonance_list == nil then
		return
	end

	-- 篇章是否开启
	local chapter_is_open, chapter_open_level = MythData.Instance:GetGongMingIsOpenByIndex(self.index)
	if chapter_is_open == false then
		local name = MythData.Instance:GetPianZhangNameByIndex(self.index)
		local quality = MythData.Instance:GetPianZhangQualityByIndex(self.index)
		if quality > 0 then
			name = ToColorStr(name, SOUL_NAME_COLOR[quality])
			self.node_list["NotOpenText"].text.text = string.format(Language.ShenHua.GongMingOpenTextTips, name, chapter_open_level - 1)
		end
	end

	self.node_list["InfoContent"]:SetActive(chapter_is_open)
	self.node_list["InfoBg"]:SetActive(not chapter_is_open)

	self.now_attr_gongming.scroller:ReloadData(0)
	self.next_attr_gongming.scroller:ReloadData(0)

	-- 共鸣等级
	local resonance_max_level = MythData.Instance:GetGongMingMaxLevelByIndex(self.index)
	local resonance_level = resonance_list.resonance_level or 0
	resonance_level = resonance_level == 0 and 1 or resonance_level
	local lock_num = MythData.Instance:GetIsLockNum(self.index)
	if resonance_level == resonance_max_level and lock_num >= 3 then
		UI:SetButtonEnabled(self.node_list["ButtonGongMing"], false)
		self.node_list["GongMingText"].text.text = Language.ShenHua.Manji
	else
		UI:SetButtonEnabled(self.node_list["ButtonGongMing"], chapter_is_open)
		self.node_list["GongMingText"].text.text = Language.ShenHua.UpgradeGongMing
	end

	-- 属性显示
	self.node_list["NowAttr"]:SetActive(true)
	self.node_list["Bg1"]:SetActive(true)
	self.node_list["Bg2"]:SetActive(false)
	self.node_list["NextAttr"]:SetActive(true)
	self.node_list["Arrow"]:SetActive(chapter_is_open)
	if resonance_level <= 1 then
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["NowAttr"]:SetActive(false)
		self.node_list["Bg1"]:SetActive(false)
		self.node_list["Bg2"]:SetActive(true)
	end
	if resonance_level >= resonance_max_level and lock_num >= 3 then
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["NowAttr"]:SetActive(false)
		self.node_list["Bg1"]:SetActive(false)
		self.node_list["Bg2"]:SetActive(true)
	end

	-- 战力
	local cur_power, next_power = MythData.Instance:GetGongMingTotalPowerByLevel(self.index, resonance_level - 1, true)
	if self.now_fight_text and self.now_fight_text.text then
		self.now_fight_text.text.text = cur_power or 0
	end
	if self.next_fight_text and self.next_fight_text.text then
		self.next_fight_text.text.text = next_power or 0
	end

	local pian_zhang_level = MythData.Instance:GetPianZhangCurLevel(self.index)
	if pian_zhang_level <= 0 then
		self.node_list["InfoContent"]:SetActive(true)
	self.node_list["InfoBg"]:SetActive(false)
	end

	local gongming_cfg = MythData.Instance:GetGongmingCfg(self.index, resonance_level)

	-- 升级材料
	local stuff_item = gongming_cfg.stuff_id
	if stuff_item then
		self.stuff_item:SetData({item_id = stuff_item.item_id})
		self.stuff_item:SetItemNumVisible(false)
		local stuff_in_bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item.item_id)
		if stuff_in_bag_num >= stuff_item.num then
			local stuff_need_num = "<color=#00ff00>"..stuff_in_bag_num.."</color>".." / "..stuff_item.num
			self.node_list["TextNum"].text.text = stuff_need_num
			MythData.Instance:SetNotEnougth(true)
		else
			local stuff_need_num = "<color=#89F201>"..stuff_in_bag_num.."</color>".." / "..stuff_item.num
			self.node_list["TextNum"].text.text = stuff_need_num
			MythData.Instance:SetNotEnougth(false)
		end
	end

	if resonance_level >= resonance_max_level then
		self.node_list["TextNum"].text.text = "<color=#ffffff>- / -</color>"
	end
	for i = 1, 3 do
		local bundle, asset = ResPath.GetMythImg("Icon_"..gongming_cfg["position_" .. i])
		self.node_list["Text" .. i].image:LoadSprite(bundle, asset)
		self.node_list["Lock" .. i]:SetActive(self.lock_list[i] ~= nil and self.lock_list[i] or false)
	end
	-- 战力值
	local activite_num = 0
	for k,v in pairs(self.lock_list) do
		if v then
			activite_num = activite_num + 1
		end
	end
	local total_power, active_power = MythData.Instance:GetCurGongMingPower(self.index, resonance_level, activite_num)
	self.node_list["Power"].text.text = total_power

	-- 图标
	local bundle, asset = ResPath.GetMythImg("myth_icon_"..(self.index))
	self.node_list["ItemCell"].image:LoadSprite(bundle, asset, function()
		self.node_list["ItemCell"].image:SetNativeSize()
	end)
	-- 特效
	local effect_name = MythData.Instance:GetPianZhangEffectByIndex(self.index)
	if effect_name ~= "" and self.last_effect_index ~= self.index then
		self:LoadEffect(effect_name)
	end

	for i = 1, 3 do
		self.scroller_list[i].cell:SetParentIndex(self.index)
		self.scroller_list[i].cell:Flush()
	end

	local single_list = MythData.Instance:GetSingleChapterInfo()
	if self.roll then
		self.roll = false
		if next(single_list) ~= nil then
			local cfg = single_list.resonance_list.cur_level_resonance
			self:StartRoll(cfg)
		end
	end
end

function MythGongMingView:LoadEffect(asset)
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

function MythGongMingView:OnClickGongMing()
	local engouth = MythData.Instance:GetNotEnougth()
	if engouth then
		self.roll = true
	else
		self.roll = false
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenHua.LessGongMingStuff)
		return
	end
	MythCtrl.Instance:SendCSMythOpera(MYTH_OPERA_TYPE.MYTH_OPERA_TYPE_RESONANCE, self.index)
end

function MythGongMingView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(334)
end

function MythGongMingView:RollComplete()

end

------------------------------- 共鸣Item -------------------------------
GongMingItemCell = GongMingItemCell or BaseClass(BaseCell)

function GongMingItemCell:__init(instance,parent)
	self.parent = parent
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["itemcell"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))

	self.is_show_red = false
end

function GongMingItemCell:__delete()

end

function GongMingItemCell:OnFlush()
	self.is_show_red = MythData.Instance:GetGongMingItemRedPoint(self.index)
	self.node_list["RedPoint"]:SetActive(self.is_show_red)

	local level = MythData.Instance:GetCurGongMingLevel(self.index)
	local is_activite = level == 0
	if is_activite then
		UI:SetGraphicGrey(self.node_list["itemcell"], true)
		self.node_list["Level"].text.text = ToColorStr(Language.ShenHua.NoActivite, TEXT_COLOR.RED)
	else
		UI:SetGraphicGrey(self.node_list["itemcell"], false)
		self.node_list["Level"].text.text = level..Language.ShenHua.Juan
	end

	local name = MythData.Instance:GetPianZhangNameByIndex(self.index)
	self.node_list["Name"].text.text = name
	local bundle, asset = ResPath.GetItemIcon(MythData.Instance:GetPianZhangIconId(self.index))
	self.node_list["itemcell"].image:LoadSprite(bundle, asset)
end

function GongMingItemCell:OnClick()
	self.call_back(self)
end

function GongMingItemCell:SetIndex(index)
	self.index = index
end

function GongMingItemCell:SetToggle(flag)
	self.node_list["Toggle"].toggle.isOn = flag
end

function GongMingItemCell:SetToggleGroup(toggle_group)
	self.node_list["Toggle"].toggle.group = toggle_group
end

function GongMingItemCell:SetCallBack(call_back)
	self.call_back = call_back
end

function GongMingItemCell:GetIsShowRed()
	return self.is_show_red
end

function GongMingItemCell:OnClickTip()
	local attr_data = {}
	local lingwu_attr_data = {}
	local attr_list = CommonStruct.AttributeNoUnderline()
	local data = MythData.Instance:GetChpaterList()[self.index]
	if not data or not next(data) then return end
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

		MythCtrl.Instance:SetDataAndOepnEquipTip(attr_data,MythEquipTip.FromView.MythGongMingView,nil,close_call_back)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenHua.PleasJiHuo)
	end
end

-------------------------共鸣属性---------------------------
AttrGongmingrCell = AttrGongmingrCell or BaseClass(BaseCell)
function AttrGongmingrCell:__init()

end

function AttrGongmingrCell:__delete()

end

function AttrGongmingrCell:OnFlush()
	if self.data == nil then return end

	local attr_list = self.data.attr_list or {}
	local lock_list = self.data.lock_list or {}
	local attr_name = attr_list.name or "gongji"
	local attr_value = attr_list.value or 0
	if attr_name == "" then
		self.node_list["GongMingAttrItem"]:SetActive(false)
		return
	end
	self.node_list["GongMingAttrItem"]:SetActive(true)

	local activity_num = 0
	for k,v in pairs(lock_list) do
		if v then
			activity_num = activity_num + 1
		end
	end
	local name = Language.ShenHua.MythAttrNameNoUnderline[attr_name]
	local max_num = math.min(self.index, 3 + ATTR_LIST_NUM)

	-- 万分比特殊显示
	for i = 10, 26 do
		if MythGongMingAttrType[i] and attr_name == MythGongMingAttrType[i] then
			attr_value = attr_value / 100
			attr_value = attr_value.."%"
		end
	end

	local active_text = ""
	if self.index > ATTR_LIST_NUM then
		activity_num = activity_num + ATTR_LIST_NUM
		if activity_num >= max_num then
			active_text = ToColorStr(Language.ShenHua.HasActivite, TEXT_COLOR.GREEN_SPECIAL_1)
		else
			active_text = ToColorStr(Language.ShenHua.NotGongMinigActivite, TEXT_COLOR.RED)
		end
	end

	self.node_list["name"].text.text = string.format(Language.ShenHua.GongMingAttrText, name, attr_value, active_text)
end

function AttrGongmingrCell:SetIndex(index)
	self.index = index
end

-----------------------------------------------转盘--------------------------------------------

ShenHuaScroller = ShenHuaScroller or BaseClass(BaseCell)

-- 每个格子的高度
local cell_hight = 80
-- 每个格子之间的间距
local distance = 30
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 149

function ShenHuaScroller:__init(instance)
	self.cell_list = {}
	self.parent_index = 1
	self.target_x = 0
	self.target = 1

	self.zhuanpan_list = {
		index1 = 0,
		index2 = 0,
		index3 = 0,
	}

	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.rect = self.node_list["Rect"]
	self.do_tween_obj = self.node_list["DoTween"]
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = cell_hight - (original_hight - (cell_hight + 2 * distance)) / 2
	-- local offset = 100
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/myth_prefab", "Icon", nil, function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, 6 do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.rect.transform, false)
			obj_transform.localPosition = Vector3(0, -(i - 2) * size + offset, 0)
			local variable_table = U3DNodeList(obj_transform:GetComponent(typeof(UINameTable)), self)
			self.cell_list[i] = variable_table["IconImage"]
			local res_id = i 
			local bundle, asset = ResPath.GetMythImg("Icon_"..res_id + 6)
			variable_table["IconImage"].image:LoadSprite(bundle, asset, function ()
				variable_table["IconImage"].image:SetNativeSize()
			end)
		end
		self:Flush()
	end)
end

function ShenHuaScroller:__delete()
	self:RemoveCountDown()
end

function ShenHuaScroller:OnValueChange(value)
	local x = value.y
end

function ShenHuaScroller:Flush()
	local chapter_list = MythData.Instance:GetChapterListByIndex(self.parent_index) or {}
	local resonance_list = chapter_list.resonance_list or {}
	local cur_level_resonance = resonance_list.cur_level_resonance or {}
	if next(cur_level_resonance) == nil then return end
	if next(self.cell_list) == nil then return end
	local index1 = 3
	local index2 = 3
	local index3 = 3 
	--三个转转图标的位置显示哪个图标
	for k,v in pairs(self.zhuanpan_list) do 
		if k == "index1" then
			if  v >= 150 and v <= 153 then
				index1 = (v % 150) + 1
			elseif v == 149 or v == 155 then
				index1 = 2
			elseif v == 154 then
				index1 = 1
			else
				index1 = 3
			end
		end
		if k == "index2" then
			if v >= 150 and v <= 153 then
				index2 = (v % 150) + 1
			elseif v == 149 or v == 155 then
				index2 = 2
			elseif v == 154 then
				index2 = 1
			else
				index2 = 3
			end
		end
		if k == "index3" then
			if v >= 150 and v <= 153 then
				index3 = (v % 150) + 1
			elseif v == 149 or v == 155 then
				index3 = 2
			elseif v == 154 then
				index3 = 1
			else
				index3 = 3
			end
		end
	end
	for k,v in pairs(cur_level_resonance) do 
		if k == 1 and self.index == 1 then
			if v == 0 then
				local bundle, asset = ResPath.GetMythImg("Icon_"..7)
				self.cell_list[index1].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index1].image:SetNativeSize()
				end)
			else
				local bundle, asset = ResPath.GetMythImg("Icon_"..v + 6)
				self.cell_list[index1].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index1].image:SetNativeSize()
				end)
			end
		elseif k == 2 and self.index == 2 then
			if v == 0 then
				local bundle, asset = ResPath.GetMythImg("Icon_"..7)
				self.cell_list[index2].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index2].image:SetNativeSize()
				end)
			else
				local bundle, asset = ResPath.GetMythImg("Icon_"..v + 6)
				self.cell_list[index2].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index2].image:SetNativeSize()
				end)
			end
		elseif k == 3 and self.index == 3 then 
			if v == 0 then
				local bundle, asset = ResPath.GetMythImg("Icon_"..7)
				self.cell_list[index3].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index3].image:SetNativeSize()
				end)
			else
				local bundle, asset = ResPath.GetMythImg("Icon_"..v + 6)
				self.cell_list[index3].image:LoadSprite(bundle, asset, function ()
					self.cell_list[index3].image:SetNativeSize()
				end)
			end
		end
	end
end

function ShenHuaScroller:StartScoller(time, target,index)
	self.do_tween_obj.transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target or 1
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	if index == 1 then
		self.zhuanpan_list.index1 = self.target_x
	elseif index == 2 then
		self.zhuanpan_list.index2 = self.target_x
	elseif index == 3 then
		self.zhuanpan_list.index3 = self.target_x
	end
	local tween = self.do_tween_obj.transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.1, BindTool.Bind(self.UpdateTime, self))
	self:Flush()
end

function ShenHuaScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
	end
end

function ShenHuaScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function ShenHuaScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function ShenHuaScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ShenHuaScroller:SetIndex(index)
	self.index = index
end

function ShenHuaScroller:SetParentIndex(index)
	self.parent_index = index or 1
end