FollowHpBar = FollowHpBar or BaseClass(BaseRender)

function FollowHpBar:__init()
	self.is_root_created = false
end

function FollowHpBar:__delete()

end

-- 在真正需要用实体时再创建
function FollowHpBar:CreateRootNode(prefab_name, obj_type, follow_parent, callback)
	if self.is_root_created then
		return
	end

	self.is_root_created = true
	self.obj_type = obj_type
	local async_loader = AllocAsyncLoader(self, "root_loader")
	async_loader:SetIsUseObjPool(true)
	async_loader:SetIsInQueueLoad(true)
	async_loader:Load("uis/views/miscpreload_prefab", prefab_name, function (gameobj)
		if IsNil(gameobj) then
			return
		end
		self:SetInstance(gameobj)
		self:SetInstanceParent(follow_parent)

		self:UpdateLocalPosition()
		self:UpdateHpPercent()
		self:UpdateActive()
		self.is_active = true

		if nil ~= callback then
			callback()
		end
	end)
end

function FollowHpBar:SetHpPercent(hp_percent)
	if nil ~= self.hp_percent and self.hp_percent == hp_percent then
		return
	end

	self.hp_percent = hp_percent
	self:UpdateHpPercent()
end

function FollowHpBar:UpdateHpPercent()
	if nil == self.hp_percent or nil == self.root_node then
		return
	end

	self.node_list["HpTop"].slider.value = self.hp_percent
	if nil == self.is_bottom_tween_move then
		self.node_list["HpBottom"].slider.value = self.hp_percent
		self.is_bottom_tween_move = true
	else
		self.node_list["HpBottom"].slider:DOValue(self.hp_percent, 0.5, false)
	end
end

function FollowHpBar:SetLocalPosition(x, y, z)
	if nil ~= self.local_pos and self.local_pos.x == self.x and self.local_pos.y == y and self.local_pos.z == z then
		return
	end

	self.local_pos = {x = x, y = y, z = z}
	self:UpdateLocalPosition()
end

function FollowHpBar:UpdateLocalPosition()
	if nil == self.local_pos or nil == self.root_node then
		return
	end

	self.root_node:SetLocalPosition(self.local_pos.x, self.local_pos.y, self.local_pos.z)
end

function FollowHpBar:SetHpIsActive(is_active)
	self.is_active = is_active
	self:UpdateActive()
end

function FollowHpBar:GetIsActive()
	return self.is_active
end

function FollowHpBar:UpdateActive()
	if nil == self.is_active or nil == self.root_node then
		return
	end

	self.root_node:SetActive(self.is_active)
end