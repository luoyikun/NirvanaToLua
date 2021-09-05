require("game/zhizun_recharge_rank/zhizun_recharge_rank_view")
require("game/zhizun_recharge_rank/zhizun_recharge_rank_data")

ZhiZunRechargeRankCtrl = ZhiZunRechargeRankCtrl or BaseClass(BaseController)
function ZhiZunRechargeRankCtrl:__init()
	if ZhiZunRechargeRankCtrl.Instance then
		print_error("[ZhiZunRechargeRankCtrl] Attemp to create a singleton twice !")
	end
	ZhiZunRechargeRankCtrl.Instance = self

	self.recharge_rank_data = ZhiZunRechargeRankData.New()
	self.recharge_rank_view = ZhiZunRechargeRankView.New(ViewName.ZhiZunRechargeRankView)

	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function ZhiZunRechargeRankCtrl:__delete()
	ZhiZunRechargeRankCtrl.Instance = nil

	if self.recharge_rank_view then
		self.recharge_rank_view:DeleteMe()
		self.recharge_rank_view = nil
	end
	if self.recharge_rank_data then
		self.recharge_rank_data:DeleteMe()
		self.recharge_rank_data = nil
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
end

function ZhiZunRechargeRankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAChongzhiRank2Info, "OnRAChongzhiRankInfo")
end

function ZhiZunRechargeRankCtrl:OnRAChongzhiRankInfo(protocol)
	-- RemindManager.Instance:Fire(RemindName.RechargeRankRemind)
	self.recharge_rank_data:SetRandActRecharge(protocol.chongzhi_num)
	self.recharge_rank_view:Flush()
end

function ZhiZunRechargeRankCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ZHIZUN_CHONGZHI_RANK)
	if is_open then
		-- 请求活动信息
	 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ZHIZUN_CHONGZHI_RANK)
	end
end

function ZhiZunRechargeRankCtrl:RemindChangeCallBack(remind_name, num)
	-- if remind_name == RemindName.RechargeRankRemind then
	-- 	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ZHIZUN_CHONGZHI_RANK, num > 0)
	-- end
end