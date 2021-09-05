LittlePetRecycleSelectView = LittlePetRecycleSelectView or BaseClass(BaseView)

function LittlePetRecycleSelectView:__init()
	self.ui_config = {{"uis/views/littlepetview_prefab","LittlePetAutoRecycle"}}
	-- self.play_audio = true
    self.open_tween = UITween.ShowFadeUp
    self.close_tween = UITween.HideFadeUp
end

function LittlePetRecycleSelectView:__delete()

end

function LittlePetRecycleSelectView:ReleaseCallBack()

end

function LittlePetRecycleSelectView:OpenCallBack()
end

function LittlePetRecycleSelectView:CloseCallBack()
	self.call_back = nil
end

function LittlePetRecycleSelectView:SetCallBack(call_back)
	self.call_back = call_back
end

function LittlePetRecycleSelectView:LoadCallBack()
	self.node_list["Bg"].button:AddClickListener(BindTool.Bind(self.Close, self))
	for i = 1, 4 do
		self.node_list["Btn" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickBtn, self, i))
	end
end

function LittlePetRecycleSelectView:OnClickBtn(i)
	if self.call_back then
		self.call_back(i)
	end
	self:Close()
end