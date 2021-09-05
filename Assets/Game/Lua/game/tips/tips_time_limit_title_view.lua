TimeLimitTitleView = TimeLimitTitleView or BaseClass(BaseView)

function TimeLimitTitleView:__init()
	self.ui_config = {{"uis/views/tips/timelimittitletips_prefab", "TimeLimitTitleView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TimeLimitTitleView:__delete()
end

function TimeLimitTitleView:ReleaseCallBack()
	TitleData.Instance:ReleaseTitleEff(self.node_list["Model"])
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self:StopCountDown()
	self.fight_text = nil
end

function TimeLimitTitleView:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:SetIsShowTips(false)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnQianGou"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnFetch"].button:AddClickListener(BindTool.Bind(self.OnCLickFetch, self))

	self.node_list["BtnUse"]:SetActive(false)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
end

function TimeLimitTitleView:CloseWindow()
	self:Close()
end

function TimeLimitTitleView:OnClickBuy()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
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
			self:Close()
		end
	end

	-- local gold_des = ToColorStr(cost_gold, TEXT_COLOR.BLUE1)
	local item_color = ITEM_COLOR[item_cfg.color]
	local item_name = ToColorStr(item_cfg.name, item_color)
	local tips_text = string.format(Language.JinJieReward.BuyTip, cost_gold, item_name)
	TipsCtrl.Instance:ShowCommonAutoView(nil, tips_text, ok_fun)
end

function TimeLimitTitleView:OnCLickFetch()
	if self.call_back then
		self.call_back(TIME_LIMIT_TITLE_CALL_TYPE.FETCH)
	end
	self:Close()
end

function TimeLimitTitleView:SetData(data)
	self.data = data
	self.call_back = data.call_back
end

function TimeLimitTitleView:OpenCallBack()
	self:Flush()
end

function TimeLimitTitleView:CloseCallBack()
	self:StopCountDown()
end

function TimeLimitTitleView:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TimeLimitTitleView:StartCountDown()
	local left_time = self.data.left_time
	local can_fetch = self.data.can_fetch
	if left_time <= 0 or can_fetch then
		self.node_list["ImgDes"]:SetActive(false)
		self.node_list["LimitTime"]:SetActive(false)
		self.node_list["TextDes"]:SetActive(false)
		return
	end
	self.node_list["ImgDes"]:SetActive(true)
	self.node_list["LimitTime"]:SetActive(true)
	self.node_list["TextDes"]:SetActive(true)

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
end

function TimeLimitTitleView:FlushTitleRes()
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

function TimeLimitTitleView:FlushItem()
	self.item_cell:SetData({item_id = self.data.item_id})
	self.item_cell:SetInteractable(false)
end

function TimeLimitTitleView:FlushContent()	
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

	--刷新属性
	self.node_list["TxtHpValue"].text.text = ToColorStr(title_cfg.maxhp or 0, TEXT_COLOR.GREEN)
	self.node_list["TxtAttackValue"].text.text = ToColorStr(title_cfg.gongji or 0, TEXT_COLOR.GREEN)
	self.node_list["TxtDefValue"].text.text = ToColorStr(title_cfg.fangyu or 0, TEXT_COLOR.GREEN)
	
	--设置战斗力
	local cap = CommonDataManager.GetCapabilityCalculation(title_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cap
	end

	--按钮显示
	local can_fetch = self.data.can_fetch
	
	self.node_list["BtnFetch"]:SetActive(can_fetch)
	self.node_list["BtnQianGou"]:SetActive(not can_fetch)
	self.node_list["TxtDiamon"]:SetActive(not can_fetch)
	

	--设置消耗
	self.node_list["TxtDiamon"].text.text = self.data.cost

	--设置倒计时
	self:StartCountDown()

	--设置描述资源
	local bundle, asset = ResPath.GetTimeLimitTitleResPath("des_" .. self.data.from_panel)
	self.node_list["ImgDes"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgDes"].image:SetNativeSize()
		end)

	if not JinJieRewardData.Instance:IsShowSmallTarget(self.data.system_type) then
		self.node_list["BtnQianGou"]:SetActive(false)
		self.node_list["TxtDiamon"]:SetActive(false)
		self.node_list["LimitTime"]:SetActive(false)
		self.node_list["ImgDes"]:SetActive(false)
		self.node_list["TextDes"]:SetActive(false)
		
	end
end

function TimeLimitTitleView:OnFlush()
	self:StopCountDown()

	self:FlushContent()
	self:FlushItem()
	self:FlushTitleRes()
end