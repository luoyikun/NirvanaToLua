
MAIN_UI_ICON_TYPE = {
	SMALL = 1,
	NORMAL = 2,
	BIG = 3,
}

local MAIN_UI_ICON_TYPE_ASSET = {
	[MAIN_UI_ICON_TYPE.SMALL] = "MainuiIconSmall",
	[MAIN_UI_ICON_TYPE.NORMAL] = "MainuiIconNormal",
	[MAIN_UI_ICON_TYPE.BIG] = "MainuiIconBig",
}
MOVE_DIS_ISON = true
--------------
--主界面按钮组
--------------
MainuiIconGroup = MainuiIconGroup or BaseClass()

function MainuiIconGroup:__init()
	self.icon_type = MAIN_UI_ICON_TYPE.NORMAL
	self.is_open_fun = false
	self.remind_id_to_index = {}
	self.icon_name_to_index = {}
	self.icon_button_list = {}
	self.icon_cfg_list = {}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.openfun_pause_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_PAUSE, BindTool.Bind(self.OpenFunPause, self))

	self.role_attr_value_change = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	PlayerData.Instance:ListenerAttrChange(self.role_attr_value_change)
end

function MainuiIconGroup:OpenFunPause(state)
	self.is_open_fun = state
end

function MainuiIconGroup:__delete()
	for k,v in pairs(self.icon_button_list) do
		v:DeleteMe()
	end
	self.icon_button_list = nil
	self.icon_name_to_index = nil
	self.remind_id_to_index = nil

	if self.openfun_pause_handle then
		GlobalEventSystem:UnBind(self.openfun_pause_handle)
		self.openfun_pause_handle = nil
	end
	RemindManager.Instance:UnBind(self.remind_change)

	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_value_change)
end

function MainuiIconGroup:Init(parent, icon_cfg, type, init_hide)
	self.parent = parent
	self.icon_cfg = icon_cfg
	self.icon_type = type
	self.init_hide = init_hide
	self:FlushIconGroup()
end

function MainuiIconGroup:FlushIconGroup()
	for i, cfg in ipairs(self.icon_cfg) do
		local fun_is_open = false
		if nil ~= cfg.func then
			fun_is_open = cfg.func()
		end
		if IS_AUDIT_VERSION then
			if cfg.name == "advanced_act" then
				fun_is_open = false
			end
		end
		if fun_is_open then
			if nil ~= self.icon_button_list[i] then
				if self.icon_type == MAIN_UI_ICON_TYPE.NORMAL and cfg.is_tween ~= false then
					self.icon_button_list[i]:SetActive(MOVE_DIS_ISON)
				else
					self.icon_button_list[i]:SetActive(true)
				end
				
				if MOVE_DIS_ISON and not self.is_open_fun then
					self.icon_button_list[i]:SetBtnState(1, true)
				end
				self.icon_button_list[i]:Flush()
			else
				local icon_node = MainuiIcon.New(ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", MAIN_UI_ICON_TYPE_ASSET[self.icon_type]))
				icon_node:SetInstanceParent(self.parent)
				icon_node:InitIcon(cfg, self.icon_type)
				self.icon_button_list[i] = icon_node
				if self.init_hide then
					self.icon_button_list[i]:SetActive(false)
				end
				if not MOVE_DIS_ISON and self.icon_type == MAIN_UI_ICON_TYPE.NORMAL and cfg.is_tween ~= false  then
					self.icon_button_list[i]:SetActive(false)
				end

				if nil ~= cfg.name and "" ~= cfg.name then
					self.icon_name_to_index[cfg.name] = i
				end

				if nil ~= cfg.guide_name and "" ~= cfg.guide_name then
					self.guide_name_to_index[cfg.guide_name] = self.icon_button_list[i]
				end

				if nil ~= cfg.remind and "" ~= cfg.remind then
					self.remind_id_to_index[cfg.remind] = i
					RemindManager.Instance:Bind(self.remind_change, cfg.remind)
					RemindManager.Instance:Bind(self.remind_change, RemindName.MainTop)
				end
				self.icon_button_list[i]:Flush()
			end
		else
			if nil ~= self.icon_button_list[i] then
				self.icon_button_list[i]:SetTimeText("")
				self.icon_button_list[i]:SetActive(false)
			end
		end

		if nil ~= self.icon_button_list[i] and self.icon_button_list[i].root_node then
			self.icon_button_list[i].root_node.transform:SetAsLastSibling()
		end
	end
end

function MainuiIconGroup:RemindChangeCallBack(remind_name, num)
	local index = self.remind_id_to_index[remind_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		if remind_name == RemindName.ShowHuanZhuangShopPoint or remind_name == RemindName.NiChongWoSong or remind_name == RemindName.LoopCharge 
			or remind_name == RemindName.KuFuLiuJie or remind_name == RemindName.SingleChange or remind_name == RemindName.IncreaseCapability 
			or remind_name == RemindName.IncreaseSuperior or remind_name == RemindName.RechargeCapacity or remind_name == RemindName.DisCount
			or remind_name == RemindName.ImmortalCard or remind_name == RemindName.CrazyHappyView then
			self.icon_button_list[index]:ShowEffect(num > 0 and MainUIData.GetIsShowLevelRed(remind_name))
		elseif RemindName.JingCai_Act == remind_name then
			if (DelayRemindList[RemindName.JingCai_Act_Delay] == nil or DelayRemindList[RemindName.JingCai_Act_Delay].delay_timer == nil) and nil ~= self.icon_button_list[index] then
				self.icon_button_list[index]:ShowRemind(num > 0 and MainUIData.GetIsShowLevelRed(remind_name))
			end
		else
			self.icon_button_list[index]:ShowRemind(num > 0 and MainUIData.GetIsShowLevelRed(remind_name))
		end
	end
end

function MainuiIconGroup:OnRoleAttrValueChange(key, new_value, old_value)
	if key == "level" then
		if old_value < COMMON_CONSTS.REMIND_LEVEL and new_value >= COMMON_CONSTS.REMIND_LEVEL then
			for k, v in pairs(self.remind_id_to_index) do
				local num = RemindManager.Instance:GetRemind(k)
				self:RemindChangeCallBack(k, num)
			end
		end
	end
end

function MainuiIconGroup:GetIconByName(icon_name)
	local index = self.icon_name_to_index[icon_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		return self.icon_button_list[index]
	end
end

function MainuiIconGroup:ShowRemind(remind_name, is_show)
	local index = self.remind_id_to_index[remind_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		self.icon_button_list[index]:ShowRemind(is_show)
	end
end

function MainuiIconGroup:ShowXianShiDuiHuan(icon_name, is_show, bundle, asset)
	local index = self.icon_name_to_index[icon_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		self.icon_button_list[index]:ShowXianShiDuiHuan(is_show, bundle, asset)
	end
end

function MainuiIconGroup:ShowEffect(icon_name, is_show)
	local index = self.icon_name_to_index[icon_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		self.icon_button_list[index]:ShowEffect(is_show)
	end
end

function MainuiIconGroup:SetImage(icon_name, image_name)
	local index = self.icon_name_to_index[icon_name]
	if nil ~= index and nil ~= self.icon_button_list[index] then
		self.icon_button_list[index]:SetImage(image_name)
	end
end

function MainuiIconGroup:GetButtonList()
	local data = {}
	local i = 1

	for key, value in pairs(self.icon_cfg) do
		local is_func = false
		if value.func() then
			is_func = true
		end
		if is_func then
			data[i] = self.icon_button_list[key]
			i = i + 1
		end
	end
	return data
end

-------------
--主界面按钮
-------------
MainuiIcon = MainuiIcon or BaseClass(BaseRender)

function MainuiIcon:__init()
end

function MainuiIcon:__delete()
	self:RemoveTimer()
end

function MainuiIcon:OnFlush(param_list)
	if self.types == MAIN_UI_ICON_TYPE.NORMAL and self.cfg.act_id then
		self:RemoveTimer()
		if self.cfg.act_id == ACTIVITY_TYPE.KF_ONEYUANSNATCH then
			local time = ActivityData.Instance:GetCrossRandActivityResidueTime(self.cfg.act_id)
			if math.floor(time) > 0 then
				self.cross_rand_countdown_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeActTime, self), 1)
			else
				self:SetTimeText("")
			end
		elseif self.cfg.act_id == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE then		-- 活动-礼物收割
			local me_info = ChristmaGiftData.Instance:GetMeData()
			local time_cfg = nil
			local next_day = false
			if me_info and me_info.round then
				if me_info.round == 0 then
					me_info.round = 1
					next_day = true
				end
				time_cfg = ChristmaGiftData.Instance:GetRoundTime(me_info.round)
			end
			if time_cfg and time_cfg.round_end_time then
				local timr_end = time_cfg.round_end_time
				local h_end = math.floor(timr_end / 100)
				local m_end = math.floor(timr_end % 100)
				local end_time = TimeUtil.NowDayTimeStart(os.time()) + (h_end * 60 * 60) + (m_end * 60)
				if next_day then
					end_time = end_time + (24 * 60 * 60)
				end

				if self.count_down_two then
					CountDown.Instance:RemoveCountDown(self.count_down_two)
					self.count_down_two = nil
				end
				self.count_down_two = CountDown.Instance:AddCountDown(999, 1, function()
					local time_text = TimeUtil.FormatSecond(end_time - os.time(), 2)
					self:SetTimeText(time_text)
				end)
			end
		else
			if self.cfg.name == "BiPin" then --策划需求全民比拼活动倒计时处理
				local bipin_day = TimeCtrl.Instance:GetCurOpenServerDay() > #COMPETITION_ACTIVITY_TYPE and #COMPETITION_ACTIVITY_TYPE or TimeCtrl.Instance:GetCurOpenServerDay()
				self.cfg.act_id = COMPETITION_ACTIVITY_TYPE[bipin_day]
			end
			local time = ActivityData.Instance:GetActivityResidueTime(self.cfg.act_id)
			if time > 0 then
				self.countdown_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeActTime, self), 1)
			else
				self:SetTimeText("")
			end
		end
	end

	local icon_name = self.cfg.icon
	if self.cfg.name == "MarryWedding" then
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
		if activity_info.status ~= HUNYAN_STATUS.OPEN then
			icon_name = "Icon_MarryXunyou"
		end
		self:SetImage(icon_name, true)
	elseif self.cfg.name == "BiPin" then
		local day = TimeCtrl.Instance:GetCurOpenServerDay()
		icon_name = day <= #COMPETITION_ACTIVITY_TYPE and "Icon_bipin_" .. day or "Icon_bipin_1"
		self:SetImage(icon_name, false)
		self:SetImageName("Icon_bipin")

	elseif self.cfg.name == "FanHuanTwo" or self.cfg.name == "FanHuan" then
		local act_id = self.cfg.name == "FanHuanTwo" and RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 or RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN
		local day = TimeCtrl.Instance:GetCurOpenServerDay()
		local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().jinjie_act_theme
		local icon_name = 1
		if ActivityData.Instance:GetActivityIsOpen(act_id) then
			for k,v in pairs(config) do
				if v.act_id == act_id and day == v.opengame_day then
					icon_name = v.act_theme
				end
			end
		end
		icon_name = "Icon_back_" .. icon_name
		self:SetImage(icon_name, false)
		self:SetImageName("Icon_back")
	elseif self.cfg.name == "Immortal" then
		if OpenFunData and OpenFunData.Instance and OpenFunData.Instance:CheckIsHide("Immortal") == true then
			if not self.is_first_open_immortal then
				local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
				local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
				local remind_day = PlayerPrefsUtil.GetInt("Immortal" .. main_role_id) or cur_day
				if cur_day ~= -1 and cur_day ~= remind_day then
					RemindManager.Instance:Fire(RemindName.ImmortalCard)
				end
				self.is_first_open_immortal = true
			end
		end	
		local is_label = ImmortalData.Instance:RemindLabel()
		local bundle, asset = ResPath.GetImages("label_status_xianshi3")
		self:ShowXianShiDuiHuan(is_label > 0, bundle, asset)
	elseif self.cfg.name == "rebateview" then
		if DailyChargeData and DailyChargeData.Instance and RebateCtrl and RebateCtrl.Instance then
			local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
			local is_show = is_show or RebateCtrl.Instance:GetBuyState()
			if history_recharge >= DailyChargeData.GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("rebateview") == true then
				if not self.is_first_open_rebateview then
					local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
					local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
					local remind_day = PlayerPrefsUtil.GetInt("rebateview" .. main_role_id) or cur_day
					if cur_day ~= -1 and cur_day ~= remind_day then
						self:ShowEffect(true)
					end
					-- local show_tag = RebateData.Instance:GetFirstOpenTag()
					-- local bundle, asset = ResPath.GetMainUI("label_status_uplevelone_img")
					-- self:ShowXianShiDuiHuan(show_tag, bundle, asset)
					self.is_first_open_rebateview = true
				end	
			end
		end
	elseif self.cfg.name == "imageskillview" then
		if DailyChargeData and DailyChargeData.Instance and ImageSkillCtrl and ImageSkillCtrl.Instance then
			local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
			local is_show = is_show or ImageSkillCtrl.Instance:GetBuyState()
			if history_recharge >= DailyChargeData.GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("imageskillview") == true then
				if not self.is_first_open_imageskillview then
					local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
					local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
					local remind_day = UnityEngine.PlayerPrefs.GetInt("imageskillview" .. main_role_id) or cur_day
					if cur_day ~= -1 and cur_day ~= remind_day then
						self:ShowEffect(true)
					end
					local show_tag = ImageSkillData.Instance:GetFirstOpenTag()
					local bundle, asset = ResPath.GetMainUI("label_status_xianshi3")
					self:ShowXianShiDuiHuan(show_tag, bundle, asset)
					self.is_first_open_imageskillview = true
				end	
			end
		end		
	elseif self.cfg.name == "Charge" then
		if DailyChargeData and DailyChargeData.Instance and ResetDoubleChongzhiData and ResetDoubleChongzhiData.Instance then
			local is_first = DailyChargeData.Instance:HasFirstRecharge()
			local open = OpenFunData.Instance:CheckIsHide("chongzhi")
			local pttq_open = ResetDoubleChongzhiData.Instance:IsShowPuTianTongQing()
			if open and is_first and pttq_open and not self.is_first_open_charge then
				MainUICtrl.Instance:FlushView("show_double_icon", {true})
				self.is_first_open_charge = true
			end
		end
	elseif self.cfg.name == "DayTrailer" then
		local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
		if trailer_info.num and trailer_info.num >= 1 then
			local info_list = trailer_info.info_list
			icon_name = info_list[1].res_icon
			self:SetImage(icon_name, false)
			if not trailer_info.is_tomorrow then
				self:ShowEffect(true)
				self:SetImageName("DayTrailerReceive")
			else
				self:ShowEffect(false)
				self:SetImageName("DayTrailer")
			end
		end
	elseif self.cfg.name == "arenaactivityview" then
		if not self.first_open_arena_icon then
			local is_show_arena = ArenaData.Instance:GetArenaMainuiShow()
			local bundle, asset = ResPath.GetImages("label_status_juebanwing")
			self:ShowXianShiDuiHuan(is_show_arena, bundle, asset)
			self.first_open_arena_icon = true
		end
	elseif self.cfg.name == "ZeroGift" then
		if not self.first_open_arena_icon then
			local is_show_label = FreeGiftData.Instance:GetFreeGiftSign()
			local bundle, asset = ResPath.GetMainUI("label_status_xianshi3")
			self:ShowXianShiDuiHuan(is_show_label, bundle, asset)
			self.first_open_arena_icon = true
		end
	elseif self.cfg.name == "GiftLimitBuy" then
		if GiftLimitBuyData and GiftLimitBuyData.Instance then
			local is_show_effect = GiftLimitBuyData.Instance:GetGiftLimitBuyRemind() == 1
			self:ShowEffect(is_show_effect)
			local is_show_xianshi = GiftLimitBuyData.Instance:GetGiftLimitBuyMainuiShow()
			local bundle, asset = ResPath.GetImages("label_status_xianshi3")
			self:ShowXianShiDuiHuan(is_show_xianshi, bundle, asset)
		end
	elseif self.cfg.name == "FourGradeEquipView" then
		if not self.first_open_arena_icon then
			local is_show_label = FourGradeEquipData.Instance:GetFourGradeIconFirstOpen()
			local bundle, asset = ResPath.GetImages("label_status_xianshi3")
			self:ShowXianShiDuiHuan(is_show_label, bundle, asset)
			self.first_open_arena_icon = true
		end
	elseif self.cfg.name == "OneYuanBuy" then
		if not self.first_open_arena_icon then
			local is_show_label = OneYuanBuyData.Instance:GetOneYuanBuyFirstOpen()
			local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
			local bundle, asset = ResPath.GetImages("label_status_xianshi3")
			self:ShowXianShiDuiHuan(is_show_label and is_open, bundle, asset)
			self.first_open_arena_icon = true
		end
	elseif self.cfg.name == "weeding_get_invite" then
		if not self.first_open_arena_icon then
			local is_show_bubble = MarriageData.Instance:GetIsShowBubble()
			if is_show_bubble then
				MarriageData.Instance:SetIsShowBubble(false)
				MarriageData.Instance:SetIsShowBubble(true)
				self:SetActive(true)
				self:SetPromptShow(true)
				if HUNYAN_STATUS.XUNYOU == MarriageData.Instance:GetActiveState() then 
					local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
					if hunyan_info.role_name and hunyan_info.lover_role_name and "" ~= hunyan_info.role_name and  "" ~= hunyan_info.lover_role_name then
						self:SetPromptTxt(string.format(Language.Marriage.MarryXunYou2, hunyan_info.role_name, hunyan_info.lover_role_name))
					else
						self:SetPromptTxt(Language.Marriage.MarryXunYou)
					end 
				elseif HUNYAN_STATUS.OPEN == MarriageData.Instance:GetActiveState() then 
					local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
					if hunyan_info.role_name and hunyan_info.lover_role_name and "" ~= hunyan_info.role_name and  "" ~= hunyan_info.lover_role_name then
						self:SetPromptTxt(string.format(Language.Marriage.MarryHunYan2, hunyan_info.role_name, hunyan_info.lover_role_name))
					else
						self:SetPromptTxt(Language.Marriage.MarryHunYan)
					end 
				end
			end
			self.first_open_arena_icon = true
		end
	elseif self.cfg.name == "marriage" then
		self:SetGraphicGrey(IS_ON_CROSSSERVER)
	elseif self.cfg.name == "guild" then
		self:SetGraphicGrey(IS_ON_CROSSSERVER)
	end
end

function MainuiIcon:InitIcon(cfg, types)
	self.cfg = cfg
	self.types = types

	self.cur_act_theme = ExpenseGiftData.Instance and ExpenseGiftData.Instance:GetCurActTheme()
	self.root_node.gameObject.name = self.cfg.name
	local icon_name = self.cfg.icon
	if self.cfg.name == "kaifuactivityview" and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		icon_name = "Icon_System_ActivityCombineServer"
	end
	local bundle, asset = ResPath.GetMainIcon(icon_name)
	self.node_list["Image"].image:LoadSprite(bundle, asset)

	if self.node_list["Name"] then
		local bundle, asset = ResPath.GetMainIcon(icon_name .. "Name")
		self.node_list["Name"]:SetActive(false)
		self.node_list["Name"].image:LoadSprite(bundle, asset, function ()
			self.node_list["Name"]:SetActive(true)
			self.node_list["Name"].image:SetNativeSize()
		end)
	end
	if self.cfg.word then
		self.node_list["Text"].text.text = self.cfg.word
	end
	if self.cfg.lable then
		self.node_list["Lable"].text.text = self.cfg.lable
	end
end

function MainuiIcon:LoadCallBack()
	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MainuiIcon:OnClick()
	if nil ~= self.cfg and nil ~= self.cfg.call then
		self.cfg.call(self.cfg.name)
	end
end

function MainuiIcon:GetConfig()
	return self.cfg
end

function MainuiIcon:ShowRemind(is_show)
	self.node_list["RedPoint"]:SetActive(is_show)
end

function MainuiIcon:ShowXianShiDuiHuan(is_show, bundle, asset)
	if not self.node_list["XianShiDuiHuan"] then return end

	if bundle and asset then
		self.node_list["XianShiDuiHuanIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["XianShiDuiHuan"]:SetActive(is_show)
		end)
	else
		self.node_list["XianShiDuiHuan"]:SetActive(is_show)
	end
end

function MainuiIcon:ShowEffect(is_show)
	self.node_list["Effect"]:SetActive(is_show)
end

function MainuiIcon:SetTimeText(str)
	if self.node_list["ActTime"] and self.root_node.gameObject.activeInHierarchy then
		self.node_list["ActTime"].text.text = str
	end
end

function MainuiIcon:ChangeActTime(time_obj, elapse_time)
	if self.cfg.act_id == ACTIVITY_TYPE.KF_ONEYUANSNATCH then 						-- 跨服运营活动(一元夺宝)
		local time, next_time = ActivityData.Instance:GetCrossRandActivityResidueTime(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
		time = next_time - TimeCtrl.Instance:GetServerTime()
		if time <= 0 then
			self:SetTimeText("")
			return
		end
		self:SetTimeText(ActivityData.Instance:GetActTimeShow(time))
	elseif ActivityData.Instance then
		local time, next_time = ActivityData.Instance:GetActivityResidueTime(self.cfg.act_id)
		local sever_time = TimeCtrl.Instance:GetServerTime()
		time = next_time - sever_time
		if time <= 0 then
			self:SetTimeText("")
			return
		end
		if self.cfg.act_id == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN then --进阶返还倒计时特殊处理按0点处理
			time = AdvancedReturnData.Instance:GetActivitytimes(sever_time)
		elseif self.cfg.act_id == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 then
			time = AdvancedReturnTwoData.Instance:GetActivitytimes(sever_time)
		end
		self:SetTimeText(ActivityData.Instance:GetActTimeShow(time))
	end
end

function MainuiIcon:RemoveTimer()
	if self.countdown_timer then
		GlobalTimerQuest:CancelQuest(self.countdown_timer)
		self.countdown_timer = nil
	end
	if self.cross_rand_countdown_timer then
		GlobalTimerQuest:CancelQuest(self.cross_rand_countdown_timer)
		self.cross_rand_countdown_timer = nil
	end

	if self.count_down_two then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end
end

function MainuiIcon:SetImage(image_name, bool)
	local bundle, asset = ResPath.GetMainIcon(image_name)
	if self.node_list["Image"] then
		self.node_list["Image"].image:LoadSprite(bundle, asset, function ()
			-- self.node_list["Image"].image:SetNativeSize()
		end)
	end
	if bool then
		self:SetImageName(image_name)
	end
end

-- 设置按钮状态
function MainuiIcon:SetBtnState(alpha, bool)
	if self.root_node and self.root_node.canvas_group then
		self.root_node.canvas_group.alpha = alpha
		self.root_node.button.interactable = bool
	end
end

function MainuiIcon:SetImageName(image_name)
	local bundle, asset = ResPath.GetMainIcon(image_name .. "Name")
	if self.node_list["Name"] then
		self.node_list["Name"]:SetActive(true)
		self.node_list["Name"].image:LoadSprite(bundle, asset, function ()
			self.node_list["Name"].image:SetNativeSize()
		end)
	end
end

-- 设置提示框显示
function MainuiIcon:SetPromptShow(is_show, str)
	self.node_list["Panel"].animator:SetBool("IsShake", is_show or false)
	if self.node_list["Prompt"] then
		self.node_list["Prompt"]:SetActive(is_show)
	end
	if self.node_list["PromptText"] and str then
		self.node_list["PromptText"].text.text = str
	end
end

function MainuiIcon:SetPromptTxt(txt)
	if self.node_list["PromptText"] then
		self.node_list["PromptText"].text.text = txt
	end
end

function MainuiIcon:SetIconShake(flag)
	if self.node_list["Panel"] and self.node_list["Panel"].animator and self.node_list["Panel"].animator.isActiveAndEnabled then
		self.node_list["Panel"].animator:SetBool("IsShake", flag or false)
	end	
end

function MainuiIcon:SetGraphicGrey(flag)
	if self.node_list["IconInfoGroup"] and self.node_list["Lock"] then
		UI:SetGraphicGrey(self.node_list["IconInfoGroup"], flag)
		self.node_list["Lock"]:SetActive(flag)
	end
end
