TipsGetNewitemView = TipsGetNewitemView or BaseClass(BaseView)

function TipsGetNewitemView:__init()
	self.ui_config = {{"uis/views/tips/getnewitemtips_prefab", "GetNewItemTips"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.id_value_list = {}
	self.is_async_load = true
end

function TipsGetNewitemView:__delete()
end

function TipsGetNewitemView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnReduce"].button:AddClickListener(BindTool.Bind(self.ChangeNumber, self, -1))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.ChangeNumber, self, 1))
	self.node_list["Btn01"].button:AddClickListener(BindTool.Bind(self.UseClick, self))

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function TipsGetNewitemView:ReleaseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end	
end

function TipsGetNewitemView:OpenView(item_id)
	self.item_data = {}
	self.item_data.item_id = item_id

	local is_add = true
	for k,v in pairs(self.id_value_list) do
		if v == item_id then
			 local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			 local bag_cfg = ItemData.Instance:GetItem(item_id)
			 if bag_cfg and item_cfg and bag_cfg.num < item_cfg.pile_limit then
			 	is_add = false
			 end
		end
	end
	if is_add then
		table.insert(self.id_value_list, item_id)
	end
	
	if not ViewManager.Instance:IsOpen(ViewName.TipsGetNewitemView) then
		local item_cfg = ItemData.Instance:GetItem(item_id)
		if item_cfg then
			self.number_value = item_cfg.num
			self.max_number = self.number_value
			self.item_data.num = item_cfg.num
			self:Open()
		end
	else
		self:Flush()
	end
end

function TipsGetNewitemView:OpenCallBack()
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.item_config = ItemData.Instance:GetItemConfig(self.id_value_list[1])
	local item_cfg = ItemData.Instance:GetItem(self.id_value_list[1])
	self.item_data.item_id = self.id_value_list[1]
	if self.item_config and item_cfg then
		self.number_value = item_cfg.num
		self.max_number = self.number_value
		self.item_data.num = item_cfg.num
		self.node_list["TxtItemName"].text.text = ToColorStr(self.item_config.name, ITEM_COLOR[self.item_config.color])
		self.item_cell:SetData(self.item_data)
		self.node_list["TxtImg"].text.text = self.number_value
	end
end

function TipsGetNewitemView:OnFlush()
	local item_cfg = ItemData.Instance:GetItem(self.id_value_list[1])
	self.item_data.item_id = self.id_value_list[1]
	self.item_config = ItemData.Instance:GetItemConfig(self.id_value_list[1])
	if self.item_config and item_cfg then
		self.number_value = item_cfg.num
		self.max_number = self.number_value
		self.item_data.num = item_cfg.num
		self.node_list["TxtItemName"].text.text = ToColorStr(self.item_config.name, ITEM_COLOR[self.item_config.color])
		self.item_cell:SetData(self.item_data)
		self.node_list["TxtImg"].text.text = self.number_value
	end
end

function TipsGetNewitemView:CloseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	self.id_value_list = {}
end

function TipsGetNewitemView:OnChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end

function TipsGetNewitemView:UseClick()
	local bag_data = ItemData.Instance:GetItem(self.id_value_list[1])
	if bag_data and self.item_config then
		if self.item_config.use_type then
			local is_advance, is_jump, model_name, advane_type = AdvanceData.Instance:GetjumpModel(self.item_config)
			if advane_type and self.number_value and self.number_value > 1 then
				if model_name then
					ViewManager.Instance:Open(model_name, nil, "all",{id = self.item_config.id})
					self:FlushList()
				else
					self:SetJump(self.item_config, self.item_config.param1)
				end
				return
			end
			if is_advance then
				self:SetJump(self.item_config, self.item_config.param1)
			else
				if is_jump and model_name then
					ViewManager.Instance:Open(model_name, nil, "all",{id = self.item_config.id})
					self:FlushList()
					return
				elseif WingData.Instance:IsShenCiHuanhuaIdAndCanJumpByItemId(self.item_config.id) then
					ViewManager.Instance:Open(ViewName.ShenCiWingHuanHua, TabIndex.shenci_wing_huan_hua, "winghuanhua", {id = self.item_config.id})
				elseif MountData.Instance:IsShenCiHuanhuaIdAndCanJumpByItemId(self.item_config.id) then
					ViewManager.Instance:Open(ViewName.ShenCiMountHuanHua, TabIndex.shenci_mount_huan_hua, "mounthuanhua", {id = self.item_config.id})
				end
			end
		end
		PackageCtrl.Instance:SendUseItem(bag_data.index, self.number_value, bag_data.sub_type, self.item_config.need_gold)
	end
	self:FlushList()
end

function TipsGetNewitemView:FlushList()
	table.remove(self.id_value_list, 1)
	if self.id_value_list[1] ~= nil then
		self:Flush()
	else
		self:Close()
	end
end

function TipsGetNewitemView:SetJump(item_cfg, param1)
	local jump_info = AdvanceData.Instance:GetJumpInfo(item_cfg.use_type, param1)
	if jump_info and jump_info.tabIndex and jump_info.fulingType and jump_info.flush_view then
		if jump_info.tabIndex == TabIndex.wing_huan_hua and WingData.Instance:IsShenCiHuanhuaIdByItemId(item_cfg.id) then
			ViewManager.Instance:Open(ViewName.ShenCiWingHuanHua, TabIndex.shenci_wing_huan_hua, jump_info.flush_view, {id = item_cfg.id})
		elseif jump_info.tabIndex == TabIndex.mount_huan_hua and MountData.Instance:IsShenCiHuanhuaIdByItemId(item_cfg.id) then
			ViewManager.Instance:Open(ViewName.ShenCiMountHuanHua, TabIndex.shenci_mount_huan_hua, jump_info.flush_view, {id = item_cfg.id})
		else
			AdvanceData.Instance:SetHuanHuaType(jump_info.tabIndex)
			AdvanceData.Instance:SetImageFulingType(jump_info.fulingType)
			ViewManager.Instance:Open(ViewName.AdvanceHuanhua, TabIndex.mount_huanhua, jump_info.flush_view, {jump_info.talent_type})
			AdvanceCtrl.Instance:FlushView(jump_info.flush_view, {id = item_cfg.id})
		end
	end
	self:FlushList()
end

function TipsGetNewitemView:ChangeNumber(number)
	local try_number = self.number_value
	try_number = try_number + number
	if try_number > 0 and try_number <= self.max_number then
		self.number_value = try_number
		self.node_list["TxtImg"].text.text = self.number_value
	end
end

function TipsGetNewitemView:CloseView()
	self:Close()
end