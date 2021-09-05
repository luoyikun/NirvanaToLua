TipsCommonPlaneTipsView = TipsCommonPlaneTipsView or BaseClass(BaseView)

function TipsCommonPlaneTipsView:__init()
	self.ui_config = {{"uis/views/tips/commonplanetips_prefab", "CommonPlaneTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
end

function TipsCommonPlaneTipsView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
end

function TipsCommonPlaneTipsView:ShowView(describe)
	self.details_value = describe
	self:Open()
end

function TipsCommonPlaneTipsView:OpenCallBack()
	self.node_list["TxtTips"].text.text = self.details_value
end

function TipsCommonPlaneTipsView:CloseView()
	self:Close()
end
