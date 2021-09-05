TisDailySelectItemView = TisDailySelectItemView or BaseClass(BaseView)
function TisDailySelectItemView:__init()
	self.ui_config = {{"uis/views/tips/dailyselectitemtips_prefab", "DailySelectItemTips"}}
	self.item_info_list = {}
	self.select_item_id = 0
	self.sure_call_back = nil
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function TisDailySelectItemView:__delete()
	
end

function TisDailySelectItemView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseOnClick, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.SureOnClick, self))
	self.item_list = {}
	self.select_item_id = 1
	for i = 1, 3 do
		local index = i
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
		self.item_list[i]:ListenClick(function()
			self.select_item_id = index
		end)
	end
end

function TisDailySelectItemView:OpenCallBack()
	for i = 1, 3 do
		self.item_list[i]:SetData(self.item_info_list[i - 1])
	end
end

function TisDailySelectItemView:SetItemInfoList(item_info_list)
	self.item_info_list = item_info_list
end

function TisDailySelectItemView:SetSureCallback(callback)
	self.sure_call_back = callback
end

function TisDailySelectItemView:CloseOnClick()
	self.select_item_id = 0
	self:Close()
end

function TisDailySelectItemView:SureOnClick()
	if self.sure_call_back ~= nil then
		self.sure_call_back(self.select_item_id)
	end
	self:Close()
end



