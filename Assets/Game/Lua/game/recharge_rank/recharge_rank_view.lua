RechargeRankView = RechargeRankView or BaseClass(BaseView)

function RechargeRankView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
	{"uis/views/randomact/rechargerank_prefab", "RechargeRank"},
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RechargeRankView:__delete()

end

function RechargeRankView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Name"].text.text = Language.RechargeCapacity.RankActName
	self:InitScroller()
	self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))
end

function RechargeRankView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.rank_change_event then
		GlobalEventSystem:UnBind(self.rank_change_event)
		self.rank_change_event = nil
	end
end

function RechargeRankView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	self.data = RechargeRankData.Instance:GetRechargeRankCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  RechargeRankCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function RechargeRankView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE)
	self:Flush()
end

function RechargeRankView:OnRankChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
		self:Flush()
	end
end

function RechargeRankView:ShowIndexCallBack(index)

end

function RechargeRankView:CloseCallBack()

end

function RechargeRankView:OnFlush(param_t)
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local rank_type = RankData.Instance:GetRankType()
	local rank = Language.Common.NoRank
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
		local rank_list = RankData.Instance:GetRankList()
		for k,v in pairs(rank_list) do
			if v.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
				rank = k
			end
		end
	end
	self.node_list["TxtRank"].text.text =string.format(Language.RechargeCapacity.Rank, rank) 
	self.node_list["TxtRecharge"].text.text = ToColorStr(RechargeRankData.Instance:GetRandActRecharge(), TEXT_COLOR.LIGHTYELLOW)
	--string.format(Language.RechargeCapacity.Recharge,  RechargeRankData.Instance:GetRandActRecharge())
end

function RechargeRankView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_CHONGZHI_RANK)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)
	if time_tab.day > 0 then
		local str = string.format(Language.IncreaseCapablity.ResTime, time_tab.day, time_tab.hour)--, time_tab.min, time_tab.s)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str) --ToColorStr(str, TEXT_COLOR.GREEN_4)
	else
		local str = TimeUtil.FormatSecond2HMS(time)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str)
	end
end
---------------------------------------------------------------
--滚动条格子

RechargeRankCell = RechargeRankCell or BaseClass(BaseCell)

function RechargeRankCell:__init()
	self.node_list["StartBtn"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end
end

function RechargeRankCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function RechargeRankCell:OnFlush()
	if nil == self.data then return end
	self.node_list["ImageHuanguan"]:SetActive(false)
	local name = ""
	local prof = 0
	local sex = 0
	if self.data.rank_index < 3 then
		if self.data.rank_index == 0 then 
			self.node_list["ImageHuanguan"]:SetActive(true)
		end
		local rank_type = RankData.Instance:GetRankType()
		if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
			local rank_list = RankData.Instance:GetRankList()
			if rank_list[self.data.rank_index + 1] then
				name = rank_list[self.data.rank_index + 1].user_name
				prof = (rank_list[self.data.rank_index + 1].prof % 10)
				sex = rank_list[self.data.rank_index + 1].sex
			end
		end
	end
	self.node_list["TxtName"].text.text = name
	if prof ~= 0 then
		self.node_list["ImgPortraitCirle"]:SetActive(true)
		if prof > 2 then
			sex = 0
		else
			sex = 1
		end
		local bundle, asset = ResPath.GetRoleHeadSmall(prof,sex)
		self.node_list["ImagePortrait"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["ImgPortraitCirle"]:SetActive(false)
	end

	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v:ShowGetEffect(item_list[k] ~= nil and self.data.rank_index < 3 and k == 1)
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	--self.node_list["TxtRanking"].text.text =string.format(Language.RechargeCapacity.NeedGoldRank, self.data.need_rank, self.data.limit_chongzhi)
	self.node_list["TxtRanking"].text.text = string.format(Language.RechargeCapacity.NeedGoldRank, self.data.need_rank)
	self.node_list["TxtGoldNum"].text.text = ToColorStr(self.data.limit_chongzhi, "#00ff30")
end

function RechargeRankCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end