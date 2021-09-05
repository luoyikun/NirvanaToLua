require("game/chat/big_face_view")
require("game/chat/gold_text_view")
-- require("game/chat/special_view")
require("game/chat/bubble_view")
require("game/chat/head_frame/head_frame_content")

CoolChatView = CoolChatView or BaseClass(BaseView)

function CoolChatView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/chatview_prefab", "BigFaceContentView", {TabIndex.big_face}},
		{"uis/views/chatview_prefab", "GoldContentView", {TabIndex.gold_text}},
		{"uis/views/chatview_prefab", "BubbleContentView", {TabIndex.bubble}},
		{"uis/views/chatview_prefab", "HeadFrameContent", {TabIndex.head}},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.full_screen = false
	self.play_audio = true
	self.def_index = TabIndex.big_face
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function CoolChatView:__delete()

end

function CoolChatView:ReleaseCallBack()
	if self.bigface_view then
		self.bigface_view:DeleteMe()
		self.bigface_view = nil
	end

	if self.gold_text_view then
		self.gold_text_view:DeleteMe()
		self.gold_text_view = nil
	end

	if self.bubble_view then
		self.bubble_view:DeleteMe()
		self.bubble_view = nil
	end

	if self.head_frame_view then
		self.head_frame_view:DeleteMe()
		self.head_frame_view = nil
	end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function CoolChatView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Chat.CoolChatTabName.BigFace , tab_index = TabIndex.big_face , remind_id = RemindName.CoolChat_BigFace},
		{name = Language.Chat.CoolChatTabName.GoldText , tab_index = TabIndex.gold_text , remind_id = RemindName.CoolChat_GodText},
		{name = Language.Chat.CoolChatTabName.Bubble , tab_index = TabIndex.bubble , remind_id = RemindName.CoolChat_Bubble},
		{name = Language.Chat.CoolChatTabName.Head , tab_index = TabIndex.head , remind_id = RemindName.CoolChat_Head},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TitleText"].text.text = Language.Chat.CoolChatViewName
	self.node_list["TitleText"].text.lineSpacing = 1
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self:Flush()
end

function CoolChatView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if index_nodes then
		if index == TabIndex.big_face then
			self.bigface_view = BigFaceView.New(index_nodes["BigFaceContentView"])
			self.show_index = TabIndex.big_face
			self.bigface_view:OpenCallBack()
			self.bigface_view:FlushBigFaceView()
		elseif index == TabIndex.gold_text then
			self.gold_text_view = GoldTextView.New(index_nodes["GoldContentView"])
			self.show_index = TabIndex.gold_text
			self.gold_text_view:FlushGoldTextView()
		elseif index == TabIndex.bubble then
			self.bubble_view = BubbleView.New(index_nodes["BubbleContentView"])
			self.show_index = TabIndex.bubble
			self.bubble_view:FlushBubbleView()
		elseif index == TabIndex.head then
			self.head_frame_view = HeadFrameContent.New(index_nodes["HeadFrameContent"])
			self.show_index = TabIndex.head
			self.head_frame_view:OpenCallBack()
		end
	end
	if index == TabIndex.big_face then
		self.bigface_view:FlushBigFaceView()
	elseif index == TabIndex.gold_text then  
		self.gold_text_view:FlushGoldTextView()
	elseif index == TabIndex.bubble then
		self.bubble_view:FlushBubbleView()
	elseif index == TabIndex.head then
		self.head_frame_view:OpenCallBack()
	end
	self:ChangeBubbleRed()
end

function CoolChatView:OpenCallBack()
	-- CoolChatData.Instance:SetIsOpen()			-- 红点原因先屏蔽了，不知道为什么要用调用
	self:Flush()
	if self.show_index == TabIndex.big_face and self.bigface_view then
		self.bigface_view:OpenCallBack()
		self.bigface_view:FlushBigFaceView()
	elseif self.show_index == TabIndex.gold_text and self.gold_text_view then
		self.gold_text_view:FlushGoldTextView()
	elseif self.show_index == TabIndex.bubble and self.bubble_view then
		self.bubble_view:FlushBubbleView()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_INFO, 0, 0, 0)
	elseif self.show_index == TabIndex.head and self.head_frame_view then
		self.head_frame_view:OpenCallBack()
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_FRAME_INFO, 0, 0, 0)
	end
end

function CoolChatView:ChangeBubbleRed()
	RemindManager.Instance:Fire(RemindName.CoolChat_BigFace)
	RemindManager.Instance:Fire(RemindName.CoolChat_GodText)
	RemindManager.Instance:Fire(RemindName.CoolChat_Bubble)
	RemindManager.Instance:Fire(RemindName.CoolChat_Head)
	RemindManager.Instance:Fire(RemindName.CoolChat)
	RemindManager.Instance:Fire(RemindName.GuildChatRed)
end

function CoolChatView:CloseWindow()
	self:Close()
	if ViewManager.Instance:IsOpen(ViewName.Chat) or ViewManager.Instance:IsOpen(ViewName.PackageView) then
		return
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function CoolChatView:OnFlush(param)
	for k, v in pairs(param) do
		if k == "big_face" then
			if self.bigface_view then
				self.bigface_view:FlushBigFaceView()
			end
		elseif k == "gold_text" then
			if self.gold_text_view then
				self.gold_text_view:FlushGoldTextView()
			end
		elseif k == "bubble" then
			if self.bubble_view then
				self.bubble_view:FlushBubbleView(v)
			end
		elseif k == "head_frame" then
			if self.head_frame_view then
				self.head_frame_view:Flush(v)
			end
		elseif v.item_id and self.head_frame_view then
			self.head_frame_view:SetSelectIndex(v)
		elseif v.item_id and self.bubble_view then
			self.bubble_view:FlushBubbleView(v)
		end
	end
	self:ChangeBubbleRed()
end