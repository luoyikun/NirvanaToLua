AgentView = AgentView or BaseClass(BaseView)

function AgentView:__init()
	self.ui_config = {{"uis/views/agents/dev_prefab", "AgentView"}}
	self.active_close = false
	self.click_login_callback = nil
	self.isInit = true
end
function AgentView:LoadCallBack()
	self.node_list["BtnLogin"].button:AddClickListener(BindTool.Bind(self.OnLoginClick, self))
	self.node_list["AccountName"].input_field.text = PlayerPrefsUtil.GetString("account_name")
	self.node_list["AccountPwd"].input_field.text = PlayerPrefsUtil.GetString("account_pwd")
	self.node_list["DaiLi"]:SetActive(false)
end

function AgentView:ReleaseCallBack()
	self.input_name = nil
end

function AgentView:SetClickLoginCallback(callback)
	self.click_login_callback = callback
end

function AgentView:OnLoginClick()
	local account_name = self.node_list["AccountName"].input_field.text
	if account_name == "" then
		return
	end

	UnityEngine.PlayerPrefs.SetString("account_name", account_name) 
	self.click_login_callback(account_name)
	print_log("[AgentView:OnLoginClick]")
	self:Close()
end
