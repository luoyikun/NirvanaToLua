KuaFuTargetView = KuaFuTargetView or BaseClass(BaseView)

function KuaFuTargetView:__init()
	self.ui_config = {
		{"uis/views/crossgolbal_prefab", "KuaFuTarget"},
	}
	
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.play_audio = true
	self.close_tween = UITween.HideFadeUp
	self.select_index = 1
end

function KuaFuTargetView:LoadCallBack()
	self.cell_list = {}
	local list_delegate = self.node_list["scroll"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	-- self.data_list = {}
	self.is_anim = 0
	for i = 1, 2 do
		self.select_index = 1
		self.node_list["Toggle"..i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickToggleTab, self, i))
	end
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClcikFinalReward, self))
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.finish_item = ItemCell.New()
	self.finish_item:SetInstanceParent(self.node_list["Item"])
end

function KuaFuTargetView:__delete()
	self:CancelQuest()
	-- self.data_list = nil
end

function KuaFuTargetView:ReleaseCallBack()
	self:CancelQuest()
	for k, v in pairs(self.cell_list) do 
		if v ~= nil then
			v:DeleteMe()
		end
	end
	if self.finish_item ~= nil then
		self.finish_item:DeleteMe()
	end

	self.cell_list = nil
end

function KuaFuTargetView:OpenCallBack()
	-- KuaFuTargetData.Instance:SetToggleIndex(1)
	local index = KuaFuTargetData.Instance:GetToggleIndex()
	self.node_list["Toggle" .. index].toggle.isOn = true
	self:Flush()
end

function KuaFuTargetView:CloseCallBack()

end

function KuaFuTargetView:EffectMove(start_obj, index)
	local bundle, asset = ResPath.GetCrossGolbEff()
	self.is_anim = index
	local callback = function ()
		if self.node_list then
			self.node_list["Slot_" .. index]:SetActive(true)
		end
		self.is_anim = 0
	end
	TipsCtrl.Instance:ShowFlyEffectManager(ViewName.KuaFuTargetView, bundle, asset, start_obj, self.node_list["Slot_" .. index], nil, 0.8, callback, nil, 1)
end

function KuaFuTargetView:OnClickToggleTab(index)
	self.select_index = index
	KuaFuTargetData.Instance:SetToggleIndex(index)
	local bundle, asset = ResPath.GetCrossGolbMid(index)
	self.node_list["ImgMid"].image:LoadSprite(bundle, asset)
	-- self.data_list = KuaFuTargetData.Instance:SortItemData()
	self.node_list["scroll"].scroller:ReloadData(0)	
	-- self.node_list["scroll"].scroller:RefreshAndReloadActiveCellViews(true)
	self:Flush()
end

function KuaFuTargetView:GetNumberOfCells()
	local count = KuaFuTargetData.Instance:GetTaskCount()
	return count
end

function KuaFuTargetView:RefreshCell(cell, data_index)
	local index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = KuaFuTargetCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local data = KuaFuTargetData.Instance:GetItemData(index)
	-- cell_item:SetIndex(index)
	cell_item:SetMoveEffCallBack(BindTool.Bind(self.EffectMove, self))
	cell_item:SetData(data)
end

function KuaFuTargetView:OnFlush()
	-- self.data_list = KuaFuTargetData.Instance:SortItemData()
	self.node_list["scroll"].scroller:RefreshActiveCellViews()
	self:FlushMid()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function KuaFuTargetView:OnClcikFinalReward()
	-- local index = KuaFuTargetData.Instance:GetFinalIndex()
	if self.select_index == 1 then
		KuaFuTargetCtrl.Instance:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.FETCH_CROSS_GOAL_REWARD_REQ, 8)
	elseif self.select_index == 2 then
		KuaFuTargetCtrl.Instance:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.FETCH_GUILD_GOAL_REWAED_REQ, 8)
	end
end

function KuaFuTargetView:CancelQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function KuaFuTargetView:FlushNextTime()
	-- local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUAFUTARGET)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local start_server_time = TimeCtrl.Instance:GetServerRealStartTime()
	local startday, endday = KuaFuTargetData.Instance:GetOpenAndEndDay()
	local time = (endday + 1) * 86400 - (server_time - start_server_time)
	if time <= 0 then
		self:CancelQuest()
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["Time"].text.text = Language.CrossGolb.Time .. time_str
end

function KuaFuTargetView:FlushMid()
 	local fetch_flag = KuaFuTargetData.Instance:GetFetchUltimateRewardFlag()
 	if fetch_flag ~= nil then
 		for i = 1, 8 do
 			self.node_list["Slot_" .. i]:SetActive(fetch_flag[i] == 2 and self.is_anim ~= i)
 		end
 		local is_get = fetch_flag[9] == 2
 		local is_finish = fetch_flag[9] == 1
 		self.node_list["BtnTxt"].text.text = is_get and Language.Common.YiLingQu or Language.Common.LingQu
 		UI:SetButtonEnabled(self.node_list["BtnGet"], is_finish)
 	end
 	for i = 1, 2 do
 		local is_remind = KuaFuTargetData.Instance:GetTabRemind(i) == 1
 		self.node_list["TabRed" .. i]:SetActive(is_remind)
 	end
 	local reward_item_data = KuaFuTargetData.Instance:GetFinishAllBeforeItemData()
 	self.finish_item:SetData(reward_item_data[0])
end 

KuaFuTargetCell = KuaFuTargetCell or BaseClass(BaseCell)

function KuaFuTargetCell:__init()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["Item"])
	-- self.index = 1
	-- self.is_finish = false
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickFetch, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickGo, self))
end

function KuaFuTargetCell:__delete()
	if self.reward_item ~= nil then
		self.reward_item:DeleteMe()
	end
end

function KuaFuTargetCell:LoadCallBack()

end

-- function KuaFuTargetCell:SetIndex(index)
-- 	self.index = index
-- end

function KuaFuTargetCell:SetData(data)
	self.data = data
	if self.data == nil then 
		return 
	end
	-- local kill_num = 0
	local cond_type = self.data.cond_type or 1
	local kill_num = KuaFuTargetData.Instance:GetParamByCondType(cond_type)
	--奖励
	self.reward_item:SetData(self.data.reward_item[0])
	
	local cond_param = self.data.cond_param or 0
	local is_finish = kill_num >= cond_param
	local color = is_finish and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local str1 = ""
	if cond_type >= 1 and cond_type <= 6 then 
		str1 = string.format(Language.CrossGolb["TaskDes" .. cond_type], cond_param)
	end

	local str2 = string.format(Language.CrossGolb.FromatNum, color, kill_num, cond_param)
	self.node_list["Task"].text.text = str1 .. str2
	local is_already_fetch = 0
	is_already_fetch = KuaFuTargetData.Instance:GetFetchUltimateRewardFlag(self.data.index + 1)
	self.node_list["BtnGo"]:SetActive(is_already_fetch == 0)
	self.node_list["Button"]:SetActive(is_already_fetch ~= 0)
	UI:SetButtonEnabled(self.node_list["Button"], is_already_fetch < 2)
	local btn_txt = Language.Common.QianWang
	if is_already_fetch == 1 then
		btn_txt = Language.Common.LingQu
	elseif is_already_fetch == 2 then
		btn_txt = Language.Common.YiLingQu
	end
	self.node_list["RedPoint"]:SetActive(is_already_fetch == 1)
	self.node_list["BtnTxt"].text.text = btn_txt
end

function KuaFuTargetCell:OnClickGo()
	ViewManager.Instance:OpenByCfg(self.data.open_panel)
end

function KuaFuTargetCell:SetMoveEffCallBack(call_back)
	self.move_eff_func = call_back
end

function KuaFuTargetCell:OnClickFetch()
	local tab_index = KuaFuTargetData.Instance:GetToggleIndex()
	local is_already_fetch = KuaFuTargetData.Instance:GetFetchUltimateRewardFlag(self.data.index + 1)
	if is_already_fetch == 1 then
		if self.move_eff_func then
			-- local start_pos = self.node_list["Button"].transform.position or Vector3(0, 0, 0)
			self.move_eff_func(self.node_list["Button"], self.data.index + 1)
		end
	end
	if tab_index == 1 then
		KuaFuTargetCtrl.Instance:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.FETCH_CROSS_GOAL_REWARD_REQ, self.data.index)
	elseif tab_index == 2 then
		KuaFuTargetCtrl.Instance:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.FETCH_GUILD_GOAL_REWAED_REQ, self.data.index)
	end
end