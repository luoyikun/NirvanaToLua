require("game/scene/follow_ui/follow_namebar")
require("game/scene/follow_ui/follow_bubble")
require("game/scene/follow_ui/follow_hpbar")

local TypeUIText = typeof(UnityEngine.UI.Text)
local TypeImage = typeof(UnityEngine.UI.Image)
local TypeGameObjectAttach = typeof(Game.GameObjectAttach)

FollowUi = FollowUi or BaseClass(BaseRender)

function FollowUi:__init()
	self.obj_type = nil

	self.is_shield_all_name = false

	self.namebar = FollowNameBar.New()
	self.hpbar = FollowHpBar.New()
	self.bubble = FollowBubble.New()

	self.is_root_created = false
	self.follow_name_prefab_name = "SceneObjName"
	self.follow_hp_prefab_name = "MonsterHP"
end

function FollowUi:__delete()
	self.namebar:DeleteMe()
	self.hpbar:DeleteMe()
	self.bubble:DeleteMe()

	if nil ~= self.root_node then
		self:ResumeDefaultFollowPos()
		
		self.root_node.uifollow_target.Canvas = nil
		self.root_node.uifollow_target.Target = nil
		self.root_node.uifollow_distance.TargetTransform = nil
	end
end

function FollowUi:CreateRootObj(obj_type)
	if self.is_root_created then
		return
	end

	self.is_root_created = true
	self.obj_type = obj_type

	local async_loader = AllocAsyncLoader(self, "root_loader")
	async_loader:SetIsUseObjPool(true)
	async_loader:SetIsInQueueLoad(true)
	async_loader:Load("uis/views/miscpreload_prefab", "FollowUi", function (gameobj)
		if IsNil(gameobj) then
			return
		end

		self:SetInstance(gameobj)
		self:SetInstanceParent(FightText.Instance.canvas.transform, false)

		self.namebar:CreateRootNode(self.follow_name_prefab_name, self.obj_type, self.node_list["Follow"].gameObject)
		self.bubble:SetFollowParent(self.obj_type, gameobj)

		self:UpdateFollowTarget()
		self:UpdateRootNodeVisible()
		self:UpdateRootLocalScale()
		self:UpdateFollowPos()
		self:UpdateTemporaryEffectObj()

		self:UpdateTitle()
		self:UpdateSetTitle()

		self:OnRootCreateCompleteCallback(gameobj)
	end)
end

function FollowUi:OnRootCreateCompleteCallback(gameobj)
	-- override
end

function FollowUi:SetFollowTarget(attach_point, follow_target_name)
	self.follow_target_attach_point = attach_point
	self.follow_target_name = follow_target_name
	self:UpdateFollowTarget()
end

function FollowUi:UpdateFollowTarget()
	if nil ~= self.follow_target_attach_point and nil ~= self.root_node then
		local follow_target_com = self.root_node:GetComponent(typeof(UIFollowTarget))
		follow_target_com.Canvas = FightText.Instance:GetCanvas()
		follow_target_com.Target = self.follow_target_attach_point

		local follow_distance_com = self.root_node:GetComponent(typeof(UIFollowDistance))
		follow_distance_com.TargetTransform = self.follow_target_attach_point

		self.root_node.gameObject.name = string.format("follow_ui(%s)", self.follow_target_name or "")
	end
end

function FollowUi:IsShow()
	return self.is_root_visible
end

function FollowUi:Show()
	if self.is_root_visible then
		return
	end
	self.is_root_visible = true
	self:UpdateRootNodeVisible()
end

function FollowUi:Hide()
	if not self.is_root_visible then
		return
	end

	self.is_root_visible = false
	self:UpdateRootNodeVisible()
end

function FollowUi:UpdateRootNodeVisible()
	if nil ~= self.is_root_visible and nil ~= self.root_node then
		self.root_node:SetActive(self.is_root_visible)
	end
end

function FollowUi:SetRootLocalScale(root_local_scale)
	self.root_local_scale = root_local_scale
	self:UpdateRootLocalScale()
end

function FollowUi:UpdateRootLocalScale()
	if nil ~= self.root_local_scale and nil ~= self.root_node then
		self.root_node.transform:SetLocalScale(self.root_local_scale, self.root_local_scale, self.root_local_scale)
	end
end

function FollowUi:SetLocalUI(x, y)
	self.follow_pos = {x = x, y = y}
	self:UpdateFollowPos()
end

function FollowUi:UpdateFollowPos()
	if nil ~= self.follow_pos and nil ~= self.root_node then
		if nil == self.default_follow_pos then
			self.default_follow_pos = self.node_list["Follow"].transform.localPosition
		end
		self.node_list["Follow"]:SetLocalPosition(self.follow_pos.x, self.follow_pos.y, 0)
	end
end

function FollowUi:ResumeDefaultFollowPos()
	if nil ~= self.default_follow_pos and nil ~= self.node_list["Follow"] then
		self.node_list["Follow"].transform.localPosition = self.default_follow_pos
	end
end

function FollowUi:SetTemporaryEffectObj(bundle, asset, pos_x, pos_y)
	if nil ~= self.temporary_effect_obj_info and self.temporary_effect_obj_info.bundle == bundle and self.temporary_effect_obj_info.asset == asset then
		return
	end

	self.temporary_effect_obj_info = {bundle = bundle, asset = asset, pos_x = pos_x, pos_y = pos_y}
	self:UpdateTemporaryEffectObj()
end

function FollowUi:RemoveTemporaryEffectObj()
	if nil ~= self.temporary_effect_obj_loader then
		self.temporary_effect_obj_loader:DeleteMe()
		self.temporary_effect_obj_loader = nil
	end
	self.temporary_effect_obj_info = nil
end

function FollowUi:UpdateTemporaryEffectObj()
	if nil == self.temporary_effect_obj_info or nil == self.root_node then
		return
	end

	self.temporary_effect_obj_loader = self.temporary_effect_obj_loader or AllocAsyncLoader(self, "temporary_effect_obj")
	self.temporary_effect_obj_loader:SetIsUseObjPool(true)
	self.temporary_effect_obj_loader:SetIsInQueueLoad(true)

	self.temporary_effect_obj_loader:Load(self.temporary_effect_obj_info.bundle, self.temporary_effect_obj_info.asset, function (gameobj)
		if not IsNil(gameobj) then
			gameobj.transform:SetParent(self.node_list["Follow"].transform, false)
			gameobj.transform:SetLocalPosition(self.temporary_effect_obj_info.pos_x or 0, self.temporary_effect_obj_info.pos_y or 80, 0)
		end
	end)
end

function FollowUi:SetNameIsActive(active)
	self.namebar:SetIsActive(active)
end

function FollowUi:SetName(name, secne_obj)
	self.namebar:SetSceneObjName(name)
end

function FollowUi:SetSpecialImage(is_show, bundle, asset)
	self.namebar:SetSpecialImage(is_show, bundle, asset)
	if is_show ~= self.special_title_img then
		self.special_title_img = is_show
		self:UpdateSetTitle()
	end
end

function FollowUi:SetGuildName(guild_name)
	self.namebar:SetGuildName(guild_name or "")
end

function FollowUi:SetLoverName(lover_name)
	self.namebar:SetLoverName(lover_name or "")
end

function FollowUi:SetNum(num)
	self.namebar:SetNumStr(num or "")
end

function FollowUi:SetMonsterNum(num)
	self.namebar:SetNumStr(num or "")
end

function FollowUi:SetRoleScore(score)
	self.namebar:SetScoreStr(score or "")
end

function FollowUi:SetScoreNum(score_num)
	self.namebar:SetScoreStr(score_num or "")
end

function FollowUi:SetTextPosY(y)
	self.namebar:SetSceneObjNamePos(0, y)
end

-- 外部设置名字的Position
function FollowUi:SetNameTextPosition()
	if self.hpbar:GetIsActive() then
		self.namebar:SetAnchoredPosition(0, 70)
	else
		self.namebar:SetAnchoredPosition(0, 45)
	end
end

function FollowUi:ShowFishImage(enable, bundle, asset)
	self.namebar:SetAttachEffect(enable, bundle, asset)
end

function FollowUi:SetIsShowMonsterImage(is_show, bundle, asset)
	self:SetSpecialImage(is_show, bundle, asset)
end

function FollowUi:SetSpecialPosition(x, y)
	local pos_x = x or 0
	local pos_y = y or 0
	self.namebar:SetSpecialImagePosXY(pos_x, pos_y)
end

function FollowUi:SetSpecialScale(scale)
	self.namebar:SetSpecialImageScale(scale or 1)
end

function FollowUi:SetRoleScorePosition(score_x)
	self.namebar:SetScorePosX(score_x or 0)
end

function FollowUi:ChangeBubble(text, time)
	self.bubble:ChangeBubble(text, time)
end

function FollowUi:HideBubble()
	self.bubble:HideBubble()
end

function FollowUi:ShowBubble()
	self.bubble:ShowBubble()
end

function FollowUi:SetHpPercent(hp_percent)
	self.hpbar:SetHpPercent(hp_percent)
end

function FollowUi:SetHpVisiable(value)
	self.hpbar:SetHpIsActive(value)
end

function FollowUi:SetHpBarLocalPosition(x, y, z)
	self.hpbar:SetLocalPosition(x, y, z)
end

-- ????
function FollowUi:ShowFollowUIUpImage(obj_id, is_show, bundle, asset, vector)
	self.namebar:ShowFollowUIUpImage(obj_id, is_show, bundle, asset, vector)
end

function FollowUi:ChangeTitle(bundle, asset, pos_x, pos_y)
	self.title_info = {bundle = bundle, asset = asset, pos_x = pos_x, pos_y = pos_y}
	self:UpdateTitle()
end

function FollowUi:UpdateTitle()
	if nil == self.title_info or nil == self.root_node then
		return
	end

	if nil == self.title_info.bundle or nil == self.title_info.asset then
		if nil ~= self.title_async_loader then
			self.title_async_loader:DeleteMe()
			self.title_async_loader = nil
		end
		return
	end

	self.title_async_loader = self.title_async_loader or AllocAsyncLoader(self, "title_loader")
	self.title_async_loader:SetIsUseObjPool(true)
	self.title_async_loader:SetIsInQueueLoad(true)

	self.title_async_loader:Load(self.title_info.bundle, self.title_info.asset, function (gameobj)
		if IsNil(gameobj) then
			return
		end
		
		gameobj.transform:SetParent(self.root_node.transform, false)
		gameobj.transform:SetLocalPosition(self.title_info.pos_x or 0, self.title_info.pos_y or 80, 0)
	end)
end

-- set title的代码太乱，不好重构
function FollowUi:SetTitle(index, title_id)
	if index > 1 then
		return
	end

	self.title_info = {index = index, title_id = title_id}
	self:UpdateSetTitle()
end

function FollowUi:UpdateSetTitle()
	-- override
end
