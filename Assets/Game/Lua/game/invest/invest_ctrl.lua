require("game/invest/invest_data")
InvestCtrl = InvestCtrl or BaseClass(BaseController)
function InvestCtrl:__init()
	if InvestCtrl.Instance then
		print_error("[InvestCtrl] Attemp to create a singleton twice !")
	end
	InvestCtrl.Instance = self
	self.show_sign = 0
	self.data = InvestData.New()

	self:RegisterProtocol(SCTouZiJiHuaInfo, "OnSCTouZiJiHuaInfo")

	self:RegisterProtocol(SCTouzijihuaFbBossInfo, "OnSCTouzijihuaFbBossInfo")
	self.first_online = true

	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)	
end

function InvestCtrl:__delete()
	self.data:DeleteMe()
	InvestCtrl.Instance = nil
	self.show_sign = 0
	if self.role_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
		self.role_change_callback = nil
	end	
end

function InvestCtrl:OnSCTouZiJiHuaInfo(protocol)
	self.data:OnSCTouZiJiHuaInfo(protocol)

	self:MainChatViewIsShow()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.INVESTMENT, true)

	KaifuActivityCtrl.Instance:FlushTouZiPlan()
	KaifuActivityCtrl.Instance:FlushLevelInvestmentView()
	RemindManager.Instance:Fire(RemindName.Invest)
	ViewManager.Instance:FlushView(ViewName.VipView)

end

function InvestCtrl:OnSCTouzijihuaFbBossInfo(protocol)
	self.data:OnSCTouzijihuaFbBossInfo(protocol)

	KaifuActivityCtrl.Instance:FlushFuBenTouZi()
	KaifuActivityCtrl.Instance:FlushBossTouZi()
	KaifuActivityCtrl.Instance:FlushShenYuBossTouZi()
	GaoZhanCtrl.Instance:FlushView("weapon")
	ViewManager.Instance:FlushView(ViewName.Boss, "miku_boss")
	ViewManager.Instance:FlushView(ViewName.ShenYuBossView, "kf_boss")
	RemindManager.Instance:Fire(RemindName.TouziActivity)
	RemindManager.Instance:Fire(RemindName.Boss_MiKu)
	RemindManager.Instance:Fire(RemindName.Boss_Kf)
	RemindManager.Instance:Fire(RemindName.FuBen_Weapon)
end

function InvestCtrl:RoleChangeCallBack(key, value, old_value)
	if key == "level" then
		local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
		for k, v in pairs(level_cfg) do
			if old_value < v.active_level_min and value >= v.active_level_min then	
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, true)
			end
		end
	end
end

function InvestCtrl:MainChatViewIsShow()
	local role_level = PlayerData.Instance:GetRoleVo().level
	local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
	local state = KaifuActivityData.Instance:CanShowTouZiPlan()
	local button_state = KaifuActivityData.Instance:TouZiButtonInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local cur_seq = InvestData.Instance:GetCurSeq(role_level)
	-- local is_act_open = ActivityData.Instance:GetActivityIsOpen(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT)
	local level_open = ActivityData.Instance:GetIsOpenLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT)
	local show_sign = InvestData.Instance:GetShowTouZiSign()
	for k, v in pairs(level_cfg) do
		-- 每天上线，活动开 ，可购买 ==>显示小图标
		if self.first_online == true and level_open and KaifuActivityData.Instance:GetTouZiState(v.seq + 1) == 0 then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, true)
			self.first_online = false
		end

		-- 上线之后，活动开，升级刚达到可购买等级，可购买，==>显示小图标
		if self.first_online == false and level_open and InvestData.Instance:IsCurReachLevel(role_level) and KaifuActivityData.Instance:GetTouZiState(v.seq + 1) == 0 then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, true)
		end

		if v.seq == cfg_num - 1 and v.sub_index == 2 then
			if role_level > v.active_level_max then
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, false)
			end
		end

		if state then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, false)
		end
	end
end

--新投资计划操作
function InvestCtrl:SendChongzhiFetchReward(operate_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNewTouzijihuaOperate)
	protocol.operate_type = operate_type
	protocol.param = param 	--第几天的奖励0~6
	protocol:EncodeAndSend()
end

--投资奖励领取
function InvestCtrl:SendFetchTouZiJiHuaReward(plan_type, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchTouZiJiHuaReward)
	protocol.plan_type = plan_type
	protocol.seq = seq
	protocol:EncodeAndSend()
end

--投资计划投资
function InvestCtrl:SendTouzijihuaActive(plan_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTouzijihuaActive)
	protocol.plan_type = plan_type
	protocol:EncodeAndSend()
end

function InvestCtrl:SendTouzijihuaFbBossOperate(operate_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTouzijihuaFbBossOperate)
	protocol.operate_type = operate_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end

