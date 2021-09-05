ItemCell = ItemCell or BaseClass(BaseRender)

local PROP_USE_TYPE = {1, 8, 21, 22, 23, 25, 26, 78 , 82, 109}
local ZHISHENG_ITEM_USE_LIST = { 			 		-- 直升丹使用类型
	[67] = 1,
	[68] = 1,
	[69] = 1,
	[70] = 1,
	[71] = 1,
	[72] = 1,
	[84] = 1,
	[94] = 1,
	[99] = 1,
	[107] = 1,
	}

local SHENGYIN_USETYPE = 96

function ItemCell:__init()
	self.is_use_objpool = false

	if nil == self.root_node then
		local bundle, asset = ResPath.GetWidgets("ItemCell")
        local u3dobj = U3DObject(ResPoolMgr:TryGetGameObject(bundle, asset))
		BaseRender.SetInstance(self, u3dobj)
		self.is_use_objpool = true
	end

	self.hide_numtxt_less_num = 1
	self.data = {}
	self.is_gray = false
	self.quality_enbale = true
	self.is_destroy_effect = false
	self.index = -1
	self.is_clear_listen = true
	self.is_showtip = true														-- 是否显示物品信息提示

	self.show_stars = {}

	self.item_effect = {}


	self.is_load_effect = false
	self.ignore_arrow = false
	self.curr_arrow = true 			-- true 为向上 , false 向下
	self.from_list_bag = false
	self.show_orange_effect = false -- 是否显示橙色特效
	self.show_virtual_effect = false -- 虚拟物品特效显示

	self.is_destory_effect_loading = false
	self.child_tab = {}

	if self.is_use_objpool then
		self:Reset()
	end
end

function ItemCell:__delete()
	self:ResetRes()

	for k, v in pairs(self.child_tab) do
		if v then
			ResPoolMgr:Release(v.gameObject)
		end
	end
	self.child_tab = {}

	for _, v in pairs(self.item_effect) do
		if nil ~= v.obj then
			ResMgr:Destroy(v.obj)
		end
	end
	self.item_effect = {}

	if self.is_use_objpool and not self:IsNil() then
		self:Reset()
		ResPoolMgr:Release(self.root_node.gameObject)
	end

	self.is_load_effect = nil
	self.data = nil
	self.is_destroy_effect = nil
	self.equip_fight_power = nil
	self.is_tian_sheng = nil
	self.from_view = nil
	self.hide_effect = nil
	self.show_orange_effect = nil
	self.show_virtual_effect = nil
	self.show_stars = {}
end

--为了保留只有一份ItemCell预制体
--重写SetInstance不允许ItemCell.New(self.node_list["CellNode"])这样的创建方式
function ItemCell:SetInstance(instance)
	if nil == instance or type(instance) == "userdata" then
		BaseRender.SetInstance(self, instance)
	else
		print_error("ItemCell.New(gameObject) not allow! ItemCell.New()-> SetInstanceParent(gameObject) Instead !")
	end
end

function ItemCell:ResetRes()
	if self.TimeLimitTxt then
		self.TimeLimitTxt.text.text = Language.Common.LimitTime
	end
	if self.JueBan then
		self.JueBan.image:LoadSprite(ResPath.GetImages("lablel_item_jueban"))
	end

	if self.change_num_scale and self.node_list["NumberBg"] then
		self.node_list["NumberBg"].transform.localScale = Vector3(1, 1, 1)
	end

	if self.node_list and self.node_list["HighLight"] then
		local asset, bundle = ResPath.GetImages("frame_select_item")
		self:ChangeHighLight(asset, bundle, 86)
	end
end

function ItemCell:SetVisibleBindLock(is_show)
	if self.node_list["BindLock"] then
		self.node_list["BindLock"]:SetActive(is_show)
	end
end

function ItemCell:Reset()
	self:SetIconGrayScale(false)
	self:SetQualityGrayScale(false)
	self.node_list["Background"]:SetActive(true)
	self.node_list["NumberBg"]:SetActive(false)
	self.node_list["Icon"]:SetActive(false)
	self.node_list["BindLock"]:SetActive(false)
	self.node_list["CellLock"]:SetActive(false)
	self.node_list["HighLight"]:SetActive(false)
	self.node_list["Quality"]:SetActive(false)

	if self.RepairImage then
		self.RepairImage:SetActive(false)
	end

	if self.show_stars then
		for k, v in pairs(self.show_stars) do
			v:SetActive(false)
		end
	end

	self:ShowToLeft(false)
	self:SetRoleProf(false)
	self:SetTimeLimit(false)
	self:SetGodQuality(false)
	self:ShowStarLevel(false)
	self:ShowHasGet(false)
	self:ShowGetEffect(false)
	self:ShowSoulEffect(false)
	self:SetShowUpArrow(false)
	self:SetIconGrayVisible(false)
	self:SetRedPoint(false)
	self:SetPropName(false)
	self:ShowStrengthLable(false)
	self:ShowNormalEffect(false)
	self:ShowActivityEffect(false)

	self.handler = nil
	local toggle = self.root_node.toggle
	toggle.onValueChanged:RemoveAllListeners()
	toggle.group = nil
	toggle.interactable = false
	toggle.isOn = false

	self.root_node.rect.anchorMax = Vector2(0.5, 0.5)
	self.root_node.rect.anchorMin = Vector2(0.5, 0.5)
	self.root_node.rect.sizeDelta = Vector2(84, 84)  -- 物品格子使用对象池后，不知道哪里有设置长宽，导致出问题。默认强设大小84 * 84
	self.root_node.rect.pivot = Vector2(0.5, 0.5)
	self.root_node.transform:SetLocalScale(1, 1, 1)  -- 物品格子使用对象池后，不知道哪里有设置scale
end

function ItemCell:SetNotShowRedPoint(is_show)
	self.not_show_red_point = is_show
end

function ItemCell:SetCellSize(size)
	local scale = size / 84
	self.root_node.transform:SetLocalScale(scale, scale, scale)
end

function ItemCell:SetIsTianSheng(is_tian_sheng)
	self.is_tian_sheng = is_tian_sheng
end

function ItemCell:AddValueChangedListener(call_back)
	self.root_node.toggle:AddValueChangedListener(call_back)
end

function ItemCell:SetItemActive(is_active)
	self.root_node.gameObject:SetActive(is_active)
end

function ItemCell:ListenClick(handler)
	-- self:ClearEvent("Click")
	self.handler = handler
	self.node_list["ItemCell"].toggle:AddClickListener(handler or BindTool.Bind(self.OnClickItemCell, self))
	-- self:ListenEvent("Click", handler or BindTool.Bind(self.OnClickItemCell, self))
end

function ItemCell:OnClickItemCell(is_click)
	local data = self.data
	if data == nil then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end
	-- if self.root_node.toggle then
	-- 	self.root_node.toggle.isOn = true
	-- end
	if not self.is_showtip then return end
	local from_view = data.from_view or self.from_view
	local param_t = data.param_t
	local close_call_back = data.close_call_back or function() self:SetHighLight(false) end
	TipsCtrl.Instance:OpenItem(data, from_view, param_t, close_call_back, self.show_the_random, self.gift_id, self.is_check_item, self.is_tian_sheng)
end

function ItemCell:SetFromView(from_veiw)
	self.from_view = from_veiw
end

function ItemCell:SetHideEffect(is_hide)
	self.hide_effect = is_hide
end

function ItemCell:ClearItemEvent(handler)
	--self:ClearEvent("Click")
end

function ItemCell:SetIsCheckItem(is_check_item)
	self.is_check_item = is_check_item
end

function ItemCell:SetGiftItemId(gift_id)
	self.gift_id = gift_id
end

-- 设置物品数量显示最小值
function ItemCell:SetShowNumTxtLessNum(value)
	self.hide_numtxt_less_num = value
end

function ItemCell:IgnoreArrow(boo)
	self.ignore_arrow = boo
end

function ItemCell:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end

function ItemCell:ShowStrengthLable(enable, pos, size, font_size)
	if self.Strength then
		self.Strength:SetActive(enable)
	else
		if enable then
			self.Strength = self:LoadChildObj("Strength", nil, pos)
			if size ~= nil then
				self.Strength.rect.sizeDelta = size
			end
			local text_list = self.Strength:GetComponentsInChildren(typeof(UnityEngine.UI.Text))
			for i = 0, text_list.Length - 1 do
				local text = text_list[i]
				if font_size ~= nil then
					text.fontSize = font_size
				end
			end
		end
	end
end

function ItemCell:SetStrength(value)
	if self.Strength then
		local text_list = self.Strength:GetComponentsInChildren(typeof(UnityEngine.UI.Text))
		for i = 0, text_list.Length - 1 do
			local text = text_list[i]
			text.text = value
		end
	end
end

function ItemCell:SetSoulResolveStrength(enable, value)
	if nil == self.SoulResolveStrength then
		self.SoulResolveStrength = self:LoadChildObj("LingHunLevel")
	end
	self.SoulResolveStrength:SetActive(enable)
	if enable then
		local text_list = self.SoulResolveStrength:GetComponentsInChildren(typeof(UnityEngine.UI.Text))
		for i = 0, text_list.Length - 1 do
			local text = text_list[i]
			text.text = value
		end
	end
end

function ItemCell:ShowHighLight(enable)
	if self.node_list and self.node_list["HighLight"] then
		self.root_node.toggle.isOn = enable
		self.node_list["HighLight"]:SetActive(enable)
	end
end

function ItemCell:ChangeHighLight(asset, bundle , size, v3_size)
	if nil == asset or nil == bundle then 
		return
	end
	if self.node_list and self.node_list["HighLight"] then
		local end_load =  function ()
			if size then 
				self.node_list["HighLight"].rect.sizeDelta = Vector3(size,size,0)
			elseif v3_size then
				self.node_list["HighLight"].rect.sizeDelta = v3_size
			end
		end
		if self.node_list["HighLight"].image then
			self.node_list["HighLight"].image:LoadSprite(asset, bundle, end_load)
		end
	end
end

function ItemCell:IsHighLight()
	return self.node_list["HighLight"].gameObject.activeInHierarchy
end

function ItemCell:ShowToLeft(enable, asset, bundle)
	if self.TopLeft then
		self.TopLeft:SetActive(enable)
	else
		if enable then
			self.TopLeft = self:LoadChildObj("TopLeft")
			local list = U3DNodeList(self.TopLeft:GetComponent(typeof(UINameTable)), self)
			self.TxtTop = list.Text
			if asset and bundle then
				self.TopLeft.image:LoadSprite(asset, bundle)
			end
		end
	end
end

function ItemCell:SetTopLeftDes(des)
	if self.TxtTop then
		self.TxtTop.text.text = des
	end
end

function ItemCell:ShowRepairImage(enable)
	if self.RepairImage then
		self.RepairImage:SetActive(enable)
	else
		if enable then
			self.RepairImage = self:LoadChildObj("RepairImage")
		end
	end
end

function ItemCell:ShowHasGet(enable)
	if self.HasGet then
		self.HasGet:SetActive(enable)
	else
		if enable then
			self.HasGet = self:LoadChildObj("HasGet")
		end
	end
	self:ResetChildObjOrder()
end

function ItemCell:IsHaseGet()
	return self.HasGet and self.HasGet.gameObject.activeInHierarchy or false
end

function ItemCell:ShowNormalEffect(enable)
	self.item_effect["NormalEffect"] = self.item_effect["NormalEffect"] or {}
	self.item_effect["NormalEffect"].enable = enable

	if self.item_effect["NormalEffect"].obj then
		self.item_effect["NormalEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetItemEffect()
			self:CreateEffectChildObj({name = "NormalEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

function ItemCell:ShowActivityEffect(enable)
	self.item_effect["ActivityEffect"] = self.item_effect["ActivityEffect"] or {}
	self.item_effect["ActivityEffect"].enable = enable

	if self.item_effect["ActivityEffect"].obj then
		self.item_effect["ActivityEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetItemActivityEffect()
			self:CreateEffectChildObj({name = "ActivityEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

function ItemCell:ShowGetEffect(enable)
	self.item_effect["GetEffect"] = self.item_effect["GetEffect"] or {}
	self.item_effect["GetEffect"].enable = enable

	if self.item_effect["GetEffect"].obj then
		self.item_effect["GetEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetItemEffect()
			self:CreateEffectChildObj({name = "GetEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

function ItemCell:ShowItemRewardEffect(enable)
	self.item_effect["ItemRewardEffect"] = self.item_effect["ItemRewardEffect"] or {}
	self.item_effect["ItemRewardEffect"].enable = enable

	if self.item_effect["ItemRewardEffect"].obj then
		self.item_effect["ItemRewardEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetItemRewardEffect()
			self:CreateEffectChildObj({name = "ItemRewardEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

function ItemCell:ShowGetEffectTwo(enable)
	self.item_effect["GetEffectTwo"] = self.item_effect["GetEffectTwo"] or {}
	self.item_effect["GetEffectTwo"].enable = enable

	if self.item_effect["GetEffectTwo"].obj then
		self.item_effect["GetEffectTwo"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_biankuang")
			self:CreateEffectChildObj({name = "GetEffectTwo", pos = {2.1, -3}, scale = 0.8,
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 真·飞仙橙装特效
function ItemCell:ShowOrangeEffect(enable)
	self.item_effect["OrangeEquipEffect"] = self.item_effect["OrangeEquipEffect"] or {}
	self.item_effect["OrangeEquipEffect"].enable = enable

	if self.item_effect["OrangeEquipEffect"].obj then
		self.item_effect["OrangeEquipEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("UI_feixianOrange02")
			self:CreateEffectChildObj({name = "OrangeEquipEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 飞仙红装
function ItemCell:ShowRedEffect(enable)
	self.item_effect["RedEquipEffect"] = self.item_effect["RedEquipEffect"] or {}
	self.item_effect["RedEquipEffect"].enable = enable

	if self.item_effect["RedEquipEffect"].obj then
		self.item_effect["RedEquipEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("UI_feixianred02")
			self:CreateEffectChildObj({name = "RedEquipEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 普通装备橙装
function ItemCell:ShowEquipOrangeEffect(enable)
	self.item_effect["EquipOrangeEffect"] = self.item_effect["EquipOrangeEffect"] or {}
	self.item_effect["EquipOrangeEffect"].enable = enable

	if self.item_effect["EquipOrangeEffect"].obj then
		self.item_effect["EquipOrangeEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_btcz_dc")
			self:CreateEffectChildObj({name = "EquipOrangeEffect", pos = {0, 0}, size = {84, 84},
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 普通装备红装
function ItemCell:ShowEquipRedEffect(enable)
	self.item_effect["EquipRedEffect"] = self.item_effect["EquipRedEffect"] or {}
	self.item_effect["EquipRedEffect"].enable = enable

	if self.item_effect["EquipRedEffect"].obj then
		self.item_effect["EquipRedEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_bthz_dc")
			self:CreateEffectChildObj({name = "EquipRedEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 普通装备粉装
function ItemCell:ShowEquipFenEffect(enable)
	self.item_effect["EquipFenEffect"] = self.item_effect["EquipFenEffect"] or {}
	self.item_effect["EquipFenEffect"].enable = enable

	if self.item_effect["EquipFenEffect"].obj then
		self.item_effect["EquipFenEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_zhuangbei_fen")
			self:CreateEffectChildObj({name = "EquipFenEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 转职装备橙装
function ItemCell:ShowZhuanzhiEquipOrangeEffect(enable)
	self.item_effect["ZhuanzhiEquipOrangeEffect"] = self.item_effect["ZhuanzhiEquipOrangeEffect"] or {}
	self.item_effect["ZhuanzhiEquipOrangeEffect"].enable = enable

	if self.item_effect["ZhuanzhiEquipOrangeEffect"].obj then
		self.item_effect["ZhuanzhiEquipOrangeEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_sjcz_dc")
			self:CreateEffectChildObj({name = "ZhuanzhiEquipOrangeEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 转职装备红装装
function ItemCell:ShowZhuanzhiEquipRedEffect(enable)
	self.item_effect["ZhuanzhiEquipRedEffect"] = self.item_effect["ZhuanzhiEquipRedEffect"] or {}
	self.item_effect["ZhuanzhiEquipRedEffect"].enable = enable

	if self.item_effect["ZhuanzhiEquipRedEffect"].obj then
		self.item_effect["ZhuanzhiEquipRedEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_sjhz_dc")
			self:CreateEffectChildObj({name = "ZhuanzhiEquipRedEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 转职装备粉装
function ItemCell:ShowZhuanzhiEquipFenEffect(enable)
	self.item_effect["ZhuanzhiEquipFenEffect"] = self.item_effect["ZhuanzhiEquipFenEffect"] or {}
	self.item_effect["ZhuanzhiEquipFenEffect"].enable = enable

	if self.item_effect["ZhuanzhiEquipFenEffect"].obj then
		self.item_effect["ZhuanzhiEquipFenEffect"].obj:SetActive(enable)
	else
		if enable then
			local bundle_name, asset_name = ResPath.GetUiEffect("uieffect_sjfz_dc")
			self:CreateEffectChildObj({name = "ZhuanzhiEquipFenEffect", pos = {0, 0}, size = {84, 84}, 
				asset_bundle = {bundle = bundle_name, asset = asset_name}})
		end
	end
end

-- 设置仙宠魂力特效
function ItemCell:ShowSoulEffect(enable, show_effect_item_id)
	if self.item_effect["SoulEffect"] and self.item_effect["SoulEffect"].obj then
		self.item_effect["SoulEffect"].obj:SetActive(false)
		if not enable then
			return
		end
	end

	if (nil == self.data or nil == self.data.item_id) and not show_effect_item_id then return end
	if nil == SpiritData.Instance then return end

	local asset, bundle
	if show_effect_item_id then
		asset, bundle = SpiritData.Instance:GetLingEffect(show_effect_item_id)
	else
		asset, bundle = SpiritData.Instance:GetLingEffect(self.data.item_id)
	end

	if not asset or not bundle then return end

	local item_key = "SoulEffect" .. asset

	if self.item_effect["SoulEffect"] and self.item_effect["SoulEffect"].key and self.item_effect["SoulEffect"].obj then
		ResMgr:Destroy(self.item_effect["SoulEffect"].obj)
		self.item_effect["SoulEffect"] = nil
	end

	self.node_list["Icon"]:SetActive(false)

	self.item_effect["SoulEffect"] = self.item_effect["SoulEffect"] or {}
	self.item_effect["SoulEffect"].enable = enable

	if self.item_effect["SoulEffect"].obj then
		self.item_effect["SoulEffect"].obj:SetActive(enable)
	else
		if enable then
			self:CreateEffectChildObj({name = "SoulEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle, asset = asset}})
		end
	end
end

function ItemCell:SetShowExtremeEffect(is_show_time)
	if is_show_time then
		local show_data = self.item_effect_tab[#self.item_effect_tab]
		if self.show_data then
			if show_data.enable == self.show_data.enable and show_data.order == self.show_data.order and 
				show_data.color == self.show_data.color then
				self.item_effect_tab = {}
				return
			end
		end
		self.show_data = show_data
		self:ShowExtremeEffect(false)
		self:ShowExtremeEffect(show_data.enable, show_data.order, show_data.color)
		self.item_effect_tab = {}
	end
	self.item_effect_tab = {}
end

-- 至尊装备(下层特效，上层特效)
function ItemCell:ShowExtremeEffect(enable, order, color, is_set_cache)
	if is_set_cache then
		local length = #self.item_effect_tab + 1
		self.item_effect_tab[length] = {}
		self.item_effect_tab[length].enable = enable
		self.item_effect_tab[length].order = order
		self.item_effect_tab[length].color = color
		return
	end

	if not order and color then
		-- 以前逻辑上修改
		order = (color == 5) and 8 or ((color == 6) and 10 or 0)
	end
	local extreme_order_effect = {
		[4] = {"zhuangbei_red" , "zhuangbei_redbiaomian"},
		[6] = {"zhuangbei_red" , "zhuangbei_redbiaomian"},
		[8] = {"zhuangbei_red" , "zhuangbei_redbiaomian"},
		[10] = {"zhuangbei_fen" , "zhuangbei_fenbiaomian"}
	}

	if order and nil == extreme_order_effect[order] then return false end

	self.item_effect["UpExtremeEffectRed"] = self.item_effect["UpExtremeEffectRed"] or {}
	self.item_effect["UpExtremeEffectRed"].enable = enable
	if self.item_effect["UpExtremeEffectRed"].obj then
		self.item_effect["UpExtremeEffectRed"].obj:SetActive(false)
	end

	self.item_effect["DownExtremeEffectRed"] = self.item_effect["DownExtremeEffectRed"] or {}
	self.item_effect["DownExtremeEffectRed"].enable = enable
	if self.item_effect["DownExtremeEffectRed"].obj then
		self.item_effect["DownExtremeEffectRed"].obj:SetActive(false)
	end

	self.item_effect["UpExtremeEffectFen"] = self.item_effect["UpExtremeEffectFen"] or {}
	self.item_effect["UpExtremeEffectFen"].enable = enable
	if self.item_effect["UpExtremeEffectFen"].obj then
		self.item_effect["UpExtremeEffectFen"].obj:SetActive(false)
	end

	self.item_effect["DownExtremeEffectFen"] = self.item_effect["DownExtremeEffectFen"] or {}
	self.item_effect["DownExtremeEffectFen"].enable = enable
	if self.item_effect["DownExtremeEffectFen"].obj then
		self.item_effect["DownExtremeEffectFen"].obj:SetActive(false)
	end

	if not order then return end
	local is_fen = (order == 10) and true or false

	local function create_effect(name, is_up)
		if enable then
			if is_up then
				local bundle_name, asset_name = ResPath.GetUiXEffect(extreme_order_effect[order][2])
				self:CreateEffectChildObj({name = name, pos = {0, 0}, size = {84, 84}, 
					asset_bundle = {bundle = bundle_name, asset = asset_name}})
			else
				local bundle_name, asset_name = ResPath.GetUiXEffect(extreme_order_effect[order][1])
				self:CreateEffectChildObj({name = name, pos = {0, 0}, size = {84, 84}, 
					asset_bundle = {bundle = bundle_name, asset = asset_name}, call_back = function ()
						self.item_effect[name].obj.transform:SetAsFirstSibling()
						-- self.item_effect[name].obj:SetActive(enable and not self.hide_effect)
					end})
			end
		end
	end

	if is_fen then
		if self.item_effect["UpExtremeEffectFen"].obj then
			self.item_effect["UpExtremeEffectFen"].obj:SetActive(enable and not self.hide_effect)
		else
			create_effect("UpExtremeEffectFen", true)
		end

		if self.item_effect["DownExtremeEffectFen"].obj then
			self.item_effect["DownExtremeEffectFen"].obj:SetActive(enable and not self.hide_effect)
		else
			create_effect("DownExtremeEffectFen", false)
		end
	else
		if self.item_effect["UpExtremeEffectRed"].obj then
			self.item_effect["UpExtremeEffectRed"].obj:SetActive(enable and not self.hide_effect)
		else
			create_effect("UpExtremeEffectRed", true)
		end
		
		if self.item_effect["DownExtremeEffectRed"].obj then
			self.item_effect["DownExtremeEffectRed"].obj:SetActive(enable and not self.hide_effect)
		else
			create_effect("DownExtremeEffectRed", false)
		end
	end

	return true
end

-- 设置ItemIcon特效
function ItemCell:SetItemEffect(enable)
	if self.item_effect["ItemIconEffect"] and self.item_effect["ItemIconEffect"].obj then
		self.item_effect["ItemIconEffect"].obj:SetActive(false)
	end

	local item_effect_tab = {
		[27011] = "UI_Effect_qibing_wuqi1",
		[27012] = "UI_Effect_qibing_kuijia_1",
	}
	
	if nil == self.data or nil == self.data.item_id or nil == item_effect_tab[self.data.item_id] then return end

	local bundle, asset = ResPath.GetItemIconEffect(item_effect_tab[self.data.item_id])
	local item_key = "ItemIconEffect" .. asset

	if self.item_effect["ItemIconEffect"] and self.item_effect["ItemIconEffect"].key and self.item_effect["ItemIconEffect"].obj then
		ResMgr:Destroy(self.item_effect["ItemIconEffect"].obj)
		self.item_effect["ItemIconEffect"] = nil
	end

	self.node_list["Icon"]:SetActive(false)

	self.item_effect["ItemIconEffect"] = self.item_effect["ItemIconEffect"] or {}
	self.item_effect["ItemIconEffect"].enable = enable

	if self.item_effect["ItemIconEffect"].obj then
		self.item_effect["ItemIconEffect"].obj:SetActive(enable)
	else
		if enable then
			self:CreateEffectChildObj({name = "ItemIconEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle, asset = asset}})
		end
	end
end

-- 转职装备觉醒S特效
function ItemCell:SetZhuanzhiEquipJueXingEffect(enable, s_num)
	if self.item_effect["JueXingSEffect"] and self.item_effect["JueXingSEffect"].obj then
		self.item_effect["JueXingSEffect"].obj:SetActive(false)
	end

	local item_effect_tab = {
		[1] = "UI_Sjuexing",
		[2] = "UI_SSjuexing",
		[3] = "UI_SSSjuexing",
	}
	
	if nil == self.data or nil == self.data.item_id or nil == item_effect_tab[s_num] then return end

	local bundle, asset = ResPath.GetUiEffect(item_effect_tab[s_num])
	local item_key = "JueXingSEffect" .. asset

	if self.item_effect["JueXingSEffect"] and self.item_effect["JueXingSEffect"].key and self.item_effect["JueXingSEffect"].obj then
		ResMgr:Destroy(self.item_effect["JueXingSEffect"].obj)
		self.item_effect["JueXingSEffect"] = nil
	end

	self.item_effect["JueXingSEffect"] = self.item_effect["JueXingSEffect"] or {}
	self.item_effect["JueXingSEffect"].enable = enable

	if self.item_effect["JueXingSEffect"].obj then
		self.item_effect["JueXingSEffect"].obj:SetActive(enable)
	else
		if enable then
			self:CreateEffectChildObj({name = "JueXingSEffect", pos = {0, 0}, 
				asset_bundle = {bundle = bundle, asset = asset}})
		end
	end
end

function ItemCell:ShowSpecialEffect(enable)
	self.item_effect["SpecialEffect"] = self.item_effect["SpecialEffect"] or {}
	self.item_effect["SpecialEffect"].enable = enable
	if self.item_effect["SpecialEffect"].obj then
		self.item_effect["SpecialEffect"].obj:SetActive(enable)
	end
end

function ItemCell:SetSpecialEffect(bunble, asset)
	if not self.item_effect["SpecialEffect"] or asset ~= self.special_effect_asset then
		if self.item_effect["SpecialEffect"] and self.item_effect["SpecialEffect"].obj then
			ResMgr:Destroy(self.item_effect["SpecialEffect"].obj)
			self.item_effect["SpecialEffect"] = nil
		end

		self:CreateEffectChildObj({name = "SpecialEffect", pos = {0, 0}, size = {84, 84}, 
			asset_bundle = {bundle = bunble, asset = asset}})
		self.special_effect_asset = asset
	end
end

--点开天神装备时,设置是否显示随机问号属性
function ItemCell:SetShowRandom(is_show)
	self.show_the_random = is_show
end

function ItemCell:SetClearListenValue(value)
	self.is_clear_listen = value
end

function ItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function ItemCell:ShowStarLevel(enable)
	-- if self.node_list["StarLevel"] then
	-- 	self.node_list["StarLevel"]:SetActive(enable)
	-- end
	if self.StarLevel then
		self.StarLevel:SetActive(enable)
	else
		if enable then
			self.StarLevel = self:LoadChildObj("StarLevel")
			local list = U3DNodeList(self.StarLevel:GetComponent(typeof(UINameTable)), self)
			self.TxtStarLevel = list.Text
		end
	end
end

function ItemCell:SetStarLevel(value)
	if self.TxtStarLevel then
		self.TxtStarLevel.text.text = value
	end
end

function ItemCell:SetHighLight(enable)
	if self.root_node and self.root_node.toggle and self:GetActive() then
		if self.node_list["HighLight"] then
			self.root_node.toggle.isOn = enable
			self.node_list["HighLight"]:SetActive(enable)
		end
	end
end

function ItemCell:SetIconGrayScale(enable)
	UI:SetGraphicGrey(self.node_list["Icon"], enable)

	self.is_gray_icon = enable

	if self.data and nil ~= self.data.item_id and self.data.item_id >= SOUL_ID_RANGE.START_ID and self.data.item_id <= SOUL_ID_RANGE.END_ID then
		self.is_gray_icon = false
	end
	
	if self.data and nil ~= self.data.item_id and (self.data.item_id == 27011 or self.data.item_id == 27012) then
		self.is_gray_icon = false
	end

	for k, v in pairs(self.item_effect) do
		-- if k == "SoulEffect" or k == "ItemIconEffect" then
		-- 	enable = false
		-- end

		if v.obj and enable then
			v.obj:SetActive(not enable)
		end
	end
end

function ItemCell:GetIconGrayScaleIsGray()
	if self.node_list["Icon"] then
		local Graphic = self.node_list["Icon"].gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Graphic))
		return Graphic == nil
	end
	return false
end

function ItemCell:SetQualityGrayScale(enable)
	if self.node_list["Quality"] then
		UI:SetGraphicGrey(self.node_list["Quality"], enable)
	end
end

function ItemCell:GetToggleIsOn()
	if self.root_node.toggle and self:GetActive() then
		return self.root_node.toggle.isOn
	end
	return false
end


function ItemCell:SetBackground(enable, res_path)
	self.node_list["Background"]:SetActive(enable)
	if res_path then
		local bundle, asset = res_path
		self.node_list["Background"].image:LoadSprite(bundle, asset)
	end
end

function ItemCell:SetItemNumVisible(enable, num)
	self.node_list["NumberBg"]:SetActive(enable)
	if num then
		self.node_list["Number"].text.text = num
	end
end

function ItemCell:ShowQuality(enable)
	if self.node_list["Quality"] then
		self.quality_enbale = enable
		self.node_list["Quality"]:SetActive(enable)
	end
end

function ItemCell:ShowNumBerBg(enble)
	if self.node_list["NumberBg"] and self.node_list["NumberBg"].image then
		self.node_list["NumberBg"].image.enabled = enble
	end
end

function ItemCell:OnlyShowQuality(enable)
	if self.node_list["Quality"] then
		self.node_list["Quality"]:SetActive(enable)
	end
end

function ItemCell:IsDestroyEffect(value)
	self.is_destroy_effect = value
end

function ItemCell:SetRedPoint(enable, pos)
	if self.RedPoint then
		self.RedPoint:SetActive(enable)
	else
		if enable then
			self.RedPoint = self:LoadChildObj("RedPoint", nil, pos)
		end
	end
end

function ItemCell:SetIndex(index)
	self.index = index
end

function ItemCell:GetIndex()
	return self.index
end

function ItemCell:FlushArrow(is_from_bag)
	-- if self.node_list["UpArrow"] then
	-- 	self.node_list["UpArrow"]:SetActive(false)
	-- end
	self:SetShowUpArrow(false)

	if not self.data or not next(self.data) then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg or (big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT) then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

	self:SetItemGridArrow(big_type, equip_index, item_cfg, self.data, gamevo, is_from_bag)
end

function ItemCell:SetData(data, is_from_bag)
	self.data = data
	if self.show_stars then
		for k, v in pairs(self.show_stars) do
			v:SetActive(false)
		end
	end

	if self.Grade then
		self.Grade:SetActive(false)
	end

	if self.InlaySlot then
		self.InlaySlot:SetActive(false)
	end

	if self.LuoShu then
		self.LuoShu:SetActive(false)
	end

	if self.SoulResolveStrength then
		self.SoulResolveStrength:SetActive(false)
	end

	if self.ShenYinName then
		self.ShenYinName:SetActive(false)
	end

	if self.TainShenEquipLabel then
		self.TainShenEquipLabel:SetActive(false)
	end

	if self.LevelNoEnough then
		self.LevelNoEnough:SetActive(false)
	end

	if nil ~= self.RomeNumImage then
		self.RomeNumImage:SetActive(false)
	end

	if self.ShengYinLock then
		self.ShengYinLock:SetActive(false)
	end

	if self.ShengYinGrade then
		self.ShengYinGrade:SetActive(false)
	end

	if self.ShengYinEffect then
		self.ShengYinEffect:SetActive(false)
	end

	if self.SuitText then
		self.SuitText:SetActive(false)
	end

	self:SetShowExtremeEffect()
	self:ShowToLeft(false)
	self:ShowRepairImage(false)
	self:ShowHasGet(false)
	self:ShowGetEffect(false)
	self:ShowSoulEffect(false)
	self:SetItemEffect(false)
	self:SetZhuanzhiEquipJueXingEffect(false)
	self:ShowOrangeEffect(false)
	self:ShowRedEffect(false)
	self:ShowEquipOrangeEffect(false)
	self:ShowEquipRedEffect(false)
	self:ShowEquipFenEffect(false)
	self:ShowZhuanzhiEquipOrangeEffect(false)
	self:ShowZhuanzhiEquipRedEffect(false)
	self:ShowZhuanzhiEquipFenEffect(false)
	self:ShowExtremeEffect(false, nil, nil, true)
	self:ShowSpecialEffect(false)
	self:SetTimeLimit(false)
	self:SetGodQuality(false)
	self:ShowStarLevel(false)
	self:SetItemGridTopLeftPropNum()
	self:SetShowUpArrow(false)
	self:SetIconGrayVisible(false)
	self:SetRedPoint(false)
	self:ShowJueBan(false)
	self:SetItemNumVisible(false)
	self:ShowNormalEffect(false)
	self:ShowActivityEffect(false)
	self:ShowEquipOrangeEffect(false)
	self:SetShowZhuanShu(false)
	self:SetShowDecorationTAG(false)
	self:SetShowLimitUse(false)
	self:SetImgDouqi(false)
	self:SetBestEquipTip(false)
	self:SetNewItem(false)
	self:SetSuitItemName(false)

	if not data or not next(data) then
		self.node_list["Icon"]:SetActive(false)
		self.node_list["NumberBg"]:SetActive(false)
		self.node_list["BindLock"]:SetActive(false)
		self.node_list["Number"].text.text = ""
		if self.node_list["Quality"] then
			self.node_list["Quality"]:SetActive(false)
		end

		self:SetRoleProf(false)
		self:SetPropName(false)
		self:ShowStrengthLable(false)
		self:SetShowExtremeEffect(true)
		return
	end

	-- 设置格子锁
	if self.node_list["CellLock"] then
		self.node_list["CellLock"]:SetActive(data.locked or false)
	end

	-- 有道具就不显示类型名字了
	if data.prop_name ~= nil then
		self:SetPropName(true, data.prop_name)
	else
		self:SetPropName(false)
	end

	-- 获取配置
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if data.is_jueban and data.is_jueban == 1 then
		self:ShowJueBan(true)
	end

	if nil == item_cfg then
		self.node_list["Icon"]:SetActive(false)
		self.node_list["NumberBg"]:SetActive(false)
		self.node_list["BindLock"]:SetActive(false)

		if self.node_list["Quality"] then
			self.node_list["Quality"]:SetActive(false)
		end

		self:SetRoleProf(false)
		self:SetPropName(false)
		self:ShowStrengthLable(false)

		if nil ~= self.RomeNumImage then
			self.RomeNumImage:SetActive(false)
		end
		self:SetShowExtremeEffect(true)
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

	-- 设置格子默认特效
	self:SetNormalItemEffect(equip_index, data, item_cfg, is_from_bag)

	self:SetInteractable(true)

	-- 设置格子装备上升、下降箭头
	self:SetItemGridArrow(big_type, equip_index, item_cfg, data, gamevo, is_from_bag)

	-- 设置格子道具左上角道具文本
	self:SetItemGridTopLeftPropNum(item_cfg)

	-- 设置格子道具右上角装备阶数
	self:SetEquipGrade(item_cfg, equip_index, big_type)

	-- 设置神格等级和阶数
	--self:SetShenGeInfo(data, is_from_bag)

	if (data.item_id == FuBenDataExpItemId.ItemId or data.item_id == 0) and self.is_clear_listen then
		-- self:ClearEvent("Click")
		self:SetInteractable(false)
	elseif nil == self.handler then
		self:ListenClick()
	end

	if self.node_list["Quality"] then
		self.node_list["Quality"]:SetActive(self.quality_enbale)
	end
	-- 设置图标
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	self.node_list["Icon"]:SetActive(true)
	local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
	self.node_list["Quality"].image:LoadSprite(bundle1, asset1)

	local temp_data = data
	-- 传奇属性显示
	if self.gift_id and ForgeData.Instance:GetEquipIsNotRandomGift(temp_data.item_id, self.gift_id) then
		temp_data = TableCopy(data)
		temp_data.param = {xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(temp_data.item_id, self.gift_id)}
	end

	--策划需求礼包表加上星数展示
	if big_type == GameEnum.ITEM_BIGTYPE_GIF then
		local star_length = item_cfg.show_id or 0
		self:SetShowStar(star_length)
	end
	-- 设置数量or强度
	if data.num ~= nil and big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		if data.num > self.hide_numtxt_less_num then
			self.node_list["NumberBg"]:SetActive(true)
			-- if data.num >= 100000 and data.num < 100000000 then
			-- 	local num_wan = math.floor(data.num / 10000)
			-- 	self.node_list["Number"].text.text = num_wan .. Language.Common.Wan
			-- elseif data.num >= 100000000 then
			-- 	local num_yi = data.num / 100000000
			-- 	num_yi = string.format("%.1f", num_yi)
			-- 	self.node_list["Number"].text.text = num_yi .. Language.Common.Yi
			-- else
			-- 	self.node_list["Number"].text.text = data.num
			-- end
			local num = CommonDataManager.ConverMoney2(data.num)
			self.node_list["Number"].text.text = num
		else
			self.node_list["NumberBg"]:SetActive(false)
		end
		self:ShowStrengthLable(false)
	elseif temp_data.param ~= nil then
		self.node_list["NumberBg"]:SetActive(false)
		local strength_level = temp_data.param.strengthen_level
		if self.data.mojie_level then
			strength_level = self.data.mojie_level
		end
		if self.from_view then
			if self.from_view ~= TipsFormDef.FROM_BAG and self.from_view ~= TipsFormDef.FROM_GIFT_VIEW and 
				self.from_view ~= TipsFormDef.FROM_FORGE_EXCHANGE and self.from_view ~= TipsFormDef.FROM_MARKET_JISHOU and
				self.from_view ~= TipsFormDef.QUICK_EQUIP and
				EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
				strength_level = ForgeData.Instance:GetUpStarLevelByIndex(temp_data.index)
			end
		elseif EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			strength_level = ForgeData.Instance:GetUpStarLevelByIndex(temp_data.index)
		end
		if not strength_level or strength_level == 0 then
			self:ShowStrengthLable(false)
		else
			self:ShowStrengthLable(not is_from_bag or false)
		end

		if EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) ~= -1 and strength_level then
			self:SetStrength("+" .. strength_level)
		else
			self:SetStrength(strength_level)
		end

		local quality_cfg = ForgeData.Instance:GetEternityEquipCfg(equip_index, temp_data.param.eternity_level)
		if quality_cfg and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) and not EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and
		 item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING and not DouQiData.Instance:IsDouqiEqupi(item_cfg.id) then
			local bundle, asset = ResPath.GetQualityIcon(quality_cfg.quality)
			self.node_list["Quality"].image:LoadSprite(bundle, asset)
			self:SetShowStar(quality_cfg.star)
			-- if quality_cfg.quality == 4 then
			-- 	self:ShowEquipOrangeEffect(true)
			if quality_cfg.quality == 5 then
				self:ShowEquipRedEffect(true)
			elseif quality_cfg.quality == 6 then
				self:ShowEquipFenEffect(true)
			end
		-- elseif EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) ~= -1 then
		else
			if ForgeData.Instance:GetZhiZunEquipCfg(data.item_id) then
				self:ShowExtremeEffect(true, item_cfg.order, nil, true)
			else
				self:ShowExtremeEffect(true, nil, item_cfg.color, true)
			end

			if temp_data.param.xianpin_type_list and next(temp_data.param.xianpin_type_list) then
				local star_length = #temp_data.param.xianpin_type_list
				self:SetShowStar(star_length)
			end
		end

		if nil ~= temp_data.param.strengthen_level then 	--这里判断为了判断这是服务端下发的装备
			if self.from_view then
				if (self.from_view == TipsFormDef.FROME_BROWSE_ROLE or self.from_view == TipsFormDef.FROM_CHECK_MEG
					or self.from_view == TipsFormDef.FROM_PLAYER_INFO
					or self.from_view == TipsFormDef.BAIZHAN_SUIT
					or self.from_view == TipsFormDef.FROM_BAG_EQUIP
					or self.from_view == TipsFormDef.FROM_NORMAL)
					and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
					-- 转职装备觉醒S特效
					local s_num = 0
					for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
						local is_show_s = ForgeData.Instance:LeftJueXingLevelIsMax2(temp_data.index, i)

						if is_show_s then
							s_num = s_num + 1
						end
					end
					
					if s_num > 0 then
						self:SetZhuanzhiEquipJueXingEffect(true, s_num)
					end
				end
			else
				if not is_from_bag and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
					local s_num = 0
					for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
						local is_show_s = ForgeData.Instance:LeftJueXingLevelIsMax2(temp_data.index, i)

						if is_show_s then
							s_num = s_num + 1
						end
					end
					
					if s_num > 0 then
						self:SetZhuanzhiEquipJueXingEffect(true, s_num)
					end			
				end
			end
		end

		if temp_data.awakening_list and temp_data.awakening_list.vo then
			local s_num = ForgeData.Instance:GetShowSNumber(equip_index, item_cfg, temp_data.awakening_list.vo)
			if s_num > 0 then
				self:SetZhuanzhiEquipJueXingEffect(true, s_num)
			end
		end
	elseif EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) ~= -1 then
		-- is_from_extreme 只针对于至尊界面展示星星（其他界面展示星星也可以用）
		if temp_data.is_from_extreme then
			self:ShowExtremeEffect(true, nil, item_cfg.color, true)
			self:SetShowStar(temp_data.is_from_extreme)
		else
			if ForgeData.Instance:GetZhiZunEquipCfg(temp_data.item_id) then
				self:ShowExtremeEffect(true, item_cfg.order, nil, true)
			else
				self:ShowExtremeEffect(true, nil, item_cfg.color, true)
			end

			if temp_data.xianpin_type_list then -- 查看角色的data
				local star_length = #temp_data.xianpin_type_list
				self:SetShowStar(star_length)
			end
			if temp_data.awakening_list then
				local s_num = ForgeData.Instance:GetShowSNumber(equip_index, item_cfg, temp_data.awakening_list.vo)
				if s_num > 0 then
					self:SetZhuanzhiEquipJueXingEffect(true, s_num)
				end
			end
		end
		self:ShowStrengthLable(false)
		self.node_list["NumberBg"]:SetActive(false)
	end

	-- 绑定标记
	if big_type == GameEnum.ITEM_BIGTYPE_VIRTUAL then
		self.node_list["BindLock"]:SetActive(false)
		-- --虚拟物品显示特效
		if item_cfg.color and item_cfg.special_show and item_cfg.special_show == 1 and self.show_virtual_effect then
			if item_cfg.color == 4 then
				self:ShowEquipOrangeEffect(true)
			elseif item_cfg.color == 5 then
				self:ShowExtremeEffect(true, 6, nil, true)
			elseif item_cfg.color == 6 then
				self:ShowExtremeEffect(true, 10, nil, true)
			end
		end
	elseif data.is_bind then
		self.node_list["BindLock"]:SetActive(0 ~= data.is_bind)
	elseif item_cfg.isbind then
		self.node_list["BindLock"]:SetActive(0 ~= item_cfg.isbind)
	end

	if not self.ignore_arrow then
		if nil ~= data.is_up_arrow then
			self:SetShowUpArrow(self.data.is_up_arrow)
		end
	end
	if item_cfg.time_length and item_cfg.time_length > 0 or item_cfg.is_curday_valid == 1 then
		self:SetTimeLimit(true)
	end

	local is_hunyin = HunQiData.Instance:IsHunyinItem(data.item_id)
	-- 设置魂印镶嵌位置
	if is_hunyin then
		self:SetInlaySlot(data.item_id)
	end

	if item_cfg.gift_type and (item_cfg.gift_type == 3 or item_cfg.gift_type == 4) then
		self:SetGiftType(Language.Common.ChooseMyself)
	end

	local is_luoshu = LuoShuData.Instance:IsLuoShuItem(data.item_id)
	if is_luoshu then
		self:SetLuoShuProf(data.item_id)
	end

	local is_shen_yin = ShenYinData.Instance:GetIsShenYinItem(data.item_id)
	if is_shen_yin then
		self:SetShenYinSlot(data.item_id)
	end

	local is_tianshen_equip = item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE
	if is_tianshen_equip then
		self:SetTainShenEquipLabel(data.item_id)
	end

	if data.item_id >= SOUL_ID_RANGE.START_ID and data.item_id <= SOUL_ID_RANGE.END_ID then
		self:ShowSoulEffect(true)
	end

	if item_cfg.gift_type and (item_cfg.gift_type == 2 or item_cfg.gift_type == 3) then
		local show_effect = {
			[15900] = 15024,	[15901] = 15032,	[15902] = 15040,
			[15903] = 15048,	[15904] = 15056,	[15905] = 15064,
		}
		-- 自选礼包显示正常物品特效
		local show_effect_item_id = show_effect[item_cfg.icon_id]
		if show_effect_item_id then
			self:ShowSoulEffect(true, show_effect_item_id)
		end
	end

	if data.item_id == 27011 or data.item_id == 27012 then
		self:SetItemEffect(true)
	end

	if self.show_orange_effect and item_cfg.color == 4 then
		self:ShowEquipOrangeEffect(true)
	end

	if data.item_id == 26436 then
		self:SetSuitItemName(true, Language.Common.SexName[1])
	elseif data.item_id == 26441 then
		self:SetSuitItemName(true, Language.Common.SexName[0])
	end

	if DouQiData.Instance:IsDouqiEqupi(data.item_id) then
		local douqi_equip_cfg = DouQiData.Instance:GetDouqiEquipCfg(data.item_id)
		if douqi_equip_cfg then
			self:SetImgDouqi(true, item_cfg.color, douqi_equip_cfg.order)
		end
	end

	-- 设置格子置灰状态(置灰层在最下面)
	self:SetItemGridGrayState(data, equip_index, item_cfg, big_type, gamevo, is_from_bag)

	if self.from_view and (self.from_view == TipsFormDef.FROM_PLAYER_INFO or self.from_view == TipsFormDef.BAIZHAN_SUIT) and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and data.index then
		local role_prof, zhuan_num = PlayerData.Instance:GetRoleBaseProf(gamevo.prof)
		local best_equip_cfg = ForgeData.Instance:GetBestEquipCfg(equip_index, gamevo.level, zhuan_num)
		if best_equip_cfg and next(best_equip_cfg) and best_equip_cfg.equip_order > item_cfg.order then
			self:SetBestEquipTip(true)
		end
	end

	if is_from_bag and data.item_id and data.item_id > 0 then
		local is_new_item = PackageData.Instance:IsNewItem(self.data.index)
		if is_new_item then
			local _, big_type = ItemData.Instance:GetNewItemConfig(data.item_id)
			if nil == big_type  then
				self:SetShowExtremeEffect(true)
				return
			end
			if big_type == GameEnum.PACKAGE_BIGTYPE_EXCHANGE and data.is_bind and data.is_bind == 0 then
				self:SetNewItem(true)
			end
		end
	end

	self:SetShowExtremeEffect(true)
end

-- 展示橙色特效
function ItemCell:SetShowOrangeEffect(show_orange_effect)
	self.show_orange_effect = show_orange_effect
end

-- 虚拟物品展示橙色特效
function ItemCell:SetShowVitualOrangeEffect(show_orange_effect)
	self.show_virtual_effect = show_orange_effect
end

-- 武器名字（字）
function ItemCell:SetPropName(enable, text)
	local function call_back(obj)
		if enable and text then
			obj.text.text = text
		end
	end
	if self.PropName then
		self.PropName:SetActive(enable)
	else
		if enable then
			self.PropName = self:LoadChildObj("PropName")
		end
	end
end

-- 限时（字）
function ItemCell:SetTimeLimit(enable)
	if self.TimeLimit then
		self.TimeLimit:SetActive(enable)
	else
		if enable then
			self.TimeLimit = self:LoadChildObj("TimeLimit")
			local list = U3DNodeList(self.TimeLimit:GetComponent(typeof(UINameTable)), self)
			self.TimeLimitTxt = list.Text
		end
	end
end

function ItemCell:SetTimeLimitText(text)
	if self.TimeLimitTxt then
		self.TimeLimitTxt.text.text = text
	end
end

-- 绝版
function ItemCell:ShowJueBan(enable)
	if self.JueBan then
		self.JueBan:SetActive(enable)
	else
		if enable then
			self.JueBan = self:LoadChildObj("JueBan")
		end
	end
end

-- 不是最好装备Tip
function ItemCell:SetBestEquipTip(enable)
	if self.BestEquipTip then
		self.BestEquipTip:SetActive(enable)
	else
		if enable then
			self.BestEquipTip = self:LoadChildObj("BestEquipTip")
		end
	end
end

function ItemCell:SetNewItem(enable)
	if self.NewItem then
		self.NewItem:SetActive(enable)
	else
		if enable then
			self.NewItem = self:LoadChildObj("NewItem")
		end
	end
	if self.NewItem then
		self.NewItem.transform:SetAsLastSibling()
	end
end

--更改左上图片
function ItemCell:ShowLeftUpImage(bundle, asset)
	if not self.JueBan then
		self.JueBan = self:LoadChildObj("JueBan")
	end	
	self.JueBan.image:LoadSprite(bundle, asset)
end

function ItemCell:SetInlaySlot(index)
	if nil == self.InlaySlot then
		self.InlaySlot = self:LoadChildObj("InlaySlot")
	end
	self.InlaySlot:SetActive(true)
	local hunyin_info = HunQiData.Instance:GetHunQiInfo()[index][1]
	self.InlaySlot.text.text = hunyin_info.show_name
end

function ItemCell:SetGiftType(text)
	if nil == self.InlaySlot then
		self.InlaySlot = self:LoadChildObj("InlaySlot")
	end
	self.InlaySlot:SetActive(true)
	self.InlaySlot.text.text = text
end

function ItemCell:SetLuoShuProf(item_id)
	if nil == self.LuoShu then
		self.LuoShu = self:LoadChildObj("LuoShuProf")
	end
	self.LuoShu:SetActive(false)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg and next(cfg) then
		if cfg.limit_sex ~= 2 then
			self.LuoShu:SetActive(true)
			self.LuoShu.text.text = Language.Common.SexName[cfg.limit_sex] or ""
		end
	end
end

function ItemCell:SetLimitUse()
	if nil == self.data or nil == self.data.item_id then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if item_cfg then
		if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
			if prof == item_cfg.limit_prof then
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
				local zhuanzhi_info = ForgeData.Instance:GetZhuanzhiEquipInfo(equip_index, item_cfg.order)

				if gamevo.level < item_cfg.limit_level or zhuan < zhuanzhi_info.role_need_min_prof_level then
					self:SetShowLimitUse(true)
					self:SetShowUpArrow(false)
				end
			end
		end
	end
end

function ItemCell:SetShowLimitUse(enable)
	if self.LimitUse then
		self.LimitUse:SetActive(enable)
	else
		if enable then
			self.LimitUse = self:LoadChildObj("LimitUse")
			self.LimitUse.gameObject.transform.localScale = Vector3(1, 1, 1)
		end
	end
end

function ItemCell:SetImgDouqi(enable, img_color, text_order)
	if self.ImgDouqi then
		self.ImgDouqi:SetActive(enable)
	else
		if enable then
			self.ImgDouqi = self:LoadChildObj("ImgDouqi")

			local list = U3DNodeList(self.ImgDouqi:GetComponent(typeof(UINameTable)), self)
			self.TxtDouqi = list.TxtDouqi
		end
	end

	if enable and self.ImgDouqi and self.TxtDouqi and img_color and text_order then
		local asset_name = ITEMCELL_IMG[img_color - 1]
		asset_name = asset_name and asset_name or "bg_corner_tag_green"
		local bundle, asset = ResPath.GetImages(asset_name)
		self.ImgDouqi.image:LoadSprite(bundle, asset)

		local douqi_info = DouQiData.Instance:GetDouqiGradeCfg(text_order)
		self.TxtDouqi.text.text = douqi_info and douqi_info.grade_name or ""
	elseif self.ImgDouqi then
		self.ImgDouqi:SetActive(false)
	end
end

function ItemCell:SetShowZhuanShu(enable)
	if self.ZhuanShu then
		self.ZhuanShu:SetActive(enable)
	else
		if enable then
			self.ZhuanShu = self:LoadChildObj("ZhuanShu")
			self.ZhuanShu.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
	end
end

function ItemCell:SetShowDecorationTAG(enable)
	if self.decoration_tag then
		self.decoration_tag:SetActive(enable)
	else
		if enable then
			self.decoration_tag = self:LoadChildObj("DecorationTAG")
			self.decoration_tag.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
	end
end

function ItemCell:SetShenYinSlot(item_id)
	if nil == self.ShenYinName then
		self.ShenYinName = self:LoadChildObj("ShenYinName")
	end
	self.ShenYinName:SetActive(true)
	local cfg = ShenYinData.Instance:GetItemIdCFGByVItemID(item_id)
	self.ShenYinName.text.text = ShenYinData.Instance:GetItemSuitNameBySuitId(cfg.suit_id)
end

-- 设置周末装备侧标签
function ItemCell:SetTainShenEquipLabel(item_id)
	if nil == self.TainShenEquipLabel then
		self.TainShenEquipLabel = self:LoadChildObj("TainShenEquipLabel")
	end
	self.TainShenEquipLabel:SetActive(true)
	local cfg = TianshenhutiData.Instance:GetEquipCfgByItemId(item_id)
	if cfg then
		local bundle, asset = ResPath.GetTianShenIconByTaoZhuangType(cfg.taozhuang_type)
		self.TainShenEquipLabel.image:LoadSprite(bundle, asset)
	end
end

function ItemCell:SetDeitySuitText(str)
	if nil == self.SuitText then
		self.SuitText = self:LoadChildObj("SuitText")
	end
	if self.SuitText then
		self.SuitText:SetActive(true)
		self.SuitText.text.text = str
	end
end

function ItemCell:SetShenGeInfo(data, is_from_bag)
	local function create_shenge_num(num)
		if nil == self.RomeNumImage then
			self.RomeNumImage = self:LoadChildObj("RomeNumImage")
		end
		self.RomeNumImage:SetActive(true)
		self.RomeNumImage.image:LoadSprite(ResPath.GetRomeNumImage(num))
	end

	if nil == data.shen_ge_data then
		local quality = ShenGeData.Instance:GetShenGeQualityByItemId(data.item_id)
		if quality < 0 then
			return
		end
		create_shenge_num(quality)
		return
	end
	create_shenge_num(data.shen_ge_data.quality)
end

-- 设置装备右上角阶数
function ItemCell:SetEquipGrade(item_cfg, equip_index, big_type)
	local enable = false
	local is_shengyin, shengyin_data = PlayerData.Instance:GetItemIsSealByItemId(item_cfg.id)
	if is_shengyin and shengyin_data ~= nil then
		self:SetShengYinGrade(shengyin_data.order)
		return
	end
	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 and not self:GetIconGrayScaleIsGray() and not DouQiData.Instance:IsDouqiEqupi(item_cfg.id) then
		enable = true
	elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
		enable = true
	elseif ItemData.IsShowNoEquipLevel(item_cfg.id) then
		enable = true
	elseif ZHISHENG_ITEM_USE_LIST[item_cfg.use_type] then
		enable = true
	elseif item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then
		enable = true
	else
		return
	end

	if nil == self.Grade then
		self.Grade = self:LoadChildObj("Grade")
	end
	self.Grade:SetActive(enable)

	if not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) and not EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) ~= -1 or ItemData.IsShowNoEquipLevel(item_cfg.id) then
		self.Grade.text.text = string.format(Language.Common.NoZhuan_level, item_cfg.limit_level)
	elseif ZHISHENG_ITEM_USE_LIST[item_cfg.use_type] then
		if item_cfg.use_type == 107 then
			self.Grade.text.text = tostring((item_cfg.param3 - 1) .. Language.Common.Jie) or ""
		else
			self.Grade.text.text = tostring((item_cfg.param2 - 1) .. Language.Common.Jie) or ""
		end
	elseif EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		self.Grade.text.text = tostring((item_cfg.order) .. Language.Common.Jie) or ""
	elseif item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then
		local cfg = TianshenhutiData.Instance:GetEquipCfgByItemId(item_cfg.id)
		if cfg then
			self.Grade.text.text = tostring((cfg.level) ..  Language.Common.Jie) or ""
		end
	else
		self.Grade.text.text = tostring((item_cfg.order - 1) .. Language.Common.Jie) or ""
	end
end

function ItemCell:ShowEquipGrade(value)
	if self.Grade then
		self.Grade:SetActive(value)
	end
end

function ItemCell:ShowEquipGradeText(level)
	if self.Grade then
		self.Grade.text.text = string.format(Language.Common.NoZhuan_level, level)
	end
end

function ItemCell:SetItemCellGrade(enable, grade_text)
	if self.Grade then
		self.Grade:SetActive(enable)
	else
		if enable then
			self.Grade = self:LoadChildObj("Grade")
		else
			return
		end
	end
	
	if grade_text then
		self.Grade.text.text = grade_text
	end
end

-- 设置格子上升和下降箭头
function ItemCell:SetItemGridArrow(big_type, equip_index, item_cfg, data, gamevo, is_from_bag)
	self:SetRoleProf(false)

	local is_up_flag = false
	local is_down_flag = false

	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0
		and (item_cfg.limit_prof == (gamevo.prof % 10) or item_cfg.limit_prof == 5) and not EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) 
		and not DouQiData.Instance:IsDouqiEqupi(item_cfg.id) then
		if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level then
			local bag_equip_power = EquipData.Instance:GetEquipCapacityPower(data)
			local curr_equip = EquipData.Instance:GetGridData(equip_index)
			local curr_equip_power = EquipData.Instance:GetEquipCapacityPower(curr_equip)
			is_up_flag = (bag_equip_power - curr_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
			is_down_flag = (curr_equip_power - bag_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
		end

		if is_from_bag then
			self:SetLevelNoEnoughImg(item_cfg.limit_level > gamevo.level)
		end

	elseif item_cfg.sub_type and EquipData.IsMarryEqType(item_cfg.sub_type) then
		-- 情缘装备

		local qy_dess_equip_list = MarryEquipData.Instance:GetMarryEquipInfo()
		local fight_power = CommonDataManager.GetCapability(item_cfg)
		local qy_dess_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
		local dress_fight_power = 0
		if qy_dess_equip_list[qy_dess_index] then
			local dress_item_cfg = ItemData.Instance:GetItemConfig(qy_dess_equip_list[qy_dess_index].item_id)
			dress_fight_power = dress_item_cfg and CommonDataManager.GetCapability(dress_item_cfg) or 0
		end

		if item_cfg.limit_sex == gamevo.sex then
			local marry_info = MarryEquipData.Instance:GetMarryInfo()
			if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= marry_info.marry_level then
				is_up_flag = fight_power > dress_fight_power
				is_down_flag = fight_power < dress_fight_power
			end
			if is_from_bag then
				self:SetLevelNoEnoughImg(item_cfg.limit_level > marry_info.marry_level)
			end
		end

		local score = ZhuanShengData.Instance:GetEquipScore(data, fight_power)
		if nil ~= score then
			self:SetGodQuality(true, score)
		end

	elseif item_cfg.sub_type and item_cfg.sub_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI and item_cfg.sub_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI then
		-- 转生装备
		-- self:SetRoleProf(true, item_cfg)

		if item_cfg.limit_prof == (gamevo.prof % 10) or item_cfg.limit_prof == 5 then
			if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level then
				local bag_equip_power = EquipData.Instance:GetEquipCapacityPower(data)
				-- local curr_equip = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
				-- local curr_equip_power = EquipData.Instance:GetEquipCapacityPower(curr_equip)	
				local curr_equip_power = ForgeData.Instance:GetZhuanzhiEquipAllPower(equip_index)
				is_up_flag = (bag_equip_power - curr_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
				is_down_flag = (curr_equip_power - bag_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
			end
			if is_from_bag then
				self:SetLevelNoEnoughImg(item_cfg.limit_level > gamevo.level)
			end
		end

		local score = ZhuanShengData.Instance:GetEquipScore(data, fight_power)
		if nil ~= score then
			self:SetGodQuality(true, score)
		end
	elseif EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		-- 百战装备
		if item_cfg.limit_prof == (gamevo.prof % 10) or item_cfg.limit_prof == 5 then
			if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level then
				local bag_equip_power = EquipData.Instance:GetEquipCapacityPower(data)	
				local curr_equip_power = ForgeData.Instance:GetBaiZhanEquipAllPower(equip_index)
				is_up_flag = (bag_equip_power - curr_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
				is_down_flag = (curr_equip_power - bag_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
			end
			if is_from_bag then
				self:SetLevelNoEnoughImg(item_cfg.limit_level > gamevo.level)
			end
		end
	elseif DouQiData.Instance:IsDouqiEqupi(item_cfg.id) then
		-- 斗气装备
		if (item_cfg.limit_prof == (gamevo.prof % 10) or item_cfg.limit_prof == 5) then
			local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
			local douqi_equip_cfg = DouQiData.Instance:GetDouqiEquipCfg(item_cfg.id)
			if (is_from_bag or TipsFormDef.FROM_DOUQI_VIEW == self.from_view) and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level and 
				douqi_info and douqi_equip_cfg and douqi_info.douqi_grade >= douqi_equip_cfg.order then

				local bag_equip_power = EquipData.Instance:GetEquipCapacityPower(data)	
				local douqi_equip = DouQiData.Instance:GetDouqiEquipByIndex(equip_index + 1)
				local curr_equip_power = EquipData.Instance:GetEquipCapacityPower(douqi_equip)	

				is_up_flag = (bag_equip_power - curr_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
			end
			if is_from_bag or TipsFormDef.FROM_DOUQI_VIEW == self.from_view then
				self:SetLevelNoEnoughImg(item_cfg.limit_level > gamevo.level or douqi_info.douqi_grade < douqi_equip_cfg.order)
			end
		end
	end

	local is_show_arrow = is_up_flag or is_down_flag
	self:SetShowUpArrow(is_show_arrow, is_down_flag)

	-- if is_from_bag then
	-- 	self:SetActivityEffect(not is_up_flag)
	-- end
end

-- 设置右上角职业
function ItemCell:SetRoleProf(value, item_cfg)
	local function call_back(obj)
		if value and item_cfg then
			obj.text.text = Language.Common.RoleProfList[item_cfg.limit_prof] and Language.Common.RoleProfList[item_cfg.limit_prof] or ""
		end
	end

	if self.RoleProf then
		self.RoleProf:SetActive(value)
	else
		if value then
			self.RoleProf = self:LoadChildObj("RoleProf")
		else
			return
		end
	end
	call_back(self.RoleProf)
end

function ItemCell:SetGodQuality(enable, score)
	if self.GodQuality then
		self.GodQuality:SetActive(enable)
	else
		if enable then
			self.GodQuality = self:LoadChildObj("GodQuality")
		else
			return
		end
	end
	if score then
		self.GodQuality.text.text = score
	end
end

function ItemCell:SetSuitItemName(enable, name)
	if self.SuitItemName then
		self.SuitItemName:SetActive(enable)
	else
		if enable then
			self.SuitItemName = self:LoadChildObj("SuitItemName")
		else
			return
		end
	end
	if name and self.SuitItemName then
		self.SuitItemName.text.text = name
	end
end

-- 设置格子道具左上角物品数字
function ItemCell:SetItemGridTopLeftPropNum(item_cfg)
	local enable = false
	if item_cfg and self:IsShowPropDesNum(item_cfg.use_type) and item_cfg.param1 then
		enable = true
	end

	local function call_back(obj)
		if enable then
			if item_cfg.param1 >= 10000 and item_cfg.param1 < 100000000 then
				local num_wan = math.floor(item_cfg.param1 / 10000)
				obj.text.text = num_wan .. Language.Common.Wan
			elseif item_cfg.param1 >= 100000000 then
				local num_yi = math.floor(item_cfg.param1 / 100000000)
				obj.text.text = num_yi .. Language.Common.Yi
			else
				obj.text.text = item_cfg.param1
			end
		end
	end

	if self.PropDes then
		self.PropDes:SetActive(enable)
	else
		if enable then
			self.PropDes = self:LoadChildObj("PropDes")
		else
			return
		end
	end
	call_back(self.PropDes)
end

-- 设置格子默认特效
function ItemCell:SetNormalItemEffect(equip_index, data, item_cfg, is_from_bag)	
	if not EquipData.Instance:GetGridData(equip_index) and (item_cfg.special_show and 1 == item_cfg.special_show) then
		if self:SpecialItemEffect(data.item_id) then
			if item_cfg.color == 4 then
				self:ShowEquipOrangeEffect(true)
			elseif item_cfg.color == 5 then
				self:ShowExtremeEffect(true, 6, nil, true)
			elseif item_cfg.color == 6 then
				self:ShowExtremeEffect(true, 10, nil, true)
			end
		else
			self:ShowExtremeEffect(true, nil, item_cfg.color, true)
		end
	end
end

-- 特殊ID段显示别的特效（非装备）
function ItemCell:SpecialItemEffect(item_id)
	if item_id then
		return (24301 <= item_id and item_id <= 24756)
	end
end

-- 设置格子是否置灰
function ItemCell:SetItemGridGrayState(data, equip_index, item_cfg, big_type, gamevo, is_from_bag)
	local is_gray = false
	if data.is_gray ~= nil then
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
			if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				data.is_gray = true
			end
		end
		is_gray = data.is_gray
	else
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
			if is_from_bag then
				if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
					is_gray = true
				else
					is_gray = false
				end
			end
		elseif is_from_bag and item_cfg.sub_type and EquipData.IsMarryEqType(item_cfg.sub_type) then
			is_gray = (gamevo.sex ~= item_cfg.limit_sex)
		elseif is_from_bag then
			if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				is_gray = true
			else
				is_gray = false
			end
		elseif item_cfg.sub_type and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				is_gray = true
			else
				is_gray = false
			end
		else
			is_gray = self.is_gray
		end
	end
	self:SetIconGrayVisible(is_gray)
end

function ItemCell:SetLevelNoEnoughImg(enable)
	if self.LevelNoEnough then
		self.LevelNoEnough:SetActive(enable)
	else
		if enable then
			self.LevelNoEnough = self:LoadChildObj("LevelNoEnough")
		end
	end
end

-- 设置运营活动物品特效
function ItemCell:IsDestoryActivityEffect(value)
	self.is_destroy_activity_effect = value
end

-- 设置运营活动格子特效
function ItemCell:SetActivityEffect(value)
	local active_value = self.is_destroy_activity_effect
	if nil ~= value then
		active_value = value
	end

	self:ShowActivityEffect(not active_value)
end

function ItemCell:GetData()
	return self.data or {}
end

function ItemCell:IsGray()
	return self.is_gray
end

function ItemCell:SetIconGrayVisible(enable)
	if self.Gray then
		self.Gray:SetActive(enable)
		self.Gray.image.enabled = true
	else
		if enable then
			self.Gray = self:LoadChildObj("Gray")	
			self.Gray.image.enabled = true
		end
	end
	self:ResetChildObjOrder()
end

function ItemCell:ResetChildObjOrder()
	if self.RedPoint then
		self.RedPoint.transform:SetAsLastSibling()
	end
	if self.Gray then
		self.Gray.transform:SetAsLastSibling()
	end
	if self.HasGet then
		self.HasGet.transform:SetAsLastSibling()
	end
end

function ItemCell:SetIconGrayAlphe(value)
	if self.Gray then
		self.Gray.image.color = Color(0, 0, 0, value)
	end
end

function ItemCell:SetIconGraySize()
	if self.Gray then
		self.Gray.rect.sizeDelta = Vector3(0, 0, 0)
	end
end


function ItemCell:SetToggle(is_on)
	if self:GetActive() then
		if self.node_list["HighLight"] then
			self.root_node.toggle.isOn = is_on
			self.node_list["HighLight"]:SetActive(is_on)
		end
	end
end

function ItemCell:SetNum(num)
	if num > 0 then
		self.node_list["NumberBg"]:SetActive(true)
		self.node_list["Number"].text.text = num
	else
		self.node_list["NumberBg"]:SetActive(false)
	end
end

function ItemCell:SetNumScale(scale)
	self.change_num_scale = true
	self.node_list["NumberBg"].transform.localScale = Vector3(scale, scale, scale)
end

function ItemCell:IsShowPropDesNum(use_type)
	if not use_type then return false end

	for k, v in pairs(PROP_USE_TYPE) do
		if use_type == v then
			return true
		end
	end

	return false
end

function ItemCell:SetItemNum(num)
	self.node_list["Number"].text.text = num
end

function ItemCell:GetEffectRoot()
	return self.node_list["Quality"]
end

function ItemCell:SetAsset(bundle, asset)
	if bundle and asset then
		self.node_list["Icon"].image:LoadSprite(bundle, asset)
		self.node_list["Icon"]:SetActive(true)
	end
end

function ItemCell:SetQualityByColor(color)
	local bundle, asset = ResPath.GetQualityIcon(color)
	if bundle and asset then
		self.node_list["Quality"].image:LoadSprite(bundle, asset)
	end
end

function ItemCell:SetShowUpArrow(is_show, is_down)
	if is_down then
		return
	end
	self.is_show_arrow = is_show
	if self.UpArrow then
		self.UpArrow:SetActive(is_show)
	else
		if is_show then
			self.UpArrow = self:LoadChildObj("UpArrow")
		end
	end
	-- if is_show and self.UpArrow then
	-- 	self.UpArrow:SetActive(false)
	-- 	self.UpArrow:SetActive(true)
	-- 	local bundle, asset = ResPath.GetImages("icon_arrow_1")
		-- if is_down then
		-- 	bundle, asset = ResPath.GetImages("icon_arrow_item_down")
		-- end
		-- self.UpArrow.image:LoadSprite(bundle, asset)
		-- local start_pos = Vector3(0 , 0 , 0)
		-- local end_pos = Vector3(0 , 30 , 0)
		-- UITween.MoveLoop(self.UpArrow, start_pos, end_pos, 0.5)
	-- end
end

function ItemCell:ResetUpArrowAni()
	if self.UpArrow and self.is_show_arrow and self.UpArrow.SetActive then
		self.UpArrow:SetActive(false)
		self.UpArrow:SetActive(true)
	end
end

function ItemCell:ResetRewardEffect()
	if self.item_effect["ItemRewardEffect"] and self.item_effect["ItemRewardEffect"].obj and self.item_effect["ItemRewardEffect"].enable then
		self.item_effect["ItemRewardEffect"].obj:SetActive(false)
		self.item_effect["ItemRewardEffect"].obj:SetActive(true)
	end
end


function ItemCell:SetAlpha(value)
	if self.root_node.canvas_group and self:GetActive() then
		self.root_node.canvas_group.alpha = value
	end
end

function ItemCell:GetTransForm()
	return self.root_node.transform
end

function ItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function ItemCell:SetCellLock(is_lock)
	self.node_list["CellLock"]:SetActive(is_lock)

end

function ItemCell:SetIsShowTips(flag)
	self.is_showtip = flag
end

function ItemCell:GetIsShowTips()
	return self.is_showtip
end

function ItemCell:SetShowStar(star_num)
	if star_num > 0 then
		for i = 1, 3 do
			if i <= star_num then
				self:SetShowStarIndex(i, true)
			else
				self:SetShowStarIndex(i, false)
			end
		end
	end
end

function ItemCell:SetVisibleShowStar(is_show)
	if not is_show then
		for i = 1, 3 do
			self:SetShowStarIndex(i, false)
		end
	end
end


function ItemCell:SetShowStarIndex(i, enable)
	if enable then
		if nil == self.StarsGroup then
			self.StarsGroup = self:LoadChildObj("StarsGroup")
		end
		self.show_stars[1] = self.StarsGroup.transform:FindHard("Star1").gameObject
		self.show_stars[2] = self.StarsGroup.transform:FindHard("Star2").gameObject
		self.show_stars[3] = self.StarsGroup.transform:FindHard("Star3").gameObject
	end
	if self.show_stars[i] then
		self.show_stars[i]:SetActive(enable)
	end
end

-- 修改子物体的transform list位置
function ItemCell:SetChildSiblingIndex(child_name, index)
	if self.node_list[child_name] then
		self.node_list[child_name].transform:SetSiblingIndex(index)
	end
end

function ItemCell:SetShengYinLock(enable)
	if self.ShengYinLock then
		self.ShengYinLock:SetActive(enable)
	else
		if enable then
			self.ShengYinLock = self:LoadChildObj("ShengYinLock")
			-- self.ShengYinLock:SetActive(enable)
		else
			return
		end
	end
end

function ItemCell:SetShengYinGrade(grade)
	if grade == nil or grade <= 0 then
		return
	end
	if self.ShengYinGrade then
		self.ShengYinGrade.text.text = tostring(grade .. Language.Common.Jie)
		self.ShengYinGrade:SetActive(true)
	else
		self.ShengYinGrade = self:LoadChildObj("ShengYinGrade")
		self.ShengYinGrade.text.text = tostring(grade .. Language.Common.Jie)
		self.ShengYinGrade:SetActive(true)
	end
	self:ResetChildObjOrder()
end

function ItemCell:SetShengYinEffect(enable, type_effect, size)
	if self.ShengYinEffect ~= nil then
		self.ShengYinEffect:SetActive(enable)
	else
		if enable then
			self.ShengYinEffect = self:LoadChildObj("ShengYinEffect")
			self.ShengYinEffect:SetActive(enable)
		else
			return
		end
	end
	if enable and type_effect ~= nil then
		for i = 1, 3 do
			self.ShengYinEffect.transform:FindHard("Effect" .. i).gameObject:SetActive(i == type_effect)
		end
	end
	self.ShengYinEffect.rect.localScale = size and size or Vector3(1, 1, 1)
end
-------------------------------------------------------

--t{name, pos, size, asset_bundle}
function ItemCell:CreateEffectChildObj(t, root)
	if self.hide_effect and t.name ~= "SoulEffect" and t.name ~= "ItemIconEffect" then
		return
	end

	local item_key = t.name .. t.asset_bundle.asset
	self.item_effect[t.name].key = self.item_effect[t.name].key or {}
	if self.item_effect[t.name].key[item_key] then
		return
	end
	self.item_effect[t.name].key[item_key] = item_key

	local root_node = self.root_node

	local async_loader = AllocAsyncLoader(self, t.name)
	async_loader:Load(t.asset_bundle.bundle, t.asset_bundle.asset, function(obj)

		if nil == obj or nil == root_node or IsNil(root_node.transform) then
			ResMgr:Destroy(obj)
			return
		elseif self.item_effect[t.name] and self.item_effect[t.name].obj then
			ResMgr:Destroy(self.item_effect[t.name].obj)
		end

		if nil ~= self.data and nil ~= self.data.item_id then
			obj.name = t.name
			obj.transform:SetParent(root_node.transform)
			obj.transform.localScale = t.scale and Vector3(t.scale, t.scale, t.scale)or Vector3(1, 1, 1)
			obj.transform.anchoredPosition3D = t.pos and Vector3(t.pos[1], t.pos[2], 0) or Vector3(0, 0, 0)
			if t.size then
				obj.gameObject:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta = Vector2(t.size[1], t.size[2])
			else
				obj.transform.anchorMax = Vector2(1, 1)
				obj.transform.anchorMin = Vector2(0, 0)
				obj:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta = Vector2(0, 0)
			end

			self.item_effect[t.name].obj = obj
			obj:SetActive(self.item_effect[t.name].enable and not self.is_gray_icon)

			if t.call_back then
				t.call_back()
			end
		else
			ResMgr:Destroy(obj)
		end
	end)
end

local ChildObj_Pos = {
	["Strength"] = {-30, 15},		["JueBan"] = {-13, 13},			["InlaySlot"] = {33, 24},
	["RomeNumImage"] = {-35, 17},	["Grade"] = {-47.5, -17},		["LevelNoEnough"] = {-4, 4.5},
	["RoleProf"] = {-49, -18},		["TopLeft"] = {0, -3},			["TimeLimit"] = {-15, 15},
	["ShenYinName"] = {0, -26},		["PropDes"] = {3, -3.5},		["GodQuality"] = {38, -15},
	["UpArrow"] = {-3, 3},			["RedPoint"] = {5, 5},			["StarsGroup"] = {-30, -32.5},
	["ShengYinLock"] = {0, 0},      ["ShengYinGrade"] = {18, 25},	["ShengYinEffect"] = {0, 0},
	["StarLevel"] = {-30, 15},		["SuitText"] = {-30, 15},		["LuoShuProf"] = {12, 25},
	["ZhuanShu"] = {31, -31},		["LimitUse"] = {-3, 3},			["SuitItemName"] = {45, -15},
	["BestEquipTip"] = {14, 14},	["LingHunLevel"] = {-27, 27},	["DecorationTAG"] = {30, -31},
	["NewItem"] = {80, 80},			["TainShenEquipLabel"] = {21, -21},	
	["ImgDouqi"] = {26.5, -26.5},
}
--Load预制物
function ItemCell:LoadChildObj(obj_name, root , position)
	local bundle, asset = self:GetChildResPath(obj_name)
	local obj = ResPoolMgr:TryGetGameObject(bundle, asset)
	if nil == obj then 
		return 
	end
	local transform = obj.transform
	obj.name = obj_name
	transform:SetParent(self.root_node.transform, false)

	local pos = position or ChildObj_Pos[obj_name]
	obj.gameObject.transform.localScale = Vector3(1, 1, 1)
	obj.gameObject.transform.anchoredPosition3D = pos and Vector3(pos[1], pos[2], 0) or Vector3(0, 0, 0)
	obj = U3DObject(obj, obj.transform, self)
	self.child_tab[#self.child_tab + 1] = obj
	return obj
end

function ItemCell:GetChildResPath(name)
	return "uis/views/commonwidgets/itemcellchild_prefab", name
end
