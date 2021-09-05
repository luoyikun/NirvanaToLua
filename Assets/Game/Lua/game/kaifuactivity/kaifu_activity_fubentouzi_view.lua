FuBenTouZiView = FuBenTouZiView or BaseClass(BaseRender)

function FuBenTouZiView:__init()
	self.cell_list = {}
	local list_delegate = self.node_list["RewardList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)	

	local price = KaifuActivityData.Instance:GetFBTouZiPrice()
	self.node_list["Price"].text.text = price
	self.node_list["InvestmentBtn"].button:AddClickListener(BindTool.Bind(self.OnInvestment, self))

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local real_role_id = CrossServerData.Instance:GetRoleId()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("FuBenTouZiView" .. real_role_id, cur_day)
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end

	self:SetReMainTime()
end

function FuBenTouZiView:OnInvestment()
	local func = function ()
		InvestCtrl.Instance:SendTouzijihuaFbBossOperate(TOUZIJIHUA_FB_BOSS_OPERATE_TYPE.TOUZIJIHUA_FB_BOSS_OPERATE_FB_BUY)
	end

	local price = KaifuActivityData.Instance:GetFBTouZiPrice()
	local desc = string.format(Language.Common.InvestTips, price)
	TipsCtrl.Instance:ShowCommonTip(func, nil, desc)	
end

function FuBenTouZiView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end
end

function FuBenTouZiView:OnFlush()
	local hai_ke_fan_huan_txt, yi_fan_huan_txt, li_ji_ling_qu_txt = KaifuActivityData.Instance:GetFBTouZiAfterGold()
	self.node_list["HaiKeFanHuanTxt"].text.text = hai_ke_fan_huan_txt
	self.node_list["YiFanHuanTxt"].text.text = yi_fan_huan_txt
	self.node_list["LiJiLingQuTxt"].text.text = li_ji_ling_qu_txt

	if InvestData.Instance:CheckIsActiveFbByID(1) then
		self.node_list["InvestmentBtnText"].text.text = Language.Activity.YiTouZi
		UI:SetButtonEnabled(self.node_list["InvestmentBtn"], false)
		self.node_list["time"]:SetActive(false)
		self.node_list["LiJiLingQu"]:SetActive(false)
		self.node_list["HaiKeFanHuan"]:SetActive(true)
		self.node_list["YiFanHuan"]:SetActive(true)
	else
		self.node_list["InvestmentBtnText"].text.text = Language.Activity.LiJiTouZi
		UI:SetButtonEnabled(self.node_list["InvestmentBtn"], true)
		self.node_list["LiJiLingQu"]:SetActive(true)
		self.node_list["HaiKeFanHuan"]:SetActive(false)
		self.node_list["YiFanHuan"]:SetActive(false)		
	end

	if self.node_list["RewardList"] and self.node_list["RewardList"].scroller.isActiveAndEnabled then
 		self.node_list["RewardList"].scroller:RefreshAndReloadActiveCellViews(true)
  	end
end

function FuBenTouZiView:GetNumberOfCells()
	local data_list = KaifuActivityData.Instance:GetFBTouZiDataList()
	return #data_list
end

function FuBenTouZiView:RefreshCell(cell, data_index)
	local data_list = KaifuActivityData.Instance:GetFBTouZiDataList()
	data_index = data_index + 1
	local reward_cell = self.cell_list[cell]
	if reward_cell == nil then
		reward_cell = FuBenTouZiViewItem.New(cell.gameObject)
		self.cell_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(data_list[data_index])
end

function FuBenTouZiView:SetReMainTime()
	local diff_time = self:GetDifferTimeOpenSever()
	local has_buy = InvestData.Instance:CheckIsActiveFbByID(1)
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 18)
			has_buy = InvestData.Instance:CheckIsActiveFbByID(1)
			self.node_list["time"]:SetActive(not has_buy)
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
			self.node_list["time"]:SetActive(false)
		end
	end
end

function FuBenTouZiView:GetDifferTimeOpenSever()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local differ_day = 4 - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day - time
	return diff_time or 0
end

------------------------------------------------------------------
FuBenTouZiViewItem = FuBenTouZiViewItem or BaseClass(BaseCell)

function FuBenTouZiViewItem:__init()
	self.node_list["Btn_Get"].button:AddClickListener(BindTool.Bind(self.OnGetReward, self))
	self.node_list["Btn_QianWang"].button:AddClickListener(BindTool.Bind(self.OnQianWang, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData(nil)
	
end

function FuBenTouZiViewItem:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function FuBenTouZiViewItem:OnGetReward()
	local now_pass_level = InvestData.Instance:GetFuBenPassLevel()
	if now_pass_level >= self.data.pass_level and not InvestData.Instance:CheckIsActiveFbByID(1) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.TouZiLiJiLingQu)
		return
	end		
	InvestCtrl.Instance:SendTouzijihuaFbBossOperate(TOUZIJIHUA_FB_BOSS_OPERATE_TYPE.TOUZIJIHUA_FB_BOSS_OPERATE_FB_REWARD, self.data.index)
end

function FuBenTouZiViewItem:OnQianWang()
	ViewManager.Instance:Close(ViewName.TouziActivityView)
	ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_weapon)
end

function FuBenTouZiViewItem:OnFlush()
	if self.data == nil then
		return
	end
	self.item:SetData({item_id = 65533, num = self.data.reward_gold_bind})

	local now_pass_level = InvestData.Instance:GetFuBenPassLevel()
	self.node_list["Txt_1"]:SetActive(now_pass_level < self.data.pass_level)
	--self.node_list["Txt_2"]:SetActive(now_pass_level >= self.data.pass_level)
	self.node_list["Txt_need_levle"].text.text = self.data.pass_level_desc
	self.node_list["Effect"]:SetActive(InvestData.Instance:CheckIsActiveFbByID(1))
	UI:SetButtonEnabled(self.node_list["Btn_Get"], InvestData.Instance:CheckIsActiveFbByID(1))

	if InvestData.Instance:CheckIsFetchedFbByID(self.data.index + 1) then
		self.node_list["Btn_QianWang"]:SetActive(false)
		self.node_list["Btn_Get"]:SetActive(false)
		self.node_list["ImgHasGet"]:SetActive(true)
	-- elseif InvestData.Instance:CheckIsActiveFbByID(self.data.index + 1) then
	elseif now_pass_level >= self.data.pass_level then	
		self.node_list["ImgHasGet"]:SetActive(false)
		self.node_list["Btn_QianWang"]:SetActive(false)
		self.node_list["Btn_Get"]:SetActive(true)
	else
		self.node_list["Btn_Get"]:SetActive(false)
		self.node_list["ImgHasGet"]:SetActive(false)
		self.node_list["Btn_QianWang"]:SetActive(true)
	end
end