WelcomeView = WelcomeView or BaseClass(BaseView)

function WelcomeView:__init()
	self.ui_config = {{"uis/views/welcomeview_prefab", "WelcomeView"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function WelcomeView:ReleaseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function WelcomeView:LoadCallBack()
	self.node_list["BtnStartGame"].button:AddClickListener(BindTool.Bind(self.OnStartGame, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnStartGame, self))

	self:SetAutoTalkTime()
end

function WelcomeView:OnStartGame()
	self:Close()
	TaskCtrl.Instance:DoTask()
end

function WelcomeView:OpenCallBack()
	TaskCtrl.Instance:SetAutoTalkState(false)
end

-- 设置倒计时
function WelcomeView:SetAutoTalkTime()
	self.auto_talk = false
	self.node_list["Txt"].text.text = string.format(Language.Task.AutoGoOn, ToColorStr(5, TEXT_COLOR.WHITE))
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(5, 1, BindTool.Bind(self.CountDown, self))
end

-- 倒计时函数
function WelcomeView:CountDown(elapse_time, total_time)
	self.node_list["Txt"].text.text = string.format(Language.Task.AutoGoOn, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.WHITE))
	if elapse_time >= total_time then
		self:Close()
	end
end