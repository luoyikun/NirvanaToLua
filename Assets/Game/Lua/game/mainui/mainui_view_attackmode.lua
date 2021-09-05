ActtackModeView = ActtackModeView or BaseClass(BaseView)

function ActtackModeView:__init()
	self.view_layer = UiLayer.MainUIHigh
	self.ui_config = {{"uis/views/mainui_prefab", "AttackModeView"}}
	self.mode_list = {}
	self.limit_list = {}
end

function ActtackModeView:__delete()
	self.mode_list = {}
	self.limit_list = {}
end

function ActtackModeView:OpenCallBack()
	self:FlushLimitAttackMode()
end

function ActtackModeView:LoadCallBack()
	-- 监听UI事件
	self.node_list["BtnPeaceMode"].button:AddClickListener(BindTool.Bind(self.SwitchPeaceMode, self))
	self.node_list["BtnTeamMode"].button:AddClickListener(BindTool.Bind(self.SwitchTeamMode, self))
	self.node_list["BtnGuildMode"].button:AddClickListener(BindTool.Bind(self.SwitchGuildMode, self))
	self.node_list["BtnAllMode"].button:AddClickListener(BindTool.Bind(self.SwitchAllMode, self))
	self.node_list["BtnColorMode"].button:AddClickListener(BindTool.Bind(self.SwitchColorMode, self))
	self.node_list["BtnSreverMode"].button:AddClickListener(BindTool.Bind(self.SwitchSreverMode, self))
	self.node_list["BtnHatredMode"].button:AddClickListener(BindTool.Bind(self.HatredModeMode, self))
	self.node_list["BtnClose"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.CloseMode, self))


	self.mode_list = {
		[GameEnum.ATTACK_MODE_PEACE] = self.node_list["BtnPeaceMode"],
		[GameEnum.ATTACK_MODE_TEAM] = self.node_list["BtnTeamMode"],
		[GameEnum.ATTACK_MODE_GUILD] = self.node_list["BtnGuildMode"],
		[GameEnum.ATTACK_MODE_ALL] = self.node_list["BtnAllMode"],
		[GameEnum.ATTACK_MODE_NAMECOLOR] = self.node_list["BtnColorMode"],
		[GameEnum.ATTACK_MODE_SREVER] = self.node_list["BtnSreverMode"],
		[GameEnum.ATTACK_MODE_HATRED] = self.node_list["BtnHatredMode"],
	}

	self:SetActtackModeNum()
	self:FlushLimitAttackMode()
end

function ActtackModeView:CloseMode()
	self:Close()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

--攻击模式改变
function ActtackModeView:SwitchPeaceMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 4501 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit1)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SwitchTeamMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_TEAM)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SwitchGuildMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 4501 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit3)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SwitchAllMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 4501 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit4)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SwitchColorMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_NAMECOLOR)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SwitchSreverMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_SREVER)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:HatredModeMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_HATRED)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function ActtackModeView:SetActtackModeNum()
	self.node_list["BtnSreverMode"]:SetActive(IS_ON_CROSSSERVER)
end

function ActtackModeView:FlushLimitAttackMode()
	if not self:IsOpen() then return end
	if nil == self.mode_list or nil == next(self.mode_list) then return end
	for k,v in pairs(self.mode_list) do
		for k1,v1 in pairs(self.limit_list) do
			if v1 == k then
				v:SetActive(true)
				break
			end
			v:SetActive(false)
		end
	end
end

function ActtackModeView:SetLimitMode(limit_list)
	self.limit_list = {}
	self.limit_list = TableCopy(limit_list)
end

function ActtackModeView:RecoverMode()
	self:SetLimitMode({GameEnum.ATTACK_MODE_PEACE, GameEnum.ATTACK_MODE_TEAM, GameEnum.ATTACK_MODE_GUILD, GameEnum.ATTACK_MODE_ALL})
end