RoleFollow = RoleFollow or BaseClass(CharacterFollow)

function RoleFollow:__init()
	self.obj_type = nil
	self.achieve_title_text = nil
	self.guild_icon_owner = nil
	self.follow_name_prefab_name = "SceneRoleObjName"
	self.follow_hp_prefab_name = "RoleHP"
	self.is_main_role = false
	self.is_role_follow_hide = false
end

function RoleFollow:__delete()
	self.guild_icon_owner = nil
end

function RoleFollow:IsMainRole(is_main_role)
	self.is_main_role = is_main_role
end

function RoleFollow:IsRoleFollowHide(is_role_follow_hide)
	self.is_role_follow_hide = is_role_follow_hide
end

function RoleFollow:UpdateRootNodeVisible()
	if not self.is_main_role and (self.is_role_follow_hide or SceneData.Instance:IsShieldRoleFollowAndShadow()) then
		self.is_root_visible = false
	end
	FollowUi.UpdateRootNodeVisible(self)
end

function RoleFollow:SetDaFuHaoIconState(enable)
	self.namebar:SetDaFuHaoIconActive(enable)
end

function RoleFollow:SetName(name, secne_obj)
	self.namebar:SetSceneObjName(name)
	if nil ~= secne_obj then
		local chengjiu_title_level = secne_obj:GetAttr("chengjiu_title_level")
		if nil ~= chengjiu_title_level and chengjiu_title_level > 0 then
			self.namebar:SetAchieveLevel(chengjiu_title_level)
		end
	end
end

function RoleFollow:SetVipIcon(vip_level)
	self.namebar:SetVipLevel(vip_level)
end

function RoleFollow:SetLongXingIcon(jingjie_level)
	self.namebar:SetJingjieLevel(jingjie_level)
end

function RoleFollow:SetGuildIcon(scene_obj)
	-- ???
end

function RoleFollow:SetIsShowGuildIcon(enable)
	-- ???
end
