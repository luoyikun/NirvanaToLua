MarryObj = MarryObj or BaseClass(Character)
local point_t = {
	"guadian_tai01",
	"guadian_tai04",
	"guadian_tai05",
	"guadian_tai08",
}
function MarryObj:__init(marry_vo)
	self.marry_time = 0
	self.obj_type = SceneObjType.MarryObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(marry_vo.obj_id)
	self.vo = marry_vo
	self.is_first = false
	self.effect = {}
	self.effect_delay = {}
end

function MarryObj:__delete()
	if MarriageData.Instance then
		local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
		local vo = Scene.Instance:GetObjectByObjId(hunyan_info.role_id)
		local lover_vo = Scene.Instance:GetObjectByObjId(hunyan_info.lover_role_id)
		GlobalTimerQuest:AddDelayTimer(function()
			if vo then
				local target_point = vo:GetRoot().transform
				vo:SetMarryFlag(0)
				if not IsNil(MainCameraFollow) and MarriageData.Instance:IsMarryUser() then
					MainCameraFollow.Target = target_point
				end
			end

			if lover_vo then
				lover_vo:SetMarryFlag(0)
			end
		end, 0)
	end

	if self.vo.marry_seq == CruiseType.HuaJiao then
		for _,v in pairs(self.qiaofu) do
			ResMgr:Destroy(v)
		end
	end

	if self.follow_ui then
		self.follow_ui:DeleteMe()
		self.follow_ui = nil
	end

	for k,v in pairs(self.effect_delay) do
		GlobalTimerQuest:CancelQuest(v)
		self.effect_delay[k] = nil
	end
	self.effect_delay = nil

	for k,v in pairs(self.effect) do
		v:Destroy()
		v:DeleteMe()
		self.effect[k] = nil
	end
	self.effect = nil

	self.vo = nil
end

function MarryObj:InitShow()
	Character.InitShow(self)

	local cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").hunyan_xunyou_duiwu
	self.res_id = cfg[self.vo.marry_seq + 1].show_model or 0

	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)

	self.qiaofu = {}
	if self.res_id ~= nil and self.res_id~= 0 then
		local bundle_name, asset_name = ResPath.GetNpcModel(self.res_id)
		self:ChangeModel(SceneObjPart.Main, bundle_name, asset_name, 
			function (obj)
				if obj then
					if self.vo.marry_seq == CruiseType.HuaJiao then
						bundle_name, asset_name = ResPath.GetNpcModel("4123001")
						for i = 1, 4 do
							if i > 2 then
								bundle_name, asset_name = ResPath.GetNpcModel("4123002")
							end
							ResPoolMgr:GetDynamicObjAsyncInQueue(
								bundle_name,
								asset_name,
								function (qiaofu_obj)
									local obj_guadian = obj.transform:FindByName(point_t[i])
									qiaofu_obj.transform:SetParent(obj_guadian, false)
									self.qiaofu[i] = qiaofu_obj
								end)
						end
					end
					if not self:IsMove() then
						if self.vo.distance > 0.1 then
							self:DoMove(math.floor(self.vo.pos_x + math.cos(self.vo.dir) * self.vo.distance), math.floor(self.vo.pos_y + math.sin(self.vo.dir) * self.vo.distance))
						end
					end
					if self.vo.marry_seq == CruiseType.HuaTong then
						local part = self.draw_obj:GetPart(SceneObjPart.Main)
						local main_part_obj = part:GetObj()
						if main_part_obj then
							local children = main_part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Animator))
							for i = 0, children.Length - 1 do
								children[i]:WaitEvent("Sahua", BindTool.Bind(self.SahuaEffect, self, i + 1))
							end
						end
					end
				end

			end)
	end
end

function MarryObj:SahuaEffect(i)
	if not self.draw_obj then return end
	
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part or nil == main_part:GetObj() then return end

	if self.effect_delay[i] then
		self:RemoveEffectDelay(i)
	end

	if self.effect[i] then
		self:RemoveEffect(i)
	end

	local main_obj = main_part:GetObj()
	local draw_position = {
		{x = main_obj.transform.localPosition.x + 1.5, z = main_obj.transform.localPosition.y},
		{x = main_obj.transform.localPosition.x - 1.5, z = main_obj.transform.localPosition.y},
	}
	self.effect[i] = AllocAsyncLoader(self, "sahua" .. i)
	self.effect[i]:Load("effects/prefab/other/sahua2_prefab", "sahua2", function(obj)
		if IsNil(obj) then
			return
		end		
		local transform = obj.transform
		transform:SetParent(main_obj.transform, false)
		transform.localPosition = Vector3(draw_position[i].x, draw_position[i].y, main_obj.transform.localPosition.z)
	end)
	self.effect_delay[i] = GlobalTimerQuest:AddDelayTimer(function()
		self:RemoveEffect(i)
	end, 2)
end

function MarryObj:RemoveEffect(i)
	if self.effect[i] ~= nil then
		self.effect[i]:Destroy()
		self.effect[i]:DeleteMe()
		self.effect[i] = nil
	end
end

function MarryObj:RemoveEffectDelay(i)
	if self.effect_delay[i] ~= nil then
		GlobalTimerQuest:CancelQuest(self.effect_delay[i])
		self.effect_delay[i] = nil
	end
end

function MarryObj:IsMarryObj()
	return true
end

function MarryObj:DoMove(pos_x, pos_y)
	Character.DoMove(self, pos_x, pos_y)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local main_part_obj = part:GetObj()
	if main_part_obj then
		local children = main_part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Animator))
		for i = 0, children.Length - 1 do
			children[i]:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		end
	end
end

function MarryObj:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	if self.marry_time <= 0 then
		self.marry_time = Status.NowTime + 1
	end

	if self.marry_time > 0 and now_time >= self.marry_time then
		if not self:IsMove() and not self.is_first then
			self.is_first = true
			if self.vo.distance > 0.1 then
				self:DoMove(math.floor(self.vo.pos_x + math.cos(self.vo.dir) * self.vo.distance), math.floor(self.vo.pos_y + math.sin(self.vo.dir) * self.vo.distance))
			end
		end
		local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
		if hunyan_info.role_prof and hunyan_info.lover_role_prof and not self.vo.name then
			if self.vo.marry_seq == CruiseType.XinLang then
				if (hunyan_info.role_prof % 10) < 3 then					--职业1，2性别为男
					self.vo.name = hunyan_info.role_name
				elseif (hunyan_info.lover_role_prof % 10) < 3 then
					self.vo.name = hunyan_info.lover_role_name
				end
			elseif self.vo.marry_seq == CruiseType.HuaJiao then
				if (hunyan_info.role_prof % 10) > 2 then					--职业1，2性别为男
					self.vo.name = hunyan_info.role_name
				elseif (hunyan_info.lover_role_prof % 10) > 2 then
					self.vo.name = hunyan_info.lover_role_name
				end
			end
			if self.vo.name then
				self:CreateFollowUi()
				self.follow_ui:SetHpVisiable(false)
			end
		end
		if self.follow_ui ~= nil then
			local draw_obj = self.draw_obj:GetRoot().transform
			self.follow_ui:SetName(self.vo.name or "", self)
			self.follow_ui:SetFollowTarget(self.draw_obj:GetAttachPoint(AttachPoint.UI) or draw_obj, self.draw_obj:GetName())
			if self.vo.marry_seq == CruiseType.HuaJiao then
				self.follow_ui:SetLocalUI(0, 20, 0)
			end
		end
		self.marry_time = 0
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING) or {}
		if activity_info.status and activity_info.status ~= HUNYAN_STATUS.XUNYOU then
			Scene.Instance:DeleteObj(self.vo.obj_id, 0)
			GlobalEventSystem:Fire(SceneEventType.OBJ_ENTER_LEVEL_ROLE)
		end
	end
end