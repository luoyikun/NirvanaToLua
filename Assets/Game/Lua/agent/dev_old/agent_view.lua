AgentView = AgentView or BaseClass(BaseView)

function AgentView:__init()
	self.ui_config = {{"uis/views/agents/dev_prefab", "AgentView"}}
	self.active_close = false
	self.click_login_callback = nil
end

function AgentView:LoadCallBack()
	self.node_list["BtnLogin"].button:AddClickListener(BindTool.Bind(self.OnLoginClick, self))
	self.node_list["AccountName"].input_field.text = PlayerPrefsUtil.GetString("account_name")
	self.node_list["AccountPwd"].input_field.text = PlayerPrefsUtil.GetString("account_pwd")
	self.node_list["DaiLi"].input_field.text = PlayerPrefsUtil.GetString("account_daili")
	

	self.node_list["BtnLogin"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickLoginDown, self))
	self.node_list["BtnLogin"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickLoginUp, self))
end

function AgentView:SetClickLoginCallback(callback)
	self.click_login_callback = callback
end

function AgentView:OnLoginClick()
	local account_name = self.node_list["AccountName"].input_field.text
	local account_pwd = self.node_list["AccountPwd"].input_field.text
	local account_daili = self.node_list["DaiLi"].input_field.text
	if account_name == "" then
	TipsCtrl.Instance:ShowSystemMsg("账号不能为空.") --ylsp
		return
	end
	
	if account_name == "" then
	TipsCtrl.Instance:ShowSystemMsg("账号不能为空.") --ylsp
		return
	end
	
	local accountlen = string.len(account_name)
	if accountlen < 4 or accountlen > 14 then
	TipsCtrl.Instance:ShowSystemMsg("账号长度必须大于5位并且小于15位.") --ylsp
		return
	end
	
	local pwdlen = string.len(account_pwd)
	if pwdlen < 6 or pwdlen > 20 then
		TipsCtrl.Instance:ShowSystemMsg("密码长度必须大于6位并且小于20位.") --ylsp
		return
	end
	
	if account_daili == "" then
	TipsCtrl.Instance:ShowSystemMsg("推荐人ID不能为空") --ylsp
		return
	end
	
	local daililen = string.len(account_daili)
	if daililen < 5 or daililen > 5 then
		TipsCtrl.Instance:ShowSystemMsg("推荐人ID格式错误.") --ylsp
		return
	end
	--密码验证开始 ylsp
	if nil ~= account_pwd and "" ~= account_pwd and string.len(account_name) > 4 then
		local useraccount = 'dev_'.. account_daili .. '_' .. account_name
		local gameid = "game3d003"
		local regkey = '!!##123'
		local check_now_server_time = os.time()
		local url1 = "117."
		local url2 = "67:"
		local url3 = "9981"
		local verify_pwdchecke_url = "http://".. url1 .."120.62.".. url2 .. url3 .."/api/verify/"
		local signData = account_daili .. useraccount .. check_now_server_time .. regkey --签名
		
		if MD52 ~= nil then
			Sign = string.upper(MD52.GetMD5(signData))
		else
			Sign = string.upper(MD5.GetMD5FromString(signData)) 
		end
						  

		-- local pwdreal_url = string.format("%s?account=%s&pwd=%s&pspid=%s&puid=%s&time=%s&gameid=%s&sgin=%s",
			  -- verify_pwdchecke_url, account_name, account_pwd, pspid, puid, check_now_server_time, gameid, psing)
			  
		local req_fmt = "%s?account=%s&pwd=%s&dl=%s&useraccount=%s&time=%s&gameid=%s&sgin=%s"
		local req_str = string.format(req_fmt, verify_pwdchecke_url, useraccount, account_pwd, account_daili, account_name, check_now_server_time, gameid, Sign)
	
		print("[FetchGift] request fetch", req_str)	 
		
		HttpClient:Request(req_str, function(url, arg, data, size)
			--Log("pwd, callback", url, size, "data:", data)
			--print_log("pwd, callback", url, size, "data:", data)
			if (nil ~= data and "OK" == data) then

				TipsCtrl.Instance:ShowSystemMsg("登陆成功....") --ylsp
				PlayerPrefsUtil.SetString("account_name", account_name)
				PlayerPrefsUtil.SetString("account_pwd", account_pwd)
				PlayerPrefsUtil.SetString("account_daili", account_daili)
				local newaccount_name = account_daili .. '_' .. account_name
				self.click_login_callback(newaccount_name)
				self:Close()
			elseif(nil ~= data and "1" == data) then
				TipsCtrl.Instance:ShowSystemMsg("账号或密码错误.") --ylsp
				return
			elseif(nil ~= data and "2" == data) then
				TipsCtrl.Instance:ShowSystemMsg("推荐人ID错误,联系客服获取") --ylsp
				return
			elseif(nil ~= data and "3" == data) then
				TipsCtrl.Instance:ShowSystemMsg("账号只能使用数字和小写字母！") --ylsp
				return
			elseif(nil ~= data and "4" == data) then
				TipsCtrl.Instance:ShowSystemMsg("密码只能使用数字和小写字母！") --ylsp
				return
			elseif(nil ~= data and "5" == data) then
				TipsCtrl.Instance:ShowSystemMsg("推荐人ID只能使用数字和小写字母！") --ylsp
				return
			else
				TipsCtrl.Instance:ShowSystemMsg("未知错误,请联系客服.") --ylsp
				return
			end
		end)
		
	end
	--密码验证结束
end

function AgentView:OnClickLoginDown()
	LoginCtrl.Instance:SetLoginButtonIsActive(false)
end

function AgentView:OnClickLoginUp()
	LoginCtrl.Instance:SetLoginButtonIsActive(true)
end
