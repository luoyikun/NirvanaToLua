ExpBallView = ExpBallView or BaseClass(BaseView)
local PAGE_COUNT = 8
function ExpBallView:__init()
	self.ui_config = {{"uis/views/mainui_prefab", "ExpBallPanel"}}
	self.is_modal = true
	self.is_any_click_close = true
end

function ExpBallView:__delete()

end

function ExpBallView:ReleaseCallBack()

end

function ExpBallView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["OutBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.node_list["WantReceive"].button:AddClickListener(BindTool.Bind(self.OnWantReceive, self)) --要领取打开充值界面
	self.node_list["Receive"].button:AddClickListener(BindTool.Bind(self.OnReceive, self))

	self:FlushContent()
end

function ExpBallView:CloseWindow()
	self:Close()
end

function ExpBallView:CloseCallBack()
end

function ExpBallView:OpenCallBack()
	TaskCtrl.Instance:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_GET_INFO)
end

function ExpBallView:OnFlush()
	self:FlushContent()
end

function ExpBallView:FlushContent()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local cfg_vip_level = TaskData.Instance:GetFreeVipLevel()
	local str = ""
	if cfg_vip_level then
		if vip_level >= cfg_vip_level then
			str = Language.Task.ExpBallText2
			-- self.node_list["OutBtn"]:SetActive(false)
			self.node_list["WantReceive"]:SetActive(false)
			self.node_list["Receive"]:SetActive(true)
		else
			str = string.format(Language.Task.ExpBallText1, TaskData.Instance:GetFreeVipLevel())
			-- self.node_list["OutBtn"]:SetActive(true)
			self.node_list["WantReceive"]:SetActive(true)
			self.node_list["Receive"]:SetActive(false)
		end
		self.node_list["Text"].text.text = str
	end
	local task_info = TaskData.Instance:GetDailyTaskInfo()
	if task_info then
		self.node_list["Exp"].text.text = string.format(Language.Task.ExpBallExpNum, task_info.daily_task_exp_ball_exp)
	end
end

function ExpBallView:OnWantReceive()
	self:CloseWindow()
	ViewManager.Instance:Open(ViewName.VipView)
end

function ExpBallView:OnReceive()
	TaskCtrl.Instance:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_FETCH_EXP_BALL_REWARD)
	self:CloseWindow()
end