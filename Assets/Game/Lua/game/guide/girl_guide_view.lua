GirlGuideView = GirlGuideView or BaseClass(BaseView)

local GirlResId = 4028001

function GirlGuideView:__init()
	self.ui_config = {{"uis/views/guideview_prefab", "GirlGuideView"}}
	self.step_cfg = {}
	self.view_layer = UiLayer.Guide
end

function GirlGuideView:__delete()

end

function GirlGuideView:ReleaseCallBack()
	if self.girl_model then
		self.girl_model:DeleteMe()
		self.girl_model = nil
	end

    self:ReleaseAudioPlayer()

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end


end

function GirlGuideView:LoadCallBack()
	self.node_list["GirlGuideView"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))


end

function GirlGuideView:SetClickCallBack(callback)
	self.click_call_back = callback
end

function GirlGuideView:SetIsNeedCloseOnClick(value)
	self.is_need_close = value
end

function GirlGuideView:CloseWindow()
	if self.is_need_close then

		self.node_list["GirlGuide"].canvas_group.blocksRaycasts = false
		self:Close()
		self.step_cfg = {}
	end
	FunctionGuide.Instance:StartNextStep()
end

function GirlGuideView:OpenCallBack()
	self.node_list["GirlGuide"].canvas_group.blocksRaycasts = true
	local audio_id = self.step_cfg.offset_x
	if audio_id and audio_id ~= "" then
		local bundle, asset = ResPath.GetVoiceRes(audio_id)
        AudioManager.Play(bundle, asset, nil, nil, function(audio_player)
            if audio_player == nil then
                return
            end

            self.audio_player = audio_player

		 	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
                 if not self.audio_player.IsPlaying then
                     GlobalTimerQuest:CancelQuest(self.time_quest)
                     self.time_quest = nil
                     self:CloseWindow()
				end
			end, 0.1)
        end)
	end
end

function GirlGuideView:CloseCallBack()
    self:ReleaseAudioPlayer()

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GirlGuideView:ReleaseAudioPlayer()
    if self.audio_player then
        self.audio_player:Stop()
        self.audio_player = nil
    end
end

function GirlGuideView:OnFlush()
	self.node_list["Text"].text.text = self.step_cfg.arrow_tip
end

function GirlGuideView:SetArrowDes(des)
	self.des = des
end

function GirlGuideView:SetStepCfg(cfg)
	self.step_cfg = cfg
end
