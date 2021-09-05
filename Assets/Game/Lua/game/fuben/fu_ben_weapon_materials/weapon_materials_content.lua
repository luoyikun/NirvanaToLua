WeaponMaterialsContent = WeaponMaterialsContent or BaseClass(BaseRender)

function WeaponMaterialsContent:__init()
	self.init_scorller_num = 0
	self.select_layer = 0				-- 当前选择的层
	self.show_tips = true
	self.next_red1_value = false
	self.cur_select_index = 0
	self.slider_value = 0
	self.chapter_value = "" 
	self.name_value = ""
	self.star_num_value = 0
	self.other_cfg = FuBenData.Instance:GetWeaponCfgOther()
	self.item_list = {}
	for i=1, 5 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ItemCell" .. i])
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i] = item_cell
	end

	self:InitMapList()
	self:InitRewardList()

	self.node_list["ButtonAdd"].button:AddClickListener(BindTool.Bind(self.ClickAdd, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["ButtonAuto"].button:AddClickListener(BindTool.Bind(self.OnClickAuto, self))
	self.node_list["ButtonChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickChallenge, self))
	self.node_list["ButtonLeft"].button:AddClickListener(BindTool.Bind2(self.ClickNext, self, 2))
	self.node_list["ButtonRight"].button:AddClickListener(BindTool.Bind2(self.ClickNext, self, 1))
	self.node_list["FBTouziViewIcon"].button:AddClickListener(BindTool.Bind(self.OnClickFBTouzi, self))

end

function WeaponMaterialsContent:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end

	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end
end

function WeaponMaterialsContent:LoadCallBack()
	FuBenCtrl.Instance:SetWeaponRemind()
end

function WeaponMaterialsContent:InitMapList()
	self.map_list = self.node_list["MapList"]
	self.cell_list = {}
	self.scroller = self.map_list.scroller
	self.map_list.scroll_rect.horizontal = false
	local list_delegate = self.map_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMapNumberOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMapCell, self)

	self.node_list["MapList"].scroller:ReloadData(0)
end

function WeaponMaterialsContent:InitRewardList()
	self.reward_list = self.node_list["RewardList"]
	self.reward_cell_list = {}
	local num = self:GetRewardNumberOfCell()
	for i = 1, num do
		local item_cell = SlaghterMapReward.New(self.node_list["reward" .. i])
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickRewardItem, self))
		table.insert(self.reward_cell_list, item_cell)
	end
end
 
 -- 用于功能引导
 function WeaponMaterialsContent:GetChallenge()
 	return self.node_list["ButtonChallenge"], BindTool.Bind(self.OnClickChallenge, self)
 end

function WeaponMaterialsContent:GetMapNumberOfCell()
	return FuBenData.Instance:GetMapListNum() + 1
end

function WeaponMaterialsContent:RefreshMapCell(cell, cell_index)
	cell_index = cell_index
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = SlaughterFBMapChapter.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	item_cell:SetIndex(cell_index+1)
	local data_list = FuBenData.Instance:GetMapList()
	if data_list[cell_index] then
		item_cell:SetClickCallBack(function (data, index)
			self:OnClickMapItem(data, index)
			item_cell:SetFlag(index)
			self:Flush()
		end)
		item_cell:SetData(data_list[cell_index])
	end
end

function WeaponMaterialsContent:OnClickMapItem(chapter, index)
	if chapter == self.cur_select_index then
		self.select_layer = index
	end
end

function WeaponMaterialsContent:OnClickChallenge(index)
	if self.cur_num_value <= 0 then
		self:ClickAdd()
		return
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local need_level = FuBenData.Instance:EquimentNeedLevel(self.cur_select_index, self.select_layer - 1) or 0
	if role_level < need_level then
		local str = string.format(Language.FuBen.WeaponFuBenTip,need_level)
		SysMsgCtrl.Instance:ErrorRemind(str)
		return
	end
	if self.select_layer > 0 then
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_NEQ_FB, self.cur_select_index, self.select_layer - 1)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectLevel)
	end
end

function WeaponMaterialsContent:OnClickAuto()
	if self.cur_num_value <= 0 then
		self:ClickAdd()
		return
	end

	if self.select_layer > 0 then
		if Scene.Instance:GetSceneType() == SceneType.Common then
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_NEQ_FB, self.cur_select_index, self.select_layer - 1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.CurrSceneNoSaoDang)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectLevel)
	end
end

function WeaponMaterialsContent:CloseCallBack()
	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end

	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end
end
 
function WeaponMaterialsContent:GetRewardNumberOfCell()
	return 3
end

function WeaponMaterialsContent:OnClickRewardItem(data, index, can_open, is_open)
	if can_open then
		FuBenCtrl.Instance:SendNeqFBStarRewardReq(data.chapter, index)
		TipsCtrl.Instance:ShowRewardView(data.reward_item, true)
	else
		TipsCtrl.Instance:ShowRewardView(data.reward_item, is_open)
	end
end

function WeaponMaterialsContent:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Bottom"], FuBenTweenData.Down)
	UITween.AlpahShowPanel(self.node_list["Frame"], true)

	local map_list_num = FuBenData.Instance:GetMapListNum() or 0

	local setting_data_key = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.FB_WEAPON_LEVELSWITCH)
	local flag = setting_data_key.item_id
	local weapon_flag_list = bit:d2b(flag)
	if weapon_flag_list[32 - map_list_num] == 0 and map_list_num ~= 0 then
		self.cur_select_index = map_list_num - 1		-- 当前的章节
	else
		self.cur_select_index = map_list_num			-- 当前的章节
	end

	if self.scroller then
		self.scroller:ReloadData(1)
		self.scroller:JumpToDataIndex(self.cur_select_index)
	end
end

function WeaponMaterialsContent:FlushInfo(key)
	if key == "wptimes" then
		self:ConstructData()
	elseif key == "wpreward" then
		self:FLushReward()
		self:ConstructData()
		if self.cur_select_index + 1 <= FuBenData.Instance:GetWeaponCfgMaxChapter() then
			local view_data = FuBenData.Instance:GetNeqFBInfo()
			local max_start = FuBenData.Instance:GetChapterMaxStart() or 99
			if next(view_data) == nil or view_data.chapter_list[self.cur_select_index + 1] == nil then return end
			if not view_data.chapter_list[self.cur_select_index + 1].red and view_data.chapter_list[self.cur_select_index + 1].cur_star >= max_start then
				self:ClickNext(1)
			end
		end
	end
end

function WeaponMaterialsContent:OnFlush(param_t)
	self:ConstructData()
	self:SetFlag()
	self:SetInfo()
	self:FLushReward()
	local index = FuBenData.Instance:GetWeaponCurCfg(self.cur_select_index)
	self.node_list["ImgBigBg"].raw_image:LoadSprite("uis/rawimages/weapon_bg_" .. index, "weapon_bg_" .. index .. ".png")

	if self.cell_list and next(self.cell_list) ~= nil then
		for k,v in pairs(self.cell_list) do
			if v.index - 1 == self.cur_select_index then
				v:SetFlag(self.select_layer)
				v:Flush()
			end
		end
	end

	local red_point_fntouzi = false
	local data_list = KaifuActivityData.Instance:GetFBTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedFbByID(v.index + 1) and InvestData.Instance:CheckIsActiveFbByID(v.index + 1) then
			red_point_fntouzi = true
		end
	end

	local all_reward = KaifuActivityData.Instance:IsAllFetchFBTouZi() == true
	local is_open_activity = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
	local has_buy = InvestData.Instance:CheckIsActiveFbByID(1)
	local differ_time = self:GetDifferTimeOpenSever()
	local can_show = false
	if has_buy then
		can_show = true
		self.node_list["refresh_tips"]:SetActive(false)
		self.node_list["effect"]:SetActive(false)
	else
		if differ_time > 0 then
			can_show = true
		end
	end
	self.node_list["IconRemind"]:SetActive(red_point_fntouzi)

	if red_point_fntouzi and self.count_down_quest == nil then
		self.count_down_quest = GlobalTimerQuest:AddRunQuest(function ()
			self.node_list["Icon"].animator:SetTrigger("shake")
		end, 2)
	end

	if not red_point_fntouzi and self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end


	self.node_list["FBTouziViewIcon"]:SetActive(can_show and is_open_activity and not all_reward)
end

function WeaponMaterialsContent:SetReMainTime()
	local diff_time = self:GetDifferTimeOpenSever()
	local has_buy = InvestData.Instance:CheckIsActiveFbByID(1)
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["FBTouziViewIcon"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 18)
			self.node_list["refresh_tips"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		if not has_buy then
			if self.day_count_down == nil then
				self.day_count_down = CountDown.Instance:AddCountDown(
					diff_time, 0.5, diff_time_func)
			end
		else
			if self.day_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.day_count_down)
				self.day_count_down = nil
			end
			self.node_list["refresh_tips"]:SetActive(false)
		end
	end
end

function WeaponMaterialsContent:GetDifferTimeOpenSever()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local differ_day = 4 - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day - time
	return diff_time or 0
end


function WeaponMaterialsContent:ConstructData()
	local data_instance = FuBenData.Instance
	local max_lev = data_instance:GetWeaponCfgMaxLev()
	local data = data_instance:GetData(self.cur_select_index)
	local view_data = data_instance:GetNeqFBInfo()
	local other_cfg = self.other_cfg
	if data == nil or next(view_data) == nil or other_cfg == nil then
		return
	end
	self.name_value = data[0].chapter_name 
	self.chapter_value = data[0].chapter_num 
	self.total_num_value = other_cfg.day_total_count + view_data.today_vip_buy_times + view_data.today_item_buy_times
	self.cur_num_value = other_cfg.day_total_count - view_data.today_fight_all_times + view_data.today_vip_buy_times + view_data.today_item_buy_times
	self.slider_value = view_data.chapter_list[self.cur_select_index + 1].cur_star / (max_lev * 3)
	self.card_id = other_cfg.auto_item_id
	local effect_level = other_cfg.effect_show
	local left_times_color = TEXT_COLOR.GREEN
	if self.cur_num_value <= 0 then
		left_times_color = TEXT_COLOR.RED
	end

	self.node_list["TextNum"].text.text = string.format(Language.FuBen.ChallengeTime, ToColorStr(self.cur_num_value, left_times_color), self.total_num_value)

	self.next_red1_value = false
	self.star_num_value = view_data.chapter_list[self.cur_select_index + 1].cur_star
	if self.cur_select_index > 0 then
		for i = 1, self.cur_select_index do
			if view_data.chapter_list[i].red then
				self.next_red1_value = true
				break
			end
		end
	end

	self.next_red2_value = false
	if self.cur_select_index + 1 <= data_instance:GetWeaponCfgMaxChapter() then
		-- index和数据要对应所以+1
		local index = self.cur_select_index + 2
		for i = index, data_instance:GetWeaponCfgMaxChapter() do
			if view_data.chapter_list[i].red then
				self.next_red2_value = true
				break
			end
		end
	end

	if self.select_layer > 0 then
		if self.cur_select_index == 0 then
			self.node_list["ButtonAuto"]:SetActive(false)
			-- UI:SetButtonEnabled(self.node_list["ButtonAuto"], false) 
		else
			self.node_list["ButtonAuto"]:SetActive(true)
			UI:SetButtonEnabled(self.node_list["ButtonAuto"], not (data[self.select_layer - 1].star ~= 3)) 
		end
		
	end
	for i,v in ipairs(self.item_list) do
		if data[self.select_layer - 1] and data[self.select_layer - 1].item_list[i] ~= nil then
			self.item_list[i]:SetData({item_id = tonumber(data[self.select_layer - 1].item_list[i])})
			self.item_list[i]:SetShowStar(data[self.select_layer - 1].equiment_star)
			self.item_list[i]:SetQualityByColor(data[self.select_layer - 1].equiment_quality)
			local func = function()
				if data[self.select_layer - 1] and data[self.select_layer - 1].item_list[i] ~= nil then
					local item_data = {item_id = tonumber(data[self.select_layer - 1].item_list[i])}
					TipsCtrl.Instance:OpenItem(item_data)

					if self.timer_quest then
						GlobalTimerQuest:CancelQuest(self.timer_quest)
						self.timer_quest = nil
					end
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						TipsCtrl.Instance:SetQualityAndClor(data[self.select_layer - 1].equiment_quality)
						TipsCtrl.Instance:SetOtherQualityAndClor(data[self.select_layer - 1].equiment_quality)
						end, 0.1)
				end
			end
			if effect_level ~= nil and data[self.select_layer - 1].equiment_quality and data[self.select_layer - 1].equiment_quality >= effect_level then
				if data[self.select_layer - 1].equiment_quality == 4 then
					self.item_list[i]:ShowEquipOrangeEffect(true)
				elseif data[self.select_layer - 1].equiment_quality == 5 then
					self.item_list[i]:ShowEquipRedEffect(true)
				elseif data[self.select_layer - 1].equiment_quality == 6 then
					self.item_list[i]:ShowEquipFenEffect(true)
				end
			end
			self.item_list[i]:ShowHighLight(false)
			self.item_list[i]:ListenClick(func)
		end
	end
end

function WeaponMaterialsContent:SetFlag()
	local list_num = FuBenData.Instance:GetMapListNum()
	self.node_list["ButtonLeft"]:SetActive(self.cur_select_index ~= 0)
	self.node_list["ImageLeftRed"]:SetActive(self.next_red1_value)
	self.node_list["ButtonRight"]:SetActive(self.cur_select_index ~= list_num and list_num >= 1)
	self.node_list["ImageRightRed"]:SetActive(self.next_red2_value)
end

function WeaponMaterialsContent:SetInfo()
	self.node_list["Slider"].slider.value = self.slider_value
	self.node_list["TextTitle"].text.text = self.chapter_value .." ".. self.name_value
	self.node_list["TextStarNum"].text.text = self.star_num_value
end

function WeaponMaterialsContent:ClickAdd()
	-- local neq_info = FuBenData.Instance:GetNeqFBInfo()
	-- local max_count = VipPower.Instance:GetParam(VipPowerId.materials_fb_buy_times)
	-- if neq_info == nil or neq_info == "" then return end

	-- if neq_info.today_vip_buy_times >= max_count then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.TodayFullBuyTimes)
	-- 	return
	-- end

	local cost_num = FuBenData.Instance:GetWeaponCfgOther()
	des = string.format(Language.FuBen.BuyManyFB, cost_num.buy_times_gold)
	local ok_callback = function ()
		FuBenCtrl.Instance:SendNeqFBBuyTimesReq()
	end

	local data_fun = function ()
		local data = {}
		local info = FuBenData.Instance:GetNeqFBInfo()
		local cost_num = FuBenData.Instance:GetWeaponCfgOther()
		data[1] = cost_num and cost_num.buy_times_gold or 0
		data[2] = info.today_vip_buy_times or 0
		data[3] = VipPower.Instance:GetParam(VipPowerId.materials_fb_buy_times)
		data[4] = VipPower.Instance:GetParam(VipPowerId.materials_fb_buy_times, true)
		return data
	end

	local data = data_fun()
	FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VipPowerId.materials_fb_buy_times, ok_callback, data_fun)
end

function WeaponMaterialsContent:FLushReward()
	local data_list = FuBenData.Instance:GetRewardList1(self.cur_select_index)
	if data_list then
		for k, v in ipairs(self.reward_cell_list) do
			v:SetIndex(k)
			v:SetData(data_list[k])
		end
	end
	-- 首次星奖励加箭头提示
	if self.cur_select_index == 0 then
		local fb_info = FuBenData.Instance:GetNeqFBInfo().chapter_list
		if nil == fb_info then return end
		local cur_fb_info = fb_info[1]
		local data_list = FuBenData.Instance:GetRewardList1(1)
		if cur_fb_info and data_list and data_list[1] and cur_fb_info.reward_flag[32] == 0 and cur_fb_info.cur_star >= data_list[1].start then
			self.node_list["Arrow"]:SetActive(true)
		else
			self.node_list["Arrow"]:SetActive(false)
		end
	else
		self.node_list["Arrow"]:SetActive(false)
	end
end

function WeaponMaterialsContent:ClickNext(flag)
	local scroller = self.map_list.scroller
	local position = scroller.ScrollPosition
	local index = self.cur_select_index

	local is_right = flag == 1
	index = is_right and index + 1 or index - 1

	if is_right then
		local key = HOT_KEY.FB_WEAPON_LEVELSWITCH
		local setting_data_key = SettingData.Instance:GetSettingDataListByKey(key)
		local flag = setting_data_key.item_id
		local weapon_flag_list = bit:d2b(flag)						--转换为32位表
		if weapon_flag_list[32 - index] == 0 then
			weapon_flag_list[32 - index] = 1 							--标记已点击过了
			flag = bit:b2d(weapon_flag_list)							--重新转换为number
			setting_data_key.item_id = flag								--保存到本地
			SettingCtrl.Instance:SendChangeHotkeyReq(key, flag)			--发送给服务器保存
		end
	end

	self:JumpToIndex(index)
	self:Flush()
end

function WeaponMaterialsContent:OnClickFBTouzi()
	ViewManager.Instance:Open(ViewName.TouziActivityView, 66)
end

function WeaponMaterialsContent:JumpToIndex(index)
	local max_count = self:GetMapNumberOfCell()
	if index < 0 then
		index = 0
	end
	local width = self.scroller.transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.scroller.spacing
	-- 当前页面可以显示的数量
	if index > max_count then
		return
	end

	self.cur_select_index = index
	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = BindTool.Bind(self.Flush, self)

	self.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)

	local data_list = FuBenData.Instance:GetMapList()
	for k,v in pairs(data_list) do
		for k1,v1 in pairs(data_list[self.cur_select_index]) do
			if v1.is_cur_level == true then
				self.select_layer = k1 + 1
			end
		end
	end
end

function WeaponMaterialsContent:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(265)
end