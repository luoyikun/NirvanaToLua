ShenShouEquipTip = ShenShouEquipTip or BaseClass(BaseView)

ShenShouEquipTip.FromView = {
	ShenShouView = 1,
	ShenShouEquipView = 2,
	ShenShouBagView = 3,
	ShenShouComposeView = 4,
}

function ShenShouEquipTip:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "ShenShouEquipTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenShouEquipTip:__delete()

end

function ShenShouEquipTip:ReleaseCallBack()
	if self.equip_tips then
		self.equip_tips:DeleteMe()
		self.equip_tips = nil
	end
	if self.equip_compare_tips then
		self.equip_compare_tips:DeleteMe()
		self.equip_compare_tips = nil
	end
end

function ShenShouEquipTip:LoadCallBack()
	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.equip_tips = ShenshouEquipLeftTip.New(self.node_list["EquipTip"], self)
	self.equip_tips.is_mine = true
	self.equip_tips:SetActive(false)

	self.equip_compare_tips = ShenshouEquipLeftTip.New(self.node_list["EquipCompareTip"], self)
end

function ShenShouEquipTip:CloseCallBack()
	self.equip_tips:CloseCallBack()
	self.equip_compare_tips:CloseCallBack()
end

function ShenShouEquipTip:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.shou_id, self.data_cache.close_call_back, self.data_cache.is_tian_sheng)
		self.data_cache = nil
		self:Flush()
	end
end

--设置显示弹出Tip的相关属性显示
function ShenShouEquipTip:SetData(data, from_view, shou_id, close_call_back, is_tian_sheng)
	if not data then
		return
	end

	from_view = from_view or ShenShouEquipTip.FromView.ShenShouView
	if self:IsOpen() then
		self.equip_compare_tips:SetData(data, from_view, shou_id, close_call_back, is_tian_sheng)

		local equip_cell_data = ShenShouData.Instance:GetOneSlotData(shou_id, data.slot_index)
		if from_view == ShenShouEquipTip.FromView.ShenShouBagView and nil ~= equip_cell_data and equip_cell_data.item_id > 0 then
			self.equip_tips:SetActive(true)
			self.equip_tips:SetData(equip_cell_data, ShenShouEquipTip.FromView.ShenShouEquipView, shou_id)
		else
			self.equip_tips:SetActive(false)
		end
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, shou_id = shou_id, close_call_back = close_call_back, is_tian_sheng = is_tian_sheng,}
		self:Open()
	end

	self.from_view = from_view
end

function ShenShouEquipTip:OnFlush(param_t)
	self.equip_tips:OnFlush(param_t)
	self.equip_compare_tips:OnFlush(param_t)
end

--=========item====================

ShenshouEquipLeftTip = ShenshouEquipLeftTip or BaseClass(BaseRender)

function ShenshouEquipLeftTip:__init(instance, parent)
	self.parent = parent
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.shou_id = 0
	self.buttons = {}
	-- 功能按钮
	self.equip_item = ShenShouEquip.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])

	for i = 1, 5 do
		local button = self.node_list["RightBtn"]:FindObj("Btn" .. i)
		local btn_text = self.node_list["RightBtn"]:FindObj("Btn" .. i .. "/Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	for i = 1, 3 do
		self.base_attr_list[i] = {
			attr_text = self.node_list["TxtBaseAttr" .. i],
		}

		self.special_attr_list[i] = {
			attr_text = self.node_list["TxtSpecialCasAttr" .. i],
		}

		self.random_attr_list[i] = {
			attr_text = self.node_list["TxtRandomAttr" .. i],
		}
	end
	self.scroller_rect = self.node_list["Scroller"].scroll_rect

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightText"], "FightPower3")
end

function ShenshouEquipLeftTip:__delete()
	self.fight_text = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.buttons = nil
	self.parent = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function ShenshouEquipLeftTip:ShowTipContent()
	local item_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if item_cfg == nil then
		return
	end

	local bundle, sprite = ResPath.GetQualityRawBgIcon(item_cfg.quality + 1)
	self.node_list["QualityImage"].raw_image:LoadSprite(bundle, sprite)
	self.node_list["Kuang"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.quality + 1))
	self.node_list["Line"].image:LoadSprite(ResPath.GetQualityTopBg(item_cfg.quality + 1))

	local item_name = item_cfg.name
	self.node_list["TxtEquaipName"].text.text = item_name

	local equip_type = Language.ShenShou.ZhuangBeiLeiXing[item_cfg.slot_index] or ""
	self.node_list["TxtTitle1"].text.text = string.format(Language.ShenShou.EquipType, equip_type)

	local attr_list = ShenShouData.Instance:GetShenshouBaseList(item_cfg.slot_index, item_cfg.quality)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(attr_list)
	local cur_attr = CommonDataManager.GetOrderAttributte(base_attr_list)
	local base_capability = CommonDataManager.GetCapability(attr_list)      							-- 装备基础评分
	local qh_shenshou_cfg = ShenShouData.Instance:GetShenshouLevelList(item_cfg.slot_index, self.data.strength_level)
	local qh_attr_struct = CommonDataManager.GetAttributteByClass(qh_shenshou_cfg)
	local strengthen_capability = CommonDataManager.GetCapability(qh_attr_struct)   	-- 锻造总评分
	local cur_shou_id = self.shou_id
	local bestattr_capability = 0
	if self.data.attr_list then
		-- bestattr_capability = ShenShouData.Instance:GetShenShouEqCapability(self.data.attr_list, cur_shou_id, self.data)   -- 极品属性追加总评分
	end
	local zhuangbei_pingfen = base_capability + strengthen_capability  					-- 装备评分
	local zonghe_pingfen = zhuangbei_pingfen + bestattr_capability 						-- 装备综合评分
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = zonghe_pingfen
	end
	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local had_base_attr = {}
	for k, v in pairs(cur_attr) do
		if v.value > 0 then
			table.insert(had_base_attr, {key = v.key, value = v.value})
		end
	end
	local qh_attr_struct_no_line = CommonDataManager.GetGoddessAttributteNoUnderline(qh_shenshou_cfg)

	local had_qh_attr = {}
	for k,v in pairs(qh_attr_struct_no_line) do
		if v > 0 then 
			table.insert(had_qh_attr, {key = k, value = v})
		end
	end
	-- 基础
	if #had_base_attr > 0 then
		for k, v in ipairs(self.base_attr_list) do
			v.attr_text:SetActive(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				local name = Language.Common.AttrName[had_base_attr[k].key]
				local add_value = qh_attr_struct[v] and math.floor(qh_attr_struct[v]) or 0
				local value = had_base_attr[k].value
				v.attr_text.text.text = string.format("%s：<color=#00ff47ff>%s</color>", name, value)
			end
		end
	end
	if #had_qh_attr > 0 then 
		self.node_list["QHAttr"]:SetActive(true)
		for i = 1, 3 do
			self.node_list["QHAttr_" .. i]:SetActive(had_qh_attr[i] ~= nil)
			if had_qh_attr[i] ~= nil then 
				local name = CommonDataManager.GetAttrName(had_qh_attr[i].key)
				local value = had_qh_attr[i].value
				self.node_list["QHAttr_" .. i].text.text = string.format("%s：<color=#00ff47ff>%s</color>", name, value)
			end
		end
	else
		self.node_list["QHAttr"]:SetActive(false)
		for i = 1, 3 do
			self.node_list["QHAttr_" .. i]:SetActive(false)
		end
	end
	if self.data.attr_list then
	    --卓越属性
		-- self.node_list["PamelSpecialAttr"]:SetActive(true)
		-- self.node_list["ImgRandomthenAttr"]:SetActive(false)

		local spec_index = 1
		if self.data.attr_list then
			for k,v in pairs(self.data.attr_list) do
				if v.attr_type > 0 then
					local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
					local add_value = add_per_t[v.attr_type] and v.attr_value / 100 .. "%" or v.attr_value
					local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(item_cfg.quality, v.attr_type) or {}
					local color = random_cfg.is_star_attr == 1 and "#F82CFF" or "#00ffff"
					if self.special_attr_list[spec_index] then
						self.special_attr_list[spec_index].attr_text:SetActive(true)
						self.special_attr_list[spec_index].attr_text.text.text = string.format("<color='%s'>%s</color>", color, random_cfg.attr_show .. "+" ..  add_value)
						spec_index = spec_index + 1
					end
				end
			end
		end
	else
		-- 随机属性
		-- self.node_list["PamelSpecialAttr"]:SetActive(false)
		-- self.node_list["ImgRandomthenAttr"]:SetActive(true)

		local rand_index = 1
		local legend_num = self.data.param and self.data.param.star_level or 0
		local legend_attr_list = ShenShouData.Instance:GetRanAttrList(item_cfg.quality, legend_num)
		-- self.node_list["TxtRandomAttr"].text.text = string.format(Language.ShenShou.EquipRandAttr, legend_num)
		for k,v in pairs(legend_attr_list) do
			if v.attr_type > 0 then
				local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
				local add_value = add_per_t[v.attr_type] and v.attr_value / 100 .. "%" or v.attr_value
				local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(item_cfg.quality, v.attr_type) or {}
				local color = "#F82CFF"
				if self.random_attr_list[rand_index] then
					self.random_attr_list[rand_index].attr_text:SetActive(true)
					self.random_attr_list[rand_index].attr_text.text.text = string.format("<color='%s'>%s</color>", color, random_cfg.attr_show .. "+" ..  add_value)
					rand_index = rand_index + 1
				end
			end
		end
	end

	self.node_list["NodeStorgeScore"]:SetActive(false)
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil or self.from_view == ShenShouEquipTip.FromView.ShenShouComposeView then
		for k,v in pairs(self.buttons) do
			v.btn:SetActive(false)
		end

		return
	end
	local handler_types = self:GetOperationState()
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = Language.Tip.ButtonLabel[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			self.node_list["Btn" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function ShenshouEquipLeftTip:GetOperationState()
	local t = {}
	if self.from_view == ShenShouEquipTip.FromView.ShenShouView then
		t[#t+1] = TipsHandleDef.HANDLE_REPLACE
		t[#t+1] = TipsHandleDef.HANDLE_LONGSHI
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	elseif self.from_view == ShenShouEquipTip.FromView.ShenShouEquipView then
		if not self.is_mine then
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		end
	elseif self.from_view == ShenShouEquipTip.FromView.ShenShouBagView then
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
	end

	return t
end

function ShenshouEquipLeftTip:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if nil == shenshou_equip_cfg then return end
	if handler_type == TipsHandleDef.HANDLE_EQUIP then --装备
		-- ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_PUT_ON, self.shou_id, self.data.index, shenshou_equip_cfg.slot_index)
		PackageCtrl.Instance:SendUseItem(self.data.index, nil,  self.shou_id)
	elseif handler_type == TipsHandleDef.HANDLE_TAKEOFF then --脱下
		if ShenShouData.Instance:IsShenShouZhuZhan(self.shou_id) then
			local func = function()
				ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.shou_id, shenshou_equip_cfg.slot_index)
				self.parent:Close()
			end
			TipsCtrl.Instance:ShowCommonAutoView("", Language.ShenShou.TakeOffEquipTips, func)
			return
		else
			ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.shou_id, shenshou_equip_cfg.slot_index)
		end
	elseif handler_type == TipsHandleDef.HANDLE_LONGSHI then
		ShenShouFulingView.CACHE_SHOW_ID = self.shou_id
		ShenShouFulingView.CACHE_SOLT_INDEX = shenshou_equip_cfg.slot_index
		ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_fuling)
	elseif handler_type == TipsHandleDef.HANDLE_REPLACE then
		ShenShouCtrl.Instance:OpenShenShouBag(self.shou_id, shenshou_equip_cfg.slot_index + 1)
	end
	
	self.parent:Close()
end

--关闭装备Tip
function ShenshouEquipLeftTip:OnClickCloseButton()
	self.parent:Close()
end

function ShenshouEquipLeftTip:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.is_tian_sheng = nil
	self.shou_id = 0
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function ShenshouEquipLeftTip:OnFlush(param_t)
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
function ShenshouEquipLeftTip:SetData(data,from_view, shou_id, close_call_back, is_tian_sheng)
	if not data then
		print("数据等于空")
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
	self.from_view = from_view
	self.shou_id = shou_id or 0
	self:Flush()
end