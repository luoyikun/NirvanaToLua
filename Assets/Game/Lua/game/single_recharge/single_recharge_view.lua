SingleRechargeView = SingleRechargeView or BaseClass(BaseView)

function SingleRechargeView:__init()

	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
	{"uis/views/randomact/singlerecharge_prefab", "SingleRecharge"},
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
  	self.close_tween = UITween.HideFadeUp
end

function SingleRechargeView:__delete()

end

function SingleRechargeView:LoadCallBack()
	self.node_list["Name"].text.text = Language.DanFanHaoLi.PanelName
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self:InitScroller()
	self.cell_list = {}
end

function SingleRechargeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function SingleRechargeView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	self.data = SingleRechargeData.Instance:GetSingleRechargeCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  SingleRechargeCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function SingleRechargeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO)
	self:Flush()
end

function SingleRechargeView:ShowIndexCallBack(index)

end

function SingleRechargeView:CloseCallBack()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SINGLE_CHONGZHI, false)
end

function SingleRechargeView:OnFlush(param_t)
	self.data = SingleRechargeData.Instance:GetSingleRechargeCfg()
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
		local rank_list = RankData.Instance:GetRankList() or {}
		for k,v in pairs(rank_list) do
			if v.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
				rank = k
			end
		end
	end

	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function SingleRechargeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI) or 0
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.node_list["TxtTime"].text.text = string.format(Language.ZhiZhunHaoLi.ActivityTime,TimeUtil.FormatSecond(time, 6))
	elseif time > 3600 then
		self.node_list["TxtTime"].text.text = string.format(Language.ZhiZhunHaoLi.ActivityTime,TimeUtil.FormatSecond(time, 0))
	else
		self.node_list["TxtTime"].text.text = string.format(Language.ZhiZhunHaoLi.ActivityTime,TimeUtil.FormatSecond(time, 2))
	end
end

---------------------------------------------------------------
--滚动条格子

SingleRechargeCell = SingleRechargeCell or BaseClass(BaseCell)

function SingleRechargeCell:__init()

	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))

	UI:SetGraphicGrey(self.node_list["TxtButton"], is_text_gray)
end

function SingleRechargeCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function SingleRechargeCell:OnFlush()
	if nil == self.data then return end
	local config = self.data.config
	local reward_gold = config.reward_gold
	self.node_list["TxtAddMoney"].text.text = reward_gold
	self.node_list["TxtDesc"].text.text = string.format(Language.ZhiZhunHaoLi.NeedTopUp, config.need_gold)
	local reward_item_list = ItemData.Instance:GetGiftItemList(config.reward_item.item_id) or {}
	
	for i = 1, 3 do
		local cell = self.reward_list[i]
		local data = reward_item_list[i]
		if data then
			cell:SetActive(true)
			cell:SetData(data)
		else
			cell:SetActive(false)
		end
	end

	-- 按钮显示
	if self.data.has_can_get_reward == 0 then
		UI:SetButtonEnabled(self.node_list["Button"],true)
	else
		UI:SetButtonEnabled(self.node_list["Button"],false)
	end
	local btn_text = (self.data.is_can_get_reward == 1) and Language.Common.LingQu or Language.ZhiZhunHaoLi.TopuUp
	if self.data.has_can_get_reward == 1 then
		btn_text = Language.Common.YiLingQu
	end
	self.node_list["TxtButton"].text.text = btn_text
	self.node_list["ImgRedPoint"]:SetActive(self.data.is_can_get_reward == 1 and self.data.has_can_get_reward == 0)

	local ok_callback = function()
		self.node_list["ImgIcon"].image:SetNativeSize()
	end

	local icon_name = ""
	if config.seq <= 1 then
		icon_name = "icon_01"
	elseif config.seq <= 3 then
		icon_name = "icon_02"
	else
		icon_name = "icon_03"
	end
	
	local asset, bundle = "uis/views/randomact/singlerecharge/images_atlas", icon_name
	self.node_list["ImgIcon"].image:LoadSprite(asset, bundle, ok_callback)
end

function SingleRechargeCell:ClickRechange()
	if self.data.is_can_get_reward == 1 then
		local config = self.data.config
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, 
														RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, config.seq)
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
end