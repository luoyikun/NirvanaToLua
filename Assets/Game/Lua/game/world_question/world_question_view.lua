WorldQuestionView = WorldQuestionView or BaseClass(BaseView)

local FIX_EXIT_TIME = 3
function WorldQuestionView:__init()
	self.ui_config = {{"uis/views/worldquestionview_prefab", "WorldQuestionView"}}
	self.full_screen = false
	self.play_audio = true
end

function WorldQuestionView:LoadCallBack()
	self.answer_list = {}
	for i = 1, 4 do
		self.answer_list[i] = {}
		self.answer_list[i].answer_text = self.node_list["TxtAnswer" .. i]
		self.answer_list[i].show_answer = self.node_list["NodeAnswer" .. i]
		self.node_list["BtnAnswer" .. i].button:AddClickListener(BindTool.Bind2(self.OnAnswerClick, self, i))
		self.node_list["TxtAnswer" .. i].button:AddClickListener(BindTool.Bind2(self.OnAnswerClick, self, i))
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
end

function WorldQuestionView:OpenCallBack()
	self:Flush()
end

function WorldQuestionView:ReleaseCallBack()
	for i = 1, 4 do
		self.answer_list[i].answer_text = nil
		self.answer_list[i].show_answer = nil
		self.answer_list[i] = {}
	end
	self.answer_list = {}
end

function WorldQuestionView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function WorldQuestionView:OnCloseClick()
	local select_index = WorldQuestionData.Instance:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.WORLD)
	if select_index == 0 then
		WorldQuestionData.Instance:SetSelectQuestion(index, WORLD_GUILD_QUESTION_TYPE.WORLD)
		WorldQuestionCtrl.SendQuestionAnswerReq(WORLD_GUILD_QUESTION_TYPE.WORLD, 999)					-- 关闭时 发一个不是0-3的值给服务端判断答题失误
		WorldQuestionData.Instance:SetSendAnswerReq(false)
	end
	self:Close()
end

function WorldQuestionView:OnAnswerClick(index)
	local select_index = WorldQuestionData.Instance:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.WORLD)
	if select_index == 0 then
		WorldQuestionData.Instance:SetSelectQuestion(index, WORLD_GUILD_QUESTION_TYPE.WORLD)
		WorldQuestionCtrl.SendQuestionAnswerReq(WORLD_GUILD_QUESTION_TYPE.WORLD, index - 1)
		WorldQuestionData:SetSendAnswerReq(true)
	end
end

function WorldQuestionView:OpenCallBack()
	self:Flush()
end

function WorldQuestionView:OnFlush()
	local question_data = WorldQuestionData.Instance
	local world_result_list = question_data:GetWorldResultList()
	local world_answer_list = question_data:GetWorldAnswerList()
	local select_index = question_data:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.WORLD)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local reward = PlayerData.Instance:GetFBExpByLevel(level) or 0
	local num = CommonDataManager.ConverMoney2(reward)
	-- local reward = ConfigManager.Instance:GetAutoConfig("question_auto").wg_question[1].right_exp_reward * (GameVoManager.Instance:GetMainRoleVo().level +50)
	self.node_list["Txt_exp"].text.text = Language.Common.JingYan .. "+" .. ToColorStr(num, TEXT_COLOR.GREEN)
	--显示限制vip
	local is_can_auto = question_data:GetCanAutoAnswer()
	local color_value = is_can_auto and COLOR.WHITE or TEXT_COLOR.RED
	local vip_limit = WorldQuestionData.Instance:GetAutoAnswerVip()
	local vip_text = ToColorStr(tostring(vip_limit), color_value)
	self.node_list["TxtAutoAnswer"].text.text = string.format(Language.Common.AutoAnser, vip_text)

	--答案状态
	if world_result_list and next(world_result_list) and select_index then
		for i = 1, 4 do
			self.answer_list[i].show_answer:SetActive(select_index == i or world_result_list.result + 1 == i)
		end

		--显示正确与错误
		self.node_list["ImgYes" .. select_index]:SetActive(world_result_list.result + 1 == select_index)
		self.node_list["ImgNo" .. select_index]:SetActive(not (world_result_list.result + 1 == select_index))
		self.node_list["ImgYes" .. world_result_list.result + 1]:SetActive(true)
		self.node_list["ImgNo" .. world_result_list.result + 1]:SetActive(false)

		--提前结束答题
		local time = world_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime()
		if time > FIX_EXIT_TIME then
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			self.node_list["TxtTime"].text.text = string.format(Language.Common.AnserCountdown, math.ceil(FIX_EXIT_TIME))
			self.count_down = CountDown.Instance:AddCountDown(FIX_EXIT_TIME, 1, BindTool.Bind(self.CountDown, self))
		end

		--弹出正确或错误提示
		if world_result_list.result + 1 == select_index then
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Correct)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Wrong)
		end
		return
	end

	--答题状态
	if world_answer_list and next(world_answer_list) then
		self.node_list["TxtQuestion"].text.text = world_answer_list.question
		--显示选项
		for i = 1, 4 do
			self.answer_list[i].show_answer:SetActive(false)
			self.answer_list[i].answer_text.text.text = world_answer_list.question_list[i]
		end

		--结束倒计时
		local time = math.ceil(world_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime()) - 2 --提早2s关闭
		self.node_list["TxtTime"].text.text = string.format(Language.Common.AnserCountdown, time)
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	end
end

function WorldQuestionView:CountDown(elapse_time, total_time)
	self.node_list["TxtTime"].text.text = string.format(Language.Common.AnserCountdown, math.ceil(total_time - elapse_time))
	if elapse_time >= total_time then
		self:Close()
	end
end
