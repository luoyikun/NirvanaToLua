TipsOtherPortraitView = TipsOtherPortraitView or BaseClass(BaseView)

function TipsOtherPortraitView:__init()
	self.ui_config = {{"uis/views/tips/portraittips_prefab", "OtherPortraitTip"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsOtherPortraitView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsOtherPortraitView:ReleaseCallBack()
end

function TipsOtherPortraitView:OpenCallBack()
	self:Flush()
end

function TipsOtherPortraitView:OnClickClose()
	self:Close()
end

function TipsOtherPortraitView:SetData(data)
	self.data = data
end

function TipsOtherPortraitView:OnFlush()
	if nil == self.data then return end
	local info = self.data
	AvatarManager.Instance:SetAvatar(info.role_id, self.node_list["raw_image_obj"], self.node_list["image_obj"], info.sex, info.prof, false)
end