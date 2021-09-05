TipsSpiritShangZhenView = TipsSpiritShangZhenView or BaseClass(BaseView)

local MAX_NUM = 40
local COLUMN_NUM = 4
local ROW_NUM = 2
function TipsSpiritShangZhenView:__init()
	self.ui_config = {{"uis/views/tips/spiritzhenfatip_prefab", "SpiritShangzhenTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.cur_data = nil
	self.cur_index = -1
	self.is_modal = true
end

function TipsSpiritShangZhenView:__delete()

end

function TipsSpiritShangZhenView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	self.list_view = nil
	self.toggle_list = {}
end

function TipsSpiritShangZhenView:LoadCallBack()
	local toggle_list = self.node_list["ToggleList"]
	self.toggle_list = {}
	for i = 1, 5 do
		local transform = toggle_list.transform:FindHard("PageToggle" .. i)
		if transform ~= nil then
			node = U3DObject(transform.gameObject, transform)
			if node then
				self.toggle_list[i] = node
			end
		end
	end
	self.item_cell_list = {}

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
end

function TipsSpiritShangZhenView:InitListView()
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

end

function TipsSpiritShangZhenView:OpenCallBack()
	self.toggle_list[1].toggle.isOn = true
	if nil == self.list_view then
		self:InitListView()
	else
		if self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:ReloadData(0)
		end
	end

end

function TipsSpiritShangZhenView:GetNumberOfCells()
	return MAX_NUM / ROW_NUM
end

function TipsSpiritShangZhenView:RefreshCell(cell, data_index)
	local group = self.item_cell_list[cell]
	if not group then
		group = TipsSpiritShangZhenGroup.New(cell.gameObject)
		self.item_cell_list[cell] = group
		for i = 1, ROW_NUM do
			group:ListenClick(i, BindTool.Bind(self.HandleOnClick, self))
		end
	end

	local page = math.floor(data_index / COLUMN_NUM)
	local column = data_index - page * COLUMN_NUM
	local grid_count = COLUMN_NUM * ROW_NUM
	for i = 1, ROW_NUM do
		local index = (i - 1) * COLUMN_NUM  + column + (page * grid_count)
		local data = SpiritData.Instance:GetShangZhenBagBestSpirit()[index + 1]
		group:SetData(i, data)
	end
end

function TipsSpiritShangZhenView:HandleOnClick(data)
	if data then
		if data.type == 1 then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.ChuZhanZhong)
		elseif data.type == 2 then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.ZhuZhenZhong)
		elseif SpiritData.Instance:HasSameSprite(data.item_data.item_id) then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SameSpriteLimit)
		else
			if self.cur_data then
				local item_cfg = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
			    if not item_cfg then return end
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF,
			    self.cur_data.index, 0, 0, 0, item_cfg.name)
				PackageCtrl.Instance:SendUseItem(data.item_data.index, 1, data.item_data.sub_type, 0)
			else
				local index = SpiritData.Instance:GetSpiritItemIndex()
				if index then
					PackageCtrl.Instance:SendUseItem(data.item_data.index, 1, data.item_data.sub_type, 0)
				end
			end
			self:Close()
		end
	end
end

function TipsSpiritShangZhenView:SetData(index, data)
	self.cur_index = index
	self.cur_data = data
end

function TipsSpiritShangZhenView:CloseCallBack()
	self.cur_data = nil
	self.cur_index = -1
end

function TipsSpiritShangZhenView:OnClickCloseButton()
	self:Close()
end

------------------------------------------------------------------------------

TipsSpiritShangZhenGroup = TipsSpiritShangZhenGroup or BaseClass(BaseRender)

function TipsSpiritShangZhenGroup:__init()
	self.cells = {}
	for i = 1, 2 do
		self.cells[i] = TipsSpiritShangZhenItem.New(self.node_list["Sprite" .. i])
	end
end

function TipsSpiritShangZhenGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function TipsSpiritShangZhenGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function TipsSpiritShangZhenGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

--------------------------------------------------------------------------------

TipsSpiritShangZhenItem = TipsSpiritShangZhenItem or BaseClass(BaseCell)

function TipsSpiritShangZhenItem:__init()
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["Item"])
	self.state1 = self.node_list["State"]
	self.state2 = self.node_list["State2"]
	self.state3 = self.node_list["State3"]
	self.level = self.node_list["LV"]:GetComponent(typeof(UnityEngine.UI.Text))
	self.cap = self.node_list["Combat"]:GetComponent(typeof(UnityEngine.UI.Text))
	self.cell:ShowHighLight(false)
end

function TipsSpiritShangZhenItem:__delete()
	self.cell:DeleteMe()
	self.cell = nil
end

function TipsSpiritShangZhenItem:OnFlush()
	if nil == self.data then
		self.cell:SetData(nil)
		self.cap.text = ""
		self.level.text = ""
		self.state1:SetActive(false)
		self.state2:SetActive(false)
		self.state3:SetActive(false)
		return
	end
	self.cell:SetData(self.data.item_data)
	self.state1:SetActive(self.data.type == 1)
	self.state2:SetActive(self.data.type == 2)
	self.state3:SetActive(self.data.type == 3)
	local spirit_cfg = nil
	local wuxing = 0
	if self.data.item_data.param then
		spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.data.item_data.item_id, self.data.item_data.param.strengthen_level)
		wuxing = self.data.item_data.param.param1
	else
		spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.data.item_data.item_id, 1)
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	local cap = 0
	if spirit_cfg then
		local base_attr_list = CommonDataManager.GetAttributteNoUnderline(spirit_cfg, true)
		cap = SpiritData.Instance:GetAddWuxingCap(base_attr_list, wuxing, item_cfg.color)
	end
	self.cap.text = string.format(Language.JingLing.HomeCapStr, cap)
	self.level.text = string.format(Language.JingLing.WuxingStr, wuxing)
end

function TipsSpiritShangZhenItem:ListenClick(handler)
	if self.event_table == nil then
		return
	end
	self.cell:ListenClick(function ()
		handler(self.data)
	end)
	self.node_list["Spirit"].button:AddClickListener(function() handler(self.data)
	end)
end


