require("game/suit_collection/red_suit_collect_view")
require("game/suit_collection/orange_suit_collect_view")

SuitCollectionView = SuitCollectionView or BaseClass(BaseView)

function SuitCollectionView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		
		{"uis/views/suitcollection_prefab", "ModelDragLayer"},
		{"uis/views/suitcollection_prefab", "OrangeSuitCollectView", {TabIndex.orange_suit_collect}},
		{"uis/views/suitcollection_prefab", "RedSuitCollectView", {TabIndex.red_suit_collect}},

		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true

	self.def_index = TabIndex.orange_suit_collect
end

function SuitCollectionView:__delete()

end

function SuitCollectionView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.orange_collect_view then
		self.orange_collect_view:DeleteMe()
		self.orange_collect_view = nil
	end

	if self.red_collect_view then
		self.red_collect_view:DeleteMe()
		self.red_collect_view = nil
	end

	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function SuitCollectionView:LoadCallBack(index)
	self.node_list["TxtTitle"].text.text = Language.Title.SuitCollection
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"].transform.localPosition = Vector3(-118, -317.5, 0)
	
	local tab_cfg = {
		{name =	Language.SuitCollect.TabbarName.OrangeSuit, bundle = "uis/images_atlas", asset = "tab_icon_uplevel", tab_index = TabIndex.orange_suit_collect, remind_id = RemindName.OrangeSuitCollection},
		{name = Language.SuitCollect.TabbarName.RedSuit, bundle = "uis/images_atlas", asset = "tab_icon_quality", tab_index = TabIndex.red_suit_collect, remind_id = RemindName.RedSuitCollection},
	}


	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	RemindManager.Instance:Fire(RemindName.OrangeSuitCollection)
	RemindManager.Instance:Fire(RemindName.RedSuitCollection)



	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

end

function SuitCollectionView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function SuitCollectionView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 监听玩家金额
function SuitCollectionView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function SuitCollectionView:OnItemDataChange()
	RemindManager.Instance:Fire(RemindName.OrangeSuitCollection)
	RemindManager.Instance:Fire(RemindName.RedSuitCollection)

	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.orange_suit_collect then
		self:Flush("orange_equip")
	elseif cur_index == TabIndex.red_suit_collect then
		self:Flush("red_equip")
	end
end

function SuitCollectionView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if nil ~= index_nodes then
		if index == TabIndex.orange_suit_collect then
			self.orange_collect_view = OrangeSuitCollect.New(index_nodes["OrangeSuitCollectView"])
		elseif index == TabIndex.red_suit_collect then
			self.red_collect_view = RedSuitCollect.New(index_nodes["RedSuitCollectView"])
		end
	end

	if index == TabIndex.orange_suit_collect then
		self.orange_collect_view:Flush("ui_tween")
	elseif index == TabIndex.red_suit_collect then
		self.red_collect_view:Flush("ui_tween")
	end



	local callback = function()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
		for k,v in pairs(vo.appearance) do
			temp_vo.appearance[k] = v
		end
		temp_vo.appearance.halo_used_imageid = 0
		temp_vo.appearance.wing_used_imageid = 0
		UIScene:SetRoleModelResInfo(temp_vo)
		vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
		UIScene:SetRoleModelResInfo(vo)

		local base_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "SuitCollectionView_role/" .. base_prof)
		transform.rotation = Quaternion.Euler(8, -168, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)
	self.node_list["RotateEventTrigger"]:SetActive(true)
end

function SuitCollectionView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "orange_equip" and self.orange_collect_view then
			self.orange_collect_view:Flush()
		elseif k == "red_equip" and self.red_collect_view then
			self.red_collect_view:Flush()
		end
	end
end

function SuitCollectionView:CloseCallBack()
	
end





