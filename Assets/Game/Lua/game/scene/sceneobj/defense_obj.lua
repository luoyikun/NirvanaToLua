
DefenseObj = DefenseObj or BaseClass(SceneObj)

function DefenseObj:__init(item_vo)
	self.obj_type = SceneObjType.DefenseObj
	self.draw_obj:SetObjType(self.obj_type)
	-- self:SetObjId(item_vo.obj_id)
	self.rotation_y = 0
	self.effect_range = nil
end

function DefenseObj:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.async_loader then
		self.async_loader:DeleteMe()
		self.async_loader = nil
	end
	self.effect_range = nil
end

function DefenseObj:InitInfo()
	SceneObj.InitInfo(self)

	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil == gather_config then
		print_log("gather_config not find, gather_id:" .. self.vo.gather_id)
		return
	end

	self.vo.name = gather_config.show_name
	self.resid = gather_config.resid
	self.scale = gather_config.scale
	self.rotation_y = gather_config.rotation or 0
end

function DefenseObj:InitShow()
	SceneObj.InitShow(self)

	self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.resid))
	if self.scale then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.scale+1, self.scale+1, self.scale+1)
	end

	if Scene.Instance:GetSceneType() == SceneType.Kf_PVP then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.scale, self.scale, self.scale)
	end

	if self.rotation_y ~= 0 then
		self.draw_obj:Rotate(0, self.rotation_y, 0)
	end
end

function DefenseObj:OnEnterScene()
	SceneObj.OnEnterScene(self)
	local scene_id = Scene.Instance:GetSceneId()
	if self.vo then
		self:ActiveFollowUi()
		self.follow_ui:SetRootLocalScale(1.5)
	end
end

function DefenseObj:GetGatherId()
	return self.vo.gather_id
end

function DefenseObj:CancelSelect()
	if SceneObj.select_obj then
		return 
	end
	
	if SceneObj.select_obj and SceneObj.select_obj == self then
		SceneObj.select_obj = nil
	end
	self.is_select = false
	if self:CanHideFollowUi() and nil ~= self.follow_ui and not self:IsRole() and not self:IsEvent() then
		self:GetFollowUi():Hide()
	end
end

function DefenseObj:CanHideFollowUi()
	return not self.is_select and (self.vo and self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE)
end

function DefenseObj:ShowAttackRangeRadius()
	if self.draw_obj then
		if self.effect_range == nil then
			self:PlayerEffectAddtion()
		else
			self.effect_range.gameObject:SetActive(true)
		end
	end
end

function DefenseObj:HideAttackRangeRadius()
	if self.draw_obj and self.effect_range then
		self.effect_range.gameObject:SetActive(false)
	end
end

function DefenseObj:PlayerEffectAddtion()
	local position = self.draw_obj:GetRoot().transform.position
	self.async_loader = AllocAsyncLoader(self, "defense_loader")
	local bundle_name, asset_name = ResPath.GetMiscEffect("yuanxinggongjifanwei")
	self.async_loader:Load(bundle_name, asset_name, function (obj)
		if not IsNil(obj) then

			self.effect_range = obj.transform
			self.effect_range:SetParent(self.draw_obj:GetRoot().transform, false)
			self.effect_range.position = Vector3(position.x, position.y + 0.25, position.z)
		end
	end)
end