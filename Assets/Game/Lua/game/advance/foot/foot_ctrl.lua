require("game/advance/foot/foot_data")

FootCtrl = FootCtrl or BaseClass(BaseController)

function FootCtrl:__init()
	if FootCtrl.Instance then
		return
	end
	FootCtrl.Instance = self

	self:RegisterAllProtocols()
	self.foot_data = FootData.New()
end

function FootCtrl:__delete()
	if self.foot_data ~= nil then
		self.foot_data:DeleteMe()
		self.foot_data = nil
	end

	FootCtrl.Instance = nil
end

function FootCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFootPrintInfo, "OnFootprintInfo")
	self:RegisterProtocol(CSFootprintOperate)
end

function FootCtrl:OnFootprintInfo(protocol)
	self.foot_data:SetFootInfo(protocol)
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	AdvanceCtrl.Instance:FlushView("foothuanhua")
	AdvanceCtrl.Instance:FlushView("foot")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	-- FootHuanHuaCtrl.Instance:FlushView("foothuanhua")
	-- 进阶装备
	RemindManager.Instance:Fire(RemindName.AdvanceEquip)
	RemindManager.Instance:Fire(RemindName.HuanHua)
	RemindManager.Instance:Fire(RemindName.AdvanceFoot)
	AdvanceCtrl.Instance:FlushEquipView()
end

function FootCtrl.SendFootOperate(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFootprintOperate)
	send_protocol.operate_type = operate_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function FootCtrl:SendUseFootImage(image_id, is_temp_image)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_USE_IMAGE, image_id, is_temp_image)
end

--发送进阶请求
function FootCtrl:SendUpGradeReq(is_auto_buy,repeat_times)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_GRADE,repeat_times,is_auto_buy)
end

-- 发送技能升级请求
function FootCtrl:FootSkillUplevelReq(skill_idx, auto_buy)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_LEVEL_SKILL, skill_idx, auto_buy)
end

function FootCtrl:SendFootUpLevelReq(equip_index)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_LEVEL_EQUIP, equip_index)
end