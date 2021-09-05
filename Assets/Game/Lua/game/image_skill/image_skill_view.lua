require("game/image_skill/image_skill_content_view")
ImageSkillView = ImageSkillView or BaseClass(BaseView)
function ImageSkillView:__init()
	self.ui_config = {
		{"uis/views/imageskillview_prefab", "ImageSkillView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ImageSkillView:__delete()

end

function ImageSkillView:LoadCallBack()

	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.image_skill_content_view = ImageSkillContentView.New(self.node_list["image_skill_content_view"])

end

function ImageSkillView:ReleaseCallBack()
	if self.image_skill_content_view then
		self.image_skill_content_view:DeleteMe()
	end
	self.image_skill_content_view = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ImageSkillView:OpenCallBack()
	-- self.image_skill_content_view:SetModelState()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local open_day = open_day_cfg and open_day_cfg.baibeifanli_price_2_openday or 4
	local end_day = open_day_cfg and open_day_cfg.baibeifanli_end_time_2 or 7
	if cur_day < end_day and cur_day >= open_day then
		UnityEngine.PlayerPrefs.SetInt("image_skill_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.ImageSkill)
	end
	self:Flush()
end

function ImageSkillView:OnCloseClick()
	self:Close()
end

function ImageSkillView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function ImageSkillView:FlushNextTime()
	local time = ImageSkillData.Instance:GetImageSkillTime()
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local left_time = time - TimeCtrl.Instance:GetServerTime()
	local time_str = ""
	local timer = TimeUtil.Format2TableDHMS(left_time)
	if timer.day > 0 then
		time_str = string.format(Language.Activity.ActivityTime6, timer.day, timer.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime5, timer.hour, timer.min, timer.s)
	end
	self.node_list["Time"].text.text = time_str
end