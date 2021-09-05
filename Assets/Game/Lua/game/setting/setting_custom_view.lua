SettingCustomView = SettingCustomView or BaseClass(BaseRender)

function SettingCustomView:__init(instance)
	SettingCustomView.Instance = self
	self.node_list["SendBtn"].button:AddClickListener(BindTool.Bind(self.SendClick, self))
	for i = 1, 3 do

		self.node_list["Toggle" .. i].toggle:AddValueChangedListener(BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.select_send_type = SEND_CUSTOM_TYPE.SUGGEST
end

function SettingCustomView:__delete()
	SettingCustomView.Instance = nil
end

function SettingCustomView:OnToggleClick(i,is_click)
	if is_click then
		self.select_send_type = i
	end
end

function SettingCustomView:OpenCustom()
	--self.sugget_toggle.toggle.isOn = true
	self.select_send_type = SEND_CUSTOM_TYPE.SUGGEST
	self.node_list["title_input"].input_field.text = ""
	self.node_list["content_input"].input_field.text = ""
end

function SettingCustomView:SendClick()
	if not self.select_send_type then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[1])
	elseif self.node_list["title_input"].input_field.text == ""  then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[2])
	elseif self.node_list["content_input"].input_field.text == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[3])
	else
		local list = {}
		local vo = GameVoManager.Instance:GetMainRoleVo()
		list.zone_id = GLOBAL_CONFIG.package_info.config.agent_id
		list.server_id = GameVoManager.Instance:GetUserVo().plat_server_id
		list.user_id = vo.role_id
		list.role_id = vo.role_id
		list.role_name = vo.role_name
		list.role_level = vo.level
		list.role_gold = vo.gold
		list.role_scene = vo.scene_id
		list.issue_type = SettingData.Instance:GetIssueTypeName(self.select_send_type)
		list.issue_subject = self.node_list["title_input"].input_field.text
		list.issue_content = self.node_list["content_input"].input_field.text
		SettingCtrl.Instance:SendRequest(list)

		self.node_list["title_input"].input_field.text = ""
		self.node_list["content_input"].input_field.text = ""
	end
end

