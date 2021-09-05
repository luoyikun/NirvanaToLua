require("game/appearance/multi_mount/multi_mount_view")		-- 双骑
require("game/appearance/tou_shi/toushi_content_view")		-- 头饰
require("game/appearance/mask/mask_content_view")			-- 面饰
require("game/appearance/waist/waist_content_view")			-- 腰饰
require("game/appearance/qilin_bi/qilinbi_content_view")	-- 麒麟臂
require("game/appearance/ling_tong/lingchong_content_view")	-- 灵童
require("game/appearance/ling_gong/linggong_content_view")	-- 灵弓
require("game/appearance/ling_qi/lingqi_content_view")		-- 灵骑
require("game/appearance/wei_yan/wei_yan_content_view")		-- 尾焰
require("game/appearance/shou_huan/shou_huan_content_view")	-- 手环
require("game/appearance/tail/tail_content_view")			-- 尾巴
require("game/appearance/fly_pet/fly_pet_content_view")		-- 飞宠
require("game/appearance/ling_zhu/lingzhu_content_view")	-- 灵珠
require("game/appearance/xian_bao/xianbao_content_view")	-- 仙宝

-- 仙域-外观
AppearanceView = AppearanceView or BaseClass(BaseView)
local MULTI_MOUNT_TOGGLE = 1
function AppearanceView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/appearance_prefab", "ModelDragLayer"}, 
		{"uis/views/appearance_prefab", "MultiMount", {TabIndex.appearance_multi_mount}}, 	-- 双骑
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_toushi}},			-- 头饰
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_mask}},				-- 面饰
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_waist}},			-- 腰饰
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_qilinbi}},			-- 麒麟臂
		{"uis/views/appearance_prefab", "ContentThree", {TabIndex.appearance_lingtong}},	-- 灵童
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_linggong}},		 	-- 灵弓
		{"uis/views/appearance_prefab", "Content", {TabIndex.appearance_lingqi}},			-- 灵骑
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_weiyan}},		-- 尾焰
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_shouhuan}},		-- 手环
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_tail}},			-- 尾巴
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_flypet}},		-- 飞宠
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_lingzhu}},		-- 灵珠
		{"uis/views/appearance_prefab", "ContentTwo", {TabIndex.appearance_xianbao}},		-- 仙宝
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	-- self.def_index = TabIndex.appearance_multi_mount

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function AppearanceView:__delete()
	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
	end
end

function AppearanceView:ReleaseCallBack()

	if self.multi_mount_view then
		self.multi_mount_view:DeleteMe()
		self.multi_mount_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.toushi_view then
		self.toushi_view:DeleteMe()
		self.toushi_view = nil
	end

	if self.mask_view then
		self.mask_view:DeleteMe()
		self.mask_view = nil
	end

	if self.waist_view then
		self.waist_view:DeleteMe()
		self.waist_view = nil
	end

	if self.lingzhu_view then
		self.lingzhu_view:DeleteMe()
		self.lingzhu_view = nil
	end

	if self.xianbao_view then
		self.xianbao_view:DeleteMe()
		self.xianbao_view = nil
	end

	if self.lingtong_view then
		self.lingtong_view:DeleteMe()
		self.lingtong_view = nil
	end

	if self.linggong_view then
		self.linggong_view:DeleteMe()
		self.linggong_view = nil
	end

	if self.lingqi_view then
		self.lingqi_view:DeleteMe()
		self.lingqi_view = nil
	end

	if self.qilinbi_view then
		self.qilinbi_view:DeleteMe()
		self.qilinbi_view = nil
	end

	if self.weiyan_view then
		self.weiyan_view:DeleteMe()
		self.weiyan_view = nil
	end

	if self.shou_huan_view then
		self.shou_huan_view:DeleteMe()
		self.shou_huan_view = nil
	end

	if self.tail_view then
		self.tail_view:DeleteMe()
		self.tail_view = nil
	end

	if self.fly_pet_view then
		self.fly_pet_view:DeleteMe()
		self.fly_pet_view = nil
	end
end

function AppearanceView:LoadCallBack()
	local tab_cfg = {
		{name = Language.MultiMount.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_double_mount", func = "appearance_multi_mount", tab_index = TabIndex.appearance_multi_mount, remind_id = RemindName.MultiMount},	--双骑
		{name = Language.MultiMount.TabbarName[6], bundle = "uis/images_atlas", asset = "tab_icon_lingtong", func = "appearance_lingtong", tab_index = TabIndex.appearance_lingtong, remind_id = RemindName.LingTong},				--灵童
		{name = Language.MultiMount.TabbarName[12], bundle = "uis/images_atlas", asset = "tab_icon_flypet", func = "appearance_flypet", tab_index = TabIndex.appearance_flypet, remind_id = RemindName.FlyPet},						--飞宠
		{name = Language.MultiMount.TabbarName[8], bundle = "uis/images_atlas", asset = "tab_icon_lingqi", func = "appearance_lingqi", tab_index = TabIndex.appearance_lingqi, remind_id = RemindName.LingQi},						--灵骑
		{name = Language.MultiMount.TabbarName[9], bundle = "uis/images_atlas", asset = "tab_icon_weiyan", func = "appearance_weiyan", tab_index = TabIndex.appearance_weiyan, remind_id = RemindName.WeiYan},						--尾焰
		{name = Language.MultiMount.TabbarName[5], bundle = "uis/images_atlas", asset = "tab_icon_qilinbi", func = "appearance_qilinbi", tab_index = TabIndex.appearance_qilinbi, remind_id = RemindName.QilinBi},					--麒麟臂
		{name = Language.MultiMount.TabbarName[7], bundle = "uis/images_atlas", asset = "tab_icon_linggong", func = "appearance_linggong", tab_index = TabIndex.appearance_linggong, remind_id = RemindName.LingGong},				--灵弓
		{name = Language.MultiMount.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_icon_waist", func = "appearance_waist", tab_index = TabIndex.appearance_waist, remind_id = RemindName.Waist},							--腰饰
		{name = Language.MultiMount.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_icon_mask", func = "appearance_mask", tab_index = TabIndex.appearance_mask, remind_id = RemindName.Mask},								--面饰
		{name = Language.MultiMount.TabbarName[11], bundle = "uis/images_atlas", asset = "tab_icon_tail", func = "appearance_tail", tab_index = TabIndex.appearance_tail, remind_id = RemindName.Tail},								--尾巴
		{name = Language.MultiMount.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_icon_toushi", func = "appearance_toushi", tab_index = TabIndex.appearance_toushi, remind_id = RemindName.TouShi},						--头饰
		{name = Language.MultiMount.TabbarName[10], bundle = "uis/images_atlas", asset = "tab_icon_shouhuan", func = "appearance_shouhuan", tab_index = TabIndex.appearance_shouhuan, remind_id = RemindName.ShouHuan},				--手环
		{name = Language.MultiMount.TabbarName[13], bundle = "uis/images_atlas", asset = "tab_icon_lingzhu", func = "appearance_lingzhu", tab_index = TabIndex.appearance_lingzhu, remind_id = RemindName.LingZhu},					--灵珠
		{name = Language.MultiMount.TabbarName[14], bundle = "uis/images_atlas", asset = "tab_icon_xianbao", func = "appearance_xianbao", tab_index = TabIndex.appearance_xianbao, remind_id = RemindName.XianBao},					--仙宝
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self:SetTuPoTabButtonIcon()
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["TxtTitle"].text.text = Language.Title.ShuangRenZuoQi
	self.node_list["UnderBg"]:SetActive(true)
	-- self.node_list["TaiZi"].transform.localPosition = Vector3(-135, -280, 0)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function AppearanceView:OpenCallBack()
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

function AppearanceView:HandleClose()
	local show_index = self.show_index or -1
	AppearanceCtrl.Instance:OpenClearBlessView(show_index, function()
		self:Close()
	end)
end

function AppearanceView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AppearanceView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	AppearanceCtrl.Instance:ClearTipsBlessT()
	UIScene:ClearWeiYanData()

	if self.lingqi_view then
		self.lingqi_view:CloseCallBack()
	end
	if self.weiyan_view then
		self.weiyan_view:CloseCallBack()
	end
	if self.qilinbi_view then
		self.qilinbi_view:CloseCallBack()
	end
	if self.lingtong_view then
		self.lingtong_view:CloseCallBack()
	end
	if self.linggong_view then
		self.linggong_view:CloseCallBack()
	end
	if self.fly_pet_view then
		self.fly_pet_view:CloseCallBack()
	end
end

-- 元宝
function AppearanceView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function AppearanceView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AppearanceView:ShowIndexCallBack(index, index_nodes, is_jump)
	self.tabbar:ChangeToIndex(index, is_jump)
	if nil ~= index_nodes then
		if index == TabIndex.appearance_multi_mount then 								-- 双骑
			self.multi_mount_view = MultiMountView.New(index_nodes["MultiMount"])		
			self.multi_mount_view:ResetModleRotation()
		elseif index == TabIndex.appearance_toushi then 								-- 头饰
			self.toushi_view = TouShiContentView.New(index_nodes["Content"])			
		elseif index == TabIndex.appearance_mask then 									-- 面饰
			self.mask_view = MaskContentView.New(index_nodes["Content"])				
		elseif index == TabIndex.appearance_waist then 									-- 腰饰
			self.waist_view = WaistContentView.New(index_nodes["Content"])				
		elseif index == TabIndex.appearance_qilinbi then 								-- 麒麟臂
			self.qilinbi_view = QilinBiContentView.New(index_nodes["Content"])			
		elseif index == TabIndex.appearance_lingzhu	then 								-- 灵珠
			self.lingzhu_view = LingZhuContentView.New(index_nodes["ContentTwo"])
		elseif index == TabIndex.appearance_xianbao	then 								-- 仙宝
			self.xianbao_view = XianBaoContentView.New(index_nodes["ContentTwo"])
		elseif index == TabIndex.appearance_lingtong then 								-- 灵童
			self.lingtong_view = LingChongContentView.New(index_nodes["ContentThree"])
		elseif index == TabIndex.appearance_linggong then 								-- 灵弓
			self.linggong_view = LingGongContentView.New(index_nodes["Content"])
		elseif index == TabIndex.appearance_lingqi then 								-- 灵骑
			self.lingqi_view = LingQiContentView.New(index_nodes["Content"])
		elseif index == TabIndex.appearance_weiyan then 								-- 尾焰
			self.weiyan_view = WeiYanContentView.New(index_nodes["ContentTwo"])
		elseif index == TabIndex.appearance_shouhuan then 								-- 手环
			self.shou_huan_view = ShouHuanContentView.New(index_nodes["ContentTwo"])
		elseif index == TabIndex.appearance_tail then 									-- 尾巴
			self.tail_view = TailContentView.New(index_nodes["ContentTwo"])
		elseif index == TabIndex.appearance_flypet then 								-- 飞宠
			self.fly_pet_view = FlyPetContentView.New(index_nodes["ContentTwo"])
		end
	end

	self:StopAutoAdvance()
	self:ClearTempData()
	UIScene:ClearWeiYanData()
	self.node_list["RotateEventTrigger"]:SetActive(true)
	-- self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	-- 双骑
	if index == TabIndex.appearance_multi_mount then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-135, -280, 0)
		self.multi_mount_view:OpenCallBack()
		local callback = function()
			self.multi_mount_view:Flush()
			self.multi_mount_view:SetModle(true)
			self.multi_mount_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "multimount")
			transform.rotation = Quaternion.Euler(0, -172, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 头饰
	elseif index == TabIndex.appearance_toushi then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.toushi_view:OpenCallBack()
		local callback = function()
			self.toushi_view:Flush("toushi")
			self.toushi_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 面饰
	elseif index == TabIndex.appearance_mask then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.mask_view:OpenCallBack()
		local callback = function()
			self.mask_view:Flush("mask")
			self.mask_view:UITween()
			
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 腰饰
	elseif index == TabIndex.appearance_waist then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.waist_view:OpenCallBack()
		local callback = function()
			self.waist_view:Flush("waist")
			self.waist_view:UITween()
			
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)

			UIScene:SetModelLoadCallBack(function(model, obj)
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 40, 0)
			end)
		end
		UIScene:ChangeScene(self, callback)
		
	-- 麒麟臂
	elseif index == TabIndex.appearance_qilinbi then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.qilinbi_view:OpenCallBack()
		local callback = function()
			self.qilinbi_view:Flush("qilinbi")
			self.qilinbi_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "arm")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 灵珠
	elseif index == TabIndex.appearance_lingzhu	then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.lingzhu_view:OpenCallBack()
		local callback = function()
			self.lingzhu_view:Flush("lingzhu")
			self.lingzhu_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingzhu")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 仙宝
	elseif index == TabIndex.appearance_xianbao	then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.xianbao_view:OpenCallBack()
		local callback = function()
			self.xianbao_view:Flush("xianbao")
			self.xianbao_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "xianbao")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
			self.node_list["RotateEventTrigger"]:SetActive(false)
		end
		UIScene:ChangeScene(self, callback)

	-- 灵童
	elseif index == TabIndex.appearance_lingtong then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.lingtong_view:OpenCallBack()
		local callback = function()
			self.lingtong_view:Flush("lingchong")
			self.lingtong_view:UITween()

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingchong")
			transform.rotation = Quaternion.Euler(4, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 灵弓
	elseif index == TabIndex.appearance_linggong then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.linggong_view:OpenCallBack()
		local callback = function()
			self.linggong_view:Flush("linggong")
			self.linggong_view:UITween()
			local call_back = function(model, obj)
				if obj then
					-- obj.gameObject.transform.localRotation = Quaternion.Euler(-30, -90, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "linggong")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 灵骑
	elseif index == TabIndex.appearance_lingqi then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.lingqi_view:OpenCallBack()
		local callback = function()
			self.lingqi_view:Flush("lingqi")
			self.lingqi_view:UITween()
			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingqi")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 尾焰
	elseif index == TabIndex.appearance_weiyan then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.weiyan_view:OpenCallBack()
		local callback = function()
			self.weiyan_view:Flush("weiyan")
			self.weiyan_view:UITween()

			local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
			local type_key = mulit_mount_res_id > 0 and "multimount" or "mount"
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, type_key)
			transform.position = Vector3(transform.position.x, transform.position.y, transform.position.z + 2)
			transform.rotation = Quaternion.Euler(0, -161, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 手环
	elseif index == TabIndex.appearance_shouhuan then 
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.shou_huan_view:OpenCallBack()
		local callback = function()
			self.shou_huan_view:Flush("shouhuan")
			self.shou_huan_view:UITween()

			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, 90, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 尾巴
	elseif index == TabIndex.appearance_tail then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.tail_view:OpenCallBack()
		local callback = function()
			self.tail_view:Flush("tail")
			self.tail_view:UITween()

			local call_back = function(model, obj)
				if obj then
					if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
						obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
					else
						obj.gameObject.transform.localRotation = Quaternion.Euler(0, 160, 0)
					end
				end
			end
			UIScene:SetModelLoadCallBack(call_back)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

	-- 飞宠
	elseif index == TabIndex.appearance_flypet then
		self.node_list["TaiZi"].transform.localPosition = Vector3(-232, -280, 0)
		self.fly_pet_view:OpenCallBack()
		local callback = function()
			self.fly_pet_view:Flush("flypet")
			self.fly_pet_view:UITween()

			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
					local animator = obj.gameObject:GetComponentInChildren(typeof(UnityEngine.Animator))
					if animator then
						animator.speed = 1
					end
				end
			end
			UIScene:SetModelLoadCallBack(call_back)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "flypet")
			transform.rotation = Quaternion.Euler(0, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	end
end

function AppearanceView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.appearance_multi_mount and self.multi_mount_view then
				self.multi_mount_view:Flush()
			elseif cur_index == TabIndex.appearance_toushi and self.toushi_view then
				self.toushi_view:Flush()
			elseif cur_index == TabIndex.appearance_mask and self.mask_view then
				self.mask_view:Flush()
			elseif cur_index == TabIndex.appearance_waist and self.waist_view then
				self.waist_view:Flush()
			elseif cur_index == TabIndex.appearance_qilinbi and self.qilinbi_view then
				self.qilinbi_view:Flush()
			elseif cur_index == TabIndex.appearance_lingzhu and self.lingzhu_view then
				self.lingzhu_view:Flush()
			elseif cur_index == TabIndex.appearance_xianbao	and self.xianbao_view then
				self.xianbao_view:Flush()
			elseif cur_index == TabIndex.appearance_lingtong and self.lingtong_view then
				self.lingtong_view:Flush()
			elseif cur_index == TabIndex.appearance_linggong then
				self.linggong_view:Flush()
			elseif cur_index == TabIndex.appearance_lingqi and self.lingqi_view then
				self.lingqi_view:Flush()
			elseif cur_index == TabIndex.appearance_weiyan then

			elseif cur_index == TabIndex.appearance_shouhuan then

			elseif cur_index == TabIndex.appearance_tail then

			elseif cur_index == TabIndex.appearance_flypet then

			end

		elseif k == "FlsuhAutoBuyToggle" then
			if cur_index == TabIndex.appearance_multi_mount and self.multi_mount_view then
				self.multi_mount_view:FlsuhAutoBuyToggle()
			end

		elseif k == "toushi" or k == "toushi_item_change" then
			if cur_index == TabIndex.appearance_toushi and self.toushi_view then
				self.toushi_view:Flush(k)
			end
		elseif k == "toushi_upgrade" then
			if cur_index == TabIndex.appearance_toushi and self.toushi_view then
				self.toushi_view:Flush(k, v)
			end

		elseif k == "mask" or k == "mask_item_change" then
			if cur_index == TabIndex.appearance_mask and self.mask_view then
				self.mask_view:Flush(k)
			end
		elseif k == "mask_upgrade" then
			if cur_index == TabIndex.appearance_mask and self.mask_view then
				self.mask_view:Flush(k, v)
			end

		elseif k == "waist" or k == "waist_item_change" then
			if cur_index == TabIndex.appearance_waist and self.waist_view then
				self.waist_view:Flush(k)
			end
		elseif k == "waist_upgrade" then
			if cur_index == TabIndex.appearance_waist and self.waist_view then
				self.waist_view:Flush(k, v)
			end

		elseif k == "qilinbi" or k == "qilinbi_item_change" then
			if cur_index == TabIndex.appearance_qilinbi and self.qilinbi_view then
				self.qilinbi_view:Flush(k)
			end
		elseif k == "qilinbi_upgrade" then
			if cur_index == TabIndex.appearance_qilinbi and self.qilinbi_view then
				self.qilinbi_view:Flush(k, v)
			end
		elseif k == "lingzhu" or k == "lingzhu_item_change" then
			if cur_index == TabIndex.appearance_lingzhu	then
				self.lingzhu_view:Flush(k)
			end
		elseif k == "lingzhu_upgrade" then
			if cur_index == TabIndex.appearance_lingzhu	and self.lingzhu_view then
				self.lingzhu_view:Flush(k, v)
			end
		elseif k == "xianbao" or k == "xianbao_item_change" then
			if cur_index == TabIndex.appearance_xianbao and self.xianbao_view then
				self.xianbao_view:Flush(k)
			end
		elseif k == "xianbao_upgrade" then
			if cur_index == TabIndex.appearance_xianbao and self.xianbao_view then
				self.xianbao_view:Flush(k, v)
			end
		elseif k == "lingchong" or k == "lingchong_item_change" then
			if cur_index == TabIndex.appearance_lingtong and self.lingtong_view then
				self.lingtong_view:Flush(k)
			end
		elseif k == "lingchong_upgrade" then
			if cur_index == TabIndex.appearance_lingtong and self.lingtong_view then
				self.lingtong_view:Flush(k, v)
			end
		elseif k == "linggong" or k == "linggong_item_change" then
			if cur_index == TabIndex.appearance_linggong and self.linggong_view then
				self.linggong_view:Flush(k)
			end
		elseif k == "linggong_upgrade" then
			if cur_index == TabIndex.appearance_linggong and self.linggong_view then
				self.linggong_view:Flush(k, v)
			end
		elseif k == "lingqi" or k == "lingqi_item_change" then
			if cur_index == TabIndex.appearance_lingqi and self.lingqi_view then
				self.lingqi_view:Flush(k)
			end
		elseif k == "lingqi_upgrade" then
			if cur_index == TabIndex.appearance_lingqi and self.lingqi_view then
				self.lingqi_view:Flush(k, v)
			end
		elseif k == "weiyan" or k == "weiyan_item_change" then
			if cur_index == TabIndex.appearance_weiyan and self.weiyan_view then
				self.weiyan_view:Flush(k)
			end
		elseif k == "weiyan_upgrade"then
			if cur_index == TabIndex.appearance_weiyan and self.weiyan_view then
				self.weiyan_view:Flush(k, v)
			end
		elseif k == "shouhuan" or k == "shouhuan_item_change" then
			if cur_index == TabIndex.appearance_shouhuan and self.shou_huan_view then
				self.shou_huan_view:Flush(k)
			end
		elseif k == "shouhuan_upgrade"then
			if cur_index == TabIndex.appearance_shouhuan and self.shou_huan_view then
				self.shou_huan_view:Flush(k, v)
			end
		elseif k == "tail" or k == "tail_item_change" then
			if cur_index == TabIndex.appearance_tail and self.tail_view then
				self.tail_view:Flush(k)
			end
		elseif k == "tail_upgrade"then
			if cur_index == TabIndex.appearance_tail and self.tail_view then
				self.tail_view:Flush(k, v)
			end
		elseif k == "flypet" or k == "flypet_item_change" then
			if cur_index == TabIndex.appearance_flypet and self.fly_pet_view then
				self.fly_pet_view:Flush(k)
			end
		elseif k == "flypet_upgrade"then
			if cur_index == TabIndex.appearance_flypet and self.fly_pet_view then
				self.fly_pet_view:Flush(k, v)
			end
		end
	end
end

function AppearanceView:MultiMountUpgradeResult(result)
	if self.multi_mount_view then
		self.multi_mount_view:MultiMountUpgradeResult(result)
	end
end

function AppearanceView:ItemDataChangeCallback()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.appearance_multi_mount and self.multi_mount_view then
		self.multi_mount_view:ItemDataChangeCallback()
	elseif cur_index == TabIndex.appearance_toushi and self.toushi_view then
		self.toushi_view:Flush()
	elseif cur_index == TabIndex.appearance_mask and self.mask_view then
		self.mask_view:Flush()
	elseif cur_index == TabIndex.appearance_waist and self.waist_view then
		self.waist_view:Flush()
	elseif cur_index == TabIndex.appearance_qilinbi and self.qilinbi_view then
		self.qilinbi_view:Flush()
	elseif cur_index == TabIndex.appearance_lingzhu and self.lingzhu_view then
		self.lingzhu_view:Flush()
	elseif cur_index == TabIndex.appearance_xianbao and self.xianbao_view then
		self.xianbao_view:Flush()
	elseif cur_index == TabIndex.appearance_lingtong and self.lingtong_view then
		self.lingtong_view:Flush()
	elseif cur_index == TabIndex.appearance_linggong and self.linggong_view then
		self.linggong_view:Flush()
	elseif cur_index == TabIndex.appearance_lingqi and self.lingqi_view then
		self.lingqi_view:Flush()
	elseif cur_index == TabIndex.appearance_weiyan and self.weiyan_view then
		self.weiyan_view:Flush()
	elseif cur_index == TabIndex.appearance_shouhuan and self.shou_huan_view then
		self.shou_huan_view:Flush()
	elseif cur_index == TabIndex.appearance_tail and self.tail_view then
		self.tail_view:Flush()
	elseif cur_index == TabIndex.appearance_flypet and self.fly_pet_view then
		self.fly_pet_view:Flush()
	end
end

function AppearanceView:FlushTabbar()	
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function AppearanceView:StopAutoAdvance()
	if self.multi_mount_view and self.multi_mount_view.is_auto then
		self.multi_mount_view:OnAutomaticAdvance()
	end
end

function AppearanceView:ClearTempData()
	if self.multi_mount_view then
		self.multi_mount_view:ClearTempData()
	end
end

function AppearanceView:OpenIndexCheck(to_index)
	local temp_index = -1
	if self.show_index then
		temp_index = self.show_index
	end
	AppearanceCtrl.Instance:OpenClearBlessView(temp_index, function()
		self:ChangeToIndex(to_index)
	end)
end

-- 获取双人坐骑
function AppearanceView:GetMultiMountView()
	if self.multi_mount_view then
		return self.multi_mount_view
	end
end

-- 获取头饰
function AppearanceView:GetTouShiView()
	if self.toushi_view then
		return self.toushi_view
	end
end

-- 获取面饰
function AppearanceView:GetMaskView()
	if self.mask_view then
		return self.mask_view
	end
end

-- 获取腰饰
function AppearanceView:GetYaoShiView()
	if self.waist_view then
		return self.waist_view
	end
end

-- 获取麒麟臂
function AppearanceView:GetQiLinBiView()
	if self.qilinbi_view then
		return self.qilinbi_view
	end
end

-- 获取灵珠
function AppearanceView:GetLingZhuView()
	if self.lingzhu_view then
		return self.lingzhu_view
	end
end

-- 获取仙宝
function AppearanceView:GetXianBaoView()
	if self.xianbao_view then
		return self.xianbao_view
	end
end

-- 获取灵童
function AppearanceView:GetLingChongView()
	if self.lingtong_view then
		return self.lingtong_view
	end
end

-- 获取灵弓
function AppearanceView:GetLingGongView()
	if self.linggong_view then
		return self.linggong_view
	end
end

-- 获取灵骑
function AppearanceView:GetLingQiView()
	if self.lingqi_view then
		return self.lingqi_view
	end
end

-- 获取尾焰
function AppearanceView:GetWeiYanView()
	if self.weiyan_view then
		return self.weiyan_view
	end
end

-- 获取手环
function AppearanceView:GetShouHuanView()
	if self.shou_huan_view then
		return self.shou_huan_view
	end
end

-- 获取尾巴
function AppearanceView:GetTailView()
	if self.tail_view then
		return self.tail_view
	end
end

-- 获取飞宠
function AppearanceView:GetFlyPetView()
	if self.fly_pet_view then
		return self.fly_pet_view
	end
end

function AppearanceView:SetTuPoTabButtonIcon()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tab_index = COMPETITION_ACTIVITY_DAY_TO_TABINDEX[cur_day]
	if tab_index and self.tabbar then
		local tab_button = self.tabbar:GetTabButton(tab_index)
		if tab_button then
			tab_button:ShowBiPin(true)
		end
	end		
end