-- 女神信息面板 GoddessContent
GoddessInfoView = GoddessInfoView or BaseClass(BaseRender)

local Gradient_Color1 = {
	[1] = Color(0/255, 222/255, 34/255, 1),
	[2] = Color(43/255, 173/255, 255/255, 1),
	[3] = Color(255/255, 118/255, 250/255, 1),
	[4] = Color(254/255, 144/255, 36/255, 1),
	[5] = Color(255/255, 1/255, 0/255, 1),
}
local Gradient_Color2 = {
	[1] = Color(75/255, 234/255, 122/255, 1),
	[2] = Color(69/255, 209/255, 255/255, 1),
	[3] = Color(203/255, 12/255, 255/255, 1),
	[4] = Color(255/255, 204/255, 0/255, 1),
	[5] = Color(255/255, 105/255, 80/255, 1),
}

local YIZHEQIANGGOUXIANNV = 9 				--一折抢购仙女阶段

local TWEEN_TIME = 0.5
function GoddessInfoView:__init(instance)
	self.node_list["HuanHuaContent"].button:AddClickListener(BindTool.Bind(self.HuanHuaBtnOnClick, self))
	-- self.node_list["CancelButton"].button:AddClickListener(BindTool.Bind(self.CancelBtnOnClick, self))
	self.node_list["TextGoTo"].button:AddClickListener(BindTool.Bind(self.OnClickGoTo, self))
	self.node_list["BtnChuZhan"].button:AddClickListener(BindTool.Bind(self.OnClickChuZhan, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, true))

	self.goddess_role_view = GoddessRoleView.New(self.node_list["RoleContent"])
	self.goddess_role_view.parent = self
	self.right_info_view = GoddessInfoRightView.New(self.node_list["talent_content"])
	self.right_info_view.parent = self
	self.left_info_view = GoddessInfoLeftView.New(self.node_list["goddess_icon_content"])
	self.left_info_view.parent = self
	
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Goddess_HuanHua)

	local id = GoddessData.Instance:GetMainCampID()
	self.xiannv_id = id
	self.current_xiannv_id = id

	self.goal_data = {}
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end	
	self.auto_upgrade = true

	self.xiannv_cout = GoddessData.Instance:GetActiveXianNvCount()
end

function GoddessInfoView:ItemDataChangeCallback(item_id)
	local id = self.current_xiannv_id or 0
	local data_list = GoddessData.Instance:GetXianNvItem(id)
	if data_list then
		local xn_zizhi = data_list.xn_zizhi or 0
		local zhi_zhi_cfg = GoddessData.Instance:GetXianNvZhiziCfg(id,xn_zizhi)
		if nil == zhi_zhi_cfg then
			return
		end
		local upgrade_item_id = zhi_zhi_cfg.uplevel_stuff_id or 0
		if item_id == upgrade_item_id then
			self:FlushRightView()
		end
	end
end

function GoddessInfoView:__delete()
	if self.right_info_view then
		self.right_info_view:DeleteMe()
		self.right_info_view = nil
	end

	if self.left_info_view then
		self.left_info_view:DeleteMe()
		self.left_info_view = nil
	end
	
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.goddess_role_view then
		self.goddess_role_view:DeleteMe()
		self.goddess_role_view = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function GoddessInfoView:RemindChangeCallBack(remind_name, num)
	if RemindName.Goddess_HuanHua == remind_name then
		self.node_list["HuanHuaRedPoint"]:SetActive(num > 0)
	end
end

function GoddessInfoView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

--响应出战按钮
function GoddessInfoView:OnClickChuZhan()
	local temp_table = {self.xiannv_id, -1, -1, -1}
	GoddessCtrl.Instance:SendCSXiannvCall(temp_table)	--出战当前选择的伙伴
end

--引导用函数
function GoddessInfoView:GetUpGradeBtn()
	return self.right_info_view and self.right_info_view:GetUpGradeBtn()
end

function GoddessInfoView:GetActiveBtn()
	return self.right_info_view and self.right_info_view:GetActiveBtn()
end

function GoddessInfoView:GetActiveClickfun()
	return self.right_info_view and self.right_info_view:GetActiveClickfun()
end

function GoddessInfoView:HuanHuaBtnOnClick()
	ViewManager.Instance:Open(ViewName.GoddessHuanHua)
end

function GoddessInfoView:CancelBtnOnClick()
	GoddessCtrl.Instance:SentXiannvImageReq(-1)
end

function GoddessInfoView:UpdateAttributeView(xiannv_id,xiannv_level)
	local attr = GoddessData.Instance:GetXiannvAttr(xiannv_id)
	if self.right_info_view then
		self.right_info_view:UpdateAttributeView(attr)
	end

	if self.goddess_role_view then
		self.goddess_role_view:SetLevelValue(xiannv_level, attr.color)
		local xiannv_name = GoddessData.Instance:GetXianNvCfg(xiannv_id).name
		self.goddess_role_view:OnFlush(xiannv_name, xiannv_id)
	end
	self.node_list["ColorName"].image:LoadSprite(ResPath.GetGoddessText(Common_Five_Rank_Color[attr.color]))
	self:ActiveOrUgrageBtn(xiannv_level)
end

function GoddessInfoView:OnFlush()
	self:FlushRightView()
	self:FlushGetWay()
	self:AllCellOnFlush()
	self:FlshGoalContent()
	if self.current_xiannv_id ~= self.xiannv_id then
		self.left_info_view:JumpToIndex(self.xiannv_id)
	end

	-- 激活仙女时左侧列表刷新
	local count = GoddessData.Instance:GetActiveXianNvCount()
	if self.xiannv_cout < count then
		local total_xiannv_list = GoddessData.Instance:GetXianNvlist()
		if count <= (#total_xiannv_list / 2) then
			self.node_list["List"].scroller:ReloadData(0)
		else
			self.node_list["List"].scroller:ReloadData(1)
		end
		self.xiannv_cout = count
	end

	self:SetCurrentXiannvID(self.xiannv_id)
end

function GoddessInfoView:FlshGoalContent()
	self.goal_info = GoddessData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1

					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(item_id)
					local active_list = GoddessData.Instance:GetXianNvHuanHuaFlag()
					self.node_list["Effect"]:SetActive(active_list[huanhua_id] ~= 1)

					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end

				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function GoddessInfoView:OpenTipsTitleLimit(is_model)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
end

function GoddessInfoView:FlushRightView()
	local level = GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi
	if not level then
		return
	end
	self:UpdateAttributeView(self.current_xiannv_id, level >= 0 and level or 0)
end

function GoddessInfoView:ActiveOrUgrageBtn(xiannv_level)
	if self.right_info_view then
		self.right_info_view:ActiveOrUgrageBtn(xiannv_level)
	end
	if xiannv_level > 0 and not GoddessData.Instance:JudgeXiannvIsInMainCamp(self.current_xiannv_id) then
		self.node_list["BtnChuZhan"]:SetActive(true)
	else
		self.node_list["BtnChuZhan"]:SetActive(false)
	end
end

function GoddessInfoView:SetCurrentXiannvID(xiannv_id)
	local goddess_data = GoddessData.Instance
	self.current_xiannv_id = xiannv_id
	if goddess_data:JudgeXiannvIsInMainCamp(xiannv_id) then
		self.node_list["BtnChuZhan"]:SetActive(false)
		self.node_list["ImgIsUse"]:SetActive(true)
	else
		self.node_list["ImgIsUse"]:SetActive(false)
	end
	self.node_list["TextGoTo"]:SetActive(not (goddess_data:GetXianNvItem(xiannv_id).xn_zizhi > 0))
	self.node_list["TextGetWay"]:SetActive(not (goddess_data:GetXianNvItem(xiannv_id).xn_zizhi > 0))
	self.node_list["TextGetWay"].text.text = goddess_data:GetXianNvCfg(xiannv_id).get_way
	-- local open_panel = goddess_data:GetXianNvCfg(xiannv_id).open_panel
	-- self.node_list["TextGoTo"]:SetActive(nil ~= open_panel and "" ~= open_panel)
	self:FlushCancelBtn()
end

function GoddessInfoView:FlushGetWay()
	self.node_list["TextGoTo"]:SetActive(not (GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi > 0))
	self.node_list["TextGetWay"]:SetActive(not (GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi > 0))
end

function GoddessInfoView:FlushCancelBtn()
	local goddess_data = GoddessData.Instance
	local huanhua_id = goddess_data:GetHuanHuaId()
	local chuzhan_id = goddess_data:GetXianNvPos()[1]
	-- if self.node_list["CancelButton"] then
	-- 	self.node_list["CancelButton"]:SetActive(huanhua_id >= 0)
	-- end
end

function GoddessInfoView:GetCurrentXiannvID()
	return self.current_xiannv_id
end

function GoddessInfoView:UpgradeXiannv()
	local xn_zizhi = GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi
	local zhi_zhi_cfg = GoddessData.Instance:GetXianNvZhiziCfg(self.current_xiannv_id,xn_zizhi)
	if nil == zhi_zhi_cfg then
		return
	end
	local upgrade_item_id = zhi_zhi_cfg.uplevel_stuff_id
	local upgrade_num = zhi_zhi_cfg.uplevel_stuff_num
	local item_num = ItemData.Instance:GetItemNumInBagById(upgrade_item_id)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[upgrade_item_id]
	if item_cfg == nil and item_num < upgrade_num then
		TipsCtrl.Instance:ShowItemGetWayView(upgrade_item_id)
		return
	end

	if item_num < upgrade_num and self.auto_upgrade then
		local func = function(item_id, item_num, is_bind, is_use,is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_upgrade = false
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, upgrade_item_id, nil, 1)	
		return
	end
	if xn_zizhi >= GODDRESS_MAX_LEVEL then
		return
	end
	local is_auto = self.auto_upgrade and 0 or 1
	GoddessCtrl.Instance:SentXiannvAddZizhiReq(self.current_xiannv_id,is_auto)
end

function GoddessInfoView:ActiveXiannv()
	local active_cfg = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id)
	local active_item_id = active_cfg.active_item
	local item_num = ItemData.Instance:GetItemNumInBagById(active_item_id)
	if item_num > 0 then
		GoddessCtrl.Instance:SendCSXiannvActiveReq(self.current_xiannv_id, active_item_id)
		-- self.right_info_view:ActiveOrUgrageBtn(1)
		-- self.node_list["List"].scroller:ReloadData(0)
	else
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[active_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(active_item_id)
			return
		end
	end
end

function GoddessInfoView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RoleContent"], GoddessData.RoleTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	-- UITween.MoveShowPanel(self.node_list["goddess_icon_content"], GoddessData.RoleTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["talent_content"], GoddessData.RoleTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"],	Vector3(-198.5, -14, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["ColorName"],	Vector3(244, 527.5, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"],	Vector3(-809, -31.5, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, TWEEN_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["HuanHuaContent"], true, TWEEN_TIME , DG.Tweening.Ease.InExpo)
end

-- 点击前往
function GoddessInfoView:OnClickGoTo()
	local cfg = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id)
	if nil == cfg then return end

	local t = Split(cfg.open_panel, "#")
	local view_name = t[1]
	if view_name ~= nil and view_name == ViewName.DisCount then
		local activity_open = DisCountData.Instance:GetActiveState()
		local buy_info = DisCountData.Instance:GetPhaseList()
		local server_time = TimeCtrl.Instance:GetServerTime() 
		local cur_activity_page_list = DisCountData.Instance:GetNewPhaseList()
		-- 根据服务端发来的特惠活动是否包括女神特惠专场来确定是否跳转
		if nil ~= cur_activity_page_list then
			for i,v in ipairs(cur_activity_page_list) do
				if v.system_id == Sysetem_Id_Jump.Xian_Nv then
					local can_buy_time = buy_info[v.phase + 1] and buy_info[v.phase + 1].close_timestamp or 0
					if activity_open and can_buy_time > server_time then
						ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {i})
						return
					end
				end
			end
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.GoddessActiveEndTip)
	else
		if MolongMibaoData and MolongMibaoData.Instance then
			MolongMibaoData.Instance:SetShowDay(1)
		end
		ViewManager.Instance:OpenByCfg(cfg.open_panel)
	end
end

function GoddessInfoView:AllCellOnFlush()
	if self.left_info_view then
		self.left_info_view:AllCellOnFlush()
	end
end

-- function GoddessInfoView:SetScrollSelect()
-- 	if self.left_info_view then
-- 		self.left_info_view:SetCellSelectActive()
-- 		self.left_info_view:SetSingleCellSelectActive(self.current_xiannv_id)
-- 	end
-- 	self:ActiveOrUgrageBtn(GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi)
-- end

function GoddessInfoView:SetToIconIndex(index)
	if self.time_quest then return end
	self:SetCurrentXiannvID(index)
	if self.left_info_view then
		self.left_info_view:ReloadData()
	end
	self:JumpToIcon(index)

	local goddess_view = GoddessCtrl.Instance:GetView()
	if goddess_view then
		goddess_view:SetModel(index)
	end
	self.xiannv_id = index
	self:Flush()
end

function GoddessInfoView:ReloadData()
	if self.left_info_view then
		self.left_info_view:ReloadData()
	end
end

function GoddessInfoView:JumpToIcon(index)
	self:CancelQuest()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		if self.left_info_view then
			self.left_info_view:DownBtnOnClick(index)
			self.left_info_view:ToClickIcon()
		end
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end, 0.2)
end

function GoddessInfoView:CanCelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GoddessInfoView:GetGoddessRoleView()
	return self.goddess_role_view
end
--------------------------------------------------------------------------
-- 左面板 GoddessIconListView
GoddessInfoLeftView = GoddessInfoLeftView or BaseClass(BaseRender)
function GoddessInfoLeftView:__init(instance)
	self.icon_cell_list = {}
	self.current_icon_index = 0
	-- self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ClickButton, self, -1))
	-- self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ClickButton, self, 1))
	self:InitListView()

	self.current_icon_cell = nil
	self.index_list = {}
end

function GoddessInfoLeftView:__delete()
	for k,v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = nil
	self.parent = nil
end

function GoddessInfoLeftView:ClickButton(i)
	self.current_icon_index = self.current_icon_index + i
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		if goddess_info_view:GetCurrentXiannvID() ~= self.current_icon_index then
			local xiannv_name = GoddessData.Instance:GetXianNvCfg(self.current_icon_index).name
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(xiannv_name, self.current_icon_index)
			end
			local xiannv_level = GoddessData.Instance:GetXianNvItem(self.current_icon_index).xn_zizhi
			goddess_info_view:SetCurrentXiannvID(self.current_icon_index)
			goddess_info_view:UpdateAttributeView(self.current_icon_index,xiannv_level)
			goddess_info_view:ActiveOrUgrageBtn(xiannv_level)
			local goddess_view = GoddessCtrl.Instance:GetView()
			if goddess_view then
				goddess_view:SetModel(self.current_icon_index)
			end
			goddess_info_view.xiannv_id = self.current_icon_index
			goddess_info_view:Flush()
			self:AllCellOnFlush()
		end
	end
	-- self:SetSingleCellSelectActive(self.current_icon_index)
	self.node_list["icon_list_view"].scroller:RefreshActiveCellViews()
	local value = self.current_icon_index / GameEnum.MAX_XIANNV_ID
	value = value > 1 and 1 or value
	self.node_list["icon_list_view"].scroll_rect.horizontalNormalizedPosition = value
end

function GoddessInfoLeftView:BagJumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["icon_list_view"].scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.node_list["icon_list_view"].scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoddessInfoLeftView:JumpToIndex(index)
	self.current_icon_index = index
	self.node_list["icon_list_view"].scroller:JumpToDataIndex(index)
end

function GoddessInfoLeftView:AllCellOnFlush()
	if self.node_list["icon_list_view"].scroller.isActiveAndEnabled then
		self.node_list["icon_list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--ListView逻辑
function GoddessInfoLeftView:InitListView()
	self.node_list["icon_list_view"].scroller.scrollerScrollingChanged = function ()
		
	end
	self.node_list["icon_list_view"].scroller.scrollerScrolled = function ()

	end

	local list_delegate = self.node_list["icon_list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GoddessInfoLeftView:GetNumberOfCells()
	return GameEnum.MAX_XIANNV_ID + 1
end

function GoddessInfoLeftView:RefreshCell(cell, data_index, cell_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = GoddessIconCell.New(cell.gameObject, self)
		icon_cell.parent = self
		icon_cell:SetToggleGroup(self.node_list["icon_list_view"].toggle_group)
		self.icon_cell_list[cell] = icon_cell
	end
	data_index = data_index + 1
	icon_cell:SetXiannvId(data_index)
	icon_cell:Flush()
	-- self.node_list["BtnLeft"]:SetActive(self.current_icon_index > 0)
	-- self.node_list["BtnRight"]:SetActive(self.current_icon_index < GameEnum.MAX_XIANNV_ID)
end

function GoddessInfoLeftView:SetCellSelectActive()
	for k,v in pairs(self.icon_cell_list) do
		v:SetCellSelectActive(false)
	end
end

function GoddessInfoLeftView:SetSingleCellSelectActive(xiannv_id)
	for k,v in pairs(self.icon_cell_list) do
		if v:GetXiannvId() == xiannv_id then
			v:SetCellSelectActive(true)
			local name = GoddessData.Instance:GetXianNvCfg(xiannv_id).name
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(name, xiannv_id)
			end

			local level = GoddessData.Instance:GetXianNvItem(xiannv_id).xn_zizhi
			if not level then
				return
			end
			self.parent:UpdateAttributeView(xiannv_id, level >= 0 and level or 0)
			break
		end
	end
end

function GoddessInfoLeftView:ToClickIcon()
	for k,v in pairs(self.icon_cell_list) do
		v:ToClickIcon()
	end
end

function GoddessInfoLeftView:ReloadData()
	self.node_list["icon_list_view"].scroller:ReloadData(0)
end

--------------------------------------------------------------------------
-- 女神信息面板的右面板 TalentContent
GoddessInfoRightView = GoddessInfoRightView or BaseClass(BaseRender)
function GoddessInfoRightView:__init(instance)
	self.node_list["upgrade_btn"].button:AddClickListener(BindTool.Bind(self.UpGradeBtnOnClick, self))
	self.node_list["active_btn"].button:AddClickListener(BindTool.Bind(self.ActiveBtnOnClick, self))

	local handler = function()
		local close_call_back = function()
			if self.item_cell then
				self.item_cell:ShowHighLight(false)
				self.item_cell:SetToggle(false)
			end
		end
		if self.item_cell then
			self.item_cell:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
		end
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ListenClick(handler)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["capablity"])

	self.current_xiannv_level = 0
end

function GoddessInfoRightView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.parent = nil
	self.fight_text = nil
end

function GoddessInfoRightView:GetUpGradeBtn()
	return self.node_list["upgrade_btn"]
end

function GoddessInfoRightView:GetActiveBtn()
	return self.node_list["active_btn"]
end

function GoddessInfoRightView:GetActiveClickfun()
	return BindTool.Bind(self.ActiveBtnOnClick, self)
end

function GoddessInfoRightView:ActiveOrUgrageBtn(xiannv_level)
	UI:SetButtonEnabled(self.node_list["upgrade_btn"], xiannv_level ~= GODDRESS_MAX_LEVEL)
	if xiannv_level <= 0 then
		self.node_list["PanelFrame"]:SetActive(true)
		self.node_list["upgrade_btn"]:SetActive(false)
		self.node_list["active_btn"]:SetActive(true)
	elseif xiannv_level > 0 and xiannv_level < GODDRESS_MAX_LEVEL then
		self.node_list["PanelFrame"]:SetActive(true)
		self.node_list["upgrade_btn"]:SetActive(true)
		self.node_list["active_btn"]:SetActive(false)
		self.node_list["btntext"].text.text = Language.Common.UpGrade
	elseif xiannv_level == GODDRESS_MAX_LEVEL then
		self.node_list["active_btn"]:SetActive(false)
		self.node_list["upgrade_btn"]:SetActive(true)
		self.node_list["NeedValueText"].text.text = Language.Common.MaxLevelDesc
		self.node_list["RedPoint"]:SetActive(false)
		self.node_list["btntext"].text.text = Language.Common.YiManJi
	end
end

function GoddessInfoRightView:UpGradeBtnOnClick()
	self.parent:UpgradeXiannv()
end

function GoddessInfoRightView:ActiveBtnOnClick()
	self.parent:ActiveXiannv()
end

function GoddessInfoRightView:UpdateAttributeView(attr)

	self.node_list["gongji"].text.text = attr.gongji
	self.node_list["fangyu"].text.text = attr.fangyu
	self.node_list["maxhp"].text.text = attr.maxhp
	self.node_list["shanghai"].text.text = attr.xiannv_gongji
	local value_text = ""
	if attr.have_mat_value < attr.need_mat_value then
		self.node_list["RedPoint"]:SetActive(false)
		value_text = ToColorStr(attr.have_mat_value .. "", TEXT_COLOR.RED) .. " / " .. ToColorStr(attr.need_mat_value .. "", TEXT_COLOR.GREEN)
	else
		self.node_list["RedPoint"]:SetActive(true)
		value_text = ToColorStr(attr.have_mat_value .. "", TEXT_COLOR.GREEN) .. " / " .. ToColorStr(attr.need_mat_value .. "", TEXT_COLOR.GREEN)
	end

	self.node_list["NeedValueText"].text.text = value_text
	self.node_list["skill_name"].text.text = attr.skill_name
	self.node_list["skill_level"].text.text = attr.show_level
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = attr.power
	end
	self.node_list["SkillSprite"].image:LoadSprite(attr.bundle, attr.asset .. ".png")
	self.node_list["Skilldesc"].text.text = attr.skill_desc
	self.item_cell:SetData(attr.info)


end

--------------------------------------------------------------------------
-- 格子 GoddessIcon
GoddessIconCell = GoddessIconCell or BaseClass(BaseCell)

function GoddessIconCell:__init(instance, left_view)
	self.left_view = left_view

	-- self.node_list["goddessIcon"].button:AddClickListener(BindTool.Bind(self.IconOnClick, self))
	-- self.node_list["set_grey_image"].button:AddClickListener(BindTool.Bind(self.GreyImageOnClick, self))
	self.node_list["goddessIcon"].toggle:AddValueChangedListener(BindTool.Bind(self.IconOnClick, self))
	self.xiannv_id = -1
end

function GoddessIconCell:__delete()
	self.parent = nil
end

function GoddessIconCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GoddessIconCell:IconOnClick(is_click)
	if not is_click then return end

	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		if goddess_info_view:GetCurrentXiannvID() ~= self.xiannv_id then
			local xiannv_name = GoddessData.Instance:GetXianNvCfg(self.xiannv_id).name
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(xiannv_name, self.xiannv_id)
			end
			local xiannv_level = GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi
			goddess_info_view:SetCurrentXiannvID(self.xiannv_id)
			goddess_info_view:UpdateAttributeView(self.xiannv_id,xiannv_level)
			goddess_info_view:ActiveOrUgrageBtn(xiannv_level)
			local goddess_view = GoddessCtrl.Instance:GetView()
			if goddess_view then
				goddess_view:SetModel(self.xiannv_id)
			end
			goddess_info_view.xiannv_id = self.xiannv_id
			self.parent.current_icon_index = self.xiannv_id
			goddess_info_view:Flush()
		end
	end
end

function GoddessIconCell:GreyImageOnClick()
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		if goddess_info_view:GetCurrentXiannvID() ~= self.xiannv_id then
			local xiannv_name = GoddessData.Instance:GetXianNvCfg(self.xiannv_id).name
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(xiannv_name, self.xiannv_id)
			end
			goddess_info_view:SetCurrentXiannvID(self.xiannv_id)
			goddess_info_view:UpdateAttributeView(self.xiannv_id, 0)
			goddess_info_view:ActiveOrUgrageBtn(0)
			local goddess_view = GoddessCtrl.Instance:GetView()
			if goddess_view then
				goddess_view:SetModel(self.xiannv_id)
			end
			goddess_info_view.xiannv_id = self.xiannv_id
			goddess_info_view:Flush()
		end
	end
end

function GoddessIconCell:ToClickIcon() --手动
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view:GetCurrentXiannvID() == self.xiannv_id then
		if GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi > 0 then
			self:IconOnClick()
		else
			self:GreyImageOnClick()
		end
	end
end

function GoddessIconCell:SetCellSelectActive(is_active)
	self.node_list["icon_select"]:SetActive(is_active)
end

function GoddessIconCell:SetXiannvId(index)
	self.xiannv_id = GoddessData.Instance:GetShowXnIdList()[index]
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	self.index = index
end

function GoddessIconCell:GetXiannvId()
	return self.xiannv_id
end

function GoddessIconCell:OnFlush()
	local xiannv_item = GoddessData.Instance:GetXianNvItem(self.xiannv_id)
	if nil == xiannv_item then
		return
	end
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	-- if goddess_info_view then
	-- 	goddess_info_view:SetScrollSelect()
	-- end
	self:SetCellSelectActive(self.xiannv_id == goddess_info_view:GetCurrentXiannvID())
	-- self.node_list["set_grey_image"]:SetActive(xiannv_item.xn_zizhi <= 0)
	local str = GoddessData.Instance:GetXianNvCfg(self.xiannv_id).name
	if xiannv_item.xn_zizhi <= 0 then
		UI:SetGraphicGrey(self.node_list["sprite"], true)
	else
		UI:SetGraphicGrey(self.node_list["sprite"], false)
		local xiannv_level = GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi
		str = "Lv." .. xiannv_level .." " .. str
	end

	self.node_list["name"].text.text = str
	local color = GoddessData.Instance:GetXiannvAttr(self.xiannv_id).color
	local name_color = self.node_list["name"]:GetComponent(typeof(UIGradient))
	if name_color then
		name_color.Color1 = Gradient_Color1[color]
		name_color.Color2 = Gradient_Color2[color]
	end

	if xiannv_item.xn_zizhi > 0 and goddess_info_view and self.xiannv_id == goddess_info_view:GetCurrentXiannvID() then
		goddess_info_view:UpdateAttributeView(self.xiannv_id,xiannv_item.xn_zizhi)
	end
	local res_id = GoddessData.Instance:GetXianNvCfg(self.xiannv_id).resid
	local bundle, asset = ResPath.GetGoddessIcon(res_id)
	self.node_list["sprite"].image:LoadSprite(bundle, asset)
	self.node_list["bg"].image:LoadSprite(ResPath.GetGoddessBg(Common_Five_Rank_Color[color]))
	-- self.node_list["sprite"].image:SetNativeSize()
	local is_chuzhan = false
	self:SetRedPoint()

	local is_show, _, cfg = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Xian_Nv)
	self.node_list["XianShiImg"]:SetActive(false)
	if is_show and cfg and cfg.system_index then
		for k, v in pairs(cfg.system_index) do
			local index_list = Split(v, "|")
			for k, v in pairs(index_list) do
				if tonumber(v) == self.xiannv_id then
					self.node_list["XianShiImg"]:SetActive(true)
					break
				end
			end
		end
	end
end

function GoddessIconCell:SetRedPoint()
	self.node_list["redpoint"]:SetActive(false)
	local level = GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi
	local zhizhi_cfg = GoddessData.Instance:GetXianNvZhiziCfg(self.xiannv_id, level)
	local need_item = 0
	local need_num = 0
	if level < 1 then
		need_item = GoddessData.Instance:GetXiannvActiveItemID(self.xiannv_id, level)
		need_num = 1
	else
		need_item = zhizhi_cfg.uplevel_stuff_id
		need_num = zhizhi_cfg.uplevel_stuff_num
	end
	local bag_item_count = ItemData.Instance:GetItemNumInBagById(need_item)
	if bag_item_count >= need_num and level < GODDRESS_MAX_LEVEL then
		self.node_list["redpoint"]:SetActive(true)
	end
end

function GoddessIconCell:SetGoddessRoleView(goddess_role_view)
	self.goddess_role_view = goddess_role_view
end

--------------------------------------------------------------------------
-- 女神信息面板 RoleContent
GoddessRoleView = GoddessRoleView or BaseClass(BaseRender)

function GoddessRoleView:__init(instance)
	if nil == instance then
		return
	end
	GoddessRoleView.Instance = self
	self.node_list["BtnRename"].button:AddClickListener(BindTool.Bind(self.ChangeNameOnClick, self))

	self.current_id = -1
end

function GoddessRoleView:SetLevelValue(xiannv_level, color)
	self.node_list["TxtLv"].text.text = "Lv." .. xiannv_level .. "·"
	local name_color = self.node_list["TxtLv"]:GetComponent(typeof(UIGradient))
	if name_color then
		name_color.Color1 = Gradient_Color1[color]
		name_color.Color2 = Gradient_Color2[color]
	end
end

function GoddessRoleView:OnFlush(name, xiannv_id)
	self.current_id = xiannv_id
	local xiannv_new_name_list = GoddessData.Instance:GetXianNvNameList()
	local color = GoddessData.Instance:GetXiannvAttr(xiannv_id).color

	if xiannv_new_name_list[xiannv_id] ~= "" then
		self.node_list["Txt"].text.text = xiannv_new_name_list[xiannv_id]
	else
		self.node_list["Txt"].text.text = name
	end
	local name_color = self.node_list["Txt"]:GetComponent(typeof(UIGradient))
	if name_color then
		name_color.Color1 = Gradient_Color1[color]
		name_color.Color2 = Gradient_Color2[color]
	end
end

function GoddessRoleView:ChangeNameOnClick()
	if not GoddessData.Instance:JudgeXianIsActive(self.current_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.GoddessRoleTip)
		return
	end
	local func = function(name)
		GoddessCtrl.Instance:SendCSXiannvRename(self.current_id, name)
	end
	local num_text = ToColorStr(GoddessData.Instance:GetXianNvOtherCfg().rename_consume_gold .. "", TEXT_COLOR.GOLD)
	local str_dec1 = Language.Goddess.HuaFei
	local str_dec2 = string.format(Language.Goddess.XiuGai, num_text)
	TipsCtrl.Instance:ShowRename(func, false, nil, str_dec1, str_dec2)
end