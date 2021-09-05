TipSpeakerNoticeView = TipSpeakerNoticeView or BaseClass(BaseView)
local LeftTime = 5
function TipSpeakerNoticeView:__init()
	self.ui_config = {{"uis/views/tips/speakertips_prefab", "SpeakNoticeView"}}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.speaker_type = SPEAKER_TYPE.SPEAKER_TYPE_LOCAL
end

function TipSpeakerNoticeView:ReleaseCallBack()
	-- 清理变量和对象
	self.rich_text = nil
	self:StopTimeQuest()
end

function TipSpeakerNoticeView:LoadCallBack()
	-- 获取变量
	self.rich_text = self.node_list["RichText"]
end

function TipSpeakerNoticeView:SetNotice(str, speaker_type)
	self.str = str or ""
	self.speaker_type = speaker_type
end

function TipSpeakerNoticeView:StopTimeQuest()
	if self.close_time_quest then
		GlobalTimerQuest:CancelQuest(self.close_time_quest)
		self.close_time_quest = nil
	end
end

function TipSpeakerNoticeView:StartTimeQuest()
	self:StopTimeQuest()
	self.close_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self:Close()
	end, LeftTime)
end

function TipSpeakerNoticeView:OpenCallBack()
	self:StartTimeQuest()
	RichTextUtil.ParseRichText(self.rich_text.rich_text, self.str)
	self.node_list["Local"]:SetActive(self.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_LOCAL)
	self.node_list["Cross"]:SetActive(self.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_CROSS)
end

function TipSpeakerNoticeView:CloseCallBack()
	self:StopTimeQuest()
end