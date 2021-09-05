TipsReminding = TipsReminding or BaseClass(BaseView)

function TipsReminding:__init()
	self.ui_config = {{"uis/views/tips/remindingtips_prefab", "RemindingTips"}}
	self.view_layer = UiLayer.Pop

	self.notice = ""
	self.play_audio = true
	self.is_modal = true
end

function TipsReminding:__delete()
end

function TipsReminding:ReleaseCallBack()
end

function TipsReminding:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
end

function TipsReminding:ClickClose()
	self:Close()
end

function TipsReminding:SetNotice(notice)
	self.notice = notice or ""
	self:Flush()
end

function TipsReminding:OnFlush()
	self.node_list["TxtStr"].text.text = self.notice
end