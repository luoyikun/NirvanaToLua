TipsCommonOneOptionView = TipsCommonOneOptionView or BaseClass(BaseView)

function TipsCommonOneOptionView:__init()
	self.ui_config = {{"uis/views/tips/commononeoptiontips_prefab", "CommonOneOptionTips"}}
	self.view_layer = UiLayer.Pop

	self.default_btton_text = Language.Tips.JieShou
	self.play_audio = true
	self.is_modal = true
end

function TipsCommonOneOptionView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnOption"].button:AddClickListener(BindTool.Bind(self.ButtonClick, self))
end

function TipsCommonOneOptionView:ShowView(describe, click_func, button_text)
	self.details_value = describe
	self.button_text_value = button_text or self.default_btton_text
	self.click_func = click_func 
	self:Open()
end

function TipsCommonOneOptionView:OpenCallBack()
	self.node_list["TxtTipsDetails"].text.text = self.details_value
end

function TipsCommonOneOptionView:ButtonClick()
	if self.click_func ~= nil then
		self.click_func()
	end
	self:Close()
end

function TipsCommonOneOptionView:CloseView()
	self:Close()
end
