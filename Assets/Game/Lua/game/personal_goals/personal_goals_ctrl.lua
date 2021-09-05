require("game/personal_goals/personal_goals_data")

PersonalGoalsCtrl = PersonalGoalsCtrl or BaseClass(BaseController)

function PersonalGoalsCtrl:__init()
	if PersonalGoalsCtrl.Instance then
		print_error("[PersonalGoalsCtrl] 尝试创建第二个单例模式")
		return
	end
	PersonalGoalsCtrl.Instance = self
	self:RegisterAllProtocols()

	self.data = PersonalGoalsData.New()
end

function PersonalGoalsCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	PersonalGoalsCtrl.Instance = nil
end

function PersonalGoalsCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRoleGoalOperaReq)
end

function PersonalGoalsCtrl:SendRoleGoalOperaReq(opera_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleGoalOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end

function PersonalGoalsCtrl:OnSCRoleGoalInfo(protocol)
	local old_reward_index = self.data:GetReWardIndex()
	self.data:SetRoleGoalInfo(protocol)
	if old_reward_index == protocol.old_chapter then
		self.view:Flush("after_reward")
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end
	PlayerCtrl.Instance:FlushMieShiSkillView()
	CollectiveGoalsCtrl.Instance:GetView():Flush()
	RemindManager.Instance:Fire(RemindName.PersonalGoals)
	RemindManager.Instance:Fire(RemindName.CollectiveGoals)
end

function PersonalGoalsCtrl:SendFinishGoleReq()
	PersonalGoalsCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.FINISH_GOLE_REQ, 1)
end