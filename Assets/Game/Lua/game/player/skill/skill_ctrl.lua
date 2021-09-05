require("game/player/skill/skill_data")

--------------------------------------------------------------
--技能相关
--------------------------------------------------------------
SkillCtrl = SkillCtrl or BaseClass(BaseController)
function SkillCtrl:__init()
	if SkillCtrl.Instance then
		print_error("[SkillCtrl] Attemp to create a singleton twice !")
	end
	SkillCtrl.Instance = self

	self.skill_data = SkillData.New()

	self:RegisterAllProtocols()
end

function SkillCtrl:__delete()
	SkillCtrl.Instance = nil

	self.skill_data:DeleteMe()
	self.skill_data = nil
end

function SkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSkillListInfoAck, "OnSkillListInfoAck")
	self:RegisterProtocol(SCSkillInfoAck, "OnSkillInfoAck")
	self:RegisterProtocol(SCSkillOtherSkillInfo, "OnSkillOtherSkillInfo")
	self:RegisterProtocol(SCUpGradeSkillInfo, "OnUpGradeSkillInfo")		-- 进阶装备技能改变
	self:RegisterProtocol(CSRoleSkillLearnReq)
	self:RegisterProtocol(SCRoleTelentInfo, "OnRoleTelentInfo")
	self:RegisterProtocol(CSRoleTelentOperate)
end

function SkillCtrl:OnSkillListInfoAck(protocol)
	self.skill_data:CheckIsNew(protocol.skill_list, protocol.is_init)
	self.skill_data:SetDefaultSkillIndex(protocol.default_skill_index)
	self.skill_data:SetSkillList(protocol.skill_list)
	GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT)
	RemindManager.Instance:Fire(RemindName.PlayerSkill)
	RemindManager.Instance:Fire(RemindName.PlayerActiveSkill)
	RemindManager.Instance:Fire(RemindName.PlayerPassiveSkill)
	ViewManager.Instance:FlushView(ViewName.Player)
end

function SkillCtrl:OnSkillInfoAck(protocol)
	self.skill_data:SetSkillInfo(protocol.skill_info)
	RemindManager.Instance:Fire(RemindName.PlayerSkill)
	RemindManager.Instance:Fire(RemindName.PlayerActiveSkill)
	RemindManager.Instance:Fire(RemindName.PlayerPassiveSkill)
end

--刺客暴击
function SkillCtrl:OnSkillOtherSkillInfo(protocol)
	self.skill_data:SetSkillOtherSkillInfo(protocol)
end

--技能学习 one_key_learn 1 一键学习
function SkillCtrl:SendRoleSkillLearnReq(skill_id, req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleSkillLearnReq)
	protocol.skill_id = skill_id
	protocol.req_type = req_type
	protocol:EncodeAndSend()
end

function SkillCtrl:OnUpGradeSkillInfo(protocol)
	PlayerData.Instance:SetAttr("upgrade_next_skill", protocol.upgrade_next_skill)
	PlayerData.Instance:SetAttr("upgrade_cur_calc_num", protocol.upgrade_cur_calc_num)

	GlobalEventSystem:Fire(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE)
end

function SkillCtrl:OnRoleTelentInfo(protocol)
	self.skill_data:SetRoleTelentInfo(protocol)
	PlayerCtrl.Instance:FlushInnateSkillView()
	RemindManager.Instance:Fire(RemindName.PlayerInnateSkill)
	RemindManager.Instance:Fire(RemindName.PlayerSkill)
end

function SkillCtrl:SendRoleTelentOperate(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleTelentOperate)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end
