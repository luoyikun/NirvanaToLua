TipsCommonWarmView = TipsCommonWarmView or BaseClass(BaseView)

function TipsCommonWarmView:__init()
	self.ui_config = {{"uis/views/tips/commontips_prefab", "CommonWarmTips"}}
	self.open_view = nil
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.content_des = ""
end

function TipsCommonWarmView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsCommonWarmView:OpenCallBack() 
	self:Flush()
end

function TipsCommonWarmView:ReleaseCallBack()

end

function TipsCommonWarmView:OnClickClose()
	self:Close()
end

function TipsCommonWarmView:SetDes(des)
	self.content_des = des or ""
end

function TipsCommonWarmView:OnFlush(param_list)
	self.node_list["TxtTips"].text.text = self.content_des
end