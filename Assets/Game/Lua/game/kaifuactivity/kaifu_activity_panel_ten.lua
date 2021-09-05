KaifuActivityPanelTen = KaifuActivityPanelTen or BaseClass(BaseRender)

function KaifuActivityPanelTen:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}
	self:IntShowTime()
end

function KaifuActivityPanelTen:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self:RealseTimer()
end

function KaifuActivityPanelTen:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetLeijiChongZhiSortCfg()
end

function KaifuActivityPanelTen:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = PanelTenListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local data = KaifuActivityData.Instance:GetLeijiChongZhiSortCfg()
	cell_item:SetData(data[data_index + 1])
end

function KaifuActivityPanelTen:Flush(activity_type)
	if KaifuActivityData.Instance:GetLeiJiChongZhiInfo() == nil then return end

	self.activity_type = activity_type or self.activity_type

	if activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end

	self.temp_activity_type = activity_type
end

function KaifuActivityPanelTen:IntShowTime()
	local open_start, open_end = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	local open_time = open_end - TimeCtrl.Instance:GetServerTime()
	if nil ~= open_time then
		self:SetRestTimeChu(open_time)
	end
end

function KaifuActivityPanelTen:SetRestTimeChu(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time = ""
			if left_time > (3600 * 24) then
				time = TimeUtil.FormatSecond(left_time, 6)
			else
				time = TimeUtil.FormatSecond(left_time, 0)
			end
			self.node_list["TimeText"].text.text = time
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end

end

function KaifuActivityPanelTen:RealseTimer()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end


PanelTenListCell = PanelTenListCell or BaseClass(BaseRender)

local ITEM_NUM = 5

function PanelTenListCell:__init(instance)
	self.item_list = {}
	self.data = {}
	for i = 1, ITEM_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellRewardItem" .. i])
	end
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function PanelTenListCell:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.data = nil
end

function PanelTenListCell:SetData(data)
	if data == nil then return end
	self.data = data
	local grade_index = 0
	local str = string.gsub(self.data.cfg.description, "%[.-%]", function (str)
		local change_str = self.data.cfg[string.sub(str, 2, -2)]
		local leiji_chongzhi_info = KaifuActivityData.Instance:GetLeiJiChongZhiInfo()
		local total_charge_value = leiji_chongzhi_info.total_charge_value or 0
		-- if total_charge_value < tonumber(change_str) then
		-- 	change_str = string.format(Language.Mount.ShowGreenStr, change_str)
		-- end
		return change_str
	end)
	-- self.node_list["TxtTitle"].text.text = self.data.cfg.description
	self.node_list["MenoyText"].text.text = self.data.cfg.need_chognzhi
	if self.data.flag == 0 then
		-- self.node_list["TxtBtn"].text.text = Language.Common.YiLingQu
		-- UI:SetButtonEnabled(self.node_list["BtnGetReward"], flase)
		self.node_list["ImgHasGet"]:SetActive(true)
		self.node_list["BtnGetReward"]:SetActive(false)
		self.node_list["ImgRedPoint"]:SetActive(false)
	elseif self.data.flag == 1 then
		self.node_list["TxtBtn"].text.text = Language.Recharge.GoReCharge
		self.node_list["ImgHasGet"]:SetActive(false)
		self.node_list["BtnGetReward"]:SetActive(true)
		self.node_list["ImgRedPoint"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], true)
	else
		self.node_list["ImgHasGet"]:SetActive(false)
		self.node_list["BtnGetReward"]:SetActive(true)
		self.node_list["ImgRedPoint"]:SetActive(true)
		self.node_list["TxtBtn"].text.text = Language.Common.LingQu
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], true)
	end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}

	local gift_id = 0
	for k, v in pairs(self.data.cfg.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)

			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end

			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end
	local cur_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE
	local cond, _ = KaifuActivityData.Instance:GetCondByType(cur_type)
	-- local color = cond < self.data.cfg.need_chognzhi and TEXT_COLOR.RED_4 or TEXT_COLOR.GREEN_4
	-- cond = ToColorStr(cond, color)
	-- self.node_list["TxtNeed"].text.text = string.format(Language.RandomActivity.SevenTotalNeed, cond, self.data.cfg.need_chognzhi)
	KaifuActivityData.Instance:OutLineRichText(cond, self.data.cfg.need_chognzhi, self.node_list["TxtNeed"], 1)
	local is_destory_effect = true
	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_list[k])

		if item_list[k] then
			-- for _, v2 in pairs(self.data.item_special or {}) do
			-- 	if v2.item_id == item_list[k].item_id then
			-- 		v:IsDestoryActivityEffect(false)
			-- 		v:SetActivityEffect()
			-- 		is_destory_effect = false
			-- 		break
			-- 	end
			-- end

			-- if is_destory_effect then
			-- 	v:IsDestoryActivityEffect(is_destory_effect)
			-- 	v:SetActivityEffect()
			-- end
			
			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end
end

function PanelTenListCell:OnClickGet()
	local flag = flag or 0
	local data = KaifuActivityData.Instance:GetLeijiChongZhiSortCfg()
	local reward_num = 0
	for k,v in pairs(data) do
		if v and v.cfg and self.data.cfg.seq == v.cfg.seq then
			reward_num = #v.cfg.reward_item
		end
	end

	local is_bag_enough = ItemData.Instance:GetEmptyNum()
	if self.data.flag == 2 and is_bag_enough >= reward_num then 
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.data.cfg.seq)
		return
	elseif self.data.flag == 1 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end
