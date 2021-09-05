GoPawnContentView = GoPawnContentView or BaseClass(BaseRender)

function GoPawnContentView:__init(instance)
	GoPawnContentView.Instance = self

	self.item_list = {}
	self.move_obj = self.node_list["move_eff_obj"]
	-- 初始化人物形象
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.move_obj.ui3d_display)
	self.move_obj.ui3d_display:SetRotation(Vector3(0, 210, 0))

	self:SetDisplayInfo()
	self.box_icon_list = {}
	self.show_open_item = {}
	self.item_cells = {}
	for i = 1, 25 do
		self.item_list[i] = {}
		self.item_list[i].item_pos = self.node_list["grid_" .. i]

		if i < 25 then
			self.item_list[i].item_box_active = self.node_list["BtnOpen" .. i]
		end

		if i < 24 then
			self.box_icon_list[i] = self.node_list["BtnOpen" .. i]
			self.show_open_item[i] = self.node_list["OpenItem" .. i]
			self.item_cells[i] = ItemCell.New()
			self.item_cells[i]:SetInstanceParent(self.node_list["OpenItem" .. i])
		end
	end

	for i = 1, 24 do
		self.node_list["BtnOpen" .. i].button:AddClickListener(BindTool.Bind(self.OnGridClick, self, i))
	end

	self.show_crap_list = {}
	for i = 1, 6 do
		self.show_crap_list[i] = self.node_list["crap_show_" .. i]
	end

	self.show_re_item = {}
	self.re_item = {}
	self.re_item_list = {}
	for i = 1, 4 do
		self.re_item[i] = self.node_list["ReItem" .. i]
		self.re_item_list[i] = ItemCell.New()
		self.re_item_list[i]:SetInstanceParent(self.re_item[i])
		self.show_re_item[i] = self.node_list["ReItem" .. i]
	end

	self.node_list["StartBtn"].button:AddClickListener(BindTool.Bind(self.OnStartClick, self))
	self.node_list["QuestionBtn"].button:AddClickListener(BindTool.Bind(self.OnQuestionClick, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.TipsCloseOnClick, self))
	self.node_list["reset_btn"].button:AddClickListener(BindTool.Bind(self.ResetBtnClick, self))

	self.node_list["TipsFrame"]:SetActive(false)

	self.current_index = 1
	self.animator = self.node_list["turn_craps_list"].animator
	YuLeCtrl.Instance:SendMoveChessFreeInfo()
	
	self.is_init = true
	self.is_use_cash_coupon = 0  --默认不使用代金券
	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id), item_id)
	self.node_list["JinQuanNum"].text.text = string.format(Language.GoPawnContenView.Ticket, item_count)

	local other_cfg = GoPawnData.Instance:GetOtherCfg()
	self.node_list["Change_Sign"].text.text = string.format(Language.GoPawnContenView.DiXiao, math.floor(other_cfg.consume_gold_count / other_cfg.item1.num))
	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()
	-- 单次调用某些功能
	self.asgin_flag = false
	self:ShowRemainRestRips()
	self.node_list["GetItemAni"]:SetActive(false)

	self.get_item = ItemCell.New()
	self.get_item:SetInstanceParent(self.node_list["GetItemAni"])
end

function GoPawnContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if nil ~= self.get_item then
		self.get_item:DeleteMe()
		self.get_item = nil
	end

	if self.reward_item_cells then
		self.reward_item_cells:DeleteMe()
		self.reward_item_cells = nil
	end

	for k,v in pairs(self.item_cells) do
		if nil ~= v then
			v:DeleteMe()
			v = nil
		end
	end

	for k,v in pairs(self.re_item_list) do
		if nil ~= v then
			v:DeleteMe()
			v = nil
		end
	end
end

function GoPawnContentView:SetDisplayInfo()
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetMainAsset(ResPath.GetRoleModel(main_role.role_res_id))
end

function GoPawnContentView:GuildGopwan()

end

function GoPawnContentView:MoveCrap(number)
	-- 人物跑起来
	self.role_model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	local loop_tweener = self.move_obj.loop_tweener
	if loop_tweener ~= nil then
		loop_tweener:Play()
	end
	timer = number * 0.5
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.move_obj
		local path = {}
		local the_first = self.current_index - number
		local the_end = self.current_index
		if the_end >= 25 then
			the_end = 25
			timer = (the_end - (self.current_index - number)) * 0.5
		end

		for i = the_first, the_end do
			if nil ~= self.item_list[i] and nil ~= self.item_list[i].item_pos and nil ~= self.item_list[i].item_pos.transform then
				local pos = self.item_list[i].item_pos.transform.position
				table.insert(path, pos)
			end
		end

		local tweener = item.transform:DOPath(
			path,
			timer,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		self.move_obj.loop_tweener = tweener
	end, 0)
end

-- 调整人物角度
function GoPawnContentView:SetRoleModleFanXiang(step)
	local angle = 10
	if step < 2 then
		angle = 340
	elseif step < 4 then
		angle = 45
	elseif step < 6 then
		angle = 320
	elseif step < 11 then
		angle = 230
	elseif step < 14 then
		angle = 320
	elseif step < 16 then
		angle = 45
	elseif step < 17 then
		angle = 100
	elseif step < 19 then
		angle = 45
	elseif step < 22 then
		angle = 320
	elseif step < 25 then
		angle = 230
	else
		angle = 10
	end
	self.move_obj.ui3d_display:SetRotation(Vector3(0, angle, 0))
end

function GoPawnContentView:OnStartClick()
	if ItemData.Instance:GetEmptyNum() < 6  then
		TipsCtrl.Instance:ShowSystemMsg(Language.GoPawnContenView.BeiNumBuZu)
		return
	end

	local func = function()
		self:GoToChallenge()
	end

	local free_times = GoPawnData.Instance:GetChessInfo().move_chess_free_times
	local cfg = GoPawnData.Instance:GetOtherCfg()
	if free_times < cfg.free_times_per_day then --如果有免费次数
		self:GoToChallenge()
		return
	end
	local tips_text = string.format(Language.GoPawnContenView.TipsText,cfg.consume_gold_count)
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(cfg.item1.item_id),cfg.item1.item_id)
	local ba_wang_quan_cfg = cfg.item1.num
	if item_count >= ba_wang_quan_cfg then
		local tip_text_2 = string.format(Language.GoPawnContenView.TipsText2,cfg.consume_gold_count,cfg.item1.num)
		tip_text_2 = ToColorStr(tip_text_2, COLOR.YELLOW)
		self.is_use_cash_coupon = 1
		TipsCtrl.Instance:ShowCommonAutoView("use_quan1",tips_text .. tip_text_2, func, nil, nil, nil, nil, nil, true, true)
	elseif item_count > 0  then
		local need_gold_count = cfg.consume_gold_count - (cfg.consume_gold_count / cfg.item1.num * item_count)
		local tip_text_2 = string.format(Language.GoPawnContenView.TipsText2,need_gold_count,item_count)
		tip_text_2 = ToColorStr(tip_text_2, COLOR.YELLOW)
		self.is_use_cash_coupon = 1
		TipsCtrl.Instance:ShowCommonAutoView("use_quan2",tips_text .. tip_text_2, func, nil, nil, nil, nil, nil, true, true)

	else
		self.is_use_cash_coupon = 0
		TipsCtrl.Instance:ShowCommonAutoView("use_gold1",tips_text, func, nil, nil, nil, nil, nil, true, true)
	end
end

function GoPawnContentView:GoToChallenge()
	if self.current_index >= 25 then
		return
	end
	local cfg = GoPawnData.Instance:GetOtherCfg()
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(cfg.item1.item_id),cfg.item1.item_id)
	local free_times = GoPawnData.Instance:GetChessInfo().move_chess_free_times
	local price = cfg.consume_gold_count
	local ba_wang_quan_cfg = cfg.item1.num
	local need_gold = price - ((price / ba_wang_quan_cfg) * item_count)
	if free_times == cfg.free_times_per_day and GameVoManager.Instance:GetMainRoleVo().gold < need_gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	self.node_list["turn_craps_list"]:SetActive(true)
	self.node_list["Block"]:SetActive(true)
	-- 请求转动骰子
	YuLeCtrl.Instance:SendMoveChessShakeReq(self.is_use_cash_coupon,0)
end

function GoPawnContentView:OnQuestionClick()
	local tips_id = 120 -- 幻境寻宝
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GoPawnContentView:GoRewardOnClick()
	YuLeCtrl.Instance:GetView():OnCloseBtnClick()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

function GoPawnContentView:TipsCloseOnClick()
	self.node_list["TipsFrame"]:SetActive(false)
end
-- 重置投掷骰子次数
function GoPawnContentView:CheckBtnState()
	local move_info = GoPawnData.Instance:GetChessInfo()
	self.node_list["reset_btn"]:SetActive(move_info.move_chess_cur_step >= GO_PAWN_MAX_STEP)
	self.node_list["StartBtn"]:SetActive(move_info.move_chess_cur_step < GO_PAWN_MAX_STEP)

	UI:SetButtonEnabled(self.node_list["reset_btn"], move_info.move_chess_reset_times < 2)
end

function GoPawnContentView:ResetBtnClick()
	local sure_func = function()
		self.current_index = 1
		self.is_init = true
		self.is_show_no_tips = true
		self.is_show_no_tips_2 = true
		YuLeCtrl.Instance:SendMoveChessResetReq()
		self.node_list["ChongzhiTipsFrame"]:SetActive(false)
	end
	local reset_need_gold = GoPawnData.Instance:GetOtherCfg().reset_consume_gold or 30
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, string.format(Language.Common.ResetGoPawnDown,reset_need_gold))
end
-- 通关展示界面
function GoPawnContentView:CheckToShowCompeletedTips()
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_cur_step >= GO_PAWN_MAX_STEP then
		local item_info_list = GoPawnData.Instance:GetMissionCompeleteList()
		local again_call_back = function()
			self:ResetBtnClick()
			self.node_list["ChongzhiTipsFrame"]:SetActive(false)
		end
		TipsCtrl.Instance:ShowMissionCompletedView(item_info_list, GoPawnData.Instance:GetOtherCfg().reset_consume_gold, again_call_back)
	end
end

function GoPawnContentView:CalTime(timer)
	local timer_cal = timer + 0.5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime

		-- 超过最大步数后的操作
		local cha_num = self.current_index - 25
		local dui_num = cha_num * 0.5 + 0.5
		if cha_num > 0 then
			dui_num = cha_num * 0.5 + 0.5
		else
			dui_num = 0.5
		end
		if timer_cal < dui_num then
			if self.asgin_flag then
				-- 人物停下来
				self.role_model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
				self.asgin_flag = false
				-- 展示奖励物品界面
				if self.current_index < 25 then
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_MOVE_CHESS)
				else
					self.node_list["ItemEffectAni"]:SetActive(false)
				end
				self:ShowRemainRestRips()
				self:CheckToShowCompeletedTips()
			end
		end

		if timer_cal < 0 then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.node_list["GetItemAni"]:SetActive(false)
		end

		if timer_cal < -0.5 then
			self.node_list["Block"]:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		end
	end, 0)
end

function GoPawnContentView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
end

--隐藏宝箱
function GoPawnContentView:HideBox(the_first, the_end)
	local current_step = the_first
	self.node_list["ItemEffectAni"]:SetActive(true)
	local item_rewart_list = GoPawnData.Instance:GetStepReward()
	self.timer_quest_hide_box = GlobalTimerQuest:AddRunQuest(function()
		local target_pos_list = {}
		if the_end > 25 then
			the_end = 25
		end
		for i= the_first + 1, the_end do
			if nil ~=  self.item_list[i] and nil ~= self.item_list[i].item_pos and nil ~= self.item_list[i].item_pos.transform then
				target_pos_list[i] = self.item_list[i].item_pos.transform.position
			else
				GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
			end
		end
		local move_pos = nil ~= self.move_obj.transform and self.move_obj.transform.position or Vector3(0, 0, 0)
		if Vector3.Distance(move_pos, target_pos_list[current_step + 1]) < 1.5 then
			self.item_list[current_step].item_box_active:SetActive(false)
			if self.item_cells[current_step] then
				self.item_cells[current_step]:SetActive(false)
			end
			self.get_item_animator = self.node_list["ItemEffectAni"]:GetComponent(typeof(UnityEngine.Animator))
			if self.get_item_animator.isActiveAndEnabled then
				self.get_item_animator:Play("AniItem",0,0)
				self.get_item_animator:SetTrigger("state")
			end
			-- 调整人物角度
			self:SetRoleModleFanXiang(current_step + 1)
			if current_step == the_end - 1 then
				GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
			end

			local d_info = item_rewart_list[(current_step + 1) - the_first]
			if d_info then
				local item_info = ItemData.Instance:GetItemConfig(d_info.item_id)
				local bundle, asset = ResPath.GetItemIcon(item_info.icon_id)
				self.get_item:SetData(d_info)
				self.node_list["GetItemAni"]:SetActive(true)
			end
			current_step = current_step + 1
		end
	end, 0)
end

--转动骰子
function GoPawnContentView:CalTurnCrapsTime()
	local timer_cal = 1
	self.animator:SetTrigger("Turn")
	self.asgin_flag = true
	self.node_list["RoleGoldNum"].text.text = CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold)
	self.cal_turm_craps_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		for i = 1, 6 do
			self.show_crap_list[i]:SetActive(false)
		end
		if timer_cal < 0 then
			self.animator:SetTrigger("Close")

			self.node_list["turn_craps_list"]:SetActive(false)
			local step = GoPawnData.Instance:GetShakePoint()
			self.show_crap_list[step]:SetActive(true)
			self.current_index = self.current_index + step
			self:CalTime(0.5 * step)
			self:MoveCrap(step)
			self:HideBox(self.current_index - step, self.current_index)
			GlobalTimerQuest:CancelQuest(self.cal_turm_craps_time_quest)

		end
	end, 0)
end

function GoPawnContentView:InitCrapsPos(step)
	if self.is_init then
		self.current_index = step + 1
		if self.move_obj.transform and self.item_list[self.current_index].item_pos.transform then
			self.move_obj.transform.position = self.item_list[self.current_index].item_pos.transform.position
		end
		if self.current_index - 1 == 1 then
			self.item_list[self.current_index - 1].item_box_active:SetActive(false)
		else
			for i = 1,self.current_index - 1 do
				self.item_list[i].item_box_active:SetActive(false)
			end
		end
		if self.current_index == 1 then
			for i = 1, 24 do
				self.item_list[i].item_box_active:SetActive(true)
			end
		end
		self.is_init = false
		for i = 1,23 do
			-- 初始化奖励物品
			local ts_reward_list = GoPawnData.Instance:GetTeshuJiangliCfg(i)
			if ts_reward_list and next(ts_reward_list) then
				-- 特殊奖励物品
				self.item_cells[i]:SetData(ts_reward_list)
				self.item_cells[i]:SetActive(true)
				self.show_open_item[i]:SetActive(true)
			else
				if i < 12 then
					local bundle, asset = ResPath.GetGoPawnImg("icon_reward_box_2")
					self.box_icon_list[i].image:LoadSprite(bundle, asset .. ".png")
				else
					local bundle, asset = ResPath.GetGoPawnImg("icon_reward_box_1")
					self.box_icon_list[i].image:LoadSprite(bundle, asset .. ".png")
				end
			end
		end

		-- 隐藏特殊的奖励格子
		for i = 1,self.current_index - 1 do
			if self.item_cells[i] then
				self.item_cells[i]:SetActive(false)
			end
		end

	end
	-- 初始化人物角度
	self:SetRoleModleFanXiang(step + 1)
	local pawn_state = GoPawnData.Instance:GetShakePoint()
	if pawn_state < 1 then
		pawn_state = 1
	end
	self.show_crap_list[pawn_state]:SetActive(true)
	self.node_list["RoleGoldNum"].text.text = CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold)
end

function GoPawnContentView:GetInitState()
	return self.is_init
end

--移除物品回调
function GoPawnContentView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function GoPawnContentView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GoPawnContentView:ItemDataChangeCallback()
	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	self.node_list["JinQuanNum"].text.text = string.format(Language.GoPawnContenView.Ticket, item_count)
end

function GoPawnContentView:FlushRemainText(free_times)
	local cfg = GoPawnData.Instance:GetOtherCfg()
	local need_dimon_count = cfg.consume_gold_count

	local miaoshu = ""
	if cfg.free_times_per_day - free_times > 0 then
		miaoshu = string.format(Language.GoPawnContenView.remain_times,(cfg.free_times_per_day - free_times))
	else
		local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id), item_id)
		if item_count >= cfg.item1.num then
			miaoshu = string.format(Language.GoPawnContenView.ItemTis,cfg.item1.num,item_cfg.name)
		elseif item_count > 0 then
			local need_some_dimon_count = need_dimon_count - need_dimon_count / cfg.item1.num * item_count
			miaoshu = string.format(Language.GoPawnContenView.need_dimon,need_some_dimon_count)
		else
			miaoshu = string.format(Language.GoPawnContenView.need_dimon,need_dimon_count)
		end
	end

	self.node_list["ReMainText"].text.text = miaoshu
end

function GoPawnContentView:SetActiveSlider(exp,value)
end
-- 通过提示剩余挑战次数
function GoPawnContentView:ShowRemainRestRips()
	local go_pawn_data = GoPawnData.Instance
	local move_info = go_pawn_data:GetChessInfo()
	if move_info.move_chess_cur_step == 24 then
		local remain_reset_num = go_pawn_data:GetOtherCfg().reset_time_per_day - move_info.move_chess_reset_times
		self.node_list["RemainReset"].text.text = remain_reset_num
		self.node_list["ChongzhiTipsFrame"]:SetActive(true)
		if remain_reset_num > 0 then
			self.node_list["ItemTis"]:SetActive(true)
			self.reward_item_cells = ItemCell.New()
			self.reward_item_cells:SetInstanceParent(self.node_list["ResetItem"])
			local item_info = GoPawnData.Instance:GetMissionCompeleteList()[4]
			if item_info then
				-- 重置的奖励
				local itemId = item_info.item_id
				local libao_list = ItemData.Instance:GetGiftItemList(itemId)
				if libao_list and next(libao_list) then
					-- 礼包奖励
					for k,v in pairs(self.re_item_list) do
						if libao_list[k] then
							v:SetData(libao_list[k])
							self.show_re_item[k]:SetActive(true)
						end
					end
				else
					-- 非礼包奖励
					self.re_item_list[1]:SetData(item_info)
					self.show_re_item[1]:SetActive(true)
				end
			end
		else
			self.node_list["ItemTis"]:SetActive(false)
		end
	end
end

function GoPawnContentView:SetRedPoint(red_point)
end

function GoPawnContentView:FlushRedPoint()
end

function GoPawnContentView:OnGridClick(i)
	local tittle_name = Language.GoPawnContenView.NormalRewardTips
	if i == 24 then
		tittle_name = Language.GoPawnContenView.LastRewardTips
	end
	TipsCtrl.Instance:ShowRewardView(GoPawnData.Instance:GetRewardListByStep(i), tittle_name)
end