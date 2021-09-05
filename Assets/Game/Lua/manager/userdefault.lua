--UnityEngine.PlayerPrefs 不允许自己调用

UserDefalut = UserDefalut or BaseClass()

function UserDefalut:__init()
	if UserDefalut.Instance then
		print_error("UserDefalut to create singleton twice")
	end
	UserDefalut.Instance = self

	self.login_handler = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRoleLogin, self))
	self.logout_handler = GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnRoleLogout, self))
end

function UserDefalut:__delete()
	GlobalEventSystem:UnBind(self.login_handler)
	GlobalEventSystem:UnBind(self.logout_handler)

	UserDefalut.Instance = nil
end

function UserDefalut:OnRoleLogin()
	if IS_ON_CROSSSERVER then
		self.role_id = CrossServerData.Instance:GetRoleId()
	else
		local role_vo = PlayerData.Instance:GetRoleVo()
		if nil ~= role_vo then
			self.role_id = role_vo.role_id
		end
	end
end

function UserDefalut:OnRoleLogout()
	self.role_id = nil
end

function UserDefalut:TransformKey(key)
	if nil ~= self.role_id then
		return tostring(self.role_id) .. "@" .. key
	end
	return key
end

function UserDefalut:SetInt(key, value)
	key = self:TransformKey(key)
	UnityEngine.PlayerPrefs.SetInt(key, value)
end

function UserDefalut:GetInt(key)
	key = self:TransformKey(key)
	return UnityEngine.PlayerPrefs.GetInt(key)
end

function UserDefalut:SetFloat(key, value)
	key = self:TransformKey(key)
	UnityEngine.PlayerPrefs.SetFloat(key, value)
end

function UserDefalut:GetFloat(key)
	key = self:TransformKey(key)
	return UnityEngine.PlayerPrefs.GetFloat(key)
end

function UserDefalut:SetString(key, value)
	key = self:TransformKey(key)
	UnityEngine.PlayerPrefs.SetString(key, value)
end

function UserDefalut:GetString(key)
	key = self:TransformKey(key)
	return UnityEngine.PlayerPrefs.GetString(key)
end

function UserDefalut:HasKey(key)
	return UnityEngine.PlayerPrefs.HasKey(key)
end

function UserDefalut:DeleteKey(key)
	UnityEngine.PlayerPrefs.DeleteKey(key)
end

function UserDefalut:DeleteAll()
	UnityEngine.PlayerPrefs.DeleteAll()
end

function UserDefalut:Save()
	UnityEngine.PlayerPrefs.Save()
end
