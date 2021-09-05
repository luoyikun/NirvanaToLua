ArenaView = ArenaView or BaseClass(BaseRender)
local TWEEN_TIME = 0.5
function ArenaView:__init()
	self.time_value = 9
	self.is_show_hook = true
	self.is_show_bubble = false
	self.is_not_show_fabao = true
	self.kill_list = {}
	self.model_list = {}

	self.node_list["SwitchEnemy"].button:AddClickListener(BindTool.Bind(self.SendRefreshCompetitor, self))
	self.node_list["BtnBuyTime"].button:AddClickListener(BindTool.Bind(self.SendBuyJoinTimes, self))
	self.node_list["TxtSwitchEnemy"].text.text = Language.Common.RefreshQuery

	for i = 1, 5 do
		self.node_list["RoleStand" .. i].button:AddClickListener(BindTool.Bind(self.ToggleEvent, self, i))
		self.node_list["imgShowKill" .. i].button:AddClickListener(BindTool.Bind(self.ToggleEvent, self, i))
		self.model_list[i] = RoleModel.New()
		self.model_list[i]:SetDisplay(self.node_list["Display"..i].ui3d_display, MODEL_CAMERA_TYPE.BASE)
		self.model_list[i]:ResetRotation()
	end

	self.fight_text = {}
	for i = 1, 5 do
		local fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFPNum" .. i])
		self.fight_text[i] = fight_text
	end
	RemindManager.Instance:SetRemindToday(RemindName.ArenaChallange)
end

function ArenaView:__delete()
	self.is_show_hook = true
	self.kill_list = {}
	self.uid_list = {}

	for k, v in pairs(self.model_list) do
		v:DeleteMe()
	end
	self.model_list = {}

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end
	self.fight_text = {}
end

function ArenaView:OnFlush()
	self:FlushArenaView()
end

function ArenaView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			local random_index = math.random(1,5)
			-- self.model_list[random_index]:SetTrigger(ANIMATOR_PARAM.COMBO1_1)
			-- self.model_list[random_index]:SetTrigger(ANIMATOR_PARAM.COMBO1_2)
			-- self.model_list[random_index]:SetTrigger(ANIMATOR_PARAM.COMBO1_3)
			self.model_list[random_index]:ShowRest()

			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function ArenaView:ToggleEvent(index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if self.uid_list[index] == main_role_id then
		return
	end
	local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[index])
	if nil == role_info then
		return
	end
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(role_info.user_id)
	if tz_info then
		local data = {}
		data.opponent_index = tz_info.index
		data.rank_pos = tz_info.rank_pos
		data.is_auto_buy = 0
		ArenaCtrl.Instance:ResetFieldFightReq(data)
		local tz_num = ArenaData.Instance:GetResidueTiaoZhanNum()
		if not self.kill_list[index] then
			ViewManager.Instance:Close(ViewName.Activity, TabIndex.arena_view)
		elseif tz_num > 0 then
			ArenaCtrl.Instance:ReqFieldGetUserInfo()
			ArenaCtrl.Instance:ResetOpponentList()
			ArenaCtrl.Instance:ReqOtherRoleInfo(0)
		end
	end
end

function ArenaView:SetModel()
	for i = 1, 5 do
		local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[i])
		if role_info then
			-- self.model_list[i]:SetFaBaoResid(0)
			self.model_list[i]:SetModelResInfo(role_info, nil, self.is_show_hook, nil, nil, nil, nil, self.is_not_show_fabao)
		end
	end
	self:CalToShowAnim()
end

function ArenaView:OpenCallBack()
	ArenaCtrl.Instance:ReqFieldGetUserInfo()
	ArenaCtrl.Instance:ReqOtherRoleInfo(0)
	self:SetReMainTime()
end

function ArenaView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Node_Button"], Vector3(1, -422, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["bg_time"], Vector3(-102, 298, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["middle"], true, TWEEN_TIME)
end

function ArenaView:SendRefreshCompetitor()
	ArenaCtrl.Instance:ResetOpponentList()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.time_value = cfg.refresh_cooldown
	self.count_down = CountDown.Instance:AddCountDown(99999, 1, BindTool.Bind(self.ChangeTime, self))
	self:ChangeTime()
end

function ArenaView:OnClickBuffBtn()
	ArenaCtrl.Instance:OpenArenaBuffView()
end

function ArenaView:SendBuyJoinTimes()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local max_goumai = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.BUY_ARENA_CHALLENGE_COUNT]
	local max_count = VipData.Instance:GetVipPowerList(15)[VIPPOWER.BUY_ARENA_CHALLENGE_COUNT]
	local describe = ""
	local yes_func = nil
	local goumaicishu = ArenaData.Instance:GetBuyJoinTimesTimes()
	if max_goumai - goumaicishu > 0 then
		local gold_cost = ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1].buy_join_times_cost
		describe = string.format(Language.Field1v1.AddNumTip, ToColorStr(gold_cost, TEXT_COLOR.GREEN), ToColorStr(goumaicishu + 1, TEXT_COLOR.GREEN))
		yes_func = function() ArenaCtrl.Instance:FieldBuyJoinTimes() end
	elseif goumaicishu < max_count then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BUY_ARENA_CHALLENGE_COUNT)
		return
	else
		describe = Language.Field1v1.AddNumTip2
		SysMsgCtrl.Instance:ErrorRemind(describe)
		return
	end

	TipsCtrl.Instance:ShowCommonAutoView("arena_view", describe, yes_func)
end

function ArenaView:ChangeTime()
	if self.time_value <= 0 then
		self.node_list["TxtSwitchEnemy"].text.text = Language.Common.RefreshQuery
		UI:SetButtonEnabled(self.node_list["SwitchEnemy"], true)
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	else
		local time = TimeUtil.FormatSecond(self.time_value, 2)
		self.node_list["TxtSwitchEnemy"].text.text = time
		UI:SetButtonEnabled(self.node_list["SwitchEnemy"], false)
	end
	self.time_value = self.time_value - 1
end

function ArenaView:FlushArenaView()
	local info = ArenaData.Instance:GetUserInfo()
	if nil == info then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sorted_list = info.rank_list
	for i,v in ipairs(sorted_list) do
		if v.user_id == main_role_vo.role_id then
			table.remove(sorted_list, i) --先把自己移除
			break
		end
	end

	if info.rank <= 5 then
		local data = {}
		data.user_id = main_role_vo.role_id
		data.rank = info.rank
		table.insert(sorted_list, data) --再把自己加进列表
	end

	table.sort(sorted_list, SortTools.KeyUpperSorter("rank")) --五名以内按名次顺序排，从弱鸡到大神

	self.uid_list = {}
	for i, v in ipairs(sorted_list) do
		table.insert(self.uid_list, v.user_id)
	end

	if info.rank > 5 then
		table.insert(self.uid_list, 2, main_role_vo.role_id) --五名以外固定显示在第二的位置，弱鸡排第一，自己排第二
	end

	self:SetModel()
	local my_capability = main_role_vo.capability
	for i = 1, #self.uid_list do
		local rank = ArenaData.Instance:GetRankByUid(self.uid_list[i])
		local role_info = ArenaData.Instance:GetRoleInfoByUid(self.uid_list[i])
		if role_info then
			local color = role_info.capability <= my_capability and TEXT_COLOR.GREEN or TEXT_COLOR.RED
			self.node_list["TxtRankNum" .. i].text.text = ToColorStr(rank, color)
			if self.fight_text[i] and self.fight_text[i].text then
				self.fight_text[i].text.text = role_info.capability
			end

			local rank_reward_cfg = nil
			if self.uid_list[i] == main_role_vo.role_id then
				local cur_index = ArenaData.Instance:GetBestRankIndex()
				rank_reward_cfg = ArenaData.Instance:GetHistoryRankCfg(cur_index)
			else
				rank_reward_cfg = ArenaData.Instance:GetHistoryRankRewardCfg(role_info.best_rank_break_level)
			end

			if rank_reward_cfg then
				local rank_name = ToColorStr(rank_reward_cfg.best_rank_name, ARENA_NAME_COLOR[rank_reward_cfg.best_rank_name_color])
				self.node_list["TxtRoleName" .. i].text.text = string.format(Language.Arena.RankName, role_info.name, rank_name)
			end
			
			self.kill_list[i] = (role_info.capability < my_capability and rank > info.rank) and true or false
			self.node_list["imgShowKill" .. i]:SetActive(self.kill_list[i])
			self.node_list["ImgRoleBG" .. i]:SetActive(self.uid_list[i] == main_role_vo.role_id)
			self.node_list["ImgMineRoleBG" .. i]:SetActive(self.uid_list[i] == main_role_vo.role_id)
		end
	end
	local tz_num = ArenaData.Instance:GetResidueTiaoZhanNum()
	if tonumber(tz_num) == 0 then
		tz_num = ToColorStr(tz_num, TEXT_COLOR.RED)
	end
	self.node_list["TxtTZNum"].text.text = tz_num
end

function ArenaView:SetReMainTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local sever_day = ArenaData.Instance:GetArenaViewOpenSeverDay()
	local differ_day = sever_day - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day + 22 * 3600 - time
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["bg_time"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 16)
			self.node_list["bg_time"]:SetActive(true)
			self.node_list["refresh_tips"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.day_count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

