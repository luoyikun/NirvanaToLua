TipsZhanchangView = TipsZhanchangView or BaseClass(BaseView)

local MAX_SHOW_LENGTH = 4 	-- 最多显示数量
local SPACE_OFFSET = 43		-- 间隔
local MOVE_TIME = 0.5		-- 进来时间

function TipsZhanchangView:__init()
	self.ui_config = {{"uis/views/tips/tipzhanchang_prefab", "TipsZhanchang"}}

	self.msg_list = {}
	self.rich_text_obj_list = {}
	self.cur_rich_text_obj_index = 0
	self.prefab_is_load = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUI
end

function TipWaBaoView:__delete()
	
end

function TipsZhanchangView:ReleaseCallBack()
	for k,v in pairs(self.rich_text_obj_list) do
		ResMgr:Destroy(v.gameObject)
	end
	
	self.msg_list = {}
	self.rich_text_obj_list = {}
	self.cur_rich_text_obj_index = 0

	if nil ~= self.zhancang_close_timer then
		GlobalTimerQuest:CancelQuest(self.zhancang_close_timer)
	end
	self.zhancang_close_timer = nil
end

function TipsZhanchangView:CloseCallBack()
	self.msg_list = {}
	self.cur_rich_text_obj_index = 0
	for k,v in pairs(self.rich_text_obj_list) do
		v:SetActive(false)
	end

	if nil ~= self.zhancang_close_timer then
		GlobalTimerQuest:CancelQuest(self.zhancang_close_timer)
	end
	self.zhancang_close_timer = nil
end

function TipsZhanchangView:LoadCallBack()
	self.root_height = self.node_list["TextRoot"].rect.rect.height

	for i = 1, MAX_SHOW_LENGTH do
		local async_loader = AllocAsyncLoader(self, "TipZhanchangText_loader_" .. i)
		async_loader:Load("uis/views/tips/tipzhanchang_prefab", "ZhanChangRichTips", function(obj)
			if IsNil(obj) then
				return
			end

			obj.transform:SetParent(self.node_list["TextRoot"].transform, false)
			obj:SetActive(false)

			table.insert(self.rich_text_obj_list, U3DObject(obj, obj.transform, self))

			if #self.rich_text_obj_list >= MAX_SHOW_LENGTH then
				self.prefab_is_load = true
				self:CheckShowText()
			end
		end)
	end
end

function TipsZhanchangView:InsertMsg(msg)
	table.insert(self.msg_list, msg)
	self:CheckShowText()
	self:TimeCloseZhanchang()
end

function TipsZhanchangView:CheckShowText()
	if not self.prefab_is_load or #self.msg_list <= 0 or self.is_tweening then
		return
	end

	if self.cur_rich_text_obj_index >= MAX_SHOW_LENGTH then
		self.cur_rich_text_obj_index = 1
	else
		self.cur_rich_text_obj_index = self.cur_rich_text_obj_index + 1
	end
	local rich_text_obj = self.rich_text_obj_list[self.cur_rich_text_obj_index]
	if rich_text_obj then
		rich_text_obj:SetActive(true)
		rich_text_obj.canvas_group.alpha = 0

		local rich_rect_tran = rich_text_obj.rect
		rich_rect_tran:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, self.root_height, 24)

		self.is_tweening = true
		local tween = rich_rect_tran:DOAnchorPosY(rich_rect_tran.anchoredPosition.y  + SPACE_OFFSET, MOVE_TIME)
		tween:SetEase(DG.Tweening.Ease.InOutSine)
		tween:OnUpdate(function()
			rich_text_obj.canvas_group.alpha = rich_text_obj.canvas_group.alpha + UnityEngine.Time.deltaTime / MOVE_TIME
		end)
		tween:OnComplete(function ()
			self.is_tweening = false
			table.remove(self.msg_list, 1)
			self:CheckShowText()
		end)

		-- RichTextUtil.ParseRichText(rich_text_obj.rich_text, self.msg_list[1], nil, nil, nil, false)

		local node_list = U3DNodeList(rich_text_obj:GetComponent(typeof(UINameTable)), self)
		RichTextUtil.ParseRichText(node_list["RichZCText"].rich_text, self.msg_list[1], nil, nil, nil, false)

		local hide_index = self.cur_rich_text_obj_index + 1 > MAX_SHOW_LENGTH and 1 or self.cur_rich_text_obj_index + 1
		for k, v in pairs(self.rich_text_obj_list) do
			if self.cur_rich_text_obj_index ~= k and v.gameObject.activeInHierarchy then
				local rect_tran = v.rect
				local other_tween = rect_tran:DOAnchorPosY(rect_tran.anchoredPosition.y  + SPACE_OFFSET, MOVE_TIME - 0.1)
				other_tween:SetEase(DG.Tweening.Ease.InOutSine)

				if k == hide_index then
					v.canvas_group.alpha = 1
					other_tween:OnUpdate(function()
						v.canvas_group.alpha = v.canvas_group.alpha - UnityEngine.Time.deltaTime / (MOVE_TIME - 0.1)
					end)
				end
			end
		end
	end
end

function TipsZhanchangView:TimeCloseZhanchang()
	if nil ~= self.zhancang_close_timer then
		GlobalTimerQuest:CancelQuest(self.zhancang_close_timer)
		self.zhancang_close_timer = nil
	end
	if self.zhancang_close_timer == nil then
		self.zhancang_close_timer = GlobalTimerQuest:AddDelayTimer(function ()
			self:Close()
		end, 4)
	end
end