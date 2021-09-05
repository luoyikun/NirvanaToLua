AdvanceHuanHuaView = AdvanceHuanHuaView or BaseClass(BaseView)

function AdvanceHuanHuaView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		-- {"uis/views/imagefuling_prefab", "FuLingContentView", {TabIndex.img_fuling_content}},
		{"uis/views/advanceview_prefab", "ModelDragLayer"}, 
		{"uis/views/advanceview_prefab", "AdvanceHuanHuaContent",{TabIndex.mount_huanhua}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.play_audio = true
	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.def_index = TabIndex.mount_huanhua
	self.play_audio = true
end

function AdvanceHuanHuaView:__delete()
end

function AdvanceHuanHuaView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.img_fuling_view ~= nil then
		self.img_fuling_view:DeleteMe()
		self.img_fuling_view = nil
	end

	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end 

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

end

function AdvanceHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		if self.huan_hua_view then
			self.huan_hua_view:CloseCallBack()
		end
	end
end

function AdvanceHuanHuaView:LoadCallBack()
	local bundle, asset = AdvanceData.Instance:GetTabIcon()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = bundle, asset = asset, tab_index = TabIndex.mount_huanhua, remind_id = RemindName.HuanHua,},
		-- {name = Language.ImageFuLing.DouKaiName, bundle = "uis/images_atlas", asset = "icon_tab_doukai", func = "img_fuling_content", tab_index = TabIndex.img_fuling_content, remind_id = RemindName.ImgFuLing,},
	}
	self.def_index = TabIndex.img_fuling_content
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TxtTitle"].text.text = Language.Title.HuanHua
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	-- self.node_list["UnderBg"]:SetActive(true)
	-- self.node_list["TaiZi"].transform.localPosition = Vector3(-135, -272, 0)
	-- self:SetBg()
end

function AdvanceHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	local fuling_type = AdvanceData.Instance:GetImageFulingType()
	if index_nodes then
		if index == TabIndex.img_fuling_content then
			self.img_fuling_view = ImageFuLingContentView.New(index_nodes["FuLingContentView"])
		elseif index == TabIndex.mount_huanhua then
			self.huan_hua_view = AdvanceHuanHuaContent.New(index_nodes["AdvanceHuanHuaContent"])
		end
	end

	if index == TabIndex.img_fuling_content then
		self.img_fuling_view:OpenCallBack()
		self.img_fuling_view:SetCurSelectIndex(fuling_type, true)
		-- self.node_list["TaiZi"]:SetActive(false)
		self:Flush()
	elseif index == TabIndex.mount_huanhua then
		-- self.node_list["TaiZi"]:SetActive(true)

		local callback = function ()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-136, -275, 0)}, nil)
			if self.huan_hua_view then
				self.huan_hua_view:Flush("open_advance_huanhua_flush")
			end
		end
		UIScene:ChangeScene(self, callback)
	end
end

-- function AdvanceHuanHuaView:SetBg(index)
-- 	local call_back = function ()
-- 		self.node_list["UnderBg"]:SetActive(true)
-- 	end
-- 	if index == TabIndex.img_fuling_content then
-- 		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_xianchong", "bg_xianchong.jpg", call_back)
-- 	elseif index == TabIndex.mount_huanhua then
-- 		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_common1_under", "bg_common1_under.jpg", call_back)
-- 	end
-- end

function AdvanceHuanHuaView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
end

function AdvanceHuanHuaView:OpenCallBack()
	AdvanceData.Instance:SetViewType(1)
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	
	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	RemindManager.Instance:Fire(RemindName.HuanHua)
end

function AdvanceHuanHuaView:CloseCallBack()
	if self.img_fuling_view then
		self.img_fuling_view:CloseCallBack()
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.huan_hua_view then
		self.huan_hua_view:CloseCallBack()
	end
end

function AdvanceHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AdvanceHuanHuaView:ItemDataChangeCallback()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.img_fuling_content then
		self.img_fuling_view:ItemDataChangeCallback()
	end
end

function AdvanceHuanHuaView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_list) do
		if k == "mounthuanhua" or k == "winghuanhua" or k == "halohuanhua"
			or k == "foothuanhua" or k == "fightmounthuanhua" or k == "fabaohuanhua"
			or k == "fashionhuanhua" or k == "wuqihuanhuaview" then
			if self.huan_hua_view then
				self.huan_hua_view:Flush(k, v)
			end
		elseif k == "all"then
			if cur_index == TabIndex.img_fuling_content then
				if self.img_fuling_view and cur_index == TabIndex.img_fuling_content then
					self.img_fuling_view:Flush()
				end
			end
		end
	end
	self.tabbar:FlushTabbar()
	-- 刷新完侧标签后，要修改一下对应的icon
	local tab_button = self.tabbar:GetTabButton(TabIndex.mount_huanhua)
	local bundle, asset = AdvanceData.Instance:GetTabIcon()
	tab_button:InitTab({name = Language.Common.Huanhua, bundle = bundle, asset = asset})
end


