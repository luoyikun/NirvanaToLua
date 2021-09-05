require("game/marriage/baobao/baobao_data")
require("game/marriage/baobao/marry_baobao_view")
require("game/marriage/baobao/baobao_longfeng_tips_view")
require("game/marriage/baobao/reminder_get_baobao_view")
--------------------------------------------------------------
--宝宝
--------------------------------------------------------------
BaobaoCtrl = BaobaoCtrl or BaseClass(BaseController)

function BaobaoCtrl:__init()
	if BaobaoCtrl.Instance then
		print_error("[BaobaoCtrl] Attemp to create a singleton twice !")
	end
	BaobaoCtrl.Instance = self
	self.data = BaobaoData.New()
	self.view = MarryBaoBaoView.New(ViewName.MarryBaby)
	self.baobao_longfeng_tips_view = BaoBaoLongFengTipsView.New(ViewName.BaoBaoLongFengTipsView)
	self.reminder_get_baobao_view = ReminderGetBaobaoView.New(ViewName.ReminderGetBaobaoView)
	self:RegisterAllProtocols()
end

function BaobaoCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.reminder_get_baobao_view then
		self.reminder_get_baobao_view:DeleteMe()
		self.reminder_get_baobao_view = nil
	end

	BaobaoCtrl.Instance = nil
end

function BaobaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBabyInfo, "OnBabyInfo")
	self:RegisterProtocol(SCBabyAllInfo, "OnBabyAllInfo")
	self:RegisterProtocol(SCRequestCreateBaby, "OnBabyBornRoute")
	self:RegisterProtocol(SCBabySpiritInfo, "OnBabySpiritInfo")
end

-- 请求单个宝宝信息  参数1 宝宝ID
function BaobaoCtrl.SendOneBabyInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_INFO, param_1, param_2, param_3)
end

-- 请求所有宝宝信息
function BaobaoCtrl.SendAllBabyInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_ALL_INFO, param_1, param_2, param_3)
end

-- 升级请求	参数1 宝宝ID
function BaobaoCtrl.SendUpBabyReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_UPLEVEL, param_1, param_2, param_3)
end

-- 祈福请求 参数1 祈福类型
function BaobaoCtrl.SendBabyBlessReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_QIFU, param_1, param_2, param_3)
end

-- 祈福答应请求 参数1 祈福类型，参数2 是否接受
function BaobaoCtrl.SendBabyBlessReply(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_QIFU_RET, param_1, param_2, param_3)
end

-- 宝宝超生
function BaobaoCtrl.SendBabyChaoshengReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_CHAOSHENG, param_1, param_2, param_3)
end

-- 请求单个宝宝的守护精灵的信息，发baby_index
function BaobaoCtrl.SendOneBabySpiritInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SPIRIT_INFO, param_1, param_2, param_3)
end

-- 培育精灵请求，发baby_index(param1)，spirit_id（param2, 从0开始，0-3）
function BaobaoCtrl.SendBabyTrainSpiritReq(param_1, param_2, param_3, param_0)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_TRAIN_SPIRIT, param_1, param_2, param_3, param_0)
end

-- 遗弃宝宝请求
function BaobaoCtrl.SendRemoveBabyReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_REMOVE_BABY, param_1, param_2, param_3)
end

-- 是否遗弃宝宝请求
function BaobaoCtrl:SendIsRemoveBabyReq(param_1, param_2, param_4_1, param_4_2)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_REMOVE_BABY_RET, param_1, param_2, nil, nil, {param_4_1, param_4_2})
end

-- 协议请求
function BaobaoCtrl.SendBabyOperaReq(opera_type, param_1, param_2, param_3, param_0, param_4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyOperaReq)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol.param_4_1 = param_4 and param_4[1] or 0
	protocol.param_4_2 = param_4 and param_4[2] or 0
	protocol.param_0 = param_0 or 0                      -- 新加字段发包数
	protocol:EncodeAndSend()
end

-- 请求改名
function BaobaoCtrl:SendBabyRenameReq(baby_index, newname)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyRenameReq)
	protocol.baby_index = baby_index or 0
	protocol.newname = newname or ""
	protocol:EncodeAndSend()
end

function BaobaoCtrl:OpenRenameView()
	self.rename_view:Open()
end

function BaobaoCtrl:OpenTotalTipView(data)
	self.total_tip_view:SetData(data)
end

function BaobaoCtrl:OnBabyInfo(protocol)
	self.data:SetBabyInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:OnBabyAllInfo(protocol)
	self.data:SetBabyAllInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:OnBabySpiritInfo(protocol)
	self.data:SetBabySpiritInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:SendBabyBlessRet(bless_type, is_ok)
	BaobaoCtrl.SendBabyBlessReply(bless_type, is_ok)
	-- ViewManager.Instance:Open(ViewName.MarryBaby, TabIndex.marriage_baobao_att)
end

function BaobaoCtrl:OnBabyBornRoute(protocol)
	if protocol.type == BABY_INFO_TYPE.BABY_INFO_TYPE_REQUESET_CREATE_BABY then
		self:ShowReminderGetBaobaoView(protocol.param_1)
	elseif protocol.type == BABY_INFO_TYPE.BABY_INFO_TYPE_REMOVE_BABY_REQ then
		local ok_callback = function()
			self:SendIsRemoveBabyReq(protocol.param_1, 1, protocol.param_2_1, protocol.param_2_2)
		end
		local cancel_callback = function()
			self:SendIsRemoveBabyReq(protocol.param_1, 0, protocol.param_2_1, protocol.param_2_2)
		end

		local baby_info = self.data:GetBabyInfo(protocol.param_1 + 1)
		if baby_info then
			local attr = BaobaoData.Instance:GetBabyInfoCfg(baby_info.baby_id)
			local baby_id = attr.id or 0
			TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.Marriage.BabyRemoveReq, ToColorStr(baby_info.baby_name or "", BAOBAO_COLOR[baby_id + 1 or 0])),
				ok_callback, cancel_callback)
		end
	end
end

-- 宝宝进阶结果返回
function BaobaoCtrl:OnBabyUpgradeResult(result,index)
	ViewManager.Instance:FlushView(ViewName.MarryBaby)
end

-- 宝宝升阶请求
function BaobaoCtrl:SendBabyUpgradeReq(baby_index, auto_buy, is_one_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyUpgradeReq)
	protocol.auto_buy = auto_buy
	protocol.is_auto_upgrade = is_one_key
	if 1 == protocol.auto_buy and is_one_key then
		local baby_list = self.data:GetListBabyData()
		if nil == baby_list or nil == baby_index or nil == next(baby_list) then return end

		local grade = 1
		for k,v in pairs(baby_list) do
			if v.baby_index == baby_index then
				grade = v.grade
			end
		end
		protocol.baby_index = baby_index or 0
		protocol.repeat_times = self.data:GetBabyUpgradeCfg(grade) and self.data:GetBabyUpgradeCfg(grade).pack_num or 1
	else
		protocol.baby_index = baby_index or 0
		protocol.repeat_times = 1
	end
	protocol:EncodeAndSend()
end

function BaobaoCtrl:OnOperateResult(result,index)
	-- if self.view then
	-- 	if self.view.guard_view then
	-- 		self.view.guard_view:OnOperateResult()
	-- 	end
	-- end
end

function BaobaoCtrl:FlushImageViewRed()
	self.view:FlushImageView()
end

function BaobaoCtrl:ResetValue()
	self.view:ResetValue()
end

function BaobaoCtrl:FlushLongFenBaoBao()
	if self.view:IsOpen() then
			self.view:Flush()
	end
	self.baobao_longfeng_tips_view:Flush()
end

function BaobaoCtrl:ShowReminderGetBaobaoView(param1)
	if self.reminder_get_baobao_view then
		self.reminder_get_baobao_view:SetData(param1)
		ViewManager.Instance:Open(ViewName.ReminderGetBaobaoView)
	end
end
