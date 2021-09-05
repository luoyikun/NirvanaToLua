ShenYinYinJiTipView = ShenYinYinJiTipView or BaseClass(BaseView)
ShenYinYinJiTipView.FromView = {
	ShenYinSlot = 1,
	ShenYinBag = 2,
	ShenYinStore = 3,
	ShenYinStrength = 4,
}
function ShenYinYinJiTipView:__init()
	self.ui_config = {{"uis/views/shenyinview_prefab", "ShenYinTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.cell_list = {}
end

function ShenYinYinJiTipView:__delete()

end

function ShenYinYinJiTipView:ReleaseCallBack()
	if self.equip_tips then
		self.equip_tips:DeleteMe()
		self.equip_tips = nil
	end
	if self.compare_equip_tips then
		self.compare_equip_tips:DeleteMe()
		self.compare_equip_tips = nil
	end
	self.cell_list = {}
end

function ShenYinYinJiTipView:LoadCallBack()
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.equip_tips = ShenYinYinJiTip.New(self.node_list["EquipTip"], self)
	self.equip_tips.is_equip = false
	self.equip_tips:SetActive(true)

	self.compare_equip_tips = ShenYinYinJiTip.New(self.node_list["CompareEquipTip"], self)
	self.compare_equip_tips.is_equip = true
	self.compare_equip_tips:SetActive(true)
end

function ShenYinYinJiTipView:CloseCallBack()
	self.equip_tips:CloseCallBack()
	self.compare_equip_tips:CloseCallBack()
end

function ShenYinYinJiTipView:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view)
		self.data_cache = nil
		self:Flush()
	end
end

--关闭装备Tip
function ShenYinYinJiTipView:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function ShenYinYinJiTipView:SetData(data, from_view)
	if not data then return end

	from_view = from_view or ShenYinYinJiTipView.FromView.ShenYinSlot
	if self:IsOpen() and self.equip_tips ~= nil then
		self.equip_tips:SetActive(true)
		self.equip_tips:SetData(data, from_view, false)
		local shenyin_slot_info = ShenYinData.Instance:GetMarkSlotInfo()
		local slot_data = shenyin_slot_info[data.imprint_slot] or nil
		self.compare_equip_tips:SetActive(from_view == ShenYinYinJiTipView.FromView.ShenYinBag and slot_data.is_have_mark)
		self.compare_equip_tips:SetData(slot_data, ShenYinYinJiTipView.FromView.ShenYinSlot, true)

		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view}
		self:Open()
	end
	self.from_view = from_view
end

function ShenYinYinJiTipView:OnFlush(param_t)
	self.equip_tips:Flush()
	self.compare_equip_tips:Flush()
end


--=========item====================


ShenYinYinJiTip = ShenYinYinJiTip or BaseClass(BaseRender)

function ShenYinYinJiTip:__init(instance, parent)
	self.parent = parent
	self.cell_list = {}
	self.base_attr_list = {}
	self.fuling_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["powerTxt"], "FightPower3")
	self.data = nil
	self.from_view = nil
	self.is_equip = true
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.suit_attr_list = {}
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])

	for i = 1, 2 do
		self.suit_attr_list[i] = {}

		local name_table = self.node_list["suit_attr"]:GetComponent(typeof(UINameTable))
		self.suit_attr_list[i].attr_obj = U3DObject(name_table:Find("attr_list" .. i))
		self.suit_attr_list[i].suit_num = U3DObject(name_table:Find("CastAttrTxt" .. i))

		self.suit_attr_list[i].attr_list = {}
		for j = 1, 3 do
			self.suit_attr_list[i].attr_list[j] = {}
			self.suit_attr_list[i].attr_list[j].attr_text = self.suit_attr_list[i].attr_obj:FindObj("Attr_" .. j)
			self.suit_attr_list[i].attr_list[j].attr_text:SetActive(false)
		end
	end

	for i =1 ,4 do
		-- local btn_text = self.node_list["RightBtn" .. i].transform:GetChild(0)
		self.buttons[i] = {btn = self.node_list["RightBtn" .. i], text = self.node_list["BtnText" .. i]}
	end

	for i = 1, 4 do
		self.base_attr_list[i] = {
			text_obj = self.node_list["BaseAttrTxt" .. i]
		}
		self.fuling_attr_list[i] = {
			text_obj = self.node_list["FuLingAttr_" .. i]
		}
		self.random_attr_list[i] = {
			text_obj = self.node_list["RandomAttrTxt" .. i]
		}
	end
end

function ShenYinYinJiTip:__delete()
	self.is_equip = true
	self.button_label = nil
	self.base_attr_list = {}
	self.fuling_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.button_handle = nil
	self.buttons = nil
	self.parent = nil
	self.fight_text = nil
	self.cell_list = {}

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function ShenYinYinJiTip:ShowTipContent()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local slot_data = ShenYinData.Instance:GetMarkSlotInfo()[self.data.imprint_slot] or {}

	-- local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.node_list["EquipNameTxt"].text.text = item_cfg.name
	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local bundle, asset = ResPath.GetQualityRawBgIcon(item_cfg.color)
	self.node_list["QualityImage"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["QualityImage"]:SetActive(true) end)
	self.node_list["Kuang"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line"].image:LoadSprite(ResPath.GetQualityTopBg(item_cfg.color))

	-- 基础属性
	local had_base_attr = {}
	local had_fuling_attr = {}
	local upstar_cfg = ShenYinData.Instance:GetUpStarCFG(self.data.imprint_slot, slot_data.grade, slot_data.level)
	local upstar_attr = CommonDataManager.GetAttributteByClass(upstar_cfg)
	local rate = (upstar_cfg.basics_addition or 0) / 10000
	local attr_list = Language.ShenYin.attr_list
	local base_attr = ShenYinData.Instance:GetItemBaseAttrCFGBySlotAndQuanlity(self.data.imprint_slot, self.data.quanlity)
	local cur_attr = CommonDataManager.GetOrderAttributte(base_attr)
	if cur_attr ~= nil and next(cur_attr) ~= nil then
		for k,v in pairs(cur_attr) do
			local text = ""
			if v.value > 0 then
				text = ToColorStr(v.value, TEXT_COLOR.GREEN_4)
				table.insert(had_base_attr, {key = v.key, value = text})
			end
			if upstar_attr[v.key] and upstar_attr[v.key] > 0 then
				text = ToColorStr(upstar_attr[v.key] + math.floor(math.ceil(v.value * rate)), TEXT_COLOR.GREEN_4) 
				table.insert(had_fuling_attr, {key = v.key, value = text})
			end
		end
	end

	if #had_base_attr > 0 then
		for k, v in ipairs(self.base_attr_list) do
			v.text_obj:SetActive(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				v.text_obj.text.text = string.format("%s:  <color=#6098CBFF>%s</color>", Language.Common.AttrName[had_base_attr[k].key], had_base_attr[k].value)
			end
		end
	end
	local show_fuling = self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot and #had_fuling_attr > 0 or (#had_fuling_attr > 0 and self.is_equip) 
	self.node_list["FuLingAttr"]:SetActive(show_fuling)
	if show_fuling then
		for k,v in pairs(self.fuling_attr_list) do
			v.text_obj:SetActive(had_fuling_attr[k] ~= nil)
			if had_fuling_attr[k] ~= nil then
				v.text_obj.text.text = string.format("%s:  <color=#6098CBFF>%s</color>", Language.Common.AttrName[had_fuling_attr[k].key], had_fuling_attr[k].value)
			end
		end
	end

	-- 附加属性(洗练属性)
	local total_value_attr = {}
	local fujia_attr_list = {}
	local attr_key_list = CommonDataManager.GetAttrKeyList()
	for k,v in pairs(slot_data.attr_param.value_list) do
		local text = ""
		if v > 0 and slot_data.attr_param.type_list[k] >= 0 then
			text = ToColorStr(v, TEXT_COLOR.GREEN_4)
			local key = attr_key_list[slot_data.attr_param.type_list[k] + 1]
			table.insert(total_value_attr, {key = Language.Common.AttrName[key], value = text})
			fujia_attr_list[key] = v
		end
	end
	--self.node_list["RandomTxt"]:SetActive(#total_value_attr > 0)
	if #total_value_attr > 0 then
		for k, v in ipairs(self.random_attr_list) do
			v.text_obj:SetActive(total_value_attr[k] ~= nil)
			if total_value_attr[k] ~= nil then
				v.text_obj.text.text = string.format("%s:  <color=#6098CBFF>%s</color>", total_value_attr[k].key, total_value_attr[k].value)
			end
		end
	end

	-- 套装属性
	local suit_attr_list = {}
	local suit_info = ShenYinData.Instance:GetSuitAttr()
	local suit_cfg = ShenYinData.Instance:GetItemSuitAttrBySuitId(self.data.suit_id)
	self.node_list["suit_attr"]:SetActive(false)
	if suit_cfg ~= nil and next(suit_cfg) ~= nil then
		self.node_list["suit_attr"]:SetActive(false)
		self.node_list["TitleTxt"].text.text = string.format("【%s】", suit_cfg[1].suit_name)
		local attr_list = Language.ShenYin.attr_list
		for k1, v1 in ipairs(suit_cfg) do
			local text_color = COLOR.WHITE
			local has_suit_num = suit_info[self.data.suit_id] or 0
			if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot and has_suit_num >= v1.count then
				text_color = TEXT_COLOR.GREEN_4
			end
			self.suit_attr_list[k1].suit_num.text.text = ToColorStr(string.format(Language.ShenYin.JianTao, v1.count, has_suit_num, v1.count), text_color)
			local attr_num = 0
			local cur_attr = CommonDataManager.GetOrderAttributte(v1)
			for k2, v2 in pairs(cur_attr) do
				if v2.value > 0 then
					local text = Language.Common.AttrName[v2.key] .. ":" .. v2.value
					-- suit_attr_list[k2] = v2
					attr_num = attr_num + 1
					local attr = self.suit_attr_list[k1].attr_list[attr_num]
					if attr then
						attr.attr_text.text.text = ToColorStr(text, text_color)
						attr.attr_text:SetActive(true)
					end
				end
			end
		end
	end

	local power = 0
	if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot or self.from_view == ShenYinYinJiTipView.FromView.ShenYinStrength then
		power = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilitySlot(self.data.imprint_slot))
	elseif self.from_view == ShenYinYinJiTipView.FromView.ShenYinBag or self.from_view == ShenYinYinJiTipView.FromView.ShenYinStore then
		power = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilityByData(self.data, false))
	end
	self.fight_text.text.text = power
	if 1 == self.data.item_type then
		local recycle_value = ShenYinData.Instance:GetShenYinShenRecycle(self.data.quanlity, self.data.suit_id ~= 0 and 1 or 0)
		self.node_list["RecycleTxt"].text.text = string.format("%s", recycle_value)
	end
	--self.node_list["RecyTxt"]:SetActive(1 == self.data.item_type)
	-- if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot or self.from_view == ShenYinYinJiTipView.FromView.ShenYinStrength then
	-- 	self.node_list["levelTxt"]:SetActive(true)
	-- 	self.node_list["levelTxt"].text.text = string.format(Language.ShenYin.JieXing, self.data.grade, self.data.level)
	-- 	--self.node_list["RandomTxt"]:SetActive(true)
	-- else
	-- 	self.node_list["levelTxt"]:SetActive(false)
	-- 	--self.node_list["RandomTxt"]:SetActive(false)
	-- end
	local shengyin_item_cfg = ShenYinData.Instance:GetItemIdCFGByVItemID(self.data.item_id)
	self.node_list["levelTxt"]:SetActive(true)
	self.node_list["levelTxt"].text.text = string.format(Language.ShenGe.ShenGeTypeName, shengyin_item_cfg.buwei or "" )
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	local handler_types = self:GetOperationState()
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self.node_list["RightBtn" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))

		else
			v.btn:SetActive(false)
		end
	end
	self.node_list["RightBtn"]:SetActive(not self.is_equip)
end

function ShenYinYinJiTip:GetOperationState()
	local t = {}
	if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot then
		t[#t + 1] = TipsHandleDef.HANDLE_ZHULING
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEOFF
		t[#t + 1] = TipsHandleDef.HANDLE_REPLACE
	elseif self.from_view == ShenYinYinJiTipView.FromView.ShenYinBag then
		t[#t + 1] = TipsHandleDef.HANDLE_EQUIP
		t[#t + 1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
	elseif self.from_view == ShenYinYinJiTipView.FromView.ShenYinStore then
		t[#t + 1] = TipsHandleDef.HANDLE_SHENYIN_LIEHUN_TAKBON
		t[#t + 1] = TipsHandleDef.HANDLE_SHENYIN_LIEHUN_RECOVER
	elseif self.from_view == ShenYinYinJiTipView.FromView.ShenYinStrength then

	end
	return t
end

function ShenYinYinJiTip:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end
	local call_back = function (data)
		if data then 
			ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_EQUIT, data.bag_index, data.imprint_slot)
		end
	end
	if handler_type == TipsHandleDef.HANDLE_EQUIP then --装备
		-- ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_EQUIT, self.data.bag_index, self.data.imprint_slot)
		PackageCtrl.Instance:SendUseItem(self.data.bag_index, 1)
	elseif handler_type == TipsHandleDef.HANDLE_TAKEOFF then --脱下
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_TAKE_OFF, self.data.imprint_slot)
	elseif handler_type == TipsHandleDef.HANDLE_ZHULING  then -- 注灵
		ShenYinCtrl.Instance:OpenShenYinQianghuaViewBySlot(self.data.imprint_slot)
	elseif handler_type == TipsHandleDef.HANDLE_RECOVER_SPIRIT then -- 回收
		-- ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_RECYCLE, self.data.bag_index, self.data.num)
		ShenYinCtrl.SendTianXiangOperate(11, self.data.bag_index, self.data.num)
	-- elseif handler_type == TipsHandleDef.HANDLE_SHENYIN_LIEHUN_TAKBON then --放入(神印-招印)，从0开始
	-- 	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.PUT_BAG, self.data.bag_index)
	-- elseif handler_type == TipsHandleDef.HANDLE_SHENYIN_LIEHUN_RECOVER then --回收(神印-招印)，从0开始
	-- 	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SINGLE_CONVERT_TO_EXP, self.data.bag_index)
	elseif handler_type == TipsHandleDef.HANDLE_REPLACE then --替换
		ShenYinCtrl.Instance:ShowSelectView(call_back, self.data)
	end
	self.parent:Close()
end

function ShenYinYinJiTip:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.is_tian_sheng = nil
end

function ShenYinYinJiTip:OnFlush(param_t)
	if self.data == nil then
		return
	end
	if self.node_list["Scroller"].scroll_rect then
		self.node_list["Scroller"].scroll_rect.normalizedPosition = Vector2(0, 1)
	end
	self:ShowTipContent()
	showHandlerBtn(self)
end

--设置显示弹出Tip的相关属性显示
function ShenYinYinJiTip:SetData(data, from_view, is_compare)
	if not data then
		print("数据等于空")
		return
	end
	self.data = data
	self.from_view = from_view

	self:LoadCell(data)

	self:Flush()
end

function ShenYinYinJiTip:LoadCell(data)
	self.current_all_suit = ShenYinData.Instance:GetTaoZhuangCfg()
	local count = 0
	local num = 0
	local current_shenyin_list_info = ShenYinData.Instance:GetMarkSlotInfo()
	local suit_name = ""
	self.data_list = {}
	if self.current_all_suit then
		for k, v in ipairs(self.current_all_suit) do
			if (data.quanlity == 5 and data.quanlity == v.quality + 1) or v.quality == data.quanlity then
				count = count + 1
				suit_name = v.name
				table.insert(self.data_list, v)
			end
		end
	end

	for k,v in pairs(self.data_list) do
		if k >= count and self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot then
			for k2, v2 in pairs(current_shenyin_list_info) do
				if (v2.quanlity == 5 and v2.quanlity - 1 == v.quality) or v2.quanlity == v.quality then
					num = num + 1
				end
			end
		end
	end

	self.node_list["SuitName"]:SetActive(suit_name ~= "")
	if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot then
		self.node_list["SuitName"].text.text = ToColorStr(string.format(Language.ShenYin.SuitName, suit_name, num, count * 2), TEXT_COLOR.ORANGE_5)
	else
		self.node_list["SuitName"].text.text = ToColorStr(string.format(Language.ShenYin.SuitName2, suit_name), TEXT_COLOR.ORANGE_5)
	end
	self.node_list["MingWenAttr"]:SetActive(count > 0)
	if count > 0 then
		local res_async_loader = AllocResAsyncLoader(self, "cell_res_async_loader")
		res_async_loader:Load("uis/views/hunqiview_prefab", "suitcell", nil, function (prefab)
			if not prefab then
				return 
			end
			if count > #self.cell_list then
				for i = #self.cell_list, count - 1 do
					local obj = ResMgr:Instantiate(prefab)
					local cell = ShenYinTipInfoCell.New(obj.gameObject)
					cell:SetInstanceParent(self.node_list["SuitAttrText"], false)
					table.insert(self.cell_list, cell)
				end
			end
			for k, v in pairs(self.cell_list) do
				v:SetData(self.data_list[k], self.from_view)
			end
		end)
	end
end

--------------------------ShenYinTipInfoCell-----------------------------
ShenYinTipInfoCell = ShenYinTipInfoCell or BaseClass(BaseCell)
function ShenYinTipInfoCell:__init()
	self.from_view = 0
end

function ShenYinTipInfoCell:__delete()

end

function ShenYinTipInfoCell:SetData(data, from_view)
	self.data = data
	self.from_view = from_view or 0

	self:Flush()
end

function ShenYinTipInfoCell:OnFlush()
	if self.data == nil then
		self.node_list["suitcell"]:SetActive(false)
		return
	end
	self.node_list["suitcell"]:SetActive(true)
	local num = 0
	local current_shenyin_list_info  = ShenYinData.Instance:GetMarkSlotInfo()
	if self.from_view == ShenYinYinJiTipView.FromView.ShenYinSlot then
		for k, v in pairs(current_shenyin_list_info) do
			if (v.quanlity == 5 and v.quanlity - 1 == self.data.quality) or v.quanlity == self.data.quality then
				num = num + 1
			end
		end
	end

	local color = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.WHITE
	local color1 = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.LightBlue
	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.need_count), color) 
	self.node_list["TxtAttr_1"].text.text = string.format(Language.HunQi.AttrList[1], color, self.data.gongji )
	self.node_list["TxtAttr_2"].text.text = string.format(Language.HunQi.AttrList[2], color, self.data.fangyu)
	self.node_list["TxtAttr_3"].text.text = string.format(Language.HunQi.AttrList[3], color, self.data.maxhp)
	self.node_list["TxtAttr_4"].text.text = string.format(Language.HunQi.AttrList[4], color, self.data.mingzhong)
	self.node_list["TxtAttr_5"].text.text = string.format(Language.HunQi.AttrList[5], color, self.data.shanbi)
	self.node_list["TxtAttr_6"].text.text = string.format(Language.HunQi.AttrList[6], color, self.data.baoji)
	self.node_list["TxtAttr_7"].text.text = string.format(Language.HunQi.AttrList[7], color, self.data.jianren)
	-- self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color, self.data.per_hunshi / 100)
	self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color, self.data.per_gongji / 100)
	self.node_list["TxtAttr_9"].text.text = string.format(Language.HunQi.AttrList[9], color, self.data.per_fangyu / 100)
	self.node_list["TxtAttr_10"].text.text = string.format(Language.HunQi.AttrList[10], color, self.data.per_maxhp / 100)
	self.node_list["TxtAttr_11"].text.text = string.format(Language.HunQi.AttrList[11], color, self.data.skill_jianshang_per / 100)

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji and self.data.gongji > 0 or false)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu and self.data.fangyu > 0 or false)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp and self.data.maxhp > 0 or false)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong and self.data.mingzhong > 0 or false)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi and self.data.shanbi > 0 or false)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji and self.data.baoji > 0 or false)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren and self.data.jianren > 0 or false)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_gongji and self.data.per_gongji > 0 or false)
	-- self.node_list["AttrGroup8"]:SetActive(self.data.per_hunshi and self.data.per_hunshi > 0 or false)
	self.node_list["AttrGroup9"]:SetActive(self.data.per_fangyu and self.data.per_fangyu > 0 or false)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_maxhp and self.data.per_maxhp > 0 or false)
	self.node_list["AttrGroup11"]:SetActive(self.data.skill_jianshang_per and self.data.skill_jianshang_per > 0 or false)
end