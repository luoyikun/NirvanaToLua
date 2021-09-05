ShenShouStuffTip = ShenShouStuffTip or BaseClass(BaseView)

function ShenShouStuffTip:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "ShenShouStuffTip"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenShouStuffTip:ReleaseCallBack()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ShenShouStuffTip:LoadCallBack()
	self.cell = ShenShouEquip.New()
	self.cell:SetInstanceParent(self.node_list["Item"])
	self.cell:SetInteractable(false)

	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function ShenShouStuffTip:ShowIndexCallBack(index)
	self:Flush()
end

function ShenShouStuffTip:OnFlush(param_t, index)
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if nil == shenshou_equip_cfg then return end
	self.cell:SetData(self.data)

	local color = shenshou_equip_cfg.quality
	self.node_list["TxtName"].text.text = string.format("<color=%s>%s</color>", ITEM_TIP_COLOR[color + 1], shenshou_equip_cfg.name)

	self.node_list["TxtAttrText1"].text.text = shenshou_equip_cfg.description
end

function ShenShouStuffTip:SetData(data)
	if nil == data then return end
	self.data = data
	self:Open()
	self:Flush()
end