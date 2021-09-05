TipJueXingView = TipJueXingView or BaseClass(BaseView)

function TipJueXingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab","TipJueXingView"},
	}
	self.play_audio = true
	self.info = nil
	self.cur_index = nil
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipJueXingView:__delete()
	
end

function TipJueXingView:ReleaseCallBack()
	self.select_index = nil
end

function TipJueXingView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(450, 450, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close,self))
	self.node_list["Txt"].text.text = Language.Forge.JueXingYuLan
	self.select_index = 0

end

function TipJueXingView:CloseCallBack()
	self.select_index = nil
end

function TipJueXingView:OpenCallBack()
	
end

function TipJueXingView:SetData(equip_index)
	self.select_index = equip_index
	if self.select_index == nil then
		return
	end
	local max_level = ForgeData.Instance:GetJueXingMaxLevelByIndex(self.select_index)
	local good_attr_list = ForgeData.Instance:GetJueXingGoodAttrByIndex(self.select_index)
	local good_attr_list_cfg = ForgeData.Instance:GetJueXingGoodAttrCfg(good_attr_list, max_level)
	for i=1, 4 do
		local bundle, asset = ResPath.GetForgeJueXingIcon(good_attr_list_cfg[i].icon_id)
		self.node_list["Image" .. i].image:LoadSprite(bundle, asset)
		self.node_list["SkillName" .. i].text.text = good_attr_list_cfg[i].skill_name
		self.node_list["SkillDec" .. i].text.text = good_attr_list_cfg[i].skill_dec
		self.node_list["SkillLevel" .. i].text.text = Language.Forge.JueXingDec3
	end
end

function TipJueXingView:OnFlush()
	
end




