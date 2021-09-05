----------------------------------------------------
--上古卷轴（天书）
----------------------------------------------------

TianShuView = TianShuView or BaseClass(BaseView)

function TianShuView:__init()
	self.ui_config = {
		{"uis/views/tianshuview_prefab", "TianShuView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.full_screen = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.select_index = 1
end

function TianShuView:__delete()

end

function TianShuView:ReleaseCallBack()

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	if self.tianshu_list then
		self.tianshu_list:DeleteMe()
		self.tianshu_list = nil
	end

	if self.challenge_count_down then
		CountDown.Instance:RemoveCountDown(self.challenge_count_down)
		self.challenge_count_down = nil
	end

	self.select_index = 1
end

function TianShuView:LoadCallBack()
	self.select_index = TianShuData.Instance:GetTianShuSelectType()
	self.contain_cell_list = {}
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		local type_name = TianShuData.Instance:GetTianShuTypeNameByIndex(i)
		self.node_list["TextName" .. i].text.text = type_name
		self.node_list["toggle_content_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnShowTab, self, i))
		self.node_list["toggle_content_" .. i].toggle.isOn = self.select_index == i
	end
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnBtnFinallyReward, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function TianShuView:GetNumberOfCells()
	local goal_count = TianShuData.Instance:GetTianShuGoalCountByIndex(self.select_index)
	self.data_list = TianShuData.Instance:GetTisnShuDataListByIndex(self.select_index)
	return goal_count
end

function TianShuView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TianShuItem.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	if self.data_list and next(self.data_list) then
		contain_cell:SetData(self.data_list[cell_index + 1], self.select_index)
		contain_cell:Flush()
	end
end

function TianShuView:OnShowTab(seq)
	if self.select_index == seq then
		return
	end
	self.select_index = seq
	self.node_list["ListView"].scroller:ReloadData(0)

	self:FlushInfo()
	self:FlushRestChallengeTime()
end

function TianShuView:ShowIndexCallBack(index)
	TianShuCtrl.Instance:SendTianShuInfo()
end

function TianShuView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.TianShu)
	local open_list = TianShuData.Instance:GetTianShuOpenType()
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		if i == open_list[1] then
			self.node_list["HightLight" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_select")
			self.node_list["Hide" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_nomal")
		elseif i == open_list[#open_list] then
			self.node_list["HightLight" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_select2")
			self.node_list["Hide" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_nomal2")
		else
			self.node_list["HightLight" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_select1")
			self.node_list["Hide" .. i].image:LoadSprite("uis/views/tianshuview/image_atlas", "toggle_nomal1")
		end
	end
	-- self:FlushInfo()
	-- self:FlushRestChallengeTime()
	self:FlushTianshuView()
end



function TianShuView:FlushInfo()
	local bundle, asset = ResPath.GetTianShuImage(self.select_index)
	self.node_list["Image"].image:LoadSprite(bundle, asset, function()
			self.node_list["Image"].image:SetNativeSize()
		end)

	local final_reward_item = TianShuData.Instance:GetFinalRewardByIndex(self.select_index)
	if final_reward_item then
		local final_reward_cfg = Split(final_reward_item, ":")
		local num = tonumber(final_reward_cfg[3])
		local final_reward_num = 0
		local data_list = TianShuData.Instance:GetTisnShuDataListByIndex(self.select_index) or {}
		for k, v in pairs(data_list) do
			if v.fetch_flag == 1 then
				final_reward_num = final_reward_num + 1
			end
		end
		self.node_list["TextDec"].text.text = string.format(Language.TianShuXunZhu.FinalRewardDesc, final_reward_cfg[1])
		final_num = final_reward_num >= num and final_reward_num or ToColorStr(final_reward_num, TEXT_COLOR.RED)
		self.node_list["TextNum"].text.text = final_num .. " / " .. num
	end

	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		local is_show_redpoint = TianShuData.Instance:GetRemindByIndex(i)
		self.node_list["RedPoint_" .. i]:SetActive(is_show_redpoint ~= 0)
		local is_open_type = TianShuData.Instance:IsOpenTianshuType(i)
		self.node_list["toggle_content_" .. i]:SetActive(is_open_type)
	end

	local fetch_flag, can_fetch_flag = TianShuData.Instance:GetFetchFlagdByIndex(self.select_index)
	UI:SetButtonEnabled(self.node_list["BtnReward"], can_fetch_flag and not fetch_flag)
	self.node_list["Effect"]:SetActive(can_fetch_flag and not fetch_flag)
	self.node_list["TextReward"].text.text = fetch_flag and Language.Common.YiLingQu or Language.Common.LingQu
	local skill_desc = TianShuData.Instance:GetTianShuDescNameByIndex(self.select_index)
	self.node_list["TextExp"].text.text = skill_desc
end

function TianShuView:CloseCallBack()
end


function TianShuView:OnFlush()
	self.node_list["ListView"].scroller:ReloadData(0)
	self:FlushInfo()
	self:FlushRestChallengeTime()
end

function TianShuView:FlushTianshuView()
	local last_index = TianShuData.Instance:GetTianShuSelectType()
	self:OnShowTab(last_index)
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		self.node_list["toggle_content_" .. i].toggle.isOn = i == last_index
	end
	self:FlushInfo()
	self:FlushRestChallengeTime()
end

function TianShuView:OnBtnFinallyReward()
	TianShuCtrl.Instance:SendTianShuFetchReward(self.select_index - 1, 31)
	TianShuCtrl.Instance:OpenTianShuSkillFinishView(self.select_index - 1)
	-- local last_index = self.select_index >= 6 and self.select_index or self.select_index + 1
	-- if last_index ~= self.select_index then
	-- 	self.select_index = last_index
	-- 	self.node_list["toggle_content_" .. last_index].toggle.isOn = true
	-- end
end

function TianShuView:FlushRestChallengeTime()
	self.node_list["Time"]:SetActive(false)
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local openday, endday = TianShuData.Instance:GetTianShuTypeOpenDayByIndex(self.select_index)
	if cur_open_day >= openday and cur_open_day < endday then
		local residue_time = (endday - cur_open_day - 1)*86400
		local endtime = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime()) - TimeCtrl.Instance:GetServerTime() + residue_time
		if self.node_list["Time"] then
			self.node_list["Time"]:SetActive(true)
		end
		if nil == self.challenge_count_down then
			local diff_time = function(elapse_time, total_time)
				local time = math.floor(total_time - elapse_time + 0.5)
				local last_time = TimeUtil.FormatSecond(time, 10)
				if self.node_list and self.node_list["TextTime"] then
					self.node_list["TextTime"].text.text = string.format(Language.TianShuXunZhu.TianShuRestTime, last_time)
				end
				if elapse_time >= total_time then
					self.node_list["Time"]:SetActive(false)
					if self.challenge_count_down then
						CountDown.Instance:RemoveCountDown(self.challenge_count_down)
						self.challenge_count_down = nil
					end
				end
			end
			self.challenge_count_down = CountDown.Instance:AddCountDown(endtime, 1, diff_time)
		end
	end
end

----------------------------------------------------------------------------------------------------
-- 天书item
----------------------------------------------------------------------------------------------------
TianShuItem = TianShuItem or BaseClass(BaseCell)
function TianShuItem:__init()
	self.item_cell = {}
	self.boss_img_cell = {}
	for i = 1, 6 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
		self.node_list["ItemCell" .. i]:SetActive(false)
	end
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnBtnGo, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnBtnReward, self))
end

function TianShuItem:__delete()
	if nil ~= next(self.item_cell) then
		for k,v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = nil
	end
end

function TianShuItem:SetData(data, select_index)
	if nil == data then return end
	self.data = data
	self.type_index = select_index

	local desc = ""
	if select_index == 1 then
		local reward = self.data.reward >= 10000 and (self.data.reward / 10000)..Language.Common.Wan or self.data.reward
		local zhuanzhi_equip_fangyu = TianShuData.Instance:GetZhuanZhiFangyuValue()
		local color = zhuanzhi_equip_fangyu >= tonumber(self.data.param1) and "#00ff00" or TEXT_COLOR.RED
		local num = string.format("<color=#00ff00>%s(%s/%s)</color>", self.data.param1, ToColorStr(zhuanzhi_equip_fangyu, color), self.data.param1)
		desc = string.format(self.data.desc, num, reward)
	elseif select_index == 2 then
		local reward = self.data.reward >= 10000 and (self.data.reward / 10000)..Language.Common.Wan or self.data.reward
		local equip_level_50, equip_level_100 = TianShuData.Instance:GetEquipCount()
		local equip_num = self.data.param2 == 50 and equip_level_50 or equip_level_100
		local color = equip_num >= tonumber(self.data.param1) and "#00ff00" or TEXT_COLOR.RED
		local num = string.format("<color=#00ff00>(%s/%s)</color>", ToColorStr(equip_num, color), self.data.param1)
		desc = string.format(self.data.desc, self.data.param1, self.data.param2, num, reward)
	elseif select_index == 3 then
		local shixue_cfg = TianShuData.Instance:GetCfgTypeAndSeq(select_index - 1, self.data.seq - 1)
		if shixue_cfg and next(shixue_cfg) then
			desc = shixue_cfg.desc
		end
	elseif select_index == 4 then
		local equip_desc = Language.TianShuXunZhu.EquipType[self.data.param2]
		local reward = self.data.reward >= 10000 and (self.data.reward / 10000)..Language.Common.Wan or self.data.reward
		desc = string.format(self.data.desc, self.data.param1, equip_desc, reward)
	elseif select_index == 5 then
		local baizhan_equip_num = TianShuData.Instance:GetBaiZhanEquipCount()
		local color = baizhan_equip_num >= tonumber(self.data.param1) and "#00ff00" or TEXT_COLOR.RED
		local num = string.format("<color=#00ff00>(%s/%s)</color>", ToColorStr(baizhan_equip_num, color), self.data.param1)
		local reward = self.data.reward >= 10000 and (self.data.reward / 10000)..Language.Common.Wan or self.data.reward
		desc = string.format(self.data.desc, self.data.param1, num, reward)
	elseif select_index == 6 then
		local reward = self.data.reward >= 10000 and (self.data.reward / 10000)..Language.Common.Wan or self.data.reward
		desc = string.format(self.data.desc, self.data.param1, reward)
	end
	self.node_list["ItemText"].text.text = desc
	self.node_list["TextTuiJian"]:SetActive(false)
	for i = 1, 3 do
		self.node_list["TuBiao" .. i]:SetActive(false)
	end
	local icon_show_list = TianShuData.Instance:GetShowIconByTypeAndSeq(select_index - 1, self.data.seq - 1)
	if icon_show_list then
		local icon_split_list = Split(icon_show_list, "|")
		if icon_split_list and next(icon_split_list) then
			for i = 1, #icon_split_list do
				if icon_split_list[i] then
					local t = Split(icon_split_list[i], ",")
					local bundle = t[1]
					local asset = t[2]
					if bundle and asset then
						self.node_list["TuBiao" .. i]:SetActive(true)
						self.node_list["ImgTuBiao" .. i].image:LoadSprite(bundle, asset, function ()
							self.node_list["ImgTuBiao" .. i].image:SetNativeSize()
						end)
						local asset1 = asset .. "Name"
						if asset1 then
							self.node_list["ImageName" .. i].image:LoadSprite(bundle, asset1, function ()
								self.node_list["ImageName" .. i].image:SetNativeSize()
							end)
						end
					end
				end
			end
		end
	end

	if self.data.recommend_t and #self.data.recommend_t > 0 then
		for i = 1, #self.data.recommend_t do
			if tonumber(self.data.recommend_t[i]) > 0 then
				self.node_list["ItemCell" .. i]:SetActive(true)
				self.item_cell[i]:SetData({item_id = self.data.recommend_t[i]})
				self.node_list["TextTuiJian"]:SetActive(true)
			else
				self.node_list["ItemCell" .. i]:SetActive(false)
			end
		end

		for i = #self.data.recommend_t + 1, 6 do
			self.node_list["ItemCell" .. i]:SetActive(false)
		end
	else
		for i = 1, 6 do
			self.node_list["ItemCell" .. i]:SetActive(false)
		end
	end
end

function TianShuItem:OnFlush()
	if nil == self.data then return end
	self.node_list["BtnGo"]:SetActive(self.data.can_fetch_flag == 0)
	UI:SetButtonEnabled(self.node_list["BtnGo"], not self.data.is_past)
	self.node_list["TextGo"].text.text = self.data.is_past and Language.Common.HadOverdue or Language.Common.QianWang
	self.node_list["BtnReward"]:SetActive(self.data.can_fetch_flag ~= 0 and self.data.fetch_flag ~= 1)
	self.node_list["HaveGet"]:SetActive(self.data.fetch_flag == 1)
end

function TianShuItem:OnBtnGo()
	if self.data == nil then return end
	local open_panel = TianShuData.Instance:GetOpenPanelByTypeAndSeq(self.type_index - 1, self.data.seq - 1)
	if nil == open_panel then return end
	if open_panel == "AdvanceHuanhua#mount_huanhua" then
		AdvanceData.Instance:SetHuanHuaType(TabIndex.wuqi_huan_hua)
		ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua,"wuqihuanhuaview",{TALENT_TYPE.TALENT_SHENYI})
		AdvanceCtrl.Instance:FlushView("wuqihuanhuaview")
		ViewManager.Instance:Close(ViewName.TianShuView)
	elseif open_panel == "FreeGiftView" then
		if OpenFunData.Instance:CheckIsHide("zero_gift") or  FreeGiftData.Instance:CanShowZeroGift() then
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		else
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		end
	elseif open_panel == "OneYuanBuyView" then
		local is_level_reach = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
		local is_all_buy = OneYuanBuyData.Instance:GetIsShowOneYuanBuyData()
		if is_level_reach and is_open and is_all_buy then
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		end
	elseif open_panel == "TouziActivityView#66" then
		if OpenFunData.Instance:CheckIsHide("kaifuactivityview") and KaifuActivityData.Instance:IsAllFetchFBTouZi() == false then
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		end
	elseif open_panel == "KaifuActivityView#8" then
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT) then
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		end
	elseif open_panel == "SecondChargeView" then
		local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
		local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
		local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)
		local fetch_flag = fetch_flag1 ~= 1 or fetch_flag2 ~= 1 or fetch_flag3 ~= 1
		if fetch_flag then
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		end
	elseif open_panel == 64100 then
		local item_id = 64100
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			local timer_callback = function()
				local bag_index = ItemData.Instance:GetItemIndex(item_id)
				PackageCtrl.Instance:SendUseItem(bag_index, 1)
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1, true)
	elseif open_panel == "Forge#forge_deity_suit" then
		local is_jump = ForgeData.Instance:GetJumpIndexBySeq(self.data.param2)
		if is_jump then
			ViewManager.Instance:Open(ViewName.Forge,TabIndex.forge_deity_suit, "jump_index", {["jump_index"] = self.data.param2})
		else
			ViewManager.Instance:OpenByCfg(open_panel)
		end
		ViewManager.Instance:Close(ViewName.TianShuView)
	-- elseif open_panel == "ShenShou#shenshou_equip" then
	-- 	local index = ShenShouData.Instance:GetShenShouJumpIndexByName(self.data.param1)
	-- 	ViewManager.Instance:Open(ViewName.ShenShou,TabIndex.shenshou_equip, "jump_index", {["jump_index"] = index})
	elseif open_panel == "RebateView" then
		local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
		local is_show = RebateCtrl.Instance:GetBuyState()
		local is_open = OpenFunData.Instance:CheckIsHide("rebateview")
		local count_down_time = RebateCtrl.Instance:GetCloseTime() - TimeCtrl.Instance:GetServerTime()
		if history_recharge >= DailyChargeData.GetMinRecharge() and is_show and is_open and count_down_time > 0 then
			ViewManager.Instance:OpenByCfg(open_panel)
			ViewManager.Instance:Close(ViewName.TianShuView)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
		end
	else
		ViewManager.Instance:OpenByCfg(open_panel)
		ViewManager.Instance:Close(ViewName.TianShuView)
	end
end

function TianShuItem:OnBtnReward()
	if self.data == nil or self.type_index == nil then
		return
	end
	TianShuCtrl.Instance:SendTianShuFetchReward(self.type_index - 1, self.data.seq - 1)
end
