local MAX_SHOW_LENGTH = 2

TipsEventNoticeView = TipsEventNoticeView or BaseClass(BaseView)

function TipsEventNoticeView:__init()
	self.ui_config = {{"uis/views/tips/tipsevent_prefab", "TipsEventView"}}
	self.view_layer = UiLayer.PopTop

	self.msg_list = {}
	self.cur_obj_index = 0
end

function TipsEventNoticeView:__delete()
	
end

function TipsEventNoticeView:CloseCallBack()
	for i = 1, 2 do
		self.node_list["Tips" .. i]:SetActive(false)
	end
	self.msg_list = {}
	self.cur_obj_index = 0

	if nil ~= self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
	end
end

function TipsEventNoticeView:LoadCallBack()
	for i = 1, 2 do
		self.node_list["Tips" .. i]:SetActive(false)
	end
	self.msg_list = {}
	self.cur_obj_index = 0
end

function TipsEventNoticeView:InsertMsg(msg, types)
	local message = {content = msg, m_type = types}
	table.insert(self.msg_list, message)
	self:CheckShowText()
	self:CheckViewClose()
end

function TipsEventNoticeView:CheckShowText()
	if not self:IsLoaded() or #self.msg_list <= 0 or self.is_tweening then
		return
	end

	if self.cur_obj_index >= MAX_SHOW_LENGTH then
		self.cur_obj_index = 1
	else
		self.cur_obj_index = self.cur_obj_index + 1
	end

	local tips_obj = self.node_list["Tips" .. self.cur_obj_index]
	if nil == tips_obj then
		return
	end

	tips_obj:SetActive(true)
	tips_obj.canvas_group.alpha = 1

	local rich_rect_tran = tips_obj.rect
	rich_rect_tran.anchoredPosition = Vector2(-1000, -138)

	self.is_tweening = true

	local tween_move_x = rich_rect_tran:DOAnchorPosX(0, 0.3)
	tween_move_x:SetEase(DG.Tweening.Ease.InOutSine)

	local tween_move_y = rich_rect_tran:DOAnchorPosY(0, 0.3)
	tween_move_y:SetEase(DG.Tweening.Ease.InOutSine)
	tween_move_y:OnUpdate(function()
		tips_obj.canvas_group.alpha = tips_obj.canvas_group.alpha - UnityEngine.Time.deltaTime / 0.3
	end)
	tween_move_y:OnComplete(function ()
		tips_obj:SetActive(false)
		self.is_tweening = false
		table.remove(self.msg_list, 1)
		self:CheckShowText()
	end)

	local sequence = DG.Tweening.DOTween.Sequence()
	sequence:Append(tween_move_x)
	sequence:AppendInterval(1.8)
	sequence:Append(tween_move_y)
		
	RichTextUtil.ParseRichText(self.node_list["MsgText" .. self.cur_obj_index].rich_text, self.msg_list[1].content, nil, nil, nil, false)
end

function TipsEventNoticeView:CheckViewClose()
	if nil ~= self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
	end

	self.delay_close_timer = GlobalTimerQuest:AddDelayTimer(function ()
			self:Close()
		end, 10)
end
