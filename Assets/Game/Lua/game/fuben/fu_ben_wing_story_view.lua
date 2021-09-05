FuBenWingStoryView = FuBenWingStoryView or BaseClass(BaseView)

function FuBenWingStoryView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "WingStoryFbView"}}

	self.open_door_callback = nil
end

function FuBenWingStoryView:__delete()
	self.open_door_callback = nil
end

function FuBenWingStoryView:LoadCallBack()
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickOpenDoor, self))

end

function FuBenWingStoryView:ShowOpenDoorView(open_door_callback)
	self.open_door_callback = open_door_callback
	self.node_list["PanelOpenDoor"]:SetActive(true)
end

function FuBenWingStoryView:OnClickOpenDoor()
	self.node_list["PanelOpenDoor"]:SetActive(false)
	if nil ~= self.open_door_callback then
		self.open_door_callback()
	end
end
