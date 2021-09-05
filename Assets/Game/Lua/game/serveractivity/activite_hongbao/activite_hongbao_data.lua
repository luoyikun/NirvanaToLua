ActiviteHongBaoData = ActiviteHongBaoData or BaseClass()
ActHongBaoFlag = {
	CanGet = 0,
	HasGet = 1,
}

function ActiviteHongBaoData:__init()
	if ActiviteHongBaoData.Instance ~= nil then
		ErrorLog("[ActiviteHongBaoData] Attemp to create a singleton twice !")
	end
	ActiviteHongBaoData.Instance = self
	self.consume_gold_num_list = {}
	self.reward_flag = 0
	self.randactivity_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	self.has_read =	false

end

function ActiviteHongBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ActHongBao)

	ActiviteHongBaoData.Instance = nil
end

function ActiviteHongBaoData:SetRARedEnvelopeGiftInfo(protocol)
	self.consume_gold_num_list = protocol.consume_gold_num_list
	self.reward_flag = protocol.reward_flag
end


function ActiviteHongBaoData:GetDiamondNum()
	return self.consume_gold_num_list
end

function ActiviteHongBaoData:GetFlag(day)
	local index = day - 1
	local bit_list = bit:d2b(self.reward_flag)
	return bit_list[32 - index]
end

function ActiviteHongBaoData:IsGetAll()
	local is_get_all = true
	for i = 1, 7 do
		if self:GetRebateDayVal(i) ~= 0 then
			if self:GetFlag(i) == 0 then
				is_get_all = false
			end
		end
	end
	return is_get_all
end

function ActiviteHongBaoData:GetRebateTotalVal()
	local return_percent = self.randactivity_cfg.red_envelope_gift[1].percent / 10000
	local total_val = 0
	for i = 1, 7 do
		total_val = total_val + self.consume_gold_num_list[i] * return_percent - self.consume_gold_num_list[i] * return_percent % 1
	end
	return total_val
end

function ActiviteHongBaoData:GetRebateDayVal(day)
	local return_percent = self.randactivity_cfg.red_envelope_gift[1].percent / 10000
	if self.consume_gold_num_list[day] ~= nil then
		return self.consume_gold_num_list[day] * return_percent - self.consume_gold_num_list[day] * return_percent % 1
	end
end

function ActiviteHongBaoData:TurnIsRead()
	self.has_read = true
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("kf_hb_act_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function ActiviteHongBaoData:IsRead()
	return self.has_read
end

function ActiviteHongBaoData:GetHongBaoRemind()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO) then
		return false
	end
	local is_show_rpt = false
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("kf_hb_act_remind_day") or cur_day
	if cur_day < 8 then
		if cur_day ~= -1 and cur_day ~= remind_day then
			is_show_rpt = true
		end
	else
		is_show_rpt = not self:IsGetAll()
	end
	return is_show_rpt
end