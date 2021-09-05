FourGradeEquipData = FourGradeEquipData or BaseClass()

function FourGradeEquipData:__init()
	if FourGradeEquipData.Instance ~= nil then
		ErrorLog("[FourGradeEquipData] Attemp to create a singleton twice !")
	end

	FourGradeEquipData.Instance = self

	self.zero_gift_cfg = ConfigManager.Instance:GetAutoConfig("zerogift_auto").god_costume_cfg
	self.is_show_label = true
	self.reward_flag = {}

	RemindManager.Instance:Register(RemindName.FourGradeEquip, BindTool.Bind(self.GetFourGradeEquipRemind, self))
end

function FourGradeEquipData:__delete()
	RemindManager.Instance:UnRegister(RemindName.FourGradeEquip)
	FourGradeEquipData.Instance = nil
end

function FourGradeEquipData:GetFourGradeEquipRemind()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local need_open_day = self.zero_gift_cfg and self.zero_gift_cfg[1].open_day or 0
	if open_day < self.zero_gift_cfg[1].open_day then
		return 0
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = self:GetFourGradeEquipCfg()
	if self:GetFourGradeEquipIsBuy() then
		for i = 1, 3 do
		 	if cfg["level_limit_" .. (i - 1)] <= role_level and 0 == self:GetFourGradeEquipRewardIsGet(i) then
		 		return 1
		 	end
		 end 
	end
	return 0
end

function FourGradeEquipData:SetFourGradeEquipInfo(protocol)
	local data = protocol.zero_gift_god_costume_info[1]
	self.buy_state = data.buy_state
	self.reward_flag = bit:d2b(data.reward_flag)
	if MainUICtrl.Instance:GetView() then
		MainUICtrl.Instance:GetView():ShowFourGradeEquipXianshi()
	end
end

-- 是否购买
function FourGradeEquipData:GetFourGradeEquipIsBuy()
	return self.buy_state == 1
end

-- 领取奖励
function FourGradeEquipData:GetFourGradeEquipRewardIsGet(index)
	return self.reward_flag[33 - index] or -1
end

function FourGradeEquipData:SetFourGradeIconFirstOpen(enable)
	self.is_show_label = enable
end

function FourGradeEquipData:GetFourGradeIconFirstOpen()
	local is_all_buy = self:GetFourGradeEquipIsBuy()
	return self.is_show_label and not is_all_buy
end

-- 获取四阶神装配置
function FourGradeEquipData:GetFourGradeEquipCfg()
	return self.zero_gift_cfg[1]
end

-- 是否打开
function FourGradeEquipData:IsOpenFourGradeEquipView()
	local is_open = OpenFunData.Instance:CheckIsHide("four_grade_equip")
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if self:GetFourGradeEquipIsBuy() then
		return (is_open and open_day >= self.zero_gift_cfg[1].open_day and (1 ~= self:GetFourGradeEquipRewardIsGet(1) or
			1 ~= self:GetFourGradeEquipRewardIsGet(2) or 1 ~= self:GetFourGradeEquipRewardIsGet(3)))
	else
		return open_day < self.zero_gift_cfg[1].end_day and is_open
	end
end
