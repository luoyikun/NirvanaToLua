LuckyLogView = LuckyLogView or BaseClass(BaseView)
function LuckyLogView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/luckylog_prefab","LuckyLog"}
	}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.count = 0
end

function LuckyLogView:__delete()
end

function LuckyLogView:LoadCallBack()
	self.log_item_list = {}
	self.node_list["Bg"].rect.sizeDelta = Vector3(620,450,0)
	self.node_list["Txt"].text.text = Language.Common.LuckyPeople
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LuckyLogView:GetNumberOfCells()
	local info = ActivityData.Instance:GetActivityLogInfo()
	if info and info.count then
		self.count = info.count
		return info.count
	end
	return 0
end

function LuckyLogView:RefreshCell(cell, data_index)
	local cfg = ActivityData.Instance:GetActivityLogInfo()
	data_index = data_index + 1
	local the_cell = self.log_item_list[cell]

	if nil ~= cfg and nil ~= cfg.log_item then
		if the_cell == nil then
			the_cell = LuckyLogItem.New(cell.gameObject)
			self.log_item_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		local data = cfg.log_item[self.count - data_index + 1]
		the_cell:SetData(data)
	end
end

function LuckyLogView:OpenCallBack()
	self.node_list["ListView"].scroller:ReloadData(0)
end

function LuckyLogView:OnFlush()
	self.node_list["ListView"].scroller:ReloadData(0)
end

function LuckyLogView:CloseView()
	self:Close()
end

function LuckyLogView:CloseCallBack()

end

function LuckyLogView:ReleaseCallBack()
	self.node_list["ListView"] = nil
	if next(self.log_item_list) ~= nil then
		local x = #self.log_item_list
		for i=1,x do
			self.log_item_list[i]:DeleteMe()
		end
	end
	self.log_item_list = {}
end

--------------抽奖列表
LuckyLogItem = LuckyLogItem or BaseClass(BaseCell)
function LuckyLogItem:__init()
	self.index = 0
end

function  LuckyLogItem:__delete()
end

function LuckyLogItem:OnFlush()
	local item_info = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_info then
		return
	end

	local log_num = #(Language.Common.LuckyLog) or 1
	local log_text = Language.Common.LuckyLog[math.random(1, log_num)]
	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	local time = os.date("%X", self.data.timestamp)
	if self.data.item_num > 1 then
		item_name = item_name .. " * " .. self.data.item_num
	end

	self.node_list["TxtInfo"].text.text = string.format("<color=#34ACF3FF>%s</color> %s", time, string.format(log_text, self.data.role_name, item_name))
	self.node_list["ImgBg"]:SetActive(0 == self.index % 2)
end