-- 仙宠-阵法-已屏蔽
TipsSpiritZhenFaValueView = TipsSpiritZhenFaValueView or BaseClass(BaseView)

function TipsSpiritZhenFaValueView:__init()
	self.ui_config = {{"uis/views/tips/spiritzhenfatip_prefab", "SpiritZhenfaValueTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
end

function TipsSpiritZhenFaValueView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
end

function TipsSpiritZhenFaValueView:__delete()

end

function TipsSpiritZhenFaValueView:ReleaseCallBack()
	
end

function TipsSpiritZhenFaValueView:CloseCallBack()
	
end

function TipsSpiritZhenFaValueView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritZhenFaValueView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_attr_list = SpiritData.Instance:GetZhenfaAttrList()
	self.node_list["TxtZhanfa"].text.text = zhenfa_attr_list.zhenfa_rate .. "%"
	self.node_list["TxtDeFenseHunyu"].text.text = zhenfa_attr_list.attackhunyu_rate .. "%"
	self.node_list["TxtAttackHunYu"].text.text = zhenfa_attr_list.lifehunyu_rate .. "%"
	self.node_list["TxtLifeHunYu"].text.text = zhenfa_attr_list.defensehunyu_rate .. "%"
	self.node_list["TxtUpLife"].text.text = math.ceil(zhenfa_attr_list.max_hp) + SpiritData.Instance:GetZhenfaCfgByLevel(spirit_info.xianzhen_level).maxhp
	self.node_list["TxtUpAttack"].text.text = math.ceil(zhenfa_attr_list.gong_ji)
	self.node_list["TxtUpDefense"].text.text = math.ceil(zhenfa_attr_list.fang_yu)
end
