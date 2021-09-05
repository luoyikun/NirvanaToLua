RechargeContentView = RechargeContentView or BaseClass(BaseRender)

local UnityStreamingAssetsPath = UnityEngine.Application.streamingAssetsPath

local MAX_DAY = -2
function RechargeContentView:__init(instance)
	RechargeContentView.Instance = self

	self.contain_cell_list = {}
	self:InitListView()

	if IS_AUDIT_VERSION then
		self.node_list["ListFrame"].rect.localPosition = Vector3(0, 52, 0)
		self.node_list["ListFrame"].rect.sizeDelta = Vector2(1075, 622)
	end
end

function RechargeContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.contain_cell_list = {}
	if self.time_quest_putiantongqing then
		GlobalTimerQuest:CancelQuest(self.time_quest_putiantongqing)
		self.time_quest_putiantongqing = nil
	end
end

function RechargeContentView:InitListView()
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function RechargeContentView:GetNumberOfCells()
	local recharge_id_list = RechargeData.Instance:GetRechargeIdList()
	if #recharge_id_list % 3 ~= 0 then
		return math.floor(#recharge_id_list / 3) + 1
	else
		return #recharge_id_list / 3
	end
end

function RechargeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RechargeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local id_list = RechargeData.Instance:GetRechargeListByIndex(cell_index)
	contain_cell:SetItemId(id_list)
end

function RechargeContentView:OnFlush()
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	-- 判断普天同庆活动是否已经开启，并且所有档次的充值都没有充满
	if ResetDoubleChongzhiData.Instance:IsShowPuTianTongQing() then
		self.node_list["QiQiu"]:SetActive(true and not IS_AUDIT_VERSION)
		if self.time_quest_putiantongqing == nil then
			self.time_quest_putiantongqing = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushPuTianTongQingTime, self), 1)
			self:FlushPuTianTongQingTime()
		end
	else
		self.node_list["QiQiu"]:SetActive(false)
	end
end

function RechargeContentView:FlushPuTianTongQingTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	if time <= 0 then
		if self.time_quest_putiantongqing then
			GlobalTimerQuest:CancelQuest(self.time_quest_putiantongqing)
			self.time_quest_putiantongqing = nil
		end
	end

	time_tab = TimeUtil.FormatSecond(time, 10)
	-- local str = nil
	-- if time >= 3600 * 24 then
	-- 	str = string.format(Language.Activity.ResTimeDHM, time_tab.day, time_tab.hour, time_tab.min)
	-- else
	-- 	str = string.format(Language.Activity.ResTimeHMS, time_tab.hour, time_tab.min, time_tab.s)
	-- end
	self.node_list["QiQiuTime"].text.text = time_tab
end

function RechargeContentView:SetRechargeActive(is_active)
	self.root_node:SetActive(is_active)
end


---------------------------------------------------------------
RechargeContain = RechargeContain  or BaseClass(BaseCell)

function RechargeContain:__init()
	self.recharge_contain_list = {}
	for i = 1, 3 do
		self.recharge_contain_list[i] = {}
		self.recharge_contain_list[i].recharge_item = RechargeItem.New(self.node_list["item_" .. i])
	end
end

function RechargeContain:__delete()
	for i = 1, 3 do
		self.recharge_contain_list[i].recharge_item:DeleteMe()
		self.recharge_contain_list[i].recharge_item = nil
	end
end

function RechargeContain:SetItemId(item_id_list)
	for i = 1, 3 do
		self.recharge_contain_list[i].recharge_item:SetItemId(item_id_list[i])
	end
end

function RechargeContain:OnFlushAllCell()
	for i = 1, 3 do
		self.recharge_contain_list[i].shop_item:Flush()
	end
end

----------------------------------------------------------------------------
RechargeItem = RechargeItem or BaseClass(BaseCell)

function RechargeItem:__init()
	self.node_list["BtnNode"].button:AddClickListener(BindTool.Bind(self.OnRechargeClick, self))
	self.node_list["BtnSpec"].button:AddClickListener(BindTool.Bind(self.OnRechargeClick, self))
	self.item_id = 0

	if IS_AUDIT_VERSION then
		if ResMgr.ExistedInStreaming("AgentAssets/Recharge/recharge_icon_gold.png") then
			self.node_list["ImgGold"]:SetActive(false)
			self.node_list["ImgGoldURL"]:SetActive(true)

			local path = ResUtil.GetAgentAssetPath("AgentAssets/Recharge/recharge_icon_gold.png")
			self.node_list["ImgGoldURL"].raw_image:LoadURLSprite(path)
		end
		if ResMgr.ExistedInStreaming("AgentAssets/Recharge/recharge_bg.png") then
			self.node_list["Bg"]:SetActive(false)
			self.node_list["BgURL"]:SetActive(true)

			local path = ResUtil.GetAgentAssetPath("AgentAssets/Recharge/recharge_bg.png")
			self.node_list["BgURL"].raw_image:LoadURLSprite(path)
		end
	end
	self:Flush()
end

function RechargeItem:__delete()
end

function RechargeItem:SetItemId(item_id)
	self.item_id = item_id
	self:Flush()
end

function RechargeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.item_id == RechargeData.InVaildId then
		self.root_node:SetActive(false)
		return
	end

	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	if not recharge_cfg then
		return
	end
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)

	self.node_list["Txt"].text.text = string.format("¥%s", " "..recharge_cfg.money)
	self.node_list["TxtGold"].text.text = recharge_cfg.gold

	self.node_list["NodeNormal"]:SetActive(true)
	self.node_list["NodeSpec"]:SetActive(false)

	self.node_list["ImgRedPoint"]:SetActive(false)

	self.node_list["ImgCoinIcon"]:SetActive(true)

	if recharge_cfg.id == RechargeData.SPEC_ID then

		self.node_list["NodeNormal"]:SetActive(false)
		self.node_list["NodeSpec"]:SetActive(true)

		local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
		local has_reward_day = RechargeData.Instance:GetChongZhi7DayRewardDay()
		local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()   -- 0未领取  1已领取
		local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()

		self.node_list["TxtSpecMoney"].text.text = recharge_cfg.gold
		self.node_list["ImgRedPoint"]:SetActive(has_buy_7day_rechange and is_fetch == 0)
		self.node_list["ImgUnBuy"]:SetActive(not has_buy_7day_rechange)

		if IS_AUDIT_VERSION and not has_buy_7day_rechange then
			if ResMgr.ExistedInStreaming("AgentAssets/Recharge/Diamond0.png") then
				self.node_list["ImgUnBuy"]:SetActive(false)
				self.node_list["ImgUnBuyURL"]:SetActive(true)

				local path = ResUtil.GetAgentAssetPath("AgentAssets/Recharge/Diamond0.png")
				self.node_list["ImgUnBuyURL"].raw_image:LoadURLSprite(path)

				self.node_list["ImgCoinIcon"]:SetActive(false)
				self.node_list["ImgCoinIconURL"]:SetActive(true)

				self.node_list["ImgCoinIconURL"].raw_image:LoadURLSprite(path)
			end
		end

		self.node_list["NodeSpecContent"]:SetActive(has_buy_7day_rechange)
		self.node_list["TxtSpecContent"]:SetActive(not has_buy_7day_rechange)

		local has_lingqu = has_buy_7day_rechange and is_fetch == 0
		UI:SetButtonEnabled(self.node_list["BtnSpec"], has_lingqu)
		self.node_list["BtnText"].text.text = has_lingqu and Language.Common.ExpenseLingQu or Language.Common.YiLingQu

		--local str = has_buy_7day_rechange and Language.Vip.HasBecomeSVIP or Language.Vip.ChangeToSVIP

		self.node_list["TxtSpecDesc"]:SetActive(has_buy_7day_rechange)
		self.node_list["TxtSpecDesc1"]:SetActive(not has_buy_7day_rechange)

		if IS_AUDIT_VERSION then
			self.node_list["NodeSpec"]:SetActive(false)
			self.node_list["NodeNormal"]:SetActive(true)
		end

	elseif reward_cfg and reward_cfg.extra_bind_gold > 0 then
		local bundle1, bind_gold_asset = ResPath.GetDiamonIcon("5_bind")
		self.node_list["ImgPresent"].image:LoadSprite(bundle1, bind_gold_asset .. ".png")
		self.node_list["TxtPresent"].text.text = reward_cfg.extra_bind_gold
		self:SetIcon(recharge_cfg)
	else
		local bundle, gold_asset = ResPath.GetDiamonIcon(5)
		self.node_list["ImgPresent"].image:LoadSprite(bundle, gold_asset .. ".png")
		self.node_list["TxtPresent"].text.text = reward_cfg.extra_gold
		self:SetIcon(recharge_cfg)
	end

	local is_first_chongzhi = DailyChargeData.Instance:CheckIsFirstRechargeById(recharge_cfg.id)
	if IS_AUDIT_VERSION then
		self.show_return = false
	else
		self.show_return = is_first_chongzhi
	end
	self.is_spec = recharge_cfg.id == RechargeData.SPEC_ID

	local now_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local show_flag = MAX_DAY >= now_day

	self.node_list["NodeReturn"]:SetActive(self.show_return and (not self.is_spec) and show_flag and not IS_AUDIT_VERSION)

	-- 判断普天同庆活动是否已经开启，并且所有档次的充值都没有充满
	if ResetDoubleChongzhiData.Instance:IsShowPuTianTongQing() then
		local is_buy = ResetDoubleChongzhiData.Instance:CheckIsFirstRechargeById(recharge_cfg.id)
		local bundle1, bind_gold_asset = ResPath.GetDiamonIcon("5_bind")
		self.node_list["ImgPresent"].image:LoadSprite(bundle1, bind_gold_asset .. ".png")		
		self.node_list["TxtPresent"].text.text = reward_cfg.openserver_extra_gold_bind
		self.node_list["NodeReturn"]:SetActive(not is_buy and (not self.is_spec) and not IS_AUDIT_VERSION)
	end


end

function RechargeItem:SetIcon(cfg)
	local res = cfg.gold_icon
	local bundle, asset = ResPath.GetVipIcon(res)
	local bundle0, asset0 = ResPath.GetVipIcon("bg_recharge_2_word")
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	if recharge_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID then
		if IS_AUDIT_VERSION then
			if ResMgr.ExistedInStreaming("AgentAssets/Recharge/".. res .. ".png") then
				self.node_list["ImgCoinIcon"]:SetActive(false)
				self.node_list["ImgCoinIconURL"]:SetActive(true)

				local path = ResUtil.GetAgentAssetPath("AgentAssets/Recharge/".. res .. ".png")
				self.node_list["ImgCoinIconURL"].raw_image:LoadURLSprite(path)
			end
		else
			self.node_list["ImgCoinIcon"].image:LoadSprite(bundle, asset .. ".png", function ()
				self.node_list["ImgCoinIcon"].image:SetNativeSize()
			end)
		end
	end
end

function RechargeItem:OnRechargeClick()
	-- local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	-- self:SendRecharge(recharge_cfg)
	local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
	if not open_chongzhi then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChongZhiError)
		return
	end
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	if not recharge_cfg then
		return
	end
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local vip_chongzhi_num = DailyChargeData.Instance:CheckIsFirstRechargeById(self.item_id)
	local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	if (nil == reward_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID) or not recharge_cfg then return end
	local discretion = ""
	if recharge_cfg.id == RechargeData.SPEC_ID then
		local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
		if has_buy_7day_rechange then
			RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
			return
		end
		discretion = string.format(Language.Recharge.RechargeDes, reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold)
		str_recharge = string.format(Language.Recharge.FirstBing, 18)
	else
		discretion = reward_cfg.discretion
		str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	end
	if vip_chongzhi_num == true then
		chongzhi_show_str = str_recharge .. "\n\n" .. string.format(discretion) .. "\n\n" .. Language.Recharge.WarmPrompt
	else
		chongzhi_show_str = str_recharge .. "\n\n" .. Language.Recharge.WarmPrompt
	end
	self:SendRecharge(recharge_cfg)
end

function RechargeItem:SendRecharge(recharge_cfg)
	RechargeCtrl.Instance:Recharge(recharge_cfg.money)
end
