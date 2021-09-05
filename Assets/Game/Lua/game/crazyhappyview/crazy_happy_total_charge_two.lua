TotalChargeTwo =  TotalChargeTwo or BaseClass(BaseRender)
--累计充值
function TotalChargeTwo:__init()
	self.contain_cell_list = {}
end

function TotalChargeTwo:__delete()
	self.list_view = nil
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	self.chongzhi_count = nil
end

function TotalChargeTwo:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO,
		RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	self.reward_list = CrazyHappyData.Instance:GetOpenActTotalChargeTwoRewardCfg(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)

	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TotalChargeTwo:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function TotalChargeTwo:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TotalChargeTwo:OnFlush()
	self.reward_list = CrazyHappyData.Instance:GetOpenActTotalChargeTwoRewardCfg(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)

	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end

	local info = CrazyHappyData.Instance:GetTotalChargeInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)
	local money = 0
	if info and info.total_charge_value then
		money =  CommonDataManager.ConverMoney(info.total_charge_value)
	end
	self.node_list["TxtXiaoFeiCount"].text.text = money or 0	--ToColorStr(info.total_charge_value or 0, TEXT_COLOR.LIGHTYELLOW)
end

function TotalChargeTwo:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}

	for k,v in pairs(time_tab) do
		temp[k] = v
	end

	-- local str = temp.day > 0 and string.format(Language.Activity.ActivityTime6, temp.day, temp.hour) or string.format(Language.Activity.ActivityTime5, temp.hour, temp.min ,temp.s)
	local str = TimeUtil.FormatSecond(rest_time, 10)
	self.node_list["TxtLastTime"].text.text = ToColorStr(str, TEXT_COLOR.GREEN)
end

function TotalChargeTwo:GetNumberOfCells()
	return #self.reward_list
end

function TotalChargeTwo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = TotalChargeTwoCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------TotalChargeTwoCell---------------------------------
TotalChargeTwoCell = TotalChargeTwoCell or BaseClass(BaseCell)

local MAX_REWARD_NUM = 4

function TotalChargeTwoCell:__init()
	self.item_cell_list = {}
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

	for i = 1, MAX_REWARD_NUM do
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.node_list["CellRewardItem_" .. i])
	end

end

function TotalChargeTwoCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end

	self.item_cell_list = {}
end


function TotalChargeTwoCell:OnFlush()
	if self.data == nil then return end

	local info = CrazyHappyData.Instance:GetTotalChargeInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)
	local cur_value = info and info.total_charge_value or 0
	local color = cur_value >= self.data.need_chognzhi and TEXT_COLOR.GREEN or TEXT_COLOR.RED_1
	-- local can_get_str = string.format(Language.Activity.CanGetTips, self.data.need_chognzhi, cur_value, self.data.need_chognzhi)
	self.node_list["TextNeed"].text.text = self.data.need_chognzhi
	-- self.node_list["TextRecharge"].text.text = string.format(Language.Activity.CanGetTips, ToColorStr(cur_value, color), self.data.need_chognzhi)
	KaifuActivityData.Instance:OutLineRichText(cur_value, self.data.need_chognzhi, self.node_list["TextRecharge"], 1)
	-- local title_description = string.gsub(self.data.description, "%[.-%]", function (title_description)
	-- 		local change_str = self.data[string.sub(title_description, 2, -2)]
	-- 		print_error("change_str",change_str)
	-- 		return change_str
	-- end)



	self.node_list["TxtTitleDescriton"].text.text = Language.Activity.ActivityLeiJiRecharge
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)

	for i = 1, MAX_REWARD_NUM do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.node_list["CellRewardItem_" .. i]:SetActive(true)
		else
			self.node_list["CellRewardItem_" .. i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	local str = fetch_reward_flag and Language.Common.YiLingQu or (cur_value >= self.data.need_chognzhi and Language.Common.LingQu or Language.Common.WEIDACHENG)
	
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], not fetch_reward_flag and cur_value >= self.data.need_chognzhi)
	self.node_list["TxtInBtn"].text.text = str
	self.node_list["ImgHadGet"]:SetActive(fetch_reward_flag and cur_value >= self.data.need_chognzhi)
	self.node_list["EffectInBtn"]:SetActive(not fetch_reward_flag and cur_value >= self.data.need_chognzhi)
	self.node_list["BtnGetReward"]:SetActive(not fetch_reward_flag)
	self.node_list["ImgRedPoint"]:SetActive(not fetch_reward_flag and cur_value >= self.data.need_chognzhi)

end

function TotalChargeTwoCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end