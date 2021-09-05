require("game/send_gift/send_gift_zengsong_view")
require("game/send_gift/send_gift_record_view")

SendGiftView = SendGiftView or BaseClass(BaseView)
function SendGiftView:__init()
    self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/sendgiftview_prefab", "SendGiftZengSongView", {TabIndex.send_gift_zengsong}},
		{"uis/views/sendgiftview_prefab", "SendGiftRecordView", {TabIndex.send_gift_record}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
    self.play_audio = true
    self.is_async_load = false
end

function SendGiftView:__delete()
end

function SendGiftView:ReleaseCallBack()
	if self.send_gift_record_view then
		self.send_gift_record_view:DeleteMe()
		self.send_gift_record_view = nil
	end
	if self.send_gift_zengsong_view then
		self.send_gift_zengsong_view:DeleteMe()
		self.send_gift_zengsong_view = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function SendGiftView:LoadCallBack()

	local tab_cfg = {
		{name = Language.SendGiftView.TabbarName[1], tab_index = TabIndex.send_gift_zengsong}, 
		{name = Language.SendGiftView.TabbarName[2], tab_index = TabIndex.send_gift_record}, 
	}

	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["TitleText"].text.text = Language.SendGiftView.Title

end


function SendGiftView:HandleClose()
	self:Close()
end


function SendGiftView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if index_nodes then
		if index == TabIndex.send_gift_zengsong then
			self.send_gift_zengsong_view = SendGiftZengSongView.New(index_nodes["SendGiftZengSongView"])
		elseif index == TabIndex.send_gift_record then
			self.send_gift_record_view = SendGiftRecordView.New(index_nodes["SendGiftRecordView"])
		end
	end


	if index == TabIndex.send_gift_zengsong then
		if self.send_gift_zengsong_view then
			self.send_gift_zengsong_view:ShowIndexCallBack()
		end		
	elseif index == TabIndex.send_gift_record then
		if self.send_gift_record_view then
			self.send_gift_record_view:ShowIndexCallBack()
		end
	else
		--默认选中标签
		self:ChangeToIndex(TabIndex.send_gift_zengsong)
	end
end

function SendGiftView:GetSendGiftZengSongView()
	return self.send_gift_zengsong_view
end

function SendGiftView:CloseCallBack()
	if self.send_gift_zengsong_view then
		self.send_gift_zengsong_view:CloseCallBack()
	end

	if self.send_gift_record_view then
		self.send_gift_record_view:CloseCallBack()
	end
end

function SendGiftView:OpenCallBack()
	
end


function SendGiftView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "zengsong" then
			if self.send_gift_zengsong_view then
				
			end			
		elseif k == "record" then
			if self.send_gift_record_view then
				self.send_gift_record_view:Flush()
			end
		end
	end
end
