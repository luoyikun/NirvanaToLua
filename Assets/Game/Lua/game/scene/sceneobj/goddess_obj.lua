Goddess = Goddess or BaseClass(FollowObj)

function Goddess:__init(vo)
	self.obj_type = SceneObjType.GoddessObj
	self.draw_obj:SetObjType(self.obj_type)
	self.goddess_res_id = 0
	self.goddess_fazhen_res_id = 0
	self.goddess_halo_res_id = 0
	self.is_goddess = true
	self:SetObjId(vo.obj_id)
	self.is_visible = true
	self.goddess_timer = 0

	self.follow_offset = 1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 7
end

function Goddess:__delete()
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end

	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
	self.vo.owner_role = nil
end

function Goddess:InitShow()
	FollowObj.InitShow(self)
	self:UpdateModelResId()
	self:UpdateWingResId()
	self:UpdateShenGongResId()
	self:ShowFollowUi()
	self:ShowFirstBubble()
	self.follow_ui:SetHpVisiable(false)

	if self.goddess_res_id ~= nil and self.goddess_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	end

	if self.goddess_fazhen_res_id ~= nil and self.goddess_fazhen_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetGoddessFaZhenModel(self.goddess_fazhen_res_id))
	end

	if self.goddess_halo_res_id ~= nil and self.goddess_halo_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetGoddessHaloModel(self.goddess_halo_res_id))
	end

	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				local complete_func = function(part, obj)
					if part == SceneObjPart.Main then
						local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
						if main_part then
							main_part:SetTrigger("ShowSceneIdle")
						end
						local transform = self.draw_obj:GetRoot().transform
						transform.localScale = Vector3(0.9, 0.9, 0.9)
					end
					self:OnModelLoaded(part, obj)
				end
				main_part:SetTrigger("ShowSceneIdle")
				self.draw_obj:SetLoadComplete(complete_func)
			end
		end
	end	
end

function Goddess:ReloadUIName()
	local role = self.vo.owner_role
	if not role then
		return
	end
	local role_vo = role:GetVo()
	local xiannv_name = role_vo.xiannv_name
	if role:IsMainRole() then
		xiannv_name = GoddessData.Instance:GetXiannvName(role_vo.use_xiannv_id)
	end
	if xiannv_name == nil or xiannv_name == "" then
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(role_vo.use_xiannv_id)
		if xiannv_cfg then
			xiannv_name = xiannv_cfg.name
		end
	end

	if self.follow_ui ~= nil then
		self.follow_ui:SetName(xiannv_name or "", self)
	end
end

function Goddess:SetAttr(key, value)
	FollowObj.SetAttr(self, key, value)
	if key == "use_xiannv_id" then
		self:UpdateModelResId()
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	elseif key == "goddess_wing_id" then
		self:UpdateWingResId()
		self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetGoddessFaZhenModel(self.goddess_fazhen_res_id))
	elseif key == "goddess_shen_gong_id" then
		self:UpdateShenGongResId()
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetGoddessHaloModel(self.goddess_halo_res_id))
	elseif key == "name" then
		self:ReloadUIName()
	elseif key == "xiannv_huanhua_id" then
		self:UpdateHuanhuaModelResId()
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	end
end

function Goddess:UpdateModelResId()
	local goddess_data = GoddessData.Instance
	if self.vo.use_xiannv_id > -1 then
		local goddess_config = goddess_data:GetXianNvCfg(self.vo.use_xiannv_id)
		if goddess_config then
			local resid = goddess_config.resid
			if resid then
				self.goddess_res_id = resid
			end
		end
		local xiannv_huanhua_id = self.vo.xiannv_huanhua_id
		if xiannv_huanhua_id > -1 then
			local cfg = goddess_data:GetXianNvHuanHuaCfg(xiannv_huanhua_id)
			if cfg then
				self.goddess_res_id = goddess_data:GetXianNvHuanHuaCfg(xiannv_huanhua_id).resid
			end
		end
	end
end

function Goddess:UpdateHuanhuaModelResId()
	local xiannv_huanhua_id = self.vo.xiannv_huanhua_id
	if xiannv_huanhua_id > -1 then
		local goddess_config = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_huanhua_id)
		if goddess_config then
			local resid = goddess_config.resid
			if resid then
				self.goddess_res_id = resid
			end
		end
	end
end

function Goddess:CanHideFollowUi()
	return false
end

function Goddess:UpdateWingResId()
	if self.vo.goddess_wing_id and self.vo.goddess_wing_id ~= 0 then
		local res_id = 0
		if self.vo.goddess_wing_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local images_cfg = ShenyiData.Instance:GetSpecialImagesCfg()
			if images_cfg and images_cfg[self.vo.goddess_wing_id - GameEnum.MOUNT_SPECIAL_IMA_ID] then
				res_id = images_cfg[self.vo.goddess_wing_id - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id or 0
			end
		else
			local images_cfg = ShenyiData.Instance:GetShenyiImageCfg()
			if images_cfg and images_cfg[self.vo.goddess_wing_id] then
				res_id = images_cfg[self.vo.goddess_wing_id].res_id or 0
			end
		end
		self.goddess_fazhen_res_id = res_id
	end
end

function Goddess:UpdateShenGongResId()
	if self.vo.goddess_shen_gong_id and self.vo.goddess_shen_gong_id ~= 0 then
		local res_id = 0
		if self.vo.goddess_shen_gong_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local images_cfg = ShengongData.Instance:GetSpecialImagesCfg()
			if images_cfg and images_cfg[self.vo.goddess_shen_gong_id - GameEnum.MOUNT_SPECIAL_IMA_ID] then
				res_id = images_cfg[self.vo.goddess_shen_gong_id - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id or 0
			end
		else
			local images_cfg = ShengongData.Instance:GetShengongImageCfg()
			if images_cfg and images_cfg[self.vo.goddess_shen_gong_id] then
				res_id = images_cfg[self.vo.goddess_shen_gong_id].res_id or 0
			end
		end
		self.goddess_halo_res_id = res_id
		-- self.goddess_halo_res_id = 12000 + self.vo.goddess_shen_gong_id
	end
end

function Goddess:IsCharacter()
	return false
end

function Goddess:GetOwerRoleId()
	return self.vo.owner_role_id
end

function Goddess:SetTrigger(key)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetTrigger(key)
		end
		if weapon_part then
			weapon_part:SetTrigger(key)
		end
	end
end

function Goddess:SetBool(key, value)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetBool(key, value)
		end
		if weapon_part then
			weapon_part:SetBool(key, value)
		end
	end
end

function Goddess:SetInteger(key, value)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetInteger(key, value)
		end
		if weapon_part then
			weapon_part:SetInteger(key, value)
		end
	end
end

function Goddess:DoAttack(...)
	Character.DoAttack(self, ...)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetTrigger(SceneObjAnimator.Atk1)
		end
	end
end

function Goddess:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	Character.EnterStateAttack(self, anim_name)
end

function Goddess:IsGoddess()
	return true
end

function Goddess:IsGoddessVisible()
	return self.is_visible
end

function Goddess:SetGoddessVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		if is_visible then
			self:GetFollowUi():Show()
		else
			self:GetFollowUi():Hide()
		end

	end
end

function Goddess:GetRandBubbletext()
	local temp_list = self:GetGoddessBubbleCfg()
	if #temp_list > 0 then
		math.randomseed(os.time())
		local bubble_text_index = math.random(1, #temp_list)
		return temp_list[bubble_text_index].bubble_goddess_text
	else
		return ""
	end
end

function Goddess:GetGoddessBubbleCfg()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_goddess_list
	local temp_list = {}
	for k,v in pairs(bubble_cfg) do
		if v.goddess_scene_id == Scene.Instance:GetSceneType() then
			table.insert(temp_list,v)
		end
	end
	return temp_list
end

function Goddess:GetFirstBubbleText()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_goddess_list
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(bubble_cfg) do
		if v.goddess_scene_id == scene_id then
			return v.bubble_goddess_text
		end
	end
end

function Goddess:ShowFirstBubble()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			if nil ~= self.follow_ui and self:IsMyGoddess() then
				local text = self:GetFirstBubbleText()
				if nil ~= text then
					self.follow_ui:ChangeBubble(text)
				end
			end
			self:UpdataTimer()
		end, 1)
	end
end

function Goddess:UpdataBubble()
	if nil ~= self.follow_ui then
		local text = self:GetRandBubbletext()
		self.follow_ui:ChangeBubble(text)
	end
end

function Goddess:UpdataTimer()
	local exist_time = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].exist_time
	local goddess_interval = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].goddess_interval
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
	end
	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, exist_time)
	local temp_list = self:GetGoddessBubbleCfg()
	if self.goddess_timer and nil ~= self.follow_ui and self:IsMyGoddess() and #temp_list > 0 then
		if self.goddess_timer >= goddess_interval then
			self.goddess_timer = self.goddess_timer - goddess_interval
			local rand_num = math.random(1, 10)
			local goddess_odds = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].goddess_odds
			if rand_num * 0.1 <= goddess_odds then
				self:UpdataBubble()
				self.follow_ui:ShowBubble()
			end
		else
			self.follow_ui:HideBubble()
		end
	end
	self.goddess_timer = self.goddess_timer + exist_time
end

function Goddess:IsMyGoddess()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end
	return false
end