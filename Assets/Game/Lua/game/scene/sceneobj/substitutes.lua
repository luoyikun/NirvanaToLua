
Substitutes = Substitutes or BaseClass(FollowObj)

-- 替身（buff表现）
function Substitutes:__init(substitutes_vo)
	self.obj_type = SceneObjType.Substitutes
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(substitutes_vo.used_sprite_id)
	self.vo = substitutes_vo

	self.follow_offset = -1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 5
end

function Substitutes:__delete()
	self.obj_type = nil
	self.load_call_back = nil
end

function Substitutes:InitShow()
	FollowObj.InitShow(self)

	self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(3002001))
end

function Substitutes:SetLoadCallBack(call_back)
	self.load_call_back = call_back
end

function Substitutes:LoadOver()
	if self.load_call_back then
		self.load_call_back()
	end
end

function Substitutes:IsCharacter()
	return false
end

function Substitutes:GetOwerRoleId()
	return self.vo.owner_role_id
end

function Substitutes:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 6
end

function Substitutes:IsSubstitutes()
	return true
end

function Substitutes:SetVisible(is_visible)
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
end