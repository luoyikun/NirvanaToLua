ExpRefineView = ExpRefineView or BaseClass(BaseView)

-- 没配置写死7天
local ExpRefineDay = 7

function ExpRefineView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelThree"},
		{"uis/views/serveractivity/exprefine_prefab", "ExpRefineContent"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true

	self.have_get_gold_num = 0
	self.old_get_gold_num = 0
	self.is_fly_ing = false
end

function ExpRefineView:__delete()

end

function ExpRefineView:ReleaseCallBack()

end

function ExpRefineView:LoadCallBack()
	self.node_list["ImgTitle"].image:LoadSprite("uis/views/serveractivity/exprefine/nopack_atlas", "jingyanping.png", function()
		self.node_list["ImgTitle"]:SetActive(true)
		self.node_list["ImgTitle"].image:SetNativeSize()
	end)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["LeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickRefineHanlder, self))
	self.node_list["ClickOpenReward"].button:AddClickListener(BindTool.Bind(self.OnClickOpenRewardHanlder, self))
end

function ExpRefineView:OpenCallBack()

	RemindManager.Instance:SetRemindToday(RemindName.ExpRefineBubble)

	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	if exp_refine_info then
		self.old_get_gold_num = exp_refine_info.refine_reward_gold
	end

	self.have_get_gold_num = 0

	ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_GET_INFO)
	ExpRefineData.Instance:SetIsShowEff(false)

	local main_chat_view = MainUICtrl.Instance:GetMainChatView()
	if main_chat_view then
		local exp_refine_btn = main_chat_view:GetChatButton(MainUIViewChat.IconList.ExpRefine)
		if exp_refine_btn then
			exp_refine_btn:ShowEffect(false)
			exp_refine_btn:SetPromptShow(false)
		end
	end
	ExpRefineData.Instance:CancelCoutDown()
	ExpRefineData.Instance:CancelCoutDown2()
end

function ExpRefineView:ShowIndexCallBack(index)
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info ~= nil and act_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_info.next_time or 0
		if CountDown.Instance:HasCountDown(self.count_down) then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end

		local time = next_time - TimeCtrl.Instance:GetServerTime()
		if self.count_down == nil and time > 0 then
			self:CountDownTime(0, time)
			self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDownTime, self))
		end
	else
		self.node_list["ActTime"].text.text = Language.Activity.YiJieShuDes
	end
end

function ExpRefineView:CloseCallBack()
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count ~= nil then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	self.is_fly_ing = false
end

function ExpRefineView:CountDownTime(elapse_time, total_time)
	local dis_time = total_time - elapse_time
	if dis_time > 0 then
		local time = TimeUtil.Format2TableDHMS(dis_time)
		local time_str = ""
		if time.day > 0 then
			time_str = time.day .. Language.Common.TimeList.d .. time.hour .. Language.Common.TimeList.h
		else
			time_str = string.format("%02d:%02d:%02d", time.hour, time.min, time.s)
		end
		self.node_list["ActTime"].text.text = string.format(Language.ExpRefine.ActTime, time_str)
	else
		if self.count_down then
			if CountDown.Instance:HasCountDown(self.count_down) then
				CountDown.Instance:RemoveCountDown(self.count_down)
			end
			self.count_down = nil
		end
		self.node_list["ActTime"].text.text = Language.Activity.YiJieShuDes
	end
end

function ExpRefineView:OnFlush()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	local buy_num = exp_refine_info.refine_today_buy_time
	local max_buy_num = ExpRefineData.Instance:GetRAExpRefineCfgMaxNum()

	-- 砖石飞过去的动画
	if self.old_get_gold_num ~= exp_refine_info.refine_reward_gold then
		self.is_fly_ing = true
		self.old_get_gold_num = exp_refine_info.refine_reward_gold
	end

	if self.is_fly_ing and self.old_get_gold_num > 0 then
		self.is_fly_ing = false
		local animator = self.node_list["DiamondAnim"]:GetComponent(typeof(UnityEngine.Animator))
		if animator.isActiveAndEnabled then
			animator:SetTrigger("state")
		end
	end

	if exp_refine_info.refine_reward_gold > 0 then
		self.have_get_gold_num = exp_refine_info.refine_reward_gold
		self.node_list["HaveGotGoldTxt"].text.text = self.have_get_gold_num
	end
	self.node_list["GoldTxt"].text.text = exp_refine_info.refine_reward_gold

	local result_buy_num = max_buy_num - buy_num
	result_buy_num = result_buy_num > 0 and result_buy_num or 0
	local str = result_buy_num
	if result_buy_num <= 0 then
		str = ToColorStr(result_buy_num, TEXT_COLOR.RED_4)
	end
	self.node_list["RightValue"].text.text = str .. " / " .. max_buy_num

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_info.next_time or 0
		local time = next_time - TimeCtrl.Instance:GetServerTime()
		local time_tab = TimeUtil.Format2TableDHM(time)
		self.node_list["DayNumTxt"].text.text = string.format(Language.ExpRefine.CanGet, time_tab.day + 1)
	else
		self.node_list["DayNumTxt"].text.text = string.format(Language.ExpRefine.CanGet, 1)
	end

	if buy_num < max_buy_num and act_info.status == ACTIVITY_STATUS.OPEN then
		local exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(buy_num)
		if exp_refine_cfg then
			self.node_list["LevelUpDay"].text.text = ExpRefineDay
			self.node_list["LeftValue"].text.text = exp_refine_cfg.consume_gold
			self.node_list["LabelRefineGetNum"].text.text =  exp_refine_cfg.reward_exp
			local role_exp = exp_refine_cfg.reward_exp
			local level = PlayerData.Instance:GetRoleLevelByExp(role_exp) or 0
			self.node_list["NextLevel"].text.text = string.format(Language.ExpRefine.LabelLevelAndRebirth, PlayerData.GetLevelString(level))
			self.node_list["NextLevel"]:SetActive(true)
			-- local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
			-- local txt = string.format(Language.ExpRefine.LevelString, sub_level, rebirth)
			-- self.node_list["LabelLevelAndRebirth"].text.text = string.format(Language.ExpRefine.LabelLevelAndRebirth, PlayerData.GetLevelString(level))		--暂时隐藏
		end
		self.node_list["left_label_bg"]:SetActive(true)
		self.node_list["TxtUseEnd"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["LeftButton"], true)
		-- self.node_list["BottomLabelImg"]:SetActive(true)
		-- self.node_list["LabelRefineGetNum"]:SetActive(true)
		-- self.node_list["LabelLevelAndRebirth"]:SetActive(true)
		-- self.node_list["BottomLabel"]:SetActive(true)	--暂时隐藏

		self.node_list["LeiJi"]:SetActive(true)
		self.node_list["Get"]:SetActive(false)
		self.node_list["Reward"]:SetActive(false)
	else
		self.node_list["TxtUseEnd"]:SetActive(true)
		self.node_list["left_label_bg"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["LeftButton"], false)
		-- self.node_list["BottomLabelImg"]:SetActive(false)
		self.node_list["LeftValue"].text.text = "--"
		self.node_list["NextLevel"]:SetActive(false)
		-- self.node_list["LabelRefineGetNum"]:SetActive(false)
		-- self.node_list["LabelLevelAndRebirth"]:SetActive(false)
		-- self.node_list["BottomLabel"]:SetActive(false)

		if act_info.status == ACTIVITY_STATUS.OPEN then
			self.node_list["LeiJi"]:SetActive(true)
			self.node_list["Get"]:SetActive(false)
			self.node_list["Reward"]:SetActive(false)
		else
			self.node_list["LeiJi"]:SetActive(false)
			if exp_refine_info and exp_refine_info.refine_reward_gold then 
				self.node_list["Get"]:SetActive(exp_refine_info.refine_reward_gold > 0)
				self.node_list["Reward"]:SetActive(exp_refine_info.refine_reward_gold <= 0)
			end
		end
	end
end

function ExpRefineView:OnClickClose()
	self:Close()
end

function ExpRefineView:OnClickRefineHanlder()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
		local exp_refine_cfg = nil
		if exp_refine_info ~= nil then
			exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(exp_refine_info.refine_today_buy_time)
		end
		if exp_refine_cfg then
			local des = string.format(Language.ExpRefine.AutoTips, exp_refine_cfg.consume_gold)
			local ok_callback = function()
				ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_BUY_EXP)
				local vo = GameVoManager.Instance:GetMainRoleVo()
				if vo.gold < exp_refine_cfg.consume_gold then
					return
				end

				if self.count == nil then
					self.count = CountDown.Instance:AddCountDown(1, 0.5, function ()
							local role_vo = PlayerData.Instance:GetRoleVo()
							local max_x = self.node_list["NodeRight"].rect.localPosition.x * 2
							local x = max_x * role_vo.exp / role_vo.max_exp
							if x > max_x then
								x = max_x
							end
							self.node_list["ExpEffEndObj"].rect.anchoredPosition = Vector3(x, 0, 0)

							local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guangdian1")
							TipsCtrl.Instance:ShowFlyEffectManager(ViewName.FriendExpBottleView, bundle_name, asset_name, 
								self.node_list["ExpEffStarObj"], self.node_list["ExpEffEndObj"], nil, 1)
							CountDown.Instance:RemoveCountDown(self.count)
							self.count = nil
						end)
				end
			end
			TipsCtrl.Instance:ShowCommonAutoView("auto_exp_refine", des, ok_callback)
		end
	end
end

function ExpRefineView:OnClickOpenRewardHanlder()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	if exp_refine_info ~= nil and exp_refine_info.refine_reward_gold > 0 then
		ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD)
	end
end