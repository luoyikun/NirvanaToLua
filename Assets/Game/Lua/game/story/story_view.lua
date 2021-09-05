StoryView = StoryView or BaseClass(BaseView)

function StoryView:__init()
	self.ui_config = {{"uis/views/story_prefab", "StoryView"}}

	self.active_close = false
	self.open_callback = nil
	self.close_callback = nil
	self.girl_say_end_time = 0
	self.show_message_timer = nil
	self.show_husong_reward_timer = nil
	self.is_show_mainui_mode = false
	self.is_show_hide_other_btn = true
	self.is_show_step_desc = false
	self.victory_count_down = nil
	self.show_attack_timer = nil
	self.show_help_timer = nil
	self.is_modal = true
end

function StoryView:__delete()
	self.open_callback = nil
	self.close_callback = nil
end

function StoryView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.show_message_timer)
	GlobalTimerQuest:CancelQuest(self.show_husong_reward_timer)
	GlobalTimerQuest:CancelQuest(self.show_attack_timer)
	GlobalTimerQuest:CancelQuest(self.show_help_timer)
	CountDown.Instance:RemoveCountDown(self.victory_count_down)

	if nil ~= self.show_or_hide_mode_list_evt then
		GlobalEventSystem:UnBind(self.show_or_hide_mode_list_evt)
		self.show_or_hide_mode_list_evt = nil
	end

	if nil ~= self.show_or_hide_other_btn_evt then
		GlobalEventSystem:UnBind(self.show_or_hide_other_btn_evt)
		self.show_or_hide_other_btn_evt = nil
	end

	if nil ~= FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.StoryView)
	end

	-- 清理变量和对象
	self.attack_icon = nil
end

function StoryView:SetOpenCallBack(open_callback)
	self.open_callback = open_callback
end

function StoryView:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function StoryView:OpenCallBack()
	Runner.Instance:AddRunObj(self, 8)
	if nil ~= self.open_callback then
		self.open_callback()
		ViewManager.Instance:CloseAll()
	end
end

function StoryView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
	self.girl_say_end_time = 0

	if nil ~= self.close_callback then
		self.close_callback()
	end
end

function StoryView:Update(now_time, elapse_time)
	self:CheckGrilSayEnd(now_time)
end

function StoryView:LoadCallBack()
	self:SetMaskActive(false)
	if nil == self.show_or_hide_mode_list_evt then
		self.show_or_hide_mode_list_evt = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	end

	if nil == show_or_hide_other_btn_evt then
		self.show_or_hide_other_btn_evt = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.SwitchButtonState, self))
	end

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.StoryView, BindTool.Bind(self.GetUiCallBack, self))
end

function StoryView:OnMainUIModeListChange(is_show)
	self.is_show_mainui_mode = is_show
	self:RefreshStepDescShowState()
end

function StoryView:SwitchButtonState(is_show)
	self.is_show_hide_other_btn = is_show
	self:RefreshStepDescShowState()
end

-- 美女说话
function StoryView:OnGirlSay(content, say_time)
	self.node_list["TxtGirlSay"].text.text = content
	self.node_list["GirlSay"]:SetActive(true)
	self.girl_say_end_time = Status.NowTime + say_time
end

function StoryView:CheckGrilSayEnd(now_time)
	if self.girl_say_end_time > 0 and now_time >= self.girl_say_end_time then
		self.node_list["GirlSay"]:SetActive(false)
		self.girl_say_end_time = 0
	end
end

-- 显示消息
function StoryView:ShowMessage(content, show_time)
	GlobalTimerQuest:CancelQuest(self.show_message_timer)

	content = string.gsub(content, "{role_name}", Scene.Instance:GetMainRole():GetName())
	self.node_list["NodeMessage"]:SetActive(true)
	self.node_list["MessageTxtNode"].text.text = content

	local animator = self.node_list["MessageTxtNode"].animator
	animator:WaitEvent("hide", function(param)
		self.node_list["NodeMessage"]:SetActive(false)
	end)

	animator:SetBool(ANIMATOR_PARAM.SHOW, true)
	self.show_message_timer = GlobalTimerQuest:AddDelayTimer(function ()
		animator:SetBool(ANIMATOR_PARAM.SHOW, false)
		self.show_message_timer = nil
	end, show_time)
end

-- 显示护送领励面板
function StoryView:ShowHusongRewardView(fetch_callback)
	GlobalTimerQuest:CancelQuest(self.show_husong_reward_timer)
	self.node_list["HusongReward"]:SetActive(true)
	self:SetMaskActive(true)

	function onclick()
		self.node_list["HusongReward"]:SetActive(false)
		self:SetMaskActive(false)
		fetch_callback()
	end

	-- self.node_list["BtnBG"].button:AddClickListener(function() onclick() end)
	self.node_list["BtnClose"].button:AddClickListener(function() onclick() end)

	self.show_husong_reward_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.node_list["HusongReward"]:SetActive(false)
		self:SetMaskActive(false)
		fetch_callback()
	end, 5)
end

-- 羽翼剧情本打开门
function StoryView:ShowOpenDoor(open_door_callback)
	self.node_list["OpenDoor"]:SetActive(true)

	self.node_list["BtnOpenDoor"].button:AddClickListener(function ()
		self.node_list["OpenDoor"]:SetActive(false)
		open_door_callback()		
	end)
end

-- 显示步骤描述
function StoryView:ShowStepDesc(desc, do_operate_callback)
	if nil == desc or "" == desc then
		return
	end

	local desc_t = Split(desc, "##")
	local bar_title = SceneType.GuideFb == Scene.Instance:GetSceneType() and Language.Story.GuideFb or Language.Story.StoryFb
	self.node_list["TxtStoryStepBar"].text.text = bar_title

	self.node_list["TxtChapterName"].text.text = desc_t[1]
	self.node_list["SliderTask"].slider.value = tonumber(desc_t[2])
	self.node_list["TxtTaskDesc"].text.text = desc_t[3]
	self.node_list["TxtTaskCondition"].text.text = desc_t[4]

	self.node_list["BtnTask"].button:AddClickListener(function ()
		local operate = desc_t[5]
		local op_param_t = {}
		for i = 6, #desc_t do
			table.insert(op_param_t, desc_t[i])
		end
		do_operate_callback(operate, op_param_t)
	end)

	self.is_show_step_desc = true
	self:RefreshStepDescShowState()
end

function StoryView:RefreshStepDescShowState()
	local is_show = self.is_show_step_desc and self.is_show_hide_other_btn and not self.is_show_mainui_mode
	self.node_list["StoryStepDesc"]:SetActive(is_show)
end

-- 攻城战显示红包
function StoryView:ShowRedPacket(distribute_callback)
	self.node_list["RedPacket"]:SetActive(true)

	function onclick()
		self.node_list["RedPacket"]:SetActive(false)
		distribute_callback()
	end

	self.node_list["BtnNormal"].button:AddClickListener(function() onclick() end)
	self.node_list["BtnRedPacketBg"].button:AddClickListener(function() onclick() end)
end

-- 显示胜利面板(1.羽翼本，2.坐骑本 3.女神本)
function StoryView:ShowVictoryView(distribute_callback, fb_type)
	self.node_list["VictoryView"]:SetActive(true)
	local icon_name = string.format("VictoryIcon%d", fb_type)
	self.node_list[icon_name]:SetActive(true)
	self.node_list["TxtTime"].text.text = string.format(Language.Story.VictoryTime, 5)
	CountDown.Instance:RemoveCountDown(self.victory_count_down)

	self.victory_count_down = CountDown.Instance:AddCountDown(5, 1,
		function (elapse_time, total_time)
			local remain_time = math.ceil(total_time - elapse_time)
			self.node_list["TxtTime"].text.text = string.format(Language.Story.VictoryTime, remain_time)

			if remain_time <= 0 then
				CountDown.Instance:RemoveCountDown(self.victory_count_down)
				self.node_list["VictoryView"]:SetActive(false)
				distribute_callback()
			end
		end)

	self.node_list["Btn01"].button:AddClickListener(function ()
		self.node_list["VictoryView"]:SetActive(false)
		distribute_callback()
	end)
end

-- 显示求救
function StoryView:ShowHelp(interactive_end, show_time)
	function onclick()
		GlobalTimerQuest:CancelQuest(self.show_help_timer)
		self.show_help_timer = nil

		SysMsgCtrl.Instance:ErrorRemind(Language.Story.HelpSucc)
		self.node_list["BtnHelp"]:SetActive(false)
		FunctionGuide.Instance:EndGuide()
		interactive_end()
	end

	self.help_icon = self.node_list["BtnHelp"] -- 引导要用
	self.help_icon:SetActive(true)
	self.help_icon.button:AddclickListener(function ()
		onclick()
	end)

	GlobalTimerQuest:CancelQuest(self.show_help_timer)
	self.show_help_timer = GlobalTimerQuest:AddDelayTimer(function ()
		onclick()
	end, show_time)

	Scene.Instance:GetMainRole():StopMove()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	FunctionGuide.Instance:TriggerGuideByGuideName("story_help")
end

-- 显示击杀
function StoryView:ShowAttack(interactive_end, show_time)
	function onclick()
		GlobalTimerQuest:CancelQuest(self.show_attack_timer)
		self.show_attack_timer = nil

		self.node_list["BtnAttack"]:SetActive(false)
		FunctionGuide.Instance:EndGuide()

		GlobalTimerQuest:AddDelayTimer(function ()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end, 0.25)

		interactive_end()
	end

	self.attack_icon = self.node_list["BtnAttack"] -- 引导要用
	self.attack_icon:SetActive(true)

	self.attack_icon.button:AddClickListener(function ()
		onclick()
	end)

	GlobalTimerQuest:CancelQuest(self.show_attack_timer)
	self.show_attack_timer = GlobalTimerQuest:AddDelayTimer(function ()
		onclick()
	end, show_time)

	Scene.Instance:GetMainRole():StopMove()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	FunctionGuide.Instance:TriggerGuideByGuideName("attack_icon")
end

function StoryView:ShowAttackBack(interactive_end, show_time)
	Scene.Instance:GetMainRole():StopMove()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	FunctionGuide.Instance:TriggerGuideByGuideName("attack_back")
end

function StoryView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end