UI = UI or {}

local CacheTbl = setmetatable({}, {__mode = "kv"})

-- 按钮置灰不可点
function UI:SetButtonEnabled(node, is_enable)
	UI:SetGraphicGrey(node, not is_enable)
	-- node.button.interactable = is_enable

	if node.button then
		node.button.interactable = is_enable
	elseif node.toggle then
		node.toggle.interactable = is_enable
	end
end

-- 图片置灰
function UI:SetGraphicGrey(node, is_grey)
	local graphic_list = CacheTbl[node]
	if not graphic_list then
		graphic_list = node.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Graphic), true)
		CacheTbl[node] = graphic_list
	end
	
	for i = 0, graphic_list.Length - 1 do
		local graphic = graphic_list[i]
		if graphic then
			self:SetMaterialGrey(graphic, is_grey)
		end
	end
end

local UiEffectLayer1 = UnityEngine.LayerMask.NameToLayer("UIEffect1")
local UiEffectLayer2 = UnityEngine.LayerMask.NameToLayer("UIEffect2")
local UiEffectLayer3 = UnityEngine.LayerMask.NameToLayer("UIEffect3")

function UI:SetMaterialGrey(graphic, is_grey)
	if graphic.gameObject.tag == "UIEffect" then
		return
	end

	if graphic.gameObject.layer == UiEffectLayer1 or graphic.gameObject.layer == UiEffectLayer2 or graphic.gameObject.layer == UiEffectLayer3 then
		return
	end 

	if is_grey then
		graphic.material = ResPoolMgr:TryGetMaterial("misc/material", "UI-NormalGrey")
	else
		graphic.material = nil
	end
end
