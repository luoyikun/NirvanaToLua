FreeGiftView = FreeGiftView or BaseClass(BaseView)

function FreeGiftView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/freegiftview_prefab", "FreeGiftView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
	self.is_modal = true
	self.day = 1
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FreeGiftView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnRewardGold"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.model = RoleModel.New()
	self.toggle_list = {}
	self.day_list = {}
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)
	for i = 1, 3 do
		self.day_list[i] = self.node_list["Toggle" .. i]
		self.day_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleDay,self, i))
	end
	self.item_list = {}
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerTxt"])
end

function FreeGiftView:__delete()

end

function FreeGiftView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if self.model then
		self.model:DeleteMe()
	end
	self.model = nil

	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
	self.day = 1
	self.fight_text = nil
end

function FreeGiftView:OpenCallBack()
	FreeGiftData.Instance:SetFreeGiftSign(false)
	MainUICtrl.Instance:GetView():ShowFreeGift()
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if nil ~= zero_gift_info then
		local reward_flag = bit:d2b(zero_gift_info.reward_flag)
		for i = 1, 3 do
			if reward_flag[32 - i + 1] == 0 then
				self.day = i
				self:FlushDayToggle(i)
				break
			end
		end
	end
	

end

function FreeGiftView:SetModel(model_show)
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	self.model:SetMainAsset(bundle, asset)
	local transform = {position = Vector3(0, 0.9, 1.6), rotation = Quaternion.Euler(0, 180, 0)}
	self.model:SetCameraSetting(transform)
end

function FreeGiftView:CloseCallBack()
	MainUICtrl.Instance:GetView():ShowFreeGift()
end

function FreeGiftView:OnToggleDay(index, isOn)
	if isOn and self.day ~= index then
		self.day = index
		self:Flush()
	end
end

function FreeGiftView:FlushDayToggle(day)
	local now_day = day
	if day > 3 then
		now_day = 3
	end
	for k, v in pairs(self.day_list) do
		if k == now_day then
			self.day = now_day
			v.toggle.isOn = true
		else
			v.toggle.isOn = false
		end
	end
	self:Flush()
end

function FreeGiftView:OnClickReward()
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if zero_gift_info and zero_gift_info.state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or zero_gift_info.state == ZERO_GIFT_STATE.ACTIVE_STATE then
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_BUY, self.seq, self.day - 1)
	else
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_FETCH_REWARD_ITEM, self.seq, self.day - 1)
		self:FlushDayToggle(self.day + 1)
	end
end

function FreeGiftView:OnFlush(param)
	for i = 1, 3 do
		self.node_list["ImgRemind" .. i]:SetActive(FreeGiftData.Instance:GetZeroGiftRemindBySeq(i - 1))
	end
	
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if nil == zero_gift_info then return end
	local zero_gift_cfg = FreeGiftData.Instance:GetZeroGiftCfg(self.seq)
	if nil == zero_gift_cfg then return end
	local zero_gift_model_cfg = FreeGiftData.Instance:GetZeroGiftModelCfg(self.seq, self.day - 1)
	if nil == zero_gift_model_cfg then return end
	local gift = {}
	if self.day == 1 then
		gift = zero_gift_cfg.reward_item_list_0[0]
	elseif self.day == 2 then
		gift = zero_gift_cfg.reward_item_list_1[0]
	elseif self.day == 3 then
		gift = zero_gift_cfg.reward_item_list_2[0]
	end

	local gift_list = ItemData.Instance:GetGiftItemList(gift.item_id or 0)
	local effect_list = Split(zero_gift_model_cfg.effect_index, ",")
	for k,v in pairs(effect_list) do
		if self.item_list[tonumber(v)] then
			self.item_list[tonumber(v)]:SetShowOrangeEffect(true)
		end
	end
	for k,v in pairs(self.item_list) do
		local item_cfg = gift_list[k]
		v:Reset()
		if item_cfg then
			local data_list = TableCopy(item_cfg)
			v:SetGiftItemId(gift.item_id)
			if data_list.item_id then
				local cfg = ItemData.Instance:GetItemConfig(data_list.item_id)
				if cfg and EquipData.Instance:IsZhuanzhiEquipType(cfg.sub_type) then
					data_list.is_from_extreme = 3
				end
			end
			v:SetData(data_list)
		end
	end

	self.next_time = TimeCtrl.Instance:GetServerTime() - zero_gift_info.timestamp
	self.cur_state = zero_gift_info.state
	if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
		self.next_time = zero_gift_info.timestamp - TimeCtrl.Instance:GetServerTime()
	end

	local data = CommonStruct.ItemDataWrapper()
	data.item_id = gift_list[1].item_id
	data.param = CommonStruct.ItemParamData()
	if gift.item_id and ForgeData.Instance:GetEquipIsNotRandomGift(data.item_id, gift.item_id)  then
		data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift.item_id)
	end
	local cur_equip_cap = EquipData.Instance:GetEquipCapacityPower(data, false, true)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cur_equip_cap
	end

	local now_time = 0
	local last_time = 0
	if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) then
		now_time = self.next_time
		last_time = self.next_time
	else
		now_time = (self.day - 1) * 86400 - self.next_time
		last_time = 3 * 86400 - self.next_time
	end

	local reward_flag = bit:d2b(zero_gift_info.reward_flag)
	local can_reward = false
	if reward_flag[32 - self.day + 1] == 0 then
		can_reward = true
	elseif reward_flag[32 - self.day + 1] == 1 then
		can_reward = false
	end
	for i = 1, 3 do
		if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE)
		 and reward_flag[32 - i + 1] == 0 and self.next_time >= (i - 1) * 86400 then

			self.node_list["ImgRemind" .. i]:SetActive(true)
		else
			self.node_list["ImgRemind" .. i]:SetActive(false)
		end
	end

	if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE and self.next_time < (self.day - 1) * 86400) or not can_reward
		 or self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE
		 or (self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and now_time > 0)
		 or (self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and not can_reward) then
		UI:SetButtonEnabled(self.node_list["BtnRewardGold"], false)
	else
		UI:SetButtonEnabled(self.node_list["BtnRewardGold"], true)
	end
	self.node_list["NeedGold"].text.text = zero_gift_cfg.buy_gold
	local show_need = zero_gift_cfg.buy_gold > 0 and (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE)
	self.node_list["NeedGoldNode"]:SetActive(show_need)
	local level_limit = zero_gift_cfg.level_limit
	local role_level = PlayerData.Instance:GetRoleVo().level
	local color = role_level < level_limit and "fe3030" or "ffe500"
	self.node_list["LevelLimit"].text.text = zero_gift_cfg.buy_gold == 0 and string.format(Language.ZeroGift.LevelLimitText, color, PlayerData.GetLevelString(level_limit)) or ""
	self.node_list["ModelEffect"]:SetActive(zero_gift_model_cfg.model_effect == 1)
	self:SetModel(zero_gift_model_cfg.model_show)

	self.node_list["RewardGoldText"].text.text = Language.ZeroGift.BtnText[zero_gift_info.state] or Language.ZeroGift.BtnText[0]

	if not can_reward then
		self.node_list["RewardGoldText"].text.text = Language.ZeroGift.BtnText[3]
	end

	if self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and can_reward then
		self.node_list["RewardGoldText"].text.text = Language.ZeroGift.BtnText[2]
	end
	if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and  zero_gift_cfg.buy_gold <= 0 then
		self.node_list["RewardGoldText"].text.text = Language.ZeroGift.BtnTextFree
	end
	self:FlushNextTime(now_time, last_time)
end

function FreeGiftView:FlushNextTime(now_time, last_time)
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
	local time = now_time
	if now_time < 0 then
		time = 0
	end
	local function diff_time_func (elapse_time, total_time)
		local left_time = total_time - elapse_time + 0.5
		if left_time <= 0.5 then
			if last_time < 0 and (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) then
				self.node_list["TimeText"].text.text = Language.ZeroGift.TimeText3
			else
				self.node_list["TimeText"].text.text = ""
			end
				self:RemoveCountDown()
				return
		end
		if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) and left_time > 0 then
			self.node_list["TimeText"].text.text = string.format(Language.ZeroGift.TimeText, self:ChangeTime2(left_time))
			if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
				self.node_list["TimeText"].text.text = self:ChangeTime(left_time)
			end

		elseif (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) and left_time <= 0 then
			self.node_list["TimeText"].text.text = ""
		end

		if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and left_time < 0 then
			self.node_list["TimeText"].text.text = Language.ZeroGift.TimeText3
		elseif (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and left_time >= 0 then
			self.node_list["TimeText"].text.text = self:ChangeTime(left_time)
		end
	end

	diff_time_func(0, time)
	self.montser_count_down_list = CountDown.Instance:AddCountDown(time, 0.5, diff_time_func)
end

function FreeGiftView:RemoveCountDown()
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
end

function FreeGiftView:ChangeTime(time)
	if nil == time then
		return ""
	end
	local time_t = TimeUtil.Format2TableDHMS(time)
	local time_str = ""
	if time_t.day > 0 then
		time_str = string.format(Language.Activity.ActivityTime6, time_t.day, time_t.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime5, time_t.hour, time_t.min, time_t.s)
	end
	return time_str
end

function FreeGiftView:ChangeTime2(time)
	if nil == time then
		return ""
	end
	local time_t = TimeUtil.Format2TableDHMS(time)
	local time_str = ""
	if time_t.day > 0 then
		time_str = string.format(Language.Activity.ActivityTime8, time_t.day, time_t.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_t.hour, time_t.min, time_t.s)
	end
	return time_str
end