local Gradient_Color1 = {
	[1] = Color(255/255, 250/255, 227/255, 1),
	[2] = Color(247/255, 255/255, 42/255, 1),
	[3] = Color(213/255, 255/255, 188/255, 1),
	[4] = Color(247/255, 255/255, 42/255, 1),
	[5] = Color(250/255, 255/255, 195/255, 1),
}
local Gradient_Color2 = {
	[1] = Color(244/255, 217/255, 167/255, 1),
	[2] = Color(253/255, 167/255, 0/255, 1),
	[3] = Color(113/255, 253/255, 0/255, 1),
	[4] = Color(253/255, 167/255, 0/255, 1),
	[5] = Color(254/255, 230/255, 80/255, 1),
}

FollowNameBar = FollowNameBar or BaseClass(BaseRender)

function FollowNameBar:__init()
	self.obj_type = nil
	self.is_root_created = false
end

function FollowNameBar:__delete()

	if nil ~= self.root_node then
		self:ResumeDefaultLoacalUI()
		self:ResumeDefaultGuildName()
		self:ResumeDefaultLoverName()
		self:ResumeDefaultNumTxt()
		self:ResumeDefaultScoreTxt()
		self:ResumeDefaultScorePosX()
		self:ResumeDefaultSceneObjNamePos()
		self:ResumeDefaultSpecialImagePos()
		self:ResumeDefaultSpecialImageScale()
		self:ResumeDefaultSpecialImageAct()
		self:ResumeDefaultAttachEffectAct()
		self:ResumeDefaultVipIconAct()
		self:ResumeDefaultJingjieAct()
		self:ResumeDefaultAchieveLevelTxtAct()
		self:ResumeDefaultDafuhaoIconAct()
	end
end

-- 在真正需要用实体时再创建
function FollowNameBar:CreateRootNode(prefab_name, obj_type, follow_parent)
	if self.is_root_created then
		return
	end

	self.is_root_created = true
	self.obj_type = obj_type
	local async_loader = AllocAsyncLoader(self, "root_loader")
	async_loader:SetIsUseObjPool(true)
	async_loader:SetIsInQueueLoad(true)
	async_loader:Load("uis/views/miscpreload_prefab", prefab_name, 
		function (gameobj)
			if IsNil(gameobj) then
				return
			end
			
			self:SetInstance(gameobj)
			self:SetInstanceParent(follow_parent)
			self.root_node.rect.anchoredPosition = Vector2(0, 45)

			self:UpdateActive()
			self:UpdateLoacalUI()
			self:UpdateSceneObjName()
			self:UpdateGuildName()
			self:UpdateLoverName()
			self:UpdateNumStr()
			self:UpdateScore()
			self:UpdateScorePosX()
			self:UpdateSceneObjectNamePos()
			self:UpdateSpecialImagePosX()
			self:UpdateSpecialImageScale()
			self:UpdateSpecialImage()
			self:UpdateAttachEffect()
			self:UpdateFollowUIUpImage()
			self:UpdateVipLevel()
			self:UpdateJingjieLevel()
			self:UpdateAchieveLevel()
			self:UpdateDaFuhaoIconActive()
		end)
end

function FollowNameBar:SetIsActive(is_root_active)
	self.is_root_active = is_root_active
	self:UpdateActive()
end

function FollowNameBar:UpdateActive()
	if nil ~= self.is_root_active and nil ~= self.root_node then
		self.root_node:SetActive(self.is_root_active)
	end
end

function FollowNameBar:SetAnchoredPosition(x, y)
	if nil ~= self.anchored_pos and self.anchored_pos.x == x and self.anchored_pos.y == y then
		return
	end

	self.anchored_pos = {x = x, y = y}
	self:UpdateLoacalUI()
end

function FollowNameBar:UpdateLoacalUI()
	if nil ~= self.anchored_pos and nil ~= self.root_node then
		if nil == self.default_anchored_pos then
			self.default_anchored_pos = self.root_node.rect.anchoredPosition
		end
		
		self.root_node.rect.anchoredPosition = Vector2(self.anchored_pos.x, self.anchored_pos.y)
	end
end

function FollowNameBar:ResumeDefaultLoacalUI()
	if nil ~= self.default_anchored_pos and nil ~= self.root_node then
		self.root_node.rect.anchoredPosition = self.default_anchored_pos
	end
end

function FollowNameBar:SetSceneObjName(scene_obj_name)
	self.scene_obj_name = scene_obj_name
	self:UpdateSceneObjName()
end

function FollowNameBar:UpdateSceneObjName()
	if nil ~= self.scene_obj_name and nil ~= self.root_node then
		self.node_list["SceneObjNameTxt"].text.text = self.scene_obj_name
	end
end

function FollowNameBar:SetGuildName(guild_name)
	self.guild_name = guild_name
	self:UpdateGuildName()
end

function FollowNameBar:UpdateGuildName()
	if nil == self.guild_name or nil == self.root_node then
		return
	end

	local gameobj = self.node_list["GuildName"]
	if nil ~= gameobj then
		if nil == self.default_guild_name_act then
			self.default_guild_name_act = gameobj:GetActiveSelf()
		end

		gameobj:SetActive("" ~= self.guild_name)
		gameobj.text.text = self.guild_name
	end
end

function FollowNameBar:ResumeDefaultGuildName()
	if nil ~= self.default_guild_name_act and nil ~= self.node_list["GuildName"] then
		self.node_list["GuildName"]:SetActive(self.default_guild_name_act)
	end
end

function FollowNameBar:SetLoverName(lover_name)
	self.lover_name = lover_name
	self:UpdateLoverName()
end

function FollowNameBar:UpdateLoverName()
	if nil == self.lover_name or nil == self.root_node then
		return
	end

	local lover_name_obj = self.node_list["LoverName"]
	if nil ~= lover_name_obj then
		if nil == self.default_lover_name_act then
			self.default_lover_name_act = lover_name_obj:GetActiveSelf()
		end

		lover_name_obj:SetActive("" ~= self.lover_name)
		lover_name_obj.text.text = self.lover_name
	end
end

function FollowNameBar:ResumeDefaultLoverName()
	if nil ~= self.default_lover_name_act and nil ~= self.node_list["LoverName"] then
		self.node_list["LoverName"]:SetActive(self.default_lover_name_act)
	end
end

function FollowNameBar:SetNumStr(num_str)
	self.num_str = num_str
	self:UpdateNumStr()
end

function FollowNameBar:UpdateNumStr()
	if nil == self.num_str or nil == self.root_node then
		return
	end

	local numstr_obj = self.node_list["NumTxt"]
	if nil ~= numstr_obj then
		if nil == self.default_num_txt_act then
			self.default_num_txt_act = numstr_obj:GetActiveSelf()
		end
		numstr_obj:SetActive("" ~= self.num_str)
		numstr_obj.text.text = "x" .. self.num_str
	end
end

function FollowNameBar:ResumeDefaultNumTxt()
	if nil ~= self.default_num_txt_act and nil ~= self.node_list["NumTxt"] then
		self.node_list["NumTxt"]:SetActive(self.default_num_txt_act)
	end
end

function FollowNameBar:SetScoreStr(score_str)
	self.score_str = score_str
	self:UpdateScore()
end

function FollowNameBar:UpdateScore()
	if nil == self.score_str or nil == self.root_node then
		return
	end

	local score_obj = self.node_list["ScoreTxt"]
	if nil ~= score_obj then
		if nil == self.default_score_txt_act then
			self.default_score_txt_act = score_obj:GetActiveSelf()
		end
		score_obj:SetActive("" ~= self.score_str)
		score_obj.text.text = self.score_str
	end
end

function FollowNameBar:ResumeDefaultScoreTxt()
	if nil ~= self.default_score_txt_act and nil ~= self.node_list["ScoreTxt"] then
		self.node_list["ScoreTxt"]:SetActive(self.default_score_txt_act)
	end
end

function FollowNameBar:SetScorePosX(x)
	self.score_pos_x = x
	self:UpdateScorePosX()
end

function FollowNameBar:UpdateScorePosX()
	if nil == self.score_pos_x or nil == self.root_node then
		return
	end

	local score_obj = self.node_list["ScoreTxt"]
	if nil ~= score_obj then
		if nil == self.default_score_txt_pos then
			self.default_score_txt_pos = score_obj.transform.localPosition
		end
		score_obj:SetLocalPosition(self.score_pos_x, score_obj.transform.localPosition.y, 0)
	end
end

function FollowNameBar:ResumeDefaultScorePosX()
	if nil ~= self.default_score_txt_pos and nil ~= self.node_list["ScoreTxt"] then
		self.node_list["ScoreTxt"].transform.localPosition = self.default_score_txt_pos
	end
end

function FollowNameBar:SetSceneObjNamePos(x, y)
	if nil ~= self.scene_obj_name_pos and self.scene_obj_name_pos.x == x and self.scene_obj_name_pos.y == y then
		return
	end

	self.scene_obj_name_pos = {x = x, y = y}
	self:UpdateSceneObjectNamePos()
end

function FollowNameBar:UpdateSceneObjectNamePos()
	if nil == self.scene_obj_name_pos or nil == self.root_node then
		return
	end

	local name_txt_obj = self.node_list["SceneObjNameTxt"]
	if nil ~= name_txt_obj then
		if nil == self.default_scene_obj_name_pos then
			self.default_scene_obj_name_pos = name_txt_obj.transform.localPosition
		end
		name_txt_obj:SetLocalPosition(self.scene_obj_name_pos.x, self.scene_obj_name_pos.y, 0)
	end
end

function FollowNameBar:ResumeDefaultSceneObjNamePos()
	if nil ~= self.default_scene_obj_name_pos and nil ~= self.node_list["SceneObjNameTxt"] then
		self.node_list["SceneObjNameTxt"].transform.localPosition = self.default_scene_obj_name_pos
	end
end

function FollowNameBar:SetSpecialImagePosXY(x, y)
	self.special_image_pos_x = x
	self.special_image_pos_y = y
	self:UpdateSpecialImagePosX()
end

function FollowNameBar:UpdateSpecialImagePosX()
	if nil == self.special_image_pos_x or nil == self.special_image_pos_y or nil == self.root_node then
		return
	end

	local special_image_obj = self.node_list["SpecialImage"]
	if nil ~= special_image_obj then
		if nil == self.default_special_image_pos then
			self.default_special_image_pos = special_image_obj.transform.localPosition
		end
		special_image_obj:SetLocalPosition(self.special_image_pos_x, self.special_image_pos_y, 0)
	end
end

function FollowNameBar:ResumeDefaultSpecialImagePos()
	if nil ~= self.default_special_image_pos and nil ~= self.node_list["SpecialImage"] then
		self.node_list["SpecialImage"].transform.localPosition = self.default_special_image_pos
	end
end

function FollowNameBar:SetSpecialImageScale(scale)
	if nil ~= self.special_image_scale and self.special_image_scale == scale then
		return
	end

	self.special_image_scale = scale
	self:UpdateSpecialImageScale()
end

function FollowNameBar:UpdateSpecialImageScale()
	if nil == self.special_image_scale or nil == self.root_node then
		return
	end

	local special_image_obj = self.node_list["SpecialImage"]
	if nil ~= special_image_obj then
		if nil == self.default_speical_image_scale then
			self.default_speical_image_scale = special_image_obj.transform.localScale
		end
		special_image_obj.transform:SetLocalScale(self.special_image_scale, self.special_image_scale, self.special_image_scale)
	end
end

function FollowNameBar:ResumeDefaultSpecialImageScale()
	if nil ~= self.default_speical_image_scale and nil ~= self.node_list["SpecialImage"] then
		self.node_list["SpecialImage"].transform.localScale = self.default_speical_image_scale
	end
end

function FollowNameBar:SetSpecialImage(is_active, bundle, asset)
	if nil == bundle or nil == asset then
		is_active = false
	end

	self.special_image_info = {is_active = is_active, bundle = bundle, asset = asset}
	self:UpdateSpecialImage()
end

function FollowNameBar:UpdateSpecialImage()
	if nil == self.special_image_info or nil == self.root_node then
		return
	end

	local special_image_obj = self.node_list["SpecialImage"]
	if nil == special_image_obj then
		return
	end

	if nil == self.default_special_image_act then
		self.default_special_image_act = special_image_obj:GetActiveSelf()
	end

	if self.special_image_info.is_active then
		special_image_obj.image:LoadSpriteAsync(self.special_image_info.bundle, self.special_image_info.asset, function()
			special_image_obj:SetActive(true)
			special_image_obj.image:SetNativeSize()
		end)
	else
		special_image_obj:SetActive(false)
	end
end

function FollowNameBar:ResumeDefaultSpecialImageAct()
	if nil ~= self.default_special_image_act and nil ~= self.node_list["SpecialImage"] then
		self.node_list["SpecialImage"]:SetActive(self.default_special_image_act)
	end
end

function FollowNameBar:SetAttachEffect(is_active, bundle, asset)
	if nil == bundle or nil == asset then
		is_active = false
	end

	self.attach_effect_info = {is_active = is_active, bundle = bundle, asset = asset}
	self:UpdateAttachEffect()
end

function FollowNameBar:UpdateAttachEffect()
	if nil == self.attach_effect_info or nil == self.root_node then
		return
	end

	local attach_effect_obj = self.node_list["AttachEffect"]
	if nil ~= attach_effect_obj then
		if nil == self.default_attach_effect_act then
			self.default_attach_effect_act = attach_effect_obj:GetActiveSelf()
		end

		attach_effect_obj:SetActive(self.attach_effect_info.is_active)
		if self.attach_effect_info.is_active then
			attach_effect_obj:ChangeAsset(self.attach_effect_info.bundle, self.attach_effect_info.asset)
		end
	end
end

function FollowNameBar:ResumeDefaultAttachEffectAct()
	if nil ~= self.default_attach_effect_act and nil ~= self.node_list["AttachEffect"] then
		self.node_list["AttachEffect"]:SetActive(self.default_attach_effect_act)
	end
end

function FollowNameBar:ShowFollowUIUpImage(obj_id, is_show, bundle, asset, vector)
	self.ui_up_image_info = {obj_id = obj_id, is_show = is_show, bundle = bundle, asset = asset, vector = vector}
	self:UpdateFollowUIUpImage()
end

function FollowNameBar:UpdateFollowUIUpImage()
	if nil == self.ui_up_image_info or nil == self.root_node then
		return
	end

	local async_loader = AllocAsyncLoader(self, "up_image" .. self.ui_up_image_info.obj_id)
	async_loader:Load("uis/views/healthbar_prefab", "ObjUpImg", function(obj)
		if IsNil(obj) then 
			return 
		end

		local up_image = obj.transform
		up_image:SetParent(self.name.transform)
		obj.gameObject.transform.anchoredPosition3D = self.ui_up_image_info.vector
		obj.gameObject.transform.localScale = Vector3(1, 1, 1)
		obj = U3DObject(obj, obj.transform, self)
		obj.image:LoadSpriteAsync(self.ui_up_image_info.bundle, self.ui_up_image_info.asset, function()
			obj.image:SetNativeSize()
			up_image.gameObject:SetActive(self.ui_up_image_info.is_show)
		end)
	end)
end

function FollowNameBar:SetVipLevel(vip_level)
	self.vip_level = IS_AUDIT_VERSION and 0 or vip_level
	self:UpdateVipLevel()
end

function FollowNameBar:UpdateVipLevel()
	if nil == self.vip_level or nil == self.root_node then
		return
	end

	if self.obj_type ~= SceneObjType.Role and self.obj_type ~= SceneObjType.MainRole then
		return
	end

	local vip_icon_obj = self.node_list["VipIcon"]
	if nil == vip_icon_obj then
		return
	end

	if nil == self.default_vip_icon_act then
		self.default_vip_icon_act = vip_icon_obj:GetActiveSelf()
	end

	vip_icon_obj:SetActive(self.vip_level > 0)
	if self.vip_level > 0 then
		local bundle, asset = ResPath.GetVipLevelIcon(self.vip_level)
		vip_icon_obj.image:LoadSpriteAsync(bundle, asset, nil)
	end
end

function FollowNameBar:ResumeDefaultVipIconAct()
	if nil ~= self.default_vip_icon_act and nil ~= self.node_list["VipIcon"] then
		self.node_list["VipIcon"]:SetActive(self.default_vip_icon_act)
	end
end

function FollowNameBar:SetJingjieLevel(jingjie_level)
	self.jingjie_level = IS_AUDIT_VERSION and 0 or jingjie_level
	self:UpdateJingjieLevel()
end

function FollowNameBar:UpdateJingjieLevel()
	if nil == self.jingjie_level or nil == self.root_node then
		return
	end

	if self.obj_type ~= SceneObjType.Role and self.obj_type ~= SceneObjType.MainRole then
		return
	end

	local jingjie_icon_obj = self.node_list["JingjieIcon"]
	local jingjie_txt_obj = self.node_list["JingjieTxt"]
	
	if nil == jingjie_icon_obj or nil == jingjie_txt_obj then
		return
	end

	if nil == self.default_jingjige_icon_act then
		self.default_jingjige_icon_act = jingjie_icon_obj:GetActiveSelf()
	end

	if nil == self.default_jingjige_txt_act then
		self.default_jingjige_txt_act = jingjie_txt_obj:GetActiveSelf()
	end

	jingjie_icon_obj:SetActive(self.jingjie_level > 0)
	jingjie_txt_obj:SetActive(false)

	if self.jingjie_level > 0 then
		local bundle, asset = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(self.jingjie_level))
		jingjie_icon_obj.image:LoadSpriteAsync(bundle, asset, function ()
			jingjie_txt_obj:SetActive(true)
			jingjie_txt_obj.text.text = JingJieData.GetjingjieNum(self.jingjie_level)
		end)
	end
end

function FollowNameBar:ResumeDefaultJingjieAct()
	if nil ~= self.default_jingjige_icon_act and nil ~= self.node_list["JingjieIcon"] then
		self.node_list["JingjieIcon"]:SetActive(self.default_jingjige_icon_act)
	end

	if nil ~= self.default_jingjige_txt_act and nil ~= self.node_list["JingjieTxt"] then
		self.node_list["JingjieTxt"]:SetActive(self.default_jingjige_txt_act)
	end
end

function FollowNameBar:SetAchieveLevel(achieve_level)
	self.achieve_level = achieve_level
	self:UpdateAchieveLevel()
end

function FollowNameBar:UpdateAchieveLevel()
	if nil == self.achieve_level or nil == self.root_node then
		return
	end

	if self.obj_type ~= SceneObjType.Role and self.obj_type ~= SceneObjType.MainRole then
		return
	end
	
	local gameobj = self.node_list["AchieveLevelTxt"]
	if nil == gameobj then
		return
	end

	if nil == self.default_acheive_level_txt_act then
		self.default_acheive_level_txt_act = gameobj:GetActiveSelf()
	end

	gameobj:SetActive(self.achieve_level > 0)
	gameobj.text.text = AchieveData.Instance:GetTitleNameByLevel(self.achieve_level)
	self.achieve_title_list.text = AchieveData.Instance:GetTitleNameByLevel(self.achieve_level)

	local show_index = math.ceil(self.achieve_level / 25)
	gameobj.ui_gradient.Color1 = Gradient_Color1[show_index]
	gameobj.ui_gradient.Color2 = Gradient_Color2[show_index]
end

function FollowNameBar:ResumeDefaultAchieveLevelTxtAct()
	if nil ~= self.default_acheive_level_txt_act and nil ~= self.node_list["AchieveLevelTxt"] then
		self.node_list["AchieveLevelTxt"]:SetActive(self.default_acheive_level_txt_act)
	end
end

function FollowNameBar:SetDaFuHaoIconActive(is_active)
	self.is_dafuhao_active = is_active
	self:UpdateDaFuhaoIconActive()
end

function FollowNameBar:UpdateDaFuhaoIconActive()
	if nil == self.is_dafuhao_active or nil == self.root_node then
		return
	end

	local gameobj = self.node_list["DaFuHaoIcon"]
	if nil == gameobj then
		return
	end

	if nil == self.default_dafuhao_icon_act then
		self.default_dafuhao_icon_act = gameobj:GetActiveSelf()
	end

	gameobj:SetActive(self.is_dafuhao_active)
end

function FollowNameBar:ResumeDefaultDafuhaoIconAct()
	if nil ~= self.default_dafuhao_icon_act and nil ~= self.node_list["DaFuHaoIcon"] then
		self.node_list["DaFuHaoIcon"]:SetActive(self.default_dafuhao_icon_act)
	end
end
