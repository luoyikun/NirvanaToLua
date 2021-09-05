KuaFu1v1ViewLoser = KuaFu1v1ViewLoser or BaseClass(BaseView)

function KuaFu1v1ViewLoser:__init(instance)
	self.ui_config = {{"uis/views/kuafu1v1_prefab", "KuaFu1v1Loser"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function KuaFu1v1ViewLoser:__delete()

end

function KuaFu1v1ViewLoser:LoadCallBack()
	self.node_list["OnClickBtn"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["RankTxt"]:SetActive(true)
	self.node_list["IsUpLevelNode"]:SetActive(false)
end

function KuaFu1v1ViewLoser:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

end

function KuaFu1v1ViewLoser:OpenCallBack()
	self:Flush()
end

function KuaFu1v1ViewLoser:OnFlush()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:OnClick() end, 5)
	local result_info = KuaFu1v1Data.Instance:GetFightResult()
	local honor_reward = KuaFu1v1Data.Instance:GetGongXunReward(result_info.result)
	local add_score = 0
	if result_info then
		add_score = result_info.award_score
		self.node_list["JifenTxt"].text.text = result_info.award_score
		self.node_list["RewardTxt"].text.text = "+" .. honor_reward
	end
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info then
		local score = info.cross_score_1v1
		local current_config, next_config = KuaFu1v1Data.Instance:GetRankByScore(score)
		self:SetCurInfo(score, current_config, next_config)
		GlobalTimerQuest:AddDelayTimer(function() self:SetNextInfo(score, add_score, current_config, next_config) end, 0.1)
	end
end

function KuaFu1v1ViewLoser:SetCurInfo(score, current_config, next_config)
	if current_config then
		self.node_list["RankTxt"].text.text = current_config.name
		self.node_list["ValueTxt"].text.text = current_config.name
		if next_config then
			local temp = next_config.score - current_config.score
			self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)).value = (score - current_config.score) / temp
			self.node_list["IsUpLevelTxt"].text.text = score .. "/" .. next_config.score
			self.node_list["NextRankTxt"].text.text = next_config.name
		else
			self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)).value = 1
			self.node_list["IsUpLevelTxt"].text.text = score
		end
	elseif next_config then
		self.node_list["RankTxt"].text.text = Language.Common.WuDuanWei
		self.node_list["ValueTxt"].text.text = Language.Common.WuDuanWei
		self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)).value = score / next_config.score
		self.node_list["IsUpLevelTxt"].text.text = score .. "/" .. next_config.score
		self.node_list["NextRankTxt"].text.text = next_config.name
	end
end

function KuaFu1v1ViewLoser:SetNextInfo(score, add_score, current_config, next_config)
	local new_score = score + add_score
	local new_current_config, new_next_config = KuaFu1v1Data.Instance:GetRankByScore(new_score)
	if current_config == new_current_config then
		if next_config then
			local temp = next_config.score - current_config.score
			self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)):DOValue((new_score - current_config.score) / temp, 0.5, false)
			self.node_list["IsUpLevelTxt"].text.text = new_score .. "/" .. next_config.score
		end
		self.node_list["RankTxt"]:SetActive(true)
		self.node_list["IsUpLevelNode"]:SetActive(false)
	else
		self.node_list["RankTxt"]:SetActive(false)
		self.node_list["IsUpLevelNode"]:SetActive(true)
		local tweener = self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)):DOValue(1, 0.25, false)
		tweener:OnComplete(function()
			if new_current_config and new_next_config then
				self.node_list["IsUpLevelTxt"].text.text = new_score .. "/" .. new_next_config.score
				local temp = new_next_config.score - new_current_config.score
				self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)).value = 0
				GlobalTimerQuest:AddDelayTimer(function() self.node_list["Slider"]:GetComponent(typeof(UnityEngine.UI.Slider)):DOValue((new_score - new_current_config.score) / temp, 0.25, false) end, 0.01)
			end
			end)
	end
end

function KuaFu1v1ViewLoser:OnClick()
	self:Close()
	CrossServerCtrl.Instance:GoBack()
end