LoopChargeData = LoopChargeData or BaseClass()

local ITEM_NUM = 4
function LoopChargeData:__init()
	if LoopChargeData.Instance ~= nil then
		print_error("[LoopChargeData] Attemp to create a singleton twice !")
	end
	LoopChargeData.Instance = self
	self.charge_data = {}
	self.charge_data.total_chongzhi = 0
	self.charge_data.cur_chongzhi = 0
	self.charge_data.cur_reward = {}
	self:InitData()
	RemindManager.Instance:Register(RemindName.LoopCharge, BindTool.Bind1(self.CheckRemind, self))
end

function LoopChargeData:__delete()
	LoopChargeData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LoopCharge)
end

function LoopChargeData:SetData(protocol)
	self.charge_data.total_chongzhi = protocol.total_chongzhi
	self.charge_data.cur_chongzhi = protocol.cur_chongzhi
end

function LoopChargeData:GetCfgData()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().circulation_chongzhi_2
end

function LoopChargeData:GetOtherData()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
end

function LoopChargeData:InitData()
	local cfg = self:GetOtherData()
	if cfg then
		self.charge_data.need_chongzhi = cfg.circulation_chongzhi_2_need_chongzhi or 0
	end
end

function LoopChargeData:ShowData()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(self:GetCfgData()) do
		if role_level <= v.level then
			self.charge_data.cur_reward = v.show_item_list
			return
		end
	end
end

function LoopChargeData:GetItemNum()
	return ITEM_NUM
end

function LoopChargeData:GetRewardList()
	return self.charge_data.cur_reward
end

function LoopChargeData:GetCharge()
	return self.charge_data.cur_chongzhi
end

function LoopChargeData:GetTotalCharge()
	return self.charge_data.total_chongzhi
end

function LoopChargeData:GetNeedCharge()
	return self.charge_data.need_chongzhi
end

function LoopChargeData:CanGetRewardFlag()
	if self:GetCharge() and self:GetNeedCharge() then
		if self:GetCharge() >= self:GetNeedCharge() then

			return true
		end
	end
	return false
end

function LoopChargeData:CheckRemind()
	if not OpenFunData.Instance:CheckIsHide("LoopCharge") then
		return 0
	end
	if MainuiActivityHallData.Instance:GetShowOnceEff(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2) then
		return 1
	end
	if self:CanGetRewardFlag() then
		return 1
	end
	return 0
end