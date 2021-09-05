QuickFlushView = QuickFlushView or BaseClass(BaseView)

function QuickFlushView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/goldhuntview_prefab", "QuickFlushView"},
	}

	
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function QuickFlushView:__delete(  )

end

function QuickFlushView:LoadCallBack(  )
	self.item = {}
	-- self.rush_list = self:FindObj("ListView")
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cfg = GoldHuntData.Instance:GetHuntInfoCfg()
	self.node_list["Bg"].rect.sizeDelta = Vector3(695, 545, 0)
	self.node_list["Txt"].text.text = Language.Common.QuickFlush
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow,self))
	self.node_list["BtnCanel"].button:AddClickListener(BindTool.Bind(self.CloseWindow,self))
	self.node_list["BtnOk"].button:AddClickListener(BindTool.Bind(self.ClickStart,self))

	GoldHuntData.Instance:ClearSelect()
end

function QuickFlushView:ReleaseCallBack()
	for k,v in pairs(self.item) do
		v:DeleteMe()
	end
end

function QuickFlushView:GetNumberOfCells()
	return math.ceil(#self.cfg / 2)
end

function QuickFlushView:RefreshCell(cell, data_index)
	data_index = math.ceil(#self.cfg / 2) - data_index - 1 	--倒序
	local group = self.item[cell]

	if nil == group then
		group = HuntQuickItem.New(cell.gameObject)
		self.item[cell] = group
	end

	local hunt = {}
	for k,v in pairs(self.cfg) do
		if v.seq == data_index*2 or v.seq == data_index*2 + 1 then
			table.insert(hunt, 1, v)
		end
	end
	group:SetData(hunt)
end


function QuickFlushView:CloseWindow()
	self:Close()
end

function QuickFlushView:ClickStart()
	if not next(GoldHuntData.Instance:GetSelect()) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Gold.NoAnimal)
		return
	end
	GoldHuntCtrl.Instance:BeginRush()
	self:Close()
	-- self.node_list["QuickFlushView"]:SetActive(false)
end

---------------------------HuntQuickItem-------------------------------
HuntQuickItem = HuntQuickItem or BaseClass(BaseRender)

function HuntQuickItem:__init(  )
	self.item = {}
	for i = 1, 2 do
		self.item["text"..i] = self.node_list["Text" .. i]
		self.node_list["HuntCell1"].toggle:AddClickListener(BindTool.Bind(self.OnClick1,self))
		self.node_list["HuntCell2"].toggle:AddClickListener(BindTool.Bind(self.OnClick2,self))
		-- self:ListenEvent("OnToggle1", BindTool.Bind(self.OnClick1,self))
		-- self:ListenEvent("OnToggle2", BindTool.Bind(self.OnClick2,self))
		-- self.item["item_cell"..i] = self:FindObj("ItemCell"..i)
		self.item["hunt"..i] = self.node_list["HuntCell"..i]
		self.item["cell"..i] = ItemCell.New()
		self.item["cell"..i]:SetInstanceParent(self.node_list["ItemCell"..i])
		self.item["animal"..i] = self.node_list["ImgAnimal" .. i]
		-- self.item["show"..i] = self:FindVariable("ShowIcon"..i)
	end

end

function HuntQuickItem:__delete()
	for i = 1, 2 do
		if self.item["cell"..i] then
			self.item["cell"..i]:DeleteMe()
			self.item["cell"..i] = nil
		end
	end
end

function HuntQuickItem:SetData(data)
	for i = 1, 2 do
		if data[i] == nil then
			return
		end
		self.item["index"..i] = data[i].seq
		local name = data[i].name
		self.item["text"..i].text.text = name
		self.node_list["TextName".. i].text.text = name
		self.item["cell"..i]:SetData(data[i].exchange_item)

		self.item["hunt"..i]:SetActive(true)
		self.item["animal"..i].image:LoadSprite(ResPath.GetGoldHuntModelHeadImg("head_" .. (data[i].seq + 1)))

		local cur_select_t = GoldHuntData.Instance:GetSelect()
		if cur_select_t then
			if cur_select_t[self.item["index"..i]] then
				self.item["hunt"..i].toggle.isOn = true
			else
				self.item["hunt"..i].toggle.isOn = false
			end
		end
	end
end

function HuntQuickItem:OnClick1()
	GoldHuntData.Instance:SetSelect(self.item.index1, self.item.hunt1.toggle.isOn)
end

function HuntQuickItem:OnClick2()
	GoldHuntData.Instance:SetSelect(self.item.index2, self.item.hunt2.toggle.isOn)
end