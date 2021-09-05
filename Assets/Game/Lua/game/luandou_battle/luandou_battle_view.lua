LuanDouBattleView = LuanDouBattleView or BaseClass(BaseView)

local ListNum = 6
local NUM = 4
function LuanDouBattleView:__init()
	self.ui_config = {
		{"uis/views/luandoubattleview_prefab", "LuanDouBattleView"}
	}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.info = {}
end

function LuanDouBattleView:__delete()

end

function LuanDouBattleView:ReleaseCallBack()
	if nil ~= self.count_down_time then
		CountDown.Instance:RemoveCountDown(self.count_down_time)
		self.count_down_time = nil
	end

	if self.boss_flush_timer then
		CountDown.Instance:RemoveCountDown(self.boss_flush_timer)
		self.boss_flush_timer = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	for k,v in pairs(self.all_score_rank_list) do
		v:DeleteMe()
	end
	self.all_score_rank_list = nil

	for k,v in pairs(self.score_rank_list) do
		v:DeleteMe()
	end
	self.score_rank_list = nil

	if self.activity_change_handle then
		GlobalEventSystem:UnBind(self.activity_change_handle)
		self.activity_change_handle = nil
	end

	self.info = nil
	self.all_score_data_list = nil
	self.score_data_list = nil
	FuBenCtrl.Instance:ClearMonsterClickCallBack()
end

function LuanDouBattleView:LoadCallBack()
	self.info = LuanDouBattleData.Instance:GetRoleInfo()
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OnClickToBoss, self))
	self.node_list["BtnOpenRankList"].button:AddClickListener(BindTool.Bind(self.SetRankListVisable, self))
	self.activity_change_handle = GlobalEventSystem:Bind(OtherEventType.ACTIVITY_CHANGE,BindTool.Bind(self.ActivityChangeCall,self))

	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_LUANDOUBATTLE) then
		self.node_list["BtnOpenRankList"]:SetActive(false)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_LUANDOUBATTLE) then
		self.node_list["BtnOpenRankList"]:SetActive(true)
	end

	self.score_data_list = {}
	self.score_rank_list = {}
	self.all_score_rank_list = {}
	self.all_score_data_list = {}
	local list_simple_delegate_free = self.node_list["ScrollHurtList"].list_simple_delegate
	list_simple_delegate_free.NumberOfCellsDel = BindTool.Bind(self.GetCellNumberHurt, self)
	list_simple_delegate_free.CellRefreshDel = BindTool.Bind(self.CellRefreshHurt, self)


	local list_simple_delegate_free = self.node_list["ScrollScoreList"].list_simple_delegate
	list_simple_delegate_free.NumberOfCellsDel = BindTool.Bind(self.GetCellNumberScore, self)
	list_simple_delegate_free.CellRefreshDel = BindTool.Bind(self.CellRefreshScore, self)
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickToBoss, self))
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self.is_show_boss_tips = true
end


function LuanDouBattleView:GetCellNumberHurt()
	local person_score_data = LuanDouBattleData.Instance:GetJiFenRankInfo()
	if #person_score_data < ListNum then
		return #person_score_data
	else
		return ListNum
	end
end

function LuanDouBattleView:ActivityChangeCall()
	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_LUANDOUBATTLE) then
		self.node_list["BtnOpenRankList"]:SetActive(false)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_LUANDOUBATTLE) then
		self.node_list["BtnOpenRankList"]:SetActive(true)
	end
end

function LuanDouBattleView:PortraitToggleChange(state)
	if self.node_list and self.node_list["PanelInfo"] then
		self.node_list["PanelInfo"]:SetActive(state)
	end
end
-- 个人排名积分
function LuanDouBattleView:CellRefreshHurt(cell, data_index)
	data_index = data_index + 1
	local person_score_rank_cell = self.score_rank_list[cell]
	if nil == person_score_rank_cell then
		person_score_rank_cell = PersonScoreRankCell.New(cell.gameObject)
		self.score_rank_list[cell] = person_score_rank_cell
	end

	local person_score_data = LuanDouBattleData.Instance:GetJiFenRankInfo()
	if person_score_data[data_index] then
		self.score_data_list[data_index] = person_score_data[data_index]
	end
	local data = self.score_data_list[data_index]

	person_score_rank_cell:SetData(data_index, data)
end

function LuanDouBattleView:GetCellNumberScore()
	local all_score_data = LuanDouBattleData.Instance:GetAllJiFenRankInfo()
	if #all_score_data < ListNum then
		return #all_score_data
	else
		return ListNum
	end
end

-- 总排名积分
function LuanDouBattleView:CellRefreshScore(cell, data_index)
	data_index = data_index + 1
	local all_score_rank_cell = self.all_score_rank_list[cell]
	if nil == all_score_rank_cell then
		all_score_rank_cell = AllScoreRankCell.New(cell.gameObject)
		self.all_score_rank_list[cell] = all_score_rank_cell
	end

	local all_score_data = LuanDouBattleData.Instance:GetAllJiFenRankInfo()
	if all_score_data[data_index] then
		self.all_score_data_list[data_index] = all_score_data[data_index]
	end

	local data = self.all_score_data_list[data_index]
	all_score_rank_cell:SetData(data_index, data)
end

function LuanDouBattleView:FlushRoleInfo()
	if self.info and self:IsOpen() then
		-- self.node_list["TxtRound"].text.text = string.format(Language.LuanDouBattle.Rank2, self.info.turn) 
		self.node_list["NextTime"].text.text = string.format(Language.LuanDouBattle.RankTime, self.info.turn) 
		self.node_list["TxtHp"].text.text = self.info.boss_hp_per .. "%"
		if self.info.boss_hp_per <= 0 then
			FuBenCtrl.Instance:SetBossTips(false)
			FuBenCtrl.Instance:SetBossInfo(true)
			self.node_list["BtnOpenRankList"]:SetActive(false)
			self.node_list["ImgBgText"]:SetActive(true)
			if nil == self.boss_flush_timer then
				local function diff_time_func(elapse_time, total_time2)
					local left_time = math.floor(total_time2 - elapse_time + 0.5)
					local the_time_text = TimeUtil.FormatSecond(left_time, 7)
					if the_time_text then
						if self.node_list and self.node_list["TxtBossTime"] then
							self.node_list["TxtBossTime"].text.text = the_time_text
						end
					end
					if (total_time2 - elapse_time) <= 0 then
						if self.boss_flush_timer then
							CountDown.Instance:RemoveCountDown(self.boss_flush_timer)
							self.boss_flush_timer = nil
						end
						-- local data = LuanDouBattleData.Instance:GetAllRankReward()
						-- LuanDouBattleCtrl.Instance:ShowLuanDouRewardTips(data)
					end
				end
				self.boss_flush_timer = CountDown.Instance:AddCountDown(self.info.next_redistribute_time - TimeCtrl.Instance:GetServerTime(), 
				1, diff_time_func)
			end
			self.is_show_boss_tips = true
		else
			FuBenCtrl.Instance:SetBossInfo(false)
			self.node_list["BtnOpenRankList"]:SetActive(true)
			self.node_list["ImgBgText"]:SetActive(false)
			if self.is_show_boss_tips == true then
				FuBenCtrl.Instance:SetBossTips(true)
			end
			if self.boss_flush_timer then
				CountDown.Instance:RemoveCountDown(self.boss_flush_timer)
				self.boss_flush_timer = nil
			end
		end
		self.node_list["TxtSelfScore"].text.text = self.info.score
		self.node_list["TxtSelfScoreRank"].text.text = string.format(Language.LuanDouBattle.CurRank, (self.info.rank + 1))
	end
	if self:IsOpen() then
		local total_info = LuanDouBattleData.Instance:GetRoleInfo()
		if total_info then
			if total_info.total_rank then
				self.node_list["TxtSelfScoreRank1"].text.text = string.format(Language.LuanDouBattle.CurRank, (total_info.total_rank + 1))
			else
				self.node_list["TxtSelfScoreRank1"].text.text = string.format(Language.LuanDouBattle.NoRank)
			end
			self.node_list["TxtSelfScore1"].text.text = total_info.total_score
		end
	end
end

function LuanDouBattleView:SetRankListVisable(is_show)
	LuanDouBattleCtrl.Instance:OpenLuanDouHurtRank()
end

function LuanDouBattleView:OpenCallBack()
	self:Flush()
end

function LuanDouBattleView:FlushRoundTime()
	if nil == self.info or nil == self.info.next_redistribute_time then return end
	if nil == self.count_down_time then
		local function diff_time_func(elapse_time, total_time2)
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local the_time_text = TimeUtil.FormatSecond(left_time, 7)
			if the_time_text then
				if self.node_list and self.node_list["TxtTime"] then
					self.node_list["TxtTime"].text.text = the_time_text
				end
			end
			if (total_time2 - elapse_time) <= 0 then
				if self.count_down_time then
					CountDown.Instance:RemoveCountDown(self.count_down_time)
					self.count_down_time = nil
				end
				-- local data = LuanDouBattleData.Instance:GetAllRankReward()
				-- LuanDouBattleCtrl.Instance:ShowLuanDouRewardTips(data)
			end
		end
		self.count_down_time = CountDown.Instance:AddCountDown(self.info.next_redistribute_time - TimeCtrl.Instance:GetServerTime() + 0.5, 
			1, diff_time_func)
	end
end


function LuanDouBattleView:OnClickToBoss()
	local x, y = LuanDouBattleData.Instance:GetBossPos()
	local other_cfg = LuanDouBattleData.Instance:GetOtherConfig()
	local monster_id = 0
	if other_cfg and other_cfg.boss_id then
		monster_id = other_cfg.boss_id
	end
	local callback = function()
		MoveCache.param1 = monster_id
		GuajiCache.monster_id = monster_id
		MoveCache.end_type = MoveEndType.FightByMonsterId
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 3, 3)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)

	if self.is_show_boss_tips then
		FuBenCtrl.Instance:SetBossTips(false)
	end
	self.is_show_boss_tips = false
	
end


function LuanDouBattleView:OnFlush(params_t)
	for k,v in pairs(params_t) do
		if k == "person_score" then
			if self.node_list["ScrollHurtList"] and self.node_list["ScrollHurtList"].scroller.isActiveAndEnabled then
				self.node_list["ScrollHurtList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		elseif k =="all_score" then
			if self.node_list["ScrollScoreList"] and self.node_list["ScrollScoreList"].scroller.isActiveAndEnabled then
				self.node_list["ScrollScoreList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end
	self:FlushRoleInfo()
	self:FlushRoundTime()
end


-----------------------------------------------------------------------------
------------------------排行ItemRender---------------------------------------
-----------------------------------------------------------------------------
-- 个人积分排行单元
PersonScoreRankCell = PersonScoreRankCell or BaseClass(BaseCell)
function PersonScoreRankCell:__init()

end

function PersonScoreRankCell:__delete()

end

function PersonScoreRankCell:SetData(rank, data)
	if not data then
		return
	end
	self.node_list["TxtName"].text.text = data.user_name
	self.node_list["TxtHurt"].text.text = data.score
	if rank < NUM then
		self.node_list["TxtRank"]:SetActive(false)
		local bundle, asset = ResPath.GetRankIcon(rank)
		self.node_list["ImgRank"].image:LoadSprite(bundle, asset , function()
			self.node_list["ImgRank"].image:SetNativeSize()
		end)
		self.node_list["ImgRank"]:SetActive(true)
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["ImgRank"]:SetActive(false)
		self.node_list["TxtRank"].text.text = rank
	end

end


-- 总积分排行单元
AllScoreRankCell = AllScoreRankCell or BaseClass(BaseCell)
function AllScoreRankCell:__init()

end

function AllScoreRankCell:__delete()

end

function AllScoreRankCell:SetData(rank, data)
	if not data then
		return
	end
	self.node_list["TxtName"].text.text = data.user_name
	self.node_list["TxtScore"].text.text = data.total_score
		if rank < NUM then
		self.node_list["TxtRank"]:SetActive(false)
		local bundle, asset = ResPath.GetRankIcon(rank)
		self.node_list["ImgRank"].image:LoadSprite(bundle, asset , function()
			self.node_list["ImgRank"].image:SetNativeSize()
		end)
		self.node_list["ImgRank"]:SetActive(true)
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["ImgRank"]:SetActive(false)
		self.node_list["TxtRank"].text.text = rank
	end
end