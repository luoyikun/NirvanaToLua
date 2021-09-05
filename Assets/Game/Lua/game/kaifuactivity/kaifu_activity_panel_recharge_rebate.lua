KaifuActivityRechargeRebate =  KaifuActivityRechargeRebate or BaseClass(BaseRender)
--充值返利 RechargeRebate
function KaifuActivityRechargeRebate:__init()
	self.contain_cell_list = {}
end

function KaifuActivityRechargeRebate:__delete()
	self.contain_cell_list = nil
end

function KaifuActivityRechargeRebate:OpenCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))

	self.reward_list = KaifuActivityData.Instance:GetKaifuActivityRechargeRebateReward()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
end

function KaifuActivityRechargeRebate:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function KaifuActivityRechargeRebate:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KaifuActivityRechargeRebate:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetKaifuActivityRechargeRebateReward()

	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end

	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	self.node_list["TxtXiaoFeiCount"].text.text = CommonDataManager.ConverMoney(info.chongzhi_gold or 0)
end

function KaifuActivityRechargeRebate:FlushTotalConsume()
	self:Flush()
end

function KaifuActivityRechargeRebate:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}

	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)

	str = TimeUtil.FormatSecond(rest_time, 6)
	self.node_list["TxtLastTime"].text.text = str
end

function KaifuActivityRechargeRebate:GetNumberOfCells()
	return #self.reward_list
end

function KaifuActivityRechargeRebate:RefreshCell(cell, cell_index)
	if self.contain_cell_list == nil then return end
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = KaifuActivityRechargeRebateCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------KaifuActivityRechargeRebateCell---------------------------------
KaifuActivityRechargeRebateCell = KaifuActivityRechargeRebateCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 4

function KaifuActivityRechargeRebateCell:__init()
	self.data = {}
	self.item_cell_list = {}
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

	for i = 1, MAX_CELL_NUM do
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.node_list["CellItem_" .. i])
	end
end

function KaifuActivityRechargeRebateCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function KaifuActivityRechargeRebateCell:SetData(data)
	self.data = data
end

function KaifuActivityRechargeRebateCell:OnFlush()
	if self.data == nil then return end

	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	local cur_value = info ~= nil and info.chongzhi_gold or 0
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)

	local color = cur_value >= self.data.need_gold and "89f201FF" or "FF3939FF"
	local outline = cur_value >= self.data.need_gold and "004b0080" or "4D161680"
	-- self.node_list["TxtCurNextRatio"].text.text = string.format(Language.Activity.ReChargeRewardTips, "", ToColorStr(cur_value, color), ToColorStr(self.data.need_gold, COLOR.GREEN))
	-- self.node_list["TxtRechargeRebate"].text.text = string.format(Language.Activity.RechargeRebateTip, self.data.need_gold)

	-- local str = string.format(Language.OutLine.RechargeRebateTip, self.data.need_gold, cur_value, color, outline, self.data.need_gold)
	-- RichTextUtil.ParseRichText(self.node_list["TxtRechargeRebate"].rich_text, str, 22)
	self.node_list["TxtRechargeRebate"].text.text = self.data.need_gold
	KaifuActivityData.Instance:OutLineRichText(cur_value, self.data.need_gold, self.node_list["TxtCurNextRatio"], 1)
	for i = 1, MAX_CELL_NUM do
		if reward_list and reward_list[i] then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.node_list["CellItem_" .. i]:SetActive(true)
		else
			self.node_list["CellItem_" .. i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	--按钮的状态
	if cur_value < self.data.need_gold then
		self.node_list["TxtInBtn"].text.text = Language.Common.WEIDACHENG
		self.node_list["BtnGetReward"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], false)
		self.node_list["EffectInBtn"]:SetActive(false)
		self.node_list["ImgHasGet"]:SetActive(false)
	elseif not fetch_reward_flag and cur_value >= self.data.need_gold then
		self.node_list["BtnGetReward"]:SetActive(true)
		self.node_list["TxtInBtn"].text.text = Language.Common.LingQu
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], true)
		self.node_list["EffectInBtn"]:SetActive(true)
		self.node_list["ImgHasGet"]:SetActive(false)
	elseif fetch_reward_flag and cur_value >= self.data.need_gold then
		self.node_list["BtnGetReward"]:SetActive(false)
		self.node_list["ImgHasGet"]:SetActive(true)
		self.node_list["EffectInBtn"]:SetActive(false)
	end
end

function KaifuActivityRechargeRebateCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end