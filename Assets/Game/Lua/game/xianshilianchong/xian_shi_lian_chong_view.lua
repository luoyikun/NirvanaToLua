XianShiLianChongView = XianShiLianChongView or BaseClass(BaseView)

function XianShiLianChongView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/xianshilianchong_prefab", "XianShiLianChongView"}
	}
	self.cell_list = {}
	self.show_fram = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
end

function XianShiLianChongView:__delete()
	

end

function XianShiLianChongView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self:RealseTimer()
	self.cell_list = {}
	self.list_view = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

end


function XianShiLianChongView:OpenCallBack()
	XianShiLianChongData.Instance:SetLianchongRedPointState(false)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO, 0, 0)
end


function XianShiLianChongView:LoadCallBack()
	self.node_list["Name"].text.text = Language.XianShiLianChong.Title
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["LingQuBtn"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu, self))

	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	if nil ~= openchu_time then
		self:SetRestTimeChu(openchu_time)
	end

	local lianchong_info = XianShiLianChongData.Instance:GetChongZhInfo()

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["RewardItem"])
	self:ShowRewardItem()
	
	if lianchong_info then
		if lianchong_info.continue_chongzhi_days < 5 then
			self.node_list["BtnText"].text.text = Language.Common.LingQu
			self.node_list["Effect"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["LingQuBtn"],false)
		end
		self.node_list["TxtTotalDay"].text.text = lianchong_info.continue_chongzhi_day
		self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(lianchong_info.today_chongzhi or 0)
	end
	
end

function XianShiLianChongView:OnFlush()
	local lianchong_info = XianShiLianChongData.Instance:GetChongZhInfo()
	local day = #XianShiLianChongData.Instance:ChongZhiCfgInfo() or 0
	self.node_list["DayTxt"].text.text = day
	if lianchong_info then
		self.node_list["TxtTotalDay"].text.text =  lianchong_info.continue_chongzhi_days
		self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(lianchong_info.today_chongzhi or 0)
		self.list_view.scroller:ReloadData(0)

		local can_fetch_reward_flag = bit:d2b(lianchong_info.can_fetch_reward_flag)
		local has_fetch_reward_falg = bit:d2b(lianchong_info.has_fetch_reward_falg)

		if lianchong_info.continue_chongzhi_days < #XianShiLianChongData.Instance:ChongZhiCfgInfo() then
			self.node_list["BtnText"].text.text = Language.Common.LingQu
			self.node_list["Effect"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["LingQuBtn"],false)
		end

		if can_fetch_reward_flag[32] == 1 then
			if has_fetch_reward_falg[32] == 0 then
				self.node_list["BtnText"].text.text = Language.Common.LingQu
				self.node_list["Effect"]:SetActive(true)
				UI:SetButtonEnabled(self.node_list["LingQuBtn"],true)
			end
			
			if has_fetch_reward_falg[32] == 1 then
				self.node_list["BtnText"].text.text = Language.Common.YiLingQu
				self.node_list["Effect"]:SetActive(false)
				UI:SetButtonEnabled(self.node_list["LingQuBtn"],false)
			end
		end
		self:ShowRewardItem()
	end

end

function XianShiLianChongView:OnClickHelp()
	local tips_id = 317
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function XianShiLianChongView:OnClickLingQu()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG, RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_EXTRA_REWARD, 0, 0)
end


function XianShiLianChongView:ShowRewardItem()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG)
	local cfg = XianShiLianChongData.Instance:ChongZhiCfgInfo()
	if nil == cfg then
		return
	end
	local reward_id = nil
	for k, v in pairs(cfg) do
		if (open_server_day - activity_day + 1) <= v.open_server_day then
			reward_id = v.continue_chongzhi_extra_reward_2
			break
		end
	end
	if reward_id then
		self.item:SetData(reward_id)
	end
end


function XianShiLianChongView:GetNumberOfCells()
	return #XianShiLianChongData.Instance:ChongZhiCfgInfo()
end

function XianShiLianChongView:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = XianShiItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end
	local index = cell_index + 1
	local item_id_group = XianShiLianChongData.Instance:ChongZhiCfgInfo()
	local data = item_id_group[index]
	shop_cell:SetIndex(index)
	shop_cell:SetData(data)
end


function XianShiLianChongView:SetRestTimeChu(diff_time)
	local lianchong_info =  XianShiLianChongData.Instance:GetChongZhInfo()
	if lianchong_info == nil then
		return
	end
	if self.count_down_chu == nil and lianchong_info.continue_chongzhi_days ~= nil then

		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				return
			end
			local format_time = TimeUtil.Format2TableDHMS(left_time)
			local time_str = ""
			if format_time.day >= 1 then
				time_str = string.format(Language.Activity.ActivityTime8, format_time.day, format_time.hour)
			else
				time_str = string.format(Language.Activity.ActivityTime9, format_time.hour, format_time.min, format_time.s)
			end
			self.node_list["TxtTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end

end

function XianShiLianChongView:RealseTimer()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end


-----------------------------XianShiItemCellGroup--------------------------
XianShiItemCellGroup = XianShiItemCellGroup or BaseClass(BaseRender)

function XianShiItemCellGroup:__init()
	self.cell_list = {}
	local cell = XianShiitemCell.New(self.node_list["item"])
	table.insert(self.cell_list, cell)
end

function XianShiItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function XianShiItemCellGroup:SetToggleGroup()

end

function XianShiItemCellGroup:SetData(data)
	self.cell_list[1]:SetData(data)
end

function XianShiItemCellGroup:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------XianShiitemCell--------------------------
XianShiitemCell = XianShiitemCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 3

function XianShiitemCell:__init()
	self.node_list["BtnLingqu"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu,self))
	self.node_list["BtnChongzhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi,self))

	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self.node_list["picture_" .. i])
		self["item_cell_" .. i]:ShowHighLight(false)
	end
end

function XianShiitemCell:__delete()
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function XianShiitemCell:OnClickLingQu()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function XianShiitemCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function XianShiitemCell:OnFlush()
	local item_num = XianShiLianChongData.Instance:GetChongZhInfo()
	if nil == item_num then
		return
	end
	local can_fetch_reward_flag = bit:d2b(item_num.can_fetch_reward_flag)
	local has_fetch_reward_falg = bit:d2b(item_num.has_fetch_reward_falg)

	if can_fetch_reward_flag[32 - self.data.day_index] == 0 then
		self.node_list["BtnLingqu"]:SetActive(false)
		self.node_list["BtnChongzhi"]:SetActive(true)
	end

	if can_fetch_reward_flag[32 - self.data.day_index] == 1 then
		if has_fetch_reward_falg[32 - self.data.day_index] == 0 then
			self.node_list["BtnLingqu"]:SetActive(true)
			self.node_list["BtnChongzhi"]:SetActive(false)
			self.node_list["TxtInBtnLingQu"].text.text = Language.Common.LingQu
			self.node_list["NodeEffect"]:SetActive(true)
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],true)
		end
		
		if has_fetch_reward_falg[32 - self.data.day_index] == 1 then
			self.node_list["BtnLingqu"]:SetActive(true)
			self.node_list["BtnChongzhi"]:SetActive(false)
			self.node_list["TxtInBtnLingQu"].text.text = Language.Common.YiLingQu
			self.node_list["NodeEffect"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],false)
			self.node_list["BtnLingqu"]:SetActive(not has_fetch_reward_falg[32 - self.data.day_index] == 1)
		end
	end
	self.node_list["IsFalg"]:SetActive(has_fetch_reward_falg[32 - self.data.day_index] == 1)
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime() or 0
	local max_time = math.ceil((openchu_end - openchu_start) / 3600 / 24)
	local flag = math.floor(openchu_time / 3600 / 24) <= (max_time - self.data.day_index)
	UI:SetButtonEnabled(self.node_list["BtnChongzhi"], flag)


	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i]:SetData(item_group[i])
		self["item_cell_" .. i]:SetRedPoint(false)
	end

	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = XianShiLianChongData.Instance:ChongZhiCfgInfo()
	local need_chongzhi = 0
	for k, v in pairs(cfg) do
		if open_sever_day <= v.open_server_day then
			if v.day_index == self.data.day_index then
				need_chongzhi = v.need_chongzhi
			end
		end
	end

	self.node_list["DayText"].text.text = string.format(Language.XianShiLianChong.DayTxt, self.data.day_index)
	self.node_list["TxtLoginDay"].text.text = string.format(Language.XianShiLianChong.ChongZhi, need_chongzhi)
end