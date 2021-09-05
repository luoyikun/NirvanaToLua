TipsCommonTwoOptionView = TipsCommonTwoOptionView or BaseClass(BaseView)
--这个代码没用的 对不上组件
function TipsCommonTwoOptionView:__init()
	self.ui_config = {{"uis/views/tips/commontwooptiontips_prefab", "CommonTwoOptionTips"}}
	self.view_layer = UiLayer.Pop
	self.default_yes = Language.Common.Confirm
	self.default_no = Language.Common.Cancel
	self.play_audio = true
	self.is_modal = true
end

function TipsCommonTwoOptionView:LoadCallBack()
	self.node_list["BtnCloseView"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnOption"].button:AddClickListener(BindTool.Bind(self.YesClick, self))
end

function TipsCommonTwoOptionView:ShowView(describe, yes_func, no_func, yes_button_text, no_button_text)
	self.details_value = describe
	self.yes_value = yes_button_text or self.default_yes
	self.no_value = no_button_text or self.default_no
	self.yes_func = yes_func
	self.no_func = no_func
	self:Open()
end

function TipsCommonTwoOptionView:OpenCallBack()
	self.node_list["TxtTipsDetails"].text.text = self.details_value
end

function TipsCommonTwoOptionView:YesClick()
	if self.yes_func ~= nil then
		self.yes_func()
	end
	self:Close()
end

function TipsCommonTwoOptionView:NoClick()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipsCommonTwoOptionView:CloseView()
	self:Close()
end
