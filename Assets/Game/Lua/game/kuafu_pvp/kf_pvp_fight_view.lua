
TeamInfo = {
	TeamNoOne = 0, 				--队伍1
	TeamNoTwo = 1, 				--队伍2
}


KFPVPFightView = KFPVPFightView or BaseClass(BaseView)

function KFPVPFightView:__init()
	self.ui_config = {{"uis/views/kuafu3v3_prefab", "KuaFu3v3Fight"}}
	
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.hide = false
	self.down_start_time = true
end


function KFPVPFightView:LoadCallBack()
	self.listen_hp = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.node_list["ActivityTime"].text.text = ""
	PlayerData.Instance:ListenerAttrChange(self.listen_hp)
	KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
	self:HeadChangeSelf()
	-- self.node_list["TipsBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	local info = KuafuPVPData.Instance:GetPrepareInfo()
	if info.match_state == 1 then
		self:StartFight()
	end

	self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing3 
	self.progess = ProgressBar.New(self.node_list["JuDianProgressBG"])
	self.progess:SetTweenType(TweenType.DoubleWay)

	self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing3

	-- self.scene_loaded = GlobalEventSystem:Bind(
	-- 	SceneEventType.SCENE_LOADING_STATE_QUIT,BindTool.Bind(self.CompeleteLoack, self))
end

function KFPVPFightView:ReleaseCallBack()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
	if self.fight_timer then
		CountDown.Instance:RemoveCountDown(self.fight_timer)
		self.fight_timer = nil
	end

	if nil ~= self.progess then
		self.progess:DeleteMe()
		self.progess = nil
	end
	self.down_start_time = true

	-- if self.scene_loaded then
	-- 	GlobalEventSystem:UnBind(self.scene_loaded)
	-- 	self.scene_loaded = nil
	-- end
end


function KFPVPFightView:OpenCallBack()
	-- if self.node_list["PreparePanel"] then
	-- 	self.node_list["PreparePanel"]:SetActive(true)
	-- end
	local info = KuafuPVPData.Instance:GetPrepareInfo()
	if info.match_state == 1 then
		-- self:ClosePrepare()
		ViewManager.Instance:Close(ViewName.KFPVPPrepareView)
	elseif info.match_state == 0 then
		-- self.node_list["PreparePanel"]:SetActive(true)
		ViewManager.Instance:Open(ViewName.KFPVPPrepareView)
	end
	self:FlushBaseInfo()
	-- self:StartCountDown()
end

-- function KFPVPFightView:CompeleteLoack()
-- 	local scene_type = Scene.Instance:GetSceneType()
-- 	if scene_type ~= SceneType.Kf_PVP then
-- 		return
-- 	end


-- end

-- function KFPVPFightView:ClosePrepare()
-- 	if self.node_list["PreparePanel"] then
-- 		self.node_list["PreparePanel"]:SetActive(false)
-- 	end
-- end

function KFPVPFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "start_time" == k then
			self:StartFight()
			return
		end
	end
	local slider_max_num = 100
	local zhanling_value = KuafuPVPData.Instance:GetSliderNum()
	local self_side = KuafuPVPData.Instance:GetRoleInfo().self_side
	if zhanling_value == nil or self_side == nil then return end
	if self_side == 1 then
		if self.progess then
			self.progess:SetValue(1 - (zhanling_value / slider_max_num))
		end
	else
		if self.progess then
			self.progess:SetValue(zhanling_value / slider_max_num)
		end
	end
	-- self.node_list["JuDianProgressBG"].slider.value = zhanling_value / slider_max_num

	if self_side == TeamInfo.TeamNoOne then
		if zhanling_value == 100 then
			self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing1
		elseif zhanling_value == 0 then
			self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing2
		end

	else
		if zhanling_value == 100 then
			self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing2
		elseif zhanling_value == 0 then
			self.node_list["ZhanLingText"].text.text = Language.Kuafu3V3.ZhanLing1
		end
		
	end
	
	local side_score_list = KuafuPVPData.Instance:GetSideScoreList()
	local side_max_score = KuafuPVPData.Instance:GetMaxScoreCfg()
	
	local my_team_flag,	enemy_team_flag = self:CheckMySide()
	if side_max_score ~= nil and side_max_score > 0 then
		self.node_list["MyScoreProg"].slider.value = side_score_list[my_team_flag] / side_max_score
		self.node_list["MyScoreProTxt"].text.text = side_score_list[my_team_flag] .. "/" .. side_max_score
		self.node_list["EnemyScoreProg"].slider.value = side_score_list[enemy_team_flag] / side_max_score
		self.node_list["EnemyScoreProgTxt"].text.text = side_score_list[enemy_team_flag] .. "/" .. side_max_score
	end

end

function KFPVPFightView:CheckMySide()
	local self_side = KuafuPVPData.Instance:GetRoleInfo().self_side
	local my_side = 0
	local enemy_side = 0
	if self_side == TeamInfo.TeamNoOne then
		my_side = TeamInfo.TeamNoOne
		enemy_side = TeamInfo.TeamNoTwo
	else
		my_side = TeamInfo.TeamNoTwo
		enemy_side = TeamInfo.TeamNoOne
	end
	return my_side, enemy_side
end

-- function KFPVPFightView:OnClickHelp()
-- 	TipsCtrl.Instance:ShowHelpTipView(291)
-- end



function KFPVPFightView:ClickExit()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit, nil, nil, false)
end



-- function KFPVPFightView:StartCountDown()
-- 	if self.count_down then
-- 		return
-- 	end
-- 	local time = KuafuPVPData.Instance:GetPrepareAndFightTime()
-- 	local match_state = KuafuPVPData.Instance:GetPrepareInfo().match_state
-- 	local start_time = time - TimeCtrl.Instance:GetServerTime()
-- 	local user_list = KuafuPVPData.Instance:GetPrepareInfo().user_info_list
-- 	local team_index = KuafuPVPData.Instance:GetRoleTeamIndex()
-- 	if user_list == nil then
-- 		return
-- 	end
-- 	for k, v in ipairs(user_list) do
-- 		if team_index == TeamInfo.TeamNoOne then
-- 			if k <= 3 then
-- 				k = k + 3
-- 			else
-- 				k = k - 3
-- 			end
-- 		end
-- 		self.node_list["Name" .. k].text.text = v.name
-- 		local img = v.sex .. (v.prof % 10)
-- 		local bundle, asset = ResPath.GetKf3V3FinishImg(img)
-- 		self.node_list["RawImage" .. k].raw_image:LoadSprite(bundle, asset)
-- 	end
-- 	self.count_down = CountDown.Instance:AddCountDown(start_time, 1, BindTool.Bind(self.CountDown, self, self.node_list["StartTimer"]))
-- end

function KFPVPFightView:RemoveCountDown()
	-- if self.count_down then
	-- 	CountDown.Instance:RemoveCountDown(self.count_down)
	-- 	self.count_down = nil
	-- end
	
	if self.fight_timer then
		CountDown.Instance:RemoveCountDown(self.fight_timer)
		self.fight_timer = nil
	end
end

-- function KFPVPFightView:CountDown(time_obj, elapse_time, total_time)
-- 	local time = math.ceil(total_time - elapse_time)
-- 	if time <= 0 then
-- 		self:StartFight()
-- 		self:RemoveCountDown()
-- 		time = 0
-- 		if callback then
-- 			callback()
-- 		end
-- 	end
-- 	time_obj.text.text = time
-- end

function KFPVPFightView:StartFight()
	local time = KuafuPVPData.Instance:GetPrepareAndFightTime()
	local match_state = KuafuPVPData.Instance:GetPrepareInfo().match_state
	local left_time = time - TimeCtrl.Instance:GetServerTime()
	if left_time >= 10 then
		self:RemoveCountDown()
		self.fight_timer = CountDown.Instance:AddCountDown(left_time, 1, BindTool.Bind(self.ActivityTimeCountDown, self, self.node_list["ActivityTime"]))
	end
end

function KFPVPFightView:ActivityTimeCountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	self.down_start_time = true
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end
	time_obj.text.text = string.format(Language.Kuafu3V3.ActivityTime, TimeUtil.FormatSecond(time, 2))
end

function KFPVPFightView:FlushBaseInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(vo.level)
	-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)

	self.node_list["MyName"].text.text =  PlayerData.GetLevelString(vo.level) .. vo.name

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.max_hp ~= nil and vo.max_hp > 0 then
		self:SetHpPercent(vo.hp / vo.max_hp)
	end

end


function KFPVPFightView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.max_hp ~= nil and vo.max_hp > 0 then
			self:SetHpPercent(vo.hp / vo.max_hp)
		end
	end
end


-- 设置目标血条
function KFPVPFightView:SetHpPercent(percent)
	self.node_list["HPTop"].slider.value = percent
end

-- 头像
function KFPVPFightView:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local avatar_path_big = AvatarManager.Instance:GetAvatarKey(vo.role_id, true)
	if AvatarManager.Instance:isDefaultImg(vo.role_id) == 0 or avatar_path_big == 0 then
		local bundle, asset = ResPath.GetRoleHeadBig((vo.prof % 10), vo.sex)
		self.node_list["IconImg"].image:LoadSprite(bundle, asset)
		return
	end
end
