local CommonFunc = require("game/tips/tips_common_func")
TipsPropView = TipsPropView or BaseClass(BaseView)

local PROPCELL = 32  -- 礼包物品item的大小
function TipsPropView:__init()
	self.ui_config = {{"uis/views/tips/proptips_prefab", "PropTip"}}
	self.view_layer = UiLayer.Pop

	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_handle = {}
	self.get_way_list = {}
	self.close_call_back = nil
	self.index = nil -- 魔器特殊处理
	self.is_magic_weapon = false
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.cell_list = {}
end

function TipsPropView:LoadCallBack()
	self.is_rich_text_item = false		-- 是否文本配置物品特效信息
	self.t_rich_list = {}

	self.node_list["ImgIcon1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["TxtShow1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["ImgIcon2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["TxtShow2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["ImgIcon3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["TxtShow3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))

	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemCell"])
	self.cell:SetIsShowTips(false)
	self.scroller_rect = self.node_list["Scroller"].scroll_rect

	self.cell_list = {}
	list_simple_delegate = self.node_list["DecList"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.text_way_list = {
		self.node_list["TxtShow1"],
		self.node_list["TxtShow2"],
		self.node_list["TxtShow3"],
	}
	self.icon_list = {
		self.node_list["ImgIcon1"],
		self.node_list["ImgIcon2"],
		self.node_list["ImgIcon3"],
	}
	self.bg_node_list = {
		self.node_list["IconBg1"],
		self.node_list["IconBg2"],
		self.node_list["IconBg3"],
	}
	self.icon_name_list = {
		self.node_list["ImgName1"],
		self.node_list["ImgName2"],
		self.node_list["ImgName3"],
	}
	for i = 1, 5 do
		local btn = self.node_list["Button" .. i]
		local text = btn.transform:FindHard("Text")
		local remind = self.node_list["Remind" .. i]
		self.buttons[i] = {btn = btn, text = text, remind = remind}
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NodeFightPower"], "FightPower3")
end

function TipsPropView:CloseView()
	self:Close()
end

function TipsPropView:__delete()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_label = nil
	CommonFunc.DeleteMe()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function TipsPropView:ReleaseCallBack()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil

	-- 清理变量和对象
	self.scroller_rect = nil
	self.text_way_list = nil
	self.icon_list = nil
	self.buttons = {}
	self.fight_text = nil

	self.is_rich_text_item = false
	self.t_rich_list = {}
end

function TipsPropView:CloseTips()
	self:Close()
end

function TipsPropView:CloseCallBack()
	if self.close_call_back ~= nil then
		if self.is_magic_weapon then
			self.close_call_back(self.index)
		else
			self.close_call_back()
		end
	end
	self.close_call_back = nil

	if self.time_count ~= nil then
		CountDown.Instance:RemoveCountDown(self.time_count)
		self.time_count = nil
	end

	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
	self.get_way_list = {}
end

function TipsPropView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
end

function TipsPropView:GetNumberOfCell()
	if self.is_rich_text_item then
		return #self.t_rich_list
	end
	return #ItemData.Instance:GetGiftItemList(self.data.item_id) or 0
end

function TipsPropView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local drop_cell = self.cell_list[cell]
	if nil == drop_cell then
		drop_cell = TipsDropCellItem.New(cell.gameObject)
		self.cell_list[cell] = drop_cell
	end
	local list_data = self.is_rich_text_item and self.t_rich_list or ItemData.Instance:GetGiftItemList(self.data.item_id)
	drop_cell:SetData(list_data[data_index])
end

function TipsPropView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end

	if ViewManager.Instance:IsOpen(ViewName.Marriage) then
		ViewManager.Instance:CloseAllViewExceptViewName2(ViewName.TipsPropView, ViewName.Marriage)
	elseif ViewManager.Instance:IsOpen(ViewName.ErnieView) then
		ViewManager.Instance:CloseAllViewExceptViewName2(ViewName.TipsPropView, ViewName.ErnieView, ViewName.ShengXiaoView)
	else
		ViewManager.Instance:CloseAllViewExceptViewName(ViewName.TipsPropView)
	end
	local list = Split(self.get_way_list[index], "#")
	if list[1] == ViewName.Compose then	-- 合成面板
		local cfg = ComposeData.Instance:GetComposeItem(self.data.item_id)
		local index = TabIndex.compose_stone

		if cfg ~= nil then
			if 2 == cfg.type then
				index = TabIndex.compose_jinjie
			elseif 3 == cfg.type then
				index = TabIndex.compose_other
			end
			ComposeData.Instance:SetToProductId(cfg.stuff_id_1)
		end
		ViewManager.Instance:Open(list[1], index, "all", self.data)

	elseif nil ~= list[2] and list[1] == ViewName.ActivityDetail then -- 如果是活动面板
		local act_id = tonumber(list[2])
		local act_info = ActivityData.Instance:GetActivityInfoById(act_id)
		if nil ~= next(act_info) then
			if IS_ON_CROSSSERVER then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
			else
				ActivityCtrl.Instance:ShowDetailView(act_id)
			end
		end
	elseif list[1] and list[1] == ViewName.Exchange  and nil == list[2] then			-- 兑换界面
		local tab_index = ExchangeData.Instance:GetCanOpenTabIndex()
		ViewManager.Instance:Open(list[1], tab_index, "all", self.data)
	else
		local tab_index = list[2] and TabIndex[list[2]] or 0
		ViewManager.Instance:Open(list[1], tab_index, "all", self.data)
	end
	self:Close()
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	local show_btn_num = 0
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			show_btn_num = show_btn_num + 1
			tx = self.data.btn_text or tx
			v.btn:SetActive(true)
			v.text:GetComponent(typeof(UnityEngine.UI.Text)).text = tx
			self:ShowBtnRemind(handler_type, v.remind)
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			local is_special = nil ~= IsSpecialHandlerType[handler_type]
			local asset = is_special and "btn_tips_side_yellow" or "btn_tips_side_blue"
			self.node_list["Button" .. k].image:LoadSprite("uis/images_atlas", asset)			
			self.button_handle[k] = self.node_list["Button" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
	
	if show_btn_num <= 4 then
		if self.node_list["RightBtn"] then
			self.node_list["RightBtn"].transform.localPosition = Vector3(190.5, 30.5, 0)
			self.node_list["RightBtn"].transform.anchoredPosition = Vector2(-4, -323)
		end
	else
		if self.node_list["RightBtn"] then
			self.node_list["RightBtn"].transform.localPosition = Vector3(190.5, 12.5, 0)
			self.node_list["RightBtn"].transform.anchoredPosition = Vector2(-4, -280)
		end
	end
end

--根据不同情况，显示和隐藏按钮红点
function TipsPropView:ShowBtnRemind(handler_type, node_list)
	if self.from_view == nil then
		return
	end
	node_list:SetActive(false)
	if self.from_view == TipsFormDef.FROM_PLAYER_INFO then
		if handler_type == TipsHandleDef.HANDLE_SHENGJI or handler_type == TipsHandleDef.HANDLE_JIHUO then
			local is_showred = MojieData.Instance:IsShowMojieRedPoint(self.data.index - 1)
			node_list:SetActive(is_showred)
		end
	end
end

function TipsPropView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end

	--魔器特殊处理
	if item_cfg.use_type == 41 then
		self.index = self.data.id
		self.is_magic_weapon = true
	end

	self:Close()
end

-- 基础属性
function TipsPropView:SetBaseAttr(item_cfg)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	-- local attr_list = self:GetAttrNameAndValue(base_attr_list)
	-- self:SetAttrObjList(self.base_attr_list, attr_list)

	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(base_attr_list)
end

--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function TipsPropView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end

	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsPropView:OnFlush()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local name_str = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	self.node_list["TxtIconName"].text.text = name_str
	self.cell:SetData(self.data)
	self.cell:SetInteractable(false)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local description = item_cfg.description
	if big_type == GameEnum.ITEM_BIGTYPE_GIF and (not description or description == "") then
		if item_cfg.need_gold and item_cfg.need_gold > 0 then
			description = string.format(Language.Tip.GlodGiftTip, item_cfg.need_gold)
		elseif item_cfg.gift_type and (item_cfg.gift_type == 3 or item_cfg.gift_type == 4) then
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.SelectGiftTip, item_cfg.rand_num)
			end
		else
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = Language.Tip.RandomGiftTip
			end
		end
		-- for k, v in pairs(ItemData.Instance:GetGiftItemList(self.data.item_id)) do
		-- 	local item_cfg2 = ItemData.Instance:GetItemConfig(v.item_id)
		-- 	if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
		-- 		local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
		-- 		if description ~= "" then
		-- 			description = description.."\n"..color_name_str.."X"..v.num
		-- 		else
		-- 			description = description..color_name_str.."X"..v.num
		-- 			RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, description)
		-- 		end
		-- 	end
		-- end

		if item_cfg.no_item_list == 1 then
			description = item_cfg.description
		end
	end

	self.t_rich_list = {}
	local text_list = Split(description, "##")
	if #text_list > 2 then
		if text_list[2] == "item_list" then
			for i = 3, #text_list do
				table.insert(self.t_rich_list, text_list[i])
			end
			self.is_rich_text_item = true
			description = text_list[1]
		else
			self.is_rich_text_item = false
		end
	else
		self.is_rich_text_item = false
	end

	self.node_list["TxtDesc"].text.text = description
	if self.is_rich_text_item then
		self.node_list["ListSize"]:SetActive(true)
		local item_num = #self.t_rich_list
		if item_num and item_num > 0 then
			self.node_list["ListSize"]:GetComponent(typeof(UnityEngine.UI.LayoutElement)).preferredHeight = item_num * PROPCELL
			self.node_list["DecList"].scroller:RefreshAndReloadActiveCellViews(false)
		end
	else
		self.node_list["ListSize"]:SetActive(1 ~= item_cfg.no_item_list and #ItemData.Instance:GetGiftItemList(self.data.item_id) > 0)
		local item_num = #ItemData.Instance:GetGiftItemList(self.data.item_id)
		if item_num and item_num > 0 then
			self.node_list["ListSize"]:GetComponent(typeof(UnityEngine.UI.LayoutElement)).preferredHeight = item_num * PROPCELL
			self.node_list["DecList"].scroller:RefreshAndReloadActiveCellViews(false)
		end
	end


	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)

	local color_level_str = ToColorStr(level_str, COLOR.WHITE)
	self.node_list["TxtUseLevel"].text.text = string.format(Language.Tip.ShiYongDengJi, color_level_str)
	if(self.data.price == nil) then
		self.data.price = item_cfg.sellprice
	end
	if self.data.price ~= nil then
		self.node_list["TxtPrice"].text.text = self.data.price
	else
		self.node_list["NodeSaleInfo"]:SetActive(false)
	end
	showHandlerBtn(self)
	self:SetWay()

	if self.data.invalid_time and self.data.invalid_time > 0 then
		self:SetPropLimitTime(self.data.invalid_time)
	elseif item_cfg.time_length and item_cfg.time_length > 0 then
		local time_limit = tonumber(item_cfg.time_length)
		self:ClickTimer(time_limit)
		local temptime = TimeUtil.FormatSecond(time_limit, 18)
		self.node_list["TxtTimeLimit"].text.text = string.format(Language.Tips.TimeGuoQi, tostring(temptime))
		-- if self.time_count == nil then
		-- 	self.time_count = CountDown.Instance:AddCountDown(time_limit, 1, 
		-- 		function (elapse_time, total_time)
		-- 			if total_time > elapse_time then
		-- 				local temptime = TimeUtil.FormatSecond(total_time - elapse_time)
		-- 				self.node_list["TxtTimeLimit"].text.text = string.format(Language.Tips.TimeGuoQi, tostring(temptime))
		-- 			end
		-- 		end)
		-- end
	end
	local is_show = (item_cfg.time_length and item_cfg.time_length > 0 or false) or (item_cfg.invalid_time and item_cfg.invalid_time > 0 or false) or (item_cfg.is_curday_valid and tonumber(item_cfg.is_curday_valid) and tonumber(item_cfg.is_curday_valid) > 0)
	self.node_list["NodeTimeLimit"]:SetActive(is_show)
	self.node_list["NodeStorgeScore"]:SetActive(false)
	if item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
		self.node_list["TxtStorgeScore"].text.text =ToColorStr(item_cfg.guild_storage_score, TEXT_COLOR.GRAY_WHITE)
	end

	local spec_id = GuildData.Instance:GetGuildConfig().storage_constant_item_id or 22703
	local sepc_score = GuildData.Instance:GetGuildConfig().constant_item_storage_score or 5000
	if (self.from_view == TipsFormDef.CANGKUEQUIP_EXCHANGE) and item_cfg and (item_cfg.id == spec_id) and sepc_score > 0 then
		self.node_list["NodeStorgeScore"]:SetActive(true)
		self.node_list["TxtStorgeScore"].text.text = string.format("<color=#ffffff>%s</color>", sepc_score)
	else
		self.node_list["NodeStorgeScore"]:SetActive(false)
	end		
	local show_power = item_cfg.power ~= nil and item_cfg.power ~= "" and item_cfg.power > 0
	self.node_list["NodeFightPower"]:SetActive(show_power)
	if show_power and self.fight_text and self.fight_text.text then
		self.fight_text.text.text = tonumber(item_cfg.power)
	end
	
	if GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type then
			-- 基础属性
		self.fight_capacity = 0
		self:SetBaseAttr(item_cfg)
		self.node_list["NodeFightPower"]:SetActive(math.ceil(self.fight_capacity) > 0)
		self.fight_text.text.text = math.ceil(self.fight_capacity)
	end

	if item_cfg.is_jiahao == 1 then
		self.fight_text.text.text = self.fight_text.text.text .. "+"
	end

	local is_show_recycle = ShenYinData.Instance:GetIsShenYinRecycleItem(self.data.item_id)
	self.node_list["NodeRecycleValue"]:SetActive(is_show_recycle)
	if is_show_recycle then
		local item_info = ShenYinData.Instance:GetItemIdCFGByVItemID(self.data.item_id)
		local recycle_value = ShenYinData.Instance:GetShenYinShenRecycle(item_info.quanlity, item_info.suit_id ~= 0 and 1 or 0)
		self.node_list["TxtRecycleValue"].text.text = string.format("%s", recycle_value)
	end

	-- 当id范围是灵魂的时，需要隐藏获取途径显示，特殊处理
	self.node_list["TuJing"]:SetActive(true)
	if self.data.item_id >= SOUL_ID_RANGE.START_ID and self.data.item_id <= SOUL_ID_RANGE.END_ID then
		self.node_list["TuJing"]:SetActive(false)
	end

end

function TipsPropView:ClickTimer(offtime)
	offtime = offtime
	local temptime = TimeUtil.FormatSecond(offtime, 18)
	self.node_list["TxtTimeLimit"].text.text = string.format(Language.Tips.TimeGuoQi, tostring(temptime))
end

-- 设置限时物品倒计时
function TipsPropView:SetPropLimitTime(invalid_time)
	if not invalid_time then return end
	local cleartime = invalid_time
	local servertime = TimeCtrl.Instance:GetServerTime()
	local time_limit = cleartime - servertime
	self:ClickTimer(time_limit)
	if self.time_count == nil then
		self.time_count = CountDown.Instance:AddCountDown(time_limit, 1, 
			function (elapse_time, total_time)
				if total_time > elapse_time then
					local temptime = TimeUtil.FormatSecond(total_time - elapse_time, 18)
					self.node_list["TxtTimeLimit"].text.text = string.format(Language.Tips.TimeGuoQi, tostring(temptime))
				end
			end)
	end
end

function TipsPropView:SetPropQualityAndClor(quality)
	if self:IsOpen() and self.cell and quality then
		self.cell:SetQualityByColor(quality)
	end
end

function TipsPropView:SetWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil== item_cfg then return end
	if item_cfg.is_curday_valid and tonumber(item_cfg.is_curday_valid) and tonumber(item_cfg.is_curday_valid) > 0 then
		local servertime = TimeCtrl.Instance:GetServerTime()
		local invalid_time = TimeUtil.NowDayTimeEnd(servertime)		--当天凌晨0点清零
		self:SetPropLimitTime(invalid_time)
	end
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.bg_node_list) do
		v:SetActive(false)
		self.text_way_list[k]:SetActive(false)
	end
	if next(way) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.node_list["NodeIcons"]:SetActive(true)
				self.node_list["NodeTexts"]:SetActive(false)
				if tonumber(v) == 0 then
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon("Icon_System_Shop")
					self.icon_list[k].image:LoadSprite(bundle, asset, function()
						-- 策划刘寒风要求设置图标80*80
						-- self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon(getway_cfg_k.icon)
					self.icon_list[k].image:LoadSprite(bundle, asset, function()
						-- 策划刘寒风要求设置图标80*80
						-- self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["NodeTexts"]:SetActive(true)
				self.node_list["NodeIcons"]:SetActive(false)
				if tonumber(v) == 0 then
					self.text_way_list[k]:SetActive(true)
					self.text_way_list[k].text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k]:SetActive(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].text.text = getway_cfg_k.button_name
					else
						self.text_way_list[k].text.text = getway_cfg_k.discription
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg then
		self.node_list["NodeTexts"]:SetActive(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.node_list["NodeIcons"]:SetActive(false)
		for k, v in pairs(msg) do
			self.text_way_list[k]:SetActive(true)
			self.text_way_list[k].text.text = v
		end
	end
end

TipsDropCellItem = TipsDropCellItem or BaseClass(BaseCell)
function TipsDropCellItem:__init()
end

function TipsDropCellItem:__delete()
	if nil ~= self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function TipsDropCellItem:OnFlush()

	if type(self.data) == "string" then
		local t_text = Split(self.data, "|")
		RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, t_text[1])
		self.node_list["Effect"]:SetActive(false)

		if nil == t_text[2] or (t_text[2] and t_text[2] ~= "1") then return end
	else
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
		if nil == self.data or nil == next(self.data) then return end

		local str = ""
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
			local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
				str = str..color_name_str.."X"..self.data.num
			-- str = string.format(Language.Tip.OpenGiftTip, self.data.item_id, self.data.num) -- 带物品点击
		end

		RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, str)
		self.node_list["Effect"]:SetActive(false)
		if self.data.is_effect <= 0 then return end
	end

	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function ()
			local width = self.node_list["rich_text"].rect.rect.width
			local widthx = self.node_list["Effect"].rect.rect.width
			local scale = width / 120
			self.node_list["Effect"]:SetActive(true)
			self.node_list["Effect"].transform.localScale = Vector3(scale + 0.1, 1, 1)

			if self.release_timer then
				GlobalTimerQuest:CancelQuest(self.release_timer)
				self.release_timer = nil
			end
		end, 0.3)
	end
end