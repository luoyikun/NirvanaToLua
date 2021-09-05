require("game/douqi_equip/douqi_grade_view")
require("game/douqi_equip/douqi_equip_view")
require("game/douqi_equip/douqi_refine_view")

DouQiView = DouQiView or BaseClass(BaseView)

function DouQiView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/forgeview_prefab", "ModelDragLayer"},
		{"uis/views/douqiview_prefab", "DouqiGradeView", {TabIndex.douqi_grade}},
		{"uis/views/douqiview_prefab", "DouqiEquipView", {TabIndex.douqi_equip}},
		{"uis/views/douqiview_prefab", "DouqiRefineView", {TabIndex.douqi_refine}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.def_index = TabIndex.douqi_grade
end

function DouQiView:__delete()

end

function DouQiView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.grade_view then
		self.grade_view:DeleteMe()
		self.grade_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.refine_view then
		self.refine_view:DeleteMe()
		self.refine_view = nil
	end
	
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function DouQiView:LoadCallBack()
	self.node_list["TxtTitle"].text.text = Language.Douqi.Title

	local function open_refine ()
		local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
		self.isopen_refine = douqi_info and douqi_info.douqi_grade > 0
		return self.isopen_refine
	end

	local tab_cfg = {
		{name =	Language.Douqi.TabbarName.Grade, bundle = "uis/images_atlas", asset = "tab_icon_uplevel", tab_index = TabIndex.douqi_grade, remind_id = RemindName.DouqiGrade},
		{name =	Language.Douqi.TabbarName.Equip, bundle = "uis/images_atlas", asset = "tab_icon_forge_advance", tab_index = TabIndex.douqi_equip, remind_id = RemindName.DouqiEquip},
		{name = Language.Douqi.TabbarName.Refine, bundle = "uis/images_atlas", asset = "tab_icon_quality", tab_index = TabIndex.douqi_refine, func = open_refine, remind_id = RemindName.DouqiRefine},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	DouQiCtrl.Instance:SendCSCrossEquipOpera(CROSS_EQUIP_REQ_TYPE.CROSS_EQUIP_REQ_TYPE_INFO)
	DouQiCtrl.Instance:SendCSCrossEquipOpera(CROSS_EQUIP_REQ_TYPE.CROSS_EQUIP_REQ_ALL_EQUIP_INFO)

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function DouQiView:OpenCallBack()

end

function DouQiView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function DouQiView:OnItemDataChange(change_item_id, change_item_index, change_reason)
	local index = self:GetShowIndex()

	if TabIndex.douqi_grade == index then
		self:Flush("grade_view")
	elseif TabIndex.douqi_equip == index and DouQiData.Instance:IsDouqiEqupi(change_item_id) then
		self:Flush("equip_view")
	-- elseif TabIndex.douqi_refine == index then
	-- 	self:Flush("refine_view")
	end
end

-- 监听玩家金额
function DouQiView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function DouQiView:CloseCallBack()
	ViewManager.Instance:Close(ViewName.DouQiEquipRecovery)
end

function DouQiView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if nil ~= index_nodes then
		if index == TabIndex.douqi_grade then
			self.grade_view = DouqiGradeView.New(index_nodes["DouqiGradeView"], self)
		elseif index == TabIndex.douqi_equip then
			self.equip_view = DouqiEquipView.New(index_nodes["DouqiEquipView"], self)
		elseif index == TabIndex.douqi_refine then
			self.refine_view = DouqiRefineView.New(index_nodes["DouqiRefineView"], self)
		end
	end

	self.node_list["UnderBg"]:SetActive(true)
	if index == TabIndex.douqi_equip then
		UIScene:ChangeScene(nil)
	else
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

			UIScene:SetActionEnable(true)

			local base_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	end


	if index == TabIndex.douqi_grade then
		self:Flush("grade_view")
	elseif index == TabIndex.douqi_equip then
		self:Flush("equip_view")
	elseif index == TabIndex.douqi_refine then
		self:Flush("refine_view")
	end

	if self.last_index == TabIndex.douqi_equip and self.equip_view then
		self.equip_view:OnOpenOrCloseRecovery(false)
	elseif self.last_index == TabIndex.douqi_refine and self.refine_view then
		self.refine_view:ResetFlag()
	end
end

function DouQiView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if "flush_tabbar" == k and self.tabbar and not self.isopen_refine then
			self.tabbar:FlushTabbar()
		elseif "grade_view" == k and self.grade_view then
			self.grade_view:Flush()
		elseif "equip_view" == k and self.equip_view then
			self.equip_view:Flush()
		elseif "refine_view" == k and self.refine_view then
			self.refine_view:Flush()
		end
	end
end
