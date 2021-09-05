MainUIViewMap = MainUIViewMap or BaseClass(BaseRender)

function MainUIViewMap:__init()
	self.scene_loading_quit_handle = GlobalEventSystem:Bind(
		SceneEventType.SCENE_LOADING_STATE_QUIT,
		BindTool.Bind1(self.OnSceneLoaded, self))
	
	self.main_role_pos_change_handle = GlobalEventSystem:Bind(
		ObjectEventType.MAIN_ROLE_POS_CHANGE,
		BindTool.Bind1(self.OnMainRolePosChange, self))

	-- 初始化
	self:OnSceneLoaded()
	local main_role = Scene.Instance:GetMainRole()
	self:OnMainRolePosChange(main_role:GetLogicPos())

	self.time_quest = GlobalTimerQuest:AddTimesTimer(
		BindTool.Bind2(self.OnUpdateTime, self), 5, 999999999)
end

function MainUIViewMap:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	GlobalEventSystem:UnBind(self.scene_loading_quit_handle)
	GlobalEventSystem:UnBind(self.main_role_pos_change_handle)
end

function MainUIViewMap:OnSceneLoaded()
	local map_name = Scene.Instance:GetSceneName()
	self.node_list["TxtMapName"].text.text = map_name
end

function MainUIViewMap:OnMainRolePosChange(x, y)
	self.node_list["TxtMapPos"].text.text = string.format("(%s, %s)", x, y)
end

function MainUIViewMap:OnUpdateTime()
	local time_text = os.date("%H:%M")
	self.node_list["TxtTime"].text.text = time_text
	local delay_time = math.floor(TimeCtrl.Instance:GetDelayTime() * 1000)
	local color = nil
	if delay_time >= 300 then
		color = Color(255, 0, 0, 1)
	elseif delay_time >= 100 then
		color = Color(255, 255, 0, 1)
	else
		color = Color(0, 255, 0, 1)
	end

	if delay_time > 500 then
		delay_time = "≥500"
	end
	
	self.node_list["TxtPin"].text.color = color
	self.node_list["TxtPin"].text.text = delay_time

	local batteryLevel = UnityEngine.SystemInfo.batteryLevel
	if batteryLevel ~= -1 then
		local slider_color = Color(0.1843, 0.8157, 0.3294, 1)
		if batteryLevel <= 0.2 then
			slider_color = Color(0.8510, 0.1098, 0.1098, 1)
		end
		self.node_list["Fill"].image.color = slider_color
		self.node_list["SliderBattery"].slider.value = batteryLevel
	end
end

function MainUIViewMap:SetShowTopBg(isOn)
	for i=1,2 do
		if self.node_list["CommBg" .. i] and self.node_list["FbBg" .. i] then
			self.node_list["CommBg" .. i]:SetActive(isOn)
			self.node_list["FbBg" .. i]:SetActive(not isOn)
		end
	end
end
