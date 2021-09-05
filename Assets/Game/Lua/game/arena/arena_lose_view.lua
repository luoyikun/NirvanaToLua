ArenaLoseView = ArenaLoseView or BaseClass(BaseView)

function ArenaLoseView:__init(instance)
	self.ui_config = {{"uis/views/arena_prefab", "ArenaLose"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function ArenaLoseView:__delete()

end

function ArenaLoseView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ArenaLoseView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.uplevel = nil
	self.guanghui = nil
	self.exp = nil
end

function ArenaLoseView:OpenCallBack()
	self:Flush()
end

function ArenaLoseView:OnFlush()
	local result = ArenaData.Instance:GetFightResult()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local user_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = PlayerData.Instance:GetFBExpByLevel(user_vo.level)
	local reward_exp = exp * cfg.exp_factor_lose
	local reward_guanghui =  cfg.lose_add_guanghui
	if result then
		self.node_list["TxtUpLevel"].text.text = "+" .. result.rank_up
		self.node_list["TxtReward"].text.text = "+" .. reward_guanghui
		self.node_list["TxtExp"].text.text = "+" .. reward_exp
	end
end

function ArenaLoseView:OnClick()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end