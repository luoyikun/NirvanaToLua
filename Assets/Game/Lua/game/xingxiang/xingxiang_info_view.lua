XingXiangInfoView = XingXiangInfoView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local MOVE_TIME = 0.5
local CELL_OF_PAGE = 3
function XingXiangInfoView:__init()
	self.node_list["BtnSuit"].button:AddClickListener(BindTool.Bind(self.OpenAttrView, self))
	self.node_list["Tips"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list["BtnActive"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	self.node_list["BtnL"].button:AddClickListener(BindTool.Bind(self.OnClickLeft, self))
	self.node_list["BtnR"].button:AddClickListener(BindTool.Bind(self.OnClickRight, self))
	self.node_list["BtnJingHua"].button:AddClickListener(BindTool.Bind(self.OnClickJingHuaItem, self))
	

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])

	self.page_simple_delegate = self.node_list["ListView"].page_simple_delegate
	self.page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetListNumOfCells, self)
	self.page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.cell_list = {}
	self.cur_index = 1
	self.cur_title = 1

	self.cur_suipian_index = 1

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["NeedItem"])

	self.list_data = XingXiangData.Instance:GetListData()
end

function XingXiangInfoView:__delete()
	self.fight_text = nil

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end

end

function XingXiangInfoView:LoadCallBack()
	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.ResoleXingXiang, self))
end

function XingXiangInfoView:ResoleXingXiang()
	ViewManager.Instance:Open(ViewName.XingXiangRecycle)
end

function XingXiangInfoView:CloseCallBack()

end

function XingXiangInfoView:GetListNumOfCells()
	return GetListNum(self.list_data)
end

function XingXiangInfoView:RefreshView(data_index, cell)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = OneCardCell.New(cell.gameObject)
		boss_cell.parent = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.list_data[data_index - 1])
end

function XingXiangInfoView:OnClickUpLevel()
	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	local max_level = XingXiangData.Instance:GetMaxLevel()
	if shengxiao_data[self.cur_index].level < max_level then
		XingXiangCtrl.Instance:SendUseShengXiao(ZODIAC_OPERA_TYPE.ZODIAC_OPERA_TYPE_LEVELUP, self.cur_index - 1)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.XingXiang.ErrorTips2)
	end
end

function XingXiangInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(337)
end

function XingXiangInfoView:OpenAttrView()
	local attr_list = XingXiangData.Instance:GetShengxiaoTotalAttr()
	TipsCtrl.Instance:ShowAttrView(attr_list, nil, "xingxiang")
end

function XingXiangInfoView:OnClickJingHuaItem()
	local item_data = {item_id = 90802}
	TipsCtrl.Instance:OpenItem(item_data)
end

function XingXiangInfoView:OnClickActive()
	local shengxiao_list = XingXiangData.Instance:GetXingXiangBagData()
	local item_index = nil
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.cur_index)

	for k,v in pairs(shengxiao_list) do
		local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(self.cur_index - 1, self.cur_suipian_index - 1)
		if stuff_id  == v.item_id and self.cur_suipian_index - 1 == v.suipian_index then
			item_index = k - 1
		end 
	end

	if item_index == nil and flag_num < 4 then 
		-- SysMsgCtrl.Instance:ErrorRemind(Language.XingXiang.ErrorTips)
		return
	end

	XingXiangCtrl.Instance:SendUseShengXiao(ZODIAC_OPERA_TYPE.ZODIAC_OPERA_TYPE_ACTIVATE, item_index)
	XingXiangCtrl.Instance:SendUseShengXiao(ZODIAC_OPERA_TYPE.ZODIAC_OPERA_TYPE_ALL_INFO)
end

function XingXiangInfoView:OnFlush()
	self.node_list["ListView"].list_view:Reload()

	local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(self.cur_index - 1, self.cur_suipian_index - 1)
	local data = {item_id = stuff_id}
	self.item:SetData(data)
	self.item:SetItemNumVisible(true, 1)



	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	if shengxiao_data == nil then return end

	local cur_attr_list = XingXiangData.Instance:GetCurAttr(self.cur_index)
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.cur_index)
	local data_list = XingXiangData.Instance:GetCurDataList(self.cur_index)

	local flag_data = bit:d2b(shengxiao_data[self.cur_index].activate_flag)
	local is_true = flag_data[32 - self.cur_suipian_index + 1] == 1
	self:IsShowActivePanel(not is_true and flag_num < 4)

	if data_list == nil then return end
	if flag_num == 0 then
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
	end

	for i = 1, 4 do  
		local attr_value = 0
		if cur_attr_list[i].attr_type >= GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI and cur_attr_list[i].attr_type <=  GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER then
			attr_value = cur_attr_list[i].attr_value / 100 .. "%"
		else
			attr_value = cur_attr_list[i].attr_value
		end




		local str = string.format(Language.XingXiang.AttrTypeName[cur_attr_list[i].attr_type], attr_value)
		local attr_txt = ToColorStr(str, TEXT_COLOR.RED)
		self.node_list["Lock" .. i]:SetActive(true)
		self.node_list["Arrow" .. i]:SetActive(false)
		if (i == 1 and flag_num >= 1) or (i == 2 and flag_num >= 2) or (i == 3 and flag_num >= 3) or (i == 4 and flag_num >= 4) then
			attr_txt = ToColorStr(str, TEXT_COLOR.WHITE)
			self.node_list["Lock" .. i]:SetActive(false)
		end
		self.node_list["AttrTxt" .. i].text.text = attr_txt
	end

	self.node_list["Level"]:SetActive(flag_num == 4)
	self.node_list["Botton"]:SetActive(flag_num == 4)
	

	local max_level = XingXiangData.Instance:GetMaxLevel()
	self.node_list["LevelTxt"].text.text = "Lv." .. shengxiao_data[self.cur_index].level

	local level_cfg = XingXiangData.Instance:GetXingXiangLevelCfg(self.cur_index)
	local level_o = {}   -- 当前属性
	local level_n = {}	 -- 下一级属性
	for k,v in pairs(level_cfg) do
		if v.level == shengxiao_data[self.cur_index].level then
			table.insert(level_o , v)
		end
		if v.level == shengxiao_data[self.cur_index].level + 1 and shengxiao_data[self.cur_index].level + 1 <= max_level then
			table.insert(level_n , v)
		end
	end

	if flag_num < 4 and flag_num > 0 then
		if self.fight_text and self.fight_text.text then
			local zhan_li_num = XingXiangData.Instance:GetZhanDouLi(data_list)
			self.fight_text.text.text = zhan_li_num
		end
	elseif flag_num == 4 then
		for i = 1, 3 do
			self.node_list["Arrow" .. i]:SetActive(true)
		end
	
		if shengxiao_data[self.cur_index].level + 1 <= max_level then
			for i = 1,3 do
				local attr_value_o = 0
				local attr_value_n = 0

				if cur_attr_list[i].attr_type >= GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI and cur_attr_list[i].attr_type <=  GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER then
					attr_value_o = level_o[1]["attr_value_" .. i - 1] / 100 .. "%"
				else
					attr_value_o = level_o[1]["attr_value_" .. i - 1]
				end

				if cur_attr_list[i].attr_type >= GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI and cur_attr_list[i].attr_type <=  GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER then
					attr_value_n = level_n[1]["attr_value_" .. i - 1] / 100 .. "%"
				else
					attr_value_n = level_n[1]["attr_value_" .. i - 1]
				end

				self.node_list["UpLevelTxt" .. i].text.text = attr_value_n - attr_value_o
			end
		end

		for i = 1, 3 do
			self.node_list["Arrow" .. i]:SetActive(shengxiao_data[self.cur_index].level < max_level)
		end

		
		if data_list then
			for i = 1,3 do
				local attr_value = 0
				if cur_attr_list[i].attr_type >= GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI and cur_attr_list[i].attr_type <=  GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER then
					attr_value = level_o[1]["attr_value_" .. i - 1] / 100 .. "%"
				else
					attr_value = level_o[1]["attr_value_" .. i - 1]
				end
				self.node_list["AttrTxt" .. i].text.text = string.format(Language.XingXiang.AttrTypeName[data_list[i].attr_type], attr_value)
			end
		end

		if self.fight_text and self.fight_text.text and level_o then
			local zhan_li_num = XingXiangData.Instance:GetZhanDouLi(level_o)
			self.fight_text.text.text = zhan_li_num
		end
	end

	local jinghua_num = XingXiangData.Instance:GetJingHuangNum()
	
	local jinghua_data = XingXiangData.Instance:GetCurNeedNum(self.cur_index)
	

	if jinghua_num < jinghua_data then
		jinghua_num = ToColorStr(jinghua_num, TEXT_COLOR.RED)
	else
		jinghua_num = ToColorStr(jinghua_num, TEXT_COLOR.GREEN)
	end
	self.node_list["NeedTxt"].text.text = string.format(Language.XingXiang.NeedNum, jinghua_num, jinghua_data)

	if shengxiao_data[self.cur_index].level >= max_level then
		self.node_list["BtnUpLevelText"].text.text = Language.Common.MaxLv
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"], false)
		self.node_list["NeedTxt"].text.text = Language.XingXiang.MaxTxt
	else
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"], true)
		self.node_list["BtnUpLevelText"].text.text = Language.Common.Up
	end
	self.node_list["BtnL"]:SetActive(self.cur_title > 1)
	self.node_list["BtnR"]:SetActive(self.cur_title < 4)
	self:FlushRedPoint()
	-- self.node_list["Botton2"]:SetActive(flag_num < 4)
end

function XingXiangInfoView:OnClickLeft()
	if self.cur_title > 1 then
		self.cur_title = self.cur_title - 1
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(self.cur_title - 1)
		-- self:Flush()
	end
end

function XingXiangInfoView:OnClickRight()
	if self.cur_title < 4 then
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(self.cur_title)
		self.cur_title = self.cur_title + 1
		-- self:Flush()
	end
end

function XingXiangInfoView:FlushRedPoint()
	local shengxiao_list = XingXiangData.Instance:GetXingXiangBagData()
	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	local flag1, flag2 = false, false
	self.node_list["RedL"]:SetActive(false)
	self.node_list["RedR"]:SetActive(false)

	if shengxiao_list then
		self.node_list["RedPoint"]:SetActive(next(shengxiao_list) ~= nil)
	end
	
	if shengxiao_list and shengxiao_data then
		for k,v in pairs(shengxiao_list) do
			if flag1 and flag2 then
				return
			end
			local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(v.zodiac_index, v.suipian_index)
			local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(v.zodiac_index + 1)
			local max_level = XingXiangData.Instance:GetZodiacMaxLevel(v.zodiac_index)
			if shengxiao_data[v.zodiac_index + 1] then
				local level = shengxiao_data[v.zodiac_index + 1].level
				local flag_data = bit:d2b(shengxiao_data[v.zodiac_index + 1].activate_flag)
				if flag_data[32 -  v.suipian_index] ~= 1 and stuff_id == v.item_id and flag_num < 4 and level < max_level then
					if v.zodiac_index < (self.cur_title - 1) * CELL_OF_PAGE then
						self.node_list["RedL"]:SetActive(true)
						flag1 = true
					elseif v.zodiac_index >= (self.cur_title) * CELL_OF_PAGE then
						self.node_list["RedR"]:SetActive(true)
						flag2 = true
					end
				end 
			end
		end
	end
end

function XingXiangInfoView:OnValueChanged()
	self.cur_title = math.ceil(self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition / 0.25)
	if self.cur_title <= 0 then
		self.cur_title = 1
	elseif self.cur_title >= 4 then
		self.cur_title = 4
	end
	local title_bundle, title_asset = ResPath.GetXingXiangTitle(self.cur_title)
	if title_bundle and title_asset then
		self.node_list["Img_title"].image:LoadSprite(title_bundle, title_asset)
	end
	self:Flush()
end

function XingXiangInfoView:IsShowActivePanel(enable)
	self.node_list["Botton2"]:SetActive(enable)
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.cur_index)
	UI:SetButtonEnabled(self.node_list["BtnActive"], enable)
	self.node_list["HasActive"]:SetActive(not enable and flag_num < 4)
	if enable then
		self.node_list["ActiveTxt"].text.text = Language.Common.Activate
	else
		self.node_list["ActiveTxt"].text.text = Language.Common.YiActivate
	end
end

function XingXiangInfoView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(943, -18, 0 ) , MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["LeftPanel"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
end

function XingXiangInfoView:FlushAll()
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_view:JumpToIndex(0)
end



OneCardCell = OneCardCell or BaseClass(BaseCell)

function OneCardCell:__init()
	for i = 1, 4 do
		self.node_list["Card" .. i].button:AddClickListener(BindTool.Bind(self.OnClickCard, self, i))
	end
end

function OneCardCell:__delete()
	self.parent = nil
end

function OneCardCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function OneCardCell:OnClickCard(index)
	self:IsShowActivePanel(index)
	if self.parent and self.data then
		if self.data.shengxiao then
			self.parent.cur_index = self.data.shengxiao + 1
		end
		self.parent.cur_title = self.data.index
		self.parent.cur_suipian_index = index
	end
	
	self.parent:Flush()
	local shengxiao_list = XingXiangData.Instance:GetXingXiangBagData()
	local item_index = nil
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.data.shengxiao + 1)
	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	local flag_data = bit:d2b(shengxiao_data[self.data.shengxiao + 1].activate_flag)
	if flag_data[32 - index + 1] == 1 then
		return
	end
	

	if shengxiao_list then
		for k,v in pairs(shengxiao_list) do
			local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(self.data.shengxiao, index - 1)
			if stuff_id  == v.item_id and index - 1 == v.suipian_index then
				item_index = k - 1
			end 
		end
	end
	
	if item_index == nil and flag_num < 4 then 
		-- SysMsgCtrl.Instance:ErrorRemind(Language.XingXiang.ErrorTips)
		return
	end

	XingXiangCtrl.Instance:SendUseShengXiao(ZODIAC_OPERA_TYPE.ZODIAC_OPERA_TYPE_ACTIVATE, item_index)
	XingXiangCtrl.Instance:SendUseShengXiao(ZODIAC_OPERA_TYPE.ZODIAC_OPERA_TYPE_ALL_INFO)

end


function OneCardCell:IsShowActivePanel(index)
	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	local flag_data = bit:d2b(shengxiao_data[self.data.shengxiao + 1].activate_flag)
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.data.shengxiao + 1)
	local is_true = flag_data[32 - index + 1] == 1
	if self.parent.node_list then
		self.parent:IsShowActivePanel(not is_true and flag_num < 4)
		-- self.parent.node_list["Botton2"]:SetActive(not is_true and flag_num < 4)
	end
end

function OneCardCell:OnFlush()
	if self.data == nil then
		return
	end
	local bundle1, asset1 = ResPath.GetRawImage("card" .. self.data.shengxiao)
	if bundle1 and asset1 then
		self.node_list["Bg"].raw_image:LoadSprite(bundle1, asset1, function()
		self.node_list["Bg"].raw_image:SetNativeSize()
		end)
	end
	local shengxiao_data = XingXiangData.Instance:GetXingXiangData()
	local shengxiao_list = XingXiangData.Instance:GetXingXiangBagData()
	local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(self.data.shengxiao + 1)
	local flag_data = bit:d2b(shengxiao_data[self.data.shengxiao + 1].activate_flag)
	local max_level = XingXiangData.Instance:GetZodiacMaxLevel(self.data.shengxiao)
	if shengxiao_data == nil then return end
	
	for i = 1, 4 do
		local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(self.data.shengxiao, i - 1)
		local item_cfg, _ = ItemData.Instance:GetItemConfig(stuff_id)
		
		local is_true = flag_data[32 - i + 1] == 1
		if item_cfg then
			local bundle, asset = ResPath.GetXingXiangCardBg(item_cfg.color)
			if bundle and asset then
				self.node_list["CardObj" .. i].image:LoadSprite(bundle, asset)
				self.node_list["PinZhiImg"].image:LoadSprite(bundle, asset)
			end
		end

		
		self.node_list["bg" .. i]:SetActive(not is_true)
		self.node_list["CardObj" .. i]:SetActive(flag_num < 4)
	end

	self.node_list["PinZhiImg"]:SetActive(flag_num >= 4)


	local level = shengxiao_data[self.data.shengxiao + 1].level
	
	local name = self.data.name
	local str = ""
	str = ToColorStr(name, TEXT_COLOR.WHITE)

	if self.parent.cur_index == self.index then
		str = ToColorStr(name, TEXT_COLOR.YELLOW)
	end
	self.node_list["SelectImg"]:SetActive(self.parent.cur_index == self.index)

	self.node_list["Txt_Name"].text.text = str

	local jinghua_num = XingXiangData.Instance:GetJingHuangNum()
	local jinghua_data = XingXiangData.Instance:GetCurNeedNum(self.data.shengxiao + 1)

	self.node_list["RedPoint"]:SetActive(jinghua_num >= jinghua_data and flag_num >= 4 and level < max_level)

	for i = 1,4 do
		self.node_list["CardObj" .. i].animator:SetBool("fold", false)
		if shengxiao_list then
			for k,v in pairs(shengxiao_list) do
				local stuff_id = XingXiangData.Instance:GetStuffIdByIndex(self.index - 1, i - 1)
				if self.index - 1 == v.zodiac_index  and flag_data[32 -  v.suipian_index] ~= 1 and stuff_id == v.item_id then
				 	self.node_list["CardObj" .. i].animator:SetBool("fold", level < max_level and flag_num < 4)
				end 
			end
		end
		
	end

end