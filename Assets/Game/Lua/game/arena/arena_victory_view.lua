ArenaVictoryView = ArenaVictoryView or BaseClass(BaseView)

function ArenaVictoryView:__init(instance)
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/arena_prefab", "ArenaVictory"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function ArenaVictoryView:__delete()
end

function ArenaVictoryView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ArenaVictoryView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.uplevel = nil
	self.guanghui = nil
	self.exp = nil
end

function ArenaVictoryView:OpenCallBack()
	self:Flush()
end

function ArenaVictoryView:OnFlush()
	local result = ArenaData.Instance:GetFightResult()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local user_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = PlayerData.Instance:GetFBExpByLevel(user_vo.level)
	local reward_exp = exp * cfg.exp_factor_win
	local reward_guanghui =  cfg.win_add_guanghui
	if result then
		self.node_list["TxtUpLevel"].text.text = "+" .. result.rank_up
		self.node_list["TxtReward"].text.text = "+" .. reward_guanghui
		self.node_list["TxtExp"].text.text = "+" .. reward_exp
	end
end

function ArenaVictoryView:OnClick()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end