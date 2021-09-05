TipsEventNoticeManager = TipsEventNoticeManager or BaseClass()

function TipsEventNoticeManager:__init()
	if TipsEventNoticeManager.Instance ~= nil then
		error("[TipsEventNoticeManager] attempt to create singleton twice!")
		return
	end
	TipsEventNoticeManager.Instance = self

	self.common_notice_tips = TipsEventNoticeView.New()
end

function TipsEventNoticeManager:__delete()
	if self.common_notice_tips ~= nil then
		self.common_notice_tips:DeleteMe()
		self.common_notice_tips = nil
	end
end

function TipsEventNoticeManager:ShowNoticeTips(msg, types)
	if not self.common_notice_tips:IsOpen() then
		self.common_notice_tips:Open()
	end
	self.common_notice_tips:InsertMsg(msg, types)
end

function TipsEventNoticeManager:ClearCacheList()
	if self.common_notice_tips:IsOpen() then
		self.common_notice_tips:Close()
	end
end