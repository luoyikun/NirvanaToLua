TianXiangGroupAttrView = TianXiangGroupAttrView or BaseClass(BaseView)

function TianXiangGroupAttrView:__init()
	self.ui_config = {{"uis/views/shenyinview_prefab", "TianXiangGroupAttr"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.view_cfg = {}
	self.index_cfg = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TianXiangGroupAttrView:__delete()

end

function TianXiangGroupAttrView:ReleaseCallBack()
	self.list_view = nil
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	self.list_view_delegate = nil
end

function TianXiangGroupAttrView:LoadCallBack()
	self.cell_list = {}
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	--self.node_list["BtnFalse"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.combine_attr_add = ShenYinData.Instance:GetTianXiangGroupCfg()

	self.list_view_delegate = self.node_list["List"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function TianXiangGroupAttrView:OnClickClose()
	self:Close()
end

function TianXiangGroupAttrView:GetNumberOfCells()
	return #self.combine_attr_add
end

function TianXiangGroupAttrView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = TianXiangGroupRander.New(cell.gameObject)
		group_cell:SetToggleGroup(self.node_list["ToggleGroup"].toggle_group)
		self.cell_list[cell] = group_cell
	end
	self.cell_list[cell]:SetData(self.combine_attr_add[data_index + 1])
	self.cell_list[cell]:Flush()
end


------------------------------------------------
TianXiangGroupRander = TianXiangGroupRander or BaseClass(BaseRender)

function TianXiangGroupRander:__init()

end

function TianXiangGroupRander:__delete()

end

function TianXiangGroupRander:SetData(data)
	self.data = data 
end

function TianXiangGroupRander:OnFlush()
	if self.data == nil then return end
	local name_1 = ShenYinData.Instance:GetTianXiangNameBySeq(self.data.combine_seq_1)
	local name_2 = ShenYinData.Instance:GetTianXiangNameBySeq(self.data.combine_seq_2)
	self.node_list["TxtName"].text.text = name_1 .. " ".. "+" .. " " .. name_2
	self.node_list["TxtAttrPro"].text.text = string.format(Language.ShenYin.Reinforce,self.data.attr_add / 100)
end

function TianXiangGroupRander:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

