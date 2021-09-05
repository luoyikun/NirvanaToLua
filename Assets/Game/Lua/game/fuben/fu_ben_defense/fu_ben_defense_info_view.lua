FuBenDefenseInfoView = FuBenDefenseInfoView or BaseClass(BaseView)

local SWEEP_BOSS_MAX_NUM = 10    ------最大召唤boss数量
function FuBenDefenseInfoView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "DefenseFBInFoView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.view_layer = UiLayer.MainUI
end

function FuBenDefenseInfoView:__delete()
	
end

function FuBenDefenseInfoView:LoadCallBack()
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))

	self.node_list["TextTime"]:SetActive(false)
	self.node_list["TextNotify"]:SetActive(false)

	for i = 1, 4 do
		self.node_list["Item" .. i].button:AddClickListener(BindTool.Bind(self.OnClickDefenseTips, self, i))
	end

	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickDefenseStart, self))
	self.node_list["BtnBoss"].button:AddClickListener(BindTool.Bind(self.OnClickDefenseBoss, self))
	self.node_list["BtnAward"].button:AddClickListener(BindTool.Bind(self.TouchDownEvent, self))

	-- self.listeners = self.node_list["BtnAward"].event_trigger_listener
	-- self.listeners:AddPointerDownListener(BindTool.Bind(self.TouchDownEvent, self))
	-- self.listeners:AddPointerUpListener(BindTool.Bind(self.TouchUpEvent, self))

	-- self.obj_create_handler = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
end

function FuBenDefenseInfoView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.node_list["TopPanel"]:SetActive(state)
	if self.node_list["TaskParent"] then
		self.node_list["TaskParent"]:SetActive(state)
	end
end

function FuBenDefenseInfoView:ReleaseCallBack()
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end

	if self.next_monster_count_down then
		CountDown.Instance:RemoveCountDown(self.next_monster_count_down)
		self.next_monster_count_down = nil
	end

	self.listeners = nil

	-- if nil ~= self.obj_create_handler then
	-- 	GlobalEventSystem:UnBind(self.obj_create_handler)
	-- 	self.obj_create_handler = nil
	-- end
end

function FuBenDefenseInfoView:OpenCallBack()
	self:Flush()
end

function FuBenDefenseInfoView:OnClickDefenseTips(index)
	-- self.node_list["ImgStart"]:SetActive(false)
	-- self.node_list["BtnStart"]:SetActive(false)
	FuBenData.Instance:SetDescIndex(index)
	FuBenCtrl.Instance:OpenDefenseTips(BuildTowerTipsView.DescPanel)
end


function FuBenDefenseInfoView:OnClickDefenseStart()
	FuBenCtrl.Instance:SendBuildTowerReq(BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_FLUSH)
end

function FuBenDefenseInfoView:OnClickDefenseBoss()
	FuBenCtrl.Instance:OpenDefenseSweep()
end

function FuBenDefenseInfoView:TouchDownEvent()
	local num = FuBenData.Instance:GetBuildTowerRewardNum()
	if num <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NotDropItem)
		return
	end
	FuBenCtrl.Instance:OpenDefenseTips(BuildTowerTipsView.RwardPanel)
end

function FuBenDefenseInfoView:TouchUpEvent()
	FuBenCtrl.Instance:CloseDefenseTips()
end

function FuBenDefenseInfoView:OnFlush()
	local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
	if defense_info == nil or next(defense_info) == nil then return end

	local exp = CommonDataManager.ConverNum(defense_info.exp)
	local cur_process = defense_info.cur_wave + 1 >= SWEEP_BOSS_MAX_NUM and ToColorStr(defense_info.cur_wave + 1, TEXT_COLOR.GREEN) or ToColorStr(defense_info.cur_wave + 1, TEXT_COLOR.RED)
	self.node_list["TextWave"].text.text = string.format(Language.FuBen.CurWaveNumber, cur_process, 10)
	self.node_list["TextEnergy"].text.text = string.format(Language.FuBen.DefenseDouHun, defense_info.douhun)
	-- self.node_list["TextExp"].text.text = string.format(Language.FuBen.DefenseExp, exp)
	local escape_monster_count = defense_info.escape_monster_count >= 20 and ToColorStr(defense_info.escape_monster_count, TEXT_COLOR.GREEN) or ToColorStr(defense_info.escape_monster_count, TEXT_COLOR.RED)
	self.node_list["TextEscaped"].text.text = string.format(Language.FuBen.EscapeMonster, escape_monster_count, 20)

	local remain_boss_num = defense_info.remain_buyable_monster_num <= 0 and 0 or defense_info.remain_buyable_monster_num
	UI:SetButtonEnabled(self.node_list["BtnBoss"], remain_boss_num ~= 0)
	self.node_list["BossNum"]:SetActive(defense_info.special_monster_num > 0)
	self.node_list["BossText"]:SetActive(defense_info.special_monster_num > 0)
	self.node_list["BossNum"].text.text = defense_info.special_monster_num
	self.node_list["ImgBossStart"]:SetActive(not (defense_info.special_monster_num > 0) and remain_boss_num ~= 0)
	if defense_info.cur_wave == -1 then
		self:DefenseFbTimePrompt(defense_info.notify_reason)
	end

	if defense_info.cur_wave ~= -1 then
		self:DefenseFbTimePrompt(defense_info.notify_reason)
		self.node_list["ImgStart"]:SetActive(false)
		self.node_list["BtnStart"]:SetActive(false)
	end
end

function FuBenDefenseInfoView:DefenseFbTimePrompt(notify_reason)
	local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
	if notify_reason == nil and self.notify_reason ~= notify_reason then return end
	self.notify_reason = notify_reason

	if self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_REASON_DEFAULT then			--正常
		return
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	local function NotVisibleTowerTime(str)
		self.node_list["TextNotify"]:SetActive(true)
		self.node_list["TextNext"]:SetActive(false)
		self.node_list["TextTime"]:SetActive(false)
		self.node_list["TextNotify"].text.text = str

		if self.delay_timer2 then
			GlobalTimerQuest:CancelQuest(self.delay_timer2)
			self.delay_timer2 = nil
		end
		if self.next_monster_count_down then
			CountDown.Instance:RemoveCountDown(self.next_monster_count_down)
			self.next_monster_count_down = nil
		end
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(function() self.node_list["TextNotify"]:SetActive(false) end, 3)
	end

	local str = ""
	if self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_PREPARE_TIME then		--准备开始倒计时
		local server_time = TimeCtrl.Instance:GetServerTime()
		local interval_time = defense_info.next_wave_timestamp - server_time
		if interval_time > 0 then
			self.count_down = CountDown.Instance:AddCountDown(interval_time, 1, function(elapse_time, total_time)
				if total_time - elapse_time > 0 then
					self.node_list["TextTime"]:SetActive(true)
					local time = (math.floor(total_time - elapse_time))
					self.node_list["TextTime"].text.text = string.format(Language.DefenseFb.DefenseStar, time)
				else
					self.node_list["TextTime"]:SetActive(false)
					if self.count_down then
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
				end
			end)
		end
		str = Language.DefenseFb.DefenseFbPrepare
		NotVisibleTowerTime(str)
	elseif self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_MONSTER_WAVE then
		self.node_list["TextTime"].text.text = string.format(Language.DefenseFb.DefenseFlushMonster, defense_info.cur_wave + 1)
		self.node_list["TextTime"]:SetActive(true)
		self.node_list["TextNext"]:SetActive(false)
		if self.delay_timer then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
		end
		if self.next_monster_count_down then
			CountDown.Instance:RemoveCountDown(self.next_monster_count_down)
			self.next_monster_count_down = nil
		end
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function() self.node_list["TextTime"]:SetActive(false) end, 3)
	elseif self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_BOSS_FLUSH then
		str = Language.DefenseFb.DefenseFbBossTip
		NotVisibleTowerTime(str)
	elseif self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_EXTRA_BOSS then
		str = Language.DefenseFb.DefenseFbBossTipTwo
		NotVisibleTowerTime(str)
	elseif self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_FB_END then

	elseif self.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_WAVE_FLUSH_END then
		if defense_info.notify_next_wave_timestamp > 0 and defense_info.cur_wave + 1 < 10 then
			if nil == self.next_monster_count_down then
				self.node_list["TextTime"]:SetActive(false)
				local next_time = defense_info.next_wave_timestamp - TimeCtrl.Instance:GetServerTime()
				self.next_monster_count_down = CountDown.Instance:AddCountDown(next_time, 1, function(elapse_time, total_time)
					if total_time - elapse_time > 0 then
						if self.node_list and self.node_list["TextNext"] then
							self.node_list["TextNext"]:SetActive(true)
							local time = math.floor(total_time - elapse_time + 0.5)
							self.node_list["TextNext"].text.text = string.format(Language.DefenseFb.DefenseNextStart, time)
						end
					else
						if self.next_monster_count_down then
							CountDown.Instance:RemoveCountDown(self.next_monster_count_down)
							self.next_monster_count_down = nil
						end
						if self.node_list and self.node_list["TextNext"] then
							self.node_list["TextNext"]:SetActive(false)
						end
					end
				end)
			end
		else
			self.node_list["TextNext"]:SetActive(false)
		end
	end
end