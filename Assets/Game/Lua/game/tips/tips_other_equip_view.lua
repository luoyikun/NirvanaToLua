local CommonFunc = require("game/tips/tips_common_func")
TipsOtherEquipView = TipsOtherEquipView or BaseClass(BaseView)

function TipsOtherEquipView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "OtherEquipTip"}}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.legent_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function TipsOtherEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:ListenClick(function() end)
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])
	for i = 1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = self.node_list["TxtBtn" .. i]
		self.buttons[i] = {btn = button, text = btn_text}
	end
	self.show_special = self.node_list["PanelShowSpecialAttr"]

	for i = 1, 3 do
		self.base_attr_list[i] = self.node_list["TxtBaseAttr_" .. i]
		self.special_attr_list[i] = self.node_list["TxtSpecialAttr_" .. i]
		self.random_attr_list[i] = self.node_list["TxtRandomAttr_" .. i]
		self.legent_attr_list[i] = self.node_list["TxtLegentName_" .. i]
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightText"], "FightPower3")
end

function TipsOtherEquipView:CloseView()
	self:Close()
end

function TipsOtherEquipView:ReleaseCallBack()
	self.fight_text = nil
	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
	self.show_special = nil
	self.show_no_trade = nil

	self.buttons = {}
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.legent_attr_list = {}

	self:RemoveCountDown()

	if self.xiaogui_data_change then
		GlobalEventSystem:UnBind(self.xiaogui_data_change)
		self.xiaogui_data_change = nil
	end
end

function TipsOtherEquipView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.button_handle = nil
	self.buttons = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	self:RemoveCountDown()
end

function TipsOtherEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local equip_index = (item_cfg.sub_type) % 100
	if EquipData.IsMarryEqType(item_cfg.sub_type) then
		equip_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
	end

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityRawBgIcon(item_cfg.color)
	self.node_list["QualityImage"].raw_image:LoadSprite(bundle, sprite, function()
		self.node_list["QualityImage"]:SetActive(true) end)
	self.node_list["Kuang"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line"].image:LoadSprite(ResPath.GetQualityTopBg(item_cfg.color))
	-- if item_cfg.color >= 5 then
	-- 	self.node_list["LongTou"].raw_image:LoadSprite(ResPath.GetTipsLongTouIcon(item_cfg.color))
	-- 	self.node_list["LongWei"].raw_image:LoadSprite(ResPath.GetTipsLongWeiIcon(item_cfg.color))
	-- 	self.node_list["LongTou"]:SetActive(true)
	-- 	self.node_list["LongWei"]:SetActive(true)
	-- else
	-- 	self.node_list["LongTou"]:SetActive(false)
	-- 	self.node_list["LongWei"]:SetActive(false)
	-- end
	self.node_list["PanelShowRandomthenAttr"]:SetActive(true)
	self.show_special:SetActive(true)

	-- local item_name = ToColorStr(item_cfg.name, "#34ACF3FF")
	self.node_list["TxtEquaipName"].text.text = item_cfg.name
	local power = 0
	local equip_type = ""
	local show_decompose = false
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_befor = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100) or 0
	-- local level_behind = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1) or 0

	-- if item_cfg.equip_level then
	-- 	if item_cfg.equip_level == "" or item_cfg.equip_level <= 0 then
	-- 		level_befor = 0
	-- 		level_behind = 0
	-- 	else
	-- 		level_befor = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level % 100) or 100
	-- 		level_behind = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level / 100) or math.floor(item_cfg.equip_level / 100) - 1
	-- 	end
	-- end
	local equip_level = item_cfg.equip_level and item_cfg.equip_level or item_cfg.limit_level
	if equip_level == "" then
		equip_level = 0
	end
	local level = math.max(0, equip_level)
	-- local level = math.max(0, item_cfg.equip_level and item_cfg.equip_level or item_cfg.limit_level)
	local level_zhuan = PlayerData.GetLevelString(level)
	-- local level_zhuan = string.format(Language.Common.NoZhuan_level, level_behind * 100, level_befor) -- 临时 确定好转职后重写
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	level_str = string.format(Language.Tip.DengJi, level_str)

	if EquipData.IsZhuanshnegEquipType(item_cfg.sub_type) then
		local zhuanshen_level = ZhuanShengData.Instance:GetZhuanShengInfo().zhuansheng_level or 0
		power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(self.data)
		equip_type = string.format(Language.Tip.ZhuangBeiLeiXing, Language.Common.ZhuanShengEquip)
		self.show_special:SetActive(false)
		self.node_list["PanshowRecyle"].text.text = item_cfg.recyclget
		show_decompose = true

	elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
		power = CommonDataManager.GetCapability(item_cfg)
		equip_type = string.format(Language.Tip.ZhuangBeiLeiXing, Language.Common.MarryEquip)
		self.show_special:SetActive(false)
		self.node_list["PanshowRecyle"].text.text = item_cfg.recyclget
		show_decompose = true
		self.node_list["TxtRecyle"].text.text = Language.Marriage.MarryEquipRecyle .. item_cfg.recyclget
		level_str = item_cfg.limit_level
		if item_cfg.limit_level > MarryEquipData.Instance:GetMarryInfo().marry_level then
			level_str = string.format(Language.Mount.ShowRedStr, level_str)
		end
		level_str = string.format(Language.Tip.MarryDengJi, level_str)
	elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
		power = CommonDataManager.GetCapability(item_cfg)
		equip_type = string.format(Language.Tip.ZhuangBeiLeiXing, Language.Common.LittlePetEquip)
		self.show_special:SetActive(false)
		show_decompose = false
		level_str = ""
	elseif EquipData.IsLittlePetEqType(item_cfg.sub_type) then
		equip_type = string.format(Language.Tip.ZhuangBeiLeiXing, Language.Common.EquipLittlePet)
		self.show_special:SetActive(false)
		show_decompose = true
		local petid = LittlePetData.Instance:GetLittlePetIDByItemID(item_cfg.id)
		local pet_cfg = LittlePetData.Instance:GetLittlePetCfg()
		if pet_cfg == nil then
			return
		end
		local pet_info = pet_cfg[petid]
		if pet_info then
			power = LittlePetData.Instance:CalPetBaseFightPower(false, pet_info.active_item_id)
		end
	elseif GameEnum.EQUIP_TYPE_HUNJIE == item_cfg.sub_type then
		equip_type = string.format(Language.Tip.ZhuangBeiLeiXing, Language.EquipTypeToName[GameEnum.EQUIP_TYPE_HUNJIE])
		power = CommonDataManager.GetCapability(item_cfg)
	elseif DouQiData.Instance:IsDouqiEqupi(self.data.item_id) then
		power = CommonDataManager.GetCapability(item_cfg)
	end

	local b = EquipData.IsMarryEqType(item_cfg.sub_type)
	self.node_list["PanelShowRecyle"]:SetActive(not b)
	self.node_list["ImgShowRecyle"]:SetActive(not b)
	self.node_list["PanshowRecyle"]:SetActive(not b)
	self.node_list["TxtRecyle"]:SetActive(b)

	self.node_list["PanelShowDecomposeInfo"]:SetActive(show_decompose)
	self.node_list["TxtEquipType"].text.text = equip_type
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
	self.node_list["TxtLevel"].text.text = level_str

	self:SetXiaoguiTime()

	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local had_base_attr = {}

	for k, v in pairs(base_attr_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end

	local show_random = false
	-- 基础
	if #had_base_attr > 0 then
		for k, v in pairs(self.base_attr_list) do
			v:SetActive(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				local str = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrNameUnderline[had_base_attr[k].key], had_base_attr[k].value)
				if had_base_attr[k].key == "jianren"
					or had_base_attr[k].key == "per_kangbao" 
					or had_base_attr[k].key == "per_mianshang" 
					or had_base_attr[k].key == "pvp_reduce_hurt_per" then
					str = string.format(Language.TipsOtherEquipCompare.SpecialNameAndValue, Language.Common.AttrNameUnderline[had_base_attr[k].key], tostring(had_base_attr[k].value / 100))
				end
				v.text.text = str
			end

			if self.data.param then
				if equip_index == 0 and item_cfg.sub_type ~= 900 and not EquipData.IsMarryEqType(item_cfg.sub_type) then
					if had_base_attr[k] then
						local str = string.format(Language.TipsOtherEquipCompare.NameAndValue, 
							Language.Common.AttrNameNoUnderline[had_base_attr[k].key], self.data.param["param"..k])
						self.random_attr_list[k].text.text = str
						self.random_attr_list[k]:SetActive(true)
						self.special_attr_list[k]:SetActive(false)
					end
				elseif EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
					--转生装备
					for i = 1, 3 do
						if nil ~= self.data.param["rand_attr_val_"..i] and self.data.param["rand_attr_val_"..i] > 0 then
							self.random_attr_list[i]:SetActive(true)
							local str = string.format(Language.TipsOtherEquipCompare,
								Language.Common.ZhuanShengRandAttr[self.data.param["rand_attr_type_"..i]], self.data.param["rand_attr_val_"..i])
							self.random_attr_list[i].text.text = str
							show_random = true
						else
							self.random_attr_list[i]:SetActive(false)
						end
					end
				else
					if self.data.param.param1 == 0 then
						self.node_list["PanelShowRandomthenAttr"]:SetActive(false)
					else
						local str = string.format(Language.TipsOtherEquipCompare.NameAndValue,
							Language.Common.AttrNameNoUnderline[had_base_attr[1].key], self.data.param.param1)
						self.random_attr_list[1].text.text = str
						self.random_attr_list[1]:SetActive(true)
						self.random_attr_list[2]:SetActive(false)
						self.random_attr_list[3]:SetActive(false)
					end

					if self.data.param.param2 == 0 then
						self.show_special:SetActive(false)
					else
						local bundle, asset = nil, nil
						if equip_index == 1 then
							bundle,asset = ResPath.GetBaseAttrIcon(per_pofang)
							local str = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrName.per_pofang, self.data.param.param2)
							self.special_attr_list[1].text.text = str
						else
							bundle,asset = ResPath.GetBaseAttrIcon(per_mianshang)
							local str = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrName.per_mianshang, self.data.param.param2)
							self.special_attr_list[1].text.text = str
						end
						self.special_attr_list[1]:SetActive(true)
						self.special_attr_list[2]:SetActive(false)
						self.special_attr_list[3]:SetActive(false)
					end
				end
			else
				self.node_list["PanelShowRandomthenAttr"]:SetActive(false)
				self.show_special:SetActive(false)
			end

			--随机传奇属性
			if self.is_tian_sheng and self.is_tian_sheng == true then
				self.node_list["PanelShowLegentAttr"]:SetActive(true)
				local random_type_list = ForgeData.Instance:GetShowZSType(self.data.limit_level, self.data.color, self.data.sub_type)
				local random_list = ForgeData.Instance:GetZSRandomValueList(self.data.limit_level, self.data.color, self.data.sub_type)
				for k,v in pairs(random_list) do
					if v then
						color = TEXT_COLOR.BLUE
						if self.data.color == 1 then
							color = TEXT_COLOR.PURPLE
						end
						self.legent_attr_list[k]:SetActive(true)
						local t = random_list[k].attr_value_min .. "-" .. random_list[k].attr_value_max
						t = ToColorStr(t, color)
						local bundle, asset = nil, nil
						local str = string.format(Language.TipsOtherEquipCompare.NameAndValue,
							Language.Common.ZhuanShengRandAttr[random_type_list[k]], t)
						self.legent_attr_list[k].text.text = str
					else
						self.legent_attr_list[k]:SetActive(false)
					end
				end
			else
				self.node_list["PanelShowLegentAttr"]:SetActive(false)
			end
		end
	end

	self.node_list["PanelShowRandomthenAttr"]:SetActive(show_random)
	self.node_list["PanshowWearIcon"]:SetActive(self.from_view == TipsFormDef.FROM_ZHUANSHENG_VIEW)

	-- if (self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE
	-- 		or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE
	-- 		or self.from_view == TipsFormDef.FROM_BAG) and not EquipData.IsMarryEqType(item_cfg.sub_type) then
	-- 	self.node_list["PanelShowStorgeScore"]:SetActive(true)
	-- 	self.node_list["TxtStorgeScore"].text.text = item_cfg.guild_storage_score and item_cfg.guild_storage_score or 0
	-- else
	-- 	self.node_list["PanelShowStorgeScore"]:SetActive(false)
	-- end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local role_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
	local base_prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
	local prof_str = ""
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
	if item_cfg.limit_prof == 5 then
		prof_str = Language.Common.AllProf2
	else
		prof_str = (role_prof == item_cfg.limit_prof) and ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
					or string.format(Language.Mount.ShowRedStr, ZhuanZhiData.Instance:GetProfNameCfg(prof, grade))
	end					

	if EquipData.IsXiaoguiEqType(item_cfg.sub_type) then
		prof_str = Language.Common.AllProf
	end
	prof_str = string.format(Language.Tip.ZhuangBeiProf, prof_str)
	if EquipData.IsMarryEqType(item_cfg.sub_type) then
		prof_str = Language.Common.SexName[item_cfg.limit_sex] or ""
		prof_str = vo.sex == item_cfg.limit_sex and prof_str or string.format(Language.Mount.ShowRedStr, prof_str)
		prof_str = string.format(Language.Tip.Sex, prof_str)
	end

	if EquipData.IsLittlePetToyType(item_cfg.sub_type) then
		prof_str = ""
	end

	self.node_list["TxtEquipProf"].text.text = prof_str

	local is_xiaogui = EquipData.IsXiaoguiEqType(item_cfg.sub_type)
	self.node_list["Description"]:SetActive(is_xiaogui)
	if is_xiaogui then
		self.node_list["Description"].text.text = item_cfg.description or ""
	end
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
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
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

function TipsOtherEquipView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data, item_cfg, handler_type, self.from_view, self.handle_param_t) then
		return
	end
	self:Close()
end

--关闭装备Tip
function TipsOtherEquipView:OnClickCloseButton()
	self:Close()
end

function TipsOtherEquipView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.is_tian_sheng = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
	end

	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function TipsOtherEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.node_list["Scroller"].normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
end

--设置显示弹出Tip的相关属性显示
function TipsOtherEquipView:SetData(data, from_view, param_t, close_call_back, show_the_random, is_tian_sheng)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self.close_call_back = close_call_back
	self.is_tian_sheng = is_tian_sheng
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.show_the_random = show_the_random
	self:Flush()
end

function TipsOtherEquipView:SetXiaoguiTime()
	self:RemoveCountDown()
	if nil == self.data then
		return
	end

	local index = self.data.index or 0
	local item_cfg, _ = ItemData.Instance:GetItemConfig(self.data.item_id)
	local is_xiaogui = EquipData.IsXiaoguiEqType(item_cfg.sub_type)
	self.node_list["TimeLeft"]:SetActive(is_xiaogui)
	if not is_xiaogui then return end

	local xiaogui_info = EquipData.Instance:GetImpGuardInfo()
	if not xiaogui_info[index] then return end

	if nil == self.xiaogui_data_change then
		self.xiaogui_data_change = GlobalEventSystem:Bind(OtherEventType.IMP_GUARD, BindTool.Bind(self.SetXiaoguiTime, self))
	end
	local time_left = 0

	if self.from_view == TipsFormDef.FROM_PLAYER_INFO or self.from_view == TipsFormDef.BAIZHAN_SUIT then
		time_left = xiaogui_info[index].item_wrapper.invalid_time - TimeCtrl.Instance:GetServerTime()
	elseif self.from_view == TipsFormDef.FROM_BAG then
		time_left = self.data.invalid_time - TimeCtrl.Instance:GetServerTime()
	end
	
	if time_left > 0 then
		local time_text = TimeUtil.FormatSecond2DHMS(time_left)
		self.node_list["TimeLeft"].text.text = string.format(Language.Player.ImpText, time_text)
		self.count_down = CountDown.Instance:AddCountDown(time_left, 1, BindTool.Bind(self.CountDown, self))
	else
		self.node_list["TimeLeft"].text.text = Language.Player.ImpDated
	end
end

-- 倒计时函数
function TipsOtherEquipView:CountDown(elapse_time, total_time)
	local time_left = total_time - elapse_time
	time_left = TimeUtil.FormatSecond2DHMS(time_left)
	self.node_list["TimeLeft"].text.text = string.format(Language.Player.ImpText, time_left)

	if elapse_time >= total_time then
		self.node_list["TimeLeft"].text.text = Language.Player.ImpDated
		self:RemoveCountDown()
	end
end

function TipsOtherEquipView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end