GuildAnswerSceneLogic = GuildAnswerSceneLogic or BaseClass(CommonActivityLogic)

function GuildAnswerSceneLogic:__init()

end

function GuildAnswerSceneLogic:__delete()
	GlobalTimerQuest:CancelQuest(self.show_tips_delay)
	if self.activity_call_back and ActivityData.Instance then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function GuildAnswerSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:ResetSelectObj()

	local target = {scene = 151, x = 56, y = 84, id = 376}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.GuildAnswerTask)
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)

	self.activity_call_back = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.GUILD_ANSWER) then
		return
	else
		ViewManager.Instance:Open(ViewName.ChatGuild)
	end

end

function GuildAnswerSceneLogic:Update(now_time, elapse_time)
	CommonActivityLogic.Update(self, now_time, elapse_time)
end

function GuildAnswerSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	ViewManager.Instance:Close(ViewName.GuildAnswerTask)
	ViewManager.Instance:Close(ViewName.ChatGuild)
end


function GuildAnswerSceneLogic:ActivityChangeCallback(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.GUILD_ANSWER and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER) then
		ViewManager.Instance:Open(ViewName.ChatGuild)
	end
end


-- function GuildAnswerSceneLogic:GuaiJiMonsterUpdate(now_time, elapse_time)
-- 	local main_role = Scene.Instance:GetMainRole()
-- 	local main_role_x, main_role_y = main_role:GetLogicPos()
-- 	local target_obj = MainuiData.Instance:GetTargetObj()
-- 	local gather_list = Scene.Instance:GetGatherList()

-- 	local player_info = GuildAnswerData.Instance:GetQuestionPlayerInfo()
-- 	local other_cfg = GuildAnswerData.Instance:GetGuildQuestionOtherCfg()
-- 	if player_info.is_gather > 0 then return end

-- 	if next(gather_list) ~= nil then
-- 		local _, gather_item = next(gather_list)
-- 		local now_distance = 100000000
-- 		for k,v in pairs(gather_list)do
-- 			if v:GetVo().gather_id == other_cfg.gather_id then
-- 				local target_x, target_y = v:GetLogicPos()
-- 				local delta_pos = cc.pSub(cc.p(target_x, target_y), cc.p(main_role_x, main_role_y))
-- 				local distance = cc.pGetLength(delta_pos)
-- 				if distance < now_distance then
-- 					gather_item = v
-- 					now_distance = distance
-- 				end
-- 			end
-- 		end
-- 		self:MoveToObj(gather_item, false)

-- 		-- MainuiCtrl.Instance:SetTargetObj(gather_item)
-- 	end
-- end