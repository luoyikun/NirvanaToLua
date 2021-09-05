FenjieView = FenjieView or BaseClass(BaseRender)
local BAG_MAX_GRID_NUM = 80			-- 最大格子数
local BAG_ROW = 4					-- 每一页有4行
local BAG_COLUMN = 4				-- 每一页有4列
local des_id = 287
-- 分解类型
Fenjie_TYPE =
{
	BLUE = 1,						-- 蓝色
	PURPLE = 2,						-- 紫色
	ORANGE = 3,						-- 橙色
	RED = 4,						-- 红色
}

local MOVE_TIME = 0.5

function FenjieView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(970 , -35 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnTips"] , Vector3(-43 , 440 , 0 ) , MOVE_TIME )
end

-- 分解
function FenjieView:__init()
	self.bag_cell = {}
	self.fenjie_list = {}
	self.bag_list_view = self.node_list["ListView"]
	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.node_list["Toggle_1"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleOnClick, self,Fenjie_TYPE.BLUE))
	self.node_list["Toggle_2"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleOnClick, self,Fenjie_TYPE.PURPLE))
	self.node_list["Toggle_3"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleOnClick, self,Fenjie_TYPE.ORANGE))
	self.node_list["Toggle_4"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleOnClick, self,Fenjie_TYPE.RED))
	for i=1,2 do
		self.node_list["Btn_Getway" .. i].button:AddClickListener(BindTool.Bind(self.MaterialGetWay, self, i))
	end
	
	-- 分解按钮
	self.node_list["FenjieButton"].button:AddClickListener(BindTool.Bind(self.OnDecompose, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OnClickShenqiTip, self))

	self:Flush()
	self.bag_list_view.scroller:RefreshActiveCellViews()

end


function FenjieView:__delete()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	self.bag_list_view = nil
end

function FenjieView:MaterialGetWay(index)
	local item_id = nil
	if index == 1 then
		item_id = 27013
	elseif index == 2 then
		item_id = 27014
	end

	if item_id then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	end
end


function FenjieView:OnToggleOnClick(i, is_click)
	local color_list = {}
	for i=1, 4 do
		if self.node_list["Toggle_" .. i].toggle.isOn == true then
			table.insert(color_list, i)
		end
	end
	ShenqiData.Instance:SetFJColor(color_list)
	ShenqiData.Instance:GetFenjieListbyQuality(color_list)
	self:FlushFenjieStuffNum()
	self.bag_list_view.scroller:RefreshActiveCellViews()
end

function FenjieView:FlushFenjieStuffNum()
	local shenbing_stuff = 0
	local baojia_stuff = 0
	local stuff_list = ShenqiData.Instance:GetFenjielist()
	if next(stuff_list) then
		for k,v in pairs(stuff_list) do
			local shenbing_num = ShenqiData.Instance:GetFenjieNumByItemID(v.item_id, 0)
			shenbing_stuff = shenbing_stuff + shenbing_num * v.num
			local baojia_num = ShenqiData.Instance:GetFenjieNumByItemID(v.item_id, 1)
			baojia_stuff = baojia_stuff + baojia_num * v.num
		end
	end

	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	local shenbing_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.shenbing_uplevel_stuff)

	local baojia_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)

	if shenbing_stuff == 0 then
		self.node_list["ShenbingNumText"].text.text = shenbing_stuff_num
	else
		self.node_list["ShenbingNumText"].text.text = (shenbing_stuff_num..ToColorStr("+",COLOR.GREEN)..ToColorStr(shenbing_stuff,COLOR.GREEN))
	end

	if baojia_stuff == 0 then
		self.node_list["BaojiaNumText"].text.text = baojia_stuff_num
	else
		self.node_list["BaojiaNumText"].text.text = (baojia_stuff_num..ToColorStr("+",COLOR.GREEN)..ToColorStr(baojia_stuff,COLOR.GREEN))
	end
end

-- 分解按钮
function FenjieView:OnDecompose()
 	local stuff_list = ShenqiData.Instance:GetFenjielist()
	if next(stuff_list) then
		for k,v in pairs(stuff_list) do
				ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_DECOMPOSE, v.item_id,v.num)
		end
	else	
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenQi.NoFenjieMet)
	end
	self:OnFlush()

end

function FenjieView:BagRefreshCell(cell, data_index, cell_index)
	-- 构造Cell对象
	local group = self.bag_cell[cell]
	if nil == group then
		group = ShenBingFenJieStuffItemGroup.New(cell.gameObject)
		group:SetToggleGroup(self.node_list["ListView"].toggle_group, self)
		self.bag_cell[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)
		local stuff_list = {}
				local data_list = ShenqiData.Instance:GetCanFenjieStuff()
				for _, v1 in pairs(data_list) do
					table.insert(stuff_list, v1)
				end


		local data = stuff_list[index + 1]
		if nil == data then data = {} end
		group:SetData(i, data, true, self.fenjie_list)
	end
end


function FenjieView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW		-- 80/4=20 总共20组
end

function FenjieView:OnFlush()
	local color_list = ShenqiData.Instance:GetFJColor()
	if color_list then
		for i,v in ipairs(color_list) do
			self.node_list["Toggle_" .. v].toggle.isOn = true
		end
	end
	self.bag_list_view.scroller:RefreshActiveCellViews()
	self:FlushFenjieStuffNum()
end

function FenjieView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(des_id)
end

---------------------------- 神兵分解背包 begin-------------------------------------
ShenBingFenJieStuffItemGroup = ShenBingFenJieStuffItemGroup or BaseClass(BaseRender)

function ShenBingFenJieStuffItemGroup:__init()
	self.fenjie_view = nil
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.cells[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
	end

	self.index_table = {}
end

function ShenBingFenJieStuffItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.fenjie_view = nil
end

function ShenBingFenJieStuffItemGroup:SetData(i, data, enable,list)
	if nil == data then 
		self.cells[i]:ShowGetEffectTwo(false)
		return 
	end

	if not next(data) then
		self.cells[i]:SetData(nil)
		self.cells[i]:ShowGetEffectTwo(false)
		return
	end

	self.cells[i]:SetData(data, enable)

	data.from_view = TipsFormDef.FROM_SHENQI_BAG
	self.index_table[i] = data.index
	local is_show = self:FenjieListView(data.item_id,data.index)
	if data and is_show then
		self.cells[i]:SetIconGrayVisible(true)
		self.cells[i]:ShowHasGet(true)
		self.cells[i]:ShowGetEffectTwo(false)
	else
		self.cells[i]:SetIconGrayVisible(false)
		self.cells[i]:ShowHasGet(false)
		self.cells[i]:ShowGetEffectTwo(false)
	end
end
function ShenBingFenJieStuffItemGroup:FenjieListView(item_id,index)
	if item_id == nil then return false end
	local list_cfg = ShenqiData.Instance:GetFenjielist()
	for k, v in pairs(list_cfg) do 
		if v.item_id  == item_id and v.index == index then
			return true
		end
	end
	return false
end

function ShenBingFenJieStuffItemGroup:OnClickItem(index)
	if index == nil then return end
	local data = self.cells[index]:GetData()
	if not data or not next(data) then
		return
	end
	local is_show = self:FenjieListView(data.item_id,data.index)
	if is_show then
		ShenqiData.Instance:SetFenjielist(data.item_id,data.index)
		self.cells[index]:ShowGetEffectTwo(false)
		self.cells[index]:ShowHasGet(false)
		self.cells[index]:SetIconGrayVisible(false)
		self.cells[index]:ShowHighLight(false)
	else
		ShenqiData.Instance:SetFenjielist1(data)
		self.cells[index]:ShowHasGet(true)
		self.cells[index]:SetIconGrayVisible(true)
		self.cells[index]:ShowHighLight(false)
	end

	if self.fenjie_view then
		self.fenjie_view:FlushFenjieStuffNum()
	end
end

function ShenBingFenJieStuffItemGroup:ListenClick(i, handler)
	self.cells[i]:AddClickListener(handler)
end

function ShenBingFenJieStuffItemGroup:SetIconGrayScale(i, enable)
	self.cells[i]:SetIconGrayScale(enable)
end

function ShenBingFenJieStuffItemGroup:SetClickCallBack(i, callback)
	self.cells[i]:ListenClick(i, callback)
end


function ShenBingFenJieStuffItemGroup:GetIconGrayScaleIsGray(i)
	return self.cells[i]:GetIconGrayScaleIsGray()
end

function ShenBingFenJieStuffItemGroup:SetToggleGroup(toggle_group, fenjie_view)
	for k, v in pairs(self.cells) do
		self.cells[k]:SetToggleGroup(toggle_group)
	end

	self.fenjie_view = fenjie_view
end

function ShenBingFenJieStuffItemGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(false)
end

function ShenBingFenJieStuffItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(false)
end

function ShenBingFenJieStuffItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function ShenBingFenJieStuffItemGroup:ShowQuality(i, enable)
	self.cells[i]:ShowQuality(enable)
end

function ShenBingFenJieStuffItemGroup:FlushArrow(value)
	for k,v in pairs(self.cells) do
		self.cells[k]:FlushArrow(value)
	end
end

-- 通过背包索引刷新格子
function ShenBingFenJieStuffItemGroup:SetDataByIndex(index, data)
	for i = 1, BAG_ROW do
		if self.index_table[i] == index then
			self.cells[i]:SetIconGrayScale(false)
			self.cells[i]:ShowQuality(nil ~= data.item_id)
			local recycle_list = ItemData.Instance:GetRecycleItemDataList()
			for k,v in pairs(recycle_list) do
				if data.item_id == v.item_id and data.index == v.index then
					self.cells[i]:SetIconGrayScale(true)
					self.cells[i]:ShowQuality(false)
				end
			end
			self.cells[i]:SetData(data, true)
			self.cells[i]:SetInteractable(nil ~= data.item_id or data.locked)
			return true, i
		end
	end
	return false
end

------------------------------ 神兵分解背包 end-------------------------------------
