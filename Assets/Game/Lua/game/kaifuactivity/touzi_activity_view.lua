require("game/kaifuactivity/kaifu_activity_fubentouzi_view")-- 副本投资
require("game/kaifuactivity/kaifu_activity_bosstouzi_view")	-- boss投资
require("game/kaifuactivity/kaifu_activity_shenyubosstouzi_view")	-- boss投资

local NODE_NAME_LIST = {
	[66] = "FuBenTouZiView",
	[67] = "BossTouZiView",
	[68] = "ShenyuBossTouZiView",
}

local RENDER_NAME_LIST = {
	[66] = FuBenTouZiView,
	[67] = BossTouZiView,
	[68] = ShenyuBossTouZiView,
}

TouziActivityView = TouziActivityView or BaseClass(BaseView)

-- 现在开服活动跟合服活动公用这个面板
function TouziActivityView:__init()
	self.ui_config = {
		{"uis/views/kaifuactivity/childpanel_prefab", "KaiFuAcitivityPanel_1"},
		{"uis/views/kaifuactivity/childpanel_prefab", "NodeBackground"},
		{"uis/views/kaifuactivity/childpanel_prefab", "LeftToggleGroup"},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[66], {66}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[67], {67}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[68], {68}},
		{"uis/views/kaifuactivity/childpanel_prefab", "KaiFuAcitivityPanel_2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.panel_obj_list = {}
	self.kaifu_open_data_list = {}

	self.cur_type = -1
	self.last_type = -1

	self.cur_tab_list_length = 0
	-- 开服活动里面要加合服活动，拿合服活动的sub_type当作activity_type
	-- 这里规定activity_type小于100的为合服活动
	self.combine_server_max_type = 100

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function TouziActivityView:__delete()
	self.hefu_script_list = {}
end

function TouziActivityView:ReleaseCallBack()
	self.cur_type = -1
	self.last_type = -1
	self.cur_index = 1
	self.cur_day = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.right_combine_content = nil

	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.model_2 then
		self.model_2:DeleteMe()
		self.model_2 = nil
	end
	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end
	self.cell_list = {}
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TouziActivityView)
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.panel_obj_list = {}
end

function TouziActivityView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	local title_name = "bg_activity_title3"
	local bundle, asset = ResPath.GetOpenGameActivityNoPackRes(title_name)
	if self.node_list["ImgTitle"] then
		self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	end

	self.last_type = -1

	local list_delegate = self.node_list["ScrollerToggleGroup"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TouziActivityView, BindTool.Bind(self.GetUiCallBack, self))
	RemindManager.Instance:Bind(self.remind_change, RemindName.TouziActivity)
end

function TouziActivityView:MainRoleLevelChange()
	if self.node_list["ScrollerToggleGroup"] then
		self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
	end
end

function TouziActivityView:OnClickClose()
	self:Close()
end

function TouziActivityView:SetOrRefreshDataList()
	self.kaifu_open_data_list = KaifuActivityData.Instance:GetTouziActivityList()
end

function TouziActivityView:GetNumberOfCells()
	return #self.kaifu_open_data_list
end

function TouziActivityView:RefreshCell(cell, data_index)
	local list = self.kaifu_open_data_list
	if not list or not next(list) then return end

	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local data = {}
	data.activity_type = activity_type

	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = TouziLeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.node_list["ScrollerToggleGroup"].toggle_group)

	tab_btn:SetHighLight(self.cur_type == activity_type)
	tab_btn:AddClickCallback(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1))

	data.is_show = false
	data.is_show_effect = false

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi then 		-- 副本投资
		data.is_show = KaifuActivityData.Instance:IsShowFuBenTouZiRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi then 		-- boss投资
		data.is_show = KaifuActivityData.Instance:IsShowBossTouZiRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi then 		-- 神域boss投资
		data.is_show = KaifuActivityData.Instance:IsShowBossTouZiRedPoint()
	end

	data.name = list[data_index + 1].name
	tab_btn:SetData(data)
end

function TouziActivityView:OnClickTabButton(activity_type, index)
	if self.cur_type == activity_type then
		return
	end

	self.is_auto_jump = false

	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	KaifuActivityData.Instance:SetSelect(self.cur_index)
	self:ChangeToIndex(KaifuActivityData.Instance:GetActivityTypeToIndex(self.cur_type))
	RemindManager.Instance:Fire(RemindName.TouziActivity)
end

function TouziActivityView:OpenPanel()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end


function TouziActivityView:ShowIndexCallBack(index, index_nodes)
	local default_open_act_type = KaifuActivityData.Instance:GetDefaultOpenActType()
	if -1 ~= default_open_act_type then
		self.cur_type = default_open_act_type < 100000 and default_open_act_type or (default_open_act_type - 100000)
		self:ChangeToIndex(KaifuActivityData.Instance:GetActivityTypeToIndex(self.cur_type))
		KaifuActivityData.Instance:ClearDefaultOpenActType()
	else
		self.cur_type = KaifuActivityData.Instance:GetActivityTypeByIndex(index)
	end
	

	if index_nodes then
		local prefab_name = NODE_NAME_LIST[index]
		self.panel_obj_list[index] = index_nodes[prefab_name]
		self.panel_list[index] = RENDER_NAME_LIST[index].New(self.panel_obj_list[index])
	end

	if self.panel_list[index] and self.panel_list[index].OpenCallBack then
		self.panel_list[index]:OpenCallBack()
	end

	local list = KaifuActivityData.Instance:GetOpenActivityList()
	for k,v in pairs(list) do
		if v.activity_type == self.cur_type then
			self.cur_index = k
		end
	end
	self:Flush()
end

function TouziActivityView:OpenCallBack()
	self.is_auto_jump = true
end

function TouziActivityView:CloseCallBack()
	RemindManager.Instance:Fire(RemindName.TouziActivity)
	self.last_type = self.cur_type
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.cur_day = nil
	self.cur_index = 1
	

	for k,v in pairs(self.panel_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end

	self.cur_tab_list_length = 0
	
end



-- 刷新fubentouzi
function TouziActivityView:FlushFuBenTouZi()
	if self.panel_list[66] then
		self.panel_list[66]:Flush()
	end
end

-- 刷新bosstouzi
function TouziActivityView:FlushBossTouZi()
	if self.panel_list[67] then
		self.panel_list[67]:Flush()
	end
end

-- 刷新神域bosstouzi
function TouziActivityView:FlushShenYuBossTouZi()
	if self.panel_list[68] then
		self.panel_list[68]:Flush()
	end
end


function TouziActivityView:OnFlush(param_t)
	self.cur_tab_list_length = #self.kaifu_open_data_list or 0
	self:SetOrRefreshDataList()
	local list = self.kaifu_open_data_list
	if list and next(list) then
		self:FlushLeftTabListView(list)
		self:FlushRightPanel(list, param_t)
	end

	-- 自动跳到对应标签下
	if self.is_auto_jump then
		self.is_auto_jump = false
		if self.cur_index - 1 > 0 then
			self.node_list["ScrollerToggleGroup"].scroller:JumpToDataIndex(self.cur_index - 1)
		end
	end
end

function TouziActivityView:FlushLeftTabListView(list)
	if list == nil or next(list) == nil then return end

	if self.node_list["ScrollerToggleGroup"].scroller.isActiveAndEnabled then
		if self.cur_day ~= TimeCtrl.Instance:GetCurOpenServerDay() or self.cur_tab_list_length ~= #list then
			if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
				self.cur_index = 1
			end
			self.cur_tab_list_length = #list
			self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
		else
			self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
end

function TouziActivityView:FlushRightPanel(list, param_t)
	local default_open_act_type = KaifuActivityData.Instance:GetDefaultOpenActType()
	if -1 ~= default_open_act_type then
		self.cur_type = default_open_act_type < 100000 and default_open_act_type or (default_open_act_type - 100000)
	else
		self.cur_type = self.cur_type or list[self.cur_index].activity_type
	end

	local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
	if cond then
		if KaifuActivityData.Instance:IsAdvanceType(self.cur_type) then
			if jinjie_type then
				if not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type) then
					local str = string.format(Language.OpenServer.JinjieTips, Language.Common.Jinjie_Type[jinjie_type], cond)
					self.node_list["TxtCurDayName"].text.text = str
				else
					local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.cur_type) or {}
					local rank = rank_info.myself_rank or -1
					local str = (rank + 1 >= 1 and rank + 1 < 100) and
					Language.Common.Jinjie_Type[jinjie_type]..string.format(Language.Rank.OnRankNum, rank + 1)or Language.Rank.NoInRank
					self.node_list["TxtRankName"].text.text = str
				end
			end
		end
		if KaifuActivityData.Instance:IsChongzhiType(self.cur_type) then
			local cond = CommonDataManager.ConverMoney(cond)
			if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
				self.node_list["TxtLeiJiDiamonds"].text.text = cond
			else
				self.node_list["TxtCurDiamonds"].text.text = "<color=#fde45c>" ..cond .. "</color>"
			end
		end
		if KaifuActivityData.Instance:IsNomalType(self.cur_type) then
			local pata_tips_str = string.format(Language.OpenServer.PaTaTips, Language.Common.Jinjie_Type[jinjie_type], cond)
			local exp_challenge_str = string.format(Language.OpenServer.ExpChallengeTips, Language.Common.Jinjie_Type[jinjie_type], cond)
			self.node_list["TxtExpChallenge"] = exp_challenge_str
			self.node_list["TxtPatatips"].text.text = pata_tips_str
		end
		if KaifuActivityData.Instance:IsStrengthenType(self.cur_type) then
			local str = string.format(Language.OpenServer.StrengthTips,Language.Common.Jinjie_Type[jinjie_type],cond)
			self.node_list["TxtEquipName"].text.text = str
		end
	end

	local panel_index = self:ShowWhichPanelByType(self.cur_type) or 0
	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush(self.cur_type)
		if self.panel_list[panel_index].FlushView then
			self.panel_list[panel_index]:FlushView()
		end
	end

	local chongzhi_time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local chongzhi_cur_time = chongzhi_time_table.hour * 3600 + chongzhi_time_table.min * 60 + chongzhi_time_table.sec
	local chongzhi_reset_time_s = 24 * 3600 - chongzhi_cur_time
	self:SetRestTime(chongzhi_reset_time_s)

	self.node_list["NodeChongzhi"]:SetActive(KaifuActivityData.Instance:IsChongzhiType(self.cur_type)
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE
											)
	self.node_list["NodeJinJie"]:SetActive(KaifuActivityData.Instance:IsAdvanceType(self.cur_type) and not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))
	self.node_list["NodePaTa"]:SetActive(KaifuActivityData.Instance:IsPaTaType(self.cur_type))
	self.node_list["NodeExpChallenge"]:SetActive(KaifuActivityData.Instance:IsExpChallengeType(self.cur_type))
	self.node_list["NodeEquipStrengthen"]:SetActive(KaifuActivityData.Instance:IsStrengthenType(self.cur_type))
	self.node_list["NodeRankJinjie"]:SetActive(KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))

	local is_show_top_bg = true
	local not_show_top_bg_act = {
		[ACTIVITY_TYPE.RAND_DAILY_LOVE] = 1
	}

	is_show_top_bg = not KaifuActivityData.Instance:IsZhengBaType(self.cur_type) and nil == not_show_top_bg_act[self.cur_type]
	self.node_list["NodeBackground"]:SetActive(is_show_top_bg)
	self.node_list["NodeLeiJiChongzhi"]:SetActive(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)

	local is_show_normal_bg = self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP and self.cur_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION
	 and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU

	local is_show_jizi_bg = self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU
	local is_show_no_bg = self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU or KaifuActivityData.Instance:IsTempAddType(self.cur_type)

	self.node_list["NodePersonalBuy"]:SetActive(not is_show_normal_bg and not is_show_jizi_bg and not is_show_no_bg)
end


function TouziActivityView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end

			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			--要设置的时间字符串
			local hour_str = ""
			local min_str = ""
			local sec_str = ""
			if left_hour < 10 then
				hour_str = 0 .. left_hour
			else
				hour_str = left_hour
			end
			if left_min < 10 then
				min_str = 0 .. left_min
			else
				min_str = left_min
			end
			if left_sec < 10 then
				sec_str = 0 .. left_sec
			else
				sec_str = left_sec
			end

			local time_str = TimeUtil.FormatSecond(left_time, 10)
			self.node_list["TxtPerSonalOneDay"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function TouziActivityView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end

function TouziActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function TouziActivityView:OpenCombineChildPanel()
	if self.cur_type > self.combine_server_max_type then
		return
	end
	local cur_type = self.cur_type
	local panel = self.combine_panel_list[cur_type]
	if nil == panel then
		local async_loader = AllocAsyncLoader(self, "panel_loader_" .. cur_type)
		async_loader:Load(
			"uis/views/hefuactivity/childpanel_prefab",
			"hefu_panel_" .. cur_type,
			function(obj)
				if IsNil(obj) then
					return
				end

				obj.transform:SetParent(self.node_list["NodeRightCombineContent"].transform, false)
				obj = U3DObject(obj)
				if nil == self.hefu_script_list[cur_type] then
					print_error("没有对应的脚本文件！！！！, 活动号：", cur_type)
					return
				end
				panel = self.hefu_script_list[cur_type].New(obj)
				self.combine_panel_list[cur_type] = panel
				panel:SetActive(true)
				if panel.OpenCallBack then
					panel:OpenCallBack()
				end
			end)
	else
		panel:SetActive(true)

		if panel.OpenCallBack then
			panel:OpenCallBack()
		end
	end
end

function TouziActivityView:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end
	return KaifuActivityData.Instance:GetActivityTypeToIndex(activity_type)
end


TouziLeftTableButton = TouziLeftTableButton or BaseClass(BaseRender)

function TouziLeftTableButton:__init(instance)

end

function TouziLeftTableButton:SetData(data)
	if data == nil then return end
	self.data = data
	self.node_list["TxtLight"].text.text = data.name
	self.node_list["TxtHighLight"].text.text = data.name
	self.node_list["ImgRedPoint"]:SetActive(data.is_show)
	self.node_list["ImgFlag"]:SetActive(data.is_show_effect)
end

function TouziLeftTableButton:GetData()
	return self.data
end

function TouziLeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function TouziLeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function TouziLeftTableButton:AddClickCallback(click_callback)
	self.node_list["TabButton"].toggle:AddClickListener(click_callback)
end