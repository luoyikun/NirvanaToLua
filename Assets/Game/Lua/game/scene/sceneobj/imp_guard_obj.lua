
ImpGuardObj = ImpGuardObj or BaseClass(FollowObj)

-- 小鬼
function ImpGuardObj:__init(spirit_vo)
	self.obj_type = SceneObjType.ImpGuardObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(spirit_vo.imp_guard_id)
	self.vo = spirit_vo
	self.is_spirit = true

	self.follow_offset = -1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 5
end

function ImpGuardObj:__delete()
	self.obj_type = nil
	self.load_call_back = nil
	--if self.draw_obj then
		--ResMgr:Destroy(self.draw_obj:GetRoot().gameObject)
	--end
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
	self:DeleteFaZhen()
end

function ImpGuardObj:InitShow()
	-- self:ShowFirstBubble()
	FollowObj.InitShow(self)

	if self.vo.imp_guard_id ~= nil and self.vo.imp_guard_id ~= 0 then
		local imp_guard_cfg = nil
		imp_guard_cfg = EquipData.GetXiaoGuiCfgType(self.vo.imp_guard_id)
		if imp_guard_cfg and  imp_guard_cfg.appe_image_id and imp_guard_cfg.appe_image_id > 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetImpGuardModel(imp_guard_cfg.res_id))
			self:ShowFollowUi()
			local imp_guard_name = imp_guard_cfg.imp_guard_name
			self:GetFollowUi():SetName(imp_guard_name)
			self.follow_ui:SetHpVisiable(false)
		end
	end
end

function ImpGuardObj:UpdateImpGuardInfo(imp_guard_id)
	self.vo.imp_guard_id = imp_guard_id or self.vo.imp_guard_id

	if self.vo.imp_guard_id ~= nil and self.vo.imp_guard_id ~= 0 then
		local imp_guard_cfg = nil
		imp_guard_cfg = EquipData.IsXiaoguiEqType(self.vo.imp_guard_id)

		if imp_guard_cfg and  imp_guard_cfg.appe_image_id and imp_guard_cfg.appe_image_id > 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetImpGuardModel(imp_guard_cfg.res_id))
			local imp_guard_name = imp_guard_cfg.imp_guard_name
			self:GetFollowUi():SetName(imp_guard_name)
			self.follow_ui:SetHpVisiable(false)
		end
	end
end

function ImpGuardObj:UpdateSpecialSpritId(user_pet_special_img)
	self.vo.user_pet_special_img = user_pet_special_img or -1
end

-- function ImpGuardObj:UpdateSpiritTitle()
-- 	local is_active_title, title_id = TitleData.Instance:IsActiveLingPoTitle()
-- 	if is_active_title then
-- 		self:GetFollowUi():SetTitle(1, title_id)
-- 	end
-- end

-- function ImpGuardObj:SetImpGuardName(imp_guard_name)
-- 	if self.vo.imp_guard_id ~= nil and self.vo.imp_guard_id ~= 0 then
-- 		local spirit_cfg = nil
-- 		if self.vo.user_pet_special_img ~= nil and self.vo.user_pet_special_img >= 0 then
-- 			spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(self.vo.user_pet_special_img)
-- 		else
-- 			spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.imp_guard_id)
-- 		end

-- 		if spirit_cfg and  spirit_cfg.res_id and spirit_cfg.res_id > 0 then
-- 			spirit_name = spirit_name ~= "" and spirit_name or spirit_cfg.name
-- 			spirit_name = spirit_name or spirit_cfg.image_name
-- 			self:GetFollowUi():SetName(spirit_name)
-- 		end
-- 	end
-- end

function ImpGuardObj:SetLoadCallBack(call_back)
	self.load_call_back = call_back
end

function ImpGuardObj:LoadOver()
	local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
	if is_hide then
		self:GetDrawObj():SetVisible(not is_hide)
		self:GetFollowUi():Hide()
	end
	if self.load_call_back then
		self.load_call_back()
	end
end

function ImpGuardObj:IsCharacter()
	return false
end

function ImpGuardObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

function ImpGuardObj:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 6
end

function ImpGuardObj:IsImpGuard()
	return true
end

function ImpGuardObj:SetImpGuardVisible(is_visible)
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
	-- if not is_visible then
	-- 	self:ChangeSpiritFazhen()
	-- end
end

function ImpGuardObj:GetRandBubbletext()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_jingling_list

	local temp_list = {}
	for k,v in pairs(bubble_cfg) do
		if v.jingling_scene_id == 0 then
			table.insert(temp_list,v)
		end
	end

	if #temp_list > 0 then
		math.randomseed(os.time())
		local bubble_text_index = math.random(1, #temp_list)
		return temp_list[bubble_text_index].bubble_jingling_text
	else
		return ""
	end
end

function ImpGuardObj:GetFirstBubbleText()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_jingling_list
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(bubble_cfg) do
		if v.jingling_scene_id == scene_id then
			return v.bubble_jingling_text
		end
	end
end

function ImpGuardObj:ShowFirstBubble()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			if nil ~= self.follow_ui and self:IsMySpirit() then
				local text = self:GetFirstBubbleText()
				if nil ~= text then
					self.follow_ui:ChangeBubble(text)
				end
			end
			self:UpdataTimer()
		end, 8)
	end
end

function ImpGuardObj:UpdataBubble()
	if nil ~= self.follow_ui then
		local text = self:GetRandBubbletext()
		self.follow_ui:ChangeBubble(text)
	end
end

function ImpGuardObj:UpdataTimer()
	local exist_time = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].exist_time
	local jingling_interval = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].jingling_interval
	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, exist_time)

	if self.timer and nil ~= self.follow_ui and self:IsMySpirit() then
		if self.timer >= jingling_interval then
			self.timer = self.timer - jingling_interval
			local rand_num = math.random(1, 10)
			local jingling_odds = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].jingling_odds
			if rand_num * 0.1 <= jingling_odds then
				self:UpdataBubble()
				self.follow_ui:ShowBubble()
			end
		else
			self.follow_ui:HideBubble()
		end
	end
	self.timer = self.timer and self.timer + exist_time or exist_time
end

function ImpGuardObj:IsMySpirit()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end
	return false
end

function ImpGuardObj:ChangeSpiritFazhen(res_id)
	if self.is_visible and nil ~= self.draw_obj then
		if not self.spirit_fazhen then
			self.spirit_fazhen = self.spirit_fazhen or AllocAsyncLoader(self, "spirit_fazhen_loader")
			self.spirit_fazhen:SetParent(self.draw_obj:GetAttachPoint(AttachPoint.Mount))
		end
		if res_id and res_id ~= "" then
			local bundle, asset = ResPath.GetEffect(res_id)
			local load_call_back = function(obj)
				if IsNil(obj) then
					return
				end
				if not self.is_visible then
					self:DeleteFaZhen()
					return
				end
			end
			self.spirit_fazhen:Load(bundle, asset, load_call_back)
		else
			self:DeleteFaZhen()
		end
	else
		self:DeleteFaZhen()
	end
end

function ImpGuardObj:DeleteFaZhen()
	if self.spirit_fazhen then
		self.spirit_fazhen:DeleteMe()
		self.spirit_fazhen = nil
	end
end