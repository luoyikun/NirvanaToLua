local CommonFunc = require("game/tips/tips_common_func")
TipsMojieView = TipsMojieView or BaseClass(BaseView)

function TipsMojieView:__init()
	self.ui_config = {{"uis/views/tips/equiptips_prefab", "MojieTip"}}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_handle = {}
	self.is_modal = true
	self.play_audio = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsMojieView:__delete()
end

function TipsMojieView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	if self.equip_item ~= nil then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	for k, v in pairs(self.base_attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.base_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil

	for k,v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	-- 清理变量和对象
	self.buttons = {}
	self.scroller_rect = nil
end

function TipsMojieView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsMojieView:OpenCallBack()
end

function TipsMojieView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])

	for i =1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = self.node_list["TxtBtn" .. i]
		self.buttons[i] = {btn = button, text = btn_text}
	end

	for i = 1, 6 do
		self.base_attr_list[i] = self.node_list["BaseAttr" .. i]
	end
	self.scroller_rect = self.node_list["Scroller"].scroll_rect
	self.node_list["PanelShowRecycle"]:SetActive(false)
end

function TipsMojieView:HandelAttrs(data, table)
	for i = 1, #table do
		table[i].gameObject:SetActive(false)
	end
	local count = 1
	for k,v in ipairs(CommonDataManager.attrview_t) do
		local key = nil
		local value = data[v[2]]
		if value > 0 then
			key = CommonDataManager.GetAttrName(v[2])
		end
		if key ~= nil then
			local attr = table[count]
			if attr then
				attr.gameObject:SetActive(true)
				local obj = attr.gameObject
				attr.text.text = key .. ": " .. ToColorStr(value, TEXT_COLOR.BLUE_1)
				count = count + 1
			else
				break
			end
		end
	end
end

function TipsMojieView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	self.node_list["PanelShowWearIcon"]:SetActive(self.data.mojie_level > 0)
	local name = MojieData.Instance:GetMojieName(self.data.index - 1, self.data.mojie_level)
	local name_str = string.format("<color=#34ACF3FF>%s</color>", name)
	self.node_list["TxtEquaipName"].text.text = name_str
	self.node_list["TxtEquipType"].text.text = Language.Mojie.Mojie

	local color = nil
	local bundle, sprite = ResPath.GetQualityRawBgIcon(item_cfg.color)
	self.node_list["ImgQuality"].raw_image:LoadSprite(bundle, sprite, function()
		self.node_list["ImgQuality"]:SetActive(true) end)
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
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_str = vo.level >= item_cfg.limit_level and string.format(Language.Role.XXJi, item_cfg.limit_level)
	self.node_list["TxtEquipLevel"].text.text = level_str
	local prof_str = Language.Common.AllProf
	self.node_list["TxtEquipProf"].text.text = prof_str
	self.equip_item:SetData(self.data, true)

	--基础、
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.data.index - 1, self.data.mojie_level) or {}
	self.node_list["PanelShowBaseAttr"]:SetActive(self.data.mojie_level > 0)
	self.node_list["BaseAttrs"]:SetActive(self.data.mojie_level > 0)
	
	local base_result = CommonDataManager.GetAttributteByClass(ring_cfg)
	self:HandelAttrs(base_result, self.base_attr_list)
	self.node_list["TxtFightNumber"].text.text = CommonDataManager.GetCapability(base_result)

	local _, skill_level, skill_id, _ = MojieData.Instance:GetMojieOpenLevel(self.data.index - 1)
	self.node_list["SkillDecs"].text.text = SkillData.RepleCfgContent(skill_id, self.data.mojie_skill_level > 0 and self.data.mojie_skill_level or skill_level)
end

function TipsMojieView:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
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
		local tx = Language.Tip.ButtonLabel[handler_type]
		if handler_type == 23 then
			--显示回收值
			self.node_list["PanelShowRecycle"]:SetActive(true)
		end

		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
				self.button_handle[k] = nil
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

local function showSellViewState(self)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then
		return
	end
	local salestate = CommonFunc.IsShowSellViewState(self.from_view)
end

function TipsMojieView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
	showSellViewState(self)
end

function TipsMojieView:OnClickHandle(handler_type)
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

--设置显示弹出Tip的相关属性显示
function TipsMojieView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	self.close_call_back = close_call_back
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
		if self.data.param == nil then
			self.data.param = CommonStruct.ItemParamData()
		end
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end