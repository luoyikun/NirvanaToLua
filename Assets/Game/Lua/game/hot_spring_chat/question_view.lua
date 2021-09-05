QuestionView = QuestionView or BaseClass(BaseView)

function QuestionView:__init()
	self.ui_config = {{"uis/views/chatroom_prefab", "QuestionView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUIHigh
end

function QuestionView:__delete()
	self:RemoveCountDown()
	self:RemoveDelayTime()
end
	
function QuestionView:ReleaseCallBack()
	self:RemoveCountDown()
	self:RemoveDelayTime()

end

function QuestionView:LoadCallBack()
	self.node_list["BtnA"].button:AddClickListener(BindTool.Bind(self.OnClickAnswer, self, 0))
	self.node_list["BtnB"].button:AddClickListener(BindTool.Bind(self.OnClickAnswer, self, 1))
end

function QuestionView:CloseCallBack()
	HotStringChatCtrl.Instance:SetToggleIsOn(1, true)
end

function QuestionView:OpenCallBack()
	HotStringChatCtrl.Instance:SetToggleIsOn(2, true)
end

function QuestionView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "question" then
			self:SetNewQuestion()
		elseif k == "result" then
			self:SetResult(v.result, v.right_result, v.last_choose)
		elseif k == "role_info" then
			self:FlushRoleInfo()
		end
	end
end

function QuestionView:OnClickAnswer(answer)
	GuajiCtrl.Instance:StopGuaji()
	self.choose_answer = answer
	HotStringChatData.Instance:SetChooseAnswer(answer)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.HotSpring then
			local pos = {}
			if answer == 0 then
				pos = scene_logic:GetPosA()
			else
				pos = scene_logic:GetPosB()
			end
			if pos and next(pos) then
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.x, pos.y, 1, 1)
			end
		end
	end
end

function QuestionView:SetNewQuestion()
	self.node_list["AnswerPanel"]:SetActive(true)
	self.node_list["ImgReminder"]:SetActive(false)
	self.node_list["YesA"]:SetActive(false)
	self.node_list["NoA"]:SetActive(false)
	self.node_list["YesB"]:SetActive(false)
	self.node_list["NoB"]:SetActive(false)

	self:FlushAnswerPanel()
end

function QuestionView:ShowSelectAnswer(index)
	local flag_1 = index ~= 2
	local flag_2 = index == 0
	self.node_list["Select0"]:SetActive(flag_1 and flag_2)
	self.node_list["Select1"]:SetActive(flag_1 and not flag_2)
end

function QuestionView:FlushAnswerPanel()
	local question_info = HotStringChatData.Instance:GetQuestionInfo()
	if question_info then
		local current_count = question_info.broadcast_question_total
		self.node_list["TxtTitle"].text.text = string.format(Language.Answer.DiJiTi, current_count)
		self.node_list["TxtQuestion"].text.text = question_info.curr_question_str
		self.node_list["TxtA"].text.text = question_info.curr_answer0_desc_str
		self.node_list["TxtB"].text.text = question_info.curr_answer1_desc_str

		local rest_time = question_info.curr_question_end_time - TimeCtrl.Instance:GetServerTime()
		self:ChangeRestTime(rest_time)
		if rest_time > 0 then
			self:RemoveCountDown()
			self.count_down = CountDown.Instance:AddCountDown(rest_time, 0.1, BindTool.Bind(self.UpdateTime, self))
		end
	end
	self.node_list["TxtTime2"].text.text = Language.Answer.ShengYuShiJian
end

function QuestionView:UpdateTime(elapse_time, total_time)
	local rest_time = total_time - elapse_time
	self:ChangeRestTime(rest_time)
end

function QuestionView:ChangeRestTime(rest_time)
	rest_time = math.max(rest_time, 0)
	local rest_time_str = string.format("%.1f", rest_time)
	-- if rest_time < 10 then
	-- 	rest_time_str = "0" .. rest_time_str
	-- else
	-- 	rest_time_str = rest_time_str
	-- end
	if rest_time < 5 then
		rest_time_str = ToColorStr(rest_time_str, TEXT_COLOR.RED)
	end
	self.node_list["TxtTime1"].text.text = rest_time_str
end

function QuestionView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function QuestionView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function QuestionView:SetResult(result, right_result, choose)
	if result == 0 then -- 回答错误
		SysMsgCtrl.Instance:ErrorRemind(Language.Answer.Wrong)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Answer.Correct)
	end
	-- 如果选择弃权
	if choose == 2 then
		if right_result == 0 then
			self.node_list["YesA"]:SetActive(true)
			self.node_list["NoB"]:SetActive(true)
		else
			self.node_list["YesB"]:SetActive(true)
			self.node_list["NoA"]:SetActive(true)
		end
	-- 选择B
	elseif choose == 1 then
		if right_result == 0 then
			self.node_list["NoB"]:SetActive(true)
		else
			self.node_list["YesB"]:SetActive(true)
		end
	-- 选择A
	else
		if right_result == 0 then
			self.node_list["YesA"]:SetActive(true)
		else
			self.node_list["NoA"]:SetActive(true)
		end
	end

	local question_info = HotStringChatData.Instance:GetQuestionInfo()
	local total_question_count = HotStringChatData.Instance:GetTotalQuestionCount() or 0
	if question_info.broadcast_question_total >= total_question_count then
		-- 如果是跟随榜首
		if HotStringChatCtrl.Instance.is_follow then
			GuajiCtrl.Instance:StopGuaji()
		end
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:Close() end, 5)
	else
		self:RemoveCountDown()
		local answer_prepare_time = question_info.next_question_start_time - TimeCtrl.Instance:GetServerTime()
		self.count_down = CountDown.Instance:AddCountDown(answer_prepare_time, 0.1, BindTool.Bind(self.UpdateTime, self))
	end
	self.node_list["TxtTime2"].text.text = Language.Answer.ZhunBeiShiJian
	result = nil
	choose = nil
	right_result = nil

end

function QuestionView:FlushRoleInfo()
	local role_info = ""
	local role_info = HotStringChatData.Instance:GetRoleAnswerInfo()
	if role_info then
		self.node_list["TxtRightCount"].text.text = role_info.question_right_count
	end
end