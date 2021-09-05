require("game/molong_mibao/molong_mibao_data")
require("game/molong_mibao/molong_mibao_view")
require("game/molong_mibao/molong_mibao_tips")

MolongMibaoCtrl = MolongMibaoCtrl or  BaseClass(BaseController)

function MolongMibaoCtrl:__init()
	if MolongMibaoCtrl.Instance ~= nil then
		print_error("[MolongMibaoCtrl] attempt to create singleton twice!")
		return
	end
	MolongMibaoCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = MolongMibaoData.New()
	self.view = MolongMibaoView.New(ViewName.MolongMibaoView)
	self.tip_view = TipsMoLongMiBaoView.New(ViewName.MolongMibaoTips)
end

function MolongMibaoCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.tip_view ~= nil then
		self.tip_view:DeleteMe()
		self.tip_view = nil
	end

	MolongMibaoCtrl.Instance = nil
end

function MolongMibaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendMagicalPreciousAllInfo, "OnSCSendMagicalPreciousAllInfo")
	self:RegisterProtocol(SCSendMagicalPreciousCurChapterInfo, "OnSendMagicalPreciousCurChapterInfo")
	self:RegisterProtocol(SCMagicalPreciousConditionParamChange, "OnMagicalPreciousConditionParamChange")
end

function MolongMibaoCtrl:OnSCSendMagicalPreciousAllInfo(protocol)
	self.data:SetMibaoInfo(protocol)
	self.view:Flush()

	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, MainUIData.RemindingName.MolongMibao, self.data:IsShowMolongMibao())
	ViewManager.Instance:FlushView(ViewName.Main, "molongmibao")
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	RemindManager.Instance:Fire(RemindName.MoLongMiBao2)
end

function MolongMibaoCtrl:OnSendMagicalPreciousCurChapterInfo(protocol)
	self.data:SetMibaoCurChapterInfo(protocol)
	self.view:Flush()
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, MainUIData.RemindingName.MolongMibao, self.data:IsShowMolongMibao())
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	RemindManager.Instance:Fire(RemindName.MoLongMiBao2)
end


function MolongMibaoCtrl:OnMagicalPreciousConditionParamChange(protocol)
	self.data:SetConditionParamChange(protocol)
	self.view:Flush()
	-- local flag = OpenFunData.Instance:CheckIsHide("molongmibaoview")
	-- if flag then
	-- 	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, MainUIData.RemindingName.MolongMibao, self.data:IsShowMolongMibao())
	-- end
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	RemindManager.Instance:Fire(RemindName.MoLongMiBao2)
end

-- 请求章奖励
function MolongMibaoCtrl.SendMagicalPreciousChapterRewardReq(chapter_id, level)
	MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(MolongMibaoData.OPERATE_TYPE.CONVERT_CHAPTER_REWARD, chapter_id, level)
end

-- 请求奖励
function MolongMibaoCtrl.SendMagicalPreciousRewardReq(reward_index, chapter_id)
	MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(MolongMibaoData.OPERATE_TYPE.FETCH_REWARD, reward_index, chapter_id)
end

-- 请求信息
function MolongMibaoCtrl.SendMagicalPreciousInfoReq()
	MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(MolongMibaoData.OPERATE_TYPE.FETCH_ALL_INFO)
end

function MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(operater_type, reward_index, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchMagicalPreciousRewardReq)
	send_protocol.operater_type = operater_type
	send_protocol.reward_index = reward_index or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()
end

function MolongMibaoCtrl:Setid(id)
	self.tip_view:SetChapterId(id)
	if ViewManager.Instance:IsOpen(ViewName.MolongMibaoTips) then
		self.tip_view:Flush()
	end
end