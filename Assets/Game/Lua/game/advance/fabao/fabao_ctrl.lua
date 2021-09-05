require("game/advance/fabao/fabao_data")

FaBaoCtrl = FaBaoCtrl or BaseClass(BaseController)

function FaBaoCtrl:__init()
	if FaBaoCtrl.Instance then
		return
	end
	FaBaoCtrl.Instance = self

	self:RegisterAllProtocols()
	self.fabao_data = FaBaoData.New()
end

function FaBaoCtrl:__delete()
	if self.fabao_data ~= nil then
		self.fabao_data:DeleteMe()
		self.fabao_data = nil
	end

	FaBaoCtrl.Instance = nil
end

function FaBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendFabaoInfo, "FaBaoInfo")
	self:RegisterProtocol(CSFabaoOperateReq)
end

function FaBaoCtrl:FaBaoInfo(protocol)
	if self.fabao_data.fabao_info and next(self.fabao_data.fabao_info) then
		if self.fabao_data.fabao_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end

	self.fabao_data:SetFaBaoInfo(protocol)
	AdvanceCtrl.Instance:FlushView("fabaohuanhua")
	AdvanceCtrl.Instance:FlushView("fabao")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	-- FaBaoHuanHuaCtrl.Instance:FlushView("fabaohuanhua")

	-- 进阶装备
	RemindManager.Instance:Fire(RemindName.AdvanceEquip)
	RemindManager.Instance:Fire(RemindName.HuanHua)
	RemindManager.Instance:Fire(RemindName.AdvanceFaBao)
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function FaBaoCtrl:SendUpGradeReq(req_type,is_auto_buy,repeat_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFabaoOperateReq)
	send_protocol.req_type   = req_type or 0		-- 请求类型
	send_protocol.param1     = is_auto_buy or 0		-- 是否主动购买进阶材料
	send_protocol.param2     = repeat_times or 1
	send_protocol:EncodeAndSend()
end

--发送使用形象请求
function FaBaoCtrl:SendUseFaBaoImage(req_type,image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFabaoOperateReq)
	send_protocol.req_type = req_type
	send_protocol.param1 = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function FaBaoCtrl:FaBaoSkillUplevelReq(req_type,skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFabaoOperateReq)
	send_protocol.req_type = req_type
	send_protocol.param1 = skill_idx
	send_protocol.param2 = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function FaBaoCtrl:SendGetFaBaoInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFaBaoGetInfo)
	send_protocol:EncodeAndSend()
end

-- 发送升阶请求
function FaBaoCtrl:FaBaoUpStarlevelReq(is_auto_buy, stuff_index, loop_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFabaoReq)
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.loop_times = loop_times or 1
	send_protocol:EncodeAndSend()
end

function FaBaoCtrl:SendFaBaoUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFabaoReq)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end

function FaBaoCtrl:GetTheFaBaoProtocol()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFabaoOperateReq)
	return protocol
end