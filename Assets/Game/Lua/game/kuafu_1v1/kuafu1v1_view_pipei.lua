KuaFu1v1ViewPiPei = KuaFu1v1ViewPiPei or BaseClass(BaseView)

function KuaFu1v1ViewPiPei:__init()
	self.ui_config = {
		{"uis/views/kuafu1v1_prefab", "ShowPk"},
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	-- self.is_modal = true
end

function KuaFu1v1ViewPiPei:LoadCallBack()
	-- self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self:PiPeiInfo()
end

function KuaFu1v1ViewPiPei:OpenCallBack()
	KuaFu1v1Ctrl.Instance:ShowEnemyInfo()
end

function KuaFu1v1ViewPiPei:ReleaseCallBack()
	if self.enter_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.enter_count_down)
		self.enter_count_down = nil
	end
end

function KuaFu1v1ViewPiPei:__delete()
	if self.enter_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.enter_count_down)
		self.enter_count_down = nil
	end
end

function KuaFu1v1ViewPiPei:OnClickClose()
	self:Close()
end

function KuaFu1v1ViewPiPei:PiPeiInfo()
	local macth_info = KuaFu1v1Data.Instance:Get1V1MacthInfo()
	macth_info.result = 0
	macth_info.match_end_left_time = 0

	local info = KuaFu1v1Data.Instance:GetMatchResult()
	KuaFu1v1Data.Instance:SetMatchingEnemySex(info)

	if info.result == 1 then
		local act_statu = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_ONEVONE) or {}
		local yes_func = function()
				self.Close()
			end
		local describe = ""
		if act_statu.status == ACTIVITY_STATUS.CLOSE then
			describe = Language.Kuafu1V1.MatchFailTxt2
		else
			describe = Language.Kuafu1V1.MatchFailTxt1
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		self.Close()
	else
		local plat = ""
		if GameVoManager.Instance:GetMainRoleVo().plat_type ~= info.oppo_plat_type then
			plat = Language.Common.WaiYu .. "_"
		end
		if info.oppo_sever_id <= 0 then
			info.oppo_sever_id = 1
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		info.name = plat .. info.oppo_name .. "_s" .. info.oppo_sever_id
		KuaFu1v1Data.Instance:SetOppoInfo(info)
		local enemy_info = KuaFu1v1Data.Instance:GetMatchingEnemySex()
		-- self.node_list["PiPeiTxt"].text.text = string.format(Language.Kuafu1V1.MatchSucTxt, plat, info.oppo_sever_id, info.oppo_name, info.capability)
		local total_time = 5
		self.node_list["BtnEnterTxt"].text.text = string.format(Language.Kuafu1V1.EnterSoonTime, total_time)
		self.node_list["Myname"].text.text = string.format(Language.Kuafu1V1.Name, main_role_vo.server_id, main_role_vo.name)
		self.node_list["Mylevel"].text.text = string.format(Language.Kuafu1V1.Level, PlayerData.GetLevelString(main_role_vo.level))
		self.node_list["Myhead"].image:LoadSprite(ResPath.Get1v1Head("prof_" .. PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)))
		if enemy_info == nil then
			return
		end 
		self.node_list["Enemyname"].text.text = string.format(Language.Kuafu1V1.Name, enemy_info.sever == 0 and Language.Kuafu1V1.WaiYu or enemy_info.sever, enemy_info.name)
		self.node_list["Enemylevel"].text.text = string.format(Language.Kuafu1V1.Level, PlayerData.GetLevelString(enemy_info.level))
		self.node_list["Enemyhead"].image:LoadSprite(ResPath.Get1v1Head("prof_" .. PlayerData.Instance:GetRoleBaseProf(enemy_info.prof)))
		
		local function send_to_onevone()
			if self.enter_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.enter_count_down)
				self.enter_count_down = nil
			end
			CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_ONEVONE)
		end
		local function second_fun()
			total_time = math.max(total_time - 1, 0)
			self.node_list["BtnEnterTxt"].text.text = string.format(Language.Kuafu1V1.EnterSoonTime, total_time)
		end
		self.node_list["BtnEnter"].button:AddClickListener(send_to_onevone)

		self.enter_count_down = CountDown.Instance:AddCountDown(5, 1, second_fun, send_to_onevone)

		KuaFu1v1Data.Instance:SetComeFromScene(true) 
	end
end
