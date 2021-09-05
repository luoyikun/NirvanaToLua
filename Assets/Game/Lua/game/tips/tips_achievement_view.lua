TipsAchievementView = TipsAchievementView or BaseClass(BaseView)

function TipsAchievementView:__init()
	self.ui_config = {{"uis/views/tips/achievementtips_prefab", "AchievementTips"}}
	self.data = {}
	self.view_layer = UiLayer.Pop
end

function TipsAchievementView:ReleaseCallBack()
	self.animator = nil
end

function TipsAchievementView:LoadCallBack()
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnRecieveClick,self))
	self.animator:ListenEvent("AniFinish", BindTool.Bind(self.AniFinish, self))
end

function TipsAchievementView:OnRecieveClick()
	AchieveCtrl.Instance:SendFetchReward(self.data.id)
	self:CloseDestroy()
end

function TipsAchievementView:OpenCallBack()

end

function TipsAchievementView:OnFlush()
	self.node_list["TxtDes"].text.text = string.format("%s\n%s", self.data.sub_type_str or "", self.data.client_desc or "")
end

function TipsAchievementView:SetData(data)
	self.data = AchieveData.Instance:GetAchieveDataById(data.reward_id)
end

function TipsAchievementView:AniFinish()
	self:CloseDestroy()
end