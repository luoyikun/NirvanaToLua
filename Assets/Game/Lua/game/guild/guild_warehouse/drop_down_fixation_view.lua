-- 挑选装备列表,固定数量item的下拉列表,不可以滚动
-- DropDownFixationView

DropDownFixationView = DropDownFixationView or BaseClass(BaseView)

function DropDownFixationView:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "DropDownFixationView"}}
	self.play_audio = true
	self.vew_cache_time = 0
end

function DropDownFixationView:__delete()

end

function DropDownFixationView:ReleaseCallBack()

end

function DropDownFixationView:OpenCallBack()
	if self.frame_pos then
		self.node_list["FramePos"].transform.localPosition = self.frame_pos
	end

	for i = 1, 10 do
		self.node_list["Select_" .. i]:SetActive(false)
	end

	if next(self.list_name) then
		for i = 1, #self.list_name do
			self.node_list["Text_" .. i].text.text = self.list_name[i]
			self.node_list["Select_" .. i]:SetActive(true)
		end
	end
end

function DropDownFixationView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end
	
	self.call_back = nil
	self.close_call_back = nil
	self.cancel_call_back = nil
	self.frame_pos = nil
	self.list_name = {}
end

function DropDownFixationView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function DropDownFixationView:SetCallBack(call_back , state)
	if "Cancel" == state then 
		self.cancel_call_back = call_back
	else 
		self.call_back = call_back
	end
end

-- 设置列表的位置
function DropDownFixationView:SetFramePosAndListName(vector, list_name)
	self.frame_pos = vector
	self.list_name = list_name
end

function DropDownFixationView:LoadCallBack()
	self.node_list["AutoSelectBlock"].button:AddClickListener(BindTool.Bind(self.Close, self))

	for i = 1, #self.list_name do
		self.node_list["Select_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickBtn, self, i))
	end

	self.node_list["SelectAll"].toggle:AddClickListener(BindTool.Bind(self.OnClickBtn, self, #self.list_name + 1))
	self.node_list["Cancel"].button:AddClickListener(BindTool.Bind(self.OnClickBtn, self))
end

function DropDownFixationView:OnClickBtn(i)
	if nil == i and self.cancel_call_back then 
		self.cancel_call_back()
	elseif nil ~= i and self.call_back then 
		self.call_back(i)
	end
	self:Close()
end
