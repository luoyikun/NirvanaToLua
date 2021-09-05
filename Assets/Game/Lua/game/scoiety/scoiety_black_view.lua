ScoietyBlackView = ScoietyBlackView or BaseClass(BaseView)
function ScoietyBlackView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/scoietyview_prefab", "BlackList"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.cell_list = {}
end

function ScoietyBlackView:__delete()

end

function ScoietyBlackView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
end

function ScoietyBlackView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(765,485,0)
	self.node_list["Txt"].text.text = Language.Title.HeiMingDan

	self.select_index = nil			-- 记录已选择格子位置

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
		-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local black_cell = self.cell_list[cell]
		if black_cell == nil then
			black_cell = ScrollerBlackCell.New(cell.gameObject)
			black_cell.black_view = self
			self.cell_list[cell] = black_cell
		end

		black_cell:SetIndex(data_index)
		black_cell:SetData(self.scroller_data[data_index])
	end
end

function ScoietyBlackView:OpenCallBack()
	self:Flush()
end

function ScoietyBlackView:CloseWindow()
	self:Close()
end

function ScoietyBlackView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyBlackView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyBlackView:OnFlush()
	self.scroller_data = ScoietyData.Instance:GetBlackList()
	self.node_list["ListView"].scroller:ReloadData(0)
end


----------------------------------------------------------------------------
--ScrollerBlackCell 		好友滚动条格子
----------------------------------------------------------------------------

ScrollerBlackCell = ScrollerBlackCell or BaseClass(BaseCell)

function ScrollerBlackCell:__init()
	self.node_list["BtnRemove"].button:AddClickListener(BindTool.Bind(self.ClickRemove, self))
end

function ScrollerBlackCell:__delete()
	self.index = nil
	self.data = nil
	self.black_view = nil
end

function ScrollerBlackCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.node_list["NameTxt"].text.text = self.data.gamename

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- self.node_list["LevelTxt"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof)

	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.sex, self.data.prof, false)
end

function ScrollerBlackCell:OnToggleAcitve(isOn)
	if isOn then
		self.black_view:SetSelectIndex(self.index)
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.BlackType, self.data.gamename)
	end
end

function ScrollerBlackCell:ClickRemove()
	ScoietyCtrl.Instance:DeleteBlackReq(self.data.user_id)
end