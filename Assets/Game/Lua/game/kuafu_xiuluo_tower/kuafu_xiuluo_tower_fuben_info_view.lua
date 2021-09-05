KuaFuXiuLuoTowerFuBenInfoView = KuaFuXiuLuoTowerFuBenInfoView or BaseClass(BaseView)

local BOX_ITEM_ID = {
	[1] = {item_id = 28681, num = 1, is_bind = 1}, 				--红宝箱
	[2] = {item_id = 28682, num = 1, is_bind = 1},				--橙宝箱
}
function KuaFuXiuLuoTowerFuBenInfoView:__init()
	self.ui_config = {{"uis/views/kuafuxiuluotower_prefab", "XiuLuoFuBenInfoView"}}
	self.active_close = false
	self.fight_info_view = true
	self.mode_vis = true
	self.menu_vis = true
	self.cur_layer_index = 1
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function KuaFuXiuLuoTowerFuBenInfoView:ReleaseCallBack()
	if self.rank_list then
		self.rank_list:DeleteMe()
		self.rank_list = nil
	end
	if self.task_view then
		self.task_view:DeleteMe()
		self.task_view = nil
	end
	if self.score_view then
		self.score_view:DeleteMe()
		self.score_view = nil
	end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.task_view = nil
	self.score_view = nil
	self.show_panel = nil
end

function KuaFuXiuLuoTowerFuBenInfoView:LoadCallBack()
	self.is_boss_die = true
	local id = GameVoManager.Instance:GetMainRoleVo().role_id

	self.task_view = XiuLuoTaskView.New(self.node_list["TaskView"])
	self.score_view = XiuLuoScoreView.New(self.node_list["ScoreView"])

	self.rank_list = KuaFuXiuLuoTowerRankList.New(self.node_list["XiuLuoTowerRankList"])
	self.rank_list:SetActive(false)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.SetRankListVisable, self, false))
	self.node_list["BtnOpenRankList"].button:AddClickListener(BindTool.Bind(self.SetRankListVisable, self, true))

	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end
function KuaFuXiuLuoTowerFuBenInfoView:OpenCallBack()
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.ClickBoss, self))
	FuBenCtrl.Instance:SetMonsterInfo(KuaFuXiuLuoTowerData.Instance:GetMonsterID())
	self:Flush()
end

function KuaFuXiuLuoTowerFuBenInfoView:SwitchButtonState(enable)
	self.menu_vis = enable
	self.node_list["PanelTaskParent"]:SetActive(self.menu_vis and self.mode_vis)
end

function KuaFuXiuLuoTowerFuBenInfoView:CloseCallBack()
	FuBenCtrl.Instance:ClearMonsterClickCallBack()
end

function KuaFuXiuLuoTowerFuBenInfoView:SetRankListVisable(is_show)
	self.rank_list:SetActive(is_show)
end

function KuaFuXiuLuoTowerFuBenInfoView:OnMainUIModeListChange(is_show)
	self.mode_vis = not is_show
	self.node_list["PanelTaskParent"]:SetActive(self.menu_vis and self.mode_vis)
end

function KuaFuXiuLuoTowerFuBenInfoView:FlushRank()
	if self:IsLoaded() then
		self.rank_list:Flush()
	end
end

--改层提示
function KuaFuXiuLuoTowerFuBenInfoView:OnLayerChange(data)
	if not self:IsLoaded() or data == nil then
		return
	end
	if data.is_drop_layer == 1 then
		self.node_list["ChangeLevel"].text.text = string.format(Language.XiuLuo.GoBack, KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() - 1)
	else
		self.node_list["ChangeLevel"].text.text = string.format(Language.XiuLuo.GoForward, KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() + 1)
	end

	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["ChangeLayerTips"].animator:SetTrigger("Show")
	end, 0.5)
end

function KuaFuXiuLuoTowerFuBenInfoView:OnFlush()
	local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	--local is_drop_level = KuaFuXiuLuoTowerData.Instance:GetIsDropLayer(cu_layer)
	local is_show_drop_des = KuaFuXiuLuoTowerData.Instance:GetCurLayerDes()
	if nil ~= is_show_drop_des then
		self.node_list["TxtReLifeTips1"]:SetActive(is_show_drop_des)
		self.node_list["TxtReLifeTips2"]:SetActive(not is_show_drop_des)
	end
	self.node_list["TxtReceng"].text.text = string.format(Language.Boss.Floor, cu_layer)
	
	self.task_view:Flush()
	self.score_view:Flush()
end

function KuaFuXiuLuoTowerFuBenInfoView:OnSelfInfoChange()
	self:Flush()
end


function KuaFuXiuLuoTowerFuBenInfoView:ClickBoss()
	local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	local max_layer = KuaFuXiuLuoTowerData.Instance:GetMaxLayer()
	if cu_layer >= max_layer then
		local x, y = KuaFuXiuLuoTowerData.Instance:GetGuajiXY()
		local callback = function()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 10, 1)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.XiuLuo.PleaseUp)
	end
end

----------------------任务View----------------------
XiuLuoTaskView = XiuLuoTaskView or BaseClass(BaseRender)

local MAX_REWARD_NUM = 3

function XiuLuoTaskView:__init()
	self.boss_reward_list = {}
	self.gather_reward_list = {}
	self.boss_name = ""
	for i = 1, MAX_REWARD_NUM do
		self.boss_reward_list[i] = ItemCell.New()
		self.boss_reward_list[i]:SetInstanceParent(self.node_list["CellBossReward" .. i])

		self.gather_reward_list[i] = ItemCell.New()
		self.gather_reward_list[i]:SetInstanceParent(self.node_list["GatherReward" .. i])

		self.node_list["BtnBox" .. i].button:AddClickListener(BindTool.Bind(self.ClickBox, self, i))
	end
	local reward_list = KuaFuXiuLuoTowerData.Instance:GetBossReward()
	for k,v in ipairs(self.boss_reward_list) do
		v:SetData(reward_list[k])
		v.root_node:SetActive(reward_list[k] ~= nil)
	end
	local boss_id = KuaFuXiuLuoTowerData.Instance:GetMonsterID()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if monster_cfg then
		local cfg = monster_cfg[boss_id]
		if cfg then
			self.boss_name = cfg.name
		end
	end

	self:GatherRewardFlush()
	--self:BossRewardFlush()
end

function XiuLuoTaskView:__delete()
	for k,v in pairs(self.boss_reward_list) do
		v:DeleteMe()
	end
	self.boss_reward_list = {}

	for k,v in pairs(self.gather_reward_list) do
		v:DeleteMe()
	end
	self.gather_reward_list = {}
	GlobalTimerQuest:CancelQuest(self.boss_countdown)
end

local old_layer = -1
function XiuLuoTaskView:Flush()
	GlobalTimerQuest:CancelQuest(self.boss_countdown)
	local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	local max_layer = KuaFuXiuLuoTowerData.Instance:GetMaxLayer()
	local history_max_layer = KuaFuXiuLuoTowerData.Instance:GetHistoryMaxLayer()
	local boss_num = KuaFuXiuLuoTowerData.Instance:GetBossNum()
	local kill_count = KuaFuXiuLuoTowerData.Instance:GetCurrentLayerKillCount()
	local kill_role_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount()

	local kill_one_honor = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].Kill_rongyao
	self.node_list["TxtKillOneHonor"].text.text = string.format(Language.Honorhalls.SkillRewardTxt[1], 1, kill_one_honor)
	local all_honor = kill_role_count * kill_one_honor
	all_honor = all_honor > 2000 and 2000 or all_honor
	self.node_list["TxtCurKillHonor"].text.text = string.format(Language.Honorhalls.SkillRewardTxt[2], all_honor)
	local cur_layer_cfg = KuaFuXiuLuoTowerData.Instance:GetLayerCfgByLayer(cu_layer)

	-- self.node_list["NodeReward"]:SetActive(not (history_max_layer >= max_layer))
	self.node_list["Slider"].slider.value = kill_count / cur_layer_cfg.need_kill_count
	self.node_list["TxtScale"].text.text = kill_count.." / "..cur_layer_cfg.need_kill_count


	if boss_num > 0 then
		self.is_boss_die = true
		FuBenCtrl.Instance:ShowMonsterHadFlush(true)
		self.node_list["TxtBossState"].text.text = string.format(Language.XiuLuo.BossState[1], self.boss_name)
	else
		if self.is_boss_die and cu_layer >= 10 then
			self.is_boss_die = false
			if self.node_list["TeamButton"].toggle and self.node_list["TeamButton"].toggle.isActiveAndEnabled then
				self.node_list["TeamButton"].toggle.isOn = true
			end
		end
		FuBenCtrl.Instance:ShowMonsterHadFlush(false)
		local gather_info_list = KuaFuXiuLuoTowerData.Instance:GetGatherInfo()
		if next(gather_info_list) then
			for i = 1, 2 do
				local count = gather_info_list[i] and gather_info_list[i].gather_count or 0
				local gather_id = gather_info_list[i] and gather_info_list[i].gather_id or 0
				local index = KuaFuXiuLuoTowerData.Instance:GetGatherIndex(gather_id)
				if index then
					self.node_list["TxtBoxCount" .. index].text.text = string.format(Language.XiuLuo.BoxCount, count)
				else
					self.node_list["TxtBoxCount" .. index].text.text = string.format(Language.XiuLuo.BoxCount, 0)
				end
			end
		else
			for i = 1,2 do
				self.node_list["TxtBoxCount" .. i].text.text = string.format(Language.XiuLuo.BoxCount, 0)
			end
		end
	end

	self.node_list["TxtLayer"].text.text = string.format(Language.XiuLuo.NowLevel, cu_layer)

	local is_max_layer = cu_layer >= max_layer
	self.node_list["NodeBossReward"]:SetActive(boss_num > 0)
	self.node_list["PanelBox"]:SetActive(boss_num <= 0)
	self.node_list["NodeTasjView1"]:SetActive(not is_max_layer)
	self.node_list["Yitongguan"]:SetActive(is_max_layer)
	self.node_list["NodeTasjView2"]:SetActive(boss_num <= 0)

	if old_layer ~= cu_layer then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	end
	if cu_layer >= max_layer then
		self.node_list["TxtNextLayer"].text.text = string.format(Language.XiuLuo.NowLevel, "")
	elseif old_layer ~= cu_layer then
		self.node_list["TxtNextLayer"].text.text = string.format(Language.XiuLuo.NowLevel, cu_layer + 1)
	end
	local total_kill_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount() or 0
	self.node_list["TxtKillCount"].text.text = total_kill_count
	if boss_num <= 0 then
		local boss_refresh_time = KuaFuXiuLuoTowerData.Instance:GetBossRefreshTime()
		local rest_time = math.floor(boss_refresh_time - TimeCtrl.Instance:GetServerTime())
		if rest_time > 0 then
			FuBenCtrl.Instance:SetMonsterDiffTime(rest_time, 1)
		end
		self.boss_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.BossTimeCountDown, self), 1)
		self:BossTimeCountDown()
	end
	if old_layer < cu_layer then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.XiuLuo.LayerUp, cu_layer))
	elseif old_layer > cu_layer then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.XiuLuo.LayerDown, cu_layer))
	end
	old_layer = cu_layer
end

function XiuLuoTaskView:BossTimeCountDown()
	local boss_refresh_time = KuaFuXiuLuoTowerData.Instance:GetBossRefreshTime()
	local seconds = math.floor(boss_refresh_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		self.node_list["TxtBossState"].text.text = string.format(Language.XiuLuo.BossState[2], TimeUtil.FormatSecond(0, 3))
		GlobalTimerQuest:CancelQuest(self.boss_countdown)
		return
	end

	self.node_list["TxtBossState"].text.text = string.format(Language.XiuLuo.BossState[2], TimeUtil.FormatSecond(seconds, 3))
end

function XiuLuoTaskView:ClickBox(index)
	local data = BOX_ITEM_ID[index]
	TipsCtrl.Instance:OpenItem(data)
end

function XiuLuoTaskView:GatherRewardFlush()
	local gather_reward_list = KuaFuXiuLuoTowerData.Instance:GetGatherBoxReward()
	for k,v in ipairs(self.gather_reward_list) do
		v:SetData(gather_reward_list[k - 1])
		v.root_node:SetActive(gather_reward_list[k - 1] ~= nil)
	end
end

-- function XiuLuoTaskView:BossRewardFlush()
-- 	local reward_list = KuaFuXiuLuoTowerData.Instance:GetBossReward()
-- 	for k,v in ipairs(self.boss_reward_list) do
-- 		v:SetData(reward_list[k - 1])
-- 		v.root_node:SetActive(reward_list[k - 1] ~= nil)
-- 	end
-- end

----------------------积分View----------------------
XiuLuoScoreView = XiuLuoScoreView or BaseClass(BaseRender)

local MAX_REWARD_NUM = 3

function XiuLuoScoreView:__init()
	self.reward_list = {}
	for i = 1, MAX_REWARD_NUM do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end
	self.old_index = -1
end

function XiuLuoScoreView:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function XiuLuoScoreView:GetRewardClick()
	KuaFuXiuLuoTowerCtrl.Instance:SendGetScoreReward()
end

function XiuLuoScoreView:Flush()
	local kill_role_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount()
	local kill_one_honor = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].Kill_rongyao
	local all_honor = kill_role_count * kill_one_honor
	all_honor = all_honor > 2000 and 2000 or all_honor
	local score = KuaFuXiuLuoTowerData.Instance:GetScoreValue()
	self.node_list["TxtScore"].text.text = string.format(Language.XiuLuo.MyScore, all_honor)
	local reward_cfg, index = KuaFuXiuLuoTowerData.Instance:GetCanGetRewardUI()
	reward_cfg = reward_cfg or {}
	if self.old_index ~= index then
		for k,v in pairs(self.reward_list) do
			v:SetData(reward_cfg["reward_item"..k])
			v.root_node:SetActive(reward_cfg["reward_item"..k] ~= nil and reward_cfg["reward_item"..k].item_id ~= 0)
			self.node_list["CellItem" .. k]:SetActive(reward_cfg["reward_item"..k] ~= nil and reward_cfg["reward_item"..k].item_id ~= 0)
		end
	end
	if reward_cfg.score then
		if score >= reward_cfg.score then
			self.node_list["TxtReachScore"].text.text = string.format(Language.XiuLuo.ReachScore, score,reward_cfg.score)
		else
			self.node_list["TxtReachScore"].text.text = string.format(Language.XiuLuo.ReachScoreTwo, score,reward_cfg.score)
		end
	end
	-- self.node_list["TxtRewardAll"]:SetActive(reward_cfg.score == nil)
	local data = KuaFuXiuLuoTowerData.Instance:GetScore()
	local score = KuaFuXiuLuoTowerData.Instance:GetScoreValue()
	if data and score then
		self.node_list["HasGet"]:SetActive(score >= data[#data].score)
	end
	self.old_index = index
end

----------------------胜利面板----------------------
XiuLuoVictoryView = XiuLuoVictoryView or BaseClass(BaseRender)
function XiuLuoVictoryView:__init()

end

function XiuLuoVictoryView:__delete()

end

function XiuLuoVictoryView:Flush()

end

function XiuLuoVictoryView:SetActive(is_show)
	self.root_node:SetActive(is_show)
end

