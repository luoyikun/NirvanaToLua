require("game/douqi_equip/douqi_data")
require("game/douqi_equip/douqi_view")
require("game/douqi_equip/douqi_use_item_view")
require("game/douqi_equip/douqi_equip_recovery_view")
require("game/douqi_equip/douqi_equip_suit_view")

DouQiCtrl = DouQiCtrl or BaseClass(BaseController)

function DouQiCtrl:__init()
	if DouQiCtrl.Instance then
		print_error("[DouQiCtrl]:Attempt to create singleton twice!")
	end
	DouQiCtrl.Instance = self

	self.data = DouQiData.New()
	self.view = DouQiView.New(ViewName.DouQiView)
	self.use_item_view = DouqiUseItemView.New()
	self.equip_recovery_view = DouqiEquipRecoveryView.New(ViewName.DouQiEquipRecovery)
	self.equip_suit_view = DouqiEquipSuitView.New()

	self:RegisterAllProtocols()
end

function DouQiCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.use_item_view then
		self.use_item_view:DeleteMe()
		self.use_item_view = nil
	end

	if self.equip_recovery_view then
		self.equip_recovery_view:DeleteMe()
		self.equip_recovery_view = nil
	end

	if self.equip_suit_view then
		self.equip_suit_view:DeleteMe()
		self.equip_suit_view = nil
	end

	DouQiCtrl.Instance = nil
end

function DouQiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossEquipAllInfo, "OnSCCrossEquipAllInfo")
	self:RegisterProtocol(SCCrossEquipRollResult, "OnSCCrossEquipRollResult")
	self:RegisterProtocol(SCCrossEquipOneEquip, "OnSCCrossEquipOneEquip")
	self:RegisterProtocol(SCCrossEquipAllEquip, "OnSCCrossEquipAllEquip")
	self:RegisterProtocol(SCCrossEquipChuanshiFragmentChange, "OnSCCrossEquipChuanshiFragmentChange")
	self:RegisterProtocol(SCCrossEquipDouqiExpChange, "OnSCCrossEquipDouqiExpChange")
end

function DouQiCtrl:OpenUseItemView()
	self.use_item_view:Open()
end

function DouQiCtrl:OpenEquipRecoveryView(data)
	self.equip_recovery_view:OpenViewWithData(data)
end

function DouQiCtrl:OpenEquipSuitView()
	self.equip_suit_view:Open()
end

function DouQiCtrl:SendCSCrossEquipOpera(req_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEquipOpera)
	protocol.req_type = req_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

-- 信息下发
function DouQiCtrl:OnSCCrossEquipAllInfo(protocol)
	self.data:SetSCCrossEquipAllInfo(protocol)

	self.view:Flush("flush_tabbar")
	self.view:Flush("grade_view")
	self.view:Flush("equip_view")
	self.view:Flush("refine_view")
	self.equip_recovery_view:Flush()

	RemindManager.Instance:Fire(RemindName.DouqiGrade)
	RemindManager.Instance:Fire(RemindName.DouqiRefine)
end

-- 抽奖返回
function DouQiCtrl:OnSCCrossEquipRollResult(protocol)
	self.data:SetSCCrossEquipRollResult(protocol)
end

-- 单个装备信息 -- 穿脱
function DouQiCtrl:OnSCCrossEquipOneEquip(protocol)
	self.data:SetSCCrossEquipOneEquip(protocol)
	self.view:Flush("equip_view")
	RemindManager.Instance:Fire(RemindName.DouqiEquip)
end

-- 所有装备信息
function DouQiCtrl:OnSCCrossEquipAllEquip(protocol)
	self.data:SetSCCrossEquipAllEquip(protocol)
	self.view:Flush("equip_view")
	RemindManager.Instance:Fire(RemindName.DouqiEquip)
end

function DouQiCtrl:FlushEuqipView()
	self.view:Flush("equip_view")
	self.equip_recovery_view:Flush()
end

-- 传世碎片改变 右下角显示
function DouQiCtrl:OnSCCrossEquipChuanshiFragmentChange(protocol)
	if protocol.change_fragment > 0 then
		local str = string.format(Language.Douqi.ChuanShiSuiPian[protocol.change_type], ToColorStr(protocol.change_fragment, TEXT_COLOR.GREEN))
		TipsCtrl.Instance:ShowFloatingLabel(str)
	end
end

-- 斗气经验改变 右下角显示
function DouQiCtrl:OnSCCrossEquipDouqiExpChange(protocol)
	self.data:SetSCCrossEquipDouqiExpChange(protocol)
end


