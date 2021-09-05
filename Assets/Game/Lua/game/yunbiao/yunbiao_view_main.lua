YunbiaoViewMain = YunbiaoViewMain or BaseClass(BaseRender)

local delay_time = 0.3

function YunbiaoViewMain:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["Toggle"].toggle.isOn = YunbiaoData.Instance:GetToggleRed() or false
	self.auto_buy = false

	self.carriage = {}
	self.model_play_list = {}
	for i = 1, 5 do
		self.carriage[i] = {}
		self.carriage[i].show_high_light = self.node_list["HlFrame" .. i]
		self.carriage[i].exp = self.node_list["TxtCount" .. i]
		self.carriage[i].mache = YunbiaoMaCheCell.New(self.node_list["MaChe" .. i])
		self.model_play_list[i] = self.node_list["Display" .. i]
	end

	self.node_list["StartHusongBtn"].button:AddClickListener(BindTool.Bind(self.DealClickHuSong, self))
	self.node_list["BtnFlush"].button:AddClickListener(BindTool.Bind(self.OnClickFlush, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["Toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickToggleRed, self))
	self.node_list["BtnChouJiang"].button:AddClickListener(BindTool.Bind(self.ClickTurntalbe, self))

	self.last_color = YunbiaoData.Instance:GetTaskColor() or 1
	self.guide_husong_color = 0

	self.item_change = BindTool.Bind(self.ItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)

	self:ItemChange()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.YunbiaoView, BindTool.Bind(self.GetUiCallBack, self))
	self:Flush()
	self:FlushModel()
end

function YunbiaoViewMain:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.YunbiaoView)
	end

	self:RemoveCountDown()
	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	for k,v in pairs(self.carriage) do
		if v.mache then
			v.mache:DeleteMe()
		end
	end
	self.carriage = {}
	self.auto_buy = nil

	for i = 1, 5 do
		if nil ~= self.model[i] then
			--self.model[i]:ClearModel()
			self.model[i]:DeleteMe()
		end
	end
end

function YunbiaoViewMain:FlushModel()
	local task_reward_factor_list = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_factor_list
	self.model = {}
	for i = 1, 5 do
		if nil == self.model[i] then
			local dispalay_name = "escort_panel_"..i
			self.model[i] = RoleModel.New(dispalay_name)
			self.model[i]:SetDisplay(self.model_play_list[i].ui3d_display, nil, true)

			if i == 1 then
				self.model[i]:SetRotation(Vector3(5, 0, 0))
				self.model[i]:SetScale(Vector3(0.9, 0.9, 0.9))
			elseif i == 2 then
				self.model[i]:SetRotation(Vector3(10, 0, 0))
			elseif i == 3 then
				self.model[i]:SetRotation(Vector3(5, -5, 0))
			elseif i == 5 then
				self.model[i]:SetScale(Vector3(1.1, 1.1, 1.1))									
			end
		end
		local asset, bundle = ResPath.GetNpcModel(task_reward_factor_list[i].show_model)
		self.model[i]:SetMainAsset(asset, bundle)
	end
end


function YunbiaoViewMain:SetGuideHusongColor(color)
	self.guide_husong_color = color
end

function YunbiaoViewMain:ClickTurntalbe()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end


function YunbiaoViewMain:Flush()
	local rest_count = math.max(0, YunbiaoData.Instance:GetHusongRemainTimes())
	self.node_list["TxtRestCount"].text.text = rest_count

	local buy_count = math.max(0, YunbiaoData.Instance:GetMaxGoumaiNum())
	self.node_list["TxtBuycount"].text.text = buy_count

	local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
	self.node_list["TxtFreeNum"].text.text = string.format(Language.YunBiao.LeftTime, free_times)
	self.node_list["TxtFreeNum"]:SetActive(free_times > 0)
	self.node_list["TxtCostCount"]:SetActive(free_times <= 0)

	local husong_act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	local reward_config = YunbiaoData.Instance:GetRewardConfig()
	if reward_config then
		for i = 1, 5 do
			if reward_config[i] then
				local exp = reward_config[i].exp or 0
				local str = ""
				-- if exp > 99999999 then
				-- 	exp = exp / 100000000
				-- 	exp = string.format("%.1f", exp)
				-- 	str = ToColorStr(exp .. Language.Common.Yi, TEXT_COLOR.LIGHTYELLOW)
				-- 	if husong_act_isopen then
				-- 		str = ToColorStr(exp .. Language.Common.Yi, TEXT_COLOR.LIGHTYELLOW) .. "x2"
				-- 	end
				-- else
				-- 	str = CommonDataManager.ConverNum(exp)
				-- 	if husong_act_isopen then
				-- 		str = CommonDataManager.ConverNum(exp) .. "x2"
				-- 	end
				-- end
				str = ToColorStr(CommonDataManager.ConverMoney2(exp), TEXT_COLOR.LIGHTYELLOW)
				if husong_act_isopen then
					str = str .. "x2"
				end
				self.carriage[i].exp.text.text = str
			end
		end
	end

	for i = 1, 5 do
		self.carriage[i].show_high_light:SetActive(false)
	end

	if self.guide_husong_color > 0 then
		if self.carriage[self.last_color] then
			self.carriage[self.last_color].mache:StopShake()
			self.carriage[self.last_color].show_high_light:SetActive(false)
		end
		self:FlushHighLight(self.guide_husong_color, self.guide_husong_color)
	else
		local level = YunbiaoData.Instance:GetTaskColor()
		if level > self.last_color then
			self:FlushHighLight(self.last_color + 1, level)
		else
			self:FlushHighLight(self.last_color, level)
		end

		self.last_color = level

		self:ItemChange()
	end
	local show_effect = WelfareData.Instance:GetTurnTableRewardCount()
	self.node_list["Effect"]:SetActive(show_effect ~= 0)
end

function YunbiaoViewMain:Close()
	ViewManager.Instance:Close(ViewName.YunbiaoView)
end

function YunbiaoViewMain:FlushHighLight(last_color, next_color)
	if last_color < 1 or next_color > 5 then return end
	self:RemoveCountDown()
	self.carriage[last_color].show_high_light:SetActive(true)
	self.carriage[last_color].mache:StartShake()
	self.count_down = CountDown.Instance:AddCountDown((next_color - last_color + 1) * delay_time, delay_time,
		function()
			if self.carriage[last_color - 1] then
				self.carriage[last_color - 1].mache:StopShake()
				self.carriage[last_color - 1].show_high_light:SetActive(false)
			end
			if self.carriage[last_color] then
				self.carriage[last_color].mache:StartShake()
				self.carriage[last_color].show_high_light:SetActive(true)
			end
			last_color = last_color + 1
		end)
end

function YunbiaoViewMain:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function YunbiaoViewMain:OnClickFlush()
	if YunbiaoData.Instance:GetTaskColor() ~= 5 then
		if self.node_list["Toggle"].toggle.isOn then
			local describe = Language.YunBiao.YiJianAlert
			local yes_func = function() YunbiaoCtrl.Instance:SendRefreshHusongTask(1, 1) end
			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		else
			local number = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id)
			local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
			if number < 1 and free_times < 1 then
				if self.auto_buy then
					YunbiaoCtrl.Instance:SendRefreshHusongTask(0, 1)
				else
					local func = function(item_id, num, is_bind, is_tip_use, is_buy_quick)
					 	ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0)
					 	self.auto_buy = is_buy_quick
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, YunbiaoData.Instance.yunbiao_item_id, nil, 1)
				end
			else
				YunbiaoCtrl.Instance:SendRefreshHusongTask(0, 0)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.MaxLevel)
	end
end

function YunbiaoViewMain:OnClickPlus()
	local free_count = YunbiaoData.Instance:GetFreeHusongNum()
	local goumaicishu = YunbiaoData.Instance:GetGouMaiCishu() + 1
	local can_buy_count = YunbiaoData.Instance:GetMaxGoumaiNum()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local next_level, next_times = VipPower.Instance:GetNextVipLevelLimint(VipPowerId.husong_buy_times, vip_level)

	-- if next_level > 0 or can_buy_count > 0 then
		local ok_fun = function ()
			YunbiaoCtrl.Instance:SendHusongBuyTimes()
		end
		local flag = next_level > 0 or can_buy_count > 0
		local cost = flag and YunbiaoData.Instance:GetBuyHusonGold()[goumaicishu].gold_cost or YunbiaoData.Instance:GetBuyHusonGold()[goumaicishu - 1].gold_cost
		local cfg = ""
		if free_count > 0 then
			cfg = string.format(Language.TowerDefend.BuyTip4, cost)
		else
			cfg = string.format(Language.TowerDefend.BuyTip, cost)
		end

		local data_fun = function ()
			local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
			local data = {}
			data[2] = YunbiaoData.Instance:GetGouMaiCishu() or 0
			data[1] = cost
			data[3] = VipData.Instance:GetVipPowerList(vip_level)[VipPowerId.husong_buy_times]
			data[4] = VipPower:GetParam(VipPowerId.husong_buy_times, true)
			return data
		end
		local data = data_fun()
		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VipPowerId.husong_buy_times, ok_fun, data_fun, 1, cfg)
	-- else
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.GouMaiTips2)
	-- end
end

-- 接护送任务
function YunbiaoViewMain:DealClickHuSong()
	if self.guide_husong_color > 0 then
		self.guide_husong_color = 0
		self:Close()
		return
	end

	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if scene_key ~= 0 then
		local describe = Language.YunBiao.CanNotRceive
		local yes_func = function() Scene.SendChangeSceneLineReq(0) end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		return
	end
	local act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	if act_isopen then
		self:SendHusongReq()
	else
		local activity_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.HUSONG)
		local describe = ""
		if activity_cfg then
			describe = string.format(Language.YunBiao.HuoDongShiJian, activity_cfg.open_time, activity_cfg.end_time)
		end
		local yes_func = BindTool.Bind(self.SendHusongReq, self)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function YunbiaoViewMain:SendHusongReq()
	local task_id = YunbiaoData.Instance:GetTaskIdByCamp()
	if task_id then
		TaskCtrl.SendTaskAccept(task_id)
	end
end

function YunbiaoViewMain:OnClickHelp()
	local str = Language.YunBiao.Tip
	TipsCtrl.Instance:ShowHelpTipView(str)
end

function YunbiaoViewMain:OnClickToggleRed(state)
	YunbiaoData.Instance:SetToggleRed(state)
end

function YunbiaoViewMain:ItemChange()
	local count = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id) or 0
	local color = TEXT_COLOR.PURPLE
	if count <= 0 then
		color = TEXT_COLOR.RED
	end
	self.node_list["TxtCostCount"].text.text = string.format(Language.YunBiao.Cost, color, 1, count)
end

function YunbiaoViewMain:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

------------------------------------------------------------------MaChe---------------------------------------------------------------

YunbiaoMaCheCell = YunbiaoMaCheCell or BaseClass(BaseCell)

function YunbiaoMaCheCell:__init()
	-- self.box_close = self.node_list["BoxClose"]
	-- self.box_open = self.node_list["BoxOpen"]
	-- self.box_close:SetActive(true)
	-- self.box_open:SetActive(false)
	-- self.anim = self.box_close:GetComponent(typeof(UnityEngine.Animator))
end

function YunbiaoMaCheCell:__delete()
	--self:RemoveDelayTime()
end

function YunbiaoMaCheCell:StartShake()
	-- self.box_open:SetActive(false)
	-- self.box_close:SetActive(true)
	-- if self.anim then
	-- 	self.anim:SetBool("Shake", true)
	-- end
	--self:RemoveDelayTime()
	--self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:OpenBox() end, 0.5)
end

function YunbiaoMaCheCell:StopShake()
	-- self.box_open:SetActive(false)
	-- self.box_close:SetActive(true)
	-- if self.anim then
	-- 	self.anim:SetBool("Shake", false)
	-- end
	--self:RemoveDelayTime()
end

function YunbiaoMaCheCell:OpenBox()
	--self:RemoveDelayTime()
	-- self.box_open:SetActive(true)
	-- self.box_close:SetActive(false)
	-- if self.anim then
	-- 	self.anim:SetBool("Shake", false)
	-- end
end

function YunbiaoMaCheCell:RemoveDelayTime()
	-- if self.delay_time then
	-- 	GlobalTimerQuest:CancelQuest(self.delay_time)
	-- 	self.delay_time = nil
	-- end
end