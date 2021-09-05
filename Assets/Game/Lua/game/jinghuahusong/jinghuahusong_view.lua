JingHuaHuSongView = JingHuaHuSongView or BaseClass(BaseView)

function JingHuaHuSongView:__init()
	self.ui_config = {{"uis/views/crystalescort_prefab", "CrystalEscortInfo"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.Pop
	self.is_safe_area_adapter = true
end

function JingHuaHuSongView:__delete()

end

function JingHuaHuSongView:ReleaseCallBack()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	GlobalTimerQuest:CancelQuest(self.time_quest)
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
end


function JingHuaHuSongView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.buttons then
		self.buttons:DeleteMe()
		self.buttons = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function JingHuaHuSongView:OpenCallBack()
	self.now_max_zhangong = 0

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/crystalescort_prefab", "CrystalSkills", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.buttons then
			self.buttons = CrystalRender.New(obj)
			-- self.buttons:AddClickListener(BindTool.Bind(self.CutFlag, self))
			self.buttons:Flush()
		end
	end)
end

function JingHuaHuSongView:LoadCallBack()
	self.node_list["BtnGoSmall"].button:AddClickListener(BindTool.Bind(self.ClickBtnSmall, self))
	self.node_list["BtnGoBig"].button:AddClickListener(BindTool.Bind(self.ClickBtnBig, self))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end
end

function JingHuaHuSongView:OnFlush()
	-- local big_num = JingHuaHuSongData.Instance:GetJingHuaGatherAmountByType(JingHuaHuSongData.JingHuaType.Big)
	local all_times = JingHuaHuSongData.Instance:GetReweardCollectionInfo()
	local current_times = JingHuaHuSongData.Instance:GetEscortSurplusTimes()
	local intercept_times = JingHuaHuSongData.Instance:GetReweardTorobInfo()
	local current_int = JingHuaHuSongData.Instance:GetInterceptTimes()
	local big_num = JingHuaHuSongData.Instance:GetBigCrystalNum()
	local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.JINGHUA_HUSONG)
	if info.status ~= ACTIVITY_STATUS.STANDY then
		local color = big_num > 0 and "#89F201" or "#F9463B"
		self.node_list["Surplus_text"].text.text = string.format(Language.CrossCrystal.CollectionTimes,current_times, all_times)
		self.node_list["surplus_time"].text.text = string.format(Language.CrossCrystal.InterceptTimes, current_int, intercept_times) 
		if big_num > 0 then
			self.node_list["BigCrystalNum"].text.text = string.format(Language.CrossCrystal.BigCrystalTips, color, big_num)  
		else
			self:SetReMainTime()
		end
	end

	local reward_cfg = JingHuaHuSongData.Instance:GetReweardItemInfo()
	for k,v in pairs(self.reward_list) do
		v:SetData(reward_cfg[k- 1])
		v.root_node:SetActive(reward_cfg[k-1] ~= nil and reward_cfg[k- 1].item_id ~= 0)
		self.node_list["CellItem" .. k]:SetActive(reward_cfg[k- 1] ~= nil and reward_cfg[k- 1].item_id ~= 0)
	end
end

function JingHuaHuSongView:SetReMainTime()
	local fush_time = JingHuaHuSongData.Instance:GetBigFushTime()
	local diff_time = fush_time - TimeCtrl.Instance:GetServerTime()
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 2)
			self.node_list["BigCrystalNum"].text.text = string.format(Language.CrossCrystal.BigCrystalTipsTime,time_str)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function JingHuaHuSongView:ClickBtnSmall()
	if JingHuaHuSongCtrl.Instance:IsOpen() then
		--前往采集物
		JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Small)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
	end
end
function JingHuaHuSongView:ClickBtnBig()
	if JingHuaHuSongCtrl.Instance:IsOpen() then
		JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Big)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
	end
end

function JingHuaHuSongView:OnMainUIModeListChange(is_show)
	self.node_list["PanelInfo"]:SetActive(is_show)
end


CrystalRender = CrystalRender or BaseClass(BaseRender)
function CrystalRender:__init()
end

function CrystalRender:LoadCallBack()
	self.node_list["BtnFlag"].button:AddClickListener(BindTool.Bind(self.CutFlag, self))
end
function CrystalRender:CutFlag()
	local husong_status = JingHuaHuSongData.Instance:GetMainRoleState()
	if husong_status ~= JH_HUSONG_STATUS.NONE then
		local husong_status = JingHuaHuSongData.Instance:GetMainRoleState()
		JingHuaHuSongCtrl.Instance:ContinueJingHuaHuSong()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.JingHuaHuSong.EscortTip)
	end
end

function CrystalRender:__delete()

end

function CrystalRender:OnFlush()

end
