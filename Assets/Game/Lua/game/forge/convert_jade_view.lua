ConvertJadeBagView = ConvertJadeBagView or BaseClass(BaseView)

local BAG_ROW = 4						-- 每行个数

function ConvertJadeBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/forgeview_prefab", "ConvertJade"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function ConvertJadeBagView:__delete()
end

function ConvertJadeBagView:ReleaseCallBack()
	self.bag_cell = {}
	self.select_length = nil
	for k, v in pairs(self.convert_cell_list) do
		v:DeleteMe()
	end
	self.convert_cell_list = {}
end

-- -- open_type 1:玉石背包回收 2：玉石兑换
-- function ConvertJadeBagView:SetOpenTypeData(open_type)
-- 	-- if open_type == 1 then
-- 	-- 	self.open_type = 1

-- 	-- elseif open_type == 2 then
-- 		-- self.open_type = 2

-- 	-- end

-- 	self:Open()
-- end

function ConvertJadeBagView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["TitleText"].text.text = Language.Forge.ConvertJade
	self.jade_convert_cfg = {}
	self.convert_cell_list = {}
	local convert_list_delegate = self.node_list["ConvertListView"].list_simple_delegate
	convert_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetConvertCellNumber, self)
	convert_list_delegate.CellRefreshDel = BindTool.Bind(self.ConvertCellRefresh, self)

end

function ConvertJadeBagView:CloseWindow()
	self:Close()
end

function ConvertJadeBagView:OpenCallBack()
	self.jade_convert_cfg = ForgeData.Instance:GetJadeConvertCfg()
	if self.node_list["ConvertListView"] then
		self.node_list["ConvertListView"].scroller:ReloadData(0)
	end
	self:Flush()
end

function ConvertJadeBagView:GetConvertCellNumber()
	return math.ceil(#self.jade_convert_cfg / BAG_ROW)
end

function ConvertJadeBagView:ConvertCellRefresh(cell, index)
	local convert_cell = self.convert_cell_list[cell]
	if nil == convert_cell then
		-- convert_cell = JadeConvertCellItem.New(cell.gameObject)
		convert_cell = JadeConvertCellGroup.New(cell.gameObject)
		self.convert_cell_list[cell] = convert_cell
	end
	for i = 1, BAG_ROW do
		local cell_index = index * BAG_ROW + i
		local data = self.jade_convert_cfg[cell_index]
		-- local index = 1
		if data == nil then
			convert_cell:SetActive(i, false)
		else
			convert_cell:SetIndex(i, cell_index)
			convert_cell:SetData(i, data)
			convert_cell:SetActive(i, true)
		end
	end

end
-----------------End-------------------
function  ConvertJadeBagView:OnFlush()
	self.node_list["JadeScoreTxt"].text.text = ToColorStr(ForgeData.Instance:GetJadeScore(), COLOR.YELLOW)
end

JadeConvertCellGroup = JadeConvertCellGroup or BaseClass(BaseRender)
function JadeConvertCellGroup:__init()
	self.exchange_list = {}
	for i = 1, BAG_ROW do
		local exchange_cell = JadeConvertCellItem.New(self.node_list["item_" .. i])
		table.insert(self.exchange_list, exchange_cell)
	end
end

function JadeConvertCellGroup:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function JadeConvertCellGroup:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function JadeConvertCellGroup:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function JadeConvertCellGroup:SetData(i, data)
	self.exchange_list[i]:SetData(data)
	self.exchange_list[i]:Flush()
end

JadeConvertCellItem = JadeConvertCellItem or BaseClass(BaseCell)
function JadeConvertCellItem:__init()
	self.jade_cell = ItemCell.New()
	self.jade_cell:SetInstanceParent(self.node_list["JadeItem"])

	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickConvert, self))
end

function JadeConvertCellItem:__delete()
	if self.jade_cell then
		self.jade_cell:DeleteMe()
		self.jade_cell = nil
	end
end

function JadeConvertCellItem:SetData(data)
	self.data = data
end

function JadeConvertCellItem:OnClickConvert()
	local function ok_callback()
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_CONVERT, self.data.seq)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.convert_stone_id)
	local des = string.format(Language.Forge.IsConvertJade, ToColorStr(self.data.convert_need_score, TEXT_COLOR.GREEN_4), ToColorStr(item_cfg.name, ORDER_COLOR[item_cfg.color]))
	TipsCtrl.Instance:ShowCommonAutoView("jade_convert", des, ok_callback, nil, nil, nil, nil, nil, nil, true)
end

function JadeConvertCellItem:OnFlush()
	if nil == self.data then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.convert_stone_id)
	local attrs = ForgeData.Instance:GetJadeAttr(self.data.convert_stone_id)
	self.jade_cell:SetData({item_id = self.data.convert_stone_id, num = 1, is_bind = 0})
	self.node_list["JadeName"].text.text = ToColorStr(item_cfg.name, ORDER_COLOR[item_cfg.color]) 
	self.node_list["Score"].text.text = self.data.convert_need_score
end

