StrengthenSelectMaterialView = StrengthenSelectMaterialView or BaseClass(BaseView)

function StrengthenSelectMaterialView:__init()
	self.ui_config = {{"uis/views/bianshen_prefab", "StrengthenSelectMaterialView"}}
	self.play_audio = true

end

function StrengthenSelectMaterialView:__delete()

end

function StrengthenSelectMaterialView:ReleaseCallBack()

end

function StrengthenSelectMaterialView:OpenCallBack()

end

function StrengthenSelectMaterialView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end
	
	self.call_back = nil
	self.close_call_back = nil
	self.cancel_call_back = nil
end

function StrengthenSelectMaterialView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function StrengthenSelectMaterialView:SetCallBack(call_back , state)
	
	if "Cancel" == state then 
		self.cancel_call_back = call_back
	else 
		self.call_back = call_back
	end

end

function StrengthenSelectMaterialView:LoadCallBack()
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

function StrengthenSelectMaterialView:OnClickBtn(i)
	if nil == i and self.cancel_call_back then 
		self.cancel_call_back()
	elseif nil ~= i and self.call_back then 
		self.call_back(i)
	end
	self:Close()
end