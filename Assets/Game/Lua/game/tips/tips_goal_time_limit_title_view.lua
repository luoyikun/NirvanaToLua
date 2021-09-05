GoalTimeLimitTitleView = GoalTimeLimitTitleView or BaseClass(BaseView)

function GoalTimeLimitTitleView:__init()
	self.ui_config = {{"uis/views/tips/timelimittitletips_prefab", "TimeLimitTitleView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.get_way_list = {}
end

function GoalTimeLimitTitleView:__delete()

end

function GoalTimeLimitTitleView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- if self.item then
	-- 	self.item:DeleteMe()
	-- 	self.item = nil
	-- end

	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	self.get_way_list = {}

	self:StopCountDown()
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Model"])
	self.icon_list = nil
end

function GoalTimeLimitTitleView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.is_first = true
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:SetIsShowTips(false)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnQianGou"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnFetch"].button:AddClickListener(BindTool.Bind(self.OnCLickFetch, self))
	self.node_list["Btn_jihuo"].button:AddClickListener(BindTool.Bind(self.OnCLickJihuo, self))
	self.node_list["Btn_huanhua"].button:AddClickListener(BindTool.Bind(self.OnCLickUseHuanhua, self))
	self.node_list["Btn_cancel_huanhua"].button:AddClickListener(BindTool.Bind(self.OnCLickCancelHuanhua, self))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnBtnUse, self))
	for i = 1, 4 do
		self.node_list["GetWayIcon" .. i].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, i))
	end

	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.icon_list = {
		{icon = self.node_list["GetWayIcon1"], name = self.node_list["Name1"], bg = self.node_list["IconBg1"]},
		{icon = self.node_list["GetWayIcon2"], name = self.node_list["Name2"], bg = self.node_list["IconBg2"]},
		{icon = self.node_list["GetWayIcon3"], name = self.node_list["Name3"], bg = self.node_list["IconBg3"]},
		{icon = self.node_list["GetWayIcon4"], name = self.node_list["Name4"], bg = self.node_list["IconBg4"]},
	}
	self:ShowWay()
end

function GoalTimeLimitTitleView:CloseWindow()
	self:Close()
end

function GoalTimeLimitTitleView:OnClickWay(index)
	if nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	if self.get_way_list[index] == ViewName.Compose then
		local cfg = ComposeData.Instance:GetComposeItem(data.item_id)
		local tab_index = TabIndex.compose_stone

		if cfg ~= nil then
			if 2 == cfg.type then
				tab_index = TabIndex.compose_jinjie
			elseif 3 == cfg.type then
				tab_index = TabIndex.compose_other
			end
			ComposeData.Instance:SetToProductId(cfg.stuff_id_1)
		end
		ViewManager.Instance:Open(self.get_way_list[index], tab_index, "all", data)
	elseif self.get_way_list[index] == ViewName.DisCount then
		local activity_open = DisCountData.Instance:GetActiveState()
		local buy_info = DisCountData.Instance:GetPhaseList()
		local server_time = TimeCtrl.Instance:GetServerTime() 
		local phase_list = DisCountData.Instance:GetPhaseListBySystemId(self.sys_type)
		local cur_activity_page_list = DisCountData.Instance:GetNewPhaseList(self.sys_type)
		local can_buy_time = false
		local phase = -1
		for _, v in ipairs(phase_list) do
			if buy_info[v + 1] and buy_info[v + 1].close_timestamp > server_time then
				can_buy_time = true 
				phase = v
				break
			end
		end
		if nil ~= cur_activity_page_list then
			for i,v in ipairs(cur_activity_page_list) do
				if activity_open and can_buy_time and v.phase == phase then
					ViewManager.Instance:CloseAll()
					ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {i})
					return
				end
			end
		end
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Goal.ErrorDescribe,Language.Goal.Reward_type[self.sys_type]))
	else
		ViewManager.Instance:OpenByCfg(self.get_way_list[index], data)
	end
	
	if self.item_id == ResPath.CurrencyToIconId.shengwang then
		PlayerCtrl.Instance:FlushPlayerView("bag_recycle")
	end

	local list = Split(self.get_way_list[index], "#")
	ViewManager.Instance:CloseAllViewExceptViewName(list[1])
end

function GoalTimeLimitTitleView:OnClickBuy()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local goal_info = {}
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		goal_info = GoddessData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		goal_info = SpiritData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		goal_info = RuneData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		goal_info = HunQiData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		goal_info = ShenGeData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		goal_info = ShenYinData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		goal_info = ShenShouData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN then
		goal_info = ForgeData.Instance:GetStrengthGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE then
		goal_info = ForgeData.Instance:GetGemGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		goal_info = ShengXiaoData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		goal_info = ShenShouData.Instance:GetShengQiGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		goal_info = BianShenData.Instance:GetGoalInfo()
	end
	local cost_gold = self.data.cost
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold < cost_gold then
			TipsCtrl.Instance:ShowLackDiamondView(function()
				self:Close()
			end)
			return
		else
			if self.call_back then
				self.call_back(TIME_LIMIT_TITLE_CALL_TYPE.BUY)
			end
			if goal_info.fetch_flag[0] == 0 then
				self:Close()
			end
		end
	end

	-- local gold_des = ToColorStr(cost_gold, TEXT_COLOR.BLUE1)
	local item_color = ITEM_COLOR[item_cfg.color]
	local item_name = ToColorStr(item_cfg.name, item_color)
	local tips_text = string.format(Language.JinJieReward.BuyTip, cost_gold, item_name)
	TipsCtrl.Instance:ShowCommonAutoView(nil, tips_text, ok_fun)
end

function GoalTimeLimitTitleView:OnCLickFetch()
	if self.call_back then
		self.call_back(TIME_LIMIT_TITLE_CALL_TYPE.Goal_FETCH)
	end

	local goal_info = {}
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		goal_info = GoddessData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		goal_info = SpiritData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		goal_info = RuneData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		goal_info = HunQiData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		goal_info = ShenGeData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		goal_info = ShenYinData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		goal_info = ShenShouData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN then
		goal_info = ForgeData.Instance:GetStrengthGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE then
		goal_info = ForgeData.Instance:GetGemGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		goal_info = ShengXiaoData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		goal_info = ShenShouData.Instance:GetShengQiGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		goal_info = BianShenData.Instance:GetGoalInfo()
	end
	if goal_info.fetch_flag[0] == 0 then
		self:Close()
	end
end

function GoalTimeLimitTitleView:SetData(data, is_model, sys_type, is_other_item, close_call_back)
	self.data = data
	self.call_back = data.call_back
	self.is_model = is_model
	self.sys_type = sys_type
	self.is_other_item = is_other_item
	self.close_call_back = close_call_back
end

function GoalTimeLimitTitleView:OpenCallBack()
	self.old_res_id = nil
	self.node_list["Model2"]:SetActive(false)
	self.node_list["Model"]:SetActive(false)
	self.node_list["NodeIcons"]:SetActive(false)
	self:Flush()
end

function GoalTimeLimitTitleView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end

	self:StopCountDown()

	self.model_view:ClearModel()
	self.model_view:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	self.item_cell:SetData(nil)
	-- if self.item then
	-- 	self.item:SetData(nil)
	-- end
	self.is_first = true
	self.has_full = nil
	self.old_res_id = nil
	self.get_way_list = {}
end

function GoalTimeLimitTitleView:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GoalTimeLimitTitleView:StartCountDown()
	local left_time = self.data.left_time
	local can_fetch = self.data.can_fetch

	if left_time <= 0 or can_fetch then
		self.node_list["ImgDes"]:SetActive(false)
		self.node_list["LimitTime"]:SetActive(false)
		self.node_list["TextDes"]:SetActive(false)
		return
	end

	if not self.has_full then
		self.node_list["ImgDes"]:SetActive(true)
		self.node_list["LimitTime"]:SetActive(true)
		self.node_list["TextDes"]:SetActive(false)
	end

	local des = TimeUtil.FormatSecond(left_time, 10)
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.node_list["ImgDes"]:SetActive(false)
			self.node_list["LimitTime"]:SetActive(false)
			self.node_list["TextDes"]:SetActive(false)
			return
		end

		left_time = total_time - math.floor(elapse_time)
		des = TimeUtil.FormatSecond(left_time, 10)
		self.node_list["TxtTimeValue"].text.text = des
	end

	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)

	--先设置一次
	self.node_list["TxtTimeValue"].text.text = des

	local goal_info = {}
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		goal_info = GoddessData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		goal_info = SpiritData.Instance:GetGoalInfo()
	end
	if next(goal_info) ~= nil then
		if goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 then
			self.node_list["LimitTime"]:SetActive(false)
			self.node_list["TextDes"]:SetActive(false)
			self.node_list["ImgDes"]:SetActive(false)
			self.node_list["TxtDiamon"]:SetActive(false)
			self:StopCountDown()
		end
	end
end

function GoalTimeLimitTitleView:FlushTitleRes()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
	if title_cfg == nil then
		return
	end

	local bundle, asset = ResPath.GetTitleIcon(title_cfg.title_id)
	self.node_list["Model"]:SetActive(false)
	self.node_list["Model"].image:LoadSprite(bundle, asset, function()
			self.node_list["Model"].image:SetNativeSize()
			self.node_list["Model"].transform.localScale = Vector3(1.6, 1.6, 1.6)
			self.node_list["Model"]:SetActive(true)
		end)
	TitleData.Instance:LoadTitleEff(self.node_list["Model"], title_cfg.title_id or 0, true)
end

function GoalTimeLimitTitleView:FlushItem()
	self.item_cell:SetData({item_id = self.data.item_id})
	self.item_cell:SetInteractable(false)
end

function GoalTimeLimitTitleView:FlushContent()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
	if title_cfg == nil then
		return
	end

	--刷新名字
	self.node_list["EquaipName"].text.text = item_cfg.name

	--设置类型
	self.node_list["Txt_type"].text.text = Language.Goal.TxtType .. Language.Goal.TypeTitle

	--刷新属性
	self.node_list["TxtHpValue"].text.text = ToColorStr(title_cfg.maxhp, TEXT_COLOR.GREEN)
	self.node_list["TxtAttackValue"].text.text = ToColorStr(title_cfg.gongji, TEXT_COLOR.GREEN)
	self.node_list["TxtDefValue"].text.text = ToColorStr(title_cfg.fangyu, TEXT_COLOR.GREEN)
	self.node_list["Txt_add_Attr"]:SetActive(false)
	
	--设置战斗力
	local cap = CommonDataManager.GetCapabilityCalculation(title_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cap
	end

	--按钮显示
	local can_fetch = self.data.can_fetch
	
	if not self.has_full then
		self.node_list["BtnFetch"]:SetActive(can_fetch)
		self.node_list["BtnQianGou"]:SetActive(not can_fetch)
		self.node_list["TxtDiamon"]:SetActive(not can_fetch)
	end
	

	--设置消耗
	self.node_list["TxtDiamon"].text.text = self.data.cost

	--设置倒计时
	self:StartCountDown()

end

function GoalTimeLimitTitleView:FlushImgDes()
	local goal_info = {}
	local goal_type = 0
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		goal_info = GoddessData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		goal_info = SpiritData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		goal_info = RuneData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		goal_info = HunQiData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		goal_info = ShenGeData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		goal_info = ShenYinData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		goal_info = ShenShouData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN then
		goal_info = ForgeData.Instance:GetStrengthGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE then
		goal_info = ForgeData.Instance:GetGemGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		goal_info = ShengXiaoData.Instance:GetGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		goal_info = ShenShouData.Instance:GetShengQiGoalInfo()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		goal_info = BianShenData.Instance:GetGoalInfo()
	end

	if goal_info.fetch_flag[0] == 0 and goal_info.fetch_flag[1] == 0 then
		goal_type = 0
	elseif goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 0 then
		goal_type = 1
	end
	local bundle,asset = ResPath.GetGoalDesImg(self.sys_type, goal_type)
	self.node_list["ImgDes"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgDes"].image:SetNativeSize()
		end)
	if goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 then
		self.node_list["ImgDes"]:SetActive(false)
		self.node_list["LimitTime"]:SetActive(false)
		self.node_list["NodeIcons"]:SetActive(false)
		self.node_list["TextDes"]:SetActive(false)
		self.node_list["TxtDiamon"]:SetActive(false)
		self.has_full = true
	end
end


function GoalTimeLimitTitleView:OnFlush()
	self:FlushImgDes()
	self:FlushButtons()
	self:StopCountDown()
	self:FlushItem()
	self:ShowWay()

	if not self.is_model and not self.is_other_item then
		self:FlushContent()
		self:FlushTitleRes()
	elseif not self.is_other_item and self.is_model then
		self:FlushModelContent()
		self:FlushModelRes()
	elseif self.is_other_item then
		self:FlushItemContent()
		self:FlushItemRes()
	end
end

function GoalTimeLimitTitleView:FlushButtons()
	self.node_list["BtnQianGou"]:SetActive(false)
	self.node_list["BtnFetch"]:SetActive(false)
	self.node_list["Btn_jihuo"]:SetActive(false)
	self.node_list["Btn_huanhua"]:SetActive(false)
	self.node_list["Btn_cancel_huanhua"]:SetActive(false)

	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		local goal_info = GoddessData.Instance:GetGoalInfo()
		local huanhua_flag_list = GoddessData.Instance:GetXianNvHuanHuaFlag()
		local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(self.data.item_id)
		local active = true

		if huanhua_id and huanhua_flag_list[huanhua_id] == 0 then
			active = false
		end
		if goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and not active then
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["Btn_jihuo"]:SetActive(true)
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["BtnFetch"]:SetActive(false)
		elseif goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and active then
			local huanhua_use_id = GoddessData.Instance:GetHuanHuaId()
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["BtnFetch"]:SetActive(false)
			self.node_list["Btn_jihuo"]:SetActive(false)
			if huanhua_use_id ~= huanhua_id then
				self.node_list["Btn_huanhua"]:SetActive(true)
				self.node_list["Btn_cancel_huanhua"]:SetActive(false)
			else
				self.node_list["Btn_huanhua"]:SetActive(false)
				self.node_list["Btn_cancel_huanhua"]:SetActive(true)
			end
		end
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local spirit_info = SpiritData.Instance:GetSpiritInfo()
		local goal_info = SpiritData.Instance:GetGoalInfo()
		local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(self.data.item_id)
		if spirit_info == nil or type_cfg == nil then
			return
		end
		local huanhua_id = type_cfg.active_image_id
		local bit_list = spirit_info.special_img_active_flag
		local active = bit_list[huanhua_id] == 1
		if goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and not active then
			self.node_list["Btn_jihuo"]:SetActive(true)
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["BtnFetch"]:SetActive(false)
		elseif goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and active then
			local use_huanhua_id = spirit_info.phantom_imageid
			self.node_list["BtnQianGou"]:SetActive(false)
			self.node_list["BtnFetch"]:SetActive(false)
			self.node_list["Btn_jihuo"]:SetActive(false)
			if use_huanhua_id ~= huanhua_id then
				self.node_list["Btn_huanhua"]:SetActive(true)
				self.node_list["Btn_cancel_huanhua"]:SetActive(false)
			else
				self.node_list["Btn_huanhua"]:SetActive(false)
				self.node_list["Btn_cancel_huanhua"]:SetActive(true)
			end
		end
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		local goal_info =  BianShenData.Instance:GetGoalInfo()
		local big_goal_cfg = BianShenData.Instance:GetBigGoalCfg()
		local bianshen_current_use_huanhua_id = BianShenData.Instance:GetCurrentUseHuanHuaId()
		local active = BianShenData.Instance:GetHuanHuaIsActive(1)
		if goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and not active then
			self.node_list["Btn_jihuo"]:SetActive(true)
			self.node_list["Btn_huanhua"]:SetActive(false)
			self.node_list["Btn_cancel_huanhua"]:SetActive(false)
		elseif goal_info.fetch_flag[0] == 1 and goal_info.fetch_flag[1] == 1 and active then
			self.node_list["Btn_jihuo"]:SetActive(false)
			self.node_list["BtnFetch"]:SetActive(false)
			self.node_list["BtnQianGou"]:SetActive(false)
			if bianshen_current_use_huanhua_id ~= big_goal_cfg.id then
				self.node_list["Btn_huanhua"]:SetActive(true)
				self.node_list["Btn_cancel_huanhua"]:SetActive(false)
			else
				self.node_list["Btn_huanhua"]:SetActive(false)
				self.node_list["Btn_cancel_huanhua"]:SetActive(true)
			end
		end
	end

	local temp_goal_info = RuneData.Instance:GetGoalInfoInAll(self.sys_type)
	if self.data.from_panel == "bag_view" and temp_goal_info and temp_goal_info.fetch_flag[0] == 1 and temp_goal_info.fetch_flag[1] == 1 and temp_goal_info.active_special_attr_flag == 0 then
		self.node_list["BtnUse"]:SetActive(true)
	else
		self.node_list["BtnUse"]:SetActive(false)
	end
end

function GoalTimeLimitTitleView:FlushItemContent()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	--刷新名字
	self.node_list["EquaipName"].text.text = item_cfg.name

	--设置类型
	self.node_list["Txt_type"].text.text = Language.Goal.TxtType .. Language.Goal.Reward_type[self.sys_type]

	local power = 0
	local attr_list = RuneData.Instance:GetGoalCfg(self.sys_type)
	if attr_list == nil then
		return
	end

	local percent_cap = 0
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		--战魂
		local attr = RuneData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		--异火
		local attr = HunQiData.Instance:GetAllAttrInfo()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)		
		-- print_error(attr, percent_cap)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		--星辉
		local attr = ShenGeData.Instance:GetShenGeAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)		
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		--铭纹
		local attr = ShenYinData.Instance:GetAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN then
		--锻造强化等级
		local attr = ForgeData.Instance:GetEquipAllStrengthAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE then
		--锻造宝石等级
		local attr = ForgeData.Instance:GetEquipAllStoneAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		--生肖
		local attr = ShengXiaoData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	end


	self.node_list["TxtHpValue"].text.text = ToColorStr(attr_list.max_hp or 0, TEXT_COLOR.GREEN)
	self.node_list["TxtAttackValue"].text.text = ToColorStr(attr_list.gongji or 0, TEXT_COLOR.GREEN)
	self.node_list["TxtDefValue"].text.text = ToColorStr(attr_list.fangyu or 0, TEXT_COLOR.GREEN)
	local cap = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight_text.text.text = cap + math.floor(percent_cap * attr_list.add_per / 10000)
	self.node_list["Txt_add_Attr"]:SetActive(true)
	self.node_list["Txt_add_Attr"].text.text = string.format(Language.Goal.BaseAttrAdd, attr_list.add_per/100) .. "%"

	--按钮显示
	local can_fetch = self.data.can_fetch
	if not self.has_full then
		self.node_list["BtnFetch"]:SetActive(can_fetch)
		self.node_list["BtnQianGou"]:SetActive(not can_fetch)
		self.node_list["TxtDiamon"]:SetActive(not can_fetch)
	end

	--设置消耗
	self.node_list["TxtDiamon"].text.text = self.data.cost

	--设置倒计时
	self:StartCountDown()
end

function GoalTimeLimitTitleView:FlushItemRes()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	if self.sys_type ~= ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		-- if self.item ==nil then
		-- 	self.item = ItemCell.New()
		-- 	self.item:SetInstanceParent(self.node_list["Model2"])
		-- 	self.item:SetIsShowTips(false)
		-- end
		-- self.item:SetData({item_id = self.data.item_id})
		local bundle,asset = ResPath.GetBigGoalImg(self.sys_type)
		self.node_list["Model2"].image:LoadSprite(bundle, asset, function()
				self.node_list["Model2"].image:SetNativeSize()
			end)
		self.node_list["Shenge_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
		self.node_list["Shenyin_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
		self.node_list["Yihuo_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
		self.node_list["Strength_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
		self.node_list["Gem_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
		self.node_list["Shengxiao_Effect"]:SetActive(self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
		self.node_list["Rune_Effect"]:SetActive(false)
	else
		self.node_list["Rune_Effect"]:SetActive(true)
	end
	self.node_list["Model2"]:SetActive(true)

end

function GoalTimeLimitTitleView:FlushModelContent()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	--刷新名字
	self.node_list["EquaipName"].text.text = item_cfg.name

	--设置类型
	self.node_list["Txt_type"].text.text = Language.Goal.TxtType .. Language.Goal.Reward_type[self.sys_type]

	-- --刷新属性
	local type_cfg = {}
	local percent_cap = 0
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(item_id)
		type_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(huanhua_id)
		local attr = GoddessData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local SpecialSpiritImageCfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(item_id)
		local huanhua_id = SpecialSpiritImageCfg.active_image_id
		type_cfg = SpiritData.Instance:GetSpecialImageCfgByID(huanhua_id, 1)
		local attr = SpiritData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		type_cfg = RuneData.Instance:GetGoalCfg(self.sys_type)
		percent_cap = ShenShouData.Instance:GetShenShouEquipAllAttr()
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		type_cfg = ShenShouData.Instance:GetGoalCfg(self.sys_type)
		local attr = ShenShouData:GetShenShouShenQiAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		type_cfg = BianShenData.Instance:GetGoalCfg(self.sys_type)
		local attr = BianShenData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	end

	local attr_list = RuneData.Instance:GetGoalCfg(self.sys_type)
	if type_cfg ~= nil and next(type_cfg) ~= nil then
		self.node_list["TxtHpValue"].text.text = ToColorStr(type_cfg.maxhp or type_cfg.max_hp, TEXT_COLOR.GREEN)
		self.node_list["TxtAttackValue"].text.text = ToColorStr(type_cfg.gongji, TEXT_COLOR.GREEN)
		self.node_list["TxtDefValue"].text.text = ToColorStr(type_cfg.fangyu, TEXT_COLOR.GREEN)
		local cap = CommonDataManager.GetCapabilityCalculation(type_cfg)
		self.fight_text.text.text = cap + math.floor(percent_cap * attr_list.add_per / 10000)
	else
		self.node_list["TxtHpValue"].text.text = ToColorStr(0, TEXT_COLOR.GREEN)
		self.node_list["TxtAttackValue"].text.text = ToColorStr(0, TEXT_COLOR.GREEN)
		self.node_list["TxtDefValue"].text.text = ToColorStr(0, TEXT_COLOR.GREEN)
		self.fight_text.text.text = 0
	end

	self.node_list["Txt_add_Attr"]:SetActive(true)
	self.node_list["Txt_add_Attr"].text.text = string.format(Language.Goal.BaseAttrAdd, attr_list.add_per/100) .. "%"


	--按钮显示
	local can_fetch = self.data.can_fetch
	
	if not self.has_full then
		self.node_list["BtnFetch"]:SetActive(can_fetch)
		self.node_list["BtnQianGou"]:SetActive(not can_fetch)
		self.node_list["TxtDiamon"]:SetActive(not can_fetch)
	end

	--设置消耗
	self.node_list["TxtDiamon"].text.text = self.data.cost

	--设置倒计时
	self:StartCountDown()
end

function GoalTimeLimitTitleView:FlushModelRes()
	if nil ~= self.model_view then
		self.node_list["Display"].ui3d_display:ResetRotation()
	end
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV and self.old_res_id ~= self.data.item_id then
		local _, res_id = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(self.data.item_id)
		local bundle, asset = ResPath.GetGoddessModel(res_id)
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(Vector3(0, 0, 0))
		self.model_view:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
		self.old_res_id = self.data.item_id
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(self.data.item_id)
		if type_cfg == nil then
			return
		end
		local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
		if not self.is_first and goal_cfg_info and self.data.item_id == goal_cfg_info.reward_item[0].item_id then
			return
		end
		self.is_first = false
		local bundle, asset = ResPath.GetSpiritModel(type_cfg.res_id)
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(Vector3(0, -30, 0))
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		local bundle, asset = "actors/longqi/10011_prefab", "10011"
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(Vector3(0, 0, 0))
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		local bundle, asset = "actors/shengqi/1101_prefab", "1101"
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(Vector3(0, 0, 0))
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		local big_goal_cfg = BianShenData.Instance:GetBigGoalCfg()
		if big_goal_cfg.res_id ~= self.old_res_id then
			local bundle, asset = ResPath.GetMingJiangRes(big_goal_cfg.res_id)
			self.model_view:SetMainAsset(bundle, asset, function()
				self.model_view:SetRotation(Vector3(0, 0, 0))
				self.model_view:SetScale(Vector3(1.2, 1.2, 1.2))
				self.model_view:SetTrigger(ANIMATOR_PARAM.REST)
				self.old_res_id = big_goal_cfg.res_id
			end)
		end
	end
end

function GoalTimeLimitTitleView:OnCLickJihuo()
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(self.data.item_id)
		local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(self.data.item_id),self.data.item_id)
		if num > 0 then
			GoddessCtrl.Instance:SendXiannvActiveHuanhua(huanhua_id,ItemData.Instance:GetItemIndex(self.data.item_id))
		end
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(self.data.item_id)
		if type_cfg == nil then
			return
		end
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, type_cfg.active_image_id, "")
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		local index = ItemData.Instance:GetItemIndex(self.data.item_id)
		PackageCtrl.Instance:SendUseItem(index, 1, nil, nil)
	end
end

function GoalTimeLimitTitleView:OnCLickUseHuanhua()
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(self.data.item_id)
		if huanhua_id ~= nil then
			GoddessCtrl.Instance:SentXiannvImageReq(huanhua_id)
		end
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(self.data.item_id)
		if type_cfg == nil then
			return
		end
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, type_cfg.active_image_id, "")
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		local big_goal_cfg = BianShenData.Instance:GetBigGoalCfg()
		if big_goal_cfg then
			BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_USE_HUANHUA_ID, big_goal_cfg.id)
		end
	end
end

function GoalTimeLimitTitleView:OnCLickCancelHuanhua()
	if self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		GoddessCtrl.Instance:SentXiannvImageReq(-1)
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, -1, "")
	elseif self.sys_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_USE_HUANHUA_ID, 0)
	end
end

function GoalTimeLimitTitleView:OnBtnUse()
	local bag_data = ItemData.Instance:GetItem(self.data.item_id)
	self:Close()
	if bag_data  then
		PackageCtrl.Instance:SendUseItem(bag_data.index, 1, bag_data.sub_type)
	end
end

function GoalTimeLimitTitleView:ShowWay()
	if not self.data then
		self.node_list["NodeIcons"]:SetActive(false)
		return
	end 
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg or not next(item_cfg) then
		self.node_list["NodeIcons"]:SetActive(false)
		return
	end
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for _, v in ipairs(self.icon_list) do
		v.bg:SetActive(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				local left_time = self.data.left_time
				self.node_list["NodeIcons"]:SetActive(not self.has_full and left_time > 0)
				if tonumber(v) == 0 then
					self.icon_list[k].icon:SetActive(true)
					self.icon_list[k].bg:SetActive(true)
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon.image:LoadSprite(bundle, asset)
					self.icon_list[k].name.image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].icon:SetActive(true)
					self.icon_list[k].bg:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon(getway_cfg_k.icon)
					self.icon_list[k].icon.image:LoadSprite(bundle, asset)
					self.icon_list[k].name.image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_list[k].name.image:SetNativeSize()
					end)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["NodeIcons"]:SetActive(false)
				if v == 0 then
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	end
end
