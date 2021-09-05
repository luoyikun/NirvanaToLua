BaiZhanSuitView = BaiZhanSuitView or BaseClass(BaseView)

local SUIT_PART_COUNT = 10
local EFFECTSIZE = Vector2(0.7, 0.7, 1)				-- 特效大小
local LASTEFFECTSIZE = Vector2(0.9, 0.9, 1)			-- 最后一个特效大小
local COLORNUM = 2  									-- 不显示特效的最高颜色索引
local CELL_TEXT_LINE_HEIGHT = 25
local RED_EFFECT_COLOR = 5
local FEN_EFFECT_COLOR = 6

function BaiZhanSuitView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/player_prefab", "BaizhanSuit"}
	}
	self.play_audio = true
	self.is_any_click_close = false
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.equip_cell_list = {} 
	self.pos_list = {}
	self.attr_text_list = {}
	self.item_id = 0
end

function BaiZhanSuitView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Player.ShengHunSuit
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.baizhan_suit_list = ForgeData.Instance:GetBaiZhanSuit()
	self.list_view_delegate = self.node_list["List"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.EquipSuitNum, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.EquipSuitCell, self)
	self.pos_list = {}
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if i ~= 0 and i ~= 1 and i ~= 3 then
			local item_baizhan = ItemCell.New()
			item_baizhan:SetInstanceParent(self.node_list["BaiZhanItemCell" .. i]) 
			item_baizhan:SetFromView(TipsFormDef.BAIZHAN_SUIT)
			self.pos_list[i] = item_baizhan
		else
			self.node_list["BaiZhanItemCell" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBigCell, self, i))
		end
	end
	self.baizhan_suit_content = self.node_list["BaiZhanSuitAttrs"].transform
	self.baizhan_suit_attr_list = {}
	for i = 1, self.baizhan_suit_content.childCount do
		self.baizhan_suit_attr_list[#self.baizhan_suit_attr_list + 1] = self.baizhan_suit_content:FindHard("BaiZhanSuitAtt" .. i)
	end	
end

function BaiZhanSuitView:OnClickBigCell(equip_index)
	local data = ForgeData.Instance:GetBaiZhanInfoByOrderPart(self.item_data.order, equip_index)
	if data and data.item_id > 0 then
		TipsCtrl.Instance:OpenItem({item_id = data.item_id, is_bind = 0, num = 1}, TipsFormDef.BAIZHAN_SUIT, nil, nil, nil, nil, nil, nil)
	end
end

function BaiZhanSuitView:__delete()
	self.item_id = 0
	self.baizhan_suit_content = nil
end

function BaiZhanSuitView:SetBaiZhanAttr(item_cfg)
	self.node_list["BaiZhanSuitAttrs"]:SetActive(false)
	self.node_list["BaiZhanSuitName"]:SetActive(false)
	for i = 1, #self.baizhan_suit_attr_list do
		self.baizhan_suit_attr_list[i].gameObject:SetActive(false)
	end		
	
	if EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		local baizhan_order_count_list = {}
		local max_order = ForgeData.Instance:GetBaiZhanListMaxOrder()
		baizhan_order_count_list = ForgeData.Instance:GetBaiZhanOrderCountListAll()

		local name = ForgeData.Instance:GetBaiZhanNameListByOrder(item_cfg.order)
		local cfg = ForgeData.Instance:GetBaiZhanAttrListByOrder(item_cfg.order)
		if name and cfg then
			 -- 同阶装备的数量最大是10
			local suit_had_count, suit_total_count = 0, 0
			if baizhan_order_count_list[item_cfg.order] then
				suit_had_count = baizhan_order_count_list[item_cfg.order]
			end
			if cfg and cfg[#cfg] and cfg[#cfg].same_order_num then
				suit_total_count = cfg[#cfg].same_order_num
			end
			local suit_count_str = ""
			if suit_had_count > 0 and suit_total_count > 0 then
				suit_count_str = "(" .. suit_had_count .. "/" .. suit_total_count .. ")"
			end
			self.node_list["BaiZhanSuitName"].text.text = ToColorStr(name .. suit_count_str, TEXT_COLOR.ORANGE_5)

			local count = 1
			for k, v in ipairs(cfg) do
				local color = TEXT_COLOR.WHITE
				local is_active = false
				if v.same_order_num <= suit_had_count then
					color = TEXT_COLOR.GREEN
					is_active = true
				end

				local suit_str = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), "#FEEFB6FF")
				local suit_str2 = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), "#00000000")
				self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ""
				self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
				count = count + 1				
				for k2, v2 in pairs(Language.Forge.BaiZhanSuitShowType) do
					if v[v2] and v[v2] > 0 then
						local suit_attr = " " .. Language.Forge.BaiZhanSuitShowAttr[v2]

						if string.find(v2, "per") then
							local attr_num = ToColorStr(((v[v2] / 100) .. "%"), color)
							if suit_str then
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str
								self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
								suit_str = nil
								count = count + 1
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(suit_attr, attr_num)
							else
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(suit_attr, attr_num)							
							end
						else
							local attr_num = ToColorStr(v[v2], color)
							if suit_str then
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str
								self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
								suit_str = nil
								count = count + 1
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(suit_attr, attr_num)
							else
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(suit_attr, attr_num)
							end
						end
						self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
						count = count + 1
					end
				end			
			end

			for i = count, #self.baizhan_suit_attr_list do
				self.baizhan_suit_attr_list[i].gameObject:SetActive(false)
			end
			self.node_list["BaiZhanSuitAttrs"]:SetActive(true)
		end
	end
end

-- 自适应高度
function BaiZhanSuitView:GetCellSizeDel(data_index)
	local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)
	local suit_attr_info_list = PlayerData.Instance:GetTotalAttrKey()
	local data = suit_data_list[data_index + 1] or {}
	local show_attri_num = 0
	for k, v in pairs(suit_attr_info_list) do
		if data[v] ~= nil and data[v] > 0 then
			show_attri_num = show_attri_num + 1
		end
	end
	return CELL_TEXT_LINE_HEIGHT * (show_attri_num + 1)
end
	
function BaiZhanSuitView:SuitInfoNum()
	if self.item_data then 
		local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)
		return #suit_data_list
	end

	return 0
end

function BaiZhanSuitView:ReleaseCallBack()
	for _, v in pairs(self.pos_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.pos_list = {}	
	for _, v in pairs(self.equip_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_cell_list = {} 
	self.data_info = nil
	self.list_view_delegate = nil
	self.baizhan_suit_content = nil

	for k, v in pairs(self.baizhan_suit_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.baizhan_suit_attr_list = {}
end

function BaiZhanSuitView:CloseWindow()
	self:Close()
end

function BaiZhanSuitView:EquipSuitNum()
	local suit_list = ForgeData.Instance:GetBaiZhanSuit()
	return #suit_list
end

function BaiZhanSuitView:EquipSuitCell(cell, data_index)
	data_index = data_index + 1
	local equip_cell = self.equip_cell_list[cell]
	if equip_cell == nil then
		equip_cell = BaiZhanSuitInfoCell.New(cell.gameObject)
		self.equip_cell_list[cell] = equip_cell
	end
	equip_cell:SetData(self.baizhan_suit_list[data_index])
	equip_cell:SetClickCallBack(BindTool.Bind(self.OnClickSuitCell, self))
	equip_cell:SetIndex(data_index)
	if self.data_info == nil then 
		self.data_info = self.baizhan_suit_list[data_index]
		self.data_index = data_index
		self:Flush()
	end

	if self.data_index == data_index then 
		equip_cell:SetHigh(true)
	else
		equip_cell:SetHigh(false)
	end
end

function BaiZhanSuitView:OnClickSuitCell(data)
	local last_data_index = self.data_index
	self.data_info = data:GetData()
	self.data_index = data:GetIndex()
	for k, v in pairs(self.equip_cell_list) do
		v:SetHigh(false)
	end
	data:SetHigh(true)
	if last_data_index ~= self.data_index then 
		self.baizhan_suit_list = ForgeData.Instance:GetBaiZhanSuit()
		self:Flush()
	end
end

function BaiZhanSuitView:OpenCallBack()
	self.baizhan_suit_list = ForgeData.Instance:GetBaiZhanSuit()
	if suit_list then
		self.data_info = self.baizhan_suit_list[1]
		self.data_index = 1
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo ~= nil and vo.sex == 1 then
		local bundle, asset = ResPath.GetRawImage("BaiZhanMen")
		self.node_list["SexBg"].raw_image:LoadSprite(bundle, asset, function()
			self.node_list["SexBg"].raw_image:SetNativeSize()
			self.node_list["SexBg"].transform.localPosition = Vector3(130, -8, 0)
		end)	
	else
		local bundle, asset = ResPath.GetRawImage("BaiZhanWomen")
		self.node_list["SexBg"].raw_image:LoadSprite(bundle, asset, function()
			self.node_list["SexBg"].raw_image:SetNativeSize()
			self.node_list["SexBg"].transform.localPosition = Vector3(130, -20, 0)
		end)
	end	
	self:Flush()
end

function BaiZhanSuitView:SetBaiZhanData(baizhan_equiplist, baizhan_order_equiplist)
	if baizhan_equiplist == nil or baizhan_order_equiplist == nil then
		return
	end
	local player_order_list = ForgeData.Instance:GetBaiZhanEquipOrderAll() or {}
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if i ~= 0 and i ~= 1 and i ~= 3 then
			if baizhan_equiplist[i + 1] and baizhan_equiplist[i + 1].item_id > 0 then 
				self.pos_list[i]:SetData(baizhan_equiplist[i + 1])
				self.pos_list[i]:ShowHighLight(false)
				self.pos_list[i]:ShowQuality(true)
				self.pos_list[i]:ListenClick()
				self.pos_list[i]:SetActive(true)
			else
				self.pos_list[i]:SetActive(false)
			end
		else
			if baizhan_equiplist[i + 1] and baizhan_equiplist[i + 1].item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(baizhan_equiplist[i + 1].item_id)
				local bundle1, asset1 = ResPath.GetPlayerImage("color" .. item_cfg.color)
				self.node_list["Quality" .. i].image:LoadSprite(bundle1, asset1)
				self.node_list["DownExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["UpExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["DownExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)
				self.node_list["UpExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)		
				local bundle, asset = ResPath.GetPlayerImage("icon" .. i .. baizhan_order_equiplist[i])
				self.node_list["Icon" .. i].image:LoadSprite(bundle, asset)		
				self.node_list["Grade" .. i].text.text = tostring((baizhan_order_equiplist[i]) .. Language.Common.Jie) or ""
				
				self.node_list["BaiZhanItemCellBG" .. i]:SetActive(false)
				self.node_list["BaiZhanItemCell" .. i]:SetActive(true)
			else
				self.node_list["BaiZhanItemCellBG" .. i]:SetActive(true)
				self.node_list["BaiZhanItemCell" .. i]:SetActive(false)
			end			
		end
		if self.item_data.order == player_order_list[i] then
			self.node_list["Gou" .. i]:SetActive(true)
		else
			self.node_list["Gou" .. i]:SetActive(false)
		end
	end

end

function BaiZhanSuitView:FlushInfo()
	if self.data_info ~= nil then 
		self.item_data = self.data_info
		local item_list = {}
		local grade_attr = CommonStruct.Attribute() 
		
		item_list = ForgeData.Instance:GetBaiZhanSuitInfoByOrder(self.item_data.order)
		
		local baizhan_order_equiplist = {}
		for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
			baizhan_order_equiplist[i] = self.item_data.order
		end
		
		self:SetBaiZhanData(item_list, baizhan_order_equiplist)
		
		if item_list ~= nil and item_list[1] ~= nil then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_list[1].item_id)
			if item_cfg ~= nil then
				self:SetBaiZhanAttr(item_cfg)
			end
		end
		local part_list = ForgeData.Instance:GetBaiZhanAttrListByOrder(self.item_data.order)
		for i, v in pairs(part_list) do
			local attribute = CommonDataManager.GetAttributteByClass(v)
			grade_attr = CommonDataManager.AddAttributeAttr(grade_attr, attribute)
		end

		-- local grade_attr2 = CommonDataManager.AddAttributeAttr(grade_attr, CommonDataManager.GetMainRoleAttr())
		-- local grade_attr3 = CommonStruct.Attribute()
		self.node_list["FightNumber"].text.text = CommonDataManager.GetCapabilityCalculation(grade_attr)
		self.node_list["List"].scroller:RefreshActiveCellViews()
	end
end

function BaiZhanSuitView:OnFlush()
	self:FlushInfo()
end

BaiZhanSuitInfoCell = BaiZhanSuitInfoCell or BaseClass(BaseCell)

function BaiZhanSuitInfoCell:__init()
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.name_outline = self.node_list["Name"].gameObject:GetComponent(typeof(UnityEngine.UI.Outline))
	self.count_outline = self.node_list["Count"].gameObject:GetComponent(typeof(UnityEngine.UI.Outline))
end

function BaiZhanSuitInfoCell:__delete()
	self.name_outline = nil
	self.count_outline = nil
end

function BaiZhanSuitInfoCell:SetHigh(is_high)
	if nil == self.data then
		return
	end
	self.node_list["High"]:SetActive(is_high)
	self.name_outline.enabled = is_high
	self.count_outline.enabled = is_high
end

function BaiZhanSuitInfoCell:OnFlush()
	if self.data == nil then return end
	self.node_list["Name"].text.text = ToColorStr(self.data.name, SOUL_NAME_COLOR[self.data.color]) or ""
	self.node_list["Count"].text.text = self:GetItemCountTxt()
end

function BaiZhanSuitInfoCell:GetItemCountTxt()
	if self.data == nil then return "" end
	local item_list = ForgeData.Instance:GetBaiZhanOrderCountListAll()
	
	local item_count = 0
	if self.data.order ~= nil then
		item_count = item_list[self.data.order] or 0
	end
	self.node_list["Gou"]:SetActive(item_count >= SUIT_PART_COUNT)
	return item_count .. " / " .. SUIT_PART_COUNT
end
