KFArenaVictoryView = KFArenaVictoryView or BaseClass(BaseView)

function KFArenaVictoryView:__init(instance)
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/arena_prefab", "ArenaVictory"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function KFArenaVictoryView:__delete()
end

function KFArenaVictoryView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function KFArenaVictoryView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.uplevel = nil
	self.guanghui = nil
	self.exp = nil
end

function KFArenaVictoryView:OpenCallBack()
	self:Flush()
end

function KFArenaVictoryView:OnFlush()
	local result = KFArenaData.Instance:GetFightResult()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local user_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = PlayerData.Instance:GetFBExpByLevel(user_vo.level)
	local reward_exp = exp * cfg.exp_factor_win
	local reward_guanghui =  cfg.win_add_guanghui
	self.node_list["Txt_Reward"]:SetActive(false)
	-- self.node_list["Txt_Reward"].text.text = Language.KFArena.ExChangeType
	-- local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[TabIndex.exchange_hunjing])
	-- self.node_list["Icon_coin"].image:LoadSprite(bundle, asset .. ".png")
	-- self.node_list["Icon_coin"].image:SetNativeSize()
	if result then
		if result.rank_up == 0 then
			self.node_list["JiFen"].text.text = Language.KFArena.RankNoChange
			self.node_list["TxtUpLevel"]:SetActive(false)
		else
			self.node_list["TxtUpLevel"].text.text = "+" .. result.rank_up
		end
		self.node_list["TxtReward"].text.text = "+" .. reward_guanghui
		self.node_list["TxtExp"].text.text = "+" .. reward_exp
	end
end

function KFArenaVictoryView:OnClick()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end