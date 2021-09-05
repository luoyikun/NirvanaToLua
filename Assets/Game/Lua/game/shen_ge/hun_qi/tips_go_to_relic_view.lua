TipsGoToRelicView = TipsGoToRelicView or BaseClass(BaseView)

function TipsGoToRelicView:__init()
	self.ui_config = {{"uis/views/hunqiview_prefab", "TipsGoToRelicView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end


function TipsGoToRelicView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BGButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnGoToGather"].button:AddClickListener(BindTool.Bind(self.GoToGather, self))
	self.node_list["BtnQuick"].button:AddClickListener(BindTool.Bind(self.QuickGather, self))
end

function TipsGoToRelicView:OpenCallBack()
	self:Flush()
end

function TipsGoToRelicView:ReleaseCallBack()
end

function TipsGoToRelicView:CloseCallBack()
	self.quick_gather_callback = nil
	self.go_to_gather_callback = nil
end

function  TipsGoToRelicView:OnFlush()
	self.node_list["TxtDescribe"].text.text = self.des
	self.node_list["TxtLeft"].text.text = self.left_txt
	self.node_list["TxtRight"].text.text = self.right_txt
end

function TipsGoToRelicView:CloseWindow()
	self:Close()
end

function TipsGoToRelicView:GoToGather()
	if self.go_to_gather_callback then
		self.go_to_gather_callback()
	end
	self:Close()
end

function TipsGoToRelicView:QuickGather()
	if self.quick_gather_callback then
		self.quick_gather_callback()
	end
	self:Close()
end

function  TipsGoToRelicView:SetDes(des)
	self.des = des
end

--快速采集
function TipsGoToRelicView:SetQuickGatherCallBack(callback)	
	 self.quick_gather_callback = callback
end

--前往采集
function TipsGoToRelicView:SetGatherCallBack(callback)
	self.go_to_gather_callback = callback
end

function TipsGoToRelicView:SetBtnTxt(left_txt,right_txt)
	self.left_txt = left_txt
	self.right_txt = right_txt
end

