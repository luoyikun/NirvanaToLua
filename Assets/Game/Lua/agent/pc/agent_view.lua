AgentView = AgentView or BaseClass(BaseView)

function AgentView:__init()
	self.ui_config = {{"uis/views/agents/pc_prefab", "PCAgentView"}}
	self.active_close = false
	self.click_login_callback = nil
end

function AgentView:LoadCallBack()
	self.node_list["BtnLogin"].button:AddClickListener(BindTool.Bind(self.OnLoginClick, self))
	self.node_list["AccountName"].input_field.text = PlayerPrefsUtil.GetString("account_name")
	self.node_list["Password"].input_field.text = PlayerPrefsUtil.GetString("password")
end

function AgentView:SetClickLoginCallback(callback)
	self.click_login_callback = callback
end

function AgentView:OnLoginClick()
	local account_name = self.node_list["AccountName"].input_field.text
	if account_name == "" then
		return
	end

	local password = self.node_list["Password"].input_field.text
	if password == "" then
		return
	end

	PlayerPrefsUtil.SetString("account_name", account_name)
	PlayerPrefsUtil.SetString("password", password)

	self.click_login_callback(account_name, password)
	self:Close()
end
