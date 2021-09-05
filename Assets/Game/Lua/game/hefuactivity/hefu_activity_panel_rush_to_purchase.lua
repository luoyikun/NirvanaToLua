RushToPurchase = RushToPurchase or BaseClass(BaseRender)
--个人抢购 panel_1
function RushToPurchase:__init()
	self.qianggou_buy_num_list = {}
	self.qianggou_rank_list = {}
	self.reward_cell_list = {}
	self.item_cell_list = {}
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
end

function RushToPurchase:OpenCallBack()
	self.first_reward = HefuActivityData.Instance:GetQiangGouFistReward()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.qianggou_list_info = HefuActivityData.Instance:GetQiangGouListInfo()
	RemindManager.Instance:SetRemindToday(RemindName.QiangGou)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)

	local page_simple_delegate = self.node_list["Scroller"].page_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
	self.node_list["Scroller"].list_view:Reload()
	self.node_list["Scroller"].list_view:JumpToIndex(0)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItem"])
	self.item_cell:SetData(self.first_reward or {})
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	local rank_data = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU)
	self.node_list["TxtPurchaseTips"].text.text = string.format(Language.HefuActivity.PurchaseNum, rank_data.rank_limit or 0)
end

function RushToPurchase:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end

	self.item_cell_list = {}

	if self.item_cell ~= nil then
		self.item_cell = nil
	end
end

function RushToPurchase:NumberOfCellsDel()
	return #self.qianggou_list_info 
end

function RushToPurchase:CellRefreshDel(cell_index, cell)
	local item_cell = self.reward_cell_list[cell]

	if nil == item_cell then
		item_cell = RushToPurchaseItem.New(cell.gameObject, self)
		self.reward_cell_list[cell] = item_cell
	end

	self.item_cell_list[cell_index + 1] = item_cell
	item_cell:SetIndex(cell_index)
	item_cell:SetData(self.qianggou_list_info[cell_index + 1])
end

function RushToPurchase:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0' .. v)
			end
		end
		temp[k] = v
	end
	local str = ""
	if temp.day >= 1 then
		str = string.format(Language.JinYinTa.ActEndTime_NEW, temp.day, temp.hour)
	else
		str = string.format(Language.JinYinTa.ActEndTime2_NEW, temp.hour, temp.min, temp.s)
	end
	self.node_list["TxtRestTime"].text.text = str
end

function RushToPurchase:OnFlush()
	self.all_qianggou_buy_num_list = HefuActivityData.Instance:GetQiangGouAllBuyNumList()
	self.qianggou_buy_num_list, self.qianggou_rank_list = HefuActivityData.Instance:GetQiangGouInfo()
	for k,v in pairs(self.item_cell_list) do
		v:SetBuyNum(self.all_qianggou_buy_num_list[k] or 0)
		v:Flush()
	end
	local count = 0
	for k,v in pairs(self.qianggou_buy_num_list) do
		count = count + v
	end
	self.node_list["TxtBuyCount"].text.text =  count
	self.node_list["TxtCostGold"].text.text = CommonDataManager.ConverMoney(self.main_role_vo.gold)
	local is_in_rank = false
	local rank_level = 0
	for k,v in pairs(self.qianggou_rank_list) do
		if v.role_id == self.main_role_vo.role_id then
			is_in_rank = true
			rank_level = k
		end
	end
	if is_in_rank then
		self.node_list["TxtRankLevel"].text.text = string.format(Language.HefuActivity.CurRankLevel_NEW, rank_level)
	else
		self.node_list["TxtRankLevel"].text.text = string.format(Language.HefuActivity.CurRankLevel_NEW, Language.HefuActivity.NotInRank)
	end	
end

function RushToPurchase:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------------RushToPurchaseItem----------------------------------
RushToPurchaseItem = RushToPurchaseItem or BaseClass(BaseCell)
-- RushToPurchaseItem 预制体
function RushToPurchaseItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItem"])
	self.buy_num = 0
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function RushToPurchaseItem:__delete()
	if self.item_cell ~= nil then
		self.item_cell = nil 
	end
end

function RushToPurchaseItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data.stuff_item)
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.stuff_item.item_id)

		local time_str = string.format(Language.HefuActivityItemNameColor[item_cfg.color], item_cfg.name)
		RichTextUtil.ParseRichText(self.node_list["TxtItemName"].rich_text, time_str, 22)

		--self.node_list["TxtItemName"].text.text = item_cfg.name
		local str = ""
		if self.data.limit_num - self.buy_num > 0 then
			str = string.format(Language.OutLine.HeFu_Green,self.data.limit_num - self.buy_num)
		else
			str = string.format(Language.OutLine.HeFu_Red,self.data.limit_num - self.buy_num)
		end
		RichTextUtil.ParseRichText(self.node_list["TxtLastNum"].rich_text, str, 22)

		self.node_list["TxtCostGold"].text.text = self.data.cost
		UI:SetButtonEnabled(self.node_list["BtnBuy"], self.data.limit_num > self.buy_num)
		self.node_list["TxtInBtn"].text.text = self.data.limit_num > self.buy_num and Language.Common.CanPurchase or Language.Common.AlreadyPurchase
	end
end

function RushToPurchaseItem:SetBuyNum(num)
	self.buy_num = num
end

function RushToPurchaseItem:OnClickGet()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU, self:GetIndex())
end