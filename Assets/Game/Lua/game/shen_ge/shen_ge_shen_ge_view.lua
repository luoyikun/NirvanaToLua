-- ShenGeShenGeView = ShenGeShenGeView or BaseClass(BaseRender)

-- function ShenGeShenGeView:__init(instance)
-- 	self.node_list["TabInlay"].toggle:AddClickListener(BindTool.Bind(self.OpenInlay, self))
-- 	self.node_list["TabBless"].toggle:AddClickListener(BindTool.Bind(self.OpenBless, self))
-- 	self.node_list["TabGroup"].toggle:AddClickListener(BindTool.Bind(self.OpenGroup, self))

-- 	self.node_list["ShenGeInlayContent"].uiprefab_loader:Wait(function(obj)
-- 		obj = U3DObject(obj)
-- 		self.shen_ge_inlay_view = ShenGeInlayView.New(obj)
-- 		if self.node_list["TopTabInlay"].toggle.isOn then
-- 			self.shen_ge_inlay_view:Flush()
-- 		end
-- 	end)

-- 	self.node_list["ShenGeBlessContent"].uiprefab_loader:Wait(function(obj)
-- 		obj = U3DObject(obj)
-- 		self.shen_ge_bless_view = ShenGeBlessView.New(obj)
-- 		if self.node_list["TopTabBless"].toggle.isOn then
-- 			self.shen_ge_bless_view:Flush()
-- 		end
-- 	end)

-- 	-- 神格组合
-- 	self.node_list["ShenGeGroupContent"] = self.node_list["ShenGeGroupContent"]
-- 	self.node_list["ShenGeGroupContent"].uiprefab_loader:Wait(function(obj)
-- 		obj = U3DObject(obj)
-- 		self.shen_ge_group_view = ShenGeGroupView.New(obj)
-- 		if self.node_list["TopTabGroup"].toggle.isOn then
-- 			self.shen_ge_group_view:Flush()
-- 		end
-- 	end)

-- 	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
-- 	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)

-- 	self.red_point_list = {
-- 		[RemindName.ShenGe_ShenGe] = self.node_list["ImgRemind"],
-- 		[RemindName.ShenGe_Bless] = self.node_list["ImgRemind1"],
-- 	}

-- 	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
-- 	for k, _ in pairs(self.red_point_list) do
-- 		RemindManager.Instance:Bind(self.remind_change, k)
-- 	end
-- end

-- function ShenGeShenGeView:__delete()
-- 	if self.shen_ge_inlay_view then
-- 		self.shen_ge_inlay_view:DeleteMe()
-- 		self.shen_ge_inlay_view = nil
-- 	end

-- 	if self.shen_ge_bless_view then
-- 		self.shen_ge_bless_view:DeleteMe()
-- 		self.shen_ge_bless_view = nil
-- 	end

-- 	if self.shen_ge_group_view then
-- 		self.shen_ge_group_view:DeleteMe()
-- 		self.shen_ge_group_view = nil
-- 	end

-- 	if nil ~= ShenGeData.Instance then
-- 		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
-- 		self.data_change_event = nil
-- 	end

-- 	if RemindManager.Instance then
-- 		RemindManager.Instance:UnBind(self.remind_change)
-- 	end
-- end

-- function SelectEquipView:OpenCallBack()
-- end

-- function ShenGeShenGeView:RemindChangeCallBack(remind_name, num)
-- 	if nil ~= self.red_point_list[remind_name] then
-- 		self.red_point_list[remind_name]:SetActive(num > 0)
-- 	end
-- end

-- function ShenGeShenGeView:OpenInlay()
-- 	if nil ~= self.shen_ge_inlay_view then
-- 		self.shen_ge_inlay_view:Flush()
-- 	end
-- end

-- function ShenGeShenGeView:OpenBless()
-- 	if nil ~= self.shen_ge_bless_view then
-- 		self.shen_ge_bless_view:Flush()
-- 	end
-- end

-- function ShenGeShenGeView:OpenGroup()
-- 	if nil ~= self.shen_ge_group_view then
-- 		self.shen_ge_group_view:Flush()
-- 	end
-- end

-- function ShenGeShenGeView:ShowIndexCallBack(index)
-- 	self:SetToggleState(index)
-- 	RemindManager.Instance:Fire(RemindName.ShenGe_Bless)
-- 	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)
-- end

-- function ShenGeShenGeView:OnDataChange(info_type, param1, param2, param3, bag_list)
-- 	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)

-- 	if self.node_list["TopTabInlay"].toggle.isOn and nil ~= self.shen_ge_inlay_view then
-- 		self.shen_ge_inlay_view:OnDataChange(info_type, param1, param2, param3, bag_list)
-- 	end

-- 	if (self.node_list["TopTabBless"].toggle.isOn or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO) and nil ~= self.shen_ge_bless_view then
-- 		self.shen_ge_bless_view:OnDataChange(info_type, param1, param2, param3, bag_list)
-- 		RemindManager.Instance:Fire(RemindName.ShenGe_Bless)
-- 	end

-- 	if self.node_list["TopTabGroup"].toggle.isOn and nil ~= self.shen_ge_group_view then
-- 		self.shen_ge_group_view:OnDataChange(info_type, param1, param2, param3, bag_list)
-- 	end
-- end

-- function ShenGeShenGeView:SetToggleState(index)
-- 	if nil ~= self.node_list["TopTabInlay"].toggle then
-- 		self.node_list["TopTabInlay"].toggle.isOn = (index == TabIndex.shen_ge_inlay) or (index == TabIndex.shen_ge_compose)
-- 		self:OpenShenGeCompose(index)
-- 	end
-- 	if nil ~= self.node_list["TopTabBless"].toggle then
-- 		self.node_list["TopTabBless"].toggle.isOn = index == TabIndex.shen_ge_bless
-- 	end
-- 	if nil ~= self.node_list["TopTabGroup"].toggle then
-- 		self.node_list["TopTabGroup"].toggle.isOn = index == TabIndex.shen_ge_group
-- 	end
-- end

-- function ShenGeShenGeView:OpenShenGeCompose(index)
-- 	if TabIndex.shen_ge_compose ~= index then
-- 		return
-- 	end
-- 	ViewManager.Instance:Open(ViewName.ShenGeComposeView)
-- end

-- function ShenGeShenGeView:OnFlush(param_list)
-- end