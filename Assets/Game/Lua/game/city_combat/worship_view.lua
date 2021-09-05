WorshipRender = WorshipRender or BaseClass(BaseRender)

function WorshipRender:__init()
	
end

function WorshipRender:__delete()
	if self.day_count_change then
		GlobalEventSystem:UnBind(self.day_count_change)
		self.day_count_change = nil
	end

	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end
end

function WorshipRender:LoadCallBack()
	self.node_list["NodePanel"]:SetActive(true)
	self.day_count_change = GlobalEventSystem:Bind(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DaycountChange, self))
	self.node_list["BtnMoBai"].button:AddClickListener(BindTool.Bind(self.OnWorship, self))

	local worship_times, _, _ = CityCombatData.Instance:GetGCZWorshipInfo()
	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	if nil ~= cfg_num then
		worship_times = worship_times or 0
		self.node_list["TxtTime"].text.text = cfg_num - worship_times
	end
	self:Flush()
end

function WorshipRender:DaycountChange(day_counter_id)
	self:Flush()
end

function WorshipRender:OnFlush()
	local worship_times, next_worship_timestamp, next_interval_addexp_timestamp = CityCombatData.Instance:GetGCZWorshipInfo()
	if nil == worship_times or nil == next_worship_timestamp or nil ==  next_interval_addexp_timestamp then
		return
	end

	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end

	local cd = next_worship_timestamp - TimeCtrl.Instance:GetServerTime()
	if cd >= 0 then
		self.count_down = CountDown.Instance:AddCountDown(cd, 0.1, BindTool.Bind(self.SetCd, self))
	end
	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	if nil ~= cfg_num then
		local num = cfg_num - worship_times
		self.node_list["TxtTime"].text.text =  num 
	end
end

function WorshipRender:OnWorship()
	local worship_times, next_worship_timestamp, _ = CityCombatData.Instance:GetGCZWorshipInfo()
	next_worship_timestamp = next_worship_timestamp or TimeCtrl.Instance:GetServerTime()
	if next_worship_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.CD)
		return
	end
	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	if nil ~= cfg_num and nil ~= worship_times then
		if worship_times >= cfg_num then 
			SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.MaxWorship)
			return
		end
	end
	CityCombatCtrl.Instance:SendWorshipReq()
end

function WorshipRender:SetCd(elapse_time, total_time)
	local worship_times, _, _ = CityCombatData.Instance:GetGCZWorshipInfo()
	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	local left_time = total_time - elapse_time
	if self.node_list["ImgMask"] then
		if left_time > 0 then
			self.node_list["ImgMask"]:SetActive(true)
			self.node_list["TxtCD"]:SetActive(true)
			self.node_list["ImgMask"].image.fillAmount = left_time / total_time
			self.node_list["TxtCD"].text.text = math.ceil(left_time)
		else
			self.node_list["ImgMask"]:SetActive(false)
			self.node_list["TxtCD"]:SetActive(false)
			self.node_list["ImgMask"].image.fillAmount = 0
		end
	end

	if cfg_num and left_time <= 0 and cfg_num > worship_times then
		self.node_list["Effect"]:SetActive(true)
	else
		self.node_list["Effect"]:SetActive(false)
	end
end