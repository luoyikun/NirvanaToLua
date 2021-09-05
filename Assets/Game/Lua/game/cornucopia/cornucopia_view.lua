CornucopiaView = CornucopiaView or BaseClass(BaseView)
function CornucopiaView:__init()
	self.ui_config = {{"uis/views/cornucopiaview_prefab", "CornucopiaView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function CornucopiaView:__delete()
end

function CornucopiaView:ReleaseCallBack()
	
end

function CornucopiaView:LoadCallBack()
	self.node_list["BTnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function CornucopiaView:ShowIndexCallBack(index)
	
end

function CornucopiaView:OpenCallBack()
	
end

function CornucopiaView:CloseCallBack()
	
end

function CornucopiaView:OnFlush(params_t)
	
end