MonsterFollow = MonsterFollow or BaseClass(CharacterFollow)

function MonsterFollow:__init()
	self.obj_type = nil
	self.is_boss = false
end

function MonsterFollow:__delete()
	if self.open_delay then
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end
end

function MonsterFollow:OnRootCreateCompleteCallback(gameobj)
	CharacterFollow.OnRootCreateCompleteCallback(self, gameobj)

	self:UpdateShowFollowUIUpImage()
end

function MonsterFollow:SetIsBoss(is_boss)
	self.is_boss = is_boss
	if self.is_boss then
		self:Hide()
	end
end

function MonsterFollow:Show()
	if not self.is_boss then
		self:SetHpVisiable(true)
	end
end

function MonsterFollow:Hide()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Defensefb then 
		self:SetHpVisiable(false)
		self:SetNameIsActive(false)
	end
end

function MonsterFollow:ShowName()
	self:SetNameIsActive(true)
end

function MonsterFollow:HideName()
	self:SetNameIsActive(false)
end

function MonsterFollow:ShowFollowUIUpImage(obj_id)
	self.follow_ui_up_image_obj_id = obj_id
	self:UpdateShowFollowUIUpImage()
end

function MonsterFollow:UpdateShowFollowUIUpImage()
	if nil == self.follow_ui_up_image_obj_id or nil == self.root then
		return
	end

	local async_loader = AllocAsyncLoader(self, "up_image" .. self.follow_ui_up_image_obj_id)
	local bundle_name, asset_name = ResPath.GetUiEffect("effect_sjjt_dc")
	async_loader:Load(bundle_name, asset_name, function (obj)
		if not IsNil(obj) then
			self.up_image = obj.transform
			self.up_image:SetParent(self.root.transform)
			obj.gameObject.transform.localPosition = Vector3(0, 50, 0)
			-- obj.gameObject.transform.anchoredPosition3D = Vector3(0, 50, 0)
			obj.gameObject.transform.localScale = Vector3(1, 1, 1)
			obj.gameObject:SetActive(false)
		end
	end)
end

function MonsterFollow:IsShowFollowUIUpImage(enable)
	if self.open_delay then
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end
	self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
		if not IsNil(self.up_image) then
			self.up_image.gameObject:SetActive(enable)
		end
	end, 0.1)
end