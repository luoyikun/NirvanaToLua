CrazyMoneyTreeView = CrazyMoneyTreeView or BaseClass(BaseView)
function CrazyMoneyTreeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/serveractivity/crazymoneytree_prefab", "CrazyMoneyTree"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function CrazyMoneyTreeView:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CrazyMoneyTreeView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CrazyMoneyTreeView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function CrazyMoneyTreeView:LoadCallBack()
	CrazyMoneyTreeData.Instance:SetIsFirstEnter(false)
	self.node_list["Name"].text.text = Language.CrazyMoneyTree.TitleTxt
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OnClickShake, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.can_get = 0
end

function CrazyMoneyTreeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY, RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end

--显示界面回调
function CrazyMoneyTreeView:ShowIndexCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CrazyMoneyTreeView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.node_list["TxtTime"] ~= nil then
		if time > 0 then
			self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond2HMS(time)
		else
			self.node_list["TxtTime"].text.text = "00:00:00"
		end
	end
end

--点击摇一摇按钮回调
function CrazyMoneyTreeView:OnClickShake()
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
	if chongzhi == 0 or math.floor(chongzhi * has_return_recive / 100) == gold then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif gold >= max_chongzhi_num then
		SysMsgCtrl.Instance:ErrorRemind(Language.CrazyMoneyTree.TipsBroughtOut)
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_FETCH_GOLD)
	end
end

function CrazyMoneyTreeView:FlushButtonText()
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
	if chongzhi == 0 then
		self.node_list["TxtBtn"].text.text = Language.Recharge.GoReCharge
	elseif gold == max_chongzhi_num then
		self.node_list["TxtBtn"].text.text = Language.Common.IsAllGet
		UI:SetButtonEnabled(self.node_list["BtnRecharge"], false)
	elseif math.floor(chongzhi * has_return_recive / 100) == gold then
		self.node_list["TxtBtn"].text.text = Language.Recharge.GoReCharge
	else
		self.node_list["TxtBtn"].text.text = Language.CrazyMoneyTree.GetGold
	end
end

--刷新
function CrazyMoneyTreeView:OnFlush(param_t, index)
	local show_point = CrazyMoneyTreeData.Instance:GetCanCrazy()
	self.node_list["ImgRedPoint"]:SetActive(show_point)
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	self.node_list["TxtHasRecharge"].text.text = chongzhi
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum()
	local surplus = max_chongzhi_num - gold
	if surplus >= 0 then
		self.node_list["TxtResReturn"].text.text = string.format(Language.CrazyMoneyTree.SurplusGold ,surplus)
	else
		self.node_list["TxtResReturn"].text.text = string.format(Language.CrazyMoneyTree.SurplusGold ,0)
	end
	local return_echarge = CrazyMoneyTreeData.Instance:GetReturnChongzhi()
	self.node_list["TxtReturn"].text.text = return_echarge .. "%"
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	
	if math.floor(chongzhi * has_return_recive / 100) <= max_chongzhi_num then
		self.can_get = math.floor(chongzhi * has_return_recive / 100) - gold
		self.node_list["TxtCanGet"].text.text = self.can_get
	else
		self.can_get = max_chongzhi_num - gold
		self.node_list["TxtCanGet"].text.text = self.can_get
	end
	-- MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, self.can_get > 0)

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	self:FlushButtonText()
end

function CrazyMoneyTreeView:OnClickClose()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, false)
	self:Close()
end

function CrazyMoneyTreeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtTime"].text.text = time_str
end





