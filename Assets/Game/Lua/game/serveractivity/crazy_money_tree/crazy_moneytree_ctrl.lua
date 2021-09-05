require("game/serveractivity/crazy_money_tree/crazy_moneytree_view")
require("game/serveractivity/crazy_money_tree/crazy_moneytree_data")

CrazyMoneyTreeCtrl = CrazyMoneyTreeCtrl or BaseClass(BaseController)

function CrazyMoneyTreeCtrl:__init()
	if CrazyMoneyTreeCtrl.Instance ~= nil then
		print("[CrazyMoneyTreeCtrl]error:create a singleton twice")
	end

	CrazyMoneyTreeCtrl.Instance = self
	self.view = CrazyMoneyTreeView.New(ViewName.CrazyMoneyTreeView)
	self.data = CrazyMoneyTreeData.New()
	self:RegisterAllProtocols()  --注册协议

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.ListenActivityChange, self))
end

function CrazyMoneyTreeCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.nomoney_view then
		self.nomoney_view:DeleteMe()
		self.nomoney_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	CrazyMoneyTreeCtrl.Instance = nil

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	
end

function CrazyMoneyTreeCtrl:RegisterAllProtocols()
	-- 注册接收到的协议
	self:RegisterProtocol(SCRAShakeMoneyInfo, "OnRAShakeMoneyInfo")
end
function CrazyMoneyTreeCtrl:SendAllInfoReq() 
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY) then
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO)
end

function CrazyMoneyTreeCtrl:OnRAShakeMoneyInfo(protocol)
	self.data:SetRAShakeMoneyInfo(protocol)
	RemindManager.Instance:Fire(RemindName.CrazyTree)
	self:CanGetMoneyNum()
	self.view:Flush()
	MainUICtrl.Instance:FlushActivity()
end

function CrazyMoneyTreeCtrl:Open()
	self.view:Open()
end

function CrazyMoneyTreeCtrl:Flush(param)
	
end

function CrazyMoneyTreeCtrl:CheckRemind()
	return self.data:GetCanCrazy()
end


function CrazyMoneyTreeCtrl:CanGetMoneyNum()
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum()
	local gold = CrazyMoneyTreeData.Instance:GetMoney()
	local can_get = 0
	if math.floor(chongzhi * has_return_recive / 100) <= max_chongzhi_num then
		can_get = math.floor(chongzhi * has_return_recive / 100) - gold
	else
		can_get = max_chongzhi_num - gold
	end
	local level = PlayerData.Instance.role_vo.level
	local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY)
	if act_cfg ~= nil and level >= act_cfg.min_level then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, max_chongzhi_num > gold)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, false)
	end
end

function CrazyMoneyTreeCtrl:ListenActivityChange()
	self:SendAllInfoReq()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, is_open)
end

function CrazyMoneyTreeCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY then
		if status == ACTIVITY_STATUS.OPEN then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, true)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO)
		elseif status == ACTIVITY_STATUS.CLOSE then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.CRAZY_TREE, false)
		end 
	end
end