SupremeMembersView =  SupremeMembersView or BaseClass(BaseRender)
--至尊会员
function SupremeMembersView:__init()
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OpenRecharge, self))
	self:Flush()
	RemindManager.Instance:SetRemindToday(RemindName.SupremeMembers)
	RemindManager.Instance:Fire(RemindName.SupremeMembers)
end

function SupremeMembersView:__delete()

end



function SupremeMembersView:OnFlush()
	local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
	local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()

	if not has_buy_7day_rechange then
		self.node_list["TxtBtn"].text.text = Language.Recharge.DayRechargeTxt[5]
	elseif has_buy_7day_rechange and is_fetch == 0 then 
		self.node_list["TxtBtn"].text.text = Language.Recharge.DayRechargeTxt[2]
		self.node_list["NodeEffect"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["BtnRecharge"], true)
	elseif has_buy_7day_rechange and is_fetch == 1 then
		self.node_list["TxtBtn"].text.text = Language.Recharge.DayRechargeTxt[4]
		self.node_list["NodeEffect"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnRecharge"], false)
	end
end

function SupremeMembersView:OpenRecharge()
	local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
	local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()

	if has_buy_7day_rechange then
		RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end

	self:Flush()
end