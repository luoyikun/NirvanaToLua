KaifuActivityPanelSeven = KaifuActivityPanelSeven or BaseClass(BaseRender)

function KaifuActivityPanelSeven:__init(instance)
	list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cell_list = {}
	self.activity_change = BindTool.Bind(self.ActiviChange, self)

	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)
end

function KaifuActivityPanelSeven:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}

	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end
end

function KaifuActivityPanelSeven:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetBattleTitleCfg()
end

function KaifuActivityPanelSeven:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = PanelSevenListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local title_cfg = KaifuActivityData.Instance:GetBattleTitleCfg() or {}
	cell_item:SetData(title_cfg[data_index + 1])
end

local BATTLE_ACT_ID_LIST = {}
for k,v in pairs(BattleActivityId) do
	BATTLE_ACT_ID_LIST[v] = true
end

function KaifuActivityPanelSeven:ActiviChange(activity_type, status, next_time, open_type)
	if BATTLE_ACT_ID_LIST[activity_type] and self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	end
end

function KaifuActivityPanelSeven:CloseCallBack()
	for k, v in pairs(self.cell_list) do
		v:RemoveCountDown()
	end
end

function KaifuActivityPanelSeven:Flush(activity_type)
	if not KaifuActivityData.Instance:IsZhengBaType(activity_type) then return end
	KaifuActivityData.Instance:SetZhengBaRedPointState(false)

	if activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end

	self.temp_activity_type = activity_type
end


PanelSevenListCell = PanelSevenListCell or BaseClass(BaseRender)

function PanelSevenListCell:__init(instance)
	self.node_list["BtnTitleRoot"].button:AddClickListener(BindTool.Bind(self.OnClickTitle, self))

	if not self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["DisplayModel"].ui3d_display)
	end

	self.is_loading = false

	self.title_effect = nil
	self.had_role_model = false
	self.cur_item_id = 0

	self.activity_states = {}

end

function PanelSevenListCell:__delete()
	TitleData.Instance:ReleaseTitleEff(self.title_effect)
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_loading = nil

	if self.title_effect then
        ResMgr:Destroy(self.title_effect)
		self.title_effect = nil
	end

	self.cur_item_id = nil
	self.activity_states = {}
	self.cur_day = nil
	self.had_role_model = false
	self.act_sep = nil
end

function PanelSevenListCell:OnClickTitle()
	if not self.cur_item_id then return end
	local data = {item_id = self.cur_item_id}
	TipsCtrl.Instance:OpenItem(data)
end

function PanelSevenListCell:RemoveCountDown()
	self.activity_states = {}
	self.cur_day = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function PanelSevenListCell:SetData(data)
	if not data then return end

	if not self.title_effect and not self.is_loading then
		self.is_loading = true
		self.cur_item_id = data.item_id
		local bundle, asset = ResPath.GetTitleModel(data.title_id)
		self:CreateAsyncLoader(self.node_list["BtnTitleRoot"].transform)

		self.async_loader:Load(bundle, asset, function(obj)
			if obj then
				local transform = obj.transform
				self.title_effect = obj.gameObject
				TitleData.Instance:LoadTitleEff(self.title_effect, data.title_id, true)	
				self.is_loading = false
			end
		end)
	end

	local activity_info = ActivityData.Instance:GetActivityStatuByType(BattleActivityId[data.act_sep])
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.node_list["TxtName"].text.text = data.act_name

	if cur_day - data.act_sep < 0 then
		self.node_list["TxtNextDayOpen"].text.text = data.act_sep
	end

	if activity_info and activity_info.next_time then
		local is_next_day = cur_day - data.act_sep < 0 and activity_info.status ~= ACTIVITY_STATUS.OPEN
		local diff_tiem = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
		local diff_hour = diff_tiem / 3600
		local format_time = os.date("*t", TimeCtrl.Instance:GetServerTime())
		local is_end = data.act_sep - cur_day < 0 or (data.act_sep - cur_day == 0 and diff_hour + format_time.hour > 24)
		local is_opening = data.act_sep - cur_day == 0 and activity_info and activity_info.status == ACTIVITY_STATUS.OPEN

		self.node_list["TxtLastTime"]:SetActive(not (is_next_day and is_end and is_opening))
		self.node_list["TxtNextDayOpen"]:SetActive(is_next_day and not (is_end))
		self.node_list["TxtEnd"]:SetActive(is_end)
		self.node_list["TxtOpening"]:SetActive(is_opening)
		self:SetRestTime(activity_info.next_time, activity_info and activity_info.status ~= ACTIVITY_STATUS.OPEN,
		self.activity_states[activity_info.type] ~= activity_info.status or self.cur_day ~= cur_day)
		self.cur_day = cur_day
		self.activity_states[activity_info.type] = activity_info.status
	end

	local battle_role_info = KaifuActivityData.Instance:GetBattleRoleInfo()[data.act_sep]
	self.node_list["ModeDisplayPanel"]:SetActive(nil ~= battle_role_info)
	self.node_list["ImgHaveNoModel"]:SetActive(not nil ~= battle_role_info)

	if battle_role_info and not self.had_role_model and self.act_sep ~= data.act_sep then
		self.had_role_model = true
		self.act_sep = data.act_sep
		
		if self.model then
			self.model:SetModelResInfo(battle_role_info, false, false, true)
		end

		self.node_list["TxtEnd"].text.text = battle_role_info.role_name or ""
	end
end

function PanelSevenListCell:SetRestTime(diff_time, is_not_open, is_remove_count_down)
	local diff_time = diff_time - TimeCtrl.Instance:GetServerTime()

	if not is_not_open or is_remove_count_down then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
	end

	if self.count_down == nil and is_not_open then
		local function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time)
			if left_time <= 0.5 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			local str = string.format(Language.Activity.ActivityLastTime , left_hour, left_min,left_sec)
			self.node_list["TxtLastTime"].text.text = str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end
