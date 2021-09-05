SPECIAL_GATHER_TYPE =
{
	JINGHUA = 1,				-- 精华采集
	GUILDBATTLE = 2,			-- 公会争霸采集物
	FUN_OPEN_MOUNT = 3, 		-- 功能开启副本-坐骑
	FUN_OPEN_WING = 4,			-- 功能开启副本-羽翼
	GUILD_BONFIRE = 5,			-- 仙盟篝火
	CROSS_FISHING = 6,			-- 钓鱼鱼篓
	SPEICAL_GATHER_TYPE_CROSS_GUILD_BATTLE_BOSS = 7,			-- 跨服六界
	SPECIAL_GATHER_TYPE_HUSONG_SHUIJING = 8 			--跨服护送水晶
}

local ShowFollowUiScene = {
	[1500] = 1, 					--水晶幻境
	[9240] = 2, 					--跨服钓鱼
}

GatherObj = GatherObj or BaseClass(SceneObj)

function GatherObj:__init(item_vo)
	self.obj_type = SceneObjType.GatherObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(item_vo.obj_id)
	self.rotation_y = 0
	self.gather_id = 0
	self.enable = false
end

function GatherObj:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function GatherObj:InitInfo()
	SceneObj.InitInfo(self)

	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil == gather_config then
		print_log("gather_config not find, gather_id:" .. self.vo.gather_id)
		return
	end
	self.vo.name = gather_config.show_name
	self.gather_color = gather_config.color or 1
	self.resid = gather_config.resid
	self.scale = gather_config.scale
	self.rotation_y = gather_config.rotation or 0
end

function GatherObj:ReloadUIName()
	local name = ""
	if SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then  -- 精灵采集物显示名称
		if SpiritData.Instance:GetSpiritType(self.vo.gather_id) == SPIRIT_QUALITY.PURPLE then
			name = "<color=#f12fea>".. self.vo.name .. "</color>"
		end
	elseif self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		name = string.format(Language.Guild.GuildGoddessName, self.vo.param2)
	elseif self.vo.special_gather_type == SPECIAL_GATHER_TYPE.CROSS_FISHING then
		name = self.vo.param2 .. "·" .. self.vo.name
	else
		name = string.format(Language.Common.ToColor, GATHER_COLOR[self.gather_color], self.vo.name)
	end
	if self.follow_ui ~= nil then
		self.follow_ui:SetName(name or "", self)
	end
end

function GatherObj:InitShow()
	SceneObj.InitShow(self)
	if SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then
		self:ReloadUIName()
		self.rotation_y = DownAngleOfCamera
		self:GetFollowUi():ShowFollowUIUpImage(self.vo.gather_id, true, "uis/images_atlas", "arrow_gather", Vector3(0, 50, 0))
	end

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.SPEICAL_GATHER_TYPE_CROSS_GUILD_BATTLE_BOSS then
		self.vo.name = ToColorStr("[" .. ToColorStr(self.vo.param2, TEXT_COLOR.GREEN) .. "]" .. Language.KuafuGuildBattle.PronGuildName .. self.vo.name, TEXT_COLOR.WHITE)
		self:ActiveFollowUi()
	end

	if SceneType.HunYanFb == Scene.Instance:GetSceneType() and MarriageData.Instance:GetIsHasGather(self.obj_id) then
		self.resid = MarrGatherId or 0
	end
	local tesk_tree = TaskData.Instance:GetGatherIdTree(self.vo.gather_id)
	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		local res_id = GuildBonfireData.Instance:GetBonfireOtherCfg().gather_res
		self:ChangeModel(SceneObjPart.Main, ResPath.GetNpcModel(res_id))
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(1.5, 1.5, 1.5)
	elseif tesk_tree and tesk_tree.task_id and tesk_tree.gather_id then
		local is_complete = TaskData.Instance:GetShuTaskState(tesk_tree.task_id)
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.resid))
		local task_cfg = TaskData.Instance:GetTaskConfig(tesk_tree.task_id)
		local current_count = TaskData.Instance:GetProgressNum(tesk_tree.task_id)
		if task_cfg then
			if is_complete or current_count >= 2 then
				self:SetGatherTrigger(ActionStatus.Status2Stop)
				if is_complete then
					local bundle, asset = "actors/gather/6201_prefab", "6201002_TX"
					self:SetEffectShow(bundle, asset)
				end
			elseif current_count > 0 then
				self:SetGatherTrigger(ActionStatus.Status1Stop)
			end
		end
		if self.scale then
			local transform = self.draw_obj:GetRoot().transform
			transform.localScale = Vector3(self.scale, self.scale, self.scale)
		end
	else
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.resid))
		if self.scale then
			local transform = self.draw_obj:GetRoot().transform
			transform.localScale = Vector3(self.scale, self.scale, self.scale)
		end
	end
	if self.rotation_y ~= 0 then
		self.draw_obj:Rotate(0, self.rotation_y, 0)
	end
end


function GatherObj:OnEnterScene()
	SceneObj.OnEnterScene(self)
	local scene_id = Scene.Instance:GetSceneId()
	if self.vo and self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		self:ActiveFollowUi()
		self:GetFollowUi():SetRootLocalScale(1.5)
	end

	if nil ~= ShowFollowUiScene[scene_id] then
		self:ActiveFollowUi()
	end
	self:PlayAction()

	if self.draw_obj then
		self.draw_obj:SetWaterHeight(COMMON_CONSTS.WATER_HEIGHT)
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			local flag = scene_logic:IsCanCheckWaterArea() and true or false
			self.draw_obj:SetCheckWater(flag)
		end
	end
end

function GatherObj:GetGatherId()
	return self.vo.gather_id
end

function GatherObj:IsGather()
	return true
end

function GatherObj:CancelSelect()
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

	if not self:IsMainRole() and Scene.Instance:GetSceneType() == SceneType.HotSpring then
		--温泉场景双修
		GlobalEventSystem:Fire(ObjectEventType.CLICK_SHUANGXIU, self, self.vo, "cancel")
	end
end

function GatherObj:CanHideFollowUi()
	return not self.is_select and (self.vo and self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE)
end

function GatherObj:PlayAction()
	if nil == self.vo or self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		return
	end
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("Action")
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function() self:PlayAction() end, 10)
		end
	end
end

function GatherObj:ChangeGatherTimes(times)
	self.vo.param3 = times
end

function GatherObj:ShowObjEffect(enable, bundle, asset, gather_id_low, gather_id_high)
	if Scene.Instance:GetSceneType() == SceneType.KF_Fish then
		local follow_ui = self.follow_ui or self:GetFollowUi()
		if self.gather_id_low == gather_id_low and self.gather_id_high == gather_id_high and self.enable == enable then
			return
		end
		self.gather_id_low = gather_id_low
		self.gather_id_high = gather_id_high
		self.enable = enable
		follow_ui:ShowFishImage(enable, bundle, asset)
	end
end

function GatherObj:SetGatherTrigger(index)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, index)
			if index == ActionStatus.Die then
				self:SetIsCanClick(false)
				if part:GetObj() and part:GetObj().animator then
					part:GetObj().animator:WaitEvent("die_exit", function ()
						Scene.Instance:DeleteObj(self.obj_id)
					end)
				end
			end
		end
	end
end

function GatherObj:SetEffectShow(bundle, asset)
	local transform = self.draw_obj:GetRoot().transform
	ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end
		if transform == nil or IsNil(transform) then
			ResPoolMgr:Release(obj)
			return
		end
		obj.transform:SetParent(transform, false)
		self.effect_obj = obj
	end)
end