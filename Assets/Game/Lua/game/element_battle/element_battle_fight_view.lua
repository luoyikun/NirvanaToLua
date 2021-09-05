
ElementBattleFightView = ElementBattleFightView or BaseClass(BaseView)

function ElementBattleFightView:__init()
	self.ui_config = {{"uis/views/elementbattle_prefab", "ElementBattleFightView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.active_close = false
	self.fight_info_view = true
end

function ElementBattleFightView:__delete()

end

function ElementBattleFightView:LoadCallBack()
	self.score_info = ElementScoreInfoView.New(self.node_list["ScorePerson"])
	self.score_rank = ElementRankView.New(self.node_list["ScoreRank"])
	self.node_list["BaiYeShow"]:SetActive(false)
	self.node_list["BtnBaiYe"].button:AddClickListener(BindTool.Bind(self.OnClickBaiYe, self))

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))
	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonStates, self))
	end

	self.is_show_remind_bai_ye = true
end

function ElementBattleFightView:ReleaseCallBack()
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end
	if self.score_rank then
		self.score_rank:DeleteMe()
		self.score_rank = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function ElementBattleFightView:OpenCallBack()
	MainUICtrl.Instance:SetViewState(false)

	self:Flush()
end

-- 拜谒按钮监听
function ElementBattleFightView:OnClickBaiYe()
	GuajiCtrl.Instance:StopGuaji()
	GuajiType.IsManualState = false

	-- 寻路，发送拜谒请求
	self.is_show_remind_bai_ye = false
	local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.QUNXIANLUANDOU)
	local pos_x = bai_ye_cfg.worship_pos_x
	local pos_y = bai_ye_cfg.worship_pos_y
	if bai_ye_cfg then
		local main_role = Scene.Instance:GetMainRole()
		local main_pos_x, main_pos_y = main_role:GetLogicPos()
		local distance = GameMath.GetDistance(main_pos_x, main_pos_y, pos_x, pos_y, false)		
		if distance <= 10 * 10 then
			CityCombatCtrl.Instance:SendBaiYeReq()
		else
			MoveCache.end_type = MoveEndType.BAIYE
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_x + math.floor(math.random(-8, 8)), pos_y + math.floor(math.random(-8, 8)), 0, 0)
		end
	 end
end

-- 设置拜谒计时器
function ElementBattleFightView:SetBaiYeDownTime()
	local complere_fun = function()
		FuBenCtrl.Instance:SendExitFBReq()
		if nil ~= self.down_time then
			CountDown.Instance:RemoveCountDown(self.down_time)
			self.down_time = nil
		end
	end
	if nil == self.down_time then
		local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.QUNXIANLUANDOU)
		local remaining_time = bai_ye_cfg.worship_time
		self.down_time = CountDown.Instance:AddCountDown(remaining_time, 1, function(elapse_time, total_time)
			local remaining_time = math.floor(total_time - elapse_time)
			if self.node_list then
				self.node_list["TextDownTime"].text.text = TimeUtil.FormatSecond(remaining_time, 2)
			end
		end, complere_fun)
	end
end

-- 设置拜谒气泡提示框倒计时
function ElementBattleFightView:SetRemindBubbleActive()
	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end

	self.remind_bubble_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		if self.node_list["RemindBaiYe"] then
			self.node_list["RemindBaiYe"]:SetActive(false)
		end
	end, 5)
end

function ElementBattleFightView:GetIsBaiYe()
	return nil ~= self.down_time
end

-- 刷新拜谒按钮CD
function ElementBattleFightView:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
	self.node_list["CDText"].text.text = ""
	self.node_list["CDMask"].image.fillAmount = 0

	local complere_fun = function()
		self.node_list["CDText"].text.text = ""
		self.node_list["CDMask"].image.fillAmount = 0
	end

	if bai_ye_info.next_worship_timestamp > 0 then
		if nil ~= self.bai_ye_cd then
			CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
			self.bai_ye_cd = nil
		end
		
		local remaining_time = (bai_ye_info.next_worship_timestamp - TimeCtrl.Instance:GetServerTime())
		self.bai_ye_cd = CountDown.Instance:AddCountDown(remaining_time,0.05, function(elapse_time, total_time)
			local daiff_value = math.ceil(total_time - elapse_time)
			if self.node_list then
				self.node_list["CDText"].text.text = daiff_value
				self.node_list["CDMask"].image.fillAmount = (total_time - elapse_time) / bai_ye_cfg.worship_click_cd
				if daiff_value <= 0 then
					self.node_list["CDText"].text.text = ""
					self.node_list["CDMask"].image.fillAmount = 0
					if nil ~= self.bai_ye_cd then
						CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
						self.bai_ye_cd = nil
					end
				end
			end
		end, complere_fun)
	end
end

function ElementBattleFightView:CloseCallBack()
	MainUICtrl.Instance:SetViewState(true)

	if self.down_time then
		CountDown.Instance:RemoveCountDown(self.down_time)
		self.down_time = nil
	end
	if self.bai_ye_cd then
		CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
		self.bai_ye_cd = nil
	end

	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end
end

function ElementBattleFightView:MianUIOpenComlete()
	MainUICtrl.Instance:SetViewState(false)
	self:Flush()
end

function ElementBattleFightView:SwitchButtonStates(enable)
	self.node_list["PanelTrackInfo"]:SetActive(enable)
end

function ElementBattleFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "rank" then
			self.score_rank:Flush()
		elseif k == "info" then
			self.score_info:Flush()
		elseif k == "bai_ye" then
			local fu_ben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
			fu_ben_icon_view:SetDownTimeActive(false)
			self.node_list["BaiYeShow"]:SetActive(true)
			local bai_ye_info = CityCombatData.Instance:GetBaiYeInfo()
			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.QUNXIANLUANDOU)
			self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times)
			if bai_ye_info and next(bai_ye_info) and bai_ye_cfg then
				self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times - bai_ye_info.worship_times)
				self.node_list["RemindBaiYe"]:SetActive(self.is_show_remind_bai_ye)
				self:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
			end
		else
			self.score_rank:Flush()
			self.score_info:Flush()
		end
	end
end

----------------------任务View----------------------
ElementScoreInfoView = ElementScoreInfoView or BaseClass(BaseRender)
function ElementScoreInfoView:__init()
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["Reward" .. i])
	end

	self:Flush()
end

function ElementScoreInfoView:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function ElementScoreInfoView:OnFlush()
	local baseinfo = ElementBattleData.Instance:GetBaseInfo()
	self.node_list["TxtKill"].text.text = string.format(Language.ElementBattle.KillTips, baseinfo.kills or 0)
	local rolejifen = ElementBattleData.Instance:GetRoleScore()
	self.node_list["TxtMyScore"].text.text = string.format(Language.ElementBattle.MyScore, rolejifen)

	local max_need_score = ElementBattleData.Instance:GetRewardMaxNeedScoreMin()
	if max_need_score <= rolejifen then
		self.node_list["ImgHasGet"]:SetActive(true)
	end

	local nextconfig = ElementBattleData.Instance:GetNextHonorForScore(rolejifen)
	if nextconfig then
		if rolejifen >= nextconfig.need_score_min then
			self.node_list["TxtReward"].text.text = string.format(Language.Activity.JiFenToRongYu, rolejifen, nextconfig.need_score_min)
		else
			self.node_list["TxtReward"].text.text = string.format(Language.Activity.JiFenToRongYuTwo, rolejifen, nextconfig.need_score_min)
		end
		for k,v in pairs(self.reward_list) do
			v.root_node:SetActive(nextconfig.reward_item[k - 1] ~= nil)
			v:SetData(nextconfig.reward_item[k - 1])
		end
	end
	local sideinfo = ElementBattleData.Instance:GetSideInfo()
	local cfg = ElementBattleData.Instance:GetCfg()
	local pos_cfg = {} 
	if cfg then
		pos_cfg = cfg.relive_pos
	end
	if sideinfo.scores then
		for k,v in pairs(sideinfo.scores) do
			self.node_list["TxtRank" .. k].text.text = string.format(Language.ElementBattle.RoleColorScore, CAMP_COLOR[0], k)--要求改成白色
			self.node_list["TxtDamage" .. k].text.text = v.score--string.format(Language.ElementBattle.RoleColorScore, CAMP_COLOR[0], v.score)
			self.node_list["TxtName" .. k].text.text = string.format(Language.ElementBattle.RoleColorScore, CAMP_COLOR[0], pos_cfg[v.side + 1].side_name)
		end
	end
end

----------------------积分View----------------------
ElementRankView = ElementRankView or BaseClass(BaseRender)
function ElementRankView:__init()
	-- 获取控件
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function ElementRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function ElementRankView:BagGetNumberOfCells()
	local data_list = ElementBattleData.Instance:GetRankList() or {}
	return #data_list
end

function ElementRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = ElementRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	local data_list = ElementBattleData.Instance:GetRankList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	-- else
	-- 	item:SetData({name = "--", score = "--"})
	end
end

function ElementRankView:Flush()
	if self.node_list["ListView"] and self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	local rolejifen = ElementBattleData.Instance:GetRoleScore()
	local my_rank = ElementBattleData.Instance:GetMyRankPos()
	local rank = my_rank <= 0 and Language.Common.NoRank or my_rank
	self.node_list["MyRank"].text.text = string.format(Language.ElementBattle.MyRankTip, rank)
	self.node_list["MyScore"].text.text = string.format(Language.ElementBattle.MyScore, rolejifen)
end

ElementRankItem = ElementRankItem or BaseClass(BaseRender)

function ElementRankItem:__init()

end

function ElementRankItem:SetIndex(index)
	self.node_list["TxtRank"].text.text = index
	if index <= 3 then
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["Rankindex"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(index)
		self.node_list["Rankindex"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["Rankindex"]:SetActive(false)
	end
end

function ElementRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function ElementRankItem:Flush()
	if nil == self.data then
		return
	end
	local color = nil
	if self.data.side == 0 then
		color = TEXT_COLOR.BLUE
	elseif self.data.side == 1 then
		color = TEXT_COLOR.RED
	elseif self.data.side == 2 then
		color = TEXT_COLOR.GREEN
	end
	color = color or TEXT_COLOR.WHITE

	self.node_list["TxtName"].text.text = ToColorStr(self.data.name, color)
	self.node_list["TxtDamage"].text.text = self.data.score
end
