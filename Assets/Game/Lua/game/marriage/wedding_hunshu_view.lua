WeddingHunShuView = WeddingHunShuView or BaseClass(BaseView)

local TouchTime = 2
local AutoCloseTime = 5

function WeddingHunShuView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","WeddingHunshuView"},}
	self.is_modal = true
end

function WeddingHunShuView:ReleaseCallBack()
	self.show_effect = nil
	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end

	if self.auto_close then
		GlobalTimerQuest:CancelQuest(self.auto_close)
		self.auto_close = nil
	end
end

function WeddingHunShuView:LoadCallBack()
	self.marry_way = MARRY_REQ_TYPE.MARRY_PRESS_FINGER_REQ
	self.agree = false
	self.otehr_agree = false
	self.node_list["Button"]:SetActive(true)
	self.node_list["FingerMe"]:SetActive(false)
	self.node_list["FingerOther"]:SetActive(false)

	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	local btn = self.node_list["Button"]:GetOrAddComponent(typeof(EventTriggerListener))
	btn:AddPointerDownListener(BindTool.Bind(self.OnClickStart, self))
	btn:AddPointerUpListener(BindTool.Bind(self.OnClickEnd, self))

	self:Flush()
end

function WeddingHunShuView:CloseCallBack()
	MarriageCtrl.Instance:CloseAllView()
end

function WeddingHunShuView:OnClickClose(is_accept)
	if self.agree and self.otehr_agree then
		self:Close()
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_uid <= 0 then
		local yes_func = function()
			local info = MarriageData.Instance:GetReqWeddingInfo()
			if not next(info) then
				local wedding_info = MarriageData.Instance:GetWeddingTargetInfo()
				if wedding_info then
					MarriageCtrl.Instance:SendMarryRet(wedding_info.wedding_type, is_accept, wedding_info.target_id)
				end
				self:Close()
				return
			end

			MarriageCtrl.Instance:SendMarryRet(info.marry_type, is_accept, info.req_uid)
			self:Close()
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Marriage.EscMarryPledge, yes_func)
	else
		MarriageCtrl.Instance:SendMarryReq(self.marry_way)
		self:Close()
	end
end

function WeddingHunShuView:OnClickStart()
	self.press_time = GlobalTimerQuest:AddDelayTimer(function ()
		self.agree = true
		self.node_list["Button"]:SetActive(false)
		MarriageCtrl.Instance:SendMarryReq(self.marry_way)
	end, TouchTime)
end

function WeddingHunShuView:OnClickEnd()
	if self.agree then return end

	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.MarryHunshuErroRemind)
end

function WeddingHunShuView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "finish" then
			if not self.otehr_agree then
				self.node_list["FingerOther"]:SetActive(true)
				self.otehr_agree = true
			else
				self.node_list["FingerMe"]:SetActive(true)
			end
		elseif k == "bothfinish" then
			self.node_list["Time"]:SetActive(true)
			if self.auto_close then
				GlobalTimerQuest:CancelQuest(self.auto_close)
				self.auto_close = nil
			end
			local time = AutoCloseTime
			if self.auto_close == nil then
				self.auto_close = GlobalTimerQuest:AddRunQuest(function ()
					self.node_list["Time"].text.text = string.format(Language.Marriage.TimeCount, time)
					time = time - 1
					if time < 0 then
						self:Close()
						GlobalTimerQuest:CancelQuest(self.auto_close)
						self.auto_close = nil
					end
				end, 1)
			end
		end
	end
end