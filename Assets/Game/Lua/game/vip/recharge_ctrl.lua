require("game/vip/recharge_data")
RechargeCtrl = RechargeCtrl or BaseClass(BaseController)
function RechargeCtrl:__init()
	if RechargeCtrl.Instance then
		print_error("[RechargeCtrl] Attemp to create a singleton twice !")
	end
	RechargeCtrl.Instance = self
	self.data = RechargeData.New()
	self:RegisterProtocol(SCChongZhiInfo, "OnSCChongZhiInfo")
	self.chongzhi_protocol = {}
	self.chongzhi_protocol.today_recharge = 0
end

function RechargeCtrl:__delete()
	RechargeCtrl.Instance = nil
	self.data:DeleteMe()
	self.chongzhi_protocol = nil
end

function RechargeCtrl:GetData()
	return self.data
end

--充值信息返回
function RechargeCtrl:OnSCChongZhiInfo(protocol)
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	local level_open = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_DAILY_LOVE)

	if is_act_open and level_open and protocol.today_recharge then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, protocol.today_recharge <= 0)
	end

	self.chongzhi_protocol = protocol
	DailyChargeData.Instance:OnSCChongZhiInfo(protocol)
	self.data:SetChongZhi7DayFetchReward(protocol)
	local first_charge_view = FirstChargeContentView.Instance
	local daily_charge_view = DailyChargeContentView.Instance
	if daily_charge_view ~= nil then
		daily_charge_view:FlushBtnState()
	end

	RemindManager.Instance:Fire(RemindName.Recharge)
	RemindManager.Instance:Fire(RemindName.SupremeMembers)
	RemindManager.Instance:Fire(RemindName.MonthInvest)
	
	ViewManager.Instance:FlushView(ViewName.VipView)
	ViewManager.Instance:FlushView(ViewName.Main, "jubaopen")
	ViewManager.Instance:FlushView(ViewName.Main, "reminder_charge")
	ViewManager.Instance:FlushView(ViewName.Main, "recharge")
	FirstChargeCtrl.Instance:FlusView()
	DailyChargeCtrl.Instance:FlusView()
	LeiJiRDailyCtrl.Instance:FlusView()
	KaifuActivityCtrl.Instance:FlushView()
	LeiJiRDailyCtrl.Instance:SetLeijiViewNextCurrentIndex()

	if not self.is_first_open_charge then
		FirstChargeCtrl.Instance:OpenView()
		self.is_first_open_charge = true
	end
end

--领取充值奖励
function RechargeCtrl:SendChongzhiFetchReward(type, param, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChongzhiFetchReward)
	protocol.type = type
	protocol.param = param --seq
	protocol.param2 = param2 --CHONGZHI_REWARD_TYPE_DAILY时表示选择的奖励索引
	protocol:EncodeAndSend()
end

--充值
function RechargeCtrl:Recharge(money)
	-- 判断不开放充值的时候禁止充值
	local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
	if not open_chongzhi then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChongZhiError)
		return
	end
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind("当前为跨服场景，无法充值")
		return
	end
	if money and money ~= 0 then
		if AgentAdapter and AgentAdapter.Instance then
			AgentAdapter.Instance:Pay(Language.Common.Gold, money)
			ReportManager:ReportPay(money)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind("充值操作失败！")
	end
end

--领取7天返利
function RechargeCtrl:SendChongZhi7DayFetchReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChongZhi7DayFetchReward)
	protocol:EncodeAndSend()
end

