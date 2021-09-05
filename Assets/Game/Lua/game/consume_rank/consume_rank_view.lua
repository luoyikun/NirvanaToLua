ConsumeRankView = ConsumeRankView or BaseClass(BaseView)

function ConsumeRankView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/consumerank_prefab", "ConsumeRank"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true
end

function ConsumeRankView:__delete()

end

function ConsumeRankView:LoadCallBack()
	self.node_list["Name"].text.text = Language.Title.XiaoFei
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self:InitScroller()
	self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))
end

function ConsumeRankView:ReleaseCallBack()
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

	-- 清理变量和对象
	self.scroller = nil
	self.rank = nil
	self.recharge = nil
end

function ConsumeRankView:InitScroller()
	self.scroller = self.node_list["ListView"]
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = ConsumeRankData.Instance:GetConsumeRankCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ConsumeRankCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function ConsumeRankView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_CONSUME_GOLD_RANK)
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD)
	self:Flush()
end

function ConsumeRankView:OnRankChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD then
		self:Flush()
	end
end

function ConsumeRankView:ShowIndexCallBack(index)

end

function ConsumeRankView:CloseCallBack()

end

function ConsumeRankView:OnFlush(param_t)
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local rank_type = RankData.Instance:GetRankType()
	local rank = Language.Common.NoRank
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD then
		local rank_list = RankData.Instance:GetRankList()
		for k,v in pairs(rank_list) do
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if v and role_vo and v.user_id == role_vo.role_id then
				rank = k
			end
		end
	end
	self.node_list["TxtRank"].text.text = string.format(Language.ConsumeRank.RankTips, rank)

	self.node_list["TxtRecharge"].text.text = ConsumeRankData.Instance:GetRandActConsume()
end

function ConsumeRankView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_CONSUME_GOLD_RANK)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.JinYinTa.ActEndTime, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtTime"].text.text = time_str
end

---------------------------------------------------------------
--滚动条格子

ConsumeRankCell = ConsumeRankCell or BaseClass(BaseCell)

function ConsumeRankCell:__init()
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
end

function ConsumeRankCell:__delete()
	for k,v in pairs(self.reward_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_list = {}
end

function ConsumeRankCell:OnFlush()
	if nil == self.data then return end
	local name = ""
	local prof = 0
	local sex = 0
	if self.data.rank_index and self.data.rank_index < 3 then
		local rank_type = RankData.Instance:GetRankType()
		if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD then
			local rank_list = RankData.Instance:GetRankList()
			if rank_list and rank_list[self.data.rank_index + 1] then
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
	self.node_list["TxtRanking"].text.text = string.format(Language.ConsumeRank.RankConsumeCanGet, self.data.need_rank)
	self.node_list["TxtRanking2"].text.text = self.data.limit_comsume
end

function ConsumeRankCell:ClickRechange()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	-- ViewManager.Instance:Open(ViewName.VipView)
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end