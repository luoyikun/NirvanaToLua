require("game/versions_activity/versions_activity_data")
require("game/versions_activity/versions_activity_view")


VersionsActivityCtrl = VersionsActivityCtrl or BaseClass(BaseController)

function VersionsActivityCtrl:__init()
	if VersionsActivityCtrl.Instance ~= nil then
		print_error("[VersionsActivityCtrl] Attemp to create a singleton twice !")
	end
	VersionsActivityCtrl.Instance = self
	self.view = VersionsActivityView.New(ViewName.VersionsActivityView)
	self.data = VersionsActivityData.New()

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.scene_load_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SceneLoadComplete, self))
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDay, self))
	self:RegisterAllProtocols()
end

function VersionsActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end
	
	VersionsActivityCtrl.Instance = nil
end

function VersionsActivityCtrl:GetView()
	return self.view
end

function VersionsActivityCtrl:RegisterAllProtocols()

end

function VersionsActivityCtrl:ActivityChange()

end

function VersionsActivityCtrl:SceneLoadComplete()

end

function VersionsActivityCtrl:ServerOpenDay()

end
