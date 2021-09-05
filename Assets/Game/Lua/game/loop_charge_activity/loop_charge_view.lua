LoopChargeView = LoopChargeView or BaseClass(BaseView)

local VIEW_STATE = {
	NORMAL = 1,
	CAN_GET_REWARD_FLAG = 2
}
function LoopChargeView:__init()
	self.ui_config = {
		{"uis/views/loopview_prefab", "LoopChargeView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function LoopChargeView:__delete()

end

function LoopChargeView:LoadCallBack()
	self.view_state = VIEW_STATE.NORMAL
	self.item_list = {}
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))
end

function LoopChargeView:ReleaseCallBack()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function LoopChargeView:OpenCallBack()
	LoopChargeCtrl.Instance.red_flag = false
	LoopChargeCtrl.Instance:FlushInfo()
end

function LoopChargeView:CloseCallBack()

end

function LoopChargeView:OnFlush()
	LoopChargeData.Instance:ShowData()
	self:ConstructData()
	self:ShowReward()
	self:ShowCharge()
	self:SetFlag()
end

function LoopChargeView:ConstructData()
	self.item_num = LoopChargeData.Instance:GetItemNum() or 0
	self.reward_list = LoopChargeData.Instance:GetRewardList()
	self.charge_value = LoopChargeData.Instance:GetCharge()
	self.total_charge_value = LoopChargeData.Instance:GetTotalCharge()
	self.need_charge_value = LoopChargeData.Instance:GetNeedCharge()
	self.can_get_reward_flag = LoopChargeData.Instance:CanGetRewardFlag()
	if self.can_get_reward_flag then
		self.view_state = VIEW_STATE.CAN_GET_REWARD_FLAG
	else
		self.view_state = VIEW_STATE.NORMAL
	end
	
end

-------------------展示部分----------------------
function LoopChargeView:ShowReward()
	if CheckInvalid(self.reward_list) then
		return
	end
	for i = 1, self.item_num do
		if self.item_list[i] then
			self.item_list[i]:SetData(self.reward_list[i - 1])
		else
			self.item_list[i] = ItemCell.New()
			self.item_list[i]:SetInstanceParent(self.node_list["item_root"])
			self.item_list[i]:SetData(self.reward_list[i - 1])
		end
	end
	for k, v in pairs(self.item_list) do
		if next(v:GetData()) == nil then
			v:SetActive(false)
		else
			v:SetActive(true)
		end
	end
end

function LoopChargeView:ShowCharge()
	if CheckInvalid(self.charge_value) and CheckInvalid(self.need_charge_value) then
		return
	end
	local str = self.charge_value .. "/" .. self.need_charge_value
	if self.charge_value  > self.need_charge_value then
		self.node_list["TxtLeijiCharge"].text.text = string.format(Language.LoopCharge.LeijiCharge, str)
	else
		self.node_list["TxtLeijiCharge"].text.text = string.format(Language.LoopCharge.LeijiCharge1, str)
	end
	if math.floor(self.charge_value / self.need_charge_value) > 0 then
		self.node_list["TxtGiftNum"].text.text = string.format(Language.LoopCharge.GiftNum, math.floor(self.charge_value / self.need_charge_value))
	else
		self.node_list["TxtGiftNum"].text.text = string.format(Language.LoopCharge.GiftNum1, math.floor(self.charge_value / self.need_charge_value))
	end
	
	self.node_list["TxtChargeNum"].text.text = self.need_charge_value
	self.node_list["Slider"].slider.value = self.charge_value / self.need_charge_value
end

function LoopChargeView:SetFlag()
	self.node_list["BtnReward"]:SetActive(self.view_state == 2)
	self.node_list["BtnRecharge"]:SetActive(self.view_state == 1)
end

-------------------点击事件----------------------
function LoopChargeView:ClickGetReward()
	if self.view_state == VIEW_STATE.NORMAL then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
	if self.view_state == VIEW_STATE.CAN_GET_REWARD_FLAG then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2,
			CIRCULATION_CHONGZHI_OPERA_TYPE.CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD)
	end
end