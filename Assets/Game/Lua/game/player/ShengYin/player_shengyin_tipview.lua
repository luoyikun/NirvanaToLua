-- require("game/player/shengyin/shengyin_equip_view")

ShengYinTipView = ShengYinTipView or BaseClass(BaseView)

------------道具属性-----------------------------------
local ATTR_BASE_SY = 1 					--圣印基础属性
local ATTR_STRENGTH_SY = 2				--圣印强化属性
local ATTR_SUIT_SY = 3 					--圣印套装属性

local MAX_ATTR_STRENGTH_NUM = 6			--强化属性最大显示个数

function ShengYinTipView:__init()
	self.ui_config = {
		{"uis/views/player/shengyin_prefab", "ShengYinEquipTip"},
	}
	self.shou_btn_use = false
	self.show_btn_exchange = false
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengYinTipView:__delete()
	for i = 1,2 do
		self.fight_text[i] = nil
	end
	self.fight_text = nil
end

function ShengYinTipView:ReleaseCallBack()
	if self.item_icon then 
		self.item_icon:DeleteMe()
		self.item_icon = nil
	end
	if self.item_icon_compare then
		self.item_icon_compare:DeleteMe()
		self.item_icon_compare = nil 
	end
	self.close_callback = nil
	self.base_attr_list = {}
	self.teshu_txt_list = {}
	self.data = {}

	
end

function ShengYinTipView:LoadCallBack()
	-- self.data = {}
	self.base_attr_list = {{}, {}}
	self.teshu_txt_list = {{}, {}}
	self.item_icon = ItemCell.New()
	self.item_icon:SetInstanceParent(self.node_list["ItemImg1"])
	self.item_icon_compare = ItemCell.New()
	self.item_icon_compare:SetInstanceParent(self.node_list["ItemImg2"])
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.UseShengYin, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ExchangeShengYin, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.fight_text = {}
	self.fight_text[1] = CommonDataManager.FightPower(self, self.node_list["FightNum1"], "FightPower3")
	self.fight_text[2] = CommonDataManager.FightPower(self, self.node_list["FightNum2"], "FightPower3")
	self.strength_nodelist_table = {}
	self.strength_nodelist_table[1] = U3DNodeList(self.node_list["CompareEquipTip1"]:GetComponent(typeof(UINameTable)))
	self.strength_nodelist_table[2] = U3DNodeList(self.node_list["CompareEquipTip2"]:GetComponent(typeof(UINameTable)))
	self.suit_variable_table = {}
	self.suit_variable_table[1] = U3DNodeList(self.node_list["SuitAttrText1"]:GetComponent(typeof(UINameTable)))
	self.suit_variable_table[2] = U3DNodeList(self.node_list["SuitAttrText2"]:GetComponent(typeof(UINameTable)))
end
-- 发送协议
function ShengYinTipView:UseShengYin()
	if self.data[1] == nil then return end 
	local item_cfg = ItemData.Instance:GetItemConfig(self.data[1].item_id) or {}
	local seal_slot = PlayerData.Instance:GetSealSlotBySealId(item_cfg.id)
 	local bag_index = self.data[1].bag_index			--PlayerData.Instance:GetShengYinBagIndex()
 	if bag_index then
 		PackageCtrl.Instance:SendUseItem(bag_index, 1)
		-- PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_PUT_ON , bag_index , seal_slot)
	end
	self:Close()
end

function ShengYinTipView:ExchangeShengYin()
	if self.data[1] == nil then return end
	ViewManager.Instance:Open(ViewName.ShengYinEquip)
	self:Close()
end

function ShengYinTipView:CloseCallBack()
	if self.close_callback ~= nil then 
		self.close_callback()
	end
end

function ShengYinTipView:SetShengYinData(data, from_view, param, close_callback)
	self.close_callback = close_callback
	self.fromView = from_view
	self.data = {}
	if from_view == TipsFormDef.FROM_SHENGYIN or from_view == TipsFormDef.FROM_SHENGYIN_COMPARE then 
		self.shou_btn_use = true
	else
		self.shou_btn_use = false
	end

	if from_view == TipsFormDef.FROM_SHENGYIN_EXCHANGE then
		self.show_btn_exchange = true
	else
		self.show_btn_exchange = false
	end

	if not data then
		return
	end
	self.data[1] = data
	
	if from_view == TipsFormDef.FROM_SHENGYIN_COMPARE then 
		self.data[2] = param
		
	else
		self.data[2] = nil
	end
	self:Open()
	self:Flush()
	
end

function ShengYinTipView:OpenCallBack()
	if self.data[2] ~= nil and self.data[2].slot_index > 0 then 
		self.node_list["CompareEquipTip1"].gameObject:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(195, 0)
		self.node_list["CompareEquipTip2"]:SetActive(true)
		self.node_list["CloseButton"]:SetActive(false)
	else
		self.node_list["CompareEquipTip1"].gameObject:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 0)
		self.node_list["CompareEquipTip2"]:SetActive(false)
		self.node_list["CloseButton"]:SetActive(true)
	end
	
end

function ShengYinTipView:OnFlush()
	self.node_list["BtnUse"]:SetActive(self.shou_btn_use)
	self.node_list["BtnExchange"]:SetActive(self.show_btn_exchange)
	self:FlushViewInfo()
	self:FlushItemCell()
end

function ShengYinTipView:FlushItemCell()
	if self.data[1] == nil then return end 
	if nil ~= self.item_icon then 
		self.item_icon:SetData(self.data[1])
		self.item_icon:SetInteractable(false)
		self.item_icon:SetIsShowTips(false)
		if self.data[1].order ~= nil and self.data[1].order > 0 then 
			-- self.item_icon:SetShengYinGrade(self.data[1].order)
			self.item_icon:ShowGetEffect(self.data[1].order > 2)
		end
	end
	local remind_list = PlayerData.Instance:GetSealEquipRemind()
	if remind_list[self.data[1].slot_index - 1] then
		self.node_list["Remind"]:SetActive(true)
	else
		self.node_list["Remind"]:SetActive(false)
	end
	if self.data[2] == nil then return end 
	if nil ~= self.item_icon_compare then 
		self.item_icon_compare:SetData(self.data[2])
		self.item_icon_compare:SetInteractable(false)
		self.item_icon_compare:SetIsShowTips(false)
		if self.data[2].order ~= nil and self.data[2].order > 0 then 
			-- self.item_icon_compare:SetShengYinGrade(self.data[2].order)
			self.item_icon_compare:ShowGetEffect(self.data[2].order > 2)
		end
	end
end

function ShengYinTipView:FlushViewInfo()
	for m = 1, 2 do
		if self.data[m] == nil then return end 
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data[m].item_id) or {}
		if not next(item_cfg) then return end

		local bundle1, asset1 = ResPath.GetQualityRawBgIcon(item_cfg.color)
		local bundle2, asset2 = ResPath.GetQualityKuangBgIcon(item_cfg.color)
		local bundle3, asset3 = ResPath.GetQualityTopBg(item_cfg.color)
		self.node_list["QualityImage" .. m].raw_image:LoadSprite(bundle1, asset1)
		self.node_list["Kuang" .. m].image:LoadSprite(bundle2, asset2)
		self.node_list["Line" .. m].image:LoadSprite(bundle3, asset3)
		local is_seal, cfg = PlayerData.Instance:GetItemIsSealByItemId(item_cfg.id)
		self.node_list["EquaipName"..m].text.text = item_cfg.name
		self.node_list["UseLevelTxt"..m].text.text = string.format(Language.Tip.UsePlace, cfg.buwei)
		if is_seal and self.fromView == TipsFormDef.FROM_SHENGYIN or self.fromView == TipsFormDef.FROM_SHENGYIN_NOT_USE or is_seal 
			or self.fromView == TipsFormDef.FROM_SHENGYIN_EXCHANGE or self.fromView == TipsFormDef.FROM_SHENGYIN_COMPARE then 
			self.attrslist = {}

			local attribute = {} 
			attribute[ATTR_BASE_SY] = PlayerData.Instance:GetBaseAttrKey() --圣印基础属性
			attribute[ATTR_STRENGTH_SY] = PlayerData.Instance:GetBaseAttrKey()	--强化属性
			self.node_list["TeShuAttr"..m]:SetActive(false)
			self.node_list["SuitAttr"..m]:SetActive(false)
			local _, item_data = PlayerData.Instance:GetItemIsSealByItemId(self.data[m].item_id)
			if self.data[m].slot_index == nil then
				local is_trun, slot_index = PlayerData.Instance:GetItemIsSealByItemId(item_cfg.id)
				self.data[m].slot_index = slot_index.slot_index
			end
			if self.data[m].level == nil then
				self.data[m].level = 0
			end
		
			if item_data.suit_type ~= 0 then 
				local suit_cfg = PlayerData.Instance:GetShengYinSuitCfg()
				local item_count = PlayerData.Instance:GetFinshSuitCountBySuitType(item_data.suit_type)
				if suit_cfg[item_data.suit_type] ~= nil then
					local name_suit = suit_cfg[item_data.suit_type].suit_name
					if self.fromView == TipsFormDef.FROM_SHENGYIN or (self.fromView == TipsFormDef.FROM_SHENGYIN_COMPARE and m == 1) then
						self.node_list["SuitName" .. m].text.text = name_suit
					else
						local suit_part_list = Split(suit_cfg[item_data.suit_type].equip_part, "|")
						self.node_list["SuitName" .. m].text.text = name_suit .. "(" .. item_count .. "/" .. #suit_part_list .. ")"
					end
				end

				attribute[ATTR_SUIT_SY] = PlayerData.Instance:GetSuitDataByItemSuitType(item_data.suit_type)	--套装属性

			else
				attribute[ATTR_SUIT_SY] = {}
			end
			
			for i = #attribute, 1, -1 do
				if ATTR_BASE_SY == i then 
					for k, v in pairs(self.base_attr_list[m]) do
						v:SetActive(false)
					end
					local value = nil
					local flag = false
					local seal_attr_list = PlayerData.Instance:GetSealAttrData(self.data[m].slot_index, self.data[m].order or 5)
					local seal_attr_has_line = CommonDataManager.GetAttributteByClass(seal_attr_list)
					local attr_add_list = PlayerData.Instance:GetSoulAttrValueBySlotIndex(self.data[m].slot_index)
					local attr_add_has_line = CommonDataManager.GetAttributteByClass(attr_add_list)
					attr_add_has_line = CommonDataManager.MulAttribute(attr_add_has_line, self.data[m].level)

					local totle_attr_list = CommonDataManager.AddAttributeAttr(seal_attr_has_line, attr_add_has_line)
					local fight_score = CommonDataManager.GetCapabilityCalculation(totle_attr_list)						-- 战力计算
					if self.fight_text[m] and self.fight_text[m].text then
						self.fight_text[m].text.text = fight_score
					end

					local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
					res_async_loader:Load("uis/views/player/shengyin_prefab", "BaseAttr", nil, function (prefab)
						if nil == prefab then
							return
						end
						for k1, v1 in pairs(attribute[i]) do
							if seal_attr_list[v1] ~= nil and seal_attr_list[v1] > 0 then
								local name_str = Language.Player.AttrNameShengYin[v1]
								local str = ""
								local split_attr = Split(v1, "_")
								local is_per = split_attr[1] == "per" or split_attr[#split_attr] == "per"
								local attri_text = ""
								local base_attr_value = seal_attr_list[v1]
								
								str = base_attr_value
								name_str = ToColorStr(name_str, TEXT_COLOR.WHITE)
								str = ToColorStr(str, TEXT_COLOR.GREEN)
								local base_attr_list = self.base_attr_list[m]
								if base_attr_list[k1] == nil then 
									local obj = ResMgr:Instantiate(prefab)
									local obj_transform = obj.transform
									obj_transform:SetParent(self.node_list["BaseAttrText"..m].transform, false)
									obj:GetComponent(typeof(UnityEngine.UI.Text)).text = name_str .. str
									table.insert(base_attr_list , k1 , obj )
									self.base_attr_list[m] = base_attr_list
								else
									base_attr_list[k1]:GetComponent(typeof(UnityEngine.UI.Text)).text = name_str .. str
									base_attr_list[k1]:SetActive(true)
								end
								flag = true
								self.node_list["BaseAttr"..m]:SetActive(true)
							end
						end
					end)
					if not flag then 
						self.node_list["BaseAttr"..m]:SetActive(false)
					end
				elseif ATTR_STRENGTH_SY == i then 
					local flag = false

					if (self.fromView == TipsFormDef.FROM_SHENGYIN_COMPARE and m == 2) or (self.fromView == TipsFormDef.FROM_SHENGYIN_EXCHANGE and m == 1) and self.strength_nodelist_table[m] then
						local attr_add_list = PlayerData.Instance:GetSoulAttrValueBySlotIndex(self.data[m].slot_index)
						local attr_add_has_line = CommonDataManager.GetAttributteByClass(attr_add_list)
						local strength_index = 1
						for k1, v1 in pairs(attribute[i]) do
							local name_str = Language.Player.AttrNameShengYin[v1]
							name_str = ToColorStr(name_str, TEXT_COLOR.WHITE)
							local attr_add_value = attr_add_list[v1] or 0
							local split_attr = Split(v1, "_")
							local is_per = split_attr[1] == "per" or split_attr[#split_attr] == "per"
							if self.data[m].level > 0 and attr_add_value > 0 then 
								flag = true
								attr_add_value = attr_add_value * self.data[m].level
								if is_per then 
									attr_add_value = attr_add_value / 100 .. "%"
								end
								if self.strength_nodelist_table[m]["RandomAttrTxt" .. strength_index] then
									self.strength_nodelist_table[m]["RandomAttrTxt" .. strength_index].text.text = name_str .. ToColorStr(attr_add_value, TEXT_COLOR.GREEN)
									self.strength_nodelist_table[m]["RandomAttrTxt" .. strength_index]:SetActive(true)
									strength_index = strength_index + 1
								end
							end
						end
						for j = strength_index, MAX_ATTR_STRENGTH_NUM do
							self.strength_nodelist_table[m]["RandomAttrTxt" .. j]:SetActive(false)
						end
					end

					self.node_list["TeShuAttr" .. m]:SetActive(flag)

				elseif ATTR_SUIT_SY == i then
					local flag = false
					if self.suit_variable_table[m] ~= nil then
						for k, v in pairs(self.suit_variable_table[m]) do
							v:SetActive(false)
						end
					end
				 	if next (attribute[i]) ~= nil and self.suit_variable_table[m] ~= nil then
				 		table.sort(attribute[i], function(a, b) return a.same_order_num < b.same_order_num end )
						local value = nil
						local seal_slot_grid_list = PlayerData.Instance:GetSealSlotItemList()
						for k1, v1 in pairs(attribute[i]) do
							self.suit_variable_table[m]["CastAttr_".. k1]:SetActive(true)
							self.suit_variable_table[m]["attrlist".. k1]:SetActive(true)
							local list_table = U3DNodeList(self.suit_variable_table[m]["attrlist".. k1]:GetComponent(typeof(UINameTable)))
							local item_count = PlayerData.Instance:GetFinshSuitCountBySuitType(v1.suit_type)
							for k, v in pairs(list_table) do
								v.gameObject:SetActive(false)
							end
							local color_s = 0 
							local key_color = 0
							local name_color = 0
							if item_count >= v1.same_order_num and self.fromView ~= TipsFormDef.FROM_SHENGYIN and 
								not (self.fromView == TipsFormDef.FROM_SHENGYIN_COMPARE and m == 1) then 			----  子豪说来自圣印背包的圣印不显示套装数量,也不让套装属性变绿
								color_s = TEXT_COLOR.GREEN
								key_color = TEXT_COLOR.GREEN
								name_color = TEXT_COLOR.GREEN
							else
								color_s = TEXT_COLOR.WHITE
								key_color = TEXT_COLOR.WHITE
								name_color = TEXT_COLOR.LightBlue
							end
							local name_str = string.format(Language.Player.SomePiece2, v1.same_order_num)
							self.suit_variable_table[m]["CastAttr_".. k1].text.text = ToColorStr(name_str, name_color) 
							local suit_attr_info_list = PlayerData.Instance:GetTotalAttrKey()
							local index = 0
							for k2, v2 in ipairs(suit_attr_info_list) do
								if v1[v2] ~= nil and v1[v2] > 0 then
									index = index + 1
									local split_attr = Split(v2, "_")
									local is_per = split_attr[1] == "per" or split_attr[#split_attr] == "per"
									local attr_value = v1[v2]
									if is_per then 
										attr_value = attr_value / 100 .. "%"
									end
									attr_value = "+" .. attr_value
									list_table["attrTxt" .. index].gameObject:SetActive(true)
									list_table["attrTxt" .. index].text.text = ToColorStr(Language.Player.AttrNameShengYinSuit[v2], key_color) .. ToColorStr(attr_value, color_s)
									flag = true
								end
							end
						end
					end
					self.node_list["SuitAttr"..m]:SetActive(flag)
				end
			end
		end
		local use_x = self.node_list["UseContent"..m].rect.anchoredPosition3D.x
		self.node_list["UseContent"..m].rect.anchoredPosition3D = Vector3(use_x, 0, 0)
	end
end