UITween = UITween or {}

function UITween.ShowFadeUp(self)
	local MOVE_TIME = 0.3
	local MOVE_DISTANCE = 25
	local canvas_group = self.root_parent:GetComponent(typeof(UnityEngine.CanvasGroup))
	canvas_group.alpha = 0
	self.root_parent.transform.anchoredPosition = Vector3(0, -MOVE_DISTANCE, 0)

	local tween = self.root_parent.transform:DOAnchorPosY(0, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.OutCubic)

	local on_tween_updata = function ()
		canvas_group.alpha = canvas_group.alpha + UnityEngine.Time.deltaTime / MOVE_TIME
	end

	local on_tween_complete = function ()
		canvas_group.alpha = 1
		self.root_parent.transform.anchoredPosition = Vector3(0, 0, 0)
	end

	return tween, on_tween_updata, on_tween_complete
end

function UITween.HideFadeUp(self)
	local MOVE_TIME = 0.3
	local MOVE_DISTANCE = 25
	local canvas_group = self.root_parent:GetComponent(typeof(UnityEngine.CanvasGroup))
	canvas_group.alpha = 1
	self.root_parent.transform.anchoredPosition = Vector3(0, 0, 0)

	local tween = self.root_parent.transform:DOAnchorPosY(MOVE_DISTANCE, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.Linear)

	local on_tween_updata = function ()
		canvas_group.alpha = canvas_group.alpha - UnityEngine.Time.deltaTime / MOVE_TIME
	end

	local on_tween_complete = function ()
		canvas_group.alpha = 0
		self.root_parent.transform.anchoredPosition = Vector3(0, MOVE_DISTANCE, 0)
	end

	return tween, on_tween_updata, on_tween_complete
end

local Tween_MoveTab = {}
function UITween.MoveShowPanel(gameObject, start_pos, tween_time, show_type)
	if Tween_MoveTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.anchoredPosition.x, gameObject.transform.anchoredPosition.y
	gameObject.transform.anchoredPosition = start_pos
	local tween = gameObject.transform:DOAnchorPos(Vector3(x, y, 0), TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.OutCubic)
	tween:OnComplete(function ()
		Tween_MoveTab[gameObject] = nil
	end)
	Tween_MoveTab[gameObject] = tween
end

local Sequence_MoveLoop = {}
local Sequence_childlist = {}
function UITween.MoveLoop(gameObj, start_pos, end_pos, tween_time, show_type)
	if Sequence_MoveLoop[gameObj] then 
		return
	end
	Sequence_childlist[gameObj] = {}
	local tween_update = function ()
		if not gameObj.gameObject.activeInHierarchy then 
			return
		end
		if Sequence_childlist[gameObj] then
			for k,v in pairs(Sequence_childlist[gameObj]) do
				if nil ~= v and not IsNil(v.gameObject) and v.gameObject.activeInHierarchy then 
					v.rect.anchoredPosition3D = gameObj.rect.anchoredPosition3D
				end
				if IsNil(v.gameObject) then 
					Sequence_childlist[gameObj][k] = nil
				end
			end
		end
	end
	local TWEEN_TIME = tween_time or 0.5
	gameObj.transform.anchoredPosition = start_pos
	Sequence_MoveLoop[gameObj] = DG.Tweening.DOTween.Sequence()
	local tween_up = gameObj.transform:DOAnchorPos(end_pos, TWEEN_TIME)		-- 到终点
	local tween_down = gameObj.transform:DOAnchorPos(start_pos, TWEEN_TIME)	-- 到起点

	tween_up:SetEase(show_type or DG.Tweening.Ease.InOutSine)
	tween_down:SetEase(show_type or DG.Tweening.Ease.InOutSine)
	Sequence_MoveLoop[gameObj]:OnUpdate(tween_update)
	Sequence_MoveLoop[gameObj]:Append(tween_up)
	Sequence_MoveLoop[gameObj]:Append(tween_down)
	Sequence_MoveLoop[gameObj]:OnComplete(function (tween_update)
		Sequence_MoveLoop[gameObj]:Restart()
	end)

end

function UITween.AddChildMoveLoop(child_obj , copy_obj)
	if nil ~= Sequence_childlist[copy_obj] then
		Sequence_childlist[copy_obj][child_obj] = child_obj
	end
end
function UITween.ReduceChildMoveLoop(child_obj , copy_obj)
	if nil ~= Sequence_childlist[copy_obj] then 
		Sequence_childlist[copy_obj][child_obj] = nil
	end
end
function UITween.KillMoveLoop(gameObject)
	if Sequence_MoveLoop[gameObject] then 
		Sequence_MoveLoop[gameObject]:Kill()
		Sequence_MoveLoop[gameObject] = nil
		Sequence_childlist[gameObject] = {}
	end
end

local Tween_ScaleTab = {}
function UITween.ScaleShowPanel(gameObject, scale, tween_time, show_type, callback)
	if Tween_ScaleTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.localScale.x, gameObject.transform.localScale.y
	gameObject.transform.localScale = scale or Vector3(0, 0, 0)
	local tween = gameObject.transform:DOScale(Vector3(x, y, 0), TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.InOutBack)
	tween:OnComplete(function ()
		Tween_ScaleTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_ScaleTab[gameObject] = tween
end

local Tween_SizeTab = {}
function UITween.SizeShowPanel(gameObject, size, tween_time, show_type, callback)
	if Tween_SizeTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.rect.sizeDelta.x, gameObject.rect.sizeDelta.y
	gameObject.rect.sizeDelta = size or Vector2(0, 0)
	local tween = gameObject.transform:DOSizeDelta(Vector2(x, y), TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.InOutBack)
	tween:OnComplete(function ()
		Tween_SizeTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_SizeTab[gameObject] = tween
end

local Tween_AlpahTab = {}
function UITween.AlpahShowPanel(gameObject, is_show, tween_time, show_type, callback)
	if Tween_AlpahTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local obj_transform = gameObject.transform:GetOrAddComponent(typeof(UnityEngine.CanvasGroup))
	obj_transform.alpha = is_show and 0 or 1
	local tween = is_show and obj_transform:DoAlpha(0, 1, TWEEN_TIME) or obj_transform:DoAlpha(1, 0, TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.OutCubic)
	tween:OnComplete(function ()
		obj_transform.alpha = 1
		Tween_AlpahTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_AlpahTab[gameObject] = tween
end

local Tween_MoveAlpahTab = {}
function UITween.MoveAlpahShowPanel(gameObject, start_pos, tween_time, show_type, callback)
	if Tween_MoveAlpahTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.anchoredPosition.x, gameObject.transform.anchoredPosition.y
	gameObject.transform.anchoredPosition = start_pos
	local canvas_group = gameObject.transform:GetOrAddComponent(typeof(UnityEngine.CanvasGroup))
	local tween_alpah = canvas_group:DoAlpha(0, 1, TWEEN_TIME)
	local tween_move = gameObject.transform:DOAnchorPos(Vector3(x, y, 0), TWEEN_TIME)
	local tween = DG.Tweening.DOTween.Sequence()
	tween:Append(tween_alpah)
	tween:Join(tween_move)
	tween:SetEase(show_type or DG.Tweening.Ease.OutCubic)
	tween:OnComplete(function ()
		Tween_MoveAlpahTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_MoveAlpahTab[gameObject] = tween
end

local Tween_MoveToTab = {}
function UITween.MoveToShowPanel(gameObject, start_pos, end_pos, tween_time, show_type, callback)
	if Tween_MoveToTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.anchoredPosition.x, gameObject.transform.anchoredPosition.y
	gameObject.transform.anchoredPosition = start_pos
	local tween = gameObject.transform:DOAnchorPos(end_pos, TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.OutCubic)
	tween:OnComplete(function ()
		Tween_MoveToTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_MoveToTab[gameObject] = tween
end

local Tween_MoveSceleTab = {}
function UITween.MoveScaleShowPanel(gameObject, start_pos, tween_time, scale, callback)
	if Tween_MoveSceleTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.anchoredPosition.x, gameObject.transform.anchoredPosition.y
	gameObject.transform.anchoredPosition = start_pos
	gameObject.transform.localScale = Vector3.zero
	local tween_scale = gameObject.transform:DOScale(scale or 1, TWEEN_TIME)
	local tween_move = gameObject.transform:DOAnchorPos(Vector3(x, y, 0), TWEEN_TIME)
	local tween = DG.Tweening.DOTween.Sequence()
	tween:Join(tween_move)
	tween:OnComplete(function ()
		Tween_MoveSceleTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_MoveSceleTab[gameObject] = tween
end

local Tween_MoveToSceleTab = {}
function UITween.MoveToScaleAndShowPanel(gameObject, start_pos, end_pos, scale, tween_time, show_type, callback)
	if Tween_MoveToSceleTab[gameObject] then
		return
	end

	local TWEEN_TIME = tween_time or 0.5
	local x, y = gameObject.transform.anchoredPosition.x, gameObject.transform.anchoredPosition.y
	gameObject.transform.anchoredPosition = start_pos
	local tween_scale = gameObject.transform:DOScale(scale or 1, TWEEN_TIME)
	local tween = gameObject.transform:DOAnchorPos(end_pos, TWEEN_TIME)
	tween:SetEase(show_type or DG.Tweening.Ease.OutCubic)
	tween:OnComplete(function ()
		Tween_MoveToSceleTab[gameObject] = nil
		if callback then
			callback()
		end
	end)
	Tween_MoveToSceleTab[gameObject] = tween
end