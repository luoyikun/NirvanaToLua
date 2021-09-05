ZhengBaoMiJingView = ZhengBaoMiJingView or BaseClass(BaseRender)
local TWEEN_TIME = 0.5
function ZhengBaoMiJingView:LoadCallBack()
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		table.insert(self.item_list, item)
	end
	self.open_day_list = {}
	self.node_list["BtnRiZhi"].button:AddClickListener(BindTool.Bind(self.ClickRiZhi, self))
	self.node_list["BtnRongyu"].button:AddClickListener(BindTool.Bind(self.ClickRongYu, self))
	self.node_list["BtnEnterAct"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	for i = 1, 3 do
		self.node_list["TuanZhanTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
	end
end

function ZhengBaoMiJingView:ClickRiZhi()
	TipsCtrl.Instance:ShowKFRecordView()
end
function ZhengBaoMiJingView:ClickRongYu()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
end
function ZhengBaoMiJingView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function ZhengBaoMiJingView:ClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end
	CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)
end

function ZhengBaoMiJingView:ItemClick(index)
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if nil == act_info or nil == act_info["reward_item" .. index] then
		return
	end
	
	local item_cfg, _ = ItemData.Instance:GetItemConfig(act_info["reward_item" .. index].item_id)

	local item_callback = function ()
		if self.item_list[index] then
			self.item_list[index]:ShowHighLight(false)
		end
	end
	if nil ~= item_cfg then
		if self.item_list[index] then
			self.item_list[index]:ShowHighLight(true)
		end
		TipsCtrl.Instance:OpenItem(act_info["reward_item" .. index],nil ,nil, item_callback)
	end
end


function ZhengBaoMiJingView:SetRewardState(act_info)
	if nil ~= act_info and nil ~= act_info.reward_item1 then
		local tab_list = Split(act_info.item_label, ":")
		for k, v in ipairs(self.item_list) do
			if tab_list[k] then
				tab_list[k] = tonumber(tab_list[k])
			end
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				v.root_node:SetActive(true)
				v:SetShowVitualOrangeEffect(true)
				v:SetData(act_info["reward_item" .. k])
				if tab_list[k]then
					v:SetShowZhuanShu(tab_list[k] == 1)
				end
			else
				v:SetInteractable(false)
				v.root_node:SetActive(false)
			end
		end
	end
end

function ZhengBaoMiJingView:GetChineseWeek(act_info)
	local open_time_tbl = Split(act_info.open_time, "|")
	local end_time_tbl = Split(act_info.end_time, "|")

	local time_des = ""

	if #self.open_day_list >= 7 then
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
		else
			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
		end
	else
		local week_str = ""
		for k, v in ipairs(self.open_day_list) do
			local day = tonumber(v)
			if k == 1 then
				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
			else
				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
			end
		end
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", week_str, time_str)
		else
			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
		end
	end
	return time_des
end

function ZhengBaoMiJingView:__delete()
	for _,v in pairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}
	self.open_day_list = {}
	self.act_id = nil
	if TitleData.Instance ~= nil then
		for i = 1, 3 do
			TitleData.Instance:ReleaseTitleEff(self.node_list["TuanZhanTitle" .. i])
		end
		TitleData.Instance:ReleaseTitleEff(self.node_list["LeftTitleImage"])
	end
end

function ZhengBaoMiJingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TuanZhanPlane"], Vector3(420, 301, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftTitle"], Vector3(420, 324, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(150, 526, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LuanDouPlane"], Vector3(1, 713, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Type2"], Vector3(309, -206, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


function ZhengBaoMiJingView:ShowIndex(act_id)
	self.act_id = act_id
	self:Flush()
end

function ZhengBaoMiJingView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	-- self.open_day_list = Split(act_info.open_day, ":")
	self.open_day_list = Split(act_info.open_day, ":")
	self:SetRewardState(act_info)
	self:SetTitleTime(act_info)
	if self.act_id == ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT then
		self:SetKFZhenBaoMiJingTower()
	else
		self.node_list["LeftBg"]:SetActive(false)
		self.node_list["LeftTitle"]:SetActive(false)
	end
	if self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		self:SetTuanZhanPlane()
	else
		self.node_list["TuanZhanPlane"]:SetActive(false)
	end
	if self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE or ACTIVITY_TYPE.LUANDOUBATTLE then
		self:SetLuanDouZhanChangPlane()
		self:SetLuanDouBattlePlane()
	else
		self.node_list["TuanZhanPlane"]:SetActive(false)
		self.node_list["LuanDouPlane"]:SetActive(false)
	end

	
	local min_level = tonumber(act_info.min_level)
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""
	-- time_des = self:GetChineseWeek(act_info)
	time_des = ActivityData.Instance:GetLimintOpenDayTextByActId(self.act_id, act_info)
	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	self.node_list["TxtExplain"].text.text = detailexplain
	local is_open = ActivityData.Instance:GetActivityIsOpen(self.act_id)
	local act_is_ready = ActivityData.Instance:GetActivityIsReady(self.act_id)

	if is_open or act_is_ready then
		self.node_list["TxtBtnEnterAct"].text.text = Language.Marriage.EnterDes
	else
		self.node_list["TxtBtnEnterAct"].text.text = Language.Guild.HasNoOpen
	end
	UI:SetButtonEnabled(self.node_list["BtnEnterAct"], is_open or act_is_ready)
end

function ZhengBaoMiJingView:SetKFZhenBaoMiJingTower()
	self.node_list["LeftBg"]:SetActive(true)
	self.node_list["LeftTitle"]:SetActive(true)
	local data = ActivityData.Instance:GetClockActivityByID(self.act_id)
	self.node_list["LeftTitleImage"].image:LoadSprite(ResPath.GetTitleIcon(data.title_id))
	TitleData.Instance:LoadTitleEff(self.node_list["LeftTitleImage"], data.title_id, true)
end

--活动时间
function ZhengBaoMiJingView:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) or ActivityData.Instance:GetActivityIsReady(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		for _, v in ipairs(self.open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				end
				break
			end
		end
	end
	self.node_list["TxtTitleTime"].text.text = time_str
end


function ZhengBaoMiJingView:SetTuanZhanPlane()
	if self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		local title_id = 0
		local other_cfg = KuaFuTuanZhanData.Instance:GetNightFightOtherCfg()
		self.node_list["TuanZhanPlane"]:SetActive(true)
		for i = 1, 3 do
			if i == 1 then
				title_id = other_cfg.title_first
			elseif i == 2 then
				title_id = other_cfg.title_second
			else
				title_id = other_cfg.title_third
			end
			local bundle, name = "uis/icons/title/3000_atlas", "Title_" .. title_id
			self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, name, function()
				self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_id, true)
		end
	end
end

function ZhengBaoMiJingView:SetLuanDouZhanChangPlane()
	if self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		self.node_list["TuanZhanPlane"]:SetActive(true)
		local title_cfg = LuanDouBattleData.Instance:GetTitleCfg()
		for i = 1,3 do
			local res_id = Split(title_cfg[i].title_show, ",")
			local bundle, asset = res_id[1], res_id[2]
			self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, asset, function()
				self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_cfg[i].title_id, true)
		end
	end
end

function ZhengBaoMiJingView:SetLuanDouBattlePlane()
	if self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE then
		self.node_list["LuanDouPlane"]:SetActive(true)
		local score_type = EXCHANGE_PRICE_TYPE.RONGYAO
		local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
		self.node_list["TxtExchangeRY"].text.text = string.format(Language.Activity.RongYao, nume or 0)
	else
		self.node_list["LuanDouPlane"]:SetActive(false)
	end
end

function ZhengBaoMiJingView:ClickTitle(index)
	local title_cfg = {}
	if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		title_cfg = ActivityData.Instance:GetXianMoItemCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.CHAOSWAR then
		title_cfg = YiZhanDaoDiData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		title_cfg = LuanDouBattleData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		local item_id = 0
		local other_cfg = KuaFuTuanZhanData.Instance:GetNightFightOtherCfg()
		if index == 1 then
			item_id = other_cfg.title_first_good
		elseif index == 2 then
			item_id = other_cfg.title_second_good
		elseif index == 3 then
			item_id = other_cfg.title_third_good
		end
		if item_id > 0 then
			local data = {item_id = item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING then
		title_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
		if title_cfg then
			local data = {item_id = title_cfg.rank_title_item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		title_cfg = KuaFuXiuLuoTowerData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end
end