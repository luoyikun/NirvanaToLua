KuaFu1v1ViewCount = KuaFu1v1ViewCount or BaseClass(BaseView)

function KuaFu1v1ViewCount:__init()
	self.ui_config = {
		{"uis/views/kuafu1v1_prefab", "CountPanel"},
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuaFu1v1ViewCount:LoadCallBack()
	self.node_list["RemindBtn"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ShowBtn"].button:AddClickListener(BindTool.Bind(self.GoBack, self))
	self.node_list["PiPeiNode"]:SetActive(true)
	self.node_list["CountTxt"]:SetActive(false)
end

function KuaFu1v1ViewCount:ReleaseCallBack()
	self:RemoveCountDown()
	self:RemoveDelayTime()
end

function KuaFu1v1ViewCount:OpenCallBack()
	self:RemoveDelayTime()
	self:StartCountDown()
end

function KuaFu1v1ViewCount:__delete()
end

function KuaFu1v1ViewCount:StartCountDown()
	if self.count_down then
		return
	end
	local result, match_end_left_time = KuaFu1v1Data.Instance:GetMatchAck()
	self.node_list["ShowTxt"].text.text = "1"
	self.node_list["PiPeiNode"]:SetActive(true)
	self.node_list["CountTxt"]:SetActive(false)
	self.node_list["RemindBtn"]:SetActive(false)
	self.node_list["ShowBtn"]:SetActive(true)
	if nil == self.count_down then
		self.count_down = CountDown.Instance:AddCountDown(600, 1, function(elapse_time, total_time) 
			self.node_list["ShowTxt"].text.text = math.ceil(elapse_time)
			end)
	end
end

function KuaFu1v1ViewCount:CountDown(callback, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end
	self.node_list["ShowTxt"].text.text = time
end

function KuaFu1v1ViewCount:MatchFaild()
	self.node_list["PiPeiNode"]:SetActive(false)
	self.node_list["CountTxt"]:SetActive(true)
	self.node_list["CountTxt"].text.text = Language.Kuafu1V1.PiPeiFailed
	self.node_list["RemindBtn"]:SetActive(true)
	self.node_list["ShowBtn"]:SetActive(false)
	self:RemoveCountDown()
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:Close() end, 5)
end

function KuaFu1v1ViewCount:MatchSucceed()
	self.node_list["PiPeiNode"]:SetActive(false)
	self.node_list["CountTxt"]:SetActive(true)
	self.node_list["ShowBtn"]:SetActive(false)
	self:RemoveCountDown()
	self.node_list["CountTxt"].text.text = Language.Kuafu1V1.PiPeiSucc
	self.node_list["ShowTxt"].text.text = 3
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, BindTool.Bind(self.EnterCross, self)))
end

function KuaFu1v1ViewCount:EnterCross()
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_ONEVONE)
	ViewManager.Instance:Close(ViewName.KuaFu1v1)
	self:Close()
end

function KuaFu1v1ViewCount:GoBack()
	self:CloseVisible()
	--KuaFu1v1Ctrl.Instance.main_view:Close()
end

function KuaFu1v1ViewCount:OnFlush()
	local info = KuaFu1v1Data.Instance:GetMatchResult()
	if not info then return end
	self:RemoveCountDown()
	if info.result == 1 then
		self:MatchFaild()
		KuaFu1v1Data.Instance:SetIsMatching(false)
	else
		self:MatchSucceed()
		KuaFu1v1Data.Instance:SetIsMatching(false)
	end
end

function KuaFu1v1ViewCount:OpenAndFlush()
	self:Open()
	self:Flush()
end

function KuaFu1v1ViewCount:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function KuaFu1v1ViewCount:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end
