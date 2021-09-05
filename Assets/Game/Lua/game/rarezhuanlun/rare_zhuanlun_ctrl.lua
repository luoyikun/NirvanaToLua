require("game/rarezhuanlun/rare_zhuanlun_view")
require("game/rarezhuanlun/rare_zhuanlun_data")
require("game/rarezhuanlun/rare_zhuanlun_quick_flush_view")

RareDialCtrl = RareDialCtrl or BaseClass(BaseController)

function RareDialCtrl:__init()
	if RareDialCtrl.Instance ~= nil then
		print_error("[RareDialCtrl] attempt to create singleton twice!")
		return
	end
	RareDialCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = RareDialView.New(ViewName.RareDial)
	self.quick_flush_view = ZhuanLunQucikFlushView.New(ViewName.ZhuanLunQucikFlushView)
	self.data = RareDialData.New()
	self.quick_flush = false
	self.is_requiring = false
end

function RareDialCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.quick_flush_view ~= nil then
		self.quick_flush_view:DeleteMe()
		self.quick_flush_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end

	if nil ~= self.delay_end_flush then
		GlobalTimerQuest:CancelQuest(self.delay_end_flush)
		self.delay_end_flush = nil
	end
	RareDialCtrl.Instance = nil
end

function RareDialCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAExtremeLuckyAllInfo, "SCRAExtremeLuckyAllInfo")
	self:RegisterProtocol(SCRAExtremeLuckySingleInfo, "SCRAExtremeLuckySingleInfo")
end

function RareDialCtrl:SCRAExtremeLuckyAllInfo(protocol)
	self.data:SetRAExtremeLuckyAllInfo(protocol)
	self.view:Flush()

	self.is_requiring = false
	if nil ~= self.delay_end_flush then
		GlobalTimerQuest:CancelQuest(self.delay_end_flush)
		self.delay_end_flush = nil
	end
	self:QuickFlushInfo()
end

function RareDialCtrl:SCRAExtremeLuckySingleInfo(protocol)
	self.data:SetRewardInfo(protocol)
	if self.fetch_award then
		self.view:FlushRightCell()
		self.fetch_award = false
	else
		self.view:FlushAnimation()
	end
end

function RareDialCtrl:SendInfo(opera_type,param_1)
	if opera_type == 1 then
		if self.is_requiring then
			return
		end
		self.is_requiring = true
		self.delay_end_flush = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ResetState, self), 2)
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR, opera_type, param_1)
end

function RareDialCtrl:FlushItem(  )
	if self.view.is_open then
		self.view:FlushItem()
	end
end

function RareDialCtrl:FetchAward()
	self.fetch_award = true
end

-- 开启/关闭自动刷新
function RareDialCtrl:QuickFlush(state)
	self.quick_flush = state
	if not self.quick_flush then
		if nil ~= self.delay_flush_time then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
	else
		GlobalTimerQuest:AddDelayTimer(function ()
			self:SendFlushInfo()
		end, 0.5)
	end
end

-- 自动刷新
function RareDialCtrl:SendFlushInfo()
	self:SendInfo(1)
end

function RareDialCtrl:ShowQuickFlush(state)
	self.view:ShowFlushButton(state)
end

function RareDialCtrl:QuickFlushState()
	return self.quick_flush
end

function RareDialCtrl:ResetState()
	self.quick_flush = false
	self.data:ClearSelectIdTable()
	self:ShowQuickFlush(false)
	self.is_requiring = false

	SysMsgCtrl.Instance:ErrorRemind(Language.RareZhuanLun.QuickFlsuhError)
end

function RareDialCtrl:QuickFlushInfo()
	if self.quick_flush then
		-- 如果没有抽到，state = true
		local state = self.data:IsCanSelectItem()
		if state and self.view.is_open then
			self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.SendFlushInfo, self), 1)
		else
			self.quick_flush = false
			self.data:ClearSelectIdTable()
			self:ShowQuickFlush(false)
		end
	end
end