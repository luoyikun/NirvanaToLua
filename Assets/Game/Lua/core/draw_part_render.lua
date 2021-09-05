DrawPartRender = DrawPartRender or BaseClass()
function DrawPartRender:__init()
	self.partObj = nil
end

function DrawPartRender:__delete()
	-- 回对象池要恢复
	if nil ~= self.actor_render then
		self.actor_render:SetIsLowMaterial(false, false)
		self.actor_render:SetIsCastShadow(false)
		self.actor_render:SetIsDisableAllAttachEffects(false)
	end

	self.actor_render = nil
end

function DrawPartRender:SetActorRender(actor_render)
	self.actor_render = actor_render
end

function DrawPartRender:GetActorRender()
	return self.actor_render
end

-- 是否使用低消耗材质球渲染(ignore_set为true的时候不管前面的参数是什么都执行)
function DrawPartRender:SetIsLowMaterial(is_low_material, ignore_set)
	if nil == self.actor_render then
		return
	end
	if nil == ignore_set then
		ignore_set = false
	end

	self.actor_render:SetIsLowMaterial(is_low_material, ignore_set)
end

function DrawPartRender:SetIsCastShadow(is_cast_shadow)
	if nil == self.actor_render then
		return
	end

	self.actor_render:SetIsCastShadow(is_cast_shadow)
end

-- 是否关掉AttachEffects
function DrawPartRender:SetIsDisableAllAttachEffects(is_disable_effect)
	if nil == self.actor_render then
		return
	end

	self.actor_render:SetIsDisableAllAttachEffects(is_disable_effect)
end

-- 设置材质球
function DrawPartRender:SetRenderMaterial(material)
	if nil == self.actor_render then
		return
	end

	self.actor_render:SetRenderMaterial(material)
end