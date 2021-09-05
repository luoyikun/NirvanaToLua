local CommonFunc = require("game/tips/tips_common_func")
TipsSpiritEquipView = TipsSpiritEquipView or BaseClass(BaseView)

function TipsSpiritEquipView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "SpiritEquipTip"}}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.fix_show_time = 8
	self.play_audio = true
	self.total_attr_list = CommonStruct.AttributeNoUnderline()
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsSpiritEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])
	for i =1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = button.transform:FindHard("Text"):GetComponent(typeof(UnityEngine.UI.Text))
		self.buttons[i] = {btn = button, text = btn_text}
	end

	for i = 1, 4 do
		self.base_attr_list[i] = {attr_name = self.node_list["TxtBaseAttr_" .. i],
								attr_value = self.node_list["TxtBaseAttr_" .. i .. "Value"]}
	end

	for i = 1, 7 do
		self.special_attr_list[i] = self.node_list["TxtCastAttr_" .. i]
	end
	self.add_attr_values = {}
	for i = 1, 3 do
		self.add_attr_values[i] = self.node_list["TxtBaseAttr_" .. i .. "Text"]
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.scroller_rect = self.node_list["Scroller"].scroll_rect
	self.display = self.node_list["Display"]
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TipsSpiritEquipView, BindTool.Bind(self.GetUiCallBack, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"], "FightPower3")

end

function TipsSpiritEquipView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.buttons = nil
	self.fix_show_time = nil
	self.button_handle = nil
	
end

function TipsSpiritEquipView:ReleaseCallBack()
	self.fight_text = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TipsSpiritEquipView)
	end
	
	-- 清理变量
	self.display = nil
	self.scroller_rect = nil
	self.add_attr_values = nil
end

function TipsSpiritEquipView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function TipsSpiritEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local spirit_level = nil ~= self.data.param and self.data.param.strengthen_level or 0
	local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.data.item_id, spirit_level)
	local aptitude_data = SpiritData.Instance:GetSpiritTalentAttrCfgById(self.data.item_id)
	if self.data.param then
		local wuxing = self.data.param.param1 or 0
		local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(self.data.item_id, self.data.param.strengthen_level,aptitude_data,wuxing)
		self.total_attr_list = CommonDataManager.GetAttributteNoUnderline(total_attr_list, true)
		self.node_list["TxtBaseAttr_5"]:SetActive(true)
		self.node_list["TxtBaseAttr_5"].text.text = string.format("%s", Language.JingLing.WuXing)
		self.node_list["TxtBaseAttr_5Value"].text.text = string.format("<color=#D0D8FFFF>：</color>%s", wuxing)
		-- local recycl_wuxing_value = SpiritData.Instance:GetRecyclWuxingValue(wuxing) - SpiritData.Instance:GetRecyclWuxingValue(0)
		-- self.node_list["TxtSaleInfo2"].text.text = recycl_wuxing_value
	else
		-- self.node_list["TxtSaleInfo2"].text.text = 0
		local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(self.data.item_id, 1,aptitude_data,0)
		self.total_attr_list = CommonDataManager.GetAttributteNoUnderline(total_attr_list, true)
	end
	if item_cfg == nil or spirit_cfg == nil then
		return
	end
	self:SetRoleModel(item_cfg.is_display_role)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.node_list["TXTEquaipName"].text.text = name_str
	local bundle, asset = ResPath.GetQualityRawBgIcon(item_cfg.color)
	self.node_list["ItemInfo"].raw_image:LoadSprite(bundle, asset)
	self.node_list["TxtTitle"].text.text = string.format(Language.Tips.LeiXing, Language.JingLing.TabbarName[1])

	local recycl_value = SpiritData.Instance:GetSpiritAllLingjingByLevel(self.data.item_id, self.data.param and self.data.param.strengthen_level or 1)
	self.node_list["TxtSaleInfo1"].text.text = recycl_value
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

	-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
	local equip_level = item_cfg.equip_level and item_cfg.equip_level or item_cfg.limit_level
	if equip_level == "" then
		equip_level = 0
	end
	local level = math.max(0, equip_level)
	local level_zhuan = PlayerData.GetLevelString(level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.node_list["TxtLevel"].text.text = string.format(Language.Tips.DengJi, level_str)
	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(spirit_cfg, true)
	local had_base_attr = {}

	local show_special_attr = false
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end
	-- 基础
	if #had_base_attr > 0 then
		for k, v in pairs(self.base_attr_list) do
			v.attr_name:SetActive(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				v.attr_name.text.text = Language.Common.AttrNameNoUnderline[had_base_attr[k].key]
				v.attr_value.text.text = string.format("<color=#D0D8FFFF>：</color>%s", had_base_attr[k].value)
			end

			if self.data.param and self.data.param.xianpin_type_list then
				if next(self.data.param.xianpin_type_list) == nil then
					for _, v2 in pairs(self.special_attr_list) do
						v2:SetActive(false)
					end
				end
				for k2, v2 in pairs(self.data.param.xianpin_type_list) do
					local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(self.data.item_id)
					if self.special_attr_list[k2] then
						if cfg["type"..v2] then
							self.special_attr_list[k2]:SetActive(true)
							self.special_attr_list[k2].text.text = string.format("%s：<color=#FFFFFFFF>%s%</color>", JINGLING_TALENT_ATTR_NAME[JINGLING_TALENT_TYPE[v2]], cfg["type"..v2] / 100)
							show_special_attr = true
						else
							print_error("No Spirit Talent Type :", "type"..v2)
						end
					end
					for i = (#self.data.param.xianpin_type_list + 1), #self.special_attr_list do
						self.special_attr_list[i]:SetActive(false)
					end
				end
			else
				for _, v2 in pairs(self.special_attr_list) do
					v2:SetActive(false)
				end
			end
		end
	end


	local add_attr_value = SpiritData.Instance:GetAddAttrValue(self.total_attr_list,base_attr_list)
	for i = 1, 3 do
		if add_attr_value[i] ~= 0 and nil ~= self.data.param then
			self.add_attr_values[i].text.text = "<color=" .. TEXT_COLOR.GREEN_1 .. ">(+" .. add_attr_value[i] .. ")</color>"
		else
			self.add_attr_values[i].text.text = ""
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(self.total_attr_list)
	end
	self.node_list["TxtSpecialAttr"]:SetActive(show_special_attr)
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
			v.text.text = tx
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

function TipsSpiritEquipView:SetRoleModel(display_role)
	local bundle, asset = nil, nil
	local res_id = 0
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	end

	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
		self.model:LoadSceneEffect(bundle, asset .. "_UIeffect", self.node_list["Display"].transform:Find("FitScale"))
		self.model:SetRotation(Vector3(0, -15, 0))
	end
end

function TipsSpiritEquipView:OnClickHandle(handler_type)
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
	self:Close()
end

function TipsSpiritEquipView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					self.model:SetTrigger(ANIMATOR_PARAM.REST)
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

--关闭装备Tip
function TipsSpiritEquipView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
	self:SetModleRestAni()
	if self.display ~= nil then
		self.display.ui3d_display:ResetRotation()
	end
end

--设置显示弹出Tip的相关属性显示
function TipsSpiritEquipView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.close_call_back = close_call_back
	self:Flush()
end

function TipsSpiritEquipView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.SpiritUse then
		if self.node_list["Btn1"] then
			return self.node_list["Btn1"], BindTool.Bind(self.OnClickHandle, self, 1)
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end