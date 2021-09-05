local CommonFunc = require("game/tips/tips_common_func")

TipsEquipCompareView = TipsEquipCompareView or BaseClass(BaseView)

function TipsEquipCompareView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "RoleEquipCompareTip"}}

	self.view_layer = UiLayer.Pop

	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.cp_show_legend = false
	self.is_load_effect = false
	self.is_load_effect_cp = false
	self.play_audio = true
	self.is_modal = true
end

function TipsEquipCompareView:LoadCallBack()
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])
	self.cp_equip_item = ItemCell.New()
	self.cp_equip_item:SetInstanceParent(self.node_list["CPEquipItem"])

	self.button_list = {}
	self.stone_item_list = {}
	self.stone_attr_list = {}
	for i = 1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = button.transform:Find("Text")
		self.button_list[i] = {btn = button, text = btn_text}
		self.stone_item_list[i] = ItemCell.New()
		self.stone_item_list[i]:SetInstanceParent(self.node["StoneItem" .. i])

		self.stone_attr_list[i] = {
			stone_text = self.node_list["TxtStoneAttr" .. i],
			stone_text2 = self.node_list["TxtStoneAttr0" .. i],
			stone_obj = self.node_list["Gemstone" .. i],
			stone_obj2 = self.node_list["Gemstone0" .. i],
		}
	end

	self.base_attr_list = {}
	self.streng_attr_list = {}
	self.cast_attr_list = {}
	self.legend_attr_list = {} 
	self.cp_base_attr_list = {}
	self.cp_legend_attr_list = {}

	for i = 1, self.node_list["BaseAttrs"].transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = self.node_list["BaseAttrs"].transform:FindHard("BaseAttr" .. i)
		self.streng_attr_list[#self.streng_attr_list + 1] = self.node_list["StrengthenAttrs"].transform:FindHard("StrengthenAttr" .. i)
		self.cast_attr_list[#self.cast_attr_list + 1] = self.node_list["CastAttrs"].transform:FindHard("CastAttr" .. i)
		self.legend_attr_list[#self.legend_attr_list + 1] = self.node_list["LegendAttrs"].transform:FindHard("LegendAttr" .. i)
		self.cp_base_attr_list[#self.cp_base_attr_list + 1] = self.node_list["CPBaseAttrs"].transform:FindHard("BaseAttr" .. i)
		self.cp_legend_attr_list[#self.cp_legend_attr_list + 1] = self.node_list["CPLegendAttrs"].transform:FindHard("LegendAttr" .. i)
	end
	self.node_list["RecycleValue"]:SetActive(false)
	self.node_list["PanelRecycle"]:SetActive(false)
end

function TipsEquipCompareView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	for k, v in pairs(self.base_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.base_attr_list = {}

	for k, v in pairs(self.streng_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.streng_attr_list = {}

	for k, v in pairs(self.cast_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.cast_attr_list = {}

	for k, v in pairs(self.legend_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.legend_attr_list = {}

	for k, v in pairs(self.cp_base_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.cp_base_attr_list = {}

	for k, v in pairs(self.cp_legend_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.cp_legend_attr_list = {}

	for k,v in pairs(self.stone_item_list) do
		v:DeleteMe()
	end
	self.stone_item_list = {}

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	if self.cp_equip_item then
		self.cp_equip_item:DeleteMe()
		self.cp_equip_item = nil
	end

	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.effect_obj_cp then
		ResMgr:Destroy(self.effect_obj_cp)
		self.effect_obj_cp = nil
	end

	self.button_label = {}
	self.stone_attr_list = {}
	self.button_handle = {}
	self.button_list = {}
	
	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.show_cast = nil
	self.show_legend = nil
	self.cp_show_legend = nil
	self.is_load_effect = nil
	self.is_load_effect_cp = nil
end

function TipsEquipCompareView:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TipsEquipCompareView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsEquipCompareView:HandelAttrs(data, table, is_legend, is_cast)
	for i = 1, #table do
		if table[i] and table[i].gameObject then
			table[i].gameObject:SetActive(false)
		end
	end

	local count = 1
	for k,v in pairs(data) do
		local key = nil
		local value = nil
		if is_legend then
			key = v
		else
			if v > 0 then
				key = CommonDataManager.GetAttrName(k)
				value = v
			end
		end
		if key ~= nil then
			local attr = table[count]
			attr.gameObject:SetActive(true)
			if is_legend then
				attr.text.text = v
			else
				attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.GREEN)
			end
			count = count + 1
			if is_legend then
				self.show_legend = true
				self.cp_show_legend = true
			elseif is_cast then
				self.show_cast = true
			end
		end
	end
end

function TipsEquipCompareView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local data = EquipData.Instance:GetGridData(equip_index)
	if not data then return end

	item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return end
	local name_str = "<color=#34ACF3FF>" .. item_cfg.name .. "</color>"
	self.node_list["TxtCpEquaipName"].text.text = name_str
	self.node_list["TxtEquiptype"].text.text = string.format(Language.Tips.LeiXing, Language.EquipTypeToName[equip_index])
	--self.node_list["TxtEquipType"].text.text = string.format(Language.Tips.LeiXing, Language.EquipTypeToName[equip_index])
	self.node_list["PanelShowLevel"].text.text = string.format(Language.Tips.Jie, Language.Common.NumToChs[item_cfg.order])
	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityRawBgIcon(item_cfg.color)
	local auto_fit_size = true
	self.node_list["ImgQuality"].raw_image:LoadSprite(bundle, sprite, function ()
		self.node_list["ImgQuality"].raw_image:SetNativeSize()
	end)
	-- self.node_list["Kuang2"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line2"].image:LoadSprite(ResPath.GetQualityLineBgIcon(item_cfg.color))
	-- if item_cfg.color >= 5 then
	-- 	self.node_list["LongTou2"].raw_image:LoadSprite(ResPath.GetTipsLongTouIcon(item_cfg.color))
	-- 	self.node_list["LongWei2"].raw_image:LoadSprite(ResPath.GetTipsLongWeiIcon(item_cfg.color))
	-- 	self.node_list["LongTou2"]:SetActive(true)
	-- 	self.node_list["LongWei2"]:SetActive(true)
	-- else
	-- 	self.node_list["LongTou2"]:SetActive(false)
	-- 	self.node_list["LongWei2"]:SetActive(false)
	-- end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = level_befor.."级【"..level_behind.."转】"
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)

	self.node_list["TxtLevel"].text.text = string.format(Language.Tips.Level, level_str)
	local role_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
	local prof_str = (role_prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
						or string.format(Language.Mount.ShowRedStr, ZhuanZhiData.Instance:GetProfNameCfg(prof, grade))
	self.node_list["TxtEquipProf"].text.text = string.format(Language.Tips.ZhiYe, prof_str)

	self.equip_item:SetData(data)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local had_base_attr = {}

	local base_attr_count = 1
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[k]..": "..ToColorStr(v, TEXT_COLOR.BLUE_1)
			base_attr_count = base_attr_count + 1
		end
	end
	for i = base_attr_count, #self.base_attr_list do
		self.base_attr_list[i].gameObject:SetActive(false)
	end

	--基础、强化、神铸、传奇属性
	local base_result, strength_result, cast_result = ForgeData.Instance:GetForgeAddition(data)

	local l_data = {}
	self.node_list["PanelShowLegendTitle"]:SetActive(false)
	self.node_list["LegendAttrs"]:SetActive(false)
	if data.param and data.param.xianpin_type_list then
		for k,v in pairs(data.param.xianpin_type_list) do
			if nil ~= v and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if nil ~= legend_cfg then
					self.node_list["PanelShowLegendTitle"]:SetActive(true)
					self.node_list["LegendAttrs"]:SetActive(true)
					color = TEXT_COLOR.BLUE
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.PURPLE
					end
					local t = ToColorStr(legend_cfg.desc, color)
					table.insert(l_data, t)
				end
			end
		end
	end
	self.node_list["TxtRecyleValue"].text.text = string.format(" <color=#ffffff>%s</color>", item_cfg.recyclget)

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(data, true)
	self.node_list["TxtFight"].text.text = capability

	-- if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
	-- 	self.node_list["PanleStorgeScore"]:SetActive(true)
	-- 	self.node_list["PanelShowStorgeScore"]:SetActive(true)
	-- 	self.node_list["TxtStorgeScore"].text.text = string.format(Language.Tips.CangKu, item_cfg.guild_storage_score)
	-- else
	-- 	self.node_list["PanleStorgeScore"]:SetActive(false)
	-- 	self.node_list["PanelShowStorgeScore"]:SetActive(false)
	-- end

	self:HandelAttrs(l_data, self.legend_attr_list, true)
	self:HandelAttrs(strength_result, self.streng_attr_list)
	self:HandelAttrs(cast_result, self.cast_attr_list, false, true)

	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	--设置神铸等级对应的特效
	if data.param.shen_level > 0 and not self.is_load_effect and not self.effect_obj then
		local effect_index = ForgeData.Instance:GetNameEffectByData(data)
		local bundle, asset = ResPath.GetUITipsEffect(effect_index)
		self.is_load_effect =  true

		local async_loader = AllocAsyncLoader(self, "level_effect_loader")
		async_loader:Load(bundle, asset, function(obj)
			if not IsNil(obj) then
				local transform = obj.transform
				transform:SetParent(self.node_list["NameEffect"].transform, false)
				self.effect_obj = obj.gameObject
				self.is_load_effect = false
			end
		end)
	end

	local show_strengthen, show_gemstone = false, false
	local star_bundle, star_asset = nil, nil
	local star_color = 0
	-- 星级属性
	if data.param then
		if data.param.strengthen_level > 0 then
			show_strengthen = true
		end
	end

	-- 宝石属性
	if equip_index >= 0 then
		for k, v in pairs(self.stone_attr_list) do
			v.stone_obj:SetActive(false)
			v.stone_obj2:SetActive(false)
			show_gemstone = false
		end
		for k, v in pairs(ForgeData.Instance:GetGemInfo()) do
			if k == equip_index then
				for i, j in pairs(v) do
					self.stone_attr_list[i + 1].stone_obj:SetActive(j.stone_id > 0)
					self.stone_attr_list[i + 1].stone_obj2:SetActive(j.stone_id > 0)
					if j.stone_id > 0 then
						show_gemstone = true
						local stone_cfg = ForgeData.Instance:GetGemCfg(j.stone_id)
						local item_data = {}
						item_data.item_id = j.stone_id
						item_data.is_bind = 0
						self.stone_item_list[i + 1]:SetData(item_data)
						local stone_attr = ForgeData.Instance:GetGemAttr(j.stone_id)

						local str = ""
						if #stone_attr >= 2 then
							str = self:StoneScendAttrString(stone_attr[2].attr_name, stone_attr[2].attr_value)
						end

						self.stone_attr_list[i + 1].stone_text.text.text = string.format("%s+%s %s", stone_attr[1].attr_name, stone_attr[1].attr_value, str)
						self.stone_attr_list[i + 1].stone_text2.text.text = string.format("%s+%s %s", stone_attr[1].attr_name, stone_attr[1].attr_value, str)
					end
				end
			end
		end
	end

	self.node_list["PanelShowstreng"]:SetActive(show_strengthen)
	self.node_list["StrengthenAttrs"]:SetActive(show_strengthen)
	self.node_list["PanelShowCastTitle"]:SetActive(self.show_cast)
	self.node_list["CastAttrs"]:SetActive(self.show_cast)
	self.node_list["PanelShowLegendTitle"]:SetActive(self.show_legend)
	self.node_list["LegendAttrs"]:SetActive(self.show_legend)
	self.node_list["PanelShowInsertedTitle"]:SetActive(show_gemstone)
	self.node_list["PanelShowGemstones"]:SetActive(show_gemstone)
end

local function showHandlerBtn(self)
	if nil == self.from_view then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.button_list) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if handler_type == 23 then
			--显示回收值
			self.node_list["RecycleValue"]:SetActive(true)
			self.node_list["PanelRecycle"]:SetActive(true)
		end

		if nil ~= tx then
			v.btn:SetActive(true)
			v.text.text.text = tx
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

function TipsEquipCompareView:SetCompareEquipData()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtCpEquaipName"].text.text = name_str
	self.node_list["TxtCpGrad"].text.text = string.format(Language.Tips.Jie, Language.Common.NumToChs[item_cfg.order] or "")

	local bundle, sprite = ResPath.GetQualityRawBgIcon(item_cfg.color)
	local color = nil
	local auto_fit_size = true
	self.node_list["PanelItemInfo"].raw_image:LoadSprite(bundle, sprite, function ()
		self.node_list["PanelItemInfo"].raw_image:SetNativeSize()
	end)
	-- self.node_list["Kuang1"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line1"].image:LoadSprite(ResPath.GetQualityLineBgIcon(item_cfg.color))
	-- if item_cfg.color >= 5 then
	-- 	self.node_list["LongTou1"].raw_image:LoadSprite(ResPath.GetTipsLongTouIcon(item_cfg.color))
	-- 	self.node_list["LongWei1"].raw_image:LoadSprite(ResPath.GetTipsLongWeiIcon(item_cfg.color))
	-- 	self.node_list["LongTou1"]:SetActive(true)
	-- 	self.node_list["LongWei1"]:SetActive(true)
	-- else
	-- 	self.node_list["LongTou1"]:SetActive(false)
	-- 	self.node_list["LongWei1"]:SetActive(false)
	-- end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = string.format(Language.Tips.JiZhuan,level_befor,level_behind)
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.node_list["TxtCPlevel"].text.text = string.format(Language.Tips.Level, level_str)
	local role_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(item_cfg.limit_prof)
	local prof_str = (role_prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
						or string.format(Language.Mount.ShowRedStr, ZhuanZhiData.Instance:GetProfNameCfg(prof, grade))
	self.node_list["TxtCPProf"].text.text = string.format(Language.Tips.ZhiYe, prof_str)
	self.cp_equip_item:SetData(self.data)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	self:HandelAttrs(base_attr_list, self.cp_base_attr_list)

	local l_data = {}
	if self.data.param and self.data.param.xianpin_type_list then
		for k,v in pairs(self.data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil then
					self.node_list["ShowLegendTitle"]:SetActive(true)
					self.node_list["CPLegendAttrs"]:SetActive(true)
					color = TEXT_COLOR.BLUE
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.PURPLE
					end
					local t = ToColorStr(legend_cfg.desc, color)
					table.insert(l_data, t)
				end
			end
		end
	end
	self:HandelAttrs(l_data, self.cp_legend_attr_list, true)
	self.node_list["TxtCPRecyleValue"].text.text = string.format(" <color=#ffffff>%s</color>", item_cfg.recyclget)

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(self.data, false, true)
	self.node_list["TxtFightText"].text.text = capability
	if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
		self.node_list["TxtCPStorgeScore"].text.text = string.format(Language.Tips.CangKu, item_cfg.guild_storage_score)
	end

	self.node_list["ShowLegendTitle"]:SetActive(self.cp_show_legend)
	self.node_list["CPLegendAttrs"]:SetActive(self.cp_show_legend)

	if self.effect_obj_cp then
		ResMgr:Destroy(self.effect_obj_cp)
		self.effect_obj_cp = nil
	end

	--添加神铸等级名字特效
	if self.data.param.shen_level > 0 and not self.is_load_effect_cp and not self.effect_obj_cp then
		local effect_index = ForgeData.Instance:GetNameEffectByData(self.data)
		local bundle, asset = ResPath.GetUITipsEffect(effect_index)
		self.is_load_effect_cp =  true

		local async_loader = AllocAsyncLoader(self, "name_effect_loader")
		async_loader:Load(bundle, asset, function(obj)
			if not IsNil(obj) then
				obj.transform:SetParent(self.node_list["NameEffect"].transform, false)
				self.effect_obj_cp = obj.gameObject
				self.is_load_effect_cp = false
			end
		end)
	end

end

function TipsEquipCompareView:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
end

function TipsEquipCompareView:OnClickHandle(handler_type)
	if nil == self.data then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

function TipsEquipCompareView:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function TipsEquipCompareView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	self.close_call_back = close_call_back
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsEquipCompareView:OnFlush()
	self:ShowTipContent()
	self:SetCompareEquipData()
	showHandlerBtn(self)
end
