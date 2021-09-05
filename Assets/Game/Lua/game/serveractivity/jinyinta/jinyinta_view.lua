JinYinTaView = JinYinTaView or BaseClass(BaseView)

function JinYinTaView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/serveractivity/jinyinta_prefab", "JinYinTaContent"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	
	-- 抽奖类型 
	self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1
	-- 金银塔奖励
	self.jinyinta_reward = {}
	-- 历史抽奖记录
	self.history_reward = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function JinYinTaView:__delete()

end

function JinYinTaView:ReleaseCallBack()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end

	for k, v in pairs(self.jinyinta_reward) do
		v:DeleteMe()
		v = nil 
	end
	self.jinyinta_reward = {}

	for k, v in pairs(self.history_reward) do
		v:DeleteMe()
		v = nil 
	end
	self.history_reward = {}

	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end

	for k,v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function JinYinTaView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	
	BaseView.Open(self)
end

function JinYinTaView:LoadCallBack()
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/serveractivity/jinyinta/images_atlas","liu_dao_xian_tower_word.png")
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.node_list["Name"].text.text = Language.Title.LiuDao
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnOneChou"].button:AddClickListener(BindTool.Bind(self.OneChou, self))
	self.node_list["BtnTenChou"].button:AddClickListener(BindTool.Bind(self.TenChou, self))
	self.node_list["QuestionBtn"].button:AddClickListener(BindTool.Bind(self.TipsClick, self))
	self.node_list["BtnSkip"].toggle:AddClickListener(BindTool.Bind(self.ClickSkip, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.item_cells = {}
	for i = 1, 21 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	-- 金银塔活动奖励
	local param = JinYinTaData.Instance:GetLevelLotteryItemList()
	for k, v in pairs(self.item_cells) do
		self.node_list["Item" .. k]:SetActive(true)
		v:SetActive(true)
		v:SetData(param[k].reward_item)
		local is_rare = param[k].is_rare
		if is_rare then 
			v:ShowGetEffect(is_rare == 1 and true or false)
		end
	end

	-- 抽一次之前的层级
	self.old_level = 1
	self.is_flush  = true
	-- 一次抽的loop次数
	self.play_num  = 3
	self.is_cancel = false

	self:InitRewardListView()
	self:FlushActEndTime()
	self:InitHistoryListView()
end

function JinYinTaView:OpenCallBack()
	-- 请求记录信息
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_QUERY_INFO)
	-- 请求活动信息	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_ACTIVITY_INFO)
	JinYinTaData.Instance:SetPlayNotClick(true)
	JinYinTaData.Instance:SetTenNotClick(true)
end

function JinYinTaView:CloseCallBack()
	JinYinTaData.Instance:SetShowReasureBool(false)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end
 
function JinYinTaView:OnFlush()
	if CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 == self.draw_type then
		self:TurnCell(JinYinTaData.Instance:GetOldLevel())
	else
		TipsCtrl.Instance:ShowTreasureView(self.draw_type)
		self.is_flush = true
		self:FlushCurrLevel()
		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end
		self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
			self:TenTurnCell()
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY)
		end,3)
		
	end
	JinYinTaData.Instance:SetTenNotClick(true)
end

function JinYinTaView:FlushKeyShow()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].jinyinta_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.node_list["TenGoldTxt"]:SetActive(item_num <= 0)
	self.node_list["KeyLable"]:SetActive(item_num > 0)
	self.node_list["PointRedCan"]:SetActive(item_num > 0)

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	--self.node_list["KeyTxt"].text.text = name_str
	local asset, bundle = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgItem"].image:LoadSprite(asset, bundle)
	self.node_list["KeyTxtCount"].text.text = Language.Common.X .. item_num
end

-- 十次抽的cell的效果
function JinYinTaView:TenTurnCell()
	local reward_info = JinYinTaData.Instance:GetLotteryRewardList()
	if reward_info and reward_info[10] then
		for i = 1, 21 do
			-- 重置itemToggle
			self.item_cells[i]:SetToggle(false)
		end
		if self.item_cells[reward_info[10] + 1] then
			self.item_cells[reward_info[10] + 1]:SetToggle(true)
		end
	end
end

-- 一次抽的cell的效果 
function JinYinTaView:TurnCell(currLevel)
	-- 每层的cell数目
	local cell_count = 6 - currLevel
	-- 某层的最大index
	local max_index = self:AddLastNum(cell_count)
	-- 某层的最小index
	local min_index = self:AddLastNum(cell_count) - cell_count + 1
	local temp = min_index
	local turn_num = 1
	local reward_info = JinYinTaData.Instance:GetLotteryRewardList()
	for i = 1, 21 do
		-- 重置itemToggle
		self.item_cells[i]:SetToggle(false)
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end


	if self.is_cancel and reward_info then
		self.item_cells[reward_info[1] + 1]:SetToggle(true)
		TipsCtrl.Instance:ShowTreasureView(self.draw_type)
		self.is_flush = true
		self:FlushCurrLevel()
		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end
		self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY)
			-- 一次抽奖结束，释放一次抽奖的锁
			JinYinTaData.Instance:SetPlayNotClick(true)
		end,1)
	else
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			for i = min_index, max_index do
				if i == temp then
					self.item_cells[i]:SetToggle(true)
					if turn_num == self.play_num then
						if (reward_info[1] == (temp - 1)) then
							if self.time_quest then
								GlobalTimerQuest:CancelQuest(self.time_quest)
								self.time_quest = nil
							end
							TipsCtrl.Instance:ShowTreasureView(self.draw_type)
							self.is_flush = true
							self:FlushCurrLevel()
							if self.show_reward_panel then
								GlobalTimerQuest:CancelQuest(self.show_reward_panel)
								self.show_reward_panel = nil
							end
							self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
								ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY)
								-- 一次抽奖结束，释放一次抽奖的锁
								JinYinTaData.Instance:SetPlayNotClick(true)
							end,1)
						end
					end
				else
					self.item_cells[i]:SetToggle(false)
				end
			end
			temp = temp + 1
			if temp > max_index then
				turn_num = turn_num + 1
				if turn_num > self.play_num then
					if self.time_quest then
						GlobalTimerQuest:CancelQuest(self.time_quest)
						self.time_quest = nil
					end
					TipsCtrl.Instance:ShowTreasureView(self.draw_type)
				end
				temp = min_index
			end
		end,0.2)

	end
end

function JinYinTaView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_JINYINTA)
end

-- 计算某层的最大index
function JinYinTaView:AddLastNum(curr_num)
	if curr_num == 6 then
		return 6
	end
	return curr_num + self:AddLastNum(curr_num + 1)
end

-- 刷新当前层级
function JinYinTaView:FlushCurrLevel()
	local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
	if self.is_flush then
		self.node_list["ImgCurrLevelTxt"].text.text = currLevel + 1
		self.is_flush =  false
	end
	-- 刷新抽奖励需要的钻石数
	local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
	self.node_list["TenChouGoldTxt"].text.text = need_gold * 30
	self.node_list["OneChouGoldTxt"].text.text = need_gold
	self:FlushKeyShow()
end

function JinYinTaView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.node_list["PointRedCanChou"]:SetActive(false)
	self.node_list["OneChouMoney"]:SetActive(true)
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)

	-- 刷新累计抽奖次数
	local buy_count = JinYinTaData.Instance:GetLeiJiRewardNum()

	-- 刷新累计奖励Item
	if self.node_list["LeiJiReward"].scroller.isActiveAndEnabled then
		self.node_list["LeiJiReward"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if JinYinTaData.Instance:GetShowReasureBool() then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD) 
		 JinYinTaData.Instance:SetShowReasureBool(false)
	end

	-- 刷新全服历史抽奖奖励Item
	if self.node_list["HistoryListView"].scroller.isActiveAndEnabled then
		self.node_list["HistoryListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function JinYinTaView:FlushCanNextTime()
	local time_str = JinYinTaData.Instance:GetLeveLotteryMianFei()
	if time_str <= 0  then
		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		self.node_list["PointRedCanChou"]:SetActive(true)
		self.node_list["OneChouMoney"]:SetActive(false)
		self.node_list["CountDownTxt"]:SetActive(false)
		self.node_list["MianFeiTxt"]:SetActive(true)
		self.node_list["MianFeiTxt"].text.text = Language.JinYinTa.KeYiMianFei
		JinYinTaData.Instance:FlushHallRedPoindRemind()
	else
		local value_str = string.format(Language.JinYinTa.MianFeiText, TimeUtil.FormatSecond(time_str))
		self.node_list["MianFeiTxt"]:SetActive(false)
		self.node_list["CountDownTxt"]:SetActive(true)
		self.node_list["CountDownTxt"].text.text = value_str
	end
end


function JinYinTaView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	local time_str = JinYinTaData.Instance:GetActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
	-- 刷新时间间隔，如果剩余时间是大于一天的那就每分钟刷新一次，小于一天的就每秒刷新一次
	local RunTick = time_tab.day >= 1 and 60 or 1
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), RunTick)
end

function JinYinTaView:FlushUpdataActEndTime()
	local time_str = JinYinTaData.Instance:GetActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
	if time_tab.day >= 1 then
		self.node_list["ShenYuTimeTxt"].text.text = string.format(Language.JinYinTa.ActEndTime, time_tab.day, time_tab.hour)
	else
		self.node_list["ShenYuTimeTxt"].text.text = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
	end
	if time_str <= 0  then
		-- 移除计时器
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end
	end
end

function JinYinTaView:OnClickClose()
	local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
	local isClick = JinYinTaData.Instance:GetTenyNotClick()
	if is_onwait then
		self:Close()
	else
		if nil == self.close_timer then
			self.close_timer = GlobalTimerQuest:AddDelayTimer(function ()
				-- 防止没有返回是关闭功能被锁住
				JinYinTaData.Instance:SetPlayNotClick(true)
				JinYinTaData.Instance:SetTenNotClick(true)
			end,5)
		end
	end
	
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA)
	-- 活动未开启
	if not is_open then
		self:Close()
	end
end

-- 抽一次
function JinYinTaView:OneChou()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
		if is_onwait then
			-- local isClick = JinYinTaData.Instance:GetTenyNotClick()
			-- if isClick then
				-- 判断是否有免费次数
				local time_str = JinYinTaData.Instance:GetLeveLotteryMianFei()
				if time_str <= 0  then
					-- 免费直接抽
					self:OneChouAction()
				else
					local sure_func = function()
						self:OneChouAction()
					end
					local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
					-- 刷新抽奖励需要的钻石数
					local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
					local tips_text = string.format(Language.JinYinTa.OneChouNeedGold,need_gold)
					-- 玩家钻石数量
					local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
					if role_gold >= need_gold then
						TipsCtrl.Instance:ShowCommonAutoView("jinyinta_use_gold_1",tips_text, sure_func, nil, nil, nil, nil, nil, true, true)
					else
						TipsCtrl.Instance:ShowLackDiamondView()
					end
				end
			-- end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function JinYinTaView:OneChouAction()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
		if bags_grid_num > 0 then
		-- 抽一次之前的层级
		self.old_level = JinYinTaData.Instance:GetLotteryCurLevel()
		JinYinTaData.Instance:SetOldLevel(self.old_level)
		self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1
		JinYinTaData.Instance:SetPlayNotClick(false)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_ONE)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

-- 抽十次
function JinYinTaView:TenChou()
	local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
	if is_onwait then
		local sure_func = function()
			self:TenChouAction()
		end

		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		local item_id = randact_cfg.other[1].jinyinta_consume_item
		local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		if item_num > 0 then
			sure_func()
			return
		end

		local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
		-- 刷新抽奖励需要的钻石数
		local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
		local ten_gold_str = string.format(Language.JinYinTa.TenChouNeedGold,need_gold * 30)
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold

		-- 有足够的钻石
		if role_gold >= need_gold then
			TipsCtrl.Instance:ShowCommonAutoView("jinyinta_use_gold_10", ten_gold_str, sure_func, nil, nil, nil, nil, nil, true, true)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
		
	end
end

-- 抽十次
function JinYinTaView:TenChouAction()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10
		JinYinTaData.Instance:SetTenNotClick(false)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_THIRTY)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

-- 玩法说明
function JinYinTaView:TipsClick()
	local tips_id = 192 -- 金银塔
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-------------------累计奖励---------------------

function JinYinTaView:InitRewardListView()
	local list_delegate = self.node_list["LeiJiReward"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCurrScoreOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.ScoreRefreshCell, self)
	self.node_list["LeiJiReward"].scroll_rect.vertical = true
	self.node_list["LeiJiReward"].scroll_rect.horizontal = false
end

function JinYinTaView:GetCurrScoreOfCells()
	return #JinYinTaData.Instance:GetLeijiJiangli() or 0
end

function JinYinTaView:ScoreRefreshCell(cell, data_index)
	data_index = data_index + 1
	local score_cell = self.jinyinta_reward[cell]
	if score_cell == nil then
		score_cell = RewardItem.New(cell.gameObject)
		score_cell.root_node.toggle.group = self.node_list["LeiJiReward"].toggle_group
		self.jinyinta_reward[cell] = score_cell
	end
	score_cell:SetClickCallBack(BindTool.Bind(self.ScoreCellClick, self))
	local reward_info = JinYinTaData.Instance:GetLeijiJiangli()
	if reward_info then
		local data = reward_info[data_index]
		score_cell:SetIndex(data_index)
		score_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_score_index then
		score_cell:SetSorceToggleIsOn(true)
	else
		score_cell:SetSorceToggleIsOn(false)
	end
end

function JinYinTaView:ScoreCellClick(cell)
	local index = cell:GetIndex()
	self.select_score_index = index
end

function JinYinTaView:ClickSkip()
	self.is_cancel = not self.is_cancel
end

-- RewardItem 	奖励item
--------------------------------------------------------------------------
RewardItem = RewardItem or BaseClass(BaseCell)

function RewardItem:__init(instance)
	self:RewardObj()
	self.node_list["RewardCell"].toggle:AddClickListener(BindTool.Bind(self.GetLeijiReward, self))
end

function RewardItem:__delete()
	if self.reward_item_cells ~= nil then
		self.reward_item_cells:DeleteMe()
		self.reward_item_cells = nil
	end
end

function RewardItem:RewardObj()
	self.reward_item_cells = ItemCell.New()
	self.reward_item_cells:SetInstanceParent(self.node_list["IconItem"])
end

function RewardItem:OnFlush()
	if not next(self.data) then return end
	local vip_str = string.format(Language.JinYinTa.VipMiaoshu,self.data.vip_level_limit)
	self.reward_item_cells:SetActive(true)
	self.reward_item_cells:SetData(self.data.reward[0])

	self.node_list["IconItem"]:SetActive(true)
	self.node_list["HighLight"]:SetActive(false)
	self.node_list["ItemEffect"]:SetActive(false)

	self.node_list["VipIcon"].text.text = vip_str
	self.node_list["VipIcon"]:SetActive(false)

	-- 是否领取了奖励
	local lottery_bool = JinYinTaData.Instance:IsGetReward(self.data.reward_index)
	if lottery_bool == 1 then
		self.node_list["NameTxt"].text.text = ""
		
		self.node_list["BgGray"]:SetActive(true)
	else
		-- 是否满足领取累计奖励
		local can_lin = JinYinTaData.Instance:CanGetRewardByVipAndCount(self.data.vip_level_limit,self.data.total_times)
		if can_lin then
			self.node_list["HighLight"]:SetActive(true)
			self.node_list["NameTxt"].text.text = Language.JinYinTa.KeLingQu
			self.node_list["ItemEffect"]:SetActive(true)
		else 
			local buy_count = JinYinTaData.Instance:GetLeiJiRewardNum()
			local lingqu = string.format(Language.JinYinTa.LingQuTiaoJian,buy_count,self.data.total_times)
			self.node_list["VipIcon"]:SetActive(true)
			self.node_list["NameTxt"].text.text = lingqu
		end
		self.node_list["BgGray"]:SetActive(false)

	end
end

function RewardItem:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function RewardItem:GetLeijiReward()
	-- 是否满足领取累计奖励
	local can_lin = JinYinTaData.Instance:CanGetRewardByVipAndCount(self.data.vip_level_limit,self.data.total_times)
	if can_lin then
		JinYinTaData.Instance:SetLenRewardLevel(self.data.total_times)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_FETCHE_TOTAL_REWARD,self.data.total_times)
		--JinYinTaData.Instance:SetShowReasureBool(true)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD)
	end
end
function RewardItem:LoadCallBack(uid, raw_img_obj, path)

end

-------------------全服抽奖记录---------------------
function JinYinTaView:InitHistoryListView()
	local list_delegate = self.node_list["HistoryListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHistoryInfoCount, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.HistoryRefreshCell, self)
end

function JinYinTaView:GetHistoryInfoCount()
	return #JinYinTaData.Instance:GetHistoryRewardList() or 0
end

function JinYinTaView:HistoryRefreshCell(cell, data_index)
	data_index = data_index + 1
	local history_cell = self.history_reward[cell]
	if history_cell == nil then
		history_cell = HistoryItem.New(cell.gameObject)
		history_cell.root_node.toggle.group = self.node_list["HistoryListView"].toggle_group
		self.history_reward[cell] = history_cell
	end
	history_cell:SetClickCallBack(BindTool.Bind(self.HistoryCellClick, self))
	local history_reward_info = JinYinTaData.Instance:GetHistoryRewardList()
	if history_reward_info then
		local data = history_reward_info[data_index]
		history_cell:SetIndex(data_index)
		history_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_history_index then
		history_cell:SetSorceToggleIsOn(true)
	else
		history_cell:SetSorceToggleIsOn(false)
	end
end

function JinYinTaView:HistoryCellClick(cell)
	local index = cell:GetIndex()
	self.select_history_index = index
end
--------------------------------------------------------------------------
-- HistoryItem 	历史抽奖item
--------------------------------------------------------------------------
HistoryItem = HistoryItem or BaseClass(BaseCell)

function HistoryItem:__init(instance)

end

function HistoryItem:__delete()
end

-- function HistoryItem:SetIndex(data_index)
-- 	self.data_index = data_index
-- end

function HistoryItem:OnFlush()
	if not next(self.data) then return end
	local name_str = string.format(Language.JinYinTa.NameMiaoShu,self.data.user_name)
	self.node_list["NameText"].text.text = name_str
	local item_info = JinYinTaData.Instance:GetHistoryRewardInfo(self.data.reward_index + 1)
	local name_info = ItemData.Instance:GetItemConfig(item_info.item_id)
	local item_str = string.format(Language.JinYinTa.ChouJiang,ToColorStr(name_info.name, ITEM_COLOR[name_info.color]),item_info.num)


	-- ToColorStr(name_info.name, ITEM_COLOR[name_info.color])

	self.node_list["ActivityText"].text.text = item_str
end

function HistoryItem:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end