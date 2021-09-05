ImmortalView = ImmortalView or BaseClass(BaseView)

function ImmortalView:__init()
	self.ui_config = {
			{"uis/views/immortalcardview_prefab", "ImmortalCardContent"},
	}

	self.play_audio = true
	self.alert1 = nil
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
end
 
function ImmortalView:__delete()

end

function ImmortalView:CloseCallBack()
	MainUICtrl.Instance:FlushImmortalIcon()
end

function ImmortalView:ReleaseCallBack()
	if self.alert1 then
		self.alert1:DeleteMe()
		self.alert1 = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
end

function ImmortalView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self:InitScroller()
	self.cell_list = {}

end

function ImmortalView:InitScroller()
	local cfg = ImmortalData.Instance:GetImmortalCfg()

	if nil == cfg then return end
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = function()
		return #cfg
	end
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] = ImmortalCell.New(cell.gameObject, data_index)
			self.cell_list[cell]:SetIndex(data_index)
			-- self.cell_list[cell]:RegisterClick()
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(cfg[data_index])
	end

	self.node_list["ListView"].scroll_rect.horizontal = false

end

function ImmortalView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.ImmortalLabel)
	local title_index = 2
	if ImmortalData.Instance:GetForeverActivityIsOpen() then
		title_index = 1
	end
	local bundle, assest = ResPath.GetImmortalTitle(title_index)
	local ok_callback = function()
		self.node_list["TitleImg"].image:SetNativeSize()
	end
	self.node_list["TitleImg"].image:LoadSprite(bundle, assest, ok_callback)
	ImmortalData.Instance:SetIsShowSmallImmortalBtn(false)
end

function ImmortalView:ShowIndexCallBack(index)
	self:Flush()
end

-- -- 刷新
function ImmortalView:OnFlush(param_t, index)
	local active_list = ImmortalData.Instance:GetActiveList()
	for i = 1, 3 do
		self.node_list["TextR" .. i].text.text = active_list[i] and ToColorStr(Language.Common.YiActivate,TEXT_COLOR.GREEN_4) or Language.Common.NoActivate 
		self.node_list["Effect"..i]:SetActive(active_list[i])
	end
	for k ,v in pairs(self.cell_list) do 
		v:Flush()
	end
end

-------------------------------------------------------
ImmortalCell = ImmortalCell or BaseClass(BaseCell)

function ImmortalCell:__init()
	self.end_timestamp = 0
	self.reward_items = {}
	self.cur_show_id = 0
	for i=1,3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemList"])
		self.reward_items[i] = item
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	-- self.diff_time = 0
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickAct, self, self.index))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnClickDailyReward, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.ClickToTips, self))
	self.node_list["Forever"].button:AddClickListener(BindTool.Bind(self.ClickToForever, self))
end

function ImmortalCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	for k,v in pairs(self.reward_items) do
		v:DeleteMe()
	end
	self.reward_items = {}
	self:CancleCardTimer()
	self:CancleLimitTimer()
	self.cur_show_id = 0
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["IconChengHao"])
end

function ImmortalCell:ClickToForever()
	local ok_func = function()
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
 		ViewManager.Instance:Open(ViewName.VipView)
	end
	local need_gold = ImmortalData.Instance:GetForeverGold(self.data.card_type)
	local str = string.format(Language.Xianzunka.ForeverTips, need_gold, self.data.name)
	TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
end

function ImmortalCell:OnFlush()
	self:SetCellName(self.index)
	self:SetButtonIcon(self.index)

	local card_type = self.data.card_type
	local is_forever = ImmortalData.Instance:IsActiveForever(card_type)
	local is_act = ImmortalData.Instance:IsActive(card_type) or is_forever
	self.node_list["HadForever"]:SetActive(is_forever)
	UI:SetGraphicGrey(self.node_list["HadForever"], true)
	self.node_list["TextTime"]:SetActive(is_act)
	if is_act and not is_forever then
		local num = ItemData.Instance:GetItemNumInBagById(self.data.active_item_id)
		self.node_list["ImageRemind"]:SetActive(num > 0)
	else
		self.node_list["ImageRemind"]:SetActive(false)
	end
	self.node_list["Forever"]:SetActive(ImmortalData.Instance:GetForeverActivityIsOpen())
	local server_time = TimeCtrl.Instance:GetServerTime()
	local limit_timestamp = ImmortalData.Instance:GetLimitTimestamp()
	local diff_time = limit_timestamp - server_time

	self.node_list["BtnStart"]:SetActive(not ImmortalData.Instance:IsActive(card_type) and not is_forever)
	self.node_list["ImageTime"]:SetActive(ImmortalData.Instance:IsActive(card_type) and not is_forever)
	if self.index == 1 then
		if diff_time > 0 and not is_act then
			self.node_list["BtnStart"]:SetActive(false)
			self.node_list["ImageTime"]:SetActive(false)
		end
	end

	if is_act then 
		-- word_bundle, word_name = ResPath.GetCardHadForeverPayResPath()
		self.node_list["BtnStart"].button.interactable = not self.forever_act_flag
	else
		local word_bundle, word_name = ResPath.GetCardPayResPath(self.index)
		self:SetButtonWord(word_bundle, word_name)
		-- self.node_list["TextStart"].text.text = string.format(Language.Xianzunka.NeedGold, self.data.need_gold)
	end

	local has_reard = ImmortalData.Instance:IsDailyReward(card_type)
	self.node_list["RewardEffect"]:SetActive(is_act and not has_reard)
	self.node_list["HasText"]:SetActive(not has_reard)
	self.node_list["HasReward"]:SetActive(has_reard)

	UI:SetButtonEnabled(self.node_list["BtnReward"], not has_reard)

	local bg_bundle, bg_name = ResPath.GetCardBGResPath(self.data.card_type + 1)
	self:SetCardBG(bg_bundle, bg_name)

	-- local cur_type_cfg = ImmortalData.Instance:GetImmortalTypeCfg(self.index)
	local title_id = self.data.title_id
	local item_id = self.data.first_active_reward.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.node_list["IsTitle"]:SetActive(item_cfg.use_type ~= GameEnum.ITEM_OPEN_TITLE)
		self.node_list["TitleShowFrame"]:SetActive(item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE)
		if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE and title_id > 0 then
			self.node_list["IconChengHao"].image:LoadSprite(ResPath.GetTitleIcon(title_id))
			TitleData.Instance:LoadTitleEff(self.node_list["IconChengHao"], title_id, true)
		else
			self:SetModel(item_id)
		end
	end

	self.reward_items[1]:SetData(self.data.first_active_reward)
	local addition_cfg = ImmortalData.Instance:GetAdditionCfg(card_type)
	if addition_cfg then
		self.reward_items[2]:SetData({item_id = addition_cfg.show_reward1, num = 1, is_bind = 0})
		self.reward_items[3]:SetData({item_id = addition_cfg.show_reward2, num = 1, is_bind = 0})
	end
	
	self.end_timestamp = ImmortalData.Instance:GetCardEndTimestamp(card_type)
	if ImmortalData.Instance:IsActiveForever(card_type) then
		self:CancleCardTimer()
		-- self.node_list["TextTime"].text.text = (Language.Xianzunka.ForeverAct)
	elseif self.end_timestamp - server_time > 0 then
		if self.card_timer == nil then
			self.card_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		self:CancleCardTimer()
		self.node_list["TextTime"].text.text = ""
	end
	self.node_list["FirstChargeTime"]:SetActive(false)
	if self.index == 1 then
		if diff_time > 0 and not is_act then
			self.node_list["FirstChargeTime"]:SetActive(true)
			if self.limit_timer == nil then
				self.limit_timer = CountDown.Instance:AddCountDown(diff_time, 1, function ()
					diff_time = diff_time - 1
					if diff_time > 0 then
						self.node_list["FirstChargeTimeTxt"].text.text = (TimeUtil.FormatSecond(diff_time, 13) .. Language.Xianzunka.FirstActive)
					else
						self:CancleLimitTimer()
					end
				end)
			end
		end	

	end

	local title_id_cfg = TitleData.Instance:GetTitleCfg(title_id)
	local Capability = CommonDataManager.GetCapabilityCalculation(title_id_cfg)
	if self.fight_text and self.fight_text.text then
		if title_id > 0 then
			self.fight_text.text.text = Capability
		else
			self.fight_text.text.text = ItemData.GetFightPower(item_id)
		end
	end
end

function ImmortalCell:CancleLimitTimer()
	self.node_list["FirstChargeTime"]:SetActive(false)
	if self.limit_timer then
		CountDown.Instance:RemoveCountDown(self.limit_timer)
		self.limit_timer = nil
	end
end

function ImmortalCell:CancleCardTimer()
	if self.card_timer then
		GlobalTimerQuest:CancelQuest(self.card_timer)
		self.card_timer = nil
	end
end

function ImmortalCell:FlushNextTime()
	local time = self.end_timestamp - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 * 24 then
			self.node_list["TextTime"].text.text = (Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 6))
		elseif time > 3600 then
			self.node_list["TextTime"].text.text = (Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 1))
		else
			self.node_list["TextTime"].text.text = (Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 2))
		end
	else
		self:CancleCardTimer()
		self.node_list["TextTime"].text.text = ""
	end
end

function ImmortalCell:SetModel(item_id)
	if self.cur_show_id == item_id then
		return
	end

	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	self.cur_show_id = item_id

	self.model:ClearModel()
	self.model:ChangeModelByItemId(item_id)
	
	--ItemData.ChangeModel(self.model, item_id)
end

function ImmortalCell:OnClick()
	ImmortalCtrl.Instance:OpenXIanzunkaDecView(self.data)
end

function ImmortalCell:OnClickAct()
	-- if self.index == 1 and self.diff_time > 0 then
	-- 	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	-- 	ViewManager.Instance:Open(ViewName.VipView)
	-- 	return
	-- end
	local card_type = self.data.card_type
	local func = function()
		ImmortalCtrl.SendXianZunKaOperaBuyReq(card_type)
	end
	local str = ""
	if ImmortalData.Instance:IsActive(card_type) then
		str = string.format(Language.Xianzunka.ReNewTips, self.data.need_gold, self.data.name)
	else
		str = string.format(Language.Xianzunka.BuyTips, self.data.need_gold, self.data.name)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, str)
end

function ImmortalCell:OnClickDailyReward()
	if not ImmortalData.Instance:IsActive(self.data.card_type) then
		return SysMsgCtrl.Instance:ErrorRemind(Language.Xianzunka.ActiveXianZunKa)
	end
	ImmortalCtrl.SendXianZunKaOperaRewardReq(self.data.card_type)
end

function ImmortalCell:ClickToTips()
	TipsCtrl.Instance:TipsImmortalViewShow(self.data.card_type + 1)
end

function ImmortalCell:SetCellName(index)
	for i = 1 , 3 do
		self.node_list["TxtName" .. i]:SetActive(false)
	end

	self.node_list["TxtName" .. index]:SetActive(true)
	self.node_list["TxtName" .. index].text.text = Language.XianZunCard.CardTypeName[index]
end

function ImmortalCell:SetCardBG(bundle, name)
	local ok_callback = function()
		self.node_list["ImgBg"].image:SetNativeSize()
	end
	self.node_list["ImgBg"].image:LoadSprite(bundle, name, ok_callback)
end

function ImmortalCell:SetRewardIcon(bundle, name)
	self.node_list["RewardIcon"].image:LoadSprite(bundle, name)
end

function ImmortalCell:SetButtonIcon(index)
	local bundle, name = ResPath.GetCardBtnResPath(index)
	-- local bundle_1, name_1 = ResPath.GetRewardBgResPath(index)
	local ok_callback = function()
		self.node_list["BtnStart"].image:SetNativeSize()
	end
	self.node_list["BtnStart"].image:LoadSprite(bundle, name, ok_callback)
	-- self.node_list["RewardBg"].image:LoadSprite(bundle_1, name_1)
	if ImmortalData.Instance:GetForeverActivityIsOpen() then
		self.node_list["Forever"].image:LoadSprite(bundle, name, ok_callback)
	end
end

function ImmortalCell:SetButtonWord(bundle, name)
	local ok_callback = function()
		self.node_list["ImgActButton"].image:SetNativeSize()
	end
	self.node_list["ImgActButton"].image:LoadSprite(bundle, name, ok_callback)
end