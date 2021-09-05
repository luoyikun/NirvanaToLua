MarryEquipReclyeInfoView = MarryEquipReclyeInfoView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 140			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 4						-- 行数
local BAG_COLUMN = 5					-- 列数
MarryEquipReclyeInfoView.SELECT_INDEX_LIST = {}
function MarryEquipReclyeInfoView:__init(instance, mother_view)
	self.bag_cell = {}
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.node_list["BtnGuaji"].button:AddClickListener(BindTool.Bind(self.OnClickGuaji, self))
	self.node_list["BtnRecycle"].button:AddClickListener(BindTool.Bind(self.OnClickRecyle, self))
	self.node_list["BtnRecycle1"].button:AddClickListener(BindTool.Bind(self.OnClickDoRecyle, self))

	self.check_lover = false
end

function MarryEquipReclyeInfoView:__delete()
	if self.bag_cell then
		for k,v in pairs(self.bag_cell) do
			v:DeleteMe()
		end
		self.bag_cell = {}
	end
end

function MarryEquipReclyeInfoView:OpenCallBack()
	MarryEquipReclyeInfoView.SELECT_INDEX_LIST = {}
	if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	end
	self:Flush()
end

function MarryEquipReclyeInfoView:OnClickGuaji()
	MarryEquipCtrl.Instance:OpenGuajiView()
end

function MarryEquipReclyeInfoView:OnClickRecyle()
	MarryEquipCtrl.Instance:OpenRecyleView(BindTool.Bind(self.AutoRecyleColor, self))
end

function MarryEquipReclyeInfoView:OnClickDoRecyle()
	for k,v in pairs(MarryEquipReclyeInfoView.SELECT_INDEX_LIST) do
		PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
	end
	MarryEquipReclyeInfoView.SELECT_INDEX_LIST = {}
end

function MarryEquipReclyeInfoView:AutoRecyleColor(color)
	local data_list = MarryEquipData.Instance:GetAllQingYuanEquipList()
	for i = 1, BAG_MAX_GRID_NUM do
		if data_list[i] then
			local item_cfg = ItemData.Instance:GetItemConfig(data_list[i].item_id)
			if item_cfg and item_cfg.color <= color and not MarryEquipData.Instance:IsBetterMarryEquip(data_list[i].item_id) then
				MarryEquipReclyeInfoView.SELECT_INDEX_LIST[data_list[i].index] = data_list[i]
			else
				MarryEquipReclyeInfoView.SELECT_INDEX_LIST[data_list[i].index] = nil
			end
		end
	end
	if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
	end
	self:SetProgTxt()
end

function MarryEquipReclyeInfoView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function MarryEquipReclyeInfoView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = MarryEqItemCell.New(cellObj)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	local data = MarryEquipData.Instance:GetAllQingYuanEquipList()[grid_index + 1] or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)
	cell:ShowHighLight(false)
	cell:SetGetImgVis(data.index ~= nil and MarryEquipReclyeInfoView.SELECT_INDEX_LIST[data.index] ~= nil)
	cell:SetData(cell_data, true)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell, data.index))
	cell:SetInteractable((nil ~= cell_data.item_id or cell_data.locked))
end

function MarryEquipReclyeInfoView:HandleBagOnClick(cell, index)
	local data = cell:GetData()
	if index and MarryEquipReclyeInfoView.SELECT_INDEX_LIST[index] then
		MarryEquipReclyeInfoView.SELECT_INDEX_LIST[index] = nil
		cell:SetGetImgVis(false)
	elseif index and data and data.item_id and data.item_id > 0 then
		MarryEquipReclyeInfoView.SELECT_INDEX_LIST[index] = data
		cell:SetGetImgVis(true)
	end
	self:SetProgTxt()
end

function MarryEquipReclyeInfoView:OnFlush()
	for k,v in pairs(MarryEquipReclyeInfoView.SELECT_INDEX_LIST) do
		if ItemData.Instance:GetItemNumInBagByIndex(k) <= 0 then
			MarryEquipReclyeInfoView.SELECT_INDEX_LIST[k] = nil
		end
	end
	if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
	end
	local marry_info = MarryEquipData.Instance:GetMarryInfo()

	local marry_level_cfg = MarryEquipData.Instance:GetMarryLevelCfg(marry_info.marry_level)
	if nil == marry_level_cfg then return end
	local cap = CommonDataManager.GetCapability(marry_level_cfg)
	self.node_list["TxtNumber"].text.text = cap
	local marry_level = string.format("LV.%s", marry_info.marry_level)
	self.node_list["TxtSlider"].text.text = marry_level
	self.node_list["TxtMarryLevel"].text.text = string.format(Language.Marriage.MarriageLevel, marry_level)
	self.node_list["TxtHP"].text.text = marry_level_cfg.maxhp
	self.node_list["TxtGongJi"].text.text = marry_level_cfg.gongji
	self.node_list["TxtFangYu"].text.text = marry_level_cfg.fangyu
	self.node_list["TxtMingZhong"].text.text = marry_level_cfg.mingzhong
	self.node_list["TxtShanBi"].text.text = marry_level_cfg.shanbi
	self.node_list["TxtBaoJi"].text.text = marry_level_cfg.baoji
	self.node_list["Txtkangbao"].text.text = marry_level_cfg.jianren

	local marry_level_n_cfg = MarryEquipData.Instance:GetMarryLevelCfg(marry_info.marry_level + 1)
	if marry_level_n_cfg then
		self.node_list["TxtSlider1"].text.text = string.format("LV.%s", marry_info.marry_level + 1)
		self.node_list["Slider"].slider.value = marry_info.marry_level_exp / marry_level_cfg.up_level_exp
	else
		self.node_list["TxtSlider1"].text.text = string.format("LV.%s", marry_info.marry_level)
		self.node_list["Slider"].slider.value = 1
	end
	self:SetProgTxt()
end

function MarryEquipReclyeInfoView:SetProgTxt()
	local marry_info = MarryEquipData.Instance:GetMarryInfo()
	local marry_level_cfg = MarryEquipData.Instance:GetMarryLevelCfg(marry_info.marry_level)
	local marry_level_n_cfg = MarryEquipData.Instance:GetMarryLevelCfg(marry_info.marry_level + 1)
	if marry_level_cfg and marry_level_n_cfg then
		local add_exp = self:GetAllSelectEquipScore()
		add_exp = add_exp > 0 and "<color=#00ff00>(+" .. self:GetAllSelectEquipScore() .. ")</color>" or ""
		self.node_list["TxtSlide"].text.text = marry_info.marry_level_exp .. add_exp .. "/" .. marry_level_cfg.up_level_exp
	else
		self.node_list["TxtSlide"].text.text = Language.Common.YiManJi
	end
end

function MarryEquipReclyeInfoView:GetAllSelectEquipScore()
	local score = 0
	for k,v in pairs(MarryEquipReclyeInfoView.SELECT_INDEX_LIST) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			score = score + item_cfg.recyclget
		end
	end
	return score
end


MarryEqItemCell = MarryEqItemCell or BaseClass(BaseCell)

function MarryEqItemCell:__init()
	self.equip = ItemCell.New()
	self.equip:SetInstanceParent(self.node_list["Item"])
end

function MarryEqItemCell:__delete()
	self.equip:DeleteMe()
	self.equip = nil
end

function MarryEqItemCell:SetData(...)
	BaseCell.SetData(self, ...)
	self.equip:SetData(...)
end

function MarryEqItemCell:SetGetImgVis(value)
	self.node_list["Img"]:SetActive(value)
end

function MarryEqItemCell:SetIconGrayScale(...)
	self.equip:SetIconGrayScale(...)
end

function MarryEqItemCell:ShowQuality(...)
	self.equip:ShowQuality(...)
end

function MarryEqItemCell:ShowHighLight(...)
	self.equip:ShowHighLight(...)
end

function MarryEqItemCell:ListenClick(...)
	self.equip:ListenClick(...)
end

function MarryEqItemCell:SetInteractable(...)
	self.equip:SetInteractable(...)
end