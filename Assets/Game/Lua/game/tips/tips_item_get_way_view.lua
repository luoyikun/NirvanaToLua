TipsItemGetWayView = TipsItemGetWayView or BaseClass(BaseView)

function TipsItemGetWayView:__init()
	self.ui_config = {{"uis/views/tips/itemgetwaytips_prefab", "ItemGetWayTips"}}
	self.view_layer = UiLayer.Pop
	self.get_way_list = {}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsItemGetWayView:ReleaseCallBack()
	self.get_way_list = {}
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.text_way_list = nil
	self.icon_list = nil
end

function TipsItemGetWayView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["TxtShowWay1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["GetWayIcon1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["TxtShowWay2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["GetWayIcon2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["TxtShowWay3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["GetWayIcon3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["GetWayIcon4"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 4))

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.text_way_list = {
		{name = self.node_list["TxtShowWay1"]},
		{name = self.node_list["TxtShowWay2"]},
		{name = self.node_list["TxtShowWay3"]},
	}
	self.icon_list = {
		{icon = self.node_list["GetWayIcon1"], name = self.node_list["Name1"], bg = self.node_list["IconBg1"]},
		{icon = self.node_list["GetWayIcon2"], name = self.node_list["Name2"], bg = self.node_list["IconBg2"]},
		{icon = self.node_list["GetWayIcon3"], name = self.node_list["Name3"], bg = self.node_list["IconBg3"]},
		{icon = self.node_list["GetWayIcon4"], name = self.node_list["Name4"], bg = self.node_list["IconBg4"]},
	}
end

function TipsItemGetWayView:SetData(item_id, close_call_back)
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self.item_id = item_id
end

function TipsItemGetWayView:OpenCallBack()
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if cfg then
		self.node_list["TxtItemName"].text.text = ToColorStr(cfg.name, ITEM_COLOR[cfg.color])
		local data = {}
		data.item_id = self.item_id
		local func = function() if ViewManager.Instance:IsOpen(ViewName.Shop) then self:Close() end end
		data.close_call_back = func
		self.item_cell:SetData(data)
		self:ShowWay()
	end
end

function TipsItemGetWayView:CloseView()
	self:Close()
end

function TipsItemGetWayView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.get_way_list = {}
	self.item_id = 0
end

function TipsItemGetWayView:OnClickWay(index)
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
	elseif self.get_way_list[index] == "DisCount" then
		local _, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(data.item_id)
		if not phase then
			SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
			return
		end

		local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
		if info then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo.level < info.active_level then
				SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
				return
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
			return
		end

		if info and info.close_timestamp then
			if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
				return
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityEnd)
				return
			end
		end
	else
		ViewManager.Instance:OpenByCfg(self.get_way_list[index], data)
	end
	
	if self.item_id == ResPath.CurrencyToIconId.shengwang then
		PlayerCtrl.Instance:FlushPlayerView("bag_recycle")
	end

	local list = Split(self.get_way_list[index], "#")
	ViewManager.Instance:CloseAllViewExceptViewName(list[1])
end

function TipsItemGetWayView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for _, v in ipairs(self.icon_list) do
		v.bg:SetActive(false)
	end
	for _,v in ipairs(self.text_way_list) do
		v.name:SetActive(false)
	end

	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.node_list["NodeIcons"]:SetActive(true)
				self.node_list["NodeTexts"]:SetActive(false)
				if tonumber(v) == 0 then
					self.icon_list[k].icon:SetActive(true)
					self.icon_list[k].bg:SetActive(true)
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon.image:LoadSprite(bundle, asset, function()
						self.icon_list[k].icon.image:SetNativeSize()
					end)
					self.icon_list[k].name.image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_list[k].name.image:SetNativeSize()
					end)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].icon:SetActive(true)
					self.icon_list[k].bg:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon(getway_cfg_k.icon)
					self.icon_list[k].icon.image:LoadSprite(bundle, asset, function()
						self.icon_list[k].icon.image:SetNativeSize()
					end)
					self.icon_list[k].name.image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_list[k].name.image:SetNativeSize()
					end)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["NodeTexts"]:SetActive(true)
				self.node_list["NodeIcons"]:SetActive(false)
				if v == 0 then
					self.text_way_list[k].name:SetActive(true)
					self.text_way_list[k].name.text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k].name:SetActive(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].name.text.text = getway_cfg_k.button_name
					else
						self.text_way_list[k].name.text.text = getway_cfg_k.discription
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif item_cfg.search_type == COMMON_CONSTS.SPRITE_SEARCH_TYPE then
		self.node_list["NodeTexts"]:SetActive(true)
		self.node_list["NodeIcons"]:SetActive(false)
		local get_msg = Language.JingLing.JLGetWay
		local msg = Split(get_msg, ",")
		for k, v in pairs(msg) do
			self.text_way_list[k].name:SetActive(true)
			self.text_way_list[k].name.text.text = v
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.node_list["NodeTexts"]:SetActive(true)
		self.node_list["NodeIcons"]:SetActive(false)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		for k, v in pairs(msg) do
			self.text_way_list[k].name:SetActive(true)
			self.text_way_list[k].name.text.text = v
		end
	end
end