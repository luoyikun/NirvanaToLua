MijiBagView = MijiBagView or BaseClass(BaseView)
local COLUMN = 2
function MijiBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengxiaoview_prefab", "MijiBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function MijiBagView:__delete()
end

function MijiBagView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MijiBagView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(817, 568, 0)
	self.node_list["Txt"].text.text = Language.ShengXiao.MiJiBeiBao
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.list_data = {}
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function MijiBagView:OpenCallBack()
	self:FlushView()
end

function MijiBagView:CloseCallBack()
	
end

function MijiBagView:FlushView()
	self.list_data = ShengXiaoData.Instance:GetBagMijiList()
	self.node_list["ListView"].scroller:ReloadData(0)
end

function MijiBagView:CloseWindow()
	self:Close()
end

function MijiBagView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function MijiBagView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = MijiBagGroupCell.New(cell.gameObject)
		group_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function MijiBagView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	local shenxiao_index = ShengXiaoData.Instance:GetMijiShengXiaoIndex()
	local cur_miji_list = ShengXiaoData.Instance:GetZodiacMijiList(shenxiao_index)
	local click_type = ShengXiaoData.Instance:GetMijiCfgByIndex(data.cfg_index).type
	for k,v in pairs(cur_miji_list) do
		if v >= 0 then
			local one_type = ShengXiaoData.Instance:GetMijiCfgByIndex(v).type
			if one_type == click_type then
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.HaveMiji)
				return
			end
		end
	end
	ShengXiaoCtrl.Instance:SetSelectStudyData(data)	
	self:Close()
end

function MijiBagView:OnFlush(params_t)
	self:FlushView()
end

-------------------MijiBagGroupCell-----------------------
MijiBagGroupCell = MijiBagGroupCell or BaseClass(BaseRender)
function MijiBagGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = MijiBagItemCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function MijiBagGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function MijiBagGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function MijiBagGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function MijiBagGroupCell:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function MijiBagGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function MijiBagGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------MijiBagItemCell-----------------------
MijiBagItemCell = MijiBagItemCell or BaseClass(BaseCell)
function MijiBagItemCell:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))

	self.node_list["PanelBagItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MijiBagItemCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.fight_text = nil
end

function MijiBagItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MijiBagItemCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function MijiBagItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.data.cfg_index)
	local name_str = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	self.node_list["TxtLevelDes"].text.text = name_str
	self.node_list["TxtAttrDes1"].text.text = miji_cfg.type_name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = miji_cfg.capacity
	end
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(data)
	end
	self.node_list["ImgRepeat"]:SetActive(self.data.have_type == 0)
	self.node_list["TxtNum"].text.text = self.data.item_num

	if self.data.item_id > 0 then
		self.item_cell:SetData({item_id = self.data.item_id, num = self.data.item_num})
	end
end