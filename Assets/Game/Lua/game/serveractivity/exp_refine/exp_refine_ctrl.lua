require("game/serveractivity/exp_refine/exp_refine_data")
require("game/serveractivity/exp_refine/exp_refine_view")

ExpRefineCtrl = ExpRefineCtrl or BaseClass(BaseController)

function ExpRefineCtrl:__init()
	if ExpRefineCtrl.Instance then
		print_error("[ExpRefineCtrl]:Attempt to create singleton twice!")
	end
	ExpRefineCtrl.Instance = self

	self.view = ExpRefineView.New(ViewName.ExpRefine)
	self.data = ExpRefineData.New()

	self:RegisterAllProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

	self.activity_change = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)
end

function ExpRefineCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end

	ExpRefineCtrl.Instance = nil
end

function ExpRefineCtrl:ActivityChangeCallback(activity_type, status, next_time, open_type)
	if activity_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE then
		return
	end
	
	if status == ACTIVITY_STATUS.OPEN and ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) and self.data:GetIsRefineTimes() then
		self.is_open = true
		self.data:SetIsShowEff(true)
		self.data:SetIsShowBubble(true)
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, true)
	elseif status == ACTIVITY_STATUS.CLOSE then
		self.is_open = false
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, false)
	end

	RemindManager.Instance:Fire(RemindName.ExpRefineBubble)
	RemindManager.Instance:Fire(RemindName.ExpRefine)
end

function ExpRefineCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAExpRefineInfo, "OnRAExpRefineInfo")

	self:RegisterProtocol(CSRAExpRefineReq)
end

function ExpRefineCtrl:MainuiOpenCreate()
	self:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_GET_INFO)
	self.data:SetCountDown2()
end

--经验炼制请求
function ExpRefineCtrl:SendRAExpRefineReq(opera_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRAExpRefineReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol:EncodeAndSend()
end

function ExpRefineCtrl:OnRAExpRefineInfo(protocol)
	self.data:SetRAExpRefineInfo(protocol)
	local max_buy_num = ExpRefineData.Instance:GetRAExpRefineCfgMaxNum()
	self.view:Flush()
	
	local is_active = self.data:GetExpRefineIsOpen() and not (protocol.refine_today_buy_time >= max_buy_num)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, is_active)
	RemindManager.Instance:Fire(RemindName.ExpRefine)
	-- MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, not (protocol.refine_today_buy_time == max_buy_num))
	if not self.data:GetIsRefineTimes() then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, false)
	end
end

function ExpRefineCtrl:FlushMainViewBubble()
	local is_show = self.data:GetIsShowBubble()
	if self.is_open and self.data:GetIsRefineTimes() then
		local num = self.data:GetExpRefineBuyTimes()
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, self.is_open, num)
	end
end
-- -- 经验炼制
-- RA_EXP_REFINE_OPERA_TYPE = {
-- 	RA_EXP_REFINE_OPERA_TYPE_BUY_EXP = 0,					-- 炼制
-- 	RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD = 1,			-- 领取炼制红包
-- 	RA_EXP_REFINE_OPERA_TYPE_GET_INFO = 2,					-- 获取信息
-- }
