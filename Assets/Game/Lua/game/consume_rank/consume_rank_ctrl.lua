require("game/consume_rank/consume_rank_view")
require("game/consume_rank/consume_rank_data")

ConsumeRankCtrl = ConsumeRankCtrl or BaseClass(BaseController)
function ConsumeRankCtrl:__init()
	if ConsumeRankCtrl.Instance then
		print_error("[ConsumeRankCtrl] Attemp to create a singleton twice !")
	end
	ConsumeRankCtrl.Instance = self

	self.consume_rank_data = ConsumeRankData.New()
	self.consume_rank_view = ConsumeRankView.New(ViewName.ConsumeRank)

	self:RegisterAllProtocols()
	-- self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function ConsumeRankCtrl:__delete()
	ConsumeRankCtrl.Instance = nil

	if self.consume_rank_view then
		self.consume_rank_view:DeleteMe()
		self.consume_rank_view = nil
	end
	if self.consume_rank_data then
		self.consume_rank_data:DeleteMe()
		self.consume_rank_data = nil
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
end

function ConsumeRankCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCRAChongzhiRankInfo, "OnRAChongzhiRankInfo")
	self:RegisterProtocol(SCRAConsumeGoldRankInfo, "OnRAConsumeGoldRankInfo")				--每日消费排行
end

function ConsumeRankCtrl:OnRAConsumeGoldRankInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ConsumeRankRemind)
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD)
	self.consume_rank_data:SetRandActConsume(protocol.consume_gold_num)
	self.consume_rank_view:Flush()
end

function ConsumeRankCtrl:MianUIOpenComlete()
	-- local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_CHONGZHI_RANK)
	-- if is_open then
	-- 	-- 请求活动信息
	--  	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_CHONGZHI_RANK)
	-- end
end

function ConsumeRankCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.ConsumeRankRemind then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_CONSUME_GOLD_RANK, num > 0)
	end
end