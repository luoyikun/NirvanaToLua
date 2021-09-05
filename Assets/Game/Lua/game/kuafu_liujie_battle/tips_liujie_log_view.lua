TipsLiuJieLogView = TipsLiuJieLogView or BaseClass(BaseView)

function TipsLiuJieLogView:__init()
	self.ui_config = {
		{"uis/views/kuafuliujie_prefab", "KuaFuLiuJieLogView"},
	}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsLiuJieLogView:__delete()
end

function TipsLiuJieLogView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCloakNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCloakCell, self)
end

function TipsLiuJieLogView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

end

function TipsLiuJieLogView:GetCloakNumberOfCells()
	local num = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if num and num.log_count then
		return num.log_count
	end
	return 0
end

function TipsLiuJieLogView:RefreshCloakCell(cell, cell_index)
	local record_cell = self.cell_list[cell]
	local log_info = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if nil ~= log_info and log_info.item_list ~= nil then
		if record_cell == nil then
			record_cell = LiuJieLogItem.New(cell.gameObject)
			self.cell_list[cell] = record_cell
		end
		record_cell:SetData(log_info.item_list[cell_index + 1])
	end
end

function TipsLiuJieLogView:OnFlush()

end

function TipsLiuJieLogView:OpenCallBack()
	-- self.node_list["TxtNoKill"]:SetActive(true)
	local log_info = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if log_info and log_info.log_count and log_info.log_count > 0 then
		self.node_list["TxtNoKill"]:SetActive(false)
	end
	self.node_list["ListView"].scroller:ReloadData(0)
end

function TipsLiuJieLogView:OnCloseClick()
	self:Close()
end

--------------------LiuJieLogItem--------------------
LiuJieLogItem = LiuJieLogItem or BaseClass(BaseCell)

function LiuJieLogItem:__init()

end

function LiuJieLogItem:__delete()

end

function LiuJieLogItem:OnFlush()
	local item_info = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_info then
		return
	end

	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	local time = os.date("%X", self.data.timestamp)
	self.node_list["TxtLog"].text.text = string.format(Language.KuafuGuildBattle.KfLiuJieLogTips, self.data.name, time, item_name)
end
--------------------LiuJieLogItem-End-------------------