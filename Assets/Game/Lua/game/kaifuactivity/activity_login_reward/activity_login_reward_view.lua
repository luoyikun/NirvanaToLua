ActivityPanelLogicRewardView =  ActivityPanelLogicRewardView or BaseClass(BaseRender)

function ActivityPanelLogicRewardView:__init()
	self.contain_cell_list = {}
	self.list_data = {}
end

function ActivityPanelLogicRewardView:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.list_view = nil
	self.contain_cell_list = nil
	self.login_day = nil
end

function ActivityPanelLogicRewardView:OpenCallBack()
	self:SetActId()
	--奖励列表
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	--登录天数
	local login_text = string.format(Language.HefuActivity.LoginDay, ActivityPanelLoginRewardData.Instance:GetCurLoginDays(self.act_id))
	self.node_list["LoginDay"].text.text = login_text

	--活动剩余时间
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT)
	-- local active_state = ActivityData.Instance:GetActivityStatuByType(self.act_id)
	-- local end_time = active_state.end_time - TimeCtrl.Instance:GetServerTime() 
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))
end

function ActivityPanelLogicRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function ActivityPanelLogicRewardView:SetActId()
	if ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT) then
		self.act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT
	end
end

function ActivityPanelLogicRewardView:OnFlush()
	self.list_data = ActivityPanelLoginRewardData.Instance:GetShowListTab(self.act_id)
	-- print_error(self.list_data)
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	self.node_list["LoginDay"].text.text = string.format(Language.HefuActivity.LoginDay, ActivityPanelLoginRewardData.Instance:GetCurLoginDays(self.act_id))
end

function ActivityPanelLogicRewardView:GetNumberOfCells()
	-- return ActivityPanelLoginRewardData.Instance:GetRewardNum(self.act_id)
	return #self.list_data
end

function ActivityPanelLogicRewardView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LogicRewardItemCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	local data = self.list_data[cell_index + 1]
	contain_cell:SetActId(self.act_id)
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(data)
end

-- function ActivityPanelLogicRewardView:RefreshCell(cell, cell_index)
-- 	local contain_cell = self.contain_cell_list[cell]
-- 	if contain_cell == nil then
-- 		contain_cell = LogicRewardItemCell.New(cell.gameObject, self)
-- 		self.contain_cell_list[cell] = contain_cell
-- 	end

-- 	cell_index = cell_index + 1
-- 	local reward_cfg = ActivityPanelLoginRewardData.Instance:GetRewardCfg(self.act_id, cell_index)
-- 	if not reward_cfg then
-- 		return
-- 	end

-- 	local data = {}
-- 	data.reward_item = reward_cfg.reward_item
-- 	data.can_get = ActivityPanelLoginRewardData.Instance:CanGetReward(self.act_id, cell_index)
-- 	data.is_overdue = ActivityPanelLoginRewardData.Instance:IsOverdue(self.act_id, cell_index)
-- 	data.is_get = ActivityPanelLoginRewardData.Instance:IsGet(self.act_id, cell_index)
-- 	data.seq = reward_cfg.seq
-- 	data.need_login_days = reward_cfg.need_login_days
-- 	data.act_id = self.act_id

-- 	contain_cell:SetIndex(cell_index)
-- 	contain_cell:SetData(data)
-- 	contain_cell:Flush()
-- end

function ActivityPanelLogicRewardView:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["RestTime"].text.text = time_str
end


----------------------------LogicRewardItemCell---------------------------------
LogicRewardItemCell = LogicRewardItemCell or BaseClass(BaseCell)

function LogicRewardItemCell:__init()
	self.node_list["GetBtn"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cell_list[i] = item_cell
	end
end

function LogicRewardItemCell:__delete()
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LogicRewardItemCell:SetActId(act_id)
	self.act_id = act_id
end

function LogicRewardItemCell:OnFlush()
	if self.data == nil then return end

	self.node_list["GoldTip"].text.text = string.format(Language.HefuActivity.RewardTips, self.data.need_login_days)
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	if #item_list == 0 then
		item_list[1] = self.data.reward_item
	end
	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_list[i]:SetActive(true)
		else
			self.item_cell_list[i]:SetActive(false)
		end
	end

	UI:SetButtonEnabled(self.node_list["GetBtn"], false)
	UI:SetGraphicGrey(self.node_list["GetBtn"], true)
	self.node_list["RedPoint"]:SetActive(false)

	-- if self.data.can_get then
	-- 	self.node_list["BtnText"].text.text = "领取"

	-- 	UI:SetButtonEnabled(self.node_list["GetBtn"], true)
	-- 	UI:SetGraphicGrey(self.node_list["GetBtn"], false)
	-- 	self.node_list["RedPoint"]:SetActive(true)
	-- elseif self.data.is_overdue then
	-- 	self.node_list["BtnText"].text.text = "已过期"
	-- elseif self.data.is_get then
	-- 	self.node_list["BtnText"].text.text = "已领取"
	-- end

	if self.data.get_flag == 0 then
		self.node_list["BtnText"].text.text = "领取"

		UI:SetButtonEnabled(self.node_list["GetBtn"], true)
		UI:SetGraphicGrey(self.node_list["GetBtn"], false)
		self.node_list["RedPoint"]:SetActive(true)
	elseif self.data.get_flag == 1 then
		self.node_list["BtnText"].text.text = "领取"
	elseif self.data.get_flag == 2 then
		self.node_list["BtnText"].text.text = "已领取"
	elseif self.data.get_flag == 3 then
		self.node_list["BtnText"].text.text = "已过期"
	end
end

function LogicRewardItemCell:OnClickGet()
	-- print_error(self.data.act_id, RA_LOGIN_GIFT_OPERA_TYPE.RA_LOGIN_GIFT_OPERA_TYPE_FETCH_COMMON_REWARD, self.data.seq)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.act_id, RA_LOGIN_GIFT_OPERA_TYPE.RA_LOGIN_GIFT_OPERA_TYPE_FETCH_COMMON_REWARD, self.data.seq)
end
