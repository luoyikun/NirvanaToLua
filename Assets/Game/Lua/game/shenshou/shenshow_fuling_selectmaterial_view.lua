FulingSelectMaterialView = FulingSelectMaterialView or BaseClass(BaseView)

function FulingSelectMaterialView:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "FulingSelectMaterialView"}}
	self.play_audio = true

end

function FulingSelectMaterialView:__delete()

end

function FulingSelectMaterialView:ReleaseCallBack()

end

function FulingSelectMaterialView:OpenCallBack()

end

function FulingSelectMaterialView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end
	
	self.call_back = nil
	self.close_call_back = nil
	self.cancel_call_back = nil
end

function FulingSelectMaterialView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function FulingSelectMaterialView:SetCallBack(call_back , state)
	
	if "Cancel" == state then 
		self.cancel_call_back = call_back
	else 
		self.call_back = call_back
	end

end

function FulingSelectMaterialView:LoadCallBack()
	self.node_list["BtnAutoSelectBlock"].button:AddClickListener(BindTool.Bind(self.Close, self))

	local nodes = {
		self.node_list["BtnGreen"],
		self.node_list["BtnBlue"],
		self.node_list["BtnPurple"],
		self.node_list["BtnOrenger"],
		self.node_list["BtnAll"],
	}

	for i = 1, 5 do
		nodes[i].toggle:AddClickListener(BindTool.Bind(self.OnClickBtn, self, i + 1))
	end
	self.node_list["BtnChanel"].button:AddClickListener(BindTool.Bind(self.OnClickBtn, self))
end

function FulingSelectMaterialView:OnClickBtn(i)
	if nil == i and self.cancel_call_back then 
		self.cancel_call_back()
	elseif nil ~= i and self.call_back then 
		self.call_back(i)
	end
	self:Close()
end