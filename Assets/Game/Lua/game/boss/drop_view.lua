DropContentView = DropContentView or BaseClass(BaseView)
function DropContentView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/bossview_prefab", "DropPanel"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.type_num = 0
end

function DropContentView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(1060,655,0)
	self.node_list["Txt"].text.text = Language.Boss.DropTitle
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.list_data = {}
	self.cell_list = {}
	list_simple_delegate = self.node_list["list_view"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function DropContentView:__delete()

end

function DropContentView:OpenCallBack()
	-- BossCtrl.Instance:RequestDropLog()
	-- BossCtrl.Instance:SendCrossBossBossInfoReq(CROSS_BOSS_OPERATE_TYPE.DROP_RECORD)
end


function DropContentView:CloseView()
	self:Close()
end

function DropContentView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function DropContentView:GetNumberOfCell()
	return #self.list_data
end

function DropContentView:SendRequest(type_num)
	self.type_num = type_num
	if type_num ~= DROP_LOG_TYPE.DOPE_LOG_TYPE_OTHER then
		BossCtrl.Instance:RequestDropLog(type_num)
	end
end

function DropContentView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local drop_cell = self.cell_list[cell]
	if nil == drop_cell then
		drop_cell = DropCellItem.New(cell.gameObject)
		self.cell_list[cell] = drop_cell
	end

	drop_cell:SetData(self.list_data[data_index])
end

function DropContentView:OnFlush()
	if self.type_num == DROP_LOG_TYPE.DOPE_LOG_TYPE_OTHER then
		self.list_data = BossData.Instance:GetShenYuBossDropLog() or {}
	else
		self.list_data = BossData.Instance:GetDropLog() or {}
	end
	self.node_list["list_view"].scroller:ReloadData(0)
end

DropCellItem = DropCellItem or BaseClass(BaseCell)
function DropCellItem:__init()
end

function DropCellItem:__delete()
end

function DropCellItem:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end

	local time_str = os.date("%m/%d %X", self.data.timestamp)
	local name_str = self.data.role_name

	local scene_name = ""
	local scene_config = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	if scene_config then
		scene_name = scene_config.name
	end

	local boss_name = ""
	local boss_cfg_info = BossData.Instance:GetMonsterInfo(self.data.monster_id)
	if boss_cfg_info then
		boss_name = boss_cfg_info.name
	end

	local param_interval = ":"
	local xianpin_type_list_num = self.data.xianpin_type_list and #self.data.xianpin_type_list or 0
	local param = ""
	local num = 6 + xianpin_type_list_num
	for i=1, num do
		if i <= 6 then
			param = param .. param_interval
		else
			if self.data.xianpin_type_list and self.data.xianpin_type_list[i - 6] then
				param = param .. param_interval .. self.data.xianpin_type_list[i - 6]
			end
		end
	end

	local str = ""
	if self.data.is_cross == 1 then
		str = string.format(Language.Boss.BossDrop, time_str, TEXT_COLOR.YELLOW, name_str, TEXT_COLOR.RED, scene_name, TEXT_COLOR.YELLOW, boss_name, self.data.item_id, param, self.data.item_num)
	elseif self.data.is_cross == 0 then
		str = string.format(Language.Boss.BossDrop, time_str, TEXT_COLOR.YELLOW, name_str, TEXT_COLOR.GREEN, scene_name, TEXT_COLOR.YELLOW, boss_name, self.data.item_id, param, self.data.item_num)
	end
	RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, str)
end