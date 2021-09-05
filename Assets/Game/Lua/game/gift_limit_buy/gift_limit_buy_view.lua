GiftLimitBuyView = GiftLimitBuyView or BaseClass(BaseView)

function GiftLimitBuyView:__init()
	self.ui_config = {
		{"uis/views/giftlimitbuy_prefab", "GiftLimitBuy"},
	}

	self.is_modal = true
	self.is_any_click_close = true
	self.full_screen = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.item_list = {}
	self.cell_list = {}
end

function GiftLimitBuyView:__delete()

end

function GiftLimitBuyView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2) 
		or not ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function GiftLimitBuyView:ReleaseCallBack()
	self.cell_list = {}
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.activity_type = nil
	self.temp_activity_type = nil

	self.eff_obj = nil
	self.cur_item_index = 0
	self.cur_res_id = nil
end

function GiftLimitBuyView:LoadCallBack()
	self.cur_item_index = 1
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy,self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisplayModel"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.cell_list = {}
	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellRewardCell" .. i])
	end

	local list_view_delegate = self.node_list["ListView"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
	self:SetEffect()
end

function GiftLimitBuyView:SetEffect()
	self.eff_obj = self.node_list["EffectRoot"]
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_tongyongbaoju_1")
	local async_loader = AllocAsyncLoader(self, "buy_effect_loader")
	async_loader:SetParent(self.eff_obj.transform)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if not IsNil(obj) then
			local transform = obj.transform
			transform.localScale = Vector3(3, 3, 3)
		end
	end)
end

function GiftLimitBuyView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.GiftLimitBuy)
	GiftLimitBuyCtrl.Instance:SendRAOpenGameGiftShopBuyInfo()
	GiftLimitBuyData.Instance:SetGiftLimitBuyMainuiShow(false)
	GiftLimitBuyData.Instance:SetOpenViewState(true)
	self.node_list["ListView"].scroller:ReloadData(0)
	self:Flush()
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "GiftLimitBuy")
end

function GiftLimitBuyView:CloseCallBack()
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:ShowGiftLimitBuyXianShi()
	end
end

function GiftLimitBuyView:GetNumberOfCells()
	return #GiftLimitBuyData.Instance:GetGiftShopCfg()
end

function GiftLimitBuyView:RefreshListView(cell, data_index)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = GiftLimitBuyListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local cfg = GiftLimitBuyData.Instance:GetGiftShopCfg()
	if not cfg or not next(cfg) then return end
	cell_item:SetData(cfg[data_index + 1])
	cell_item:SetToggleGroup(self.node_list["ListView"].toggle_group)
	cell_item:SetHightLight(self.cur_item_index == (data_index + 1))
	cell_item.node_list["ItemCell"].toggle:AddClickListener(BindTool.Bind(self.OnClickItemCell, self, cfg[data_index + 1], data_index + 1))
	-- cell_item:SetClickCallBack(BindTool.Bind(self.OnClickItemCell, self, cfg[data_index + 1], data_index + 1))

end

function GiftLimitBuyView:OnClickBuy()
	local cfg = GiftLimitBuyData.Instance:GetGiftShopCfg()[self.cur_item_index]

	if not cfg then
		return
	end

	local func = function()
		GiftLimitBuyCtrl.Instance:SendRAOpenGameGiftShopBuy(cfg.seq)
	end

	local str = string.format(Language.Activity.BuyGiftTip, cfg.price)
	TipsCtrl.Instance:ShowCommonAutoView("", str, func)
end

function GiftLimitBuyView:OnFlush(activity_type)
	self.node_list["ListView"].scroller:RefreshActiveCellViews()

	local cfg = GiftLimitBuyData.Instance:GetGiftShopCfg()[self.cur_item_index]
	if not cfg or not next(cfg) then return end 
	self:SetItemListData(cfg)
	self.node_list["ImgModel"]:SetActive(cfg.is_model == 0)
	self.node_list["DisplayModel"]:SetActive(cfg.is_model == 1)

	if cfg.model_assetbundle and cfg.is_model == 1 then
		if cfg.seq == 2 then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			local t = Split(cfg.model_assetbundle, ";")
			if t[prof] then
				local t2 = Split(t[prof], ",")
				local bundle, asset = t2[1], t2[2]
				self:SetModel(bundle, asset, cfg.seq)
			end
		else
			local t = Split(cfg.model_assetbundle, ",")
			local bundle, asset = t[1], t[2]
			self:SetModel(bundle, asset, cfg.seq)
		end
	else
		local t = Split(cfg.model_assetbundle, ",")
		local bundle, asset = t[1], t[2]
		self.node_list["ImgModel"].image:LoadSprite(bundle, asset, function()
				self.node_list["ImgModel"].image:SetNativeSize()
			end)
	end
	local selectindex = GiftLimitBuyData.Instance:GetSelectIndex()
	local act_statu = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2)

	if act_statu and next(act_statu) then
		local end_act_time  = act_statu.end_time -  TimeCtrl.Instance:GetServerTime()
		if end_act_time >  0 then
			self:SetRestTime(end_act_time)
		else
			self.node_list["TxtRestTime"].text.text = end_act_day
		end
	end
end

function GiftLimitBuyView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local format_time = TimeUtil.FormatSecond(left_time, 10)
			if self.node_list and self.node_list["TxtRestTime"] then
				self.node_list["TxtRestTime"].text.text = format_time
			end
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function GiftLimitBuyView:OnClickItemCell(cfg, index)
	if not cfg then return end
	if self.cur_item_index == index then
		return
	end
	self.cur_item_index = index
	self:SetItemListData(cfg)
	self.node_list["ImgModel"]:SetActive(cfg.is_model == 0)
	self.node_list["DisplayModel"]:SetActive(cfg.is_model == 1)

	if cfg.model_assetbundle and cfg.is_model == 1 then
		if cfg.seq == 2 then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			local t = Split(cfg.model_assetbundle, ";")
			if t[prof] then
				local t2 = Split(t[prof], ",")
				local bundle, asset = t2[1], t2[2]
				self:SetModel(bundle, asset, cfg.seq)
			end
		else
			local t = Split(cfg.model_assetbundle, ",")
			local bundle, asset = t[1], t[2]
			self:SetModel(bundle, asset, cfg.seq)
		end
	else
		local t = Split(cfg.model_assetbundle, ",")
		local bundle, asset = t[1], t[2]
		self.node_list["ImgModel"].image:LoadSprite(bundle, asset, function()
				self.node_list["ImgModel"].image:SetNativeSize()
			end)
	end
end

function GiftLimitBuyView:SetItemListData(cfg)
	local item_list = {}
	local gift_id = 0
	for k, v in pairs(cfg.reward_item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id

			local gift_item_list = ItemData.Instance:GetGiftItemListByProf(v.item_id)
			for _, v2 in pairs(gift_item_list) do
				table.insert(item_list, v2)
			end
		else
			table.insert(item_list, v)
		end
	end
	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetGiftItemId(gift_id)
			local data = {}
			data = item_list[k]
			local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
			if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and item_cfg.color >= 5 then
				data.is_from_extreme = 3
			end
			v:SetData(data)
		end
	end

	self.node_list["TxtPrice"].text.text = cfg.price
	self.node_list["Tips"].text.text = cfg.show_language_1
	local flag = GiftLimitBuyData.Instance:GetGiftShopFlag()
	--服务端标记 1 为已经购买 0为还没有购买
	self.node_list["TextBuy"].text.text = not (flag[32 - cfg.seq] == 1) and Language.OpenServer.LiJiGouMai or Language.OpenServer.YiGouMai
	UI:SetButtonEnabled(self.node_list["BtnBuy"], flag[32 - cfg.seq] ~= 1)
end

function GiftLimitBuyView:SetModel(bundle, asset, index)
	if not bundle or not asset then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.model and self.cur_res_id ~= asset then
		self.cur_res_id = asset
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset,function()
			if index == 2 then
				local transform = nil
				if prof == GameEnum.ROLE_PROF_1 then
					transform = {position = Vector3(0, -0.9, 4.8), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == GameEnum.ROLE_PROF_2 then
					transform = {position = Vector3(0, 0, 4.5), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == GameEnum.ROLE_PROF_4 then
					transform = {position = Vector3(0, -0.5, 3.5), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == GameEnum.ROLE_PROF_3 then
					transform = {position = Vector3(0, -0.1, 1.62), rotation = Quaternion.Euler(0, 180, 0)}
				end
				self.model:SetTrigger("action")
				self.model:SetCameraSetting(transform)
			elseif index == 3 then
				local transform = {position = Vector3(0, 0.7, 0.7), rotation = Quaternion.Euler(0, 180, 0)}
				self.model:SetCameraSetting(transform)
			end
		end)
	end
end

---------------------------------------
--------------- GiftLimitBuyListCell
---------------------------------------
GiftLimitBuyListCell = GiftLimitBuyListCell or BaseClass(BaseCell)

function GiftLimitBuyListCell:__init()
	self.show_image_list = {}
	self.data = {}
end

function GiftLimitBuyListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function GiftLimitBuyListCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GiftLimitBuyListCell:SetHightLight(value)
	self.root_node.toggle.isOn = value
end

function GiftLimitBuyListCell:SetData(data)
	self.node_list["ImgGoods"]:SetActive(false)
	if not data then return end
	-- 资源没到
	self.data = data
	local bundle, asset = ResPath.GetGiftLimitBuyRes("gift_shop_icon_" .. self.data.seq)
	self.node_list["ImgGoods"].image:LoadSprite(bundle, asset, function()
				self.node_list["ImgGoods"].image:SetNativeSize()
				self.node_list["ImgGoods"]:SetActive(true)
			end)
	self:Flush()
end

function GiftLimitBuyListCell:OnFlush()
	self.node_list["TxtGiftName"].text.text = self.data.name
	self.node_list["VipGift"]:SetActive(self.data.vip_level > 0)
	if self.data.flag == 1 then
		UI:SetGraphicGrey(self.node_list["Frame"].gameObject, true)
		self.node_list["HadBuy"]:SetActive(true)
	else
		UI:SetGraphicGrey(self.node_list["Frame"].gameObject, false)
		self.node_list["HadBuy"]:SetActive(false)
	end
end