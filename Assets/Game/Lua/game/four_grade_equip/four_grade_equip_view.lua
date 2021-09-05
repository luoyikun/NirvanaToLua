FourGradeEquipView = FourGradeEquipView or BaseClass(BaseView)

function FourGradeEquipView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFive_1"},
		{"uis/views/fourgradeequip_prefab", "FourGradeEquip"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFive_2"},
	}

	self.is_modal = true
	self.is_any_click_close = true


end

function FourGradeEquipView:__delete()

end

function FourGradeEquipView:ReleaseCallBack()
	self.fight_text = nil

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model then
		self.model:DeleteMe()
	end
	self.model = nil	
	self:CancelTimeCountDown()
end

function FourGradeEquipView:LoadCallBack()
	self.node_list["NameTxt"]:SetActive(false)
	self.node_list["NameTxt2"]:SetActive(true)
	self.node_list["NameTxt2"].text.text = Language.Activity.FourGradeEquip

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnRewardGold"].button:AddClickListener(BindTool.Bind(self.OnBtnRewardGold, self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)

	self.day_btn_list = {}
	for i = 1, 3 do
		self.day_btn_list[i] = self.node_list["Btn" .. i]
		self.day_btn_list[i].button:AddClickListener(BindTool.Bind(self.OnClickBtn,self, i))
	end

	self.item_list = {}
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightText"])
end

function FourGradeEquipView:OpenCallBack()
	FourGradeEquipData.Instance:SetFourGradeIconFirstOpen(false)
	MainUICtrl.Instance:GetView():ShowFourGradeEquipXianshi()

	self:SetModel()
	-- self:OnClickBtn(1)
	local cfg = FourGradeEquipData.Instance:GetFourGradeEquipCfg()
	if nil == cfg then 
		return
	end
	for i = 1, 3 do
		local is_get_reward = FourGradeEquipData.Instance:GetFourGradeEquipRewardIsGet(i)
		if 0 == is_get_reward then
			self:OnClickBtn(i)
			break
		end
	end

	for i = 1, 3 do
		local gift_list = cfg["reward_item_list_" .. (i - 1)]
		local gift_item = (gift_list and gift_list[0])and gift_list[0].item_id or 0
		local item_data_list = ItemData.Instance:GetGiftItemList(gift_item)
		if nil == item_data_list or nil == item_data_list[1] or nil == item_data_list[1].item_id then return end

		local item_cfg = ItemData.Instance:GetItemConfig(item_data_list[1].item_id)
		if nil == item_cfg then return end

		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["Icon" .. i].image:LoadSprite(bundle, asset)

		local index_level = cfg["level_limit_" .. (i - 1)]
		self.node_list["Desc" .. i].text.text = string.format(Language.Activity.FourGradeEquipDesc, index_level)
	end

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if open_day < cfg.end_day then
		local function now_daytime_start(now_time)
			local tab = os.date("*t", now_time)
			tab.hour = 0
			tab.min = 0
			tab.sec = 0
			local result = os.time(tab)
			return result
		end

		local surplus_day = cfg.end_day - open_day - 1
		local day_start_timr = now_daytime_start(TimeCtrl.Instance:GetServerTime())
		local day_surplus_time = day_start_timr + (24 * 60 * 60) - TimeCtrl.Instance:GetServerTime()
		day_surplus_time = day_surplus_time + surplus_day * (24 * 60 * 60)

		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(day_surplus_time - elapse_time + 0.5)
			if left_time <= 0 then
				self:CancelTimeCountDown()
				self.node_list["TimeText"]:SetActive(false)
				return
			end
			if left_time > 0 then
				self.node_list["TimeText"]:SetActive(true)
				self.node_list["TimeText"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(left_time, 10))
			else
				self.node_list["TimeText"]:SetActive(false)
			end
		end

		diff_time_func(0, day_surplus_time)
		self.count_down = CountDown.Instance:AddCountDown(
			day_surplus_time, 0.5, diff_time_func)		
	else
		self.node_list["TimeText"]:SetActive(false)
	end

	self:Flush()
end


function FourGradeEquipView:CancelTimeCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FourGradeEquipView:CloseCallBack()
	self:CancelTimeCountDown()
	MainUICtrl.Instance:GetView():ShowFourGradeEquipXianshi()
end

function FourGradeEquipView:OnClickBtn(index)
	self.click_index = index

	for i = 1, 3 do
		self.node_list["HL" .. i]:SetActive(i == index)
	end

	self:Flush()
end

function FourGradeEquipView:OnFlush()
	local cfg = FourGradeEquipData.Instance:GetFourGradeEquipCfg()
	if nil == self.click_index or nil == cfg then
		return 
	end

	local index = self.click_index

	local gift_list = cfg["reward_item_list_" .. (index - 1)]
	local gift_item = (gift_list and gift_list[0])and gift_list[0].item_id or 0
	local item_data_list = ItemData.Instance:GetGiftItemList(gift_item)

	local effect_list = Split(cfg.effect_index or "", ",")
	for k, v in pairs(effect_list) do
		if self.item_list[tonumber(v)] then
			self.item_list[tonumber(v)]:SetShowOrangeEffect(true)
		end
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, 3 do
		local is_get_reward = FourGradeEquipData.Instance:GetFourGradeEquipRewardIsGet(i)
		if FourGradeEquipData.Instance:GetFourGradeEquipIsBuy() then
			if cfg["level_limit_" .. (i - 1)] <= role_level and 0 == is_get_reward then
				self.node_list["RedPoint" .. i]:SetActive(true)
			else
				self.node_list["RedPoint" .. i]:SetActive(false)
			end
		else
			self.node_list["RedPoint" .. i]:SetActive(false)
		end
	end

	-- ItemCell
	for k,v in pairs(self.item_list) do
		local item_data = item_data_list[k]
		v:Reset()
		if item_data and item_data.item_id then
			local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
			v:SetGiftItemId(gift_item)
			if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
				local equip_data = TableCopy(item_data)
				equip_data.is_from_extreme = 3
				v:SetData(equip_data)
			else
				v:SetData(item_data)
			end
		end
	end

	-- Cap
	local data = CommonStruct.ItemDataWrapper()
	data.item_id = item_data_list[1].item_id
	data.param = CommonStruct.ItemParamData()
	if gift_item and ForgeData.Instance:GetEquipIsNotRandomGift(data.item_id, gift_item)  then
		data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_item)
	end
	local cur_equip_cap = EquipData.Instance:GetEquipCapacityPower(data, false, true)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cur_equip_cap
	end

	--BtnText
	if not FourGradeEquipData.Instance:GetFourGradeEquipIsBuy() then
		self.node_list["BtnText"].text.text = Language.Activity.ButtonText12
		UI:SetButtonEnabled(self.node_list["BtnRewardGold"], true)
		self.node_list["Gold"]:SetActive(true)
		self.node_list["TextLingQu"]:SetActive(false)
	else
		local index_level = cfg["level_limit_" .. (index - 1)]
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		local is_get_reward = FourGradeEquipData.Instance:GetFourGradeEquipRewardIsGet(index)
		self.node_list["Gold"]:SetActive(false)
		
		if role_level >= index_level then
			self.node_list["TextLingQu"]:SetActive(false)
			if 0 == is_get_reward then
				self.node_list["BtnText"].text.text = Language.Activity.ButtonText11
				UI:SetButtonEnabled(self.node_list["BtnRewardGold"], true)
			else
				self.node_list["BtnText"].text.text = Language.Activity.ButtonText9
				UI:SetButtonEnabled(self.node_list["BtnRewardGold"], false)
			end
		else
			self.node_list["TextLingQu"]:SetActive(true)
			self.node_list["TextLingQu"].text.text = string.format(Language.Activity.LingQu, index_level)
			self.node_list["BtnText"].text.text = Language.Activity.ButtonText6
			UI:SetButtonEnabled(self.node_list["BtnRewardGold"], false)
		end
	end

	self.node_list["GoldText"].text.text = cfg.buy_gold
end

function FourGradeEquipView:SetModel()
	local cfg = FourGradeEquipData.Instance:GetFourGradeEquipCfg()
	if nil == cfg or nil == next(cfg) then
		return
	end

	local open_day_list = Split(cfg.model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	self.model:SetMainAsset(bundle, asset)
	local transform = {position = Vector3(0, 0.8, 1.14), rotation = Quaternion.Euler(0, 180, 0)}
	self.model:SetCameraSetting(transform)

	self.node_list["Effect"]:SetActive(true)
end

function FourGradeEquipView:OnBtnRewardGold()
	local cfg = FourGradeEquipData.Instance:GetFourGradeEquipCfg()

	if nil == cfg or nil == self.click_index then
		return
	end

	if not FourGradeEquipData.Instance:GetFourGradeEquipIsBuy() then
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_BUY_GOD_COSTUME)
	else
		local index_level = cfg["level_limit_" .. (self.click_index - 1)]
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		local is_get_reward = FourGradeEquipData.Instance:GetFourGradeEquipRewardIsGet(self.click_index)

		if role_level >= index_level then
			if 0 == is_get_reward then
				FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_FETCH_GOD_COSTUME_REWARD_ITEM, 0, self.click_index - 1)
				local index = self.click_index < 3 and self.click_index + 1 or self.click_index
				self:OnClickBtn(index)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Activity.ButtonText9)
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.ButtonText6)
		end
	end
end


