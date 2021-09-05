require("game/marriage/shengdi/shengdi_equip_view")

QingYuanShengDiView = QingYuanShengDiView or BaseClass(BaseRender)

function QingYuanShengDiView:__init(instance, mother_view)
	self.tab_index = TabIndex.marriage_shengdi
	self.node_list["equip_fuben"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.shengdi_equip_view = ShengDiEquipView.New(obj, self)
		self.shengdi_equip_view:OpenCallBack()
	end)

	self.red_point_list = {
		[RemindName.MarryShengDi] = self.node_list["ImgRemind"],
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

end

function QingYuanShengDiView:__delete()
	if self.shengdi_equip_view then
		self.shengdi_equip_view:DeleteMe()
		self.shengdi_equip_view = nil
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function QingYuanShengDiView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function QingYuanShengDiView:ShowOrHideTab()

end

function QingYuanShengDiView:OnToggleChange(index, is_on)
	if is_on then
		self.tab_index = index
		if self.tab_index == TabIndex.marriage_shengdi and self.shengdi_equip_view then
			self.shengdi_equip_view:OpenCallBack()
		end
	end
end

function QingYuanShengDiView:OpenCallBack()
	if self.tab_index == TabIndex.marriage_shengdi and self.shengdi_equip_view then
		self.shengdi_equip_view:OpenCallBack()
	end
end

function QingYuanShengDiView:OnFlush()
	if self.tab_index == TabIndex.marriage_shengdi and self.shengdi_equip_view then
		self.shengdi_equip_view:Flush()
	end
end