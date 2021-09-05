-- 仙女信息 幻化界面 GoddessHuanHuaView
GoddessHuanHuaView = GoddessHuanHuaView or BaseClass(BaseView)

function GoddessHuanHuaView:__init()
	self.ui_config = {
		{"uis/views/goddess_prefab", "ModelDragLayer"},
		{"uis/views/goddess_prefab", "GoddessHuanHuaView"},	
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.def_index = TabIndex.goddess_huanhua
	self.play_audio = true
	self.full_screen = true

	self.prefab_preload_id = 0
	self.model_xiannv_id = -1
end

function GoddessHuanHuaView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = "uis/images_atlas", asset = "tab_icon_goddess_info", tab_index = TabIndex.goddess_huanhua, remind_id = RemindName.Goddess_HuanHua},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ShowIndex, self))

	self.node_list["RotateEventTrigger"].event_trigger_listener:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.node_list["TxtTitle"].text.text = Language.Common.Huanhua
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))

	self.node_list["BtnActive"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self.player_data_change = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	self.first_select = true
	self.current_xiannv_id = -1
	self.icon_cell_list = {}

	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
			self.item_cell:SetToggle(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ListenClick(handler)

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetGoddessNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGoddessCell, self)
end

function GoddessHuanHuaView:ReleaseCallBack()
	self.fight_text = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
	end
	self.player_data_change = nil

	for _,v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = nil
	self.model_xiannv_id = -1

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function GoddessHuanHuaView:OpenCallBack()
	self.res_id = nil
	self.current_xiannv_id = -1
	self.model_xiannv_id = -1
	self:DoPanelTweenPlay()
	self:IsActiveToUpgrde()
	local _,cur_huanhua_list = GoddessData.Instance:GetCurHuanHuaList()
	local xiannv_id = cur_huanhua_list[1] and cur_huanhua_list[1].id or 0
	self:OnIconToggleClick(xiannv_id)
	self.node_list["list_view"].scroller:ReloadData(0)
end

function GoddessHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function GoddessHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self.res_id = nil
		self.current_xiannv_id = -1
	end
end

function GoddessHuanHuaView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.RoleTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.RoleTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftBg"], GoddessData.RoleTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(729, -378, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GoddessData.RoleTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function GoddessHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	local callback = function ()
		UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		UIScene:SetTerraceBg(nil, nil, {position = Vector3(-134, -275, 0)}, nil)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
		UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))

		self:OpenCallBack()
	end
	UIScene:ChangeScene(self, callback)
end

function GoddessHuanHuaView:UpdateAttrView()
	local level = GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id)
	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(self.current_xiannv_id)
	if nil == level and nil == huanhua_cfg then
		return
	end

	local huanhua_level_attr = {}
	local huanhua_next_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id, level, true) or {}
	-- huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,level)
	if level == 0 then
		huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,level + 1)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = GoddessData.Instance:GetHuanhuaPower(self.current_xiannv_id, level + 1)
		end
		self.node_list["GongJi"].text.text = 0
		self.node_list["FangYu"].text.text = 0
		self.node_list["MaxHp"].text.text = 0
		self.node_list["ShangHai"].text.text = 0
	else
		huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,level)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = GoddessData.Instance:GetHuanhuaPower(self.current_xiannv_id, level)
		end
		self.node_list["GongJi"].text.text = huanhua_level_attr.gongji
		self.node_list["FangYu"].text.text = huanhua_level_attr.fangyu
		self.node_list["MaxHp"].text.text = huanhua_level_attr.maxhp
		self.node_list["ShangHai"].text.text = huanhua_level_attr.xiannv_gongji
	end

	local current_level = "Lv." .. level
	if huanhua_next_level_attr and next(huanhua_next_level_attr) then
		self.node_list["ArrowGongJi"]:SetActive(true)
		self.node_list["ArrowFangYu"]:SetActive(true)
		self.node_list["ArrowMaxHp"]:SetActive(true)
		self.node_list["ArrowShangHai"]:SetActive(true)
		if level == 0 then
			self.node_list["AddValueGongJi"].text.text = huanhua_level_attr.gongji
			self.node_list["AddValueFangYu"].text.text = huanhua_level_attr.fangyu
			self.node_list["AddValueMaxHp"].text.text = huanhua_level_attr.maxhp
			self.node_list["AddValueShangHai"].text.text = huanhua_level_attr.xiannv_gongji
		else
			self.node_list["AddValueGongJi"].text.text = huanhua_next_level_attr.gongji - huanhua_level_attr.gongji
			self.node_list["AddValueFangYu"].text.text = huanhua_next_level_attr.fangyu - huanhua_level_attr.fangyu
			self.node_list["AddValueMaxHp"].text.text = huanhua_next_level_attr.maxhp - huanhua_level_attr.maxhp
			self.node_list["AddValueShangHai"].text.text = huanhua_next_level_attr.xiannv_gongji - huanhua_level_attr.xiannv_gongji
		end
	else
		self.node_list["ArrowGongJi"]:SetActive(false)
		self.node_list["ArrowFangYu"]:SetActive(false)
		self.node_list["ArrowMaxHp"]:SetActive(false)
		self.node_list["ArrowShangHai"]:SetActive(false)
	end
	local is_show_super = GoddessData.Instance:IsShowSuperPower(self.current_xiannv_id)
	local is_active_super = GoddessData.Instance:GetStarIsShowSuperPower(self.current_xiannv_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	
	if is_show_super and not is_active_super then
		local need_reach_level = GoddessData.Instance:GetActiveSuperPowerNeedLevel(self.current_xiannv_id)
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end
	
	local have_item_num = ItemData.Instance:GetItemNumInBagById(huanhua_level_attr.uplevel_stuff_id)
	local need_item_num =  huanhua_level_attr.uplevel_stuff_num
	local text_1 = ""
	if have_item_num >= need_item_num then
		text_1 = ToColorStr(have_item_num .. "", TEXT_COLOR.GREEN)
	else
		text_1 = ToColorStr(have_item_num .. "" , TEXT_COLOR.RED)
	end
	self.node_list["TxtMaterialsNum"].text.text = text_1 .. " / " .. need_item_num
	
	local info = ItemData.Instance:GetItemConfig(huanhua_level_attr.uplevel_stuff_id)
	if not info then return end
	local name_str = "<color=" .. SOUL_NAME_COLOR[info.color] .. ">" .. huanhua_cfg.name .. "</color>"
	self.node_list["Name"].text.text = current_level .. "·" ..name_str

	local data = {}
	data.item_id = huanhua_level_attr.uplevel_stuff_id
	self.item_cell:SetData(data)
end

function GoddessHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if v and v.id then
			local index, num = GoddessData.Instance:CanHuanhuaIndexByImageId(v.id)
			if index then
				self.current_xiannv_id = index
				local _,cfg_list = GoddessData.Instance:GetCurHuanHuaList()
				num = num > 5 and num or num - 1
				self.node_list["list_view"].scroller:ReloadData(num / #cfg_list)
			end
		end
	end
	self:SetModel(self.current_xiannv_id)
	self:OnFlushCell()
	self:UpdateAttrView()
	self:IsActiveToUpgrde()
end

-- 关闭窗口
function GoddessHuanHuaView:HandleClose()
	self.first_select = true
	self:Close()
end
-- 增加充值
function GoddessHuanHuaView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 玩家元宝改变时
function GoddessHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

--list_view
function GoddessHuanHuaView:GetGoddessNumberOfCells()
	local cur_huanhua_list, huanhua_list = GoddessData.Instance:GetCurHuanHuaList()
	return #huanhua_list
end

function GoddessHuanHuaView:RefreshGoddessCell(cell, cell_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = GoddessHuanHuaCell.New(cell.gameObject, self)
		self.icon_cell_list[cell] = icon_cell
		icon_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	local _,cur_huanhua_list = GoddessData.Instance:GetCurHuanHuaList()
	if cur_huanhua_list == nil and cur_huanhua_list[cell_index + 1] == nil then
		return
	end
	local id = cur_huanhua_list[cell_index + 1].id
	icon_cell:InitCell(id)
	icon_cell:SetToggleIsOn(id == self.current_xiannv_id)
	icon_cell:ListenClick(BindTool.Bind(self.OnIconToggleClick, self, id))
end

function GoddessHuanHuaView:OnIconToggleClick(xiannv_id)
	if self.current_xiannv_id == xiannv_id then
		return
	end

	self:SetXiannvID(xiannv_id)
	self:UpdateAttrView(xiannv_id)
	self:SetModel(xiannv_id)
	self:IsActiveToUpgrde()
end

function GoddessHuanHuaView:IsActiveToUpgrde()
	local huanhua_flag_list = GoddessData.Instance:GetXianNvHuanHuaFlag()
	local huanhua_id = GoddessData.Instance:GetHuanHuaId()

	if huanhua_flag_list[self.current_xiannv_id] and huanhua_flag_list[self.current_xiannv_id] == 1 then
		self.node_list["BtnActive"]:SetActive(false)
		self.node_list["BtnUpGrade"]:SetActive(true)
		if huanhua_id == self.current_xiannv_id then
			self.node_list["BtnUse"]:SetActive(false)
			self.node_list["BtnCancel"]:SetActive(true)
		else
			self.node_list["BtnUse"]:SetActive(true)
			self.node_list["BtnCancel"]:SetActive(false)
		end
	else
		self.node_list["BtnActive"]:SetActive(true)
		self.node_list["BtnUpGrade"]:SetActive(false)
		self.node_list["BtnUse"]:SetActive(false)
		self.node_list["BtnCancel"]:SetActive(false)
	end

	self:SetButtonGray(GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id))
end

function GoddessHuanHuaView:OnClickActive()
	local active_num = #(GoddessData.Instance:GetXiannvActiveList())

	if active_num <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.JiHuoGodess)
		return
	end

	local item_id = GoddessData.Instance:GetXianNvHuanHuaCfg(self.current_xiannv_id).active_item
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)

	if num > 0 then
		GoddessCtrl.Instance:SendXiannvActiveHuanhua(self.current_xiannv_id,ItemData.Instance:GetItemIndex(item_id))
	else
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
end

function GoddessHuanHuaView:OnClickUpgrade()
	local huanhua_level = GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id)

	if huanhua_level >= GODDRESS_HUANHUA_MAX_LEVEL then
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.MaxLevel)
		return
	end

	local item_id = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,huanhua_level).uplevel_stuff_id
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	if num > 0 then
		GoddessCtrl.Instance:SentXiannvHuanHuaUpLevelReq(self.current_xiannv_id,1)
	else
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, num)
		return
	end

end


function GoddessHuanHuaView:OnClickUse()
	GoddessCtrl.Instance:SentXiannvImageReq(self.current_xiannv_id)
end

function GoddessHuanHuaView:OnClickCancel()
	GoddessCtrl.Instance:SentXiannvImageReq(-1)
end

function GoddessHuanHuaView:GetFirstSelect()
	return self.first_select
end

function GoddessHuanHuaView:SetFirstSelect(first_select)
	self.first_select = first_select
end

function GoddessHuanHuaView:SetXiannvID(xiannv_id)
	self.current_xiannv_id = xiannv_id
end

function GoddessHuanHuaView:GetXiannvID()
	return self.current_xiannv_id
end

function GoddessHuanHuaView:OnFlushCell()
	for k,v in pairs(self.icon_cell_list) do
		v:OnFlush()
	end
end

function GoddessHuanHuaView:SetButtonGray(level)
	if level == GODDRESS_HUANHUA_MAX_LEVEL then
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		self.node_list["TextManJi"].text.text = Language.Common.YiManJi
		self.node_list["TxtMaterialsNum"].text.text = "<color=#ffffff>- / -</color>"
	else
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		self.node_list["TextManJi"].text.text = Language.Common.UpGrade
	end
end

function GoddessHuanHuaView:SetModel(xiannv_id)
	if self.model_xiannv_id ~= xiannv_id then
		local call_back = function(model, obj)
			self:CalToShowAnim(true)
			if obj then
				obj.gameObject.transform.localPosition = Vector3(-0.3, 0, 0)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_id)
		local bundle, asset = ResPath.GetGoddessModel(huanhua_cfg.resid)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		self.model_xiannv_id = xiannv_id
	end
end

function GoddessHuanHuaView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	local call_back = function()
		if UIScene.role_model then
			UIScene.role_model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
		end
	end
	call_back()
	self.time_quest = GlobalTimerQuest:AddRunQuest(call_back, 15)
end

function GoddessHuanHuaView:CloseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest = nil
	end

	self.res_id = nil
end

function GoddessHuanHuaView:ClickSuperPower()
	local data = GoddessData.Instance:GetSpecialHuanHuaShowData(self.current_xiannv_id)
	TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
end


----------------------------------------------------------------------------
-- 幻化 GoddessHuanHuaItem

GoddessHuanHuaCell = GoddessHuanHuaCell or BaseClass(BaseRender)

function GoddessHuanHuaCell:__init(instance, parent)
	self.parent_view = parent
	self.xiannv_id = -1
end

function GoddessHuanHuaCell:__delete(instance, parent)
	self.parent_view = nil
end

function GoddessHuanHuaCell:InitCell(xiannv_id)
	self.xiannv_id = xiannv_id
	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_id)

	if huanhua_cfg == nil then
		return
	end

	local res_id = huanhua_cfg.active_item
	local bundle, asset = ResPath.GetItemIcon(res_id)
	self.node_list["icon_sprite"].image:LoadSprite(bundle, asset .. ".png")

	self:OnFlush()
end

function GoddessHuanHuaCell:ListenClick(callback)
	self.node_list["goddesshuanhuaitem"].toggle:AddClickListener(callback)
end

function GoddessHuanHuaCell:OnFlush()
	self.node_list["redpoint"]:SetActive(false)
	self.node_list["ImgYiHuanHua"]:SetActive(false)
	-- local huanhua_flag_list = bit:d2b(GoddessData.Instance:GetXianNvHuanHuaFlag())
	local huanhua_flag_list = GoddessData.Instance:GetXianNvHuanHuaFlag()
	local need_item = 0

	-- if huanhua_flag_list[32 - self.xiannv_id] == 1 then
	if huanhua_flag_list[self.xiannv_id] and huanhua_flag_list[self.xiannv_id] == 1 then
		UI:SetGraphicGrey(self.node_list["icon_sprite"], false)
		need_item = GoddessData.Instance:GetXiannvHuanhuaUpgradeItemID(self.xiannv_id, GoddessData.Instance:GetXianNvHuanHuaLevel(self.xiannv_id))
		if GoddessData.Instance:GetHuanHuaId() == self.xiannv_id then
			self.node_list["ImgYiHuanHua"]:SetActive(true)
		else
			self.node_list["ImgYiHuanHua"]:SetActive(false)
		end
	else
		UI:SetGraphicGrey(self.node_list["icon_sprite"], true)
		need_item = GoddessData.Instance:GetXiannvHuanhuaActiveItemID(self.xiannv_id)
	end

	local count = ItemData.Instance:GetItemNumInBagById(need_item)
	if count > 0 and GoddessData.Instance:GetXianNvHuanHuaLevel(self.xiannv_id) < GODDRESS_HUANHUA_MAX_LEVEL 
		and #(GoddessData.Instance:GetXiannvActiveList()) >= 1 then
		self.node_list["redpoint"]:SetActive(true)
	end

	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(self.xiannv_id)
	if huanhua_cfg == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(need_item)
	if item_cfg == nil then return end

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. huanhua_cfg.name .. "</color>"
	self.node_list["name"].text.text = name_str
end

function GoddessHuanHuaCell:SetStateActive(is_active)
	self.node_list["ImgYiHuanHua"]:SetActive(is_active)
end

function GoddessHuanHuaCell:SetToggleGroup(toggle_group)
	self.node_list["goddesshuanhuaitem"].toggle.group = toggle_group
end

function GoddessHuanHuaCell:SetToggleIsOn(is_on)
	self.node_list["goddesshuanhuaitem"].toggle.isOn = is_on
end

function GoddessHuanHuaCell:GetXiannvID()
	return self.xiannv_id
end
