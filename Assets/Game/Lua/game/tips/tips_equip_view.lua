local CommonFunc = require("game/tips/tips_common_func")
TipsEquipView = TipsEquipView or BaseClass(BaseView)

local AttrDescColor = TEXT_COLOR.WHITE
local AttrColor = TEXT_COLOR.GREEN

function TipsEquipView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "RoleEquipTip"}}
	self.view_layer = UiLayer.Pop
	
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_handle = {}
	self.cell_list = {}
	self.cell_obj_list = {}
	self.play_audio = true
	self.yongheng_name = ""
	self.show_no_trade = false
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsEquipView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	for k, v in pairs(self.base_attr_list) do
        ResMgr:Destroy(v.gameObject)
	end
	self.base_attr_list = {}

	for k, v in pairs(self.streng_attr_list) do
        ResMgr:Destroy(v.gameObject)
	end
	self.streng_attr_list = {}

	for k, v in pairs(self.quality_attr_list) do
        ResMgr:Destroy(v.gameObject)
	end
	self.quality_attr_list = {}

	for k, v in pairs(self.yongheng_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.yongheng_attr_list = {}

	for k, v in pairs(self.cast_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.cast_attr_list = {}

	for k, v in pairs(self.stone_item) do
		v:DeleteMe()
	end
	self.stone_item = {}

	for k, v in pairs(self.extreme_attr) do
		ResMgr:Destroy(v.gameObject)
	end
	self.extreme_attr = {}

	for k, v in pairs(self.legend_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.legend_attr_list = {}

	for k, v in pairs(self.upstar_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.upstar_attr_list = {}

	if self.extreme_suit_attr then
		ResMgr:Destroy(self.extreme_suit_attr.gameObject)
	end
	self.extreme_suit_attr = nil

	if self.refine_attr then
		ResMgr:Destroy(self.refine_attr.gameObject)
	end
	self.refine_attr = nil

	for k, v in pairs(self.fuling_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.fuling_attr_list = {}

	for k, v in pairs(self.suit_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.suit_attr_list = {}

	for k, v in pairs(self.baizhan_suit_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.baizhan_suit_attr_list = {}

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	for _, v in pairs(self.cell_obj_list) do
		if not IsNil(v) then
			ResMgr:Destroy(v)
		end
	end
	self.cell_obj_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}


	self.button_root = nil
	self.suit_name = nil
	self.suit_content = nil
	self.baizhan_suit_content = nil
	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.gift_id = nil
	self.is_data_param_nil = nil
	self.button_label = nil

	self.buttons = {}
	self.stone_attr_list = {}
	self.fight_text = nil
	self.best_fight_text = nil
end

function TipsEquipView:CloseCallBack()

	if nil ~= self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	for k ,v in pairs(self.buttons) do
		if v then
			v.btn:SetActive(false)
		end
	end
	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	for _, v in pairs(self.cell_obj_list) do
		if not IsNil(v) then
			ResMgr:Destroy(v)
		end
	end
	self.cell_obj_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.is_data_param_nil = false
	self.check_role_msg = nil

	self.node_list["Kuang"].image.enabled = false
	self.node_list["Line"].image.enabled = false
	self.node_list["QualityImage"].raw_image.enabled = false
	self.node_list["TianshenSuitAttr"]:SetActive(false)
end

function TipsEquipView:LoadCallBack()
	-- ????????????
	self.equip_item = ItemCell.New()
	self.equip_item:ListenClick(function() end)	--??????????????????
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightText"], "FightPower3")
	self.best_fight_text = CommonDataManager.FightPower(self, self.node_list["BestEquipCap"], "FightPower3")

	self.buttons = {}
	self.stone_item = {}
	for i =1 ,5 do
		local btn_text = self.node_list["Btn" .. i].transform:Find("Text")
		self.buttons[i] = {btn = self.node_list["Btn" .. i], text = btn_text}
		self.buttons[i].btn:SetActive(false)


	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["GetBestBtn"].button:AddClickListener(BindTool.Bind(self.OnGetBestBtn, self))

	self.button_label = Language.Tip.ButtonLabel

	self.base_attr_list = {}
	self.streng_attr_list = {}
	self.quality_attr_list = {}
	self.yongheng_attr_list = {}
	self.cast_attr_list = {}
	self.stone_attr_list = {}
	self.legend_attr_list = {}
	self.upstar_attr_list = {}

	for i = 1, self.node_list["BaseAttrs"].transform.childCount do
		-- ????????????
		self.base_attr_list[#self.base_attr_list + 1] = self.node_list["BaseAttrs"].transform:FindHard("BaseAttr" .. i)
		-- ????????????
		self.streng_attr_list[#self.streng_attr_list + 1] = self.node_list["StrengthenAttrs"].transform:FindHard("StrengthenAttr" .. i)
		-- ????????????
		self.quality_attr_list[#self.quality_attr_list + 1] = self.node_list["QualityAttrs"].transform:FindHard("QualityAttr" .. i)
		-- ????????????
		self.yongheng_attr_list[#self.yongheng_attr_list + 1] = self.node_list["YonghengAttrs"].transform:FindHard("YonghengAttr" .. i)
		-- ????????????
		self.cast_attr_list[#self.cast_attr_list + 1] = self.node_list["CastAttrs"].transform:FindHard("CastAttr" .. i)
		-- ????????????
		self.legend_attr_list[#self.legend_attr_list + 1] = self.node_list["LegendAttrs"].transform:FindHard("LegendAttr" .. i)
		-- ????????????
		self.upstar_attr_list[#self.upstar_attr_list + 1] = self.node_list["UpStarAttrs"].transform:FindHard("UpStarAttr"..i)
	end

	-- ??????/????????????
	for i = 1, 6 do
		self.stone_item[i] = ItemCell.New()
		self.stone_item[i]:SetInstanceParent(self.node_list["StoneItem" .. i])
		self.stone_item[i]:ListenClick(function () 
			self.stone_item[i]:ShowHighLight(false)
		end)
		self.stone_attr_list[i] = {
			stone_name = self.node_list["StoneName" .. i],
			stone_text = self.node_list["TxtAttrStone" .. i],
			stone_text2 = self.node_list["TxtAttrStone" .. i .. "2"],
			stone_obj = self.node_list["PanelGemstone0" .. i]
		}
	end

	-- ????????????
	self.extreme_attr = {}
	for i = 1, self.node_list["ExtremeAttrs"].transform.childCount do
		self.extreme_attr[#self.extreme_attr + 1] = self.node_list["ExtremeAttrs"].transform:FindHard("ExtremeAttr" .. i)
	end
	-- ??????????????????
	self.extreme_suit_attr = self.node_list["ExtremeSuitAttrs"].transform:FindHard("ExtremeSuitAttr")
	-- ????????????
	self.refine_attr = self.node_list["RefineAttrs"].transform:FindHard("RefineAttr")
	-- ????????????
	self.fuling_attr_list = {}
	for i = 1, self.node_list["FulingAttrs"].transform.childCount do
		self.fuling_attr_list[#self.fuling_attr_list + 1] = self.node_list["FulingAttrs"].transform:FindHard("FulingAttr" .. i)
	end
	-- ????????????
	self.suit_name = self.node_list["SuitAttrs"].transform:FindHard("SuitName")
	self.suit_content = self.node_list["SuitAttrs"].transform:FindHard("SuitContent").transform
	self.suit_attr_list = {}
	for i = 1, self.suit_content.childCount do
		self.suit_attr_list[#self.suit_attr_list + 1] = self.suit_content:FindHard("SuitAtt" .. i)
	end

	-- ??????????????????
	self.baizhan_suit_content = self.node_list["BaiZhanSuitAttrs"].transform
	self.baizhan_suit_attr_list = {}
	for i = 1, self.baizhan_suit_content.childCount do
		self.baizhan_suit_attr_list[#self.baizhan_suit_attr_list + 1] = self.baizhan_suit_content:FindHard("BaiZhanSuitAtt" .. i)
	end	

	self.node_list["ShowRecycleValue"]:SetActive(false)

	if self.show_no_trade then
		if self.data.is_bind then
			self.node_list["ImgShowNoTrade"]:SetActive(self.data.is_bind == 1)
		else
			self.node_list["ImgShowNoTrade"]:SetActive(true)
		end
	end

	self.tianshen_suit_attr_list = U3DNodeList(self.node_list["TianshenSuitAttrText"]:GetComponent(typeof(UINameTable)))
end

function TipsEquipView:CloseView()
	self:Close()
end

function TipsEquipView:OnGetBestBtn()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
	self:Close()
end

--??????????????????Tip?????????????????????
function TipsEquipView:SetData(data, from_view, param_t, close_call_back, gift_id)
	if not data then return end
	self.close_call_back = close_call_back

	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = TableCopy(data)
		self.item_data = data
		if self.data.param == nil then
			self.data.param = CommonStruct.ItemParamData()
			if gift_id and ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, gift_id)  then
				self.is_data_param_nil = true
				self.gift_id = gift_id
				self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
			end
		end
	end

	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsEquipView:OnFlush(param_t)
	if nil == self.data then return end

	self.node_list["Scroller"].scroll_rect.normalizedPosition = Vector2(0, 1)

	self:ShowTipContent()
	self:ShowHandlerBtn(self)
	self:ShowSellViewState(self)
	self:SetEquipCrystal()
	self:SetShenXiaoSuit()
end

function TipsEquipView:TianshenhutiSuit()
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(self.data.suit_id)
	if nil == item_cfg or nil == self.tianshen_suit_attr_list then
		return
	end

	local tz_cfg = TianshenhutiData.Instance:GetTaozhuangLevelTypeCfg(item_cfg.level_taozhuang_type)
	local cur_has = TianshenhutiData.Instance:GetTaozhuangLevelTypeHas(item_cfg.level_taozhuang_type)
	if tz_cfg then
		self.node_list["ShenXiaoAttrs"]:SetActive(false)
		self.node_list["TianshenSuitName"].text.text = string.format(Language.Tianshenhuti.TipsSuitNumShow, tz_cfg[1].taozhuang_effect_name, cur_has)

		for i,v in ipairs(tz_cfg) do
			local color = cur_has >= v.level_taozhuang_num and TEXT_COLOR.GREEN or COLOR.WHITE
			self.tianshen_suit_attr_list["CastAttr_".. i]:SetActive(true)
			self.tianshen_suit_attr_list["attrlist".. i]:SetActive(true)
			self.tianshen_suit_attr_list["CastAttr_".. i].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, v.level_taozhuang_num), color)
			local list_table = U3DNodeList(self.tianshen_suit_attr_list["attrlist".. i]:GetComponent(typeof(UINameTable)))
			local typs_list = Language.Forge.TianshenSuitShowType
			local num = 1
			for i1,v1 in ipairs(typs_list) do
				if v[v1] and v[v1] > 0 then
					local attr_str = v[v1]
					if i1 > 7 then
						attr_str = math.floor(attr_str / 100)
					end
					list_table["attrTxt" .. num].text.text = string.format(Language.HunQi.AttrList[i1], color, attr_str)
					num = num + 1
				end
			end
			for k, v in pairs(typs_list) do
				list_table["attrTxt" .. k].gameObject:SetActive(k < num)
			end
		end
		self.node_list["TianshenSuitAttr"]:SetActive(true)
	end
end

function TipsEquipView:SetShenXiaoSuit()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil or not EquipData.IsShengXiaoEqType(item_cfg.sub_type) then
		return
	end
	-- if nil == self.data or (self.from_view ~= TipsFormDef.FROM_SHENGXIAO_BAG and 
	-- 	self.from_view ~= TipsFormDef.FROM_SHENGXIAO_EQUIP and self.from_view ~= TipsFormDef.FROM_BAG) then return end
	local open_index = ShengXiaoData.Instance:GetEquipListByindex()
	local count = 3
	local show_value = 1 --??????????????????????????????
	if self.from_view == TipsFormDef.FROM_SHENGXIAO_EQUIP then
		show_value = 0
	end
	self.data_list = {}
	local quailty = ItemData.Instance:GetItemQuailty(self.data.item_id)
	self.node_list["ShenXiaoAttrs"]:SetActive(quailty >= GameEnum.ITEM_COLOR_ORANGE)
	
	if quailty < GameEnum.ITEM_COLOR_ORANGE then
		return
	end
	
	if quailty >= 6 then
		quailty = 5
	end

	self.current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(open_index)
	if self.current_all_suit then
		for k, v in ipairs(self.current_all_suit) do
			if v.suit_color == quailty then
				-- count = count + 1
				table.insert(self.data_list, v)
			end
		end
	end

	if count > 0 then
		local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
		res_async_loader:Load("uis/views/hunqiview_prefab", "suitcell", nil, function (prefab)
			if not prefab then
				return 
			end
			if count > #self.cell_list then
				for i = #self.cell_list, count - 1 do
					local obj = ResMgr:Instantiate(prefab)
					local cell = EquipSuitInfoCell.New(obj.gameObject)
					cell:SetInstanceParent(self.node_list["BaseAttrText"], false)
					table.insert(self.cell_obj_list, obj)
					table.insert(self.cell_list, cell)
				end
			end
			for k, v in pairs(self.cell_list) do
				v:SetData(self.data_list[k], show_value)
			end
		end)
	end

	local equip_list = ShengXiaoData.Instance:GetEquipLevelListByindex(open_index)
	if equip_list == nil or next(equip_list) == nil then return end
	self.new_color_list = {}
	for k, v in pairs(equip_list) do
		if v > 0 then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v)
			local color_index = item_cfg.color
			if color_index == 6 then   -- ??????????????????????????????????????????????????????
				color_index = 5
			end
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end

	local count_orange = 0
	local count_red = 0
	for k, v in pairs(self.current_all_suit) do
		if v.suit_color == 4 then
			count_orange = count_orange + 1
		elseif v.suit_color == 5 then
			count_red = count_red + 1
		end
	end
	local orange_max_num = self.current_all_suit[count_orange].need_count or 0
	local red_max_num = self.current_all_suit[#self.current_all_suit].need_count or 0
	local orange_num = self.new_color_list[4] or 0 						--4????????????
	local red_num = self.new_color_list[5] or 0 						--5????????????
	if self.from_view == TipsFormDef.FROM_BAG or self.from_view == TipsFormDef.FROM_SHENGXIAO_BAG then
		if item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.OrangeSuitName2)
		else
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.RedSuitName2)
		end
	else
		if item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.OrangeSuitName, orange_num, orange_max_num)
		else
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.RedSuitName, red_num, red_max_num)
		end
	end
end

-- ??????????????????????????????????????????
function TipsEquipView:ShowHandlerBtn(self)
	if self.from_view == nil then
		return
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	self.node_list["ShowRecycleValue"]:SetActive(false)
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		if nil == handler_type then return end
		local tx = self.button_label[handler_type]
		if handler_type == 23 then
			--???????????????
			if not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
				self.node_list["ShowRecycleValue"]:SetActive(true)
			end
		end

		if nil ~= tx then
			v.btn:SetActive(true)
			v.text:GetComponent(typeof(UnityEngine.UI.Text)).text = tx
			if nil ~= self.button_handle[k] then
				self.button_handle[k]:Dispose()
			end
			local is_special = nil ~= IsSpecialHandlerType[handler_type]
			local asset = is_special and "btn_tips_side_yellow" or "btn_tips_side_blue"
			self.node_list["Btn" .. k].image:LoadSprite("uis/images_atlas", asset)			
			self.button_handle[k] = self.node_list["Btn" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TipsEquipView:OnClickHandle(handler_type)
	if not self.data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then return end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

function TipsEquipView:ShowSellViewState(self)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)

	if not item_cfg then
		return
	end

	local salestate = CommonFunc.IsShowSellViewState(self.from_view)
end

-- ????????????????????????
function TipsEquipView:SetEquipCrystal()
	self.node_list["PanelRed"]:SetActive(false)
	self.node_list["PanelOrange"]:SetActive(false)
	local param = self.data and self.data.param or {}
	local xianpin_count = param.xianpin_type_list or {}

	local now_cfg = ForgeData.Instance:GetRedEquipComposeCfg(self.data.item_id, #xianpin_count)
	if nil == now_cfg then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	if item_cfg.color == 4 then
		self.node_list["PanelOrange"]:SetActive(true)
		self.node_list["TxtOrange"].text.text = string.format(" <color=#ffffff>%s</color>", now_cfg.discard_return[0].num)
	elseif item_cfg.color == 5 then
		self.node_list["PanelRed"]:SetActive(true)
		self.node_list["TxtRed"].text.text = string.format(" <color=#ffffff>%s</color>", now_cfg.discard_return[0].num)
	end
end

-- ??????????????????
function TipsEquipView:IsZhuanzhiEquip()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	return (item_cfg.sub_type and (item_cfg.sub_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI) and (item_cfg.sub_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI))
end

function TipsEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then return end

	self.yongheng_name = ""
	self.quality_name = ""
	self.fight_capacity = 0

	self.equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	if nil == self.equip_index then return end

	if self.from_view == TipsFormDef.FROM_CHECK_MEG then
		self.check_role_msg = true
	end
	-- ????????????
	self:SetBaseAttr(item_cfg)
	if EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		-- ???????????????
		self:HideCommonEquip()
		-- ???????????????
		self:HideZhuanzhiEquip()
		-- ????????????
		self.node_list["StoneTitle"]:SetActive(false)
		self.node_list["StoneAttrs"]:SetActive(false)

		-- ????????????
		self:SetBaiZhanAttr(item_cfg)
	elseif DouQiData.Instance:IsDouqiEqupi(item_cfg.id) then
		-- ???????????????
		self:HideCommonEquip()
		-- ???????????????
		self:HideZhuanzhiEquip()
		-- ????????????
		self.node_list["StoneTitle"]:SetActive(false)
		self.node_list["StoneAttrs"]:SetActive(false)

		-- ????????????
		self:SetDouqiAttr(item_cfg)		
	elseif not self:IsZhuanzhiEquip() then
		-- ???????????????
		self:HideZhuanzhiEquip()
		-- ???????????????
		self:HideBaiZhanEquip()
		-- ????????????
		self.node_list["StoneTitle"]:SetActive(true)
		self.node_list["StoneAttrs"]:SetActive(true)				

		-- ????????????
		self:SetStrengthAttr()
		-- ????????????
		-- self:SetQualityAttr(item_cfg)
		-- ????????????(????????????)
		self:SetYonghengAttr()
		-- ????????????
		self:SetCastAttr()
		-- ????????????
		self:SetStoneAttr("gem")

		self:TianshenhutiSuit()
	else
		-- ???????????????
		self:HideCommonEquip()
		-- ???????????????
		self:HideBaiZhanEquip()
		-- ????????????
		self.node_list["StoneTitle"]:SetActive(true)
		self.node_list["StoneAttrs"]:SetActive(true)				

		-- ????????????
		self:SetJueXingAttr(item_cfg)
		-- ????????????
		self:SetZhiZunAttr()
		-- ??????????????????
		self:SetZhiZunSuitAttr(item_cfg)
		-- ????????????
		self:SetLegendAttr(item_cfg)
		-- ????????????
		self:SetUpStarAttr()
		-- ????????????
		self:SetStoneAttr("jade")
		-- ????????????
		-- self:SetRefineAttr()
		-- ????????????
		self:SetFulingAttr()
		-- ????????????
		self:SetSuitAttr(item_cfg)
	end

	if (self.from_view == TipsFormDef.FROM_BAG_EQUIP or self.from_view == TipsFormDef.FROM_PLAYER_INFO) and self.data.index then
		self.node_list["ImgWearIcon"]:SetActive(true)
	else
		self.node_list["ImgWearIcon"]:SetActive(false)
	end

	local bundle1, asset1 = "", ""
	local bundle2, asset2 = "", ""
	local bundle3, asset3 = "", ""
	local quality_color = 1
	local is_tianshen = false
	if item_cfg.use_type and item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then
		is_tianshen = true
	end

	if((self.data.index and self.data.index >= 0 and not is_tianshen) or self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROM_CHAT_EUQIP) and 
		self.data.param and self.data.param.eternity_level and not self:IsZhuanzhiEquip() and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) and 
		not EquipData.IsBianShenEquipType(item_cfg.sub_type) and not EquipData.IsLongQiEqType(item_cfg.sub_type) and not is_tianshen then
		local quality_cfg
		if self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
			quality_cfg = ForgeData.Instance:GetEternityEquipCfg(self.equip_index, self.data.param.eternity_level)
		else
			quality_cfg = ForgeData.Instance:GetEternityEquipCfg(self.data.index, self.data.param.eternity_level)
		end
		if quality_cfg then
			bundle1, asset1 = ResPath.GetQualityRawBgIcon(quality_cfg.quality)
			bundle2, asset2 = ResPath.GetQualityKuangBgIcon(quality_cfg.quality)
			bundle3, asset3 = ResPath.GetQualityTopBg(quality_cfg.quality)
			quality_color = quality_cfg.quality
		else
			bundle1, asset1 = ResPath.GetQualityRawBgIcon(1)
			bundle2, asset2 = ResPath.GetQualityKuangBgIcon(1)
			bundle3, asset3 = ResPath.GetQualityTopBg(1)
		end
	else
		bundle1, asset1 = ResPath.GetQualityRawBgIcon(item_cfg.color)
		bundle2, asset2 = ResPath.GetQualityKuangBgIcon(item_cfg.color)
		bundle3, asset3 = ResPath.GetQualityTopBg(item_cfg.color)
		quality_color = item_cfg.color
	end
	
	self.node_list["QualityImage"].raw_image:LoadSprite(bundle1, asset1)
	self.node_list["Kuang"].image:LoadSprite(bundle2, asset2)
	self.node_list["Line"].image:LoadSprite(bundle3, asset3)
	-- if quality_color >= 5 then
	-- 	self.node_list["LongTou"].raw_image:LoadSprite(ResPath.GetTipsLongTouIcon(quality_color))
	-- 	self.node_list["LongWei"].raw_image:LoadSprite(ResPath.GetTipsLongWeiIcon(quality_color))
	-- 	self.node_list["LongTou"]:SetActive(true)
	-- 	self.node_list["LongWei"]:SetActive(true)
	-- else
	-- 	self.node_list["LongTou"]:SetActive(false)
	-- 	self.node_list["LongWei"]:SetActive(false)
	-- end

	if self.data and self.data.show_rank_attr and self.data.is_from_extreme then
		-- local str = CommonDataManager.GetDaXie(self.data.is_from_extreme)
		self.node_list["TxtRankAttr"].text.text = string.format(Language.Tips.StarRankAttr, self.data.is_from_extreme)
		self.node_list["TxtRankAttr"]:SetActive(true)
	else
		self.node_list["TxtRankAttr"]:SetActive(false)
	end

	local name_str = item_cfg.name
	if "" ~= self.yongheng_name then
		name_str = self.yongheng_name .. "??" .. name_str
	end
	if "" ~= self.quality_name then
		name_str = self.quality_name .. "??" .. name_str
	end
	-- name_str = ToColorStr(name_str, ORDER_COLOR[quality_color])
	self.node_list["TxtEquaipName"].text.text = name_str
	self.node_list["TxtEquaipType"]:SetActive(true)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_str = vo.level >= item_cfg.limit_level and item_cfg.limit_level or string.format(Language.Mount.ShowRedStr, item_cfg.limit_level)
	local level_color = vo.level >= item_cfg.limit_level and TEXT_COLOR.WHITE or TEXT_COLOR.RED
	-- self.node_list["TxtLevel"].text.text = string.format(Language.Tips.Grade, "#ffffff", "#ffffff", level_str)

	local is_show_best_tip = false
	if self:IsZhuanzhiEquip() then
		local zhuanzhi_info = ForgeData.Instance:GetZhuanzhiEquipInfo(self.equip_index, item_cfg.order)
		local role_need_min_prof_level = 0
		if zhuanzhi_info and zhuanzhi_info.role_need_min_prof_level > 0 then
			role_need_min_prof_level = zhuanzhi_info.role_need_min_prof_level
		end		

		local special_equip_cfg = ForgeData.Instance:GetSpecialEquipCfg(item_cfg.id)
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", Language.ZhuanzhiEquipTypeToName[item_cfg.sub_type])
		
		local role_prof, zhuan_num = PlayerData.Instance:GetRoleBaseProf(vo.prof)
		local is_special_equip = ForgeData.Instance:GetSpecialEquipCfg(item_cfg.id)
		local limti_color = ""
		local prof_color = TEXT_COLOR.RED
		if item_cfg.limit_prof == 5 or is_special_equip ~= nil then
			limti_color = TEXT_COLOR.WHITE
		else
			limti_color = (role_prof == item_cfg.limit_prof and zhuan_num >= role_need_min_prof_level) and "#ffffff" or TEXT_COLOR.RED
		end
		if item_cfg.limit_prof == 5 or item_cfg.limit_prof == role_prof then
			prof_color = TEXT_COLOR.WHITE
		end

		local limit_prof_name = PlayerData.Instance:GetZhuanzhiLimitProfNameTwo(item_cfg.limit_prof, 0)
		local limit_order = ""
		if ForgeData.Instance:GetZhiZunEquipCfg(item_cfg.id) and self.equip_index == 0 then
			limit_prof_name = PlayerData.Instance:GetZhuanzhiLimitProfNameTwo(item_cfg.limit_prof, 0)
		elseif ForgeData.Instance:GetSpecialEquipCfg(item_cfg.id) then
			limit_prof_name = PlayerData.Instance:GetZhuanzhiLimitProfNameTwo(item_cfg.limit_prof, 0)
		else
			if zhuanzhi_info and zhuanzhi_info.role_need_min_prof_level > 0 then
				-- limit_order = string.format("???%s???", Language.Forge.EquipNumOrder[zhuanzhi_info.role_need_min_prof_level])
				limit_order = ToColorStr(string.format("???%s???", zhuanzhi_info.role_need_min_prof_level .. Language.Common.Zhuan), limti_color)
			end
		end
		self.node_list["TxtEquipProf"].text.text = string.format(Language.Tips.JobOrder, "#ffffff", prof_color, limit_prof_name, "")
		if item_cfg.limit_level == 1 and zhuanzhi_info.role_need_min_prof_level == 0 or (special_equip_cfg and special_equip_cfg.role_need_min_level == 1 and special_equip_cfg.role_need_min_prof_level == 0) then
			self.node_list["TxtLevel"].text.text = string.format(Language.Tips.Grade2, "#ffffff", "#ffffff", Language.Common.CapNoLimmit)
		else
			self.node_list["TxtLevel"].text.text = string.format(Language.Tips.Grade, "#ffffff", level_color, item_cfg.limit_level) .. limit_order
		end

		self.node_list["Profession"]:SetActive(true)

		-- ????????????Tip
		if self.from_view and self.from_view == TipsFormDef.FROM_PLAYER_INFO then
			local role_level = GameVoManager.Instance:GetMainRoleVo().level
			local best_equip_cfg = ForgeData.Instance:GetBestEquipCfg(self.equip_index, role_level, zhuan_num)

			if best_equip_cfg and next(best_equip_cfg) and best_equip_cfg.equip_order > item_cfg.order then
				local temp_equip_cfg = ItemData.Instance:GetItemConfig(best_equip_cfg.equip_compare_id)
				local temp_equip = {}
				temp_equip.item_id = best_equip_cfg.equip_compare_id
				temp_equip.param = {}
				temp_equip.param.xianpin_type_list = {1, 2, 3} --???????????????3???
				local temp_equip_cap = EquipData.Instance:GetEquipCapacityPower(temp_equip)
				local equip_cap = EquipData.Instance:GetEquipCapacityPower(self.data)

				self.node_list["RoleLevel"].text.text = string.format(Language.Tip.BestEquipTip1, role_level, zhuan_num)
				self.node_list["EquipGradeTip"].text.text = string.format(Language.Tip.BestEquipTip2, item_cfg.order - 1, best_equip_cfg.equip_order - 1)
				-- self.node_list["CanUpCap"].text.text = string.format(Language.Tip.BestEquipTip3, temp_equip_cap - equip_cap)
				self.best_fight_text.text.text = temp_equip_cap - equip_cap
				is_show_best_tip = true
			end
		end
	else
		-- local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		self.node_list["TxtLevel"].text.text = string.format(Language.Tips.Grade, "#ffffff", level_color, item_cfg.limit_level)
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", Language.EquipTypeToName[self.equip_index])

		local prof_str = ""
		if item_cfg.limit_sex == 2 then
			local role_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
			local prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
			if item_cfg.limit_prof == 5 then
				prof_str = Language.Common.AllProf2
			else
				prof_str = (role_prof == item_cfg.limit_prof) and ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
							or string.format(Language.Mount.ShowRedStr, ZhuanZhiData.Instance:GetProfNameCfg(prof, grade))
			end
			self.node_list["TxtEquipProf"].text.text = string.format(Language.Tips.Job, "#ffffff", "#ffffff", prof_str)
		else
			prof_str = Language.Common.SexName[item_cfg.limit_sex]
			self.node_list["TxtEquipProf"].text.text = string.format(Language.Tips.Sex, "#ffffff", "#ffffff", prof_str)
		end
		self.node_list["Profession"]:SetActive(true)
	end

	if EquipData.IsShengXiaoEqType(item_cfg.sub_type) then
		self.node_list["Profession"]:SetActive(false)
		self.node_list["TxtLevel"].text.text = ""
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", item_cfg.name)
	end

	if EquipData.IsBianShenEquipType(item_cfg.sub_type) then
		self.node_list["Profession"]:SetActive(false)
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", item_cfg.name)
		self.node_list["TxtLevel"].text.text = ""
	end

	if EquipData.IsLongQiEqType(item_cfg.sub_type) then
		self.node_list["Profession"]:SetActive(false)
		self.node_list["TxtLevel"].text.text = ""
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", item_cfg.name)
	end

	if EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		self.node_list["TxtEquaipType"].text.text = string.format(Language.Tips.Type, "#ffffff", "#ffffff", Language.BaiZhanquipTypeToName[item_cfg.sub_type])
	end

	if is_tianshen then
		local item_info = TianshenhutiData.Instance:GetEquipCfgByItemId(item_cfg.id)
		if item_info then
			self.node_list["TxtLevel"].text.text = string.format(Language.Tianshenhuti.TipsjieShow, item_info.level)
			self.node_list["TxtEquipProf"].text.text = ""
			local name_str = TianshenhutiData.Instance:GetTaozhuangTypeName(item_info.taozhuang_type)
			self.node_list["TxtEquaipType"].text.text = string.format(Language.Tianshenhuti.TaoZhaung, name_str)
		end
	end
	-- self.node_list["GradeText"].text.text = string.format(Language.Tips.Jie, CommonDataManager.GetDaXie(item_cfg.order))

	--????????????
	-- if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
	-- 	self.node_list["PanelStorgeScore"]:SetActive(true)
	-- 	self.node_list["TextStorgeScore"].text.text = string.format("<color=#ffffff>%s</color>", item_cfg.guild_storage_score)
	-- else
	-- 	self.node_list["PanelStorgeScore"]:SetActive(false)
	-- end
	if (self.from_view == TipsFormDef.CANGKUEQUIP_EXCHANGE or self.from_view == TipsFormDef.FROM_BAG) and item_cfg and (EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) or item_cfg.item_id == 22703) and item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
		self.node_list["PanelStorgeScore"]:SetActive(true)
		self.node_list["TextStorgeScore"].text.text = string.format("<color=#ffffff>%s</color>", item_cfg.guild_storage_score)
	else
		self.node_list["PanelStorgeScore"]:SetActive(false)
	end

	self.node_list["TxtRecycleValue"].text.text = string.format(" <color=#ffffff>%s</color>", item_cfg.recyclget)


	if self.is_data_param_nil then
		if (self.gift_id and not ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, self.gift_id)) or not self.gift_id then
			self.equip_item:SetData(self.item_data)
		else
			self.equip_item:SetData(self.data)
		end
	else
		if self.data.is_from_extreme then
			self.equip_item:SetData(self.item_data)
		else
			self.equip_item:SetData(self.data)
		end
	end
	self.equip_item:SetShowUpArrow(false)
	
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = math.ceil(self.fight_capacity)
	end

	if self.check_role_msg or self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		self:SetEquipCellState()
	end

	if is_show_best_tip then
		self.node_list["Frame"].transform.localPosition = Vector3(115, 0, 0)
		self.node_list["BestEquipTip"]:SetActive(true)
	else
		self.node_list["Frame"].transform.localPosition = Vector3(-9, 0, 0)
		self.node_list["BestEquipTip"]:SetActive(false)
	end
end

-- ???????????????????????????????????????
function TipsEquipView:GetAttrNameAndValue(attr_tab)
	attr_tab = CommonDataManager.GetOrderAttributte(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(attr_tab) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = math.ceil(v.value)
			count = count + 1
		end
	end
	return total_attr
end

-- ????????????
function TipsEquipView:SetAttrObjList(obj_list, attr_list)
	for k, v in pairs(obj_list) do
		local obj = v.gameObject
		if attr_list[k] and attr_list[k].value > 0 then
			obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(attr_list[k].name .. ": ", AttrDescColor)  ..  ToColorStr(attr_list[k].value, AttrColor)
			obj:SetActive(true)
		else
			obj:SetActive(false)
		end
	end
end

-- ????????????
function TipsEquipView:SetBaseAttr(item_cfg)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg and item_cfg.sub_type and EquipData.IsLongQiEqType(item_cfg.sub_type) then
		local shenshou_item_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
		base_attr_list = ShenShouData.Instance:GetShenshouBaseList(shenshou_item_cfg.slot_index, shenshou_item_cfg.quality)
	elseif item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then
		base_attr_list = TianshenhutiData.Instance:GetEquipCfgByItemId(self.data.item_id)
	end

	local attr_list = self:GetAttrNameAndValue(base_attr_list)
	self:SetAttrObjList(self.base_attr_list, attr_list)

	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(base_attr_list)
end

-- ????????????
function TipsEquipView:SetStrengthAttr()
	if nil == self.data.index or not (self.data.param and self.data.param.strengthen_level and self.data.param.strengthen_level > 0) then 
		self.node_list["StrengthenTitle"]:SetActive(false)
		self.node_list["StrengthenAttrs"]:SetActive(false)
		return 
	else
		self.node_list["StrengthenTitle"]:SetActive(true)
		self.node_list["StrengthenAttrs"]:SetActive(true)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local strength_cfg = ForgeData.Instance:GetStrengthCfg(self.data.index, self.data.param.strengthen_level)
	if item_cfg and item_cfg.sub_type and EquipData.IsLongQiEqType(item_cfg.sub_type) then
		local shenshou_item_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
		strength_cfg = ShenShouData.Instance:GetShenshouLevelList(shenshou_item_cfg.slot_index, self.data.param.strengthen_level)
	end
	local strength_attr = CommonDataManager.GetAttributteNoUnderline(strength_cfg)
	local attr_list = self:GetAttrNameAndValue(strength_attr)
	self:SetAttrObjList(self.streng_attr_list, attr_list)

	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(strength_attr)
end

-- ????????????
function TipsEquipView:SetQualityAttr(item_cfg)
	if nil == self.data.index or not (self.data.param and self.data.param.quality and self.data.param.quality > 0) then
		self.node_list["QualityTitle"]:SetActive(false)
		self.node_list["QualityAttrs"]:SetActive(false)
		return 
	else
		self.node_list["QualityTitle"]:SetActive(true)
		self.node_list["QualityAttrs"]:SetActive(true)
	end

	local quality_cfg = ForgeData.Instance:GetForgeQualityCfg(self.data.index, self.data.param.quality)
	if not quality_cfg then return end

	local quality_attr = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	quality_attr = CommonDataManager.MulAttributeNoUnderline(quality_attr, (quality_cfg.attr_percent / 10000))
	local attr_list = self:GetAttrNameAndValue(quality_attr)
	self:SetAttrObjList(self.quality_attr_list, attr_list)	

	self.quality_name = quality_cfg.pre
	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(quality_attr)
end

-- ????????????
function TipsEquipView:SetYonghengAttr()
	if (self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROM_CHAT_EUQIP) and (self.data.param and self.data.param.eternity_level and self.data.param.eternity_level > 0) then
		self.node_list["YonghengTltle"]:SetActive(true)
		self.node_list["YonghengAttrs"]:SetActive(true)
	elseif nil == self.data.index or not (self.data.param and self.data.param.eternity_level and self.data.param.eternity_level > 0) then
		self.node_list["YonghengTltle"]:SetActive(false)
		self.node_list["YonghengAttrs"]:SetActive(false)
		return 
	else
		self.node_list["YonghengTltle"]:SetActive(true)
		self.node_list["YonghengAttrs"]:SetActive(true)
	end

	local yongheng_cfg
	if self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		yongheng_cfg = ForgeData.Instance:GetEternityEquipCfg(self.equip_index, self.data.param.eternity_level)
	else
		yongheng_cfg = ForgeData.Instance:GetEternityEquipCfg(self.data.index, self.data.param.eternity_level)
	end
	if not yongheng_cfg then return end
	local yongheng_attr = CommonDataManager.GetAttributteNoUnderline(yongheng_cfg)
	local attr_list = self:GetAttrNameAndValue(yongheng_attr)
	self:SetAttrObjList(self.yongheng_attr_list, attr_list)	

	self.yongheng_name = yongheng_cfg.name
	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(yongheng_attr)
end

-- ????????????
function TipsEquipView:SetCastAttr()
	if nil == self.data.index or not (self.data.param and self.data.param.shen_level and self.data.param.shen_level > 0) then
		self.node_list["CastTitle"]:SetActive(false)
		self.node_list["CastAttrs"]:SetActive(false)
		self.node_list["CastEffectShow"]:SetActive(false)
		return 
	else
		self.node_list["CastTitle"]:SetActive(true)
		self.node_list["CastAttrs"]:SetActive(true)
		self.node_list["CastEffectShow"]:SetActive(true)
	end

	local cast_cfg = ForgeData.Instance:GetShenOpSingleCfg(self.data.index, self.data.param.shen_level)
	if not cast_cfg then return end

	local cast_attr = CommonDataManager.GetAttributteNoUnderline(cast_cfg)
	local attr_list = self:GetAttrNameAndValue(cast_attr)
	self:SetAttrObjList(self.cast_attr_list, attr_list)	 

	self.node_list["CastPercentAttr"].text.text = string.format(ToColorStr(Language.Forge.ShuXingAddDesc, AttrDescColor), cast_cfg.attr_percent)
	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(cast_attr)
end

-- ??????/????????????
function TipsEquipView:SetStoneAttr(stone_type)
	self.have_jade = false

	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG then 
		self.node_list["StoneTitle"]:SetActive(false)
		self.node_list["StoneAttrs"]:SetActive(false)
		return
	else
		self.node_list["StoneTitle"]:SetActive(true)
		self.node_list["StoneAttrs"]:SetActive(true)
	end

	local info = {}
	if stone_type == "gem" and self.check_role_msg then
		info = CheckData.Instance:GetRoleInfo().stone_param[self.data.index] or {}
	elseif stone_type == "jade" and (self.check_role_msg or self.from_view == TipsFormDef.FROM_CHAT_EUQIP) then
		info = self.data.slot_list
	elseif stone_type == "gem" then
		info = ForgeData.Instance:GetGemInfoByIndex(self.data.index)
	elseif stone_type == "jade" then
		local jade_infos = ForgeData.Instance:GetEquipJadeInfo(self.data.index)
		info = jade_infos and jade_infos.slot_list or {}
	end

	if not info or not next(info) then
		self.node_list["StoneTitle"]:SetActive(false)
		self.node_list["StoneAttrs"]:SetActive(false)
		return		
	end

	local show_stone = false
	local power = 0
	if stone_type == "gem" then
		for k, v in pairs(info) do
			self.stone_attr_list[k + 1].stone_obj:SetActive(v.stone_id > 0)
			if v.stone_id > 0 then
				show_stone = true
				local stone_cfg = ForgeData.Instance:GetGemCfg(v.stone_id)
				local icon_cfg = ItemData.Instance:GetItemConfig(v.stone_id)
				local data = {}
				data.item_id = v.stone_id
				data.is_bind = 0
				self.stone_item[k + 1]:SetData(data)
				self.stone_item[k + 1]:SetBackground(false)
				self.stone_item[k + 1]:OnlyShowQuality(false)
				local stone_attr = ForgeData.Instance:GetGemAttr(v.stone_id)
				local str = ""
				if next(stone_attr) and icon_cfg then
					if #stone_attr >= 2 then
						str = string.format("%s+%s", stone_attr[2].attr_name, stone_attr[2].attr_value)
						self.stone_attr_list[k + 1].stone_text2.text.text = ToColorStr(str, AttrColor)
						self.stone_attr_list[k + 1].stone_text2:SetActive(true)
					else
						self.stone_attr_list[k + 1].stone_text2:SetActive(false)
					end
					self.stone_attr_list[k + 1].stone_name.text.text = ToColorStr(icon_cfg.name, ORDER_COLOR[icon_cfg.color])
					self.stone_attr_list[k + 1].stone_text.text.text = ToColorStr(string.format("%s+%s", stone_attr[1].attr_name, stone_attr[1].attr_value), AttrColor)
				end
			end
		end
		self.node_list["StoneTitleText"].text.text = Language.Forge.StoneTitleName[1]
		power = ForgeData.Instance:GetGemPowerByIndex(self.data.index)
	elseif stone_type == "jade" then
		for k, v in pairs(info) do
			self.stone_attr_list[k].stone_obj:SetActive(v.stone_id > 0)
			if v.stone_id > 0 then
				self.have_jade = true
				show_stone = true
				local stone_cfg = ForgeData.Instance:GetJadeCfg(v.stone_id)
				local icon_cfg = ItemData.Instance:GetItemConfig(v.stone_id)
				local data = {}
				data.item_id = v.stone_id
				data.is_bind = 0
				self.stone_item[k]:SetData(data)
				self.stone_item[k]:SetBackground(false)
				self.stone_item[k]:OnlyShowQuality(false)
				local stone_attr = ForgeData.Instance:GetJadeAttr(v.stone_id)
				local str = ""
				if next(stone_attr) then
					if #stone_attr >= 2 then
						str = string.format("%s+%s", stone_attr[2].attr_name, stone_attr[2].attr_value)
						self.stone_attr_list[k].stone_text2.text.text = ToColorStr(str, AttrColor)
						self.stone_attr_list[k].stone_text2:SetActive(true)
					else
						self.stone_attr_list[k].stone_text2:SetActive(false)
					end
					self.stone_attr_list[k].stone_name.text.text = ToColorStr(icon_cfg.name, ORDER_COLOR[icon_cfg.color])
					self.stone_attr_list[k].stone_text.text.text = ToColorStr(string.format("%s+%s", stone_attr[1].attr_name, stone_attr[1].attr_value), AttrColor)
				end
			end
		end
		self.node_list["StoneTitleText"].text.text = Language.Forge.StoneTitleName[2]
		local power_attr = ForgeData.Instance:GetAllJadePower(info)
		power = CommonDataManager.GetCapability(power_attr)
		self.jade_power = power
	end

	self.fight_capacity = self.fight_capacity + power

	if not show_stone then
		self.node_list["StoneTitle"]:SetActive(false)
		self.node_list["StoneAttrs"]:SetActive(false)
	end
end

-- ????????????
function TipsEquipView:SetJueXingAttr(item_cfg)
	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["HuaShenSkill"]:SetActive(false)
		self.node_list["HuaShenSkillAttr"]:SetActive(false)
		return
	end
	-- self.equip_item:SetFromView(TipsFormDef.FROM_CHECK_MEG)	

	local juexing_list = {}
	if self.check_role_msg then
		juexing_list = self.data.awakening_list and self.data.awakening_list.vo or {}
	elseif self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		if self.data.chat_juexing_list and type(self.data.chat_juexing_list) == "table" 
			and self.data.chat_juexing_list.awakening_in_equip and type(self.data.chat_juexing_list.awakening_in_equip) == "table" then
			juexing_list = self.data.chat_juexing_list.awakening_in_equip
		end		
	else
		local all_juexing_list = ForgeData.Instance:GetZhuanzhiEquipAwakeningAllInfoByIndex(self.data.index)
		juexing_list = all_juexing_list and all_juexing_list.awakening_in_equip or {}
	end

	local show_juexing_attr = false
	local show_num = 1
	for k, v in pairs(juexing_list) do
		 if v.level > 0 then
		 	local cfg = ForgeData.Instance:GetJueXingAttrCfg(v.type, v.level)
		 	local is_show_max = ForgeData.Instance:GetJueXingLevelIsMax(item_cfg.order, v.level)
		 	-- local is_show_eff = ForgeData.Instance:LeftJueXingLevelIsMax2(self.equip_index, k)
		 	local is_zhenxi = ForgeData.Instance:IsZhenXiAttr(self.equip_index, v.type)
		 	if is_show_max then
		 		self.node_list["HuaShenLevel" .. show_num].text.text = string.format(Language.Forge.JueXingDec1, cfg.skill_name)
		 	else
		 		self.node_list["HuaShenLevel" .. show_num].text.text = string.format(Language.Forge.JueXingDec2, cfg.skill_name, v.level) 
		 	end
		 	self.node_list["HuaShenEffect" .. show_num]:SetActive(is_show_max and is_zhenxi == 1)
		 	local bundle, asset = ResPath.GetJueXingIcon(cfg.icon_id)
			self.node_list["HuaShenImage" .. show_num].image:LoadSprite(bundle, asset)
			self.node_list["HuaShenAttr" .. show_num].text.text = cfg.skill_dec


			-- local width = self.node_list["HuaShenAttr" .. show_num].rect.rect.width
			-- local scale = width / 120
			-- self.node_list["HuaShenEffect" .. show_num].transform.localScale = Vector3(scale + 0.1, 1, 1)
			

		 	
		 	self.node_list["HuaShenLevel" .. show_num]:SetActive(true)
		 	show_num = show_num + 1
		 	show_juexing_attr = true
		 end
	end

	for i = show_num, 3 do
	 	self.node_list["HuaShenLevel" .. show_num]:SetActive(false)
	end

	if not show_juexing_attr then
		self.node_list["HuaShenSkill"]:SetActive(false)
		self.node_list["HuaShenSkillAttr"]:SetActive(false)
		return
	else
		self.node_list["HuaShenSkill"]:SetActive(true)
		self.node_list["HuaShenSkillAttr"]:SetActive(true)
	end
end

-- ????????????
function TipsEquipView:SetZhiZunAttr()
	local extreme_cfg = ForgeData.Instance:GetZhiZunEquipCfg(self.data.item_id)
	if not extreme_cfg then
		self.node_list["ExtremeTitle"]:SetActive(false)
		self.node_list["ExtremeAttrs"]:SetActive(false)
		return 
	else
		self.node_list["ExtremeTitle"]:SetActive(true)
		self.node_list["ExtremeAttrs"]:SetActive(true)
	end

	for k, v in pairs(self.extreme_attr) do
		local obj = v.gameObject
		if extreme_cfg["param" .. k] > 0 then
			local role_level = GameVoManager.Instance:GetMainRoleVo().level
			local value = role_level * extreme_cfg["param" .. k]
			obj:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(Language.Forge.ExtremeAttrName[k], value)
			obj:SetActive(true)
		else
			obj:SetActive(false)
		end
	end
end

-- ??????????????????
function TipsEquipView:SetZhiZunSuitAttr(item_cfg)
	if nil == self.data.index and not self.data.is_from_extreme then
		self.node_list["ExtremeSuitTitle"]:SetActive(false)
		self.node_list["ExtremeSuitAttrs"]:SetActive(false)
		return
	end

	local extreme_suit_cfg = ForgeData.Instance:GetZhiZunEquipCfg(item_cfg.id)
	local suit_attr_type = ForgeData.Instance:GetZhuanzhiSuitAttrType(self.equip_index)
	local extreme_suit_order_cfg = ForgeData.Instance:GetZhiZunAttrCfg(item_cfg.order)

	if not extreme_suit_cfg or not extreme_suit_order_cfg or not suit_attr_type or suit_attr_type.group_type < 2 then
		self.node_list["ExtremeSuitTitle"]:SetActive(false)
		self.node_list["ExtremeSuitAttrs"]:SetActive(false)
		return 
	else
		self.node_list["ExtremeSuitTitle"]:SetActive(true)
		self.node_list["ExtremeSuitAttrs"]:SetActive(true)
	end

	local is_active = false
	if self.check_role_msg then
		local check_attr = CheckData.Instance:UpdateAttrView()
		local zhuanzhi_list = check_attr.zhuanzhi_equip_list
		local wuqi = zhuanzhi_list[0]
		local hufu = zhuanzhi_list[9]
		local wuqi_order = 0
		local hufu_order = 0
		if wuqi and wuqi.item_id > 0 and ForgeData.Instance:GetZhiZunEquipCfg(wuqi.item_id) then
			local item_cfg = ItemData.Instance:GetItemConfig(wuqi.item_id)
			wuqi_order = item_cfg.order
		end
		if hufu and hufu.item_id > 0 and ForgeData.Instance:GetZhiZunEquipCfg(hufu.item_id) then
			local item_cfg = ItemData.Instance:GetItemConfig(hufu.item_id)
			hufu_order = item_cfg.order
		end
		is_active = (wuqi_order == item_cfg.order and hufu_order == item_cfg.order)
	else
		is_active = ForgeData.Instance:GetIsGetZhiZunAttr(item_cfg.order)
	end

	local color = COLOR.GREY
	if is_active then
		self.node_list["ExtremeSuitText"].text.text = Language.Forge.ZhizunSuitAttrName .. "(2/2)"
		color = TEXT_COLOR.RED
	else
		self.node_list["ExtremeSuitText"].text.text = Language.Forge.ZhizunSuitAttrName .. "(1/2)"
	end
	self.extreme_suit_attr.gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(string.format(Language.Forge.ZhizunSuitAttr, extreme_suit_order_cfg.show_zengshang / 100), color)
end

-- ????????????
function TipsEquipView:SetLegendAttr(item_cfg)
	local from_extreme_xianpin = {}
	local xianpin_type_list = {}
	if nil == self.data.is_from_extreme then
		if self.check_role_msg then
			if nil ~= self.data.index and self.data.xianpin_type_list and #self.data.xianpin_type_list > 0 then
				xianpin_type_list = self.data.xianpin_type_list
			end
		elseif (self.from_view == TipsFormDef.FROM_CHAT_EUQIP or self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROME_MARKET_GOUMAI
			or self.from_view == TipsFormDef.FROM_FORGE_EXCHANGE) then
			if nil ~= self.equip_index and self.data.param and self.data.param.xianpin_type_list and #self.data.param.xianpin_type_list > 0 then
				xianpin_type_list = self.data.param.xianpin_type_list
			end
		elseif self.data.noindex_show_xianpin then
			xianpin_type_list = self.data.param.xianpin_type_list
		else
			if nil ~= self.data.index and self.data.param and self.data.param.xianpin_type_list and #self.data.param.xianpin_type_list > 0 then
				xianpin_type_list = self.data.param.xianpin_type_list
			end
		end
		if next(xianpin_type_list) then
			self.node_list["LegendTitle"]:SetActive(true)
			self.node_list["LegendAttrs"]:SetActive(true)
			self.node_list["LegendTitleText"].text.text = Language.Forge.LegendTitleName[1]
		else
			self.node_list["LegendTitle"]:SetActive(false)
			self.node_list["LegendAttrs"]:SetActive(false)
			return
		end
	else
		self.node_list["LegendTitle"]:SetActive(true)
		self.node_list["LegendAttrs"]:SetActive(true)
		from_extreme_xianpin = ForgeData.Instance:GetLegendCfgByEquipColor(item_cfg.color)
		self.node_list["LegendTitleText"].text.text = Language.Forge.LegendTitleName[1]
	end

	local legend_count = 0
	for k, v in pairs(self.legend_attr_list) do
		local obj = v.gameObject
		local temp = tonumber(self.data.is_from_extreme and from_extreme_xianpin[k] or xianpin_type_list[k])
		if temp ~= nil and temp > 0 then
			local legend_cfg = ForgeData.Instance:GetLegendCfgByType(temp)
			if legend_cfg ~= nil then
				local str = ToColorStr(legend_cfg.desc, TEXT_COLOR.PURPLE)
				obj:GetComponent(typeof(UnityEngine.UI.Text)).text = str
				obj:SetActive(true)
				legend_count = legend_count + 1
			else
				obj:SetActive(false)
			end
		else
			obj:SetActive(false)
		end
	end

	local zhuanzhi_info = ForgeData.Instance:GetZhuanzhiEquipInfo(self.equip_index, item_cfg.order)
	local attr_tab = {}
	local is_long = true
	if zhuanzhi_info and zhuanzhi_info.special_attr_color == item_cfg.color then
		if zhuanzhi_info.effect_type > 0 then
			attr_tab[1] = Language.Forge.ZhuanzhiEquipAttr["effect_" .. zhuanzhi_info.effect_type]
		else
			local temp_attr_tab = {}
			for k, v in pairs(Language.Forge.ZhuanzhiEquipAttr) do
				if zhuanzhi_info[k] and zhuanzhi_info[k] > 0 then
					temp_attr_tab[k] = string.format(v, zhuanzhi_info[k] / 100)
				end
			end
			if temp_attr_tab["pvp_zengshang_per"] and temp_attr_tab["pve_zengshang_per"] then
				temp_attr_tab["pvp_zengshang_per"] = nil
				temp_attr_tab["pve_zengshang_per"] = nil
				temp_attr_tab["pvp_pve_zengshang_per"] = string.format(Language.Forge.ZhuanzhiEquipAttr["pvp_pve_zengshang_per"], zhuanzhi_info["pvp_zengshang_per"] / 100)
			end
			if temp_attr_tab["pvp_jianshang_per"] and temp_attr_tab["pve_jianshang_per"] then
				temp_attr_tab["pvp_jianshang_per"] = nil
				temp_attr_tab["pve_jianshang_per"] = nil
				temp_attr_tab["pvp_pve_jianshang_per"] = string.format(Language.Forge.ZhuanzhiEquipAttr["pvp_pve_zengshang_per"], zhuanzhi_info["pvp_jianshang_per"] / 100)
			end
			local count = 1
			for k, v in pairs(temp_attr_tab) do
				attr_tab[count] = v
				count = count + 1
			end
		end

		if zhuanzhi_info.effect_type > 0 then
			local obj = self.legend_attr_list[6].gameObject
			obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(attr_tab[1], ORDER_COLOR[item_cfg.color])
			obj:SetActive(true)
		else
			for k, v in pairs(attr_tab) do
				local obj = self.legend_attr_list[legend_count + k].gameObject
				obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(v, ORDER_COLOR[item_cfg.color])
				obj:SetActive(true)
			end
		end
	end

	if self:IsZhuanzhiEquip() then
		if item_cfg.sub_type == GameEnum.E_TYPE_ZHUANZHI_JIEZHI or item_cfg.sub_type == GameEnum.E_TYPE_ZHUANZHI_SHOUZHUO or item_cfg.sub_type == GameEnum.E_TYPE_ZHUANZHI_XIANGLIAN then
			if #xianpin_type_list >= 3 then
				local obj = self.legend_attr_list[7].gameObject
				local attr_type, attr_value = ForgeData.Instance:GetCondiTionAttr(self.equip_index,item_cfg.order)
				if attr_type and attr_value then
					obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(string.format(Language.ZhuanzhiAttrTypeName.Desc, Language.ZhuanzhiAttrTypeName[attr_type], attr_value / 100) , SOUL_NAME_COLOR[5])
					obj:SetActive(true)
				end
			end
		end
	end

	local power
	if self.data.is_from_extreme then
		local temp_data = TableCopy(self.data)
		temp_data.param = {}
		temp_data.param.xianpin_type_list = from_extreme_xianpin
		local base_power  = CommonDataManager.GetCapabilityCalculation(item_cfg)
		power = EquipData.Instance:GetEquipCapacityPower(temp_data) - base_power
	elseif nil ~= self.data.index and self.data.xianpin_type_list and #self.data.xianpin_type_list > 0 then
		local temp_data = TableCopy(self.data)
		temp_data.param = temp_data.param and temp_data.param or {}
		temp_data.param.xianpin_type_list = temp_data.xianpin_type_list
		local base_power  = CommonDataManager.GetCapabilityCalculation(item_cfg)
		power = EquipData.Instance:GetEquipCapacityPower(temp_data) - base_power		
	else
		local base_power  = CommonDataManager.GetCapabilityCalculation(item_cfg)
		power = EquipData.Instance:GetEquipCapacityPower(self.data) - base_power
	end

	self.fight_capacity = self.fight_capacity + power
end

-- ????????????
function TipsEquipView:SetUpStarAttr()
	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["UpStarTltle"]:SetActive(false)
		self.node_list["UpStarAttrs"]:SetActive(false)
		return
	end	

	local star_level = 0
	if self.check_role_msg then
		star_level = self.data.star_level
	elseif self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		star_level = self.data.param.star_level
	else
		star_level = ForgeData.Instance:GetUpStarLevelByIndex(self.data.index)
	end

	if nil == star_level or not (star_level > 0) then
		self.node_list["UpStarTltle"]:SetActive(false)
		self.node_list["UpStarAttrs"]:SetActive(false)
		return		
	else
		self.node_list["UpStarTltle"]:SetActive(true)
		self.node_list["UpStarAttrs"]:SetActive(true)
	end	

	local upstar_cfg = ForgeData.Instance:GetUpStarSingleCfg(self.data.index, star_level)
	local upstar_attr = CommonDataManager.GetAttributteNoUnderline(upstar_cfg)
	local attr_list = self:GetAttrNameAndValue(upstar_attr)
	self:SetAttrObjList(self.upstar_attr_list, attr_list)

	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(upstar_attr)
end

-- ????????????
function TipsEquipView:SetRefineAttr()
	if nil == self.data.index or not self.have_jade or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["RefineTitle"]:SetActive(false)
		self.node_list["RefineAttrs"]:SetActive(false)
		return
	end

	local refine_level = 0
	if self.check_role_msg then
		refine_level = self.data.refine_level
	else
		local refine_info = ForgeData.Instance:GetEquipJadeInfo(self.data.index)
		if not refine_info then 
			self.node_list["RefineTitle"]:SetActive(false)
			self.node_list["RefineAttrs"]:SetActive(false)
			return 
		end
		refine_level = refine_info.refine_level
	end

	local refine_cfg = ForgeData.Instance:GetJadeRefineCfg(refine_level)
	if refine_cfg and refine_cfg.per_attr_add > 0 then
		self.refine_attr.gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(Language.Forge.RefineAttrName, refine_cfg.per_attr_add / 100 .. "%")
		self.node_list["RefineTitle"]:SetActive(true)
		self.node_list["RefineAttrs"]:SetActive(true)

		self.fight_capacity = self.fight_capacity + self.jade_power * refine_cfg.per_attr_add / 10000
	else
		self.node_list["RefineTitle"]:SetActive(false)
		self.node_list["RefineAttrs"]:SetActive(false)
	end

end

-- ????????????
function TipsEquipView:SetFulingAttr()
	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["FulingTitle"]:SetActive(false)
		self.node_list["FulingAttrs"]:SetActive(false)
		return
	end

	local clear_data = {}
	if self.check_role_msg or self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		clear_data = self.data.baptize_info
	else
		clear_data = ForgeData.Instance:GetClearPartInfo(self.data.index)
	end

	if not clear_data or not next(clear_data) then
		self.node_list["FulingTitle"]:SetActive(false)
		self.node_list["FulingAttrs"]:SetActive(false)
		return 
	end

	local attr_value_list = clear_data.baptize_list
	local attr_seq_list = clear_data.attr_seq_list
	local attr_list = {}
	local color_list = {}
	local count = 0
	for k, v in pairs(self.fuling_attr_list) do
		local obj = v.gameObject
		local attr_seq = attr_seq_list[k]
		local attr_value = attr_value_list[k]
		if  attr_seq and attr_value and attr_seq > 0 and attr_value > 0 then
			local attr_seq_cfg = ForgeData.Instance:GetClearAttrBySeq(attr_seq)
			local color_seq = ForgeData.Instance:GetClearAttrColorSeq(attr_seq, attr_value)
			local attr_percent = "(" .. math.floor(attr_value / attr_seq_cfg["red_value_high"] * 100) .. "%)"
			obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(attr_seq_cfg.attr_name .. "+" .. attr_value, ORDER_COLOR[color_seq + 1])
			obj:SetActive(true)
			attr_list[attr_seq_cfg.attr_type] = attr_value
			self.node_list["FulingPercent" .. (count + 1)].text.text = ToColorStr(attr_percent, ORDER_COLOR[color_seq + 1])
			color_list[count] = color_seq
			-- if color_seq >= 3 then
			-- 	self.node_list["FulingEffect" .. (count + 1)]:SetActive(true)
			-- else
			-- 	self.node_list["FulingEffect" .. (count + 1)]:SetActive(false)
			-- end
			count = count + 1
		else
			obj:SetActive(false)
		end
	end

	local curr_suit_cfg, next_suit_cfg = ForgeData.Instance:GetClearSuitCfg(self.data.index, color_list)
	if next_suit_cfg then
		self.node_list["FulingSpecialAttr"].text.text = ToColorStr(curr_suit_cfg.show_shuxing1, ORDER_COLOR[curr_suit_cfg.baptize_color + 1])
		self.node_list["FulingSpecialAttr"]:SetActive(true)
	else
		self.node_list["FulingSpecialAttr"]:SetActive(false)
	end

	if count > 0 then
		self.node_list["FulingTitle"]:SetActive(true)
		self.node_list["FulingAttrs"]:SetActive(true)

		self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(attr_list)
	else
		self.node_list["FulingTitle"]:SetActive(false)
		self.node_list["FulingAttrs"]:SetActive(false)
	end	


	--[[ 	?????????????????????-?????????
	local fuling_info = {}
	if self.check_role_msg then
		fuling_info = self.data.fuling_count_list
	else
		fuling_info = ForgeData.Instance:GetFulingData(self.data.index)
	end

	if not fuling_info then 
		self.node_list["FulingTitle"]:SetActive(false)
		self.node_list["FulingAttrs"]:SetActive(false)
		return 
	end

	local material_cfg = ForgeData.Instance:GetFulingMaterial()
	local count = 0
	local attr_list = {}
	for k, v in pairs(material_cfg) do
		if fuling_info[k] > 0 then
			show_fuling = true
			count = count + 1
			local name  = CommonDataManager.GetAttrName(v.add_attr_type)
			local value = fuling_info[k] * v.add_attr_val
			attr_list[count] = {}
			attr_list[count].name = name
			attr_list[count].value = value
		end
	end

	self:SetAttrObjList(self.fuling_attr_list, attr_list)

	if count > 0 then
		self.node_list["FulingTitle"]:SetActive(true)
		self.node_list["FulingAttrs"]:SetActive(true)

		self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(attr_list)
	else
		self.node_list["FulingTitle"]:SetActive(false)
		self.node_list["FulingAttrs"]:SetActive(false)
	end	]]
end

-- ????????????
function TipsEquipView:SetSuitAttr(item_cfg)
	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["SuitTitle"]:SetActive(false)
		self.node_list["SuitAttrs"]:SetActive(false)
		return
	end

	local suit_type = nil
	local check_info = {}
	if self.check_role_msg then
		check_info = CheckData.Instance:GetRoleInfo()
		suit_type = check_info.zhuanzhi_suit_type_list[self.data.index]
	elseif self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		check_info = self.data.zhuanzhi_suit_infos
		suit_type = check_info.zhuanzhi_suit_type_list[self.data.index]
	else
		suit_type = ForgeData.Instance:GetZhuanzhiSuitType(self.data.index)
	end
	if not suit_type or suit_type < 0 then
		self.node_list["SuitTitle"]:SetActive(false)
		self.node_list["SuitAttrs"]:SetActive(false)
		return
	end

	local suit_attr_tab = ForgeData.Instance:GetSuitAttrList(self.data.index, suit_type, item_cfg.order)
	if not suit_attr_tab or not next(suit_attr_tab) then
		self.node_list["SuitTitle"]:SetActive(false)
		self.node_list["SuitAttrs"]:SetActive(false)
		return 
	end
	
	local suit_total_count, suit_had_count = 0, 0
	if self.check_role_msg or self.from_view == TipsFormDef.FROM_CHAT_EUQIP then
		suit_total_count, suit_had_count = ForgeData.Instance:GetCheckRoleInfoSuitCount(self.data.index, suit_type, item_cfg.order, check_info.zhuanzhi_suit_type_list, check_info.zhuanzhi_order_list)
	else
		suit_total_count, suit_had_count = ForgeData.Instance:GetSuitCount(self.data.index, suit_type, item_cfg.order)
	end
	
	if suit_attr_tab and suit_attr_tab[1].same_order_num > suit_had_count then
		self.node_list["SuitTitle"]:SetActive(false)
		self.node_list["SuitAttrs"]:SetActive(false)
		return
	end

	local capacity_tab = {
		["show_maxhp"] = 0,
		["show_gongji"] = 0,
		["show_fangyu"] = 0
	}

	local count = 1
	for k, v in pairs(suit_attr_tab) do
		local color = TEXT_COLOR.WHITE
		local is_active = false
		if v.same_order_num <= suit_had_count then
			color = TEXT_COLOR.GREEN
			is_active = true
		end

		-- self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), color)
		local suit_str = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), color)
		local suit_str2 = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), "#00000000")
		self.suit_attr_list[count].gameObject:SetActive(true)
		count = count + 1

		for k2, v2 in pairs(Language.Forge.SuitShowType) do
			if v[v2] and v[v2] > 0 then
				local suit_attr = Language.Forge.SuitShowAttr[v2]
				if string.find(v2, "per") then
					if suit_str then
						self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str .. " " .. ToColorStr(string.format(suit_attr, (v[v2] / 100) .. "%"), color)
						suit_str = nil
					else
						self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str2 .. " " .. ToColorStr(string.format(suit_attr, (v[v2] / 100) .. "%"), color)
					end
				else
					if suit_str then
						self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str .. " " .. ToColorStr(string.format(suit_attr, v[v2]), color)
						suit_str = nil
					else
						self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str2 .. " " .. ToColorStr(string.format(suit_attr, v[v2]), color)
					end
					if is_active then
						capacity_tab[v2] = capacity_tab[v2] + v[v2]
					end
				end
				self.suit_attr_list[count].gameObject:SetActive(true)
				count = count + 1
			end
		end
	end

	for i = count, #self.suit_attr_list do
		self.suit_attr_list[i].gameObject:SetActive(false)
	end

	local suit_count_str = "(" .. suit_had_count .. "/" .. suit_total_count .. ")"
	self.suit_name.gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(Language.Forge.SuitTypeName[suit_type] .. item_cfg.name .. suit_count_str, "#FDAD00FF")
	self.node_list["SuitTitle"]:SetActive(true)
	self.node_list["SuitAttrs"]:SetActive(true)

	local attr_list = {}
	attr_list.maxhp = capacity_tab.show_maxhp
	attr_list.gongji = capacity_tab.show_gongji
	attr_list.fangyu = capacity_tab.show_fangyu
	self.fight_capacity = self.fight_capacity + CommonDataManager.GetCapabilityCalculation(attr_list)
end

-- ????????????
function TipsEquipView:SetBaiZhanAttr(item_cfg)
	self.node_list["BaiZhanSuitTitle"]:SetActive(false)
	self.node_list["BaiZhanSuitAttrs"]:SetActive(false)
	self.node_list["BaiZhanSuitName"]:SetActive(false)
	--self.node_list["BaiZhanSuitContent"]:SetActive(false)
	for i = 1, #self.baizhan_suit_attr_list do
		self.baizhan_suit_attr_list[i].gameObject:SetActive(false)
	end		
	
	if EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		local baizhan_order_count_list = {}
		local max_order = ForgeData.Instance:GetBaiZhanListMaxOrder()
		if self.from_view == TipsFormDef.FROM_PLAYER_INFO or self.from_view == TipsFormDef.BAIZHAN_SUIT then
			baizhan_order_count_list = ForgeData.Instance:GetBaiZhanOrderCountListAll()
		elseif self.from_view == TipsFormDef.FROM_CHECK_MEG then
			local check_attr = CheckData.Instance:UpdateAttrView()
			if check_attr and check_attr.baizhan_order_count_list then
				baizhan_order_count_list = check_attr.baizhan_order_count_list
			end			
		end

		-- TipsEquipView?????????????????????????????????????????????????????????????????????????????????????????????
		-- if self.from_view == TipsFormDef.FROM_CHECK_MEG or self.from_view == TipsFormDef.FROM_PLAYER_INFO then
			
		-- end

		local name = ForgeData.Instance:GetBaiZhanNameListByOrder(item_cfg.order)
		local cfg = ForgeData.Instance:GetBaiZhanAttrListByOrder(item_cfg.order)
		if name and cfg then
			 -- ??????????????????????????????10
			local suit_had_count, suit_total_count = 0, 0
			if baizhan_order_count_list[item_cfg.order] then
				suit_had_count = baizhan_order_count_list[item_cfg.order]
			end
			if cfg and cfg[#cfg] and cfg[#cfg].same_order_num then
				suit_total_count = cfg[#cfg].same_order_num
			end
			local suit_count_str = ""
			if suit_had_count > 0 and suit_total_count > 0 then
				suit_count_str = "(" .. suit_had_count .. "/" .. suit_total_count .. ")"
			end
			self.node_list["BaiZhanSuitName"].text.text = ToColorStr(name .. suit_count_str, TEXT_COLOR.ORANGE_5)

			local count = 1
			for k, v in ipairs(cfg) do
				local color = TEXT_COLOR.WHITE
				local is_active = false
				if v.same_order_num <= suit_had_count then
					color = TEXT_COLOR.GREEN
					is_active = true
				end

				local suit_str = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), color)
				local suit_str2 = ToColorStr(string.format(Language.Forge.SuitCount, v.same_order_num), "#00000000")
				self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ""
				self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
				count = count + 1				
				for k2, v2 in pairs(Language.Forge.BaiZhanSuitShowType) do
					if v[v2] and v[v2] > 0 then
						local suit_attr = Language.Forge.BaiZhanSuitShowAttr[v2]
						local space_str = ""
						if v.same_order_num < 10 then
							space_str = ToColorStr("0", "#00000000")
						end
						if string.find(v2, "per") then
							if suit_str then
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str .. space_str .. ToColorStr(string.format(suit_attr, (v[v2] / 100) .. "%"), color)
								suit_str = nil
							else
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str2 .. space_str .. ToColorStr(string.format(suit_attr, (v[v2] / 100) .. "%"), color)
							end
						else
							if suit_str then
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str .. space_str .. ToColorStr(string.format(suit_attr, v[v2]), color)
								suit_str = nil
							else
								self.baizhan_suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = suit_str2 .. space_str .. ToColorStr(string.format(suit_attr, v[v2]), color)
							end
						end
						self.baizhan_suit_attr_list[count].gameObject:SetActive(true)
						count = count + 1
					end
				end			
			end

			for i = count, #self.baizhan_suit_attr_list do
				self.baizhan_suit_attr_list[i].gameObject:SetActive(false)
			end
			--self.node_list["BaiZhanSuitContent"]:SetActive(true)
			self.node_list["BaiZhanSuitName"]:SetActive(true)
			self.node_list["BaiZhanSuitAttrs"]:SetActive(true)
			self.node_list["BaiZhanSuitTitle"]:SetActive(true)
		end
	end
end

--????????????
function TipsEquipView:SetDouqiAttr(item_cfg)
	if TipsFormDef.FROM_DOUQI_VIEW_TAKEOFF == self.from_view then

		local douqi_equip_cfg =  DouQiData.Instance:GetDouqiEquipCfg(item_cfg.id)
		if douqi_equip_cfg and douqi_equip_cfg.color == 5 then
			local suit_data = DouQiData.Instance:GetSuitDataBtIndex(self.equip_index + 1) or {}
			-- if nil == suit_data then return end

			local suit_attr_cfg =  DouQiData.Instance:GetDouqiEquipClientSuitAttr(douqi_equip_cfg.order)
			if nil == suit_attr_cfg then return end

			local suit_type_num = suit_data.suit_type or 0
			local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(douqi_equip_cfg.order)
			local suit_name = douqi_cfg and (douqi_cfg.grade_name .. Language.Douqi.TaoZhuang) or ""
			self.suit_name.gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(string.format("???%s???", suit_name), "#FDAD00FF")
			local count = 1
			for k, v in pairs(suit_attr_cfg) do
				local txt_color = suit_type_num >= v.need_count and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ""
				self.suit_attr_list[count].gameObject:SetActive(true)
				count = count + 1
				local need_count_text = string.format(Language.Douqi.SuitCount, v.need_count)
				local temp_count_text = ""
				if v.need_count < 10 then
					temp_count_text = ToColorStr("0", "#00000000")
				end
				local is_add_text = true
				for k2, v2 in pairs(Language.Douqi.DouqiSuitShowType) do
					if v[v2] and v[v2] > 0 then
						local suit_attr = Language.Douqi.DouqiSuitShowAttr[v2]
						if string.find(v2, "per") then
							local temp_attr = string.format("%s+%s%%", suit_attr, v[v2] / 100)
							self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(need_count_text .. temp_count_text .. temp_attr, txt_color)
						else
							local temp_attr = string.format("%s+%s", suit_attr, v[v2])
							self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(need_count_text .. temp_count_text .. temp_attr, txt_color)
						end
						if is_add_text then
							need_count_text = ToColorStr(need_count_text, "#00000000")
							is_add_text = false
						end
						self.suit_attr_list[count].gameObject:SetActive(true)
						count = count + 1
					end
				end
			end

			for i = count, #self.suit_attr_list do
				self.suit_attr_list[i].gameObject:SetActive(false)
			end

			self.node_list["SuitTitle"]:SetActive(true)
			self.node_list["SuitAttrs"]:SetActive(true)
		end
	else
		local douqi_equip_cfg =  DouQiData.Instance:GetDouqiEquipCfg(item_cfg.id)
		if douqi_equip_cfg and douqi_equip_cfg.color == 5 then
			local suit_attr_cfg = DouQiData.Instance:GetDouqiEquipClientSuitAttr(douqi_equip_cfg.order)
			if suit_attr_cfg then
				local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(douqi_equip_cfg.order)
				local suit_name = douqi_cfg and (douqi_cfg.grade_name .. Language.Douqi.TaoZhuang) or ""
				self.suit_name.gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(string.format("???%s???", suit_name), "#FDAD00FF")
				local count = 1
				for k, v in pairs(suit_attr_cfg) do
					local txt_color = TEXT_COLOR.WHITE
					self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ""
					count = count + 1
					local need_count_text = string.format(Language.Douqi.SuitCount, v.need_count)
					local temp_count_text = ""
					if v.need_count < 10 then
						temp_count_text = ToColorStr("0", "#00000000")
					end
					local is_add_text = true
					for k2, v2 in pairs(Language.Douqi.DouqiSuitShowType) do
						if v[v2] and v[v2] > 0 then
							local suit_attr = Language.Douqi.DouqiSuitShowAttr[v2]
							if string.find(v2, "per") then
								local temp_attr = string.format("%s+%s%%", suit_attr, v[v2] / 100)
								self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(need_count_text .. temp_count_text .. temp_attr, txt_color)
							else
								local temp_attr = string.format("%s+%s", suit_attr, v[v2])
								self.suit_attr_list[count].gameObject:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(need_count_text .. temp_count_text .. temp_attr, txt_color)
							end
							if is_add_text then
								need_count_text = ToColorStr(need_count_text, "#00000000")
								is_add_text = false
							end
							count = count + 1
						end
					end
				end
				for i = count, #self.suit_attr_list do
					self.suit_attr_list[i].gameObject:SetActive(false)
				end

				self.node_list["SuitTitle"]:SetActive(true)
				self.node_list["SuitAttrs"]:SetActive(true)
			end
		end
	end
end

function TipsEquipView:SetQualityAndClor(quality)
	if self:IsOpen() and self.equip_item and quality then
		self.equip_item:SetQualityByColor(quality)
		local bundle2, asset2 = ResPath.GetQualityKuangBgIcon(quality)
		local bundle1, asset1 = ResPath.GetQualityRawBgIcon(quality)
		local bundle3, asset3 = ResPath.GetQualityTopBg(quality)
		self.node_list["QualityImage"].raw_image:LoadSprite(bundle1, asset1)
		self.node_list["Kuang"].image:LoadSprite(bundle2, asset2)
		self.node_list["Line"].image:LoadSprite(bundle3, asset3)
	end
end


-- ???????????????
function TipsEquipView:HideZhuanzhiEquip()
	self.node_list["ExtremeTitle"]:SetActive(false)
	self.node_list["ExtremeAttrs"]:SetActive(false)
	self.node_list["ExtremeSuitTitle"]:SetActive(false)
	self.node_list["ExtremeSuitAttrs"]:SetActive(false)
	self.node_list["LegendTitle"]:SetActive(false)
	self.node_list["LegendAttrs"]:SetActive(false)
	self.node_list["UpStarTltle"]:SetActive(false)
	self.node_list["UpStarAttrs"]:SetActive(false)
	self.node_list["RefineTitle"]:SetActive(false)
	self.node_list["RefineAttrs"]:SetActive(false)
	self.node_list["FulingTitle"]:SetActive(false)
	self.node_list["FulingAttrs"]:SetActive(false)
	self.node_list["SuitTitle"]:SetActive(false)
	self.node_list["SuitAttrs"]:SetActive(false)
	self.node_list["HuaShenSkill"]:SetActive(false)
	self.node_list["HuaShenSkillAttr"]:SetActive(false)
end

-- ???????????????
function TipsEquipView:HideCommonEquip()
	self.node_list["StrengthenTitle"]:SetActive(false)
	self.node_list["StrengthenAttrs"]:SetActive(false)
	self.node_list["QualityTitle"]:SetActive(false)
	self.node_list["QualityAttrs"]:SetActive(false)
	self.node_list["YonghengTltle"]:SetActive(false)
	self.node_list["YonghengAttrs"]:SetActive(false)
	self.node_list["CastTitle"]:SetActive(false)
	self.node_list["CastAttrs"]:SetActive(false)
end

-- ???????????????
function TipsEquipView:HideBaiZhanEquip()
	self.node_list["BaiZhanSuitTitle"]:SetActive(false)
	self.node_list["BaiZhanSuitAttrs"]:SetActive(false)
	self.node_list["BaiZhanSuitName"]:SetActive(false)
end

function TipsEquipView:SetEquipCellState()
	if nil == self.data.index or self.from_view == TipsFormDef.FROM_BAG  then return end

	local star_level = 0
	if self.from_view == TipsFormDef.FROM_CHAT_EUQIP and not self.is_mine then
		star_level = self.data.param.star_level or 0
	else
		star_level = self.data.star_level or self.data.param.star_level or 0
	end
	if star_level > 0 then
		self.equip_item:ShowStrengthLable(true)
		self.equip_item:SetStrength("+" .. star_level)
	else
		self.equip_item:ShowStrengthLable(false)
	end
end