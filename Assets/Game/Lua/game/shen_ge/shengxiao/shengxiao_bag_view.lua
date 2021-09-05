ShengXiaoBagView = ShengXiaoBagView or BaseClass(BaseView)

function ShengXiaoBagView:__init()
	self.ui_config = {{"uis/views/shengxiaoview_prefab", "ShengXiaoBagView"}}
	self.view_layer = UiLayer.Pop
	self.chapter = 1
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengXiaoBagView:__delete()

end

function ShengXiaoBagView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_cell_list = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.select_index = 0
	self.chapter = 1
end

function ShengXiaoBagView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnCompose"].button:AddClickListener(BindTool.Bind(self.OnClickCompose, self))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))

	self.item_cell_list = {}
	for i = 1, 5 do
		local item_cell = self.node_list["Item" .. i]
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(item_cell)
		self.item_cell_list[i]:SetIndex(i)
		self.item_cell_list[i].root_node.toggle.group = self.node_list["Bottom"].toggle_group
		self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItem, self, i , self.item_cell_list[i]))
	end
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.select_index = 0
	self:Flush()
end


function ShengXiaoBagView:ItemDataChangeCallback()
	self:Flush()
end

function ShengXiaoBagView:OpenCallBack()
	self:Flush()
end

function ShengXiaoBagView:ClickItem(i , item_cell)
	if self.select_index == i then
		item_cell:OnClickItemCell()
	end
	self.select_index = i
	-- item_cell:SetHighLight(true)
	self:FlushDesc()

	for k, v in pairs(self.item_cell_list) do
		if v:GetIndex() == i then
			v:ShowHighLight(true)
		else
			v:ShowHighLight(false)
		end
	end
end

function ShengXiaoBagView:FlushDesc()
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	if self.select_index > 0 and self.select_index <= 4 then
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(chose_data.item_id)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name .."</color>"
		local desc = string.format(Language.ShengXiao.PieceCompose, compose_item.stuff_count_1, name_str)
		self.node_list["TxtDesc"].text.text = desc
	else
		self.node_list["TxtDesc"].text.text = ""
	end
	UI:SetButtonEnabled(self.node_list["BtnCompose"], self.select_index <= 4)
end

function ShengXiaoBagView:OnFlush()
	local bag_list = TableCopy(ShengXiaoData.Instance:GetBeadInBagList())
	for k,v in pairs(bag_list) do
		v.close_call_back = function () end
		self.item_cell_list[k]:SetData(v)
		if v.num then
			-- UI:SetGraphicGrey(self.item_cell_list[k].node_list["Icon"], v.num <= 0)
			self.item_cell_list[k]:SetIconGrayScale(v.num <= 0)
			local flag = v.num > 0 and true or false
			self.item_cell_list[k]:ShowQuality(flag)
		end
	end
end

function ShengXiaoBagView:CloseWindow()
	self:Close()
end

function ShengXiaoBagView:SetViewChapter(chapter)
	self.chapter = chapter
end

function ShengXiaoBagView:OnClickCompose()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
		return
	end
	if self.select_index <= 4 then
		local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local bag_num = bag_list[self.select_index].num
		ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, 1, 0)
	end
end

function ShengXiaoBagView:OnClickUse()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
		return
	end
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	local chose_data = bag_list[self.select_index]
	if chose_data.num > 0 then
		ShengXiaoCtrl.Instance:SendPutBeadReq(self.select_index, self.chapter - 1)
	else
		TipsCtrl.Instance:ShowItemGetWayView(chose_data.item_id)
	end
end