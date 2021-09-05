-- 仙宠-仙宠命魂-SoulContent
SpiritSoulView = SpiritSoulView or BaseClass(BaseRender)

local MAX_NUM = 72
local ROW = 3
local COLUMN = 4

local SOUL_SLOT_NUM = 8		-- 命魂槽数量

function SpiritSoulView:__init(instance)
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnMingHunAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAttrsBtn, self))
	self.node_list["BtnMingHunTuJian"].button:AddClickListener(BindTool.Bind(self.OnClickHandbook, self))
	self.node_list["BtnFenJie"].button:AddClickListener(BindTool.Bind(self.OnClickSoulResolve, self))
	self.node_list["BtnYiJian"].button:AddClickListener(BindTool.Bind(self.OnClickSoulUpGrade, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSoulNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSoulBagCell, self)

	self.page_toggle_list = {}
	for i = 1, 6 do
		self.page_toggle_list[i] = self.node_list["PageToggle" .. i].toggle
	end

	self.dress_soul_items = {}
	for i = 1, SOUL_SLOT_NUM do
		self.dress_soul_items[i] = SpiritDressSoulItem.New(self.node_list["DressItem"..i])
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["zhanliTxt"])

	self.cur_click_slot_index = -1

	self.soul_items = {}
end

function SpiritSoulView:__delete()
	for k, v in pairs(self.soul_items) do
		v:DeleteMe()
	end
	self.soul_items = {}

	self.cur_click_slot_index = nil

	for k, v in pairs(self.dress_soul_items) do
		v:DeleteMe()
	end
	self.dress_soul_items = {}
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	self.fight_text = nil
	self.res_id = nil
end

function SpiritSoulView:OnClickSoulResolve()
	ViewManager.Instance:Open(ViewName.SpiritSoulResolveView)
end

function SpiritSoulView:OnClickSoulUpGrade()
	SpiritData.Instance:SetSoulIsPlayEffect(true)
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.LIEMING_HUNSHOU_OPERA_TYPE_AUTO_UPLEVEL)
end

function SpiritSoulView:OnClickHandbook()
	ViewManager.Instance:Open(ViewName.SoulHandBook)
end

function SpiritSoulView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.res_id = nil
end

function SpiritSoulView:GetSoulNumberOfCells()
	return MAX_NUM / ROW
end

function SpiritSoulView:RefreshSoulBagCell(cell, data_index)
	local group = self.soul_items[cell]
	local bag_list = SpiritData.Instance:GetAllSoulInfo()
	-- local bag_list = SpiritData.Instance:GetAllSoulInfoBySelectIndex(self.cur_click_slot_index)
	if nil == group then
		group = SpiritSoulItemGroup.New(cell.gameObject)
		self.soul_items[cell] = group
	end
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW

	for i = 1, ROW do
		local index = (i -1) * COLUMN + column + (page * grid_count) + 1

		if bag_list[index] then
			if group:GetData(i) and group:GetData(i).id == bag_list[index].id then
				group:IsDestroyEffect(i, false)
			else
				group:IsDestroyEffect(i, true)
			end
			group:SetData(i, bag_list[index])
			group:ListenClick(i, BindTool.Bind(self.OnClickBagSoulItem, self, index))
		else
			group:IsDestroyEffect(i, true)
			group:SetData(i, nil)
		end
	end
end

-- 打开总属性面板
function SpiritSoulView:OnClickAttrsBtn()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local temp_attr_list = CommonDataManager.GetAttributteNoUnderline()
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.item_id > 0 then
				local cfg = SpiritData.Instance:GetSoulCfgById(v.item_id)
				local level = v.param and v.param.strengthen_level or 0
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.item_id, level) or {}
				if SOUL_ATTR_NAME_LIST[cfg.hunshou_type] and temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
				end
			end
		end
	end
	TipsCtrl.Instance:ShowAttrView(temp_attr_list, true)
end


-- 背包命魂格子
function SpiritSoulView:OnClickBagSoulItem(index)
	if index == nil then return end
	-- local bag_list = SpiritData.Instance:GetAllSoulInfoBySelectIndex(self.cur_click_slot_index)
	local bag_list = SpiritData.Instance:GetAllSoulInfo()
	local data = bag_list and bag_list[index] or nil
	if nil == data or nil == next(data) then return end
	if data.id <= 0 then return end
	TipsCtrl.Instance:ShowSpiritSoulPropView(data, SOUL_FROM_VIEW.SOUL_BAG)
end

function SpiritSoulView:FlushBagView()
	 if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

function SpiritSoulView:JumpToPage(page)
	page = page or 1
	local jump_index = 0
	local scrollerOffset = 0
	local cellOffset = 0
	local scrollerTweenType = self.node_list["ListView"].scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = function()
		self.current_page = page
	end
	self.node_list["ListView"].scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	self.page_toggle_list[1].isOn = true
end

function SpiritSoulView:OnClickHelp()
	local tip_id = 41
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 点击命魂槽
function SpiritSoulView:OnClickSlotSoul(index, is_lock)
	if nil == index then return end

	self.cur_click_slot_index = index
	local slot_list = SpiritData.Instance:GetSpiritSlotSoulInfo().slot_list
	local data = slot_list and slot_list[index] or {}
	local hunge_activity_condition = ConfigManager.Instance:GetAutoConfig("lieming_auto").hunge_activity_condition
	if is_lock then
		local msg = ""
		if index == 8 then
			msg = Language.JingLing.NoOpen
		else
			if hunge_activity_condition ~= nil and hunge_activity_condition[index + 1] ~= nil then
				local level = hunge_activity_condition[index + 1].role_level
				msg = string.format(Language.JingLing.SoulSlotOpenAdition, PlayerData.GetLevelString(level))
			end
		end
		TipsCtrl.Instance:ShowSystemMsg(msg)
		return
	end

	data.id = data.item_id
	data.level = data.param.strengthen_level
	data.exp = data.param.param1
	data.slot_index = index

	if nil == data.id or data.id <= 0 then 
		return 
	end

	local callback = function()
		self.cur_click_slot_index = -1
	end
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback)
end

-- 刷新弹出Tip数据
function SpiritSoulView:FlushSlotSoulTip()
	if -1 >= self.cur_click_slot_index then return end

	local slot_list = SpiritData.Instance:GetSpiritSlotSoulInfo().slot_list
	local data = slot_list and slot_list[self.cur_click_slot_index] or {}
	
	data.id = data.item_id
	data.level = data.param.strengthen_level
	data.exp = data.param.param1
	data.slot_index = self.cur_click_slot_index

	if nil == data.item_id or data.item_id <= 0 then 
		return
	end
	
	local callback = function()
		self.cur_click_slot_index = -1
	end
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback)
end

function SpiritSoulView:SetModel()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if not spirit_info or not spirit_info.use_jingling_id or not spirit_info.jingling_list then return end

	if spirit_info.use_jingling_id > 0 then
		local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(spirit_info.use_jingling_id)
		self:SetModelShow(spirit_cfg)
	elseif spirit_info.use_jingling_id <= 0 and next(spirit_info.jingling_list) then
		local spirit_cfg = nil
		for k, v in pairs(spirit_info.jingling_list) do
			spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(v.item_id)
			break
		end
		self:SetModelShow(spirit_cfg)
	else
		local item_id = 15001
		local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(item_id)
		self:SetModelShow(spirit_cfg)
	end
end

-- 模型展示
function SpiritSoulView:SetModelShow(spirit_cfg)
	if nil == spirit_cfg then return end
	if spirit_cfg.res_id and spirit_cfg.res_id > 0 then
		if spirit_cfg.res_id ~= self.res_id then
			PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			-- 展示场景特效
			UIScene:LoadSceneEffect(bundle, asset)
			local load_list = {{bundle, asset}}
			self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetTrigger(ANIMATOR_PARAM.REST)
				end
			end
			self.res_id = spirit_cfg.res_id
		end
	end
end

function SpiritSoulView:OnFlush()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	if slot_soul_info and next(slot_soul_info) then
		local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
		for k, v in pairs(self.dress_soul_items) do
			local id = slot_soul_info.slot_list[k - 1].item_id or -1
			local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(id, slot_soul_info.slot_list[k - 1].param.strengthen_level)
			local data = {}
			data.is_lock = (bit_list and bit_list[32 - k] or 0) ~= 1
			data.show_level = (slot_soul_info.slot_list[k - 1] and slot_soul_info.slot_list[k - 1].param.strengthen_level or 0) > 0
			data.level = slot_soul_info.slot_list[k - 1].param.strengthen_level or 0
			data.name = ""
			data.id = slot_soul_info.slot_list[k - 1].item_id or 0
			data.exp = slot_soul_info.slot_list[k - 1].param.param1 or 0
			data.index = slot_soul_info.slot_list[k - 1].index or 0
			
			-- 是否显示可以升级红点
			if nil ~= attr_cfg  and slot_soul_info.total_exp and slot_soul_info.slot_list[k - 1].param.param1 then
				local exp = slot_soul_info.total_exp >= attr_cfg.exp - slot_soul_info.slot_list[k - 1].param.param1
				local max_level = SpiritData.Instance:GetSoulCfgMaxLevel()
				local level = data.level ~= max_level
				data.show_redpoint = exp and level
			else
				data.show_redpoint = false
			end

			local soul_cfg = SpiritData.Instance:GetSoulCfgById(data.id)
			if soul_cfg then
				if SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type] then
					local name = Language.Common.AttrNameNoUnderline[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]]
					local str = "<color=" .. SOUL_NAME_COLOR[soul_cfg.hunshou_color] .. ">" .. name .. "</color>"
					data.name = str
				end
			end

			v:SetData(data)
			if not v:GetEffectId() or v:GetEffectId() ~= id then
				v:LoadEffect(id)
			end
			v:ListenClick(BindTool.Bind(self.OnClickSlotSoul, self, k - 1, data.is_lock))
		end

		local slot_soul_result_info = SpiritData.Instance:GetSpiritSlotSoulResult()
		local is_get_finish =  SpiritData.Instance:GetSpiritSlotSoulIsFinish()
		local is_play = SpiritData.Instance:GetSoulIsPlayEffect()
		if slot_soul_result_info and is_play and is_get_finish == 1 then
			SpiritData.Instance:SetSoulIsPlayEffect(false)
			for k, v in pairs(self.dress_soul_items) do
				for k1, v1 in pairs(slot_soul_result_info) do
					if k - 1 == k1 and v1 == 1 then
						v:SetUpStarEffect()
						SpiritData.Instance:ClearSpiritSlotSoulEffectResult(k - 1)
					end
				end
			end
		end
	else
		for k, v in pairs(self.dress_soul_items) do
			local data = {}
			data.is_lock = true
			data.show_redpoint = false
			data.level = 0
			data.name = ""
			data.index = 0
			v:SetData(data)
			v:LoadEffect(-2)
		end
	end
	local total_exp = slot_soul_info and slot_soul_info.total_exp or 0
	self.node_list["TxtTotalHunLi"].text.text = string.format(Language.JingLing.TotalExp, total_exp)
	local vo = GameVoManager.Instance:GetMainRoleVo()

	self:FlushBagView()
	self:FlushSlotSoulTip()
	self:SetModel()
	RemindManager.Instance:Fire(RemindName.SpiritSoul)

	if slot_soul_info.notify_reason == LIEMING_BAG_NOTIFY_REASON.LIEMING_BAG_NOTIFY_REASON_BAG_MERGE then
		self:JumpToPage()
	end

	-- 计算战力
	local base_attr = CommonDataManager.GetAttributteNoUnderline() or {}
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.item_id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.item_id)
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.item_id, v.param.strengthen_level) or {}
				if cfg and cfg.hunshou_type and base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] and attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					local single_attr = attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
					base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = base_attr[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + single_attr
				end
			end
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(base_attr)
	end
end

-- 命魂界面动画效果
function SpiritSoulView:UITween()
	UITween.MoveShowPanel(self.node_list["TopPanel"], Vector3(0, 430, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(0, -500, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BackpackView"], Vector3(400, 3.5, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["CenterPanel"], true, 0.5, DG.Tweening.Ease.InExpo)
end

------------------------------------------------------------------
-- 3个长度的命魂格子组，在命魂背包
SpiritSoulItemGroup = SpiritSoulItemGroup or BaseClass(BaseRender)

function SpiritSoulItemGroup:__init(instance)
	self.items = {}

	for i = 1, 3 do
		self.items[i] = SpiritSoulItem.New(self.node_list["SoulItem" .. i])
	end
end

function SpiritSoulItemGroup:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function SpiritSoulItemGroup:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function SpiritSoulItemGroup:SetData(i, data)
	self.items[i]:SetData(data)
end

function SpiritSoulItemGroup:IsDestroyEffect(i, enable)
	self.items[i]:IsDestroyEffect(enable)
end

function SpiritSoulItemGroup:GetData(i)
	return self.items[i]:GetData()
end

------------------------------------------------------------------------------------------------
-- 穿着的命魂格子
SpiritDressSoulItem = SpiritDressSoulItem or BaseClass(BaseRender)

function SpiritDressSoulItem:__init(instance)
	self.effect = nil
	self.is_load = false
	self.is_stop_load_effect = false
end

function SpiritDressSoulItem:__delete()
	self.is_load = nil
	if self.effect then
		ResMgr:Destroy(self.effect)
		self.effect = nil
	end
	self.id = nil
end

function SpiritDressSoulItem:ListenClick(handler)
	self.node_list["SpecialNode"].button:AddClickListener(handler)
end

function SpiritDressSoulItem:SetData(data)
	self.node_list["SpecialTxt"].text.text = data.level
	self.node_list["ImgLv"]:SetActive(data.show_level)
	self.node_list["LockTxt"]:SetActive(data.is_lock)
	self.node_list["SpecialImg"]:SetActive(data.show_redpoint)
	self.node_list["NameBg"]:SetActive(data.show_level)
	self.node_list["TxtName"].text.text = data.name
	self.index = data.index

	-- local is_show = data.id <= 0 
	local is_has_other = SpiritData.Instance:GetSpiritHasOtherBetterSoulById(data.id)
	self.node_list["UpArrow"]:SetActive(is_has_other)
end

-- function SpiritDressSoulItem:PlayEffect()
-- 	local slot_soul_result_info = SpiritData.Instance:GetSpiritSlotSoulResult()
-- 	if slot_soul_result_info then
-- 		for k, v in pairs(slot_soul_result_info) do
-- 			if k == self.index and v == 1 then
-- 				self:SetUpStarEffect()
-- 				SpiritData.Instance:ClearSpiritSlotSoulEffectResult(k)
-- 			end
-- 		end
-- 	end
-- end

function SpiritDressSoulItem:LoadEffect(id)
	self.id = id
	local cfg = SpiritData.Instance:GetSoulCfgById(id)

	if self.effect then
		ResMgr:Destroy(self.effect)
		self.effect = nil
	elseif self.is_load and id < 0 then
		self.is_stop_load_effect = true
	end

	if id == GameEnum.HUNSHOU_EXP_ID then
		cfg = {name = Language.JingLing.ExpHun, hunshou_color = 1, hunshou_effect = "minghun_g_01"}
	end
	if cfg then
		if cfg.hunshou_effect and not self.effect and not self.is_load then
			self.is_load = true

			local async_loader = AllocAsyncLoader(self, "effect_loader")
			local bundle_name, asset_name = ResPath.GetUiJingLingMingHunResid(cfg.hunshou_effect)
			async_loader:Load(bundle_name, asset_name, function (obj)
				if IsNil(obj) then
					return
				end

				if self.is_stop_load_effect then
					self.is_stop_load_effect = false
					return
				end

				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				self.effect = obj.gameObject
				self.is_load = false
			end)
		end
	end
end

function SpiritDressSoulItem:SetUpStarEffect()
	local async_loader = AllocAsyncLoader(self, "effect_2")
	local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
	async_loader:Load(bundle_name, asset_name, 
		function (obj)
			if not IsNil(obj) then
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				GlobalTimerQuest:AddDelayTimer(function()
					ResMgr:Destroy(obj)
				end, 1)
			end
		end)
end


function SpiritDressSoulItem:GetEffectId()
	return self.id
end