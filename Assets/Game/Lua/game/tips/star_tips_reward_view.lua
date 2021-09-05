TipsStarRewardView = TipsStarRewardView or BaseClass(BaseView)

function TipsStarRewardView:__init()
	self.ui_config = {{"uis/views/tips/rewardtips_prefab", "StarRewardTips"}}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsStarRewardView:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
end

function TipsStarRewardView:SetData(items,show_gray,ok_callback,show_button)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
end

function TipsStarRewardView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))
	self.item_list = {}
	for i = 1, 3 do
		local item_obj = self.node_list["Item"..i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
end

function TipsStarRewardView:CloseView()
	self:Close()
end

function TipsStarRewardView:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end

	self:Close()
end

function TipsStarRewardView:OpenCallBack()
	self:Flush()
end
function TipsStarRewardView:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
		UI:SetButtonEnabled(self.node_list["BtnConfirm"], not self.show_gray_data)
		if self.show_button_value == nil then
			self.node_list["BtnConfirm"]:SetActive(true)
		else
			self.node_list["BtnConfirm"]:SetActive(self.show_button_value)
		end
	end
end
