-- 幻灵 YuanhunContent
SymbolYuanhunView = SymbolYuanhunView or BaseClass(BaseRender)

function SymbolYuanhunView:__init()
	self.model_res = 0
	self.cur_act = false
	self.stuff_item_id = 0
	self.lock_slot_num = 0
	self.lock_slot_flag = 0

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["item"])
	self.stuff_cell:ListenClick(BindTool.Bind(self.SelectStuff, self))

	-- self.lock_cell = ItemCell.New()
	-- self.lock_cell:SetInstanceParent(self.node_list["lock_item"])
	self.cell_list = {}
	self.left_select = 0
	self:InitLeftScroller()

	self.attr_list = {}
	for i = 1, 8 do
		local xilian_element_obj =  self.node_list["Element" .. i]
		local element = yuanhunXiLianElement.New(xilian_element_obj)
		element:SetIndex(i)
		element.parent = self
		table.insert(self.attr_list, element)
	end

	self.select_stuff_cfg = SymbolData.Instance:GetXiLianDefaultInfo()

	self.node_list["BtnLianHun"].button:AddClickListener(BindTool.Bind(self.OnClickXiLian, self))
	self.node_list["Btn_add"].button:AddClickListener(BindTool.Bind(self.SelectStuff, self))
	self.node_list["Btn_help"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"])
end

function SymbolYuanhunView:__delete()
	self.fight_text = nil
	
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	if self.attr_list then
		for k,v in pairs(self.attr_list) do
			v:DeleteMe()
		end
		self.attr_list = nil
	end
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
	-- if self.lock_cell then
	-- 	self.lock_cell:DeleteMe()
	-- 	self.lock_cell = nil
	-- end
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function SymbolYuanhunView:InitLeftScroller()
	local delegate = self.node_list["LeftList"].list_simple_delegate
	-- 生成数量
	self.left_data = SymbolData.Instance:GetElementHeartOpencCfg()
	delegate.NumberOfCellsDel = function()
		return #self.left_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  YuanhunLeftCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.node_list["LeftList"].toggle_group)
		end
		
		target_cell:SetData(self.left_data[data_index + 1])
		target_cell:SetIndex(data_index)
		local info = SymbolData.Instance:GetElementInfo(data_index)
		target_cell:Lock(info ~= nil and info.element_level <= 0)
		target_cell:IsOn(data_index == self.left_select)
		target_cell:SetClickCallBack(BindTool.Bind(self.ClickLeftListCell, self, target_cell))
	end
end

function SymbolYuanhunView:FlushModel(info)
	if info and info.element_level > 0 then
		if nil == self.model then
			self.model = RoleModel.New()
			self.model:SetDisplay(self.node_list["ModelDisplay"].ui3d_display)
		end
		local model_res = SymbolData.ELEMENT_MODEL[info.wuxing_type]
		if self.model_res ~= model_res then
			self.model_res = model_res
			local asset, bundle = ResPath.GetSpiritModel(model_res)
			self.model:SetMainAsset(asset, bundle)
			self.model:SetScale(Vector3(1.7, 1.7, 1.7))
		end
	elseif self.model then
		self.model_res = 0
		self.model:ClearModel()
	end
end

function SymbolYuanhunView:OnClickXiLian()
	if ItemData.Instance:GetItemNumInBagById(self.stuff_item_id) <= 0 and (not self.node_list["toggle"].toggle.isOn or self.select_stuff_cfg.comsume_color >= HunQiData.XiLianStuffColor.RED) then
		-- 物品不足，弹出TIP框
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["toggle"].toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_item_id, nil, 1)
		return
	end

	local has_rare, num = SymbolData.Instance:GetXiLianHasRareById(self.left_select)
	local des = string.format(Language.HunQi.XiLianConfireTips, num)
	local function ok_callback()
		-- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买,
		local is_auto_buy = self.node_list["toggle"].toggle.isOn and 1 or 0
		SymbolCtrl.Instance:SendXilianElementHeartReq(self.left_select, self.lock_slot_flag, self.xilian_comsume_color, is_auto_buy)
	end
	if has_rare then
		TipsCtrl.Instance:ShowCommonAutoView("Symbol_XiLian", des, ok_callback, nil, nil, nil, nil, nil, true, false)
	else
		ok_callback()
	end
end

function SymbolYuanhunView:SelectStuff()
	SymbolCtrl.Instance:OpenSymbolXilianStuffView(BindTool.Bind(self.SelectStuffCallBack, self))
end

function SymbolYuanhunView:SelectStuffCallBack(data)
	self.select_stuff_cfg = data
	self.node_list["toggle"].toggle.isOn = false
	self:Flush()
end

function SymbolYuanhunView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(245)
end

function SymbolYuanhunView:ClickLeftListCell(cell)
	if self.left_select ~= cell.index then
		SymbolData.LOCK = {}
		self.lock_slot_flag = 0
		self.lock_slot_num = 0
		self.left_select = cell.index
		self.select_stuff_cfg = SymbolData.Instance:GetXiLianDefaultInfo()
		self:Flush()
	end
end

function SymbolYuanhunView:OpenCallBack()
	local up_pos = self.node_list["UpPanel"].transform.anchoredPosition
	local left_pos = self.node_list["LeftPanel"].transform.anchoredPosition
	local under_pos = self.node_list["UnderPanel"].transform.anchoredPosition
	local under_center_pos = self.node_list["UnderMove"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["UnderMove"], Vector3(under_center_pos.x, under_center_pos.y - 100, under_center_pos.z))
	UITween.MoveShowPanel(self.node_list["UpPanel"], Vector3(up_pos.x, up_pos.y + 200, up_pos.z))
	UITween.MoveShowPanel(self.node_list["LeftPanel"], Vector3(left_pos.x - 200, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["UnderPanel"], Vector3(under_pos.x, under_pos.y - 300, under_pos.z))

	self.select_stuff_cfg = SymbolData.Instance:GetXiLianDefaultInfo()
	SymbolData.LOCK = {}
	self.lock_slot_flag = 0
	self.lock_slot_num = 0
	self.model_res = 0
	self:Flush()
end

function SymbolYuanhunView:CloseCallBack()
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.Symbol_XiLian = nil
end

function SymbolYuanhunView:UpdateLockPanel()
	local count = 0
	local lock_flag = 0

	for k,v in pairs(SymbolData.LOCK) do
		if v then
			count = count + 1
			lock_flag = lock_flag + math.pow(2 , k)
		end
	end

	self.lock_slot_num = count
	self.lock_slot_flag = lock_flag
	--local lock_cfg = SymbolData.Instance:GetElementXiLianLockCfg(self.lock_slot_num)

	-- if lock_cfg then
	-- 	self.lock_cell:SetData({item_id = lock_cfg.lock_comsume_ID, num = 0})
	-- 	local need = lock_cfg.lock_comsume_item.num
	-- 	local has = ItemData.Instance:GetItemNumInBagById(lock_cfg.lock_comsume_ID)
	-- 	local color = need < has and "#89f201" or COLOR.RED
	-- 	self.node_list["Txt_locknum"].text.text = "<color=" .. color ..">" .. has .. "</color>" .. " / " .. need 
	-- end

	local stuff_cfg = self.select_stuff_cfg
	self.stuff_cell:SetData({item_id = stuff_cfg.consume_item.item_id})
	self.xilian_comsume_color = stuff_cfg.comsume_color
	self.node_list["toggle"]:SetActive(self.xilian_comsume_color < SymbolData.XiLianStuffColor.RED)
	self.stuff_item_id = stuff_cfg.consume_item.item_id
	local num = ItemData.Instance:GetItemNumInBagById(stuff_cfg.consume_item.item_id)
	local lock_cfg = SymbolData.Instance:GetElementXiLianLockCfg(self.lock_slot_num, stuff_cfg.comsume_color)
	local need_num = lock_cfg.lock_comsume_item.num
	local color = num >= need_num and "#89f201" or COLOR.RED
	self.node_list["Txt_num"].text.text = ToColorStr(num , color) .. " / " .. need_num
end

function SymbolYuanhunView:OnFlush(param_t)
	self:InitLeftScroller()
	self:UpdateLockPanel()

	local data = SymbolData.Instance
	local info = data:GetElementInfo(self.left_select)
	self:FlushModel(info)
	self.cur_act = info ~= nil and info.element_level > 0
	local yuanhun_info = data:GetElementXiLianSingleInfo(self.left_select)
	--self.lock_cell.root_node:SetActive(true)
	self.node_list["Txtattr1"].text.text = ""
	self.node_list["Txtattr2"].text.text = ""
	self.node_list["ImgLimit1"].image.enabled = false
	self.node_list["ImgLimit2"].image.enabled = false
	local count_t = {}
	local attr_list = CommonStruct.Attribute()

	if self.cur_act and yuanhun_info then
		local name = Language.Symbol.ElementsName[info.wuxing_type]
		self.node_list["Txt_name"].text.text = Language.Symbol.LvTxt .. info.element_level .. " " .. name
		for k,v in pairs(self.attr_list) do
			local vo = yuanhun_info.slot_list[k]
			if vo then
				local attr_type = data:GetElementXiLianAttr(self.left_select, k - 1)
				attr_list[attr_type] = attr_list[attr_type] + vo.xilian_val
				v:SetData({element_id = self.left_select, slot = k -1, xilian_val = vo.xilian_val, element_attr_type = vo.element_attr_type, open_slot = vo.open_slot, attr_type = attr_type, wuxing_type = info.wuxing_type})
				if vo.open_slot == 1 then
					if count_t[vo.element_attr_type] then
						count_t[vo.element_attr_type] = count_t[vo.element_attr_type] + 1
					else
						count_t[vo.element_attr_type] = 1
					end
				end
			else
				v:SetData({element_id = self.left_select, slot = k -1, open_slot = 0})
			end
		end
		local addition_cfg = SymbolData.Instance:GetElementXiLianAttrAddition(info.wuxing_type)
		if addition_cfg then
			local index = 1
			for i,v in ipairs(addition_cfg) do
				local has_count = count_t[v.element_shuxing_type] or 0
				local color = has_count < v.need_element_shuxing_count and "#f9463b" or "#89F201"
				local add_name = Language.Symbol.Elements[v.element_shuxing_type] or ""
				self.node_list["Txtattr" .. index].text.text = string.format(Language.Symbol.ElementAttrAdd, name, v.add_percent, color, has_count, v.need_element_shuxing_count, add_name)
				self.node_list["ImgLimit" .. index].image.enabled = true
				self.node_list["ImgLimit" .. index].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. v.element_shuxing_type))
				self.node_list["EffLimit" .. index]:ChangeAsset(ResPath.GetHunYinEffect(SymbolData.EFFECT_PATH[v.element_shuxing_type]))
				index = index + 1
			end
		end
	else
		self.node_list["Txt_name"].text.text = ""
		--self.node_list["Txt_locknum"].text.text = ""
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
		--self.lock_cell.root_node:SetActive(false)
		for k,v in pairs(self.attr_list) do
			v:SetData({element_id = self.left_select, slot = k -1, open_slot = 0})
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(attr_list)
	end

	if self.node_list["LeftList"].scroller.isActiveAndEnabled then
		self.node_list["LeftList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end


------------------------------------YuanshuLeftCell-----------------------------------------
YuanhunLeftCell = YuanhunLeftCell or BaseClass(BaseCell)

function YuanhunLeftCell:__init()
	self.node_list["ToggleCell"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClick, self))
end

function YuanhunLeftCell:__delete()

end

function YuanhunLeftCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function YuanhunLeftCell:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function YuanhunLeftCell:Lock(value)
	self.node_list["ToggleCell"].toggle.interactable = not value
	self.node_list["ImgIcon"]:SetActive(not value) 
	self.node_list["BtnLock"]:SetActive(value)
end

function YuanhunLeftCell:OnFlush()
	if nil == self.data then return end
	local info = SymbolData.Instance:GetElementInfo(self.data.id)

	if info and info.element_level > 0 then
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. info.wuxing_type))
		self.node_list["TxtName"].text.text = Language.Symbol.LvTxt .. info.element_level
	else
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_lock"))
		self.node_list["TxtName"].text.text =""
	end
	self.node_list["ImgRed"]:SetActive(false)
end

----------------------------------Elemen1 - 8----------------------------
yuanhunXiLianElement = yuanhunXiLianElement or BaseClass(BaseCell)

function yuanhunXiLianElement:__init()
	self.node_list["BtnLock"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function yuanhunXiLianElement:__delete()
	self.parent = nil
end

function yuanhunXiLianElement:OnClick()
	if not SymbolData.Instance:GetElementXiLianCanChangeLock(self.data.element_id, self.data.slot) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.XilianLockLimit)
		return
	end
	SymbolData.LOCK[self.data.slot] = not SymbolData.LOCK[self.data.slot]
	local lock_img = SymbolData.LOCK[self.data.slot] == true and "icon_lock_close" or "icon_lock_open"
	self.node_list["BtnLock"].image:LoadSprite(ResPath.GetImages(lock_img))
	if self.parent then
		self.parent:UpdateLockPanel()
	end
end

function yuanhunXiLianElement:OnFlush(param_t)
	if not self.data then
		return
	end
	local element_data = SymbolData.Instance
	self.node_list["ImgIcon"]:SetActive(self.data.open_slot == 1)
	self.node_list["BtnLock"]:SetActive(self.data.open_slot == 1)
	UI:SetGraphicGrey(self.node_list["ImageBg"], self.data.open_slot == 0)
	if self.data.open_slot == 0 then
		local open_lv = element_data:GetElementXiLianOpenLevel(self.data.element_id, self.data.slot)
		self.node_list["TxtLimit"].text.text = string.format(Language.Symbol.SymbolXLOpenLevel, open_lv)
		self.node_list["Txt_attr"].text.text = ""
		return
	end

	self.node_list["TxtLimit"].text.text = ""
	local star = element_data:GetElementXiLianAttrStar(self.data.element_id, self.data.slot, self.data.xilian_val)
	local color = TEXT_COLOR.BLUE
	if star >= 9 then
		color = TEXT_COLOR.RED
	elseif star >= 7 then
		color = TEXT_COLOR.ORANGE_3
	elseif star >= 5 then
		color = TEXT_COLOR.PURPLE_3
	end

	local str = Language.Common.AttrName[self.data.attr_type] .. ": <color='".. color .. "'>+" .. self.data.xilian_val .. "(" .. star .. Language.Symbol.Xing .. ")</color>"
	self.node_list["Txt_attr"].text.text = str
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. self.data.element_attr_type))
	if self.data.wuxing_type == self.data.element_attr_type then
		self.node_list["effect"]:SetActive(true)
		self.node_list["effect"]:ChangeAsset(ResPath.GetHunYinEffect(SymbolData.EFFECT_PATH[self.data.element_attr_type]))
		local bundle, asset = ResPath.GetSymbolImage("bg_5")
		self.node_list["ImageBg"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["ImageBg"].image.type = UnityEngine.UI.Image.Type.Simple
	else
		self.node_list["effect"]:SetActive(false)
		local bundle, asset = ResPath.GetSymbolImage("bg_37")
		self.node_list["ImageBg"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["ImageBg"].image.type = UnityEngine.UI.Image.Type.Sliced
	end
	local lock_img = SymbolData.LOCK[self.data.slot] and "icon_lock_close" or "icon_lock_open"
	self.node_list["BtnLock"].image:LoadSprite(ResPath.GetImages(lock_img))
end