GiftRecordView = GiftRecordView or BaseClass(BaseView)

function GiftRecordView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "GiftRecordView"}}
	self.cell_list = {}
end

function GiftRecordView:__delete()

end

function GiftRecordView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function GiftRecordView:LoadCallBack()
	self.select_index = nil			-- 记录已选择格子位置

	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnAllReturn"].button:AddClickListener(BindTool.Bind(self.ClickAllReturn, self))
		-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
		--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
		--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1

		local record_cell = self.cell_list[cell]
		if record_cell == nil then
			record_cell = GiftInfoCell.New(cell.gameObject)
			record_cell.gift_record_view = self
			self.cell_list[cell] = record_cell
		end

		record_cell:SetIndex(data_index)
		record_cell:SetData(self.scroller_data[data_index])
	end

end

function GiftRecordView:OpenCallBack()
	self:Flush()
end

function GiftRecordView:ClickAllReturn()
	ScoietyCtrl.Instance:SendGiftReq(nil, 1, 1)
	SysMsgCtrl.Instance:ErrorRemind(Language.Society.RecGiftScecss)
	self:Close()
end

function GiftRecordView:CloseWindow()
	self:Close()
end

function GiftRecordView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function GiftRecordView:GetSelectIndex()
	return self.select_index or 0
end

function GiftRecordView:OnFlush()
	self.scroller_data = ScoietyData.Instance:GetGiftRecordList()
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)

	local send_times = ScoietyData.Instance:GetSendGiftTimes()
	local get_times = ScoietyData.Instance:GetShouGiftTimes()
	self.node_list["SendGiftTimesText"].text.text = string.format(Language.Society.SendGiftTimes, send_times)
	self.node_list["GetGiftTimesText"].text.text = string.format(Language.Society.GetGiftTimes, get_times)

end


----------------------------------------------------------------------------
--GiftInfoCell 		--送礼记录滚动条格子
----------------------------------------------------------------------------

GiftInfoCell = GiftInfoCell or BaseClass(BaseCell)

function GiftInfoCell:__init()
	self.node_list["RecordBtn"].button:AddClickListener(BindTool.Bind(self.ClickRec, self))
end

function GiftInfoCell:__delete()

end

function GiftInfoCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.node_list["RecordBtn"]:SetActive(self.data.is_return ~= 1)
	self.node_list["NameText"].text.text =string.format(Language.Society.Name, self.data.role_name) 

	-- local shou_gift_time = self.data.shou_gift_time
	-- local server_time = TimeCtrl.Instance:GetServerTime()
	-- local time_rec = math.floor(server_time - shou_gift_time)
	-- local time_str = ""
	-- if time_rec > 60 then
	-- 	if time_rec > 3600 then				--大于一小时
	-- 		local hour = math.floor(time_rec/3600)
	-- 		time_str = string.format(Language.Common.BeforeXXHour, hour)
	-- 	elseif time_rec > 86400 then		--大于一天
	-- 		local day = math.floor(time_rec/86400)
	-- 		time_str = string.format(Language.Common.BeforeXXDay, day)
	-- 	elseif time_rec > 2592000 then		--大于一个月
	-- 		local month = math.floor(time_rec/2592000)
	-- 		time_str = string.format(Language.Common.BeforeXXMonth, month)
	-- 	else
	-- 		local minute = math.floor(time_rec/60)
	-- 		time_str = string.format(Language.Common.BeforeXXMinute, minute)
	-- 	end
	-- end
	-- time_str = ToColorStr(time_str, TEXT_COLOR.GREEN)
end

function GiftInfoCell:ClickRec()
	ScoietyCtrl.Instance:SendGiftReq(self.data.role_id, 0, 1)
end