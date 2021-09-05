TipsBuffPandectView = TipsBuffPandectView or BaseClass(BaseView)

function TipsBuffPandectView:__init()
	self.ui_config = {{"uis/views/tips/bufftips_prefab", "BuffPandectTip"}}
	self.view_layer = UiLayer.MainUIHigh
	self.cell_list = {}
	self.data_list = {}
	self.play_audio = true
	self.is_any_click_close = true
end

function TipsBuffPandectView:LoadCallBack()

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)

	self.node_list["ListView"].scroll_rect.normalizedPosition = Vector2(0, 1)
	self.view_open_event = GlobalEventSystem:Bind(OtherEventType.VIEW_OPEN, BindTool.Bind(self.HasViewOpen, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
end

function TipsBuffPandectView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.data_list = {}

	if self.view_open_event then
		GlobalEventSystem:UnBind(self.view_open_event)
		self.view_open_event = nil
	end

	if self.menu_toggle_change then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end

	if self.buff_effect_change then
		GlobalEventSystem:UnBind(self.buff_effect_change)
		self.buff_effect_change = nil
	end

end

function TipsBuffPandectView:HasViewOpen(view)
	if view.view_name and view.view_name ~= "" and view.view_name ~= ViewName.BuffPandectTips
	and view.view_layer == UiLayer.Normal then
		self:Close()
	end
end

function TipsBuffPandectView:PortraitToggleChange(state, from_move)
	if from_move then
		self:Close()
	end
end

function TipsBuffPandectView:GetNumberOfCells()
	return #FightData.Instance:GetMainRoleShowEffect()
end

function TipsBuffPandectView:RefreshMountCell(cell, data_index)
	local item_cell = self.cell_list[cell]

	if not item_cell then
		item_cell = TipBuffCell.New(cell)
		self.cell_list[cell] = item_cell
	end
	local main_role_all_effect_list = FightData.Instance:GetMainRoleShowEffect()
	item_cell:SetData(main_role_all_effect_list[data_index + 1])

end

function TipsBuffPandectView:OpenCallBack()
	if nil == self.buff_effect_change then
		self.buff_effect_change = GlobalEventSystem:Bind(
		ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind(self.OnFightEffectChange, self))

	end
	self:Flush()
end

function TipsBuffPandectView:CloseCallBack()
	if nil ~= self.buff_effect_change then
		GlobalEventSystem:UnBind(self.buff_effect_change)
		self.buff_effect_change = nil
	end
end

function TipsBuffPandectView:OnFightEffectChange(is_main_role)
	if is_main_role then
		self:Flush()
	end
end

function TipsBuffPandectView:OnFlush()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------------------
TipBuffCell = TipBuffCell or BaseClass(BaseCell)

function TipBuffCell:__init(instance)
	self.begin_time = 0
end

function TipBuffCell:__delete()
	GlobalTimerQuest:CancelQuest(self.buff_timer)
end

function TipBuffCell:OnFlush()
	if not self.data then return end
	self.node_list["Buff"]:SetActive(self.data.type == 0 or self.data.type == 1 or self.data.type == 6 or self.data.type == 99)

	self.node_list["BuffExp"]:SetActive(self.data.type == 2)
	self.node_list["BuffVip"]:SetActive(self.data.type == 3)
	self.node_list["BuffXianZunCard"]:SetActive(self.data.type == 4)
	self.node_list["BuffImpExp"]:SetActive(self.data.type == 5)
	if nil ~= self.data.info then
		local dec, name = FightData.Instance:GetEffectDesc(self.data)
		if self.data.type == 99 then 		--经验药水特殊处理
			local is_has_otherbuff = FightData.Instance:GetIsHasOtherExpBuff()
			if is_has_otherbuff then
				self.node_list["TxtBuffDec"].text.text = dec .. Language.ExpBuy.IsHasOtherExpBuff
			else
				self.node_list["TxtBuffDec"].text.text = dec
			end
		else
			self.node_list["TxtBuffDec"].text.text = dec
		end
		
		GlobalTimerQuest:CancelQuest(self.buff_timer)
		self.begin_time = Status.NowTime
		if self.data.info.cd_time <= 0 or self.data.info.cd_time >= 10 * 24 * 3600 or self.data.info.client_effect_type == 3065 or self.data.info.client_effect_type == 3066 then
			self.node_list["TxtBuffName"].text.text = string.format("%s<color=#1eff00>%s</color>",name,"")
		else
			local buff_time = ""
			local cd_time = self.data.info.cd_time - (Status.NowTime - self.begin_time)
			buff_time = string.format("(%s)", TimeUtil.FormatSecond(cd_time))
			self.node_list["TxtBuffName"].text.text = string.format("%s<color=#1eff00>%s</color>", name, buff_time)
		end
		self.buff_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateBuffTime, self, name), 1)
		
		local asset, bundle = ResPath.GetBuffSmallIcon(self.data.info.client_effect_type)
		if asset and bundle then
			self.node_list["ImgBuff"].image:LoadSprite(asset, bundle)
		end
	end
	if self.node_list["BuffVip"] then
		self.node_list["BtnBuffVip"].button:AddClickListener(BindTool.Bind(self.OnClickBuffVip, self))
	end
	if self.node_list["BuffExp"] then
		self.node_list["BtnBuffExp"].button:AddClickListener(BindTool.Bind(self.OnClickBuffExp, self))
	end

	if self.node_list["BuffXianZunCard"] then
		self.node_list["BtnXianZunCard"].button:AddClickListener(BindTool.Bind(self.OnClickBuffXianZun, self))
	end

	if self.node_list["BtnImpExp"] then
		self.node_list["BtnImpExp"].button:AddClickListener(BindTool.Bind(self.OnClickBuffImpExp, self))
	end

end

function TipBuffCell:OnClickBuffXianZun()
	-- 若未激活仙尊卡则跳转到激活仙尊卡的见面去
	ViewManager.Instance:Open(ViewName.ImmortalView)
end


function TipBuffCell:OnClickBuffExp()
	-- 物品不足，弹出TIP框
	-- 策划要求写死2倍经验圣水
	local exp_water = 23089
	local three_exp_water = 23090--子豪要求加3倍药水
	if ItemData.Instance:GetItemNumInBagById(exp_water) <= 0 and ItemData.Instance:GetItemNumInBagById(three_exp_water) <= 0 then
		local item_cfg = ShopData.Instance:GetShopItemCfg(exp_water)
		if item_cfg then
			local ok_fun = function()
				local vo = GameVoManager.Instance:GetMainRoleVo()
				if vo.bind_gold >= item_cfg.gold then
					ExchangeCtrl.Instance:SendCSShopBuy(exp_water, 1, 1, 1)
				else
					ExchangeCtrl.Instance:SendCSShopBuy(exp_water, 1, 0, 1)
				end
			end
			TipsCtrl.Instance:ShowCommonTip(ok_fun , nil, string.format(Language.ExpBuy.ExpWaterBingGold, item_cfg.gold), nil, nil, nil ,nil ,nil ,nil, nil, nil, 1, nil, nil, Language.Common.Cancel)
		end
	else
		-- self:UseBuffExp(exp_water)
		TipsCtrl.Instance:ShowTipExpFubenView()
	end
end

function TipBuffCell:UseBuffExp(item_id)
	local bag_data = ItemData.Instance:GetItem(item_id)
	self.exp_cfg = ItemData.Instance:GetItemConfig(item_id)
	if bag_data then
		PackageCtrl.Instance:SendUseItem(bag_data.index, 1, bag_data.sub_type, self.exp_cfg.need_gold)
	end
end

function TipBuffCell:OnClickBuffVip()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TipBuffCell:OnClickBuffImpExp()
	local item_id = 64100-- 策划要求
	local func = function(item_id, item_num, is_bind, is_use)
	MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		local timer_callback = function()
			local bag_index = ItemData.Instance:GetItemIndex(item_id)
			PackageCtrl.Instance:SendUseItem(bag_index, 1)
		end
		GlobalTimerQuest:AddDelayTimer(timer_callback, 0.5)			--延迟发送协议
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1, true)
end

function TipBuffCell:UpdateBuffTime(name)
	local buff_time = ""
	if nil == self.data or nil == self.data.info then 
		return 
	end
	if self.data.type == 99 then
		return
	end
	if self.data.info.cd_time <= 0 or self.data.info.cd_time >= 10 * 24 * 3600 then   --超过10天不显示时间，方便服务端处理
		return 
	end

	if self.data.info.client_effect_type == 3065 or self.data.info.client_effect_type == 3066 then	--把秘境组队副本的buff时间隐藏
		return
	end

	local cd_time = self.data.info.cd_time - (Status.NowTime - self.begin_time)
	buff_time = string.format("(%s)", TimeUtil.FormatSecond(cd_time))
	self.node_list["TxtBuffName"].text.text = string.format("%s<color=#1eff00>%s</color>", name, buff_time)
end