FulingTips = FulingTips or BaseClass(BaseView)
function FulingTips:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "FulingTips"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FulingTips:__delete()

end

function FulingTips:ReleaseCallBack()	
	self.open_call_back = nil
	self.close_call_back = nil
end

function FulingTips:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function FulingTips:SetOpenCallBack(call_back)
	self.open_call_back = call_back
end

function FulingTips:LoadCallBack()
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnEnsure"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self))
end

function FulingTips:OpenCallBack()
	if self.open_call_back then
		local cost, shuliandu = self.open_call_back()
		self.cost = shuliandu / cost
		self.cost = math.ceil(self.cost)
	end
	local str = string.format(Language.ShenShou.FulingTips, self.cost)
	self.node_list["TxtContent"].text.text = str
end

function FulingTips:CloseCallBack()
end

function FulingTips:ClickBtn()
	if self.close_call_back then
		self.close_call_back()
	end
	self:Close()
end

function FulingTips:CloseWindow()
	self:Close()
end