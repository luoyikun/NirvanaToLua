require("game/marriage/equip/marry_equip_info_view")
require("game/marriage/equip/marry_equip_suit_view")
require("game/marriage/equip/marry_equip_recyle_info_view")

MarryEquipContentView = MarryEquipContentView or BaseClass(BaseRender)

function MarryEquipContentView:__init(instance, mother_view)
	self.tab_index = TabIndex.marriage_equip
	self.node_list["EquipView"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_view = MarryEquipInfoView.New(obj, self)
		self.equip_view:OpenCallBack()
	end)

	self.node_list["SuitView"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.suit_view = MarryEquipSuitView.New(obj, self)
		self.suit_view:OpenCallBack()
	end)

	self.node_list["RecyleView"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.recyle_view = MarryEquipReclyeInfoView.New(obj, self)
		self.recyle_view:OpenCallBack()
	end)

	self.node_list["Tab1"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip))
	self.node_list["Tab2"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip_suit))
	self.node_list["Tab3"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip_recyle))
end

function MarryEquipContentView:__delete()
	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.recyle_view then
		self.recyle_view:DeleteMe()
		self.recyle_view = nil
	end
end

function MarryEquipContentView:ShowOrHideTab()

end

function MarryEquipContentView:OnToggleChange(index, is_on)
	if is_on then
		self.tab_index = index
		if self.tab_index == TabIndex.marriage_equip and self.equip_view then
			self.equip_view:OpenCallBack()
		elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
			MarryEquipCtrl.SendActiveLoverEquipInfo()
			self.suit_view:OpenCallBack()
		elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
			MarryEquipCtrl.SendActiveLoverEquipInfo()
			self.recyle_view:OpenCallBack()
		end
	end
end

function MarryEquipContentView:OpenCallBack()
	MarryEquipCtrl.SendActiveLoverEquipInfo()
	if self.tab_index == TabIndex.marriage_equip and self.equip_view then
		self.equip_view:OpenCallBack()
	elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
		self.suit_view:OpenCallBack()
	elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
		self.recyle_view:OpenCallBack()
	end
	self:UpdateRemind()
end

function MarryEquipContentView:OnFlush(param_t)
	self:UpdateRemind()
	if self.tab_index == TabIndex.marriage_equip and self.equip_view then
		self.equip_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
		self.suit_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
		self.recyle_view:Flush()
	end
end

function MarryEquipContentView:UpdateRemind()
	local remind_m = RemindManager.Instance
	self.node_list["RedPoint1"]:SetActive(remind_m:GetRemind(RemindName.MarryEquip) > 0)
	self.node_list["RedPoint2"]:SetActive(remind_m:GetRemind(RemindName.MarrySuit) > 0)
	self.node_list["RedPoint3"]:SetActive(remind_m:GetRemind(RemindName.MarryEquipRecyle) > 0)
end