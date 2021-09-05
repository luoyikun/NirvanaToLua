KaifuActivityPanelTwelve = KaifuActivityPanelTwelve or BaseClass(BaseRender)
--礼包限购 panel12
local MODEL_TRANS_CFG = {
	[1] = {
		position = Vector3(0, 0.48, 3),
		rotation =  Quaternion.Euler(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[2] = {
		position = Vector3(0, 0.76, 0.55),
		rotation =  Quaternion.Euler(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[3] = {
		position = Vector3(0, 2.3, 8),
		rotation =  Quaternion.Euler(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[4] = {
		position = Vector3(0, 0.55, 4),
		rotation =  Quaternion.Euler(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[5] = {
		position = Vector3(0, 0.75, 1.22),
		rotation =  Quaternion.Euler(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
}

function KaifuActivityPanelTwelve:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickBuy,self))

	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellRewardCell" .. i])
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisplayModel"].ui3d_display, MODEL_CAMERA_TYPE.TIPS)

	self.cell_list = {}

	self.cur_item_index = 1
	KaifuActivityCtrl.Instance:SendRAOpenGameGiftShopBuyInfo()
end

function KaifuActivityPanelTwelve:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.equip_bg_effect_obj ~= nil then
		ResMgr:Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaifuActivityPanelTwelve:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetGiftShopCfg()
end

function KaifuActivityPanelTwelve:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = PanelTwelveListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[data_index + 1]
	cell_item:SetData(cfg)
	cell_item:SetToggleGroup(self.node_list["ScrollerListView"].toggle_group)
	cell_item:SetHightLight(self.cur_item_index == (data_index + 1))
	cell_item.node_list["ItemCell12"].toggle:AddClickListener(BindTool.Bind(self.OnClickItemCell, self, cfg, data_index + 1))
end

function KaifuActivityPanelTwelve:OnClickBuy()
	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[self.cur_item_index]

	if not cfg  then
		return
	end

	local func = function()
		KaifuActivityCtrl.Instance:SendRAOpenGameGiftShopBuy(cfg.seq)
	end

	local str = string.format(Language.Activity.BuyGiftTip, cfg.price)
	TipsCtrl.Instance:ShowCommonAutoView("", str, func)
end

function KaifuActivityPanelTwelve:OnClickItemCell(cfg, index)
	if not cfg then return end

	if self.cur_item_index == index then
		return
	end

	self.cur_item_index = index
	self:SetItemListData(cfg)

	if cfg.model_assetbundle then
		if cfg.seq == 5 then
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
	end

	-- local res_name = self.cur_item_index >= 4 and "img_zhe" or "img_zhe_1"
	-- local asset,bundle = ResPath.GetOpenGameActivityRes(res_name)
	-- self.node_list["ImgDiscount"].image:LoadSprite(asset,bundle)
end

function KaifuActivityPanelTwelve:SetItemListData(cfg)
	local item_list = {}
	local gift_id = 0
	local special_list = Split(cfg.item_special or 0, ",")
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
			for _, item_id in ipairs(special_list) do
				if tonumber(item_id) == item_list[k].item_id then
					v:ShowSpecialEffect(true)
					local bunble, asset = ResPath.GetItemActivityEffect()
					v:SetSpecialEffect(bunble, asset)
				end
			end
		end
	end

	self.node_list["TxtPrice"].text.text = cfg.price
	self.node_list["Tips"].text.text = cfg.show_language_1
	local flag = KaifuActivityData.Instance:GetGiftShopFlag()
	--服务端标记 1 为已经购买 0为还没有购买
	self.node_list["TxtInBtn"].text.text = not (flag[32 - cfg.seq] == 1) and Language.OpenServer.LiJiGouMai or Language.OpenServer.YiGouMai
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], flag[32 - cfg.seq] ~= 1)
end

function KaifuActivityPanelTwelve:OnFlush(activity_type)
	self.activity_type = activity_type or self.activity_type

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end

	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[self.cur_item_index]
	self:SetItemListData(cfg)

	self.temp_activity_type = activity_type

	if cfg.model_assetbundle then
		if cfg.seq == 5 then
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
	end
	local selectindex = KaifuActivityData.Instance:GetSelectIndex()
	local act_statu = ActivityData.Instance:GetActivityStatuByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT)
	-- local end_act_day = KaifuActivityData.Instance:GetOpenActivityList()[selectindex].activity_type   --  - TimeCtrl.Instance:GetCurOpenServerDay() or 0
	-- local act_statu  = ActivityData.Instance:GetActivityStatuByType(end_act_day)

	if act_statu and next(act_statu) then
		local end_act_time  = act_statu.end_time -  TimeCtrl.Instance:GetServerTime()
		if end_act_time >  0 then
			-- local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
			-- local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
			-- local reset_time_s = 24 * 3600 - cur_time
			self:SetRestTime(end_act_time)
		else
			self.node_list["TxtRestTime"].text.text = string.format(Language.Competition.RemainActTime1, end_act_day)
		end
	end
end

function KaifuActivityPanelTwelve:SetRestTime(diff_time)
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
			local format_time = TimeUtil.Format2TableDHMS(left_time)
			local time_str = ""
			if format_time.day >= 1 then
				time_str = string.format(Language.JinYinTa.ActEndTime, format_time.day, format_time.hour)
			else
				time_str = string.format(Language.JinYinTa.ActEndTime2, format_time.hour, format_time.min, format_time.s)
			end
			self.node_list["TxtRestTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function KaifuActivityPanelTwelve:SetModel(bundle, asset, index)
	if not bundle or not asset then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.model and self.cur_res_id ~= asset then
		self.cur_res_id = asset
		if not self.equip_bg_effect_obj and not self.is_loading then
			self.is_loading = true
			self.async_loader = self.async_loader or AllocAsyncLoader(self, "model_effect_loader")
			self.async_loader:SetParent(self.node_list["EffectRoot"].transform)
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_tongyongbaoju_1")
			self.async_loader:Load(bundle_name, asset_name, function(obj)
				if not IsNil(obj) then
					local transform = obj.transform
					transform.localScale = Vector3(3, 3, 3)
					self.equip_bg_effect_obj = obj.gameObject
					self.is_loading = false
				end
			end)
		end
		self.model:SetMainAsset(bundle, asset, function()
			if index == 5 then
				local transform = nil
				if prof == 1 then
					transform = {position = Vector3(0, -0.45, 4.8), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 2 then
					transform = {position = Vector3(0, 0.15, 4.5), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 4 then
					transform = {position = Vector3(0, -0.2, 3.5), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 3 then
					transform = {position = Vector3(0.1, 0, 1.62), rotation = Quaternion.Euler(0, 180, 0)}
				end
				self.model:SetCameraSetting(transform)
			else
				local transform = MODEL_TRANS_CFG[index + 1]
				if type(transform) == "table" then
					self.model:SetCameraSetting(transform)
				end
				if index == 2 then
					self.model:SetRotation(Vector3(0, -45, 0))
					self.model:ShowRest()
				else
					if index == 3 then
						self.model:SetTrigger("action")
					end
					self.model:SetRotation(Vector3(0, 0, 0))
				end
			end
		end)
	end
end


PanelTwelveListCell = PanelTwelveListCell or BaseClass(BaseRender)

 local MAX_GOODS = 4

function PanelTwelveListCell:__init(instance)
	self.show_image_list = {}
	self.data = {}
end

function PanelTwelveListCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function PanelTwelveListCell:SetHightLight(value)
	self.root_node.toggle.isOn = value
end

function PanelTwelveListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function PanelTwelveListCell:SetData(data)
	if not data then return end
	-- 资源没到
	self.data = data
	local bundle, asset = ResPath.GetOpenGameActivityRes("gift_shop_icon_" .. self.data.seq)
	self.node_list["ImgGoods1"].image:LoadSprite(bundle, asset)
	self:Flush()
end

function PanelTwelveListCell:OnFlush()
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