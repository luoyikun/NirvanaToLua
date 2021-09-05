require("game/bianshen/msg/msg_view")					-- 信息
require("game/bianshen/qian_neng/qian_neng_view")		-- 潜能
require("game/bianshen/equip/equip_content")			-- 装备
require("game/bianshen/strengthen/strengthen_view")		-- 强化
require("game/bianshen/qing_shen/qing_shen_view")		-- 请神
-- 仙域-变身(名将)
BianShenView = BianShenView or BaseClass(BaseView)

function BianShenView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/bianshen_prefab", "ModelDragLayer" },					
		{"uis/views/bianshen_prefab", "MsgContent", {TabIndex.bian_shen_msg}},					-- 信息
		{"uis/views/bianshen_prefab", "QianNengContent", {TabIndex.bian_shen_qian_neng}},		-- 潜能
		{"uis/views/bianshen_prefab", "EquipContent", {TabIndex.bian_shen_equip}},				-- 装备
		{"uis/views/bianshen_prefab", "StrengthenContent", {TabIndex.bian_shen_strengthen}},	-- 强化
		{"uis/views/bianshen_prefab", "QingShenContent", {TabIndex.bian_shen_qing_shen}},		-- 请神
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.bian_shen_msg
end

function BianShenView:__delete()
	self:StopCountDown()

end

function BianShenView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.msg_view then
		self.msg_view:DeleteMe()
		self.msg_view = nil
	end

	if self.qian_neng_view then
		self.qian_neng_view:DeleteMe()
		self.qian_neng_view = nil
	end

	if self.qing_shen_view then
		self.qing_shen_view:DeleteMe()
		self.qing_shen_view = nil
	end

	if self.equip_content then
		self.equip_content:DeleteMe()
		self.equip_content = nil
	end

	if self.strengthen_view then
		self.strengthen_view:DeleteMe()
		self.strengthen_view = nil
	end

	self:StopCountDown()
end

function BianShenView:LoadCallBack()
	local tab_cfg = {
			{name = Language.BianShen.TabbarName[1], bundle = "uis/images_atlas", asset = "icon_bian_shen_msg", func = "bian_shen_msg", tab_index = TabIndex.bian_shen_msg, remind_id = RemindName.BianShenMsg},						-- 信息
			{name = Language.BianShen.TabbarName[2], bundle = "uis/images_atlas", asset = "icon_bian_shen_qian_neng", func = "bian_shen_qian_neng", tab_index = TabIndex.bian_shen_qian_neng, remind_id = RemindName.BianShenQianNeng},	-- 潜能
			{name = Language.BianShen.TabbarName[4], bundle = "uis/images_atlas", asset = "icon_bian_shen_equip", func = "bian_shen_equip", tab_index = TabIndex.bian_shen_equip, remind_id = RemindName.BianShenEquip},				-- 装备
			{name = Language.BianShen.TabbarName[5], bundle = "uis/images_atlas", asset = "icon_bian_shen_strengthen", func = "bian_shen_strengthen", tab_index = TabIndex.bian_shen_strengthen, remind_id = RemindName.BianShenStrengthen},-- 强化
			{name = Language.BianShen.TabbarName[3], bundle = "uis/images_atlas", asset = "icon_bian_shen_qing_shen", func = "bian_shen_qing_shen", tab_index = TabIndex.bian_shen_qing_shen, remind_id = RemindName.BianShenQingShen},	-- 请神
		}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))

	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"].transform.localPosition = Vector3(-102, -270, 0)
	self.node_list["TxtTitle"].text.text = Language.Title.BianShen
	self.node_list["UnderBg"]:SetActive(true)
	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.BianShenView, BindTool.Bind(self.GetUiCallBack, self))

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Sheng_Mo)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end
end

-- 一折抢购跳转
function BianShenView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function BianShenView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function BianShenView:OpenCallBack()
	BianShenData.Instance:ClearSortList()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
end

function BianShenView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function BianShenView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function BianShenView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function BianShenView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function BianShenView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.bian_shen_msg then					-- 信息
			self.msg_view = MsgView.New(index_nodes["MsgContent"])
		elseif index == TabIndex.bian_shen_qian_neng then		-- 潜能
			self.qian_neng_view = QianNengView.New(index_nodes["QianNengContent"])
		elseif index == TabIndex.bian_shen_qing_shen then		-- 请神
			self.qing_shen_view = QingShenView.New(index_nodes["QingShenContent"])
		elseif index == TabIndex.bian_shen_equip then			-- 装备
			self.equip_content = EquipContent.New(index_nodes["EquipContent"])
		elseif index == TabIndex.bian_shen_strengthen then		-- 强化
			self.strengthen_view = StrengthenView.New(index_nodes["StrengthenContent"])
		end
	end

	self:SetBgAndTaizi(index)
	if index == TabIndex.bian_shen_msg and self.msg_view then
		self.msg_view:OpenCallBack()
		local callback = function()
			self.msg_view:Flush()
			self.msg_view:UITween()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mingjiang")
			transform.rotation = Quaternion.Euler(0, -174, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.bian_shen_qian_neng and self.qian_neng_view then
		self.qian_neng_view:OpenCallBack()
		local callback = function()
			self.qian_neng_view:Flush()
			self.qian_neng_view:UITween()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mingjiang")
			transform.rotation = Quaternion.Euler(0, -174, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.bian_shen_qing_shen and self.qing_shen_view then
		self.qing_shen_view:OpenCallBack()
		local callback = function()
			self.qing_shen_view:Flush()
			self.qing_shen_view:UITween()
			
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mingjiang")
			transform.rotation = Quaternion.Euler(-2, -197, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.bian_shen_equip and self.equip_content then
		self.equip_content:OpenCallBack()
		local callback = function()
			self.equip_content:Flush()
			self.equip_content:UITween()
			
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mingjiang")
			transform.rotation = Quaternion.Euler(-1.5, -170, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.bian_shen_strengthen and self.strengthen_view then
		self.strengthen_view:OpenCallBack()
		local callback = function()
			self.strengthen_view:Flush()
			self.strengthen_view:UITween()
			
		end
		UIScene:ChangeScene(self, callback)
	end
end

function BianShenView:SetBgAndTaizi(index)
	local asset, bundle = "uis/rawimages/bg_common1_under", "bg_common1_under.jpg"
	local vect = Vector3(-250, 0, 0)
	local is_show_taizi = true
	local taizi_vect = Vector3(-102, -270, 0)
	local taizi_scale = Vector3(1, 1, 1)

	if index == TabIndex.bian_shen_qing_shen then
		vect = Vector3(221, 0, 0)
		asset, bundle = "uis/rawimages/bianshen_bg", "bianshen_bg.jpg"
		is_show_taizi = false
	elseif index == TabIndex.bian_shen_strengthen then
		is_show_taizi = false
	elseif index == TabIndex.bian_shen_equip then
		is_show_taizi = true
		taizi_scale = Vector3(0.8, 0.8, 0.8)
		taizi_vect = Vector3(-182, -298, 0)
	end

	self.node_list["RotateEventTrigger"].gameObject.transform.localPosition = vect
	self.node_list["UnderBg"].raw_image:LoadSprite(asset, bundle)
	self.node_list["TaiZi"]:SetActive(is_show_taizi)
	self.node_list["TaiZi"].transform.localPosition = taizi_vect
	self.node_list["TaiZi"].transform.localScale = taizi_scale
end

function BianShenView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.bian_shen_msg and self.msg_view then
				self.msg_view:Flush(k, v)
			elseif cur_index == TabIndex.bian_shen_qian_neng and self.qian_neng_view then
				self.qian_neng_view:Flush()
			elseif cur_index == TabIndex.bian_shen_qing_shen and self.qing_shen_view then
				self.qing_shen_view:Flush()
			elseif cur_index == TabIndex.bian_shen_equip and self.equip_content then
				self.equip_content:Flush()
			elseif cur_index == TabIndex.bian_shen_strengthen and self.strengthen_view then
				self.strengthen_view:Flush()
			end
		elseif k == "bianshen_msg" then
			if cur_index == TabIndex.bian_shen_msg and self.msg_view then
				self.msg_view:Flush()
			end
		elseif k == "bianshen_qianneng" then
			if cur_index == TabIndex.bian_shen_qian_neng and self.qian_neng_view then
				self.qian_neng_view:Flush()
			end
		elseif k == "bianshen_qingshen" then
			if cur_index == TabIndex.bian_shen_qing_shen and self.qing_shen_view then
				self.qing_shen_view:Flush()
			end
		elseif k == "bianshen_equipcontent" then
			if cur_index == TabIndex.bian_shen_equip and self.equip_content then
				self.equip_content:Flush()
			end
		elseif k == "bianshen_strengthen" then
			if cur_index == TabIndex.bian_shen_strengthen and self.strengthen_view then
				self.strengthen_view:Flush()
			end
		end
	end
end

function BianShenView:ItemDataChangeCallback()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.bian_shen_msg and self.msg_view then
		self.msg_view:Flush()
	elseif cur_index == TabIndex.bian_shen_qian_neng and self.qian_neng_view then
		self.qian_neng_view:Flush()
	elseif cur_index == TabIndex.bian_shen_qing_shen and self.qing_shen_view then
		self.qing_shen_view:Flush()
	elseif cur_index == TabIndex.bian_shen_equip and self.equip_content then
		self.equip_content:Flush()
	elseif cur_index == TabIndex.bian_shen_strengthen and self.strengthen_view then
		self.strengthen_view:Flush()
	end
end

function BianShenView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end

function BianShenView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.BianShenActive then
		if self.msg_view then
			return self.msg_view:GetBtnActive()
		end
	elseif ui_name == GuideUIName.BianShenUse then
		if self.msg_view then
			return self.msg_view:GetBtnUse()
		end
	elseif ui_name == GuideUIName.CloseBtn then
		if self.node_list["BtnClose"] then
			return self.node_list["BtnClose"], BindTool.Bind(self.Close, self)
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end