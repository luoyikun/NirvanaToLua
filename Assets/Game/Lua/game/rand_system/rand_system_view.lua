RandSystemView = RandSystemView or BaseClass(BaseView)

local interval = 0.1			--移动间隔
local distance = 3				--每次移动距离

function RandSystemView:__init()
	self.ui_config = {{"uis/views/randsystemview_prefab", "RandSystemView"}}
	self.view_layer = UiLayer.Pop
	self.is_async_load = true
end

function RandSystemView:__delete()
end

function RandSystemView:ReleaseCallBack()

end

function RandSystemView:LoadCallBack()

	-- 获取变量
end

function RandSystemView:OpenCallBack()
	local show_index = RandSystemData.Instance:GetLastShowIndex()
	local notice_info = RandSystemData.Instance:GetNoticeInfoByIndex(show_index)
	local notice = notice_info.notice_dec or ""
	self.node_list["Txt"].text.text = notice

end

function RandSystemView:CloseCallBack()
	if self.tweener1 then
		self.tweener1:Pause()
	end
end