FallItem = FallItem or BaseClass(SceneObj)

function FallItem:__init(vo)
	self.obj_type = SceneObjType.FallItem
	self.draw_obj:SetObjType(self.obj_type)

	self.is_drop_done = false
	self.is_picked = false
	self.picked_invalid_time = 0

	-- 是否延时创建
	self.is_delay_create = vo.is_create == 1
end

function FallItem:__delete()
	self:RemoveDelayTime()
	if nil ~= self.item_effect then
		self.item_effect:DeleteMe()
		self.item_effect = nil
	end
end

function FallItem:InitInfo()
	SceneObj.InitInfo(self)

	self.cfg , self.item_type = ItemData.Instance:GetItemConfig(self.vo.item_id)
	if nil ~= self.cfg then
		self.vo.name = self.cfg.name
	end
end

function FallItem:InitShow()
	-- 延迟创建
	if self.is_delay_create then
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.is_delay_create = false self:InitShow() end, 1)
		return
	end

	SceneObj.InitShow(self)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = Scene.Instance:GetSceneId()
	if (BossData.Instance:IsCrossBossScene(scene_id) or BossData.Instance:IsShenYuBossScene(scene_id)) and self.vo.owner_role_id ~= main_role_vo.role_id then	--相关场景只看到自己的归属掉落物
		self.draw_obj:GetRoot():SetActive(false)
	end

	local model_bundle, model_asset = ResPath.GetFallItemModel(5102002) -- 宝箱模型

	local effect_name = nil
	if self.vo.is_buff_falling == 1 then
		effect_name = BUFF_FALLING_APPEARAN_TYPE_EFF[self.vo.buff_appearan] or BUFF_FALLING_APPEARAN_TYPE_EFF[1]
		model_bundle, model_asset = nil, nil
		if Language.TowerDefend.FallItemName[self.vo.buff_appearan] then
			local follow_ui = self:GetFollowUi()
			follow_ui:Show()
			follow_ui:SetLocalUI(0, 80, 0)
			follow_ui:SetName(Language.TowerDefend.FallItemName[self.vo.buff_appearan], self)
		end
		self.is_drop_done = true
	else
		effect_name = "5102002_0".. (self.cfg and self.cfg.color or 1)
	end

	if nil == effect_name then return end

	local draw_obj_transform = self.draw_obj:GetRoot().transform
	self.item_effect = self.item_effect or AllocAsyncLoader(self, "item_effect_loader")
	local bundle_name, asset_name = ResPath.GetMiscEffect(effect_name)
	self.item_effect:SetParent(draw_obj_transform)
	self.item_effect:Load(bundle_name, asset_name)

	if nil == model_bundle or nil == model_asset then return end

	local callback = function (obj)
		if self.vo.create_interval > 1 then
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			part:SetTrigger("fall_imm")
		end
	
		local monster_x, monster_y = GameMapHelper.LogicToWorld(self.vo.obj_pos_x, self.vo.obj_pos_y)
		local fallitem_x, fallitem_y = GameMapHelper.LogicToWorld(self.logic_pos.x, self.logic_pos.y)
		local origin_y = draw_obj_transform.position.y
		draw_obj_transform.position = Vector3(monster_x, origin_y, monster_y)
		draw_obj_transform.localScale = Vector3(0.8, 0.8, 0.8)
		
		local tween_scale = draw_obj_transform:DOScale(Vector3.one, 0.4)
		local tween = draw_obj_transform:DOJump(Vector3(fallitem_x, origin_y, fallitem_y), 6, 1, 0.5)
		tween:Append(tween_scale)
		tween:SetEase(DG.Tweening.Ease.InQuart)
		tween:AppendInterval(0.6)
		tween:OnComplete(function ()
			self.is_drop_done = true
		end)
	end
	
	self:ChangeModel(SceneObjPart.Main, model_bundle, model_asset, callback)--self.cfg.drop_icon
end

function FallItem:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function FallItem:Update(now_time, elapse_time)
	if self.picked_invalid_time > 0 and now_time >= self.picked_invalid_time then
		self.picked_invalid_time = 0
		self.is_picked = false
	end
end

function FallItem:IsCoin()
	return self.vo.coin > 0
end

function FallItem:GetAutoPickupMaxDis()
	-- 如果在障碍区，则直接捡起
	if self:IsInBlock() or EquipData.Instance:GetImpGuardActiveInfo() then
		return 0
	elseif self.vo and self.vo.buff_appearan > 0 then
		return 4
	else
		return Scene.Instance:GetSceneLogic():GetPickItemMaxDic(self.vo.item_id)
	end
end

function FallItem:PlayPick()
	-- 播放拾取特效
	local position = self:GetRoot().transform.position

	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "drop_weapon")
	if nil ~= obj then
		obj:GetOrAddComponent(typeof(TrailRendererController))
		obj.transform.position = position

		local follow = obj:GetComponent(typeof(FollowTarget))
		local main_role = Scene.Instance:GetMainRole()
		if follow ~= nil and
			main_role ~= nil and
			main_role.draw_obj ~= nil and
			not main_role:IsDeleted() and
			main_role:GetRoot().gameObject ~= nil then
			local hurt_point = main_role.draw_obj:GetAttachPoint(AttachPoint.Hurt)
			follow:Follow(hurt_point, function()
				ResMgr:Destroy(obj)
			end)
		else
			ResMgr:Destroy(obj)
		end
		if self.vo.is_buff_falling == 1 then
			GlobalTimerQuest:AddDelayTimer(function() self:CheckShowEff() end, 0.5)
			if Language.TowerDefend.FallItemDec[self.vo.buff_appearan] then
				TipsCtrl.Instance:ShowSystemMsg(Language.TowerDefend.FallItemDec[self.vo.buff_appearan])
			end
		end
	end
end

function FallItem:IsDropDone()
	return self.is_drop_done
end

function FallItem:RecordIsPicked()
	self.is_picked = true
	self.picked_invalid_time = Status.NowTime + 1.5
end

function FallItem:IsPicked()
	return self.is_picked
end

function FallItem:CheckShowEff()
	if self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_1 then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
		local life_tower_monster_id = other_cfg.life_tower_monster_id
		local monster_list = Scene.Instance:GetMonsterList()
		for k,v in pairs(monster_list) do
			if v:GetMonsterId() == life_tower_monster_id then
				local res = "Buff_nvshenzhufu"
				local pos = v.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
				if pos then
					local bundle_name, prefab_name = ResPath.GetBuffEffect(res)
					EffectManager.Instance:PlayControlEffect(v, bundle_name, prefab_name, pos.transform.position)
				end
			end
		end
	elseif self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_2 then
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			main_role:AddEffect("BUFF_nvshenzhiqiang", 3)
		end
	elseif self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_3 then
		local pos = Scene.Instance:GetMainRole().draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
		if pos then
			local bundle_name, prefab_name = ResPath.GetBuffEffect("BUFF_nvshenzhinu")
			EffectManager.Instance:PlayControlEffect(self, bundle_name, prefab_name, pos.transform.position)
		end
	end
end