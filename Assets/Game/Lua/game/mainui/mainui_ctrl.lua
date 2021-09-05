require("game/mainui/mainui_data")
require("game/mainui/mainui_view")
require("game/mainui/mainui_view_attackmode")				--攻击模式界面
require("game/mainui/mainui_line_view")						--分线界面
require("game/mainui/mainui_activity_hall_view")						--活动卷轴
require("game/mainui/mainui_activity_hall_data")						--活动卷轴
require("game/mainui/main_collectgarbage_text")
require("game/mainui/exp_ball_view")

-- 登录
MainUICtrl = MainUICtrl or BaseClass(BaseController)

function MainUICtrl:__init()
	if MainUICtrl.Instance ~= nil then
		print_error("[MainUICtrl] attempt to create singleton twice!")
		return
	end
	MainUICtrl.Instance = self

	self.view = MainUIView.New(ViewName.Main)
	self.data = MainUIData.New()

	self.attack_mode_view = ActtackModeView.New(ViewName.AttackMode)
	self.line_view = MainUILineView.New(ViewName.LineView)
	self.activity_hall = MainuiActivityHallView.New(ViewName.ActivityHall)
	self.activity_data = MainuiActivityHallData.New()
	self.exp_ball_view = ExpBallView.New(ViewName.ExpBall)

	self:RegisterAllProtocols()
end

function MainUICtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.attack_mode_view then
		self.attack_mode_view:DeleteMe()
		self.attack_mode_view = nil
	end

	if self.line_view then
		self.line_view:DeleteMe()
		self.line_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
	if self.activity_data then
		self.activity_data:DeleteMe()
		self.activity_data = nil
	end

	if self.activity_hall then
		self.activity_hall:DeleteMe()
		self.activity_hall = nil
	end

	if self.exp_ball_view then
		self.exp_ball_view:DeleteMe()
		self.exp_ball_view = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.collectgarbage_view then
		self.collectgarbage_view:DeleteMe()
		self.collectgarbage_view = nil
	end

	MainUICtrl.Instance = nil
end


function MainUICtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSetAttackMode, "OnSetAttackMode")
	self:RegisterProtocol(SCContinueKillInfo, "OnContinueKillInfo")
	self:RegisterProtocol(CSSetAttackMode)
end

function MainUICtrl:OnSetAttackMode(protocol)
	if protocol.result ~= GameEnum.SET_ATTACK_MODE_SUCC then
		local str = Language.Mainui.AttackMode[protocol.result]
		TipsCtrl.Instance:ShowSystemMsg(str)
		return
	end

	local mode = protocol.attack_mode
	local obj_id = protocol.obj_id
	-- 自己的攻击模式改变
	if obj_id == Scene.Instance:GetMainRole():GetObjId() then
		self.view:UpdateAttackMode(mode)
	end

	--TODO 其他人攻击模式改变,改变vo即可
	for k,v in pairs(Scene.Instance.obj_list) do
		if v.obj_type == SceneObjType.Role or v.obj_type == SceneObjType.MainRole and v:GetObjId() == obj_id then
			v:SetAttackMode(mode)
			v:SetRoleVisible()
			v:SetFollowLocalPosition()
			if not Scene.Instance.is_pingbi_other_role and Scene.Instance.is_pingbi_friend_role then
				GlobalEventSystem:Fire(SettingEventType.SYSTEM_SETTING_CHANGE, SETTING_TYPE.SHIELD_SAME_CAMP, true)
			end
		end
	end
end

function MainUICtrl:OnContinueKillInfo(protocol)
	TipsCtrl.Instance:OpenDoubleHitView(protocol)
end

function MainUICtrl:GetView()
	return self.view
end

function MainUICtrl:GetData()
	return self.data
end

function MainUICtrl:ShowIconGroup2Effect(name, flag)
	return self.view:ShowIconGroup2Effect(name, flag)
end

function MainUICtrl:IsLoaded()
	return self.view:IsLoaded()
end

function MainUICtrl:GetTaskView()
	return self.view.task_view
end

function MainUICtrl:GetTargetView()
	return self.view.target_view
end

function MainUICtrl:GetMenuToggleState()
	return self.view:GetMenuToggleState()
end

function MainUICtrl:GetFightToggleState()
	return self.view:GetFightToggleState()
end

function MainUICtrl:GetJoystickRegion()
	return self.view:GetJoystickRegion()
end

function MainUICtrl:GetSkillButtonPosition()
	if IS_AUDIT_VERSION then
		return self.view:GetMainAuditSkillButtonPosition()
	else
		return self.view:GetSkillButtonPosition()
	end
end

function MainUICtrl:GetMainChatView()
	return self.view:GetMainChatView()
end

function MainUICtrl:FlushView(key, value_t)
	if self.view and self.view:IsOpen() then
		self.view:Flush(key, value_t)
	end
end

--主界面聊天小图标显示或隐藏
function MainUICtrl:FlushTipsIcon(icon_name, is_active, param_list)
	if self.view and self.view:IsOpen() then
		self.view:FlushTipsIcon(icon_name, is_active, param_list)
	end
end

function MainUICtrl:OnTaskRefreshActiveCellViews()
	if self.view and self.view:IsOpen() then
		self.view:OnTaskRefreshActiveCellViews()
	end
end

function MainUICtrl:SendSetAttackMode(mode, is_fanji)
	print('设置攻击模式', mode)
	if mode ~= 0 then
		local scene_id = Scene.Instance:GetSceneId()
		if scene_id == 8050 or scene_id == 520 then
			TipsCtrl.Instance:ShowSystemMsg("当前场景不能PvP")
			return
		end
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSSetAttackMode)
	protocol.mode = mode
	protocol.is_fanji = is_fanji or 0
	protocol:EncodeAndSend()
end

function MainUICtrl:SetBeAttackedIcon(role_vo)
	self.view:Flush("be_atk", {role_vo})
end

-- 自动采集
function MainUICtrl:AutoGather(target, end_type, task_id)
	if self.view and self.view.task_view then
		self.view.task_view:MoveToTarget(target, end_type, task_id)
	end
end

function MainUICtrl:SetViewState(enable)
	if self.view and self.view:IsOpen() then
		self.view:SetViewState(enable)
	end
end

function MainUICtrl:ChangeFightStateEnable(enable)
	if self.view and self.view:IsOpen() then
		self.view:ChangeFightStateEnable(enable)
	end
end

function MainUICtrl:ShakeExpBottle(enable)
	if self.view:IsOpen() then
		self.view:SetExpBottleShakeState(enable)
	end
end

function MainUICtrl:ShowEXPBottleText(num)
	if self.view:IsOpen() then
		self.view:ShowEXPBottleText(num)
	end
end

function MainUICtrl:CloseExpBottleText()
	if self.view:IsOpen() then
		self.view:CloseExpBottleText()
	end
end

function MainUICtrl:FlushActivityRed()
	self.activity_hall:FlushRankActivityRed()
end

function MainUICtrl:FlushActivity()
	self.activity_hall:FlushRankActivity()
end

function MainUICtrl:CloseActivityHallView()
	if self.activity_hall:IsOpen() then
		self.activity_hall:Close()
	end
end

function MainUICtrl:CreateMainCollectgarbageText()
	if self.collectgarbage_view == nil then
		self.collectgarbage_view = MainCollectgarbageText.New()
		self.collectgarbage_view:Open()
	else
		self.collectgarbage_view:Close()
		self.collectgarbage_view:DeleteMe()
		self.collectgarbage_view = nil
	end
end

function MainUICtrl:ChangeFunctionTrailer(state)
	if self.view then
		self.view:ChangeFunctionTrailer(state)
	end
end

function MainUICtrl:ShowQingGongGuideSkillEffect(is_show, is_qinggong_down)
	if self.view then
		self.view:ShowQingGongGuideSkillEffect(is_show, is_qinggong_down)
	end
end

function MainUICtrl:SetJoystickIsShow(is_show)
	if self.view then
		self.view:SetJoystickIsShow(is_show)
	end
end

function MainUICtrl:SetQingGongGuideClickCountDownState(state)
	if self.view then
		self.view:SetQingGongGuideClickCountDownState(state)
	end
end

function MainUICtrl:SetShowExpBottle(bool)
	if self.view:IsOpen() then
		self.view:SetShowExpBottle(bool)
	end
end

function MainUICtrl:LimitAttackMode(limit_list)
	self.attack_mode_view:SetLimitMode(limit_list)
end

function MainUICtrl:RecoverMode()
	self.attack_mode_view:RecoverMode()
end

function MainUICtrl:SetViewHideorShow(view_name, state)
	self.view:SetViewHideorShow(view_name, state)
end

function MainUICtrl:ShowActivitySkill(attach_obj)
	self.view:ShowActivitySkill(attach_obj)

	if type(attach_obj)  == "boolean" and attach_obj == false then
		if CityCombatCtrl.Instance:CheckShowMoBaiSkillIcon() then
			CityCombatCtrl.Instance:ShowMoBaiSkillIcon(true, true)
			return
		end
		if YunbiaoCtrl.Instance:CheckHuSongSkillState() then
			YunbiaoCtrl.Instance:ShowHuSongButton(true, true)
			return
		end
		if GuildCtrl.Instance:CheckGuildYunBiaoState() then
			GuildCtrl.Instance:SetGuildYunbiaoSkillState(true, true)
			return
		end
	end
end

function MainUICtrl:SetvisibleGath()
	if self.view then
		self.view:SetvisibleGath()
	end
end

function MainUICtrl:FlushExpBall()
	self.exp_ball_view:Flush()
	self.view:Flush("ExpBallInfo")
end

function MainUICtrl:CanShowCapChange()
	return self.view:CanShowCapChange()
end

function MainUICtrl:FlushImmortalIcon()
	self.view:FlushImmortalIcon()
end