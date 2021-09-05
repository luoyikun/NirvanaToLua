TipsActivityEndView = TipsActivityEndView or BaseClass(BaseView)

function TipsActivityEndView:__init()
	self.ui_config = {
		{"uis/views/activityview_prefab", "ActivityEndView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsActivityEndView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function TipsActivityEndView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.item_cells = {}
	for i = 1, 8 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.item_cells, item_cell)
	end
end

function TipsActivityEndView:OnClickClose()
	self:Close()
end

function TipsActivityEndView:OnFlush()
	if self.data then
		for i = 1,8 do
			if self.data[i] then
				self.node_list["Item" .. i]:SetActive(true)
				self.item_cells[i]:SetData(self.data[i])
			else
				self.node_list["Item" .. i]:SetActive(false)
			end
		end
	end
end

function TipsActivityEndView:SetData(data)
	if nil == data then return end
	self.data = data
end
