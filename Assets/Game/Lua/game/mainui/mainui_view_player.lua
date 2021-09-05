require("game/mainui/mainui_activity_preview")

MainUIViewPlayer = MainUIViewPlayer or BaseClass(BaseRender)

local EffectType = {
	ADD_GONGJI = 0,
	ADD_FANGYU = 2,
	ADD_BAOJI = 3,
	ADD_EXP = 9001,
	ADD_WORLD_EXP = 9004,
	BLOOD = 1006,
	DIZZY = 1109,
	REDUCE_GONGJI = 1104,
	REDUCE_FANGYU = 1103,
	REDUCE_SPEED = 1106,
	ADD_GONGJI_MARRY = 9007,
}

function MainUIViewPlayer:__init()
	local CHARGE_ICON_GROUP = {
		--{name = "firstchargeview", is_tween = false, icon = "Icon_System_firstcharge", remind = RemindName.RechargeGroud, guide = GuideUIName.MainUIFirstCharge, func = BindTool.Bind(self.IsOpenRechargeFirst, self), call = BindTool.Bind(self.OpenFirstCharge, self)},
		{name = "Charge", is_tween = false, icon = "Icon_System_Deposit", remind = RemindName.RechargeAndVIP, guide = GuideUIName.MainUIRank, func = BindTool.Bind(self.IsOpenRecharge, self), call = BindTool.Bind(self.OpenRecharge, self)},
		{name = "daily_charge", is_tween = false, icon = "Icon_System_Daily_Charge", remind = RemindName.DailyCharge,guide = GuideUIName.MainUIDailyCharge, func = BindTool.Bind(self.IsOpenRechargeDaily, self), call = BindTool.Bind(self.OpenDailyCharge, self)},
		{name = "leichong", is_tween = false, icon = "Icon_System_LeiJiRecharge", func = BindTool.Bind(self.IsOpenRechargeLeiJi, self), call = BindTool.Bind(self.OpenLeiJiChargeView, self)},
		{name = "leiji_daily", is_tween = false, icon = "Icon_System_LeiJiDaily", remind = RemindName.DailyLeiJi, func = BindTool.Bind(self.IsOpenDailyLeiJi, self), call = BindTool.Bind(self.OpenLeiJiDaily, self)},
		{name = "reset_double_chongzhi_view", is_tween = false, icon = "Icon_System_PuTianTongQing", remind = RemindName.ResetDoubleChongzhi, func = BindTool.Bind(self.IsOpenPuTianTongQing, self), call = BindTool.Bind(self.OpenPuTianTongQing, self)},
		--{name = "jubaopen",icon = "Icon_System_Treasure_Bowl", remind = RemindName.JuBaoPen, func = BindTool.Bind(self.IsOpenJuBaoPen, self), call = BindTool.Bind(self.OpenJuBaoPen, self)},
	}

	self.is_show_marrbtn = true
	self.charge_icon_group = MainuiIconGroup.New()
	self.charge_icon_group:Init(self.node_list["ChargeButtonGroup"], CHARGE_ICON_GROUP, MAIN_UI_ICON_TYPE.NORMAL)

	self.act_preview_view = MainUiActivityPreview.New(ViewName.MainUIActivityPreview)

	self.hp_slider_top = self.node_list["HPTop"].slider
	self.hp_slider_bottom = self.node_list["HPBottom"].slider

	self.node_list["ButtonHead"].button:AddClickListener(BindTool.Bind(self.OnClickPlayer, self))
	self.node_list["BtnAddBuff"].button:AddClickListener(BindTool.Bind(self.OnClickBuff, self))
	self.node_list["ButtonMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnTeamMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnGuildMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnAllMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnColorMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnSreverMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	self.node_list["BtnHatredMode"].button:AddClickListener(BindTool.Bind(self.OpenModeList, self))
	if IS_AUDIT_VERSION then
		self.node_list["BtnVIP"]:SetActive(false)
	else
		self.node_list["BtnVIP"].button:AddClickListener(BindTool.Bind(self.OpenVip, self))
	end
	self.node_list["BtnHpBag"].button:AddClickListener(BindTool.Bind(self.OpenHpBag, self))
	self.node_list["ButtonInvest"].button:AddClickListener(BindTool.Bind(self.OpenInvest, self))
	self.node_list["ButtonMarryMe"].button:AddClickListener(BindTool.Bind(self.OnMarryMe, self))
	self.node_list["ButtonMarryMe"]:SetActive(false)
	self.node_list["ButtonPerfectLove"].button:AddClickListener(BindTool.Bind(self.OnMarryPerfectLove, self))
	self.node_list["ChargeBtn"].button:AddClickListener(BindTool.Bind(self.OpenRecharge, self))
	self.node_list["ButtonPerfectLove"]:SetActive(false)
	-- 属性事件处理
	self.attr_handlers = {
		vip_level = BindTool.Bind1(self.OnVipLevelChanged, self),
		capability = BindTool.Bind1(self.OnFightPowerChanged, self),
		level = BindTool.Bind1(self.OnLevelChanged, self),
		hp = BindTool.Bind1(self.OnHPChanged, self),
		max_hp = BindTool.Bind1(self.OnHPChanged, self),
		gold = BindTool.Bind1(self.OnGoldChanged, self),
		bind_gold = BindTool.Bind1(self.OnBindGoldChanged, self),
	}

	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.head_change = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE, BindTool.Bind(self.OnHeadChange, self))
	self.effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE, BindTool.Bind(self.OnFightEffectChange, self))
	self.temp_head_change = GlobalEventSystem:Bind(ObjectEventType.TEMP_HEAD_CHANGE, BindTool.Bind(self.ChangeTempHead, self))
	self.show_or_hide_other_btn =  GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.SwitchButtonState, self))

	self:Flush()
end

function MainUIViewPlayer:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
	self.player_data_change_callback = nil

	if self.charge_icon_group then
		self.charge_icon_group:DeleteMe()
		self.charge_icon_group = nil
	end

	if self.act_preview_view then
		self.act_preview_view:DeleteMe()
		self.act_preview_view = nil
	end

	if self.head_change ~= nil then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end

	if self.temp_head_change ~= nil then
		GlobalEventSystem:UnBind(self.temp_head_change)
		self.temp_head_change = nil
	end

	if self.effect_change ~= nil then
		GlobalEventSystem:UnBind(self.effect_change)
		self.effect_change = nil
	end

	if self.effec_change ~= nil then
		GlobalEventSystem:UnBind(self.effec_change)
		self.effec_change = nil
	end
	if self.show_or_hide_other_btn ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_btn)
		self.show_or_hide_other_btn = nil
	end

	self:StopTempVipCountDown()

	if self.image_double then
		if self.image_double.gameObject then
			ResMgr:Destroy(self.image_double.gameObject)
		end
		self.image_double = nil
	end
	self.btn_charge = nil
	self.double_shake_obj = nil
	if self.delay_double_shake then
		GlobalTimerQuest:CancelQuest(self.delay_double_shake)
		self.delay_double_shake = nil
	end
	if self.runquest_double_shake then
		GlobalTimerQuest:CancelQuest(self.runquest_double_shake)
		self.runquest_double_shake = nil
	end
end

function MainUIViewPlayer:OnFlush()
	-- 首次刷新数据
	self:OnFightPowerChanged()
	self:OnLevelChanged()
	self:OnHPChanged()
	self:OnVipLevelChanged()
	self:OnGoldChanged()
	self:OnBindGoldChanged()
	self:OnHeadChange()
	self:RoleChangeProf()
	local mode = Scene.Instance:GetMainRole().vo.attack_mode
	self:UpdateAttackMode(mode)
	self:OnFightEffectChange(true)
	self:IsOnCrossServerAttackMode()
end

function MainUIViewPlayer:FlushSetActiveMaayMe(bool)
	if nil ~= bool then
		self.is_show_marrbtn = bool
	end
	if not self.is_show_marrbtn then
		self.node_list["ButtonMarryMe"]:SetActive(false)
		return
	end
	RemindManager.Instance:Fire(RemindName.MainMarryme)
	if RemindManager.Instance:RemindToday(RemindName.MainMarryme) then
		if self.node_list["MarryMeEffect"] then
			self.node_list["MarryMeEffect"]:SetActive(false)
		end
	end


	RemindManager.Instance:Fire(RemindName.MainPerfectLove)
	if RemindManager.Instance:RemindToday(RemindName.MainPerfectLove) then
		if self.node_list["PerfectLoveEffect"] then
			self.node_list["PerfectLoveEffect"]:SetActive(false)
		end
	end
	if ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.MARRY_ME) and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.MARRY_ME) and self.is_show_marrbtn then
		self.node_list["ButtonMarryMe"]:SetActive(true)
	else
		self.node_list["ButtonMarryMe"]:SetActive(false)
	end
	if ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) and MarriageData.Instance:CheckIsMarry() then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI, RA_PERFECT_OPERA_TYPE.RA_MARRYME_REQ_INFO)
		self.node_list["ButtonPerfectLove"]:SetActive(true)
	else
		self.node_list["ButtonPerfectLove"]:SetActive(false)
	end

	-- 结婚后不需要显示这个按钮
	if MarriageData.Instance:CheckIsMarry() then
		self.node_list["ButtonMarryMe"]:SetActive(false)
	end
end

function MainUIViewPlayer:FlushIconGroup()
	self.charge_icon_group:FlushIconGroup()
end

function MainUIViewPlayer:IsOpenRecharge()
	-- local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	local open = OpenFunData.Instance:CheckIsHide("chongzhi")
	return open and is_first
end

function MainUIViewPlayer:IsOpenRechargeDaily()
	-- local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	local open = OpenFunData.Instance:CheckIsHide("daily_charge")
	return open and is_first
end

function MainUIViewPlayer:IsOpenRechargeLeiJi()
	-- local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	local open = OpenFunData.Instance:CheckIsHide("leichong")
	return open and is_first
end

function MainUIViewPlayer:IsPerfectLoverEffect(bool)
	if bool and self.node_list["PerfectLoveEffect"] then
		self.node_list["PerfectLoveEffect"]:SetActive(false)
	end
end

function MainUIViewPlayer:IsOpenRechargeFirst()
	return DailyChargeData.Instance:GetThreeRechargeOpen(1)
end

function MainUIViewPlayer:IsOpenDailyLeiJi()
	-- local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
	local flag = DailyChargeData.Instance:GetDailyLeiJiGetFlag()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	local open = OpenFunData.Instance:CheckIsHide("leiji_daily")
	local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if active_reward_info and active_reward_info.reward_state and time_day > 0 then
		flag = true
	end

	return open and is_first and flag
end

--普天同庆是否开启
function MainUIViewPlayer:IsOpenPuTianTongQing()
	return ResetDoubleChongzhiData.Instance:IsShowPuTianTongQing()
end

function MainUIViewPlayer:ShowDoubleIcon(is_show)
	if not self.charge_icon_group then return end

	if nil == self.image_double and is_show then
		self.btn_charge = self.charge_icon_group:GetIconByName("Charge")
		if not self.btn_charge then return end

		self.image_double = U3DObject(GameObject.New("Image_Double"), nil, self)
		self.image_double.gameObject.layer = UnityEngine.LayerMask.NameToLayer("UI")
		self.image_double.transform:SetParent(self.btn_charge.root_node.transform, false)

		local image = self.image_double.gameObject:AddComponent(typeof(UnityEngine.UI.Image))
		local bundle, asset = ResPath.GetRestDoubleChongZhiRes("double_chong_zhi")
		self.image_double.image:LoadSpriteAsync(bundle, asset, function()
			self.image_double.image:SetNativeSize()

			local rect = self.image_double.rect
			rect.anchorMin = Vector2(0, 0)
			rect.anchorMax = Vector2(0, 0)
			rect.anchoredPosition3D = Vector3(26, 60, 0)
		end)
	end

	if nil == self.double_shake_obj and is_show then
		self.btn_charge = self.charge_icon_group:GetIconByName("Charge")
		if not self.btn_charge then return end
		local async_loader = AllocAsyncLoader(self, "rest_double_chong_zhi_shake")
		async_loader:Load("uis/views/mainui_prefab", "RestDoubleChongZhiShake", function(obj)
			if not IsNil(obj) then
				self.double_shake_obj = obj
				self.double_shake_obj.transform:SetParent(self.btn_charge.root_node.transform, false)
				self:DoubleShakeTime(10)
				if nil ~= self.runquest_double_shake then
					GlobalTimerQuest:CancelQuest(self.runquest_double_shake)
					self.runquest_double_shake = nil
				end
				self.runquest_double_shake = GlobalTimerQuest:AddRunQuest(function()			--每隔600s抖动
					self:DoubleShakeTime(10)
				end, 600)
			end
		end)
	end

	if self.image_double then
		self.image_double:SetActive(is_show)
	end

	if self.double_shake_obj and is_show then
		self:DoubleShakeTime(10)
		if nil ~= self.runquest_double_shake then
			GlobalTimerQuest:CancelQuest(self.runquest_double_shake)
			self.runquest_double_shake = nil
		end
		self.runquest_double_shake = GlobalTimerQuest:AddRunQuest(function()			--每隔600s抖动
			self:DoubleShakeTime(10)
		end, 600)
	elseif self.double_shake_obj and not is_show then
		self.double_shake_obj:SetActive(false)
	end
end

function MainUIViewPlayer:DoubleShakeTime(time)
	self.double_shake_obj:SetActive(true)
	if nil ~= self.delay_double_shake then
		GlobalTimerQuest:CancelQuest(self.delay_double_shake)
		self.delay_double_shake = nil
	end
	self.delay_double_shake = GlobalTimerQuest:AddDelayTimer(function()
		self.double_shake_obj:SetActive(false)
	end, time)
end

function MainUIViewPlayer:IsOpenJuBaoPen()
	return JuBaoPenData.Instance:CheckIsShow()
end

--充值
function MainUIViewPlayer:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--首充
function MainUIViewPlayer:OpenDailyCharge()
	ViewManager.Instance:Open(ViewName.DailyChargeView)
end

function MainUIViewPlayer:OpenLeiJiChargeView()
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

--首充
function MainUIViewPlayer:OpenFirstCharge()
	DailyChargeData.Instance:SetShowPushIndex(1)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

--每日累充
function MainUIViewPlayer:OpenLeiJiDaily()
	ViewManager.Instance:Open(ViewName.LeiJiDailyView)
end

--打开普天同庆
function MainUIViewPlayer:OpenPuTianTongQing()
	if ResetDoubleChongzhiData.Instance then
		ResetDoubleChongzhiData.Instance:SetNum(0)
		RemindManager.Instance:Fire(RemindName.ResetDoubleChongzhi)
	end
	ViewManager.Instance:Open(ViewName.ResetDoubleChongzhiView)
end

function MainUIViewPlayer:OpenJuBaoPen()
	ViewManager.Instance:Open(ViewName.JuBaoPen)
end

-- 角色面板
function MainUIViewPlayer:OnClickPlayer()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_intro)
	TitleCtrl.Instance:SendCSGetTitleList()
end

function MainUIViewPlayer:UpdateAttackMode(mode)
	local attack_modes_node_list = {
		[GameEnum.ATTACK_MODE_PEACE] = self.node_list["PeaceMode"],
		[GameEnum.ATTACK_MODE_TEAM] = self.node_list["BtnTeamMode"],
		[GameEnum.ATTACK_MODE_GUILD] = self.node_list["BtnGuildMode"],
		[GameEnum.ATTACK_MODE_ALL] = self.node_list["BtnAllMode"],
		[GameEnum.ATTACK_MODE_NAMECOLOR] = self.node_list["BtnColorMode"],
		[GameEnum.ATTACK_MODE_SREVER] = self.node_list["BtnSreverMode"],
		[GameEnum.ATTACK_MODE_HATRED] = self.node_list["BtnHatredMode"],
	}
	for k,v in pairs(attack_modes_node_list) do
		attack_modes_node_list[k]:SetActive(k == mode)
	end
end

function MainUIViewPlayer:IsOnCrossServerAttackMode()
	local mode = Scene.Instance:GetMainRole().vo.attack_mode
	if not IS_ON_CROSSSERVER and GameEnum.ATTACK_MODE_SREVER == mode then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	end
end

function MainUIViewPlayer:OnClickBuff()
	if ViewManager.Instance:IsOpen(ViewName.BuffPandectTips) then
		ViewManager.Instance:Close(ViewName.BuffPandectTips)
	else
		ViewManager.Instance:Open(ViewName.BuffPandectTips)
	end
end

function MainUIViewPlayer:CloseBuff()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function MainUIViewPlayer:OpenModeList()
	-- 一些特殊场景不允许切换攻击模式
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		local scene_type = scene_logic:GetSceneType()
		local scene_id = Scene.Instance:GetSceneId()
		local is_field = (scene_id >= 101 and scene_id <= 109 and scene_id ~= 103)
		local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if (scene_cfg.cant_change_mode and 1 == scene_cfg.cant_change_mode)
			or scene_type == SceneType.LingyuFb
			or scene_type == SceneType.QingYuanFB
			or scene_type == SceneType.HunYanFb
			or scene_type == SceneType.HotSpring
			or scene_type == SceneType.ZhongKui
			or scene_type == SceneType.GuildStation
			or scene_type == SceneType.QunXianLuanDou
			or scene_type == SceneType.Question
			or scene_type == SceneType.ClashTerritory
			or scene_type == SceneType.CrossFB 
			or scene_type == SceneType.ShuiJing 
			or scene_type == SceneType.CrossGuild
			or scene_type == SceneType.GuildMiJingFB 
			or scene_type == SceneType.KF_Borderland 
			or scene_type == SceneType.CrossLieKun_FB 
			-- or (scene_id >= 9040 and scene_id <= 9049)
			-- or BossData.Instance:IsMikuPeaceBossScene(scene_id)
			-- or BossData.Instance:IsActiveBossScene(scene_id)
			or is_field
			or BossData.Instance:IsWorldBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.AttackMode)
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
			if scene_type == SceneType.KF_Borderland then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CannotChangeMode2)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CannotChangeMode)
			end
			return
		end
	end
	ViewManager.Instance:Open(ViewName.AttackMode)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, true)
end

--VIP
function MainUIViewPlayer:OpenVip()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
end

--投资计划
function MainUIViewPlayer:OpenInvest()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView, 3)
end

function MainUIViewPlayer:OnMarryMe()
	ViewManager.Instance:Open(ViewName.MarryMe)
	RemindManager.Instance:SetRemindToday(RemindName.MainMarryme)
	if self.node_list["MarryMeEffect"] then
		self.node_list["MarryMeEffect"]:SetActive(false)
	end
end

function MainUIViewPlayer:OnMarryPerfectLove()
	ViewManager.Instance:Open(ViewName.PerfectLover)
	RemindManager.Instance:SetRemindToday(RemindName.MainPerfectLove)
	if self.node_list["PerfectLoveEffect"] then
		self.node_list["PerfectLoveEffect"]:SetActive(false)
	end
end

-- function MainUIViewPlayer:OnMarryBiaobai()
-- 	ViewManager.Instance:Open(ViewName.BiaoBaiQiang)
-- end

function MainUIViewPlayer:OpenActivityPreView()
	self.act_preview_view:Open()
end

function MainUIViewPlayer:CloseActivityPreView()
	self.act_preview_view:Close()
end

-- 血包
function MainUIViewPlayer:OpenHpBag()
	HpBagData.Instance:SetIsShowRepdt(false)
	RemindManager.Instance:Fire(RemindName.HpBag)
	ViewManager.Instance:Open(ViewName.HpBag)
end

function MainUIViewPlayer:PlayerDataChangeCallback(attr_name, value, old_value)
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end

function MainUIViewPlayer:OnFightPowerChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtNumber"].text.text = vo.capability
end

function MainUIViewPlayer:OnLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local str = Language.Mainui.Level2
	local zhuan = math.floor(vo.prof / 10)
	
	self.node_list["TxtLevel"].text.text = string.format(str, vo.level, zhuan)
end

function MainUIViewPlayer:RoleChangeProf()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local res_id = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(base_prof, zhuan)
	if self.node_list["ProfImage"] and res_id then
		local bundle,asset = ResPath.GetTransferNameIcon(res_id)
		self.node_list["ProfImage"].image:LoadSpriteAsync(bundle, asset)
	end
	self:OnLevelChanged()
end

function MainUIViewPlayer:OnHPChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.max_hp ~= nil and vo.max_hp > 0 then
		self:SetHpPercent(vo.hp / vo.max_hp)
	end
	self.node_list["TxtHp"].text.text = CommonDataManager.ConverMoney2(vo.hp)
	local limit_hp = vo.max_hp * 0.2
	self.node_list["Effect"]:SetActive(vo.hp <= limit_hp)
	HpBagData.Instance:SetIsShowRepdt(true)
	RemindManager.Instance:Fire(RemindName.HpBag)
end

function MainUIViewPlayer:OnVipLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- self.node_list["TxtVIPLevel"].text.text = string.format("VIP%s", vo.vip_level)
	self.node_list["TxtVIPLevel"].text.text = vo.vip_level
	if ForgeData.Instance:IsSendStoneMsg(vo.vip_level) then
		ForgeCtrl.Instance:SendStoneInfo()
	end
	-- local bundle,asset = ResPath.GetVipLevelIcon(vo.vip_level)
	-- self.node_list["ImgVIP"].image:LoadSpriteAsync(bundle, asset .. ".png")
	-- self.node_list["TxtVIPLevel"]:SetActive(false)
end

function MainUIViewPlayer:OnGoldChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = CommonDataManager.ConverMoney(vo.gold)
end

function MainUIViewPlayer:OnBindGoldChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = CommonDataManager.ConverMoney(vo.bind_gold)
end

-- 设置目标血条
function MainUIViewPlayer:SetHpPercent(percent)
	local value_hp = percent or 0
	self.hp_slider_top.value = value_hp
	self.hp_slider_bottom:DOValue(value_hp, 0.8, false)
end

-- 头像更换
function MainUIViewPlayer:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Main) or not MainUICtrl.Instance:IsLoaded() then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = vo.role_id or 0
	local cross_before_id = CrossServerData.Instance:GetRoleId()
	if cross_before_id > 0 and role_id ~= cross_before_id then
		role_id = cross_before_id
	end

	local raw_image_obj = self.node_list["RawPortrait"]
	local image_obj = self.node_list["Portrait"]
	local sex = vo.sex
	local prof = PlayerData.Instance:GetRoleBaseProf()
	AvatarManager.Instance:SetAvatar(role_id, raw_image_obj, image_obj, sex, prof, false)
end

function MainUIViewPlayer:ChangeTempHead(path)
	if nil == path then
		return
	end
	self.node_list["Portrait"].gameObject:SetActive(false)
	self.node_list["RawPortrait"].gameObject:SetActive(true)
	self.node_list["RawPortrait"].raw_image:LoadURLSprite(path, function()
	end)
end

function MainUIViewPlayer:OnFightEffectChange(is_main_role)
	if is_main_role then
		local _, buff_num = FightData.Instance:GetMainRoleShowEffect()
		self.node_list["TxtBuffCount"].text.text =  "x" .. buff_num
	end
end

function MainUIViewPlayer:OnClickButtonDaily()
	-- ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

function MainUIViewPlayer:ShowRightBtns(value)
	--self.node_list["BtnPlayerRigehtBtns"]:SetActive(value)
end

function MainUIViewPlayer:SwitchButtonState(state)
	ViewManager.Instance:Close(ViewName.AttackMode)
end

function MainUIViewPlayer:ShowTempVip(enable)
	self.node_list["NodeTempVip"]:SetActive(enable)
end

function MainUIViewPlayer:SetTempVipDes(des)
	self.node_list["TxtVIPDes"].text.text = des
end

function MainUIViewPlayer:StopTempVipCountDown()
	if self.temp_vip_count_down then
		CountDown.Instance:RemoveCountDown(self.temp_vip_count_down)
		self.temp_vip_count_down = nil
	end
end

function MainUIViewPlayer:StarTempVipCountDown(time)
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StopTempVipCountDown()
			self:ShowTempVip(false)
			return
		end
		local server_time = TimeCtrl.Instance:GetServerTime()
		local temp_vip_end_time = VipData.Instance:GetTempVipEndTime()
		local diff_time_str = TimeUtil.FormatSecond(temp_vip_end_time - server_time, 2)
		local des = string.format(Language.Vip.TempVipDes, diff_time_str)
		self:SetTempVipDes(des)
	end
	self.temp_vip_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
end

function MainUIViewPlayer:FlushTempVip()
	--刷新临时vip
	self:StopTempVipCountDown()
	local is_in_temp_vip = VipData.Instance:GetIsInTempVip()
	self:ShowTempVip(is_in_temp_vip)
	if is_in_temp_vip then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local temp_vip_end_time = VipData.Instance:GetTempVipEndTime()
		local diff_time_str = TimeUtil.FormatSecond(temp_vip_end_time - server_time, 2)
		local des = string.format(Language.Vip.TempVipDes, diff_time_str)
		self:SetTempVipDes(des)
		self:StarTempVipCountDown(temp_vip_end_time - server_time)
	end
end
