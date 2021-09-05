KFPVPViewPiPei = KFPVPViewPiPei or BaseClass(BaseView)

function KFPVPViewPiPei:__init()
	self.ui_config = {
		{"uis/views/kuafu3v3_prefab", "PiPeiPanel"},
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
end

function KFPVPViewPiPei:LoadCallBack()
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["Enter"].button:AddClickListener(BindTool.Bind(self.OnEnter, self))
	self.node_list["QuXiao"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self:PiPeiInfo()
end

function KFPVPViewPiPei:OpenCallBack()
	
end

function KFPVPViewPiPei:ReleaseCallBack()

end

function KFPVPViewPiPei:__delete()

end

function KFPVPViewPiPei:OnEnter()
	-- 发送匹配协议
	KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeMatchgingReq()
	self:Close()
end


function KFPVPViewPiPei:OnClickClose()
	self:Close()
end

function KFPVPViewPiPei:PiPeiInfo()
	local mate_list = KuafuPVPData.Instance:GetMatesInfo()
	local tream_list = ScoietyData.Instance:GetMemberList()
	if #mate_list > 1 then
		if #tream_list > 3 then
			SysMsgCtrl.Instance:ErrorRemind(Language.KuafuPVP.MaxTeammateTips)
			return
		end
		local team_mate = ""
		for k,v in pairs(mate_list) do
			local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
			if v.uid ~= role_id then
				-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(v.level)
				-- local level = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
				team_mate = team_mate .. "    " .. v.user_name .. " " .. PlayerData.GetLevelString(v.level) .. "\n"
			end
		end
		self.node_list["PiPeiTxt"].text.text = string.format(Language.KuafuPVP.TeamMatch, team_mate)
	else
		self.node_list["PiPeiTxt"].text.text = Language.KuafuPVP.SelfMatch
	end
end
