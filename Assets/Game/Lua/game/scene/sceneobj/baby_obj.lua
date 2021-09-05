Baby = Baby or BaseClass(FollowObj)

-- 宝宝
function Baby:__init(baby_vo)
	self.obj_type = SceneObjType.Baby
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(baby_vo.baby_id)

	self.vo = baby_vo
	self.is_baby = true
	self.follow_offset = -1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 10
	self.is_visible = true
	self.bubble_cfg = {}
	self.other_cfg = {}
end

function Baby:__delete()
	self.obj_type = nil
	self.load_call_back = nil
	self.parent_name = nil

	self:CancelBobbleTimerQuest()
	self:CancelIntervalTimerQuest()
	self:DestroyBabyDisappearedEffect()
	self:CancelReleaseQuest()
	self:RemoveBabyDisappearedDelay()
end

function Baby:SetAttr(key, value)
	FollowObj.SetAttr(self, key, value)
end

function Baby:InitShow()
	if nil == self.vo.baby_id or 0 >= self.vo.baby_id then return end

	local is_change_scale = true
	for k, v in pairs(BaobaoData.BabyModel) do
	  	if self.vo.baby_id == v then
	  		is_change_scale = false
	  	end
	end  
	local transform = self.draw_obj:GetRoot().transform
	if is_change_scale then
		transform.localScale = Vector3(0.5, 0.5, 0.5)
	else
		transform.localScale = Vector3(1, 1, 1)
	end


	local role_sex = GameVoManager.Instance:GetMainRoleVo().sex or 0
	self.parent_name = Language.Marriage.BaoBaoChatCall[role_sex]

	FollowObj.InitShow(self)
	self:ShowFirstBubble()

	self:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(self.vo.baby_id))
	-- self:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(BaobaoData.BabyModel[self.vo.baby_id]))
	self:ShowFollowUi()
	local baby_name = self.vo.baby_name
	self:GetFollowUi():SetName(baby_name)
	self.follow_ui:SetHpVisiable(false)

	if nil == self.draw_obj or self.draw_obj:IsDeleted() then return end

	local complete_func = function(part, obj)
		self:PlayAppearEffect()
	end
	self.draw_obj:SetLoadComplete(complete_func)
end

function Baby:PlayAppearEffect(time)
	if not self.draw_obj then
		return
	end
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part or nil == main_part:GetObj() or not self:IsMyBaby() then return end
	local delay_time = time or 1

	self:RemoveBabyDisappearedDelay()
	self:DestroyBabyDisappearedEffect()

	local baby_obj = main_part:GetObj()
	self.baby_appear_effect = AllocAsyncLoader(self, "baby_effect_loader")
	self.baby_appear_effect:SetParent(baby_obj.transform)
	local bundle_name, asset_name = ResPath.GetMiscEffect("xianchongchuchang")
	self.baby_appear_effect:Load(bundle_name, asset_name)
	self.baby_delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self:DestroyBabyDisappearedEffect()
	end, delay_time)
end

-- 带渐变效果移除小宠物
function Baby:RemoveBabyWithFade(delete_call_back)
	self:ClearBubble()
	if not self:IsMyBaby() then
		delete_call_back()
		return
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part or nil == main_part:GetObj() then return end

	local baby_obj = main_part:GetObj()
	local fade_time = 0.5
	self:PlayBabyFade(0, fade_time, delete_call_back)
	if baby_obj and baby_obj.gameObject then
		self:DoBabyRun(baby_obj.gameObject, fade_time, 3)
		self:PlayAppearEffect(3)
	end
end

-- 小宠物渐变
function Baby:PlayBabyFade(fade_type, fade_time, call_back)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part then return end

	local baby_obj = main_part:GetObj()
	if baby_obj == nil then
		call_back()
		return
	end
	
	local fadeout = baby_obj.actor_fadout
	if fadeout ~= nil then
		if fade_type == 0 then
			fadeout:Fadeout(fade_time, call_back)
		elseif fade_type == 1 then
			fadeout:Fadein(fade_time, call_back)
		end
	else
		call_back()
	end
end

-- 小宠物位移
function Baby:DoBabyRun(obj, time, distance)
	if obj and obj.transform then
		local anim = obj:GetComponent(typeof(UnityEngine.Animator))
		if anim == nil then
			return
		end
		local target_pos = obj.transform.position + obj.transform.forward * distance
		if not self.game_root then
			self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
		end
		if self.game_root then
			obj.transform:SetParent(self.game_root.transform, true)
		end
		anim:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		local tween = obj.transform:DOMove(target_pos, time)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

-- 移除特效
function Baby:DestroyBabyDisappearedEffect()
	if self.baby_appear_effect ~= nil then
		self.baby_appear_effect:Destroy()
		self.baby_appear_effect:DeleteMe()
		self.baby_appear_effect = nil
	end
end

-- 清除特效延迟
function Baby:RemoveBabyDisappearedDelay()
	if self.baby_delay_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.baby_delay_time)
		self.baby_delay_time = nil
	end
end

function Baby:UpdateBabyId(baby_id)
	self.vo.baby_id = baby_id or self.vo.baby_id
end

function Baby:SetBabyName(baby_name)
	local baby_cfg = BaobaoData.Instance:GetBabyInfoCfg(self.vo.baby_id)

	if 0 < self.vo.baby_id then
		baby_name = baby_name ~= "" and baby_name or (baby_cfg and baby_cfg.name or "")
		self:GetFollowUi():SetName(baby_name)
		self.follow_ui:SetHpVisiable(false)
	end
end

function Baby:SetLoadCallBack(call_back)
	self.load_call_back = call_back
end

function Baby:LoadOver()
	if self.load_call_back then
		self.load_call_back()
	end
end

function Baby:IsCharacter()
	return false
end

function Baby:GetOwerRoleId()
	return self.vo.owner_role_id
end

function Baby:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 6
end

function Baby:IsBaby()
	return true
end

function Baby:SetBabyVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		if is_visible then
			self:SetBabyName("")
			self:GetFollowUi():Show()
		else
			self:GetFollowUi():Hide()
		end
	end
end

function Baby:ShowFirstBubble()
	if not self:IsMyBaby() then return end

	self:GetDialogCfg()
	local delay_time = self.diglog_cfg[self.cur_talk_index] and self.diglog_cfg[self.cur_talk_index].time or 5
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:CancelReleaseQuest()
			self:UpdataTimer()
		end, delay_time)
	end
end

function Baby:CancelReleaseQuest()
	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function Baby:GetDialogCfg()
	local dialog_random_num, dialog_random_cfg = BaobaoData.Instance:GetBaoBaoDialog()
	self.dialog_random_num = dialog_random_num
	self.diglog_cfg = dialog_random_cfg.dialog_cfg
	self.baby_talk = dialog_random_cfg.baby_first_talk
	self.talk_count = #self.diglog_cfg
	self.cur_talk_index = 1
end

function Baby:GetDialogText()
	local cur_dialog_child_cfg = self.diglog_cfg[self.cur_talk_index]
	local number_2 = cur_dialog_child_cfg and cur_dialog_child_cfg.dialog or 1
	local text = Language.Marriage.BaoBaoDialog[self.dialog_random_num][number_2]
	text = string.format(text, self.parent_name)

	self.cur_talk_index = self.cur_talk_index + 1
	self.baby_talk = not self.baby_talk
	return text
end

function Baby:UpdataBabyTalk()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		obj.follow_ui:HideBubble()
	end

	if nil ~= self.follow_ui then
		local dialog_text = self:GetDialogText()
		self.follow_ui:ChangeBubble(dialog_text)
		self.follow_ui:ShowBubble()
	end	

end

function Baby:UpdataRoleTalk()
	if nil ~= self.follow_ui then
		self.follow_ui:HideBubble()
	end

	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		local dialog_text = self:GetDialogText()
		obj.follow_ui:ChangeBubble(dialog_text)
		obj.follow_ui:ShowBubble()
	end	
end

function Baby:UpdataTimer()
	if self.baby_talk then
		self:UpdataBabyTalk()
	else
		self:UpdataRoleTalk()
	end

	if self.talk_count + 1 == tonumber(self.cur_talk_index) then
		self.hide_bubble_timer = true
		self.interval_time = 3
		self:SetTalkIntervalTimer()
		self:GetDialogCfg()
		return
	end

	local delay_time = self.diglog_cfg[self.cur_talk_index] and self.diglog_cfg[self.cur_talk_index].time or 5

	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, delay_time)
end

function Baby:CancelBobbleTimerQuest()
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
end

function Baby:ClearBubble()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		obj.follow_ui:HideBubble()
	end

	if nil ~= self.follow_ui then
		self.follow_ui:HideBubble()
	end			
end

function Baby:SetTalkIntervalTimer()
	self.interval_timer = GlobalTimerQuest:AddDelayTimer(function() 
		if self.hide_bubble_timer then
			self:ClearBubble()
			self.hide_bubble_timer = false
			self.interval_time = 180
			self:SetTalkIntervalTimer()
		else
			 self:CancelIntervalTimerQuest()
			 self:UpdataTimer()
		end
	end, self.interval_time)
end

function Baby:CancelIntervalTimerQuest()
	if self.interval_timer then
		GlobalTimerQuest:CancelQuest(self.interval_timer)
		self.interval_timer = nil
	end
end

function Baby:IsMyBaby()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end

	return false
end