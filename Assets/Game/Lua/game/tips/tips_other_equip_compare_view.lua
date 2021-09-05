local CommonFunc = require("game/tips/tips_common_func")
TipsOtherEquipCompareView = TipsOtherEquipCompareView or BaseClass(BaseView)

function TipsOtherEquipCompareView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "OtherEquipCompareTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
end

function TipsOtherEquipCompareView:__delete()

end

function TipsOtherEquipCompareView:ReleaseCallBack()
	CommonFunc.DeleteMe()
	if self.equip_tips then
		self.equip_tips:DeleteMe()
		self.equip_tips = nil
	end

	if self.equip_compare_tips then
		self.equip_compare_tips:DeleteMe()
		self.equip_compare_tips = nil
	end
end

function TipsOtherEquipCompareView:LoadCallBack()
	self.equip_tips = TipsOtherEquipCPView.New(self.node_list["EquipTip"], self)
	self.equip_tips.is_mine = true
	self.equip_compare_tips = TipsOtherEquipCPView.New(self.node_list["EquipCompareTip"], self)
end

function TipsOtherEquipCompareView:CloseCallBack()
	self.equip_tips:CloseCallBack()
	self.equip_compare_tips:CloseCallBack()
end

function TipsOtherEquipCompareView:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.param_t, self.data_cache.close_call_back, self.data_cache.is_tian_sheng)
		self.data_cache = nil
		self:Flush()
	end
end

--关闭装备Tip
function TipsOtherEquipCompareView:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function TipsOtherEquipCompareView:SetData(data, from_view, param_t, close_call_back, is_tian_sheng)
	if not data then
		return
	end
	if self:IsOpen() then
		self.equip_compare_tips:SetData(data, from_view, param_t, close_call_back, is_tian_sheng)
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		local show_strengthen, show_gemstone = false, false
		if item_cfg == nil then
			return
		end
		local equip_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
		local my_data = ZhuanShengData.Instance:GetDressEquipList()[equip_index]
		if EquipData.IsMarryEqType(item_cfg.sub_type) then
			equip_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
			my_data = MarryEquipData.Instance:GetMarryEquipInfo()[equip_index]
		end
		if my_data then
			self.equip_tips:SetData(my_data)
		end
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, param_t = param_t, close_call_back = close_call_back, is_tian_sheng = is_tian_sheng,}
		self:Open()
	end
end

function TipsOtherEquipCompareView:OnFlush(param_t)
	self.equip_tips:OnFlush(param_t)
	self.equip_compare_tips:OnFlush(param_t)
end
--=========item====================
TipsOtherEquipCPView = TipsOtherEquipCPView or BaseClass(BaseRender)
function TipsOtherEquipCPView:__init(instance, parent)
	self.parent = parent
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
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:ListenClick(function() end)
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])
	self.button_root = self.node_list["RightBtn"]
	for i =1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = button.transform:FindHard("Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end
	self.show_special = self.node_list["PanelShowSpecialAttr"]

	for i = 1, 3 do
		self.base_attr_list[i] = self.node_list["TxtBaseAttr" .. i]
		self.special_attr_list[i] = self.node_list["TxtSpecialAttr" .. i]
		self.random_attr_list[i] = self.node_list["TxtRandomAttr" .. i]

		if self.is_mine == nil or self.is_mine == false then
			self.legent_attr_list[i] = self.node_list["TxtCastAttr" .. i]
		end
	end
	if self.is_mine == nil or self.is_mine == false then
		self.show_legent = self.node_list["PanelShowLegentAttr"]
	end
	self.show_random = self.node_list["PanelShowRandomthenAttr"]
	self.scroller_rect = self.node_list["Scroller"].scroll_rect
end

function TipsOtherEquipCPView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.button_handle = nil
	self.buttons = nil
	self.parent = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function TipsOtherEquipCPView:ShowTipContent()
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
	self.node_list["ImgQuantry"].raw_image:LoadSprite(bundle, sprite, function()
		self.node_list["ImgQuantry"]:SetActive(true) end)
	-- self.node_list["Kuang"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line"].image:LoadSprite(ResPath.GetQualityLineBgIcon(item_cfg.color))
	-- if item_cfg.color >= 5 then
	-- 	self.node_list["LongTou"].raw_image:LoadSprite(ResPath.GetTipsLongTouIcon(item_cfg.color))
	-- 	self.node_list["LongWei"].raw_image:LoadSprite(ResPath.GetTipsLongWeiIcon(item_cfg.color))
	-- 	self.node_list["LongTou"]:SetActive(true)
	-- 	self.node_list["LongWei"]:SetActive(true)
	-- else
	-- 	self.node_list["LongTou"]:SetActive(false)
	-- 	self.node_list["LongWei"]:SetActive(false)
	-- end
	self.show_random:SetActive(true)
	self.show_special:SetActive(true)

	local item_name = ToColorStr(item_cfg.name, "#34ACF3FF")
	self.node_list["TxtEquipName"].text.text = item_name
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
	local prof_str = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
	prof_str = string.format(Language.Tip.ZhuangBeiProf, prof_str)
	if EquipData.IsMarryEqType(item_cfg.sub_type) then
		prof_str = Language.Common.SexName[item_cfg.limit_sex] or ""
		local vo = GameVoManager.Instance:GetMainRoleVo()
		prof_str = vo.sex == item_cfg.limit_sex and prof_str or string.format(Language.Mount.ShowRedStr, prof_str)
		prof_str = string.format(Language.Tip.Sex, prof_str)
	end
	self.node_list["TxtEquipProf"].text.text = prof_str
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
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	level_str = string.format(Language.Tip.DengJi, level_str)

	if EquipData.IsZhuanshnegEquipType(item_cfg.sub_type) then
		local zhuanshen_level = ZhuanShengData.Instance:GetZhuanShengInfo().zhuansheng_level or 0
		power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(self.data)
		equip_type = Language.Common.ZhuanShengEquip
		self.show_special:SetActive(false)
		self.node_list["TxtDecompose"].text.text = item_cfg.recyclget
		show_decompose = true

	elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
		power = CommonDataManager.GetCapability(item_cfg)
		equip_type = Language.Common.MarryEquip
		self.show_special:SetActive(false)
		self.node_list["TxtDecompose"].text.text = item_cfg.recyclget
		show_decompose = true
		self.node_list["TxtRecyle"].text.text = Language.Marriage.MarryEquipRecyle .. item_cfg.recyclget
		level_str = item_cfg.limit_level
		if item_cfg.limit_level > MarryEquipData.Instance:GetMarryInfo().marry_level then
			level_str = string.format(Language.Mount.ShowRedStr, level_str)
		end
		level_str = string.format(Language.Tip.MarryDengJi, level_str)
	elseif GameEnum.EQUIP_TYPE_HUNJIE == item_cfg.sub_type then
		equip_type = Language.EquipTypeToName[GameEnum.EQUIP_TYPE_HUNJIE]
		power = CommonDataManager.GetCapability(item_cfg)
	end
	local is_eq_type = EquipData.IsMarryEqType(item_cfg.sub_type)
	self.node_list["TxtRecyle"]:SetActive(is_eq_type)
	self.node_list["TxtDecompose"]:SetActive(not is_eq_type)
	self.node_list["ImgShowRecyle"]:SetActive(not is_eq_type)
	self.node_list["TxtShowRecyle"]:SetActive(not is_eq_type)
	self.node_list["ShowDecomposeInfo"]:SetActive(show_decompose)
	self.node_list["TxtEquipType"].text.text = equip_type
	self.node_list["TxtFight"].text.text = power
	self.node_list["TxtLevel"].text.text = level_str

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
				local text = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrNameNoUnderline[had_base_attr[k].key], had_base_attr[k].value)
				v.text.text = text
			end

			if self.data.param then
				if equip_index == 0 and item_cfg.sub_type ~= 900 and not EquipData.IsMarryEqType(item_cfg.sub_type) then
					if had_base_attr[k] then
						local text = string.format(Language.TipsOtherEquipCompare.NameAndValue,
							Language.Common.AttrNameNoUnderline[had_base_attr[k].key],
							self.data.param["param"..k])
						self.random_attr_list[k].text.text = text
						self.random_attr_list[k]:SetActive(true)

						self.special_attr_list[k]:SetActive(false)
						local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
					end
				elseif EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
					--转生装备
					for i = 1, 3 do
						if nil ~= self.data.param["rand_attr_val_"..i] and self.data.param["rand_attr_val_"..i] > 0 then
							self.random_attr_list[i]:SetActive(true)
							local str = string.format(Language.TipsOtherEquipCompare.NameAndValue,
								Language.Common.ZhuanShengRandAttr[self.data.param["rand_attr_type_"..i]],
								self.data.param["rand_attr_val_"..i])
							self.random_attr_list[i].text.text = str
							show_random = true
							local bundle,asset = ResPath.GetBaseAttrIcon(self.data.param["rand_attr_type_"..i])
						else
							self.random_attr_list[i]:SetActive(false)
						end
					end
				else
					if self.data.param.param1 == 0 then
						self.show_random:SetActive(false)
					else
						local str = string.format(Language.TipsOtherEquipCompare.NameAndValue, 
							Language.Common.AttrNameNoUnderline[had_base_attr[1].key], 
							self.data.param.param1)
						self.random_attr_list[1].text.text = str
						self.random_attr_list[1]:SetActive(true)
						self.random_attr_list[2]:SetActive(false)
						self.random_attr_list[3]:SetActive(false)
						local bundle,asset = ResPath.GetBaseAttrIcon(self.data.param["rand_attr_type_" .. i])
					end

					if self.data.param.param2 == 0 then
						self.show_special:SetActive(false)
					else
						if equip_index == 1 then
							bundle,asset = ResPath.GetBaseAttrIcon(per_pofang)
							local text = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrName.per_pofang, self.data.param.param2)
							self.special_attr_list[1].text.text = text
						else
							bundle,asset = ResPath.GetBaseAttrIcon(per_mianshang)
							local text = string.format(Language.TipsOtherEquipCompare.NameAndValue, Language.Common.AttrName.per_mianshang, self.data.param.param2)
							self.special_attr_list[1].text.text = text
						end
						self.special_attr_list[1]:SetActive(true)
						self.special_attr_list[2]:SetActive(false)
						self.special_attr_list[3]:SetActive(false)
					end
				end
			else
				self.show_random:SetActive(false)
				self.show_special:SetActive(false)
			end
			--随机传奇属性
			if self.is_mine == nil or self.is_mine == false then
				if self.is_tian_sheng and self.is_tian_sheng == true then
					self.show_legent:SetActive(true)
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
							bundle,asset = ResPath.GetBaseAttrIcon(Language.Common.AttrIconKey[random_type_list[k]])
							self.legent_attr_list[k].text.text = string.format(Language.TipsOtherEquipCompare.NameAndValue, 
								Language.Common.ZhuanShengRandAttr[random_type_list[k]],
								t)
						else
							self.legent_attr_list[k]:SetActive(false)
						end
					end
				else
					self.show_legent:SetActive(false)
				end
			end
		end
	end
	self.show_random:SetActive(show_random)

	if (self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE
		or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE
		or self.from_view == TipsFormDef.FROM_BAG) and not EquipData.IsMarryEqType(item_cfg.sub_type) then
		self.node_list["PanceShowStorgeScore"]:SetActive(true)
		self.node_list["TxtStorgeScore"].text.text = item_cfg.guild_storage_score and item_cfg.guild_storage_score or 0
	else
		self.node_list["PanceShowStorgeScore"]:SetActive(false)
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
			v.text:GetComponent(typeof(UnityEngine.UI.Text)).text = tx
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

function TipsOtherEquipCPView:OnClickHandle(handler_type)
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
	self.parent:Close()
end

function TipsOtherEquipCPView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.is_tian_sheng = nil
	self.handle_param_t = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsOtherEquipCPView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	if self.scroller_rect then
		self.scroller_rect.normalizedPosition = Vector2(0, 1)
	end
	self:ShowTipContent()
	showHandlerBtn(self)
end

--设置显示弹出Tip的相关属性显示
function TipsOtherEquipCPView:SetData(data,from_view, param_t, close_call_back, is_tian_sheng)
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
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
end