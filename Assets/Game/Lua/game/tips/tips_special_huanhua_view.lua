TipsSpecialHuanHuaView = TipsSpecialHuanHuaView or BaseClass(BaseView)

function TipsSpecialHuanHuaView:__init()
	self.ui_config = {{"uis/views/tips/specailhuanhuatips_prefab", "TipsSpecialHuanHuaView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSpecialHuanHuaView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"], "FightPower3")
end

function TipsSpecialHuanHuaView:ReleaseCallBack()
	self.fight_text = nil
end

function TipsSpecialHuanHuaView:OpenCallBack()
	self:Flush()
end

function TipsSpecialHuanHuaView:SetData(data)
	self.data = data
end

function TipsSpecialHuanHuaView:OnFlush()
	self.node_list["Hp"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["hp"], self.data.max_hp)
	self.node_list["Gongji"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["gongji"], self.data.gong_ji)
	self.node_list["Fangyu"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["fangyu"], self.data.fang_yu)
	self.node_list["Desc"].text.text = self.data.desc
	--设置战斗力
	local cap = CommonDataManager.GetCapabilityCalculation(self.data)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cap
	end
end