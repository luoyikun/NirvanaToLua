-- 仙宠-宠物
SpiritView = SpiritView or BaseClass(BaseView)

function SpiritView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/spiritview_prefab","ModelDragLayer"},
		{"uis/views/spiritview_prefab", "SpiritContent", {TabIndex.spirit_spirit}},	--仙宠
		{"uis/views/spiritview_prefab", "SpiritLingPo", {TabIndex.spirit_lingpo}},	--图鉴
		{"uis/views/spiritview_prefab", "HuntContent", {TabIndex.spirit_hunt}},		--猎取
		{"uis/views/spiritview_prefab", "MeetContent", {TabIndex.spirit_meet}},		--奇遇
		{"uis/views/spiritview_prefab", "SkillContent", {TabIndex.spirit_skill}},	--技能
		{"uis/views/spiritview_prefab", "SoulContent", {TabIndex.spirit_soul}},		--命魂
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_bindgold_click = false 
	self.def_index = TabIndex.spirit_spirit
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function SpiritView:LoadCallBack()
	local tab_cfg = {
		{name = Language.JingLing.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_sprite", tab_index = TabIndex.spirit_spirit, func = "spirit_spirit", remind_id = RemindName.SpiritInfo},	--仙宠
		{name = Language.JingLing.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_icon_tujian", tab_index = TabIndex.spirit_lingpo, func = "spirit_lingpo", remind_id = RemindName.SpiritLingpo},	--图鉴
		{name = Language.JingLing.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_icon_leiqu", tab_index = TabIndex.spirit_hunt, func = "spirit_hunt", remind_id = RemindName.SpiritHunt},			--猎取
		{name = Language.JingLing.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_icon_qiyu", tab_index = TabIndex.spirit_meet, func = "spirit_meet", remind_id = RemindName.SpiritMeet},			--奇遇
		{name = Language.JingLing.TabbarName[5], bundle = "uis/images_atlas", asset = "tab_icon_skill", tab_index = TabIndex.spirit_skill, func = "spirit_skill", remind_id = RemindName.SpiritSkill},		--技能
		{name = Language.JingLing.TabbarName[6], bundle = "uis/images_atlas", asset = "tab_icon_minghun", tab_index = TabIndex.spirit_soul, func = "spirit_soul", remind_id = RemindName.SpiritSoul},		--命魂
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TxtTitle"].text.text = Language.JingLing.TabbarName[1]
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.SpiritView, BindTool.Bind(self.GetUiCallBack, self))
end

function SpiritView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function SpiritView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function SpiritView:OpenCallBack()
	SpiritCtrl.Instance:SendHuntSpiritGetFreeInfo()
	PlayerCtrl.Instance:SendGetRoleCapability()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_REASON.JING_LING_HOME_REASON_DEF, main_role_vo.role_id)
	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function SpiritView:__delete()
	if PlayerPrefsUtil.GetInt("slotoldindex", 999) >= 8 then
		PlayerPrefsUtil.DeleteKey("slotoldindex")
	end

	if self.open_trigger_handle ~= nil then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end
end

function SpiritView:ReleaseCallBack()
	if self.son_spirit_view then
		self.son_spirit_view:DeleteMe()
		self.son_spirit_view = nil
	end

	if self.hunt_view then
		self.hunt_view:DeleteMe()
		self.hunt_view = nil
	end

	if self.soul_view then
		self.soul_view:DeleteMe()
		self.soul_view = nil
	end

	if self.son_skill_view then
		self.son_skill_view:DeleteMe()
		self.son_skill_view = nil
	end

	if self.lingpo_view then
		self.lingpo_view:DeleteMe()
		self.lingpo_view = nil
	end

	if self.meet_view then
		self.meet_view:DeleteMe()
		self.meet_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.SpiritView)
	end
end

function SpiritView:CloseCallBack()
	if nil ~= self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if nil ~= self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.hunt_view then
		self.hunt_view:CloseCallBack()
	end

	if self.son_spirit_view then
		self.son_spirit_view:CloseCallBack()
	end

	if self.soul_view then
		self.soul_view:CloseCallBack()
	end

	if self.son_skill_view then
		self.son_skill_view:CloseCallBack()
	end

	if self.meet_view then
		self.meet_view:CloseCallBack()
	end

	if self.lingpo_view then
		self.lingpo_view:OnClose()
	end

	if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	end
end

-- 物品不足，购买成功后刷新物品数量
function SpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.son_spirit_view then
		self.son_spirit_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.spirit_fazhen then
		if self.fazhen_view then
			self.fazhen_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	elseif cur_index == TabIndex.spirit_halo then
		if self.halo_view then
			self.halo_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	elseif cur_index == TabIndex.spirit_skill then
		if self.son_skill_view then
			self.son_skill_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	elseif cur_index == TabIndex.spirit_lingpo then
		if self.lingpo_view then
			self.lingpo_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
		end
	end
	if (self.auto_equip_time == nil or self.auto_equip_time < Status.NowTime) and old_num < new_num then
		self.auto_equip_time = Status.NowTime + 2
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
		if SpiritData.Instance:HasNotSprite() and item_cfg and EquipData.IsJLType(item_cfg.sub_type) then
			PackageCtrl.Instance:SendUseItem(index, 1, 0, item_cfg.need_gold)
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
							0, 0, 0, 0, item_cfg.name)
		end
	end
end

-- 切换标签调用
function SpiritView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.spirit_spirit then
			self.son_spirit_view = SonSpiritView.New(index_nodes["SpiritContent"])

		elseif index == TabIndex.spirit_lingpo then
			self.lingpo_view = SpiritLingPoView.New(index_nodes["SpiritLingPo"])

		elseif index == TabIndex.spirit_hunt then
			self.hunt_view = SpiritHuntView.New(index_nodes["HuntContent"])

		elseif index == TabIndex.spirit_meet then
			self.meet_view = SpiritMeetView.New(index_nodes["MeetContent"])
		elseif index == TabIndex.spirit_skill then
			self.son_skill_view = SonSkillView.New(index_nodes["SkillContent"])

		elseif index == TabIndex.spirit_soul then
			self.soul_view = SpiritSoulView.New(index_nodes["SoulContent"])
		end
	end

	self:ChangeTabIcon(index)
	self:StopChouHun()
	self:CloseRollingView(index)

	if index ~= TabIndex.spirit_spirit then
		if self.son_spirit_view then
			self.son_spirit_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_hunt then
		if self.hunt_view then
			self.hunt_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_soul then
		if self.soul_view then
			self.soul_view:CloseCallBack()
		end
	end

	if index ~= TabIndex.spirit_skill then
		if self.son_skill_view then
			self.son_skill_view:CloseCallBack()
		end
	end

	if index == TabIndex.spirit_spirit then
		local callback = function()
			if self.son_spirit_view then
				self.son_spirit_view:OpenCallBack()
				self.son_spirit_view:UITween()
			end
			-- self:Flush("flush_son_spirit_view_opencallback")
			UIScene:SetBackground("uis/rawimages/bg_xianchong", "bg_xianchong.jpg")
			UIScene:SetTerraceBg("uis/rawimages/taizi_xianchong", "taizi_xianchong.png",  {position = Vector3(-180, -255, 0)}, nil)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(3, -170, 0)
			UIScene:SetCameraTransform(transform)

			if self.node_list["BaseFullPanel_1"].gameObject.activeSelf then
				self.node_list["BaseFullPanel_1"]:SetActive(false)
			end
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.spirit_lingpo then
		local callback = function()
			self.lingpo_view:ShowIndexToGetSortList()
			self.lingpo_view:Flush()
			self.lingpo_view:Flush("flush_modle", {[1] = true})
			self.lingpo_view:UITween()
			UIScene:SetBackground("uis/rawimages/bg_xianchong", "bg_xianchong.jpg")
			UIScene:SetTerraceBg("uis/rawimages/taizi_xianchong", "taizi_xianchong.png",  {position = Vector3(-139, -252, 0)}, nil)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(3, -172, 0)
			UIScene:SetCameraTransform(transform)

			if self.node_list["BaseFullPanel_1"].gameObject.activeSelf then
				self.node_list["BaseFullPanel_1"]:SetActive(false)
			end
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.spirit_hunt then
		local callback = function()
			if self.hunt_view then
				self:Flush("hunt")
				self:SetExchangeScore()
				self.hunt_view:UITween()
			end
			self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_xianchong_liequ", "bg_xianchong_liequ.jpg", function()
				self.node_list["TaiZi"]:SetActive(false)
				self.node_list["BaseFullPanel_1"]:SetActive(true)
				self.node_list["UnderBg"]:SetActive(true)
			end)
		end
		UIScene:ChangeScene(self, callback)
		-- 判断是否打开弹幕
		if RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING) then
			return
		end
		-- 弹幕的屏蔽，不要删了
		-- RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		-- ViewManager.Instance:Open(ViewName.RollingBarrageView)

	elseif index == TabIndex.spirit_meet then
		local callback = function()
			if self.meet_view then
				self.meet_view:OpenCallBack()
				self.meet_view:UITween()
				self.meet_view:Flush()
			end
			self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_xianchong_qiyu", "bg_xianchong_qiyu.jpg", function()
				self.node_list["TaiZi"]:SetActive(false)
				self.node_list["BaseFullPanel_1"]:SetActive(true)
				self.node_list["UnderBg"]:SetActive(true)
			end)
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.spirit_skill then
		local callback = function()
			if self.son_skill_view then
				self.son_skill_view:OpenCallBack()
				self.son_skill_view:UITween()
			end
			self.son_skill_view:Flush()
			UIScene:SetBackground("uis/rawimages/bg_xianchong", "bg_xianchong.jpg")
			UIScene:SetTerraceBg("uis/rawimages/taizi_xianchong", "taizi_xianchong.png",  {position = Vector3(-180, -255, 0)}, nil)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(3, -170, 0)
			UIScene:SetCameraTransform(transform)

			if self.node_list["BaseFullPanel_1"].gameObject.activeSelf then
				self.node_list["BaseFullPanel_1"]:SetActive(false)
			end
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.spirit_soul then
		local callback = function()
			self:SetHunLiNum()
			self:OpenSoul()
			self.soul_view:UITween()
			UIScene:SetBackground("uis/rawimages/bg_xianchong", "bg_xianchong.jpg")
			UIScene:SetTerraceBg("uis/rawimages/taizi_xianchong", "taizi_xianchong.png",  {position = Vector3(-281, -291, 0)}, nil)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(3, -165, 0)
			UIScene:SetCameraTransform(transform)

			if self.node_list["BaseFullPanel_1"].gameObject.activeSelf then
				self.node_list["BaseFullPanel_1"]:SetActive(false)
			end
		end
		UIScene:ChangeScene(self, callback)
	end

	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -15, 0)
		end
	end

	UIScene:SetModelLoadCallBack(call_back)
end

-- 关闭仙宠猎取的弹幕
function SpiritView:CloseRollingView(index)
	if index ~= TabIndex.spirit_hunt then
		if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
			ViewManager.Instance:Close(ViewName.RollingBarrageView)
		end
	end
end

-- 切换界面时停止抽命魂操作
function SpiritView:StopChouHun()
	if not self.soul_view then
		return
	end
	local state = SpiritData.Instance:GetQuickChangeLifeState()
	if state == QUICK_FLUSH_STATE.CHOU_HUN_ZHONG then
		self.soul_view:OnClickAutoChangeLige()
	end
end

-- 仙宠顶部积分、魂力、绑元等显示设置 --
function SpiritView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 设置元宝、绑元
function SpiritView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	elseif attr_name == "hunli" then
		self:SetHunLiNum()
	elseif attr_name == "bind_gold" then
		local cur_index = self:GetShowIndex()
		if cur_index ~= TabIndex.spirit_hunt and cur_index ~= TabIndex.spirit_soul then
			self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
		end
	end
end

-- 设置兑换积分
function SpiritView:SetExchangeScore()
	local count = SpiritData.Instance:GetSpiritExchangeScore()
	self.node_list["BindGoldText"].text.text = CommonDataManager.ConverNum(count)
end

-- 设置魂力
function SpiritView:SetHunLiNum()
	local count =SpiritData.Instance:GetSpiritSlotSoulInfo().total_exp
	self.node_list["BindGoldText"].text.text = CommonDataManager.ConverNum(count)
end

-- 改变顶部标签显示积分、魂力
function SpiritView:ChangeTabIcon(index)
	if self.node_list["ImgBindGold"] then
		if index == TabIndex.spirit_hunt then
			self.node_list["ImgBindGold"].image:LoadSprite("uis/views/spiritview/images_atlas", "icon_jifen", function ()
				self.node_list["ImgBindGold"].rect.sizeDelta = Vector3(45, 45, 0)
			end)
			self.node_list["ImgBindGold"].button:AddClickListener(function ()
					TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_SPIRIT_JIFEN})
			end)
		elseif index == TabIndex.spirit_soul then
			self.node_list["ImgBindGold"].image:LoadSprite("uis/views/spiritview/images_atlas", "icon_hunli", function ()
				self.node_list["ImgBindGold"].rect.sizeDelta = Vector3(50, 50, 0)
			end)
			self.node_list["ImgBindGold"].button:AddClickListener(function ()
					TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_SPIRIT_SOUL})
			end)
		else
			self.node_list["ImgBindGold"].image:LoadSprite("uis/images_atlas", "icon_gold_5_bind", function()
					self.node_list["ImgBindGold"].image:SetNativeSize()
			end)
			self.node_list["ImgBindGold"].button:AddClickListener(function ()
				TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL})
			end)
			self:PlayerDataChangeCallback("bind_gold")
		end
	end
end
-- 仙宠顶部积分、魂力、绑元等显示设置END --

function SpiritView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.spirit_spirit and self.son_spirit_view then
				self.son_spirit_view.is_click_item = false
				local open_param = SpiritData.Instance:GetOpenParam()
				if nil ~= open_param then
					SpiritData.Instance:ClearOpenParam()
					if open_param == "spirit_wuxing" then
						self:OpenAptitudeView()
					elseif open_param == "spirit_grow" then
						self:OpenAttrView()
					end
				end
				self.son_spirit_view:Flush()
			elseif cur_index == TabIndex.spirit_hunt and self.hunt_view then
				self.hunt_view:Flush()
				self:SetExchangeScore()
			elseif cur_index == TabIndex.spirit_soul and self.soul_view then
				self.soul_view:Flush()
				self:SetHunLiNum()
			elseif cur_index == TabIndex.spirit_skill and self.son_skill_view then
				self.son_skill_view:Flush()
			elseif cur_index == TabIndex.spirit_mee and self.meet_view then
				self.meet_view:Flush()
			end

		elseif k == "spirit" then
			if cur_index == TabIndex.spirit_spirit and self.son_spirit_view then
				self.son_spirit_view:Flush()
			end

		elseif k == "from_bag" then
			if cur_index == TabIndex.spirit_spirit and self.son_spirit_view then
				self.son_spirit_view:OnClickBackPack()
			end

		elseif k == "hunt" then
			if cur_index == TabIndex.spirit_hunt and self.hunt_view then
				self.hunt_view:Flush()
			end

		elseif k == "exchange" then
			if cur_index == TabIndex.spirit_hunt and self.hunt_view then
				self:SetExchangeScore()
			end

		elseif k == "ling_po" then
			if cur_index == TabIndex.spirit_lingpo and self.lingpo_view then
				self.lingpo_view:Flush()
			end

		elseif k == "ling_po_slider" then
			if cur_index == TabIndex.spirit_lingpo and self.lingpo_view then
				self.lingpo_view:FlushSlider(true)
			end

		elseif k == "ling_po_model" then
			if cur_index == TabIndex.spirit_lingpo and self.lingpo_view then
				self.lingpo_view:Flush("flush_modle", {[1] = true})
			end

		elseif k == "flush_meet" then
			if cur_index == TabIndex.spirit_meet and self.meet_view then
				self.meet_view:Flush()
			end

		elseif k == "flush_son_spirit_view_opencallback" then
			if cur_index == TabIndex.spirit_spirit and self.son_spirit_view then
				self.son_spirit_view:OpenCallBack()
			end
		elseif k == "spirit_egg_pos_info" then
			if cur_index == TabIndex.spirit_meet and self.meet_view then
				self.meet_view:Flush("spirit_egg_pos_info")
			end
		end

	end
end

function SpiritView:OpenAttrView()
	if self.son_spirit_view then
		self.son_spirit_view:OpenTagView(true)
	end
end

function SpiritView:OpenAptitudeView()
	if self.son_spirit_view then
		self.son_spirit_view:OpenTagView(false)
	end
end

-- 仙宠命魂 --
function SpiritView:SoulQuickFlushButtonState(state)
	if self.soul_view then
		self.soul_view:ShowButtonState(state)
	end
end

function SpiritView:IsOpenSoulView()
	if self.soul_view then
		return true
	end
	return false
end

function SpiritView:OpenSoul()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local bit_list = bit:d2b(slot_soul_info and slot_soul_info.slot_activity_flag or {})
	local hunli = GameVoManager.Instance:GetMainRoleVo().hunli
	local index = 0
	if bit_list then
		for k, v in pairs(bit_list) do
			if v == 1 then
				index = index + 1
			end
		end
		if index > 0 then
			PlayerPrefsUtil.SetInt("slotoldindex", index)
		end
	end

	if self.soul_view then
		self.soul_view:Flush()
	end
	self:SetHunLiNum()
end
-- 仙宠命魂END --

-- 获取仙宠面板，用于幻化返回时播放UI动画
function SpiritView:GetSonSpiritView()
	if self.son_spirit_view then
		return self.son_spirit_view
	end
end

-- 打开仓库
function SpiritView:OpenWarehouse()
	if self.hunt_view then 
		self.hunt_view:OpenCangKu()
	end
end


function SpiritView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if self.tabbar:GetTabButton(index) then
			local root_node = self.tabbar:GetTabButton(index).root_node
			local callback = BindTool.Bind(self.ChangeToIndex, self, index)
			if index == self.show_index then
				return NextGuideStepFlag
			else
				return root_node, callback
			end
		end
	elseif ui_name == GuideUIName.SpiritChoose then
		if self.son_spirit_view then
			return self.son_spirit_view:GetSonGuide()
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