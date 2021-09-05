local InitRequire = {
	ctrl_state = CTRL_STATE.START,
	require_list = {},
	require_count = 0,
	require_index = 0,
}

function InitRequire:Start()
	-- 获取基础的require列表.
	self.require_list = require("game/common/require_list")

	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		table.insert(self.require_list, "agent/pc/agent_adapter")
	else
		-- 创建渠道匹配器, 如果这个列表里面没有则使用默认的.
		local agentTable = {
			["dev"] = "agent/dev/agent_adapter",
			["its"] = "agent/dev/agent_adapter",
			["dtw"] = "agent/dev/agent_adapter",
			["ttw"] = "agent/dev/agent_adapter"
		}

		local agentPath = agentTable[ChannelAgent.GetChannelID()]
		if agentPath ~= nil then
			table.insert(self.require_list, agentPath)
		else
			table.insert(self.require_list, "agent/agent_adapter")
		end
	end

	self.require_count = #self.require_list
	if IS_AUDIT_VERSION then
		local auditldtext = GLOBAL_CONFIG.param_list.auditldtext
		if auditldtext ~= "" then
			InitCtrl:SetText(auditldtext)
		else
			InitCtrl:SetText("通信中...")
		end
	else
		InitCtrl:SetText("加载中(不耗流量)")
	end
	ReportManager:Step(Report.STEP_REQUIRE_START)
end

function InitRequire:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.UPDATE then
		local end_index = self.require_index + 24
		for i = self.require_index + 1, end_index do
			self.require_index = i
			if nil == self.require_list[i] then
				ReportManager:Step(Report.STEP_REQUIRE_END)
				self.ctrl_state = CTRL_STATE.STOP
				InitCtrl:SetPercent(0.3, function()
					InitCtrl:OnCompleteRequire()
				end)
				return
			else
				local path = self.require_list[self.require_index]
				if string.match(path, "^config/auto_new/.*") then
					CheckLuaConfig(path, require(path))
				else
					require(path)
				end
			end
		end
		InitCtrl:SetPercent(self.require_index / self.require_count * 0.3)
	elseif self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
end

function InitRequire:Stop()
	GameRoot.Instance:PruneLuaBundles()
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
end

return InitRequire
