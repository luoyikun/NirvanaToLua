local M = {}

function M.ProjectileSingleEffectEvent(hit_effect, position, rotation, hit_effect_with_rotation, source_scale, layer)
	local game_object = hit_effect.gameObject
	local obj = ResPoolMgr:TryGetGameObjectInPrefab(game_object)
	if not obj then
		return
	end

	local effect = obj:GetComponent(typeof(EffectControl))
	if effect == nil then
		ResPoolMgr:Release(obj)
		return
	end

	if hit_effect_with_rotation then
		effect.transform:SetPositionAndRotation(position, rotation)
	else
		effect.transform.position = position
	end

	effect.transform.localScale = source_scale
	effect.gameObject:SetLayerRecursively(layer)
	
	effect:Reset()
	effect:WaitFinsh(function()
		ResPoolMgr:Release(obj)
	end)
	
	effect:Play()
end


local index = 0
function M.UIMouseClickEffectEvent(temp, effects, canvas, mouse_click_transform)
	if effects.Length > 0 then
		local obj = effects[index]
		index = index + 1
		index = index % effects.Length
		if nil ~= obj then
			local effect = ResPoolMgr:TryGetGameObjectInPrefab(obj)
			if IsNil(effect) then
				return
			end

			local rect = effect.transform
			rect:SetParent(mouse_click_transform, false)
			rect.localScale = Vector3.one

			local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform, UnityEngine.Input.mousePosition, canvas.worldCamera, Vector2(0, 0))
			rect.localPosition = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
			effect:GetComponent(typeof(UnityEngine.Animator)):WaitEvent("exit", function ()
				if nil ~= effect then
					ResPoolMgr:Release(effect)
				end
				effect = nil
			end)
		end
	end
end

EffectEventHandle = M

return M
