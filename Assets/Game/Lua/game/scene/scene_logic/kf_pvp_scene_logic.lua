
KfPVPSceneLogic = KfPVPSceneLogic or BaseClass(CrossServerSceneLogic)

function KfPVPSceneLogic:__init()
	self.strong_hold_list = {}
	self.show_value = 0
	self.show_index = 0
end

function KfPVPSceneLogic:__delete()

end

-- 进入场景
function KfPVPSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	self.strong_hold_cfg = KuafuPVPData.Instance:GetStrongHoldCfg()
	for k, v in ipairs(self.strong_hold_cfg)do
		local defense_vo = GameVoManager.Instance:CreateVo(DefenseVo)
		defense_vo.gather_id = v.hold
		defense_vo.pos_x = v.pos_x
		defense_vo.pos_y = v.pos_y
		local obj = Scene.Instance:CreateObj(defense_vo, SceneObjType.DefenseObj)
		self.strong_hold_list[#self.strong_hold_list + 1] = obj
	end

	MainUICtrl.Instance:SetViewState(false)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end
	MainUICtrl.Instance:ChangeFightStateEnable(false)
	KuafuPVPCtrl.Instance:InitFight()
	self:FlushHoldObjVisible()
end

function KfPVPSceneLogic:Out(old_scene_type, new_scene_type)
	MainUICtrl.Instance:ChangeFightStateEnable(true)

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetAllViewState(true)
	end
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	KuafuPVPCtrl.Instance:CloseFight()
	KuafuPVPCtrl.Instance:CloseVector()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	ViewManager.Instance:Close(ViewName.ReviveView)
	ViewManager.Instance:Open(ViewName.KuaFu3v3)

	self.hold_none = nil
end

function KfPVPSceneLogic:FlushHoldObjVisible()
	-- self.hold_none = true
	local zhanling_value = KuafuPVPData.Instance:GetSliderNum()
	local self_side = KuafuPVPData.Instance:GetRoleInfo().self_side

	if (self.show_value == zhanling_value or self.show_index == 3) and
		zhanling_value ~= 100 and zhanling_value ~= 0 and self.hold_none == nil then
		for k,v in ipairs(self.strong_hold_list) do
			if v.vo and k < 3 then
				local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
				follow_ui:Hide()
				follow_ui:SetName("")
				v.draw_obj:SetVisible(false)
			end
		end
		return 
	end

	if self.hold_none ~= nil and zhanling_value ~= 100 and zhanling_value ~= 0 then
		return
	end

	self.show_value = zhanling_value

	for k,v in ipairs(self.strong_hold_list) do
		if v.vo then
			local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
			follow_ui:Hide()
			follow_ui:SetName("")
			v.draw_obj:SetVisible(false)
			
			if zhanling_value ~= nil or self_side ~= nil then
				if self_side == TeamInfo.TeamNoOne then
					if zhanling_value >= 100 and k == 1 then
						v.draw_obj:SetVisible(true)
						self.hold_none = false
						self.show_index = k
					elseif zhanling_value <= 0 and k == 2 then
						v.draw_obj:SetVisible(true)
						self.hold_none = false
						self.show_index = k
					end
				else
					if zhanling_value >= 100 and k == 2 then
						v.draw_obj:SetVisible(true)
						self.hold_none = false
						self.show_index = k
					elseif zhanling_value <= 0 and k == 1 then
						v.draw_obj:SetVisible(true)
						self.hold_none = false
						self.show_index = k
					end
				end
				if self.hold_none == nil and k == 3 then
					v.draw_obj:SetVisible(true)
					self.show_index = k
				end
			end
		end
	end

end
function KfPVPSceneLogic:GetRoleNameBoardText(role_vo)
	local self_side = role_vo.special_param or 0
	local col_t = {[0] = COLOR3B.WHITE, COLOR3B.RED, COLOR3B.BLUE}
	local t = {}
	local index = 1
	local role_info = KuafuPVPData.Instance:GetRoleInfo()
	t[index] = {}
	t[index].color = col_t[self_side + 1] or COLOR3B.WHITE
	t[index].text = role_vo.name

	return t
end

-- 获取采集物特殊名字显示
function KfPVPSceneLogic:GetGatherSpecialText(gather_vo)
	local t = {}
	local gather_name, gather_color = KuafuPVPData.Instance:GetGatherNameByObjid(gather_vo.obj_id)
	if gather_name then
		t[1] = {}
		t[1].color = gather_color
		t[1].text = "【" .. gather_name .. "】"
		return t
	end
	return t
end

-- 获取采集物特殊形象
function KfPVPSceneLogic:GetGatherSpecialRes(gather_vo)
	return KuafuPVPData.Instance:GetGatherResByObjid(gather_vo.obj_id)
end

function KfPVPSceneLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		local role_side = obj:GetVo().special_param
		local main_role = Scene.Instance:GetMainRole()
		local my_side = KuafuPVPData.Instance:GetRoleInfo().self_side

		if main_role == nil or obj:GetVo().role_id == main_role.vo.role_id then
			return true, "uis/views/kuafu3v3/images_atlas", "kuafu_pvp_" .. 0
		end

		if my_side == role_side then
			return true, "uis/views/kuafu3v3/images_atlas", "kuafu_pvp_" .. 0
		else
			return true, "uis/views/kuafu3v3/images_atlas", "kuafu_pvp_" .. 1
		end
	end
end

function KfPVPSceneLogic:GetColorName(scene_obj)
	local name = scene_obj.vo.name

	local main_role = Scene.Instance:GetMainRole()
	if main_role == nil or scene_obj.vo.role_id == main_role.vo.role_id then
		return name
	end

	if not (scene_obj:GetType() == SceneObjType.Role) then
		return name
	end

	local my_side = KuafuPVPData.Instance:GetRoleInfo().self_side
	local role_side = scene_obj:GetVo().special_param
	return my_side ~= role_side and ToColorStr(name, TEXT_COLOR.RED) or ToColorStr(name, TEXT_COLOR.BLUE)
end

-- 角色是否是敌人
function KfPVPSceneLogic:IsRoleEnemy(target_obj, main_role)
	local my_side = KuafuPVPData.Instance:GetRoleInfo().self_side
	if my_side == target_obj:GetVo().special_param then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end

-- 是否是挂机打怪的敌人
function KfPVPSceneLogic:IsGuiJiMonsterEnemy(target_obj)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Role 
		or target_obj:IsRealDead() or not Scene.Instance:IsEnemy(target_obj) then
		return false
	end
	return true
end

-- 获取挂机打怪的敌人
function KfPVPSceneLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	local obj,dis = Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
	if obj then
		return obj,dis
	else
		return Scene.Instance:SelectObjHelper(Scene.Instance:GetMonsterList(), x, y, distance_limit, SelectType.Enemy)
	end
end

function KfPVPSceneLogic:OnClickHeadHandler(is_show)
	CrossServerSceneLogic.OnClickHeadHandler(self, is_show)
end

-- function KfPVPSceneLogic:GuaiJiMonsterUpdate(now_time, elapse_time)
-- 	self.guai_ji_next_move_time = Status.NowTime - 3

-- 	if self:RolePickUpFallItem() then
-- 		return true
-- 	end

-- 	local target_obj = MainUIData.Instance:GetTargetObj()
-- 	if target_obj == nil then
-- 		local main_role = Scene.Instance:GetMainRole()
-- 		local x, y = main_role:GetLogicPos()
-- 		local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
-- 		target_obj = Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
-- 		if target_obj ~= nil and self:IsRoleEnemy(target_obj, main_role) then
-- 			MainUICtrl.Instance:SetTargetObj(target_obj)
-- 		end
-- 	end
-- end