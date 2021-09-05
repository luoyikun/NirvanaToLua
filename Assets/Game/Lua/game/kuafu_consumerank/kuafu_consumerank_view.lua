KuaFuConsumeRankView = KuaFuConsumeRankView or  BaseClass(BaseView)
local SLOT_NUM = 10
function KuaFuConsumeRankView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/kuafuconsumerank_prefab", "KuaFuConsumeRankView"}
	}
	self.cell_list = {}
	self.reward_info = {}
	self.reward_list = {}
	self.show_fram = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
end

function KuaFuConsumeRankView:__delete()

end

function KuaFuConsumeRankView:LoadCallBack()
	self.node_list["Name"].text.text = Language.KuaFuConsume.Title

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["CanYuJiang"].button:AddClickListener(BindTool.Bind(self.OnCanyu, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["Frame"]:SetActive(false)

	local data = KuaFuConsumeRankData.Instance:GetConsumeRank()
	local num = 0
	for k,v in pairs(data) do
		self.reward_info[num] = v
		num = num + 1
	end
	local activity_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_KUAFUCONSUME)
	local rest_time = activity_info and activity_info["end_time"] or 0
	-- rest_time = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_KUAFUCONSUME)["end_time"] or 0
	self:FlushTime(rest_time)
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
	self.consume_discount = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	self:InitScroller()
end

function KuaFuConsumeRankView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	self.list_view_reward = nil

	self.new_list_view_attur = nil
	self.list_view_delegate = nil

	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
end

function KuaFuConsumeRankView:OpenCallBack()
	if nil == self.timer_request then
		self.timer_request = GlobalTimerQuest:AddRunQuest(function()
			local modify_id = KuaFuConsumeRankData.Instance:GetModifyId()
			KuaFuConsumeRankCtrl.SendTianXiangOperate2(modify_id)
		end, 1)
	end
	self:Flush()
end

function KuaFuConsumeRankView:CloseCallBack()
	if self.timer_request then
		 GlobalTimerQuest:CancelQuest(self.timer_request)
		 self.timer_request = nil
	end
end

function KuaFuConsumeRankView:CompleteRollerTime()

end

function KuaFuConsumeRankView:UpdataRollerTime(elapse_time, next_time)
	self:FlushTime(next_time)
end

function KuaFuConsumeRankView:FlushTime(next_time)
	local time = math.floor(next_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		local format_time = TimeUtil.Format2TableDHM(time)
		local str_list = Language.Common.TimeList
		local time_str = ""
		if format_time.day > 0 then
			time_str = format_time.day .. str_list.d
		end
		if format_time.hour > 0 then
			time_str = time_str .. format_time.hour .. str_list.h
		end
		time_str = time_str .. format_time.min .. str_list.min
		self.node_list["Time"].text.text = string.format(Language.ZeroGift.TimeText2, time_str)
	end
end

--初始化滚动条
function KuaFuConsumeRankView:InitScroller()

	self.list_view_delegate = self.node_list["ScrollRanklist"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.list_view_reward = self.node_list["Ranklist"].list_simple_delegate
	self.list_view_reward.NumberOfCellsDel = BindTool.Bind(self.GetRankCells, self)
	self.list_view_reward.CellRefreshDel = BindTool.Bind(self.RefreshRankView, self)

	self.new_list_view_attur = self.node_list["GongXianJianglistview"].list_simple_delegate
	self.new_list_view_attur.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfNewAtturCells, self)
	self.new_list_view_attur.CellRefreshDel = BindTool.Bind(self.RefreshNewAtturView, self)
end

function KuaFuConsumeRankView:OnCanyu()
	if self.show_fram == true then
		self.node_list["Frame"]:SetActive(true)
		self.show_fram = false
	else
		self.show_fram = true
		self.node_list["Frame"]:SetActive(false)
	end
end


function KuaFuConsumeRankView:GetNumberOfCells()
	local rank_info = KuaFuConsumeRankData.Instance:GetCrossRankInfo()
	local max_num = SLOT_NUM
	if rank_info then
		max_num = #rank_info
	end
	return max_num
end

function KuaFuConsumeRankView:RefreshNewAtturView(cell, data_index)
	local item_cell = self.reward_list[cell]
	if item_cell == nil then
		item_cell = KuaFuConsumeRewardItemCell.New(cell.gameObject, self)
		self.reward_list[cell] = item_cell
		self.reward_list[cell]:SetToggleGroup(self.node_list["GongXianJianglistview"].toggle_group)
	end
	self.reward_list[cell]:SetIndex(data_index + 1)
	self.reward_list[cell]:SetData(self.reward_info[data_index])

end

function KuaFuConsumeRankView:RefreshView(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = KuaFuConsumeRankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.node_list["ScrollRanklist"].toggle_group)
	end
	the_cell:SetIndex(cell_index + 1)
	the_cell:Flush()
end


function KuaFuConsumeRankView:GetRankCells()
	return SLOT_NUM
end

function KuaFuConsumeRankView:RefreshRankView(cell, data_index)
	local item_cell = self.cell_list[cell]
	if item_cell == nil then
		item_cell = KuaFuConsumeItemCell.New(cell.gameObject, self)
		self.cell_list[cell] = item_cell
		self.cell_list[cell]:SetToggleGroup(self.node_list["Ranklist"].toggle_group)
	end
	self.cell_list[cell]:SetIndex(data_index + 1)
	self.cell_list[cell]:SetData(self.reward_info[data_index])
	item_cell:Flush()

end

function KuaFuConsumeRankView:GetNumberOfNewAtturCells()
	return 3
end

function KuaFuConsumeRankView:OnClickHelp()
	local tips_id = 319
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuaFuConsumeRankView:OnFlush()
	if self.node_list["ScrollRanklist"].scroller.isActiveAndEnabled then
		self.node_list["ScrollRanklist"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local total_consume = KuaFuConsumeRankData.Instance:GetConsumeInfo()
	self.node_list["MoneyTxt"].text.text = total_consume
end
--------------------------------------------------------------------
KuaFuConsumeRankCell = KuaFuConsumeRankCell or BaseClass(BaseCell)

function KuaFuConsumeRankCell:__init()

end

function KuaFuConsumeRankCell:__delete()

end

function KuaFuConsumeRankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	local rank_info = KuaFuConsumeRankData.Instance:GetCrossRankInfo()
	local index = self:GetIndex()

	if nil == rank_info[index] then
		return
	end

	local server_id = rank_info[index].mvp_server_id
	local server_name = LoginData.Instance:GetServerName(server_id)

	if rank_info[index].total_consume == 0 then
		return
	end
	self.node_list["QuFu"].text.text = string.format(Language.KuaFuConsume.qufu, server_id, server_name)
	self.node_list["ChongZhi"].text.text = string.format(Language.KuaFuConsume.zuanshicount, rank_info[index].total_consume)
	self.node_list["Name"].text.text = rank_info[index].mvp_name
	if index <= 3 then
		local bundle, asset = ResPath.GetConsumerRankIcon(index)
		self.node_list["Rank"].image:LoadSprite(bundle, asset, function()
			self.node_list["Rank"].image:SetNativeSize()
		end)
	else
		self.node_list["RankText"].text.text = index
	end
	self.node_list["RankText"]:SetActive(index >= 4)
	self.node_list["Rank"]:SetActive(index <= 3)
end

function KuaFuConsumeRankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

--------------
KuaFuConsumeItemCell = KuaFuConsumeItemCell or BaseClass(BaseCell)

function KuaFuConsumeItemCell:__init()

	self.from_view = 0
	self.click_hanser = nil
	self.show = ItemCell.New()
	self.show:SetInstanceParent(self.node_list["itemcell"])
end

function KuaFuConsumeItemCell:__delete()
	if self.show then
		self.show:DeleteMe()
		self.show = nil
	end
end

function KuaFuConsumeItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function KuaFuConsumeItemCell:OnFlush()
	if nil == self.data then return end
	local data = self.data
	self.show:SetData(data.join_reward_item)

	local cfg = KuaFuConsumeRankData.Instance:GetConsumeRank()
	local index = self:GetIndex()
	if nil == cfg[index] then
		return
	end
	self.node_list["Dec1"].text.text = string.format(Language.KuaFuConsume.NoRank, cfg[index].rank)
	self.node_list["Dec2"].text.text = string.format(Language.KuaFuConsume.Reward, cfg[index].need_total_consume)
end


------------------------------------
KuaFuConsumeRewardItemCell = KuaFuConsumeRewardItemCell or BaseClass(BaseCell)

function KuaFuConsumeRewardItemCell:__init()
	self.from_view = 0
	self.cell_list = {}

	for i = 1, 3 do 
		self.cell_list[i] = ItemCell.New()
		self.cell_list[i]:SetInstanceParent(self.node_list["itemcellgongxian" .. i])
	end
end

function KuaFuConsumeRewardItemCell:__delete()
	if self.cell_list then
		for i = 1, 3 do 
			if self.cell_list[i] then
				self.cell_list[i]:DeleteMe()
				self.cell_list[i] = nil
			end
		end
		self.cell_list = nil
	end
end

function KuaFuConsumeRewardItemCell:SetToggleGroup(toggle_group)
	 self.root_node.toggle.group = toggle_group
end

function KuaFuConsumeRewardItemCell:OnFlush()
	local data = self.data
	
	if data and data.person_reward_item and data.person_reward_item.item_id then
		local list = KuaFuConsumeRankData.Instance:GetGiftCfgById(data.person_reward_item.item_id)
		if list then
			for i = 1, 3 do
				if list[i] then
					self.cell_list[i]:SetData(list[i])
				end	
			end
		end

		local cfg = KuaFuConsumeRankData.Instance:GetConsumeRank()
		local index = self:GetIndex() or 0
		if not cfg or nil == cfg[index] then
			return
		end
		self.node_list["Dec"].text.text = string.format(Language.KuaFuConsume.ChongzhiReward, cfg[index].rank)
	end
end