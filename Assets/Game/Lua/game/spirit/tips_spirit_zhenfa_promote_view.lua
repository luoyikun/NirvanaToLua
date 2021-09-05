-- 仙宠-阵法-已屏蔽
-- require("game/spirit/xianzhen_upgrade_view")
-- require("game/spirit/hunyu_upgrade_view")
TipsSpiritZhenFaPromoteView = TipsSpiritZhenFaPromoteView or BaseClass(BaseView)
local TAB_BAR = {
		XIANZHEN = 1,
		HUNYU = 2,
	}
function TipsSpiritZhenFaPromoteView:__init()
	self.ui_config = {{"uis/views/tips/spiritzhenfatip_prefab", "SpiritZhenfaPromoteTip"}}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.data = nil
	self.play_audio = true
	self.is_modal = true
end

function TipsSpiritZhenFaPromoteView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	local xianzhen_upgrade_content = self.node_list["xianzhenupgrade_content"]
	xianzhen_upgrade_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.xianzhen_upgrade_view = XianZhenUpGradeView.New(obj)
		self.xianzhen_upgrade_view:Flush()
	end)
	local hunyu_upgrade_content = self.node_list["hunyuupgrade_content"]
	hunyu_upgrade_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.hunyu_upgrade_view = HunYuUpGradeView.New(obj)
		self.hunyu_upgrade_view:Flush()
	end)
	self.node_list["lingzhen_toggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TAB_BAR.XIANZHEN))
	self.node_list["hunshouyu_toggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TAB_BAR.HUNYU))
end

function TipsSpiritZhenFaPromoteView:__delete()

end

function TipsSpiritZhenFaPromoteView:ReleaseCallBack()
	-- 清理变量
	if self.xianzhen_upgrade_view then
		self.xianzhen_upgrade_view:DeleteMe()
		self.xianzhen_upgrade_view = nil
	end
	if self.hunyu_upgrade_view then
		self.hunyu_upgrade_view:DeleteMe()
		self.hunyu_upgrade_view = nil
	end
end

function TipsSpiritZhenFaPromoteView:OnToggleChange(index, is_on)
	if is_on then
		self:ShowIndex(index)
	end
end

function TipsSpiritZhenFaPromoteView:OpenCallBack()

end

function TipsSpiritZhenFaPromoteView:CloseCallBack()
	
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end

end

function TipsSpiritZhenFaPromoteView:SetData(tab_index)

end

function TipsSpiritZhenFaPromoteView:ShowIndexCallBack(index)
	if index == TAB_BAR.XIANZHEN and not self.node_list["lingzhen_toggle"].toggle.isOn then
		self.node_list["lingzhen_toggle"].toggle.isOn = true
	elseif index == TAB_BAR.HUNYU and not self.node_list["hunshouyu_toggle"].toggle.isOn then
	 	self.node_list["hunshouyu_toggle"].toggle.isOn = true
	end
	self:Flush()
end

function TipsSpiritZhenFaPromoteView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritZhenFaPromoteView:OnFlush()
	if nil ~= self.xianzhen_upgrade_view then
		self.xianzhen_upgrade_view:Flush()
	end
	if nil ~= self.hunyu_upgrade_view then
		self.hunyu_upgrade_view:Flush()
	end
	self.node_list["RedPoint1"]:SetActive(SpiritData.Instance:CanXianZhenUp())
	self.node_list["RedPoint2"]:SetActive(SpiritData.Instance:ShowAllHunyuRedPoint())

end