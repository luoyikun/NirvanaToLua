DanBiChongZhiView = DanBiChongZhiView or BaseClass(BaseRender)
function DanBiChongZhiView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}

end

function DanBiChongZhiView:__delete()
	self:CloseCallBack()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.contain_cell_list = {}
	end
end

function DanBiChongZhiView:OpenCallBack()
	KaifuActivityData.Instance:InitSingleChargeOne()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local end_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0)
	self.reward_list = KaifuActivityData.Instance:GetSingleCfgInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	self:SetTime(end_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(end_time, 1, function ()
			end_time = end_time - 1
			self:SetTime(end_time)
	end)
end

function DanBiChongZhiView:PanelClick()
	KaifuActivityData.Instance:SetIsOpen(true)
	RemindManager.Instance:Fire(RemindName.OnLineDanBi)
end

function DanBiChongZhiView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end


function DanBiChongZhiView:GetNumberOfCells()
	return GetListNum(self.reward_list)
end

function DanBiChongZhiView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = KuanHuanDanBiChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	
	local cfg = KaifuActivityData.Instance:GetSingleInfoById(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0)
	if nil == cfg then
		return
	end

	local reward_type = KaifuActivityData.Instance:GetRewardType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0)
	local reward_time = KaifuActivityData.Instance:GetSingleRewardTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0, cell_index)
	self.node_list["Tips1"]:SetActive(reward_type)
	self.node_list["Tips2"]:SetActive(not reward_type)
	contain_cell:SetType(reward_type)

	contain_cell:SetRewardTime(reward_time)
	contain_cell:SetData(self.reward_list[cell_index])

	cell_index = cell_index + 1
end

function DanBiChongZhiView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str
	if temp.day > 0 then
		str = string.format(Language.OutLine.ActivityTime1, temp.day, temp.hour)
	else
		str = string.format(Language.OutLine.ActivityTime2, temp.hour, temp.min,temp.s)
	end
		RichTextUtil.ParseRichText(self.node_list["TxtRestTime"].rich_text, str)
	-- self.node_list["TxtRestTime"].text.text = str
end

function DanBiChongZhiView:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetSingleCfgInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0)
	self.node_list["ScrollerListView"].scroller:ReloadData(0)
end

------------------------------KuanHuanDanBiChongZhiCell-------------------------------------
KuanHuanDanBiChongZhiCell = KuanHuanDanBiChongZhiCell or BaseClass(BaseCell)
function KuanHuanDanBiChongZhiCell:__init()
	self.reward_type = 0
	self.cfg = nil
	self.cell_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function KuanHuanDanBiChongZhiCell:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.cell_list = {}
	end

	self.cfg = nil
end

function KuanHuanDanBiChongZhiCell:SetType(reward_type)
	self.reward_type = reward_type
end

function KuanHuanDanBiChongZhiCell:SetRewardTime(reward_time)
	self.reward_time_num = reward_time
end

function KuanHuanDanBiChongZhiCell:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["LingQuTxt"]:SetActive(self.reward_type)
	local color_get = self.reward_time_num == 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
	self.node_list["LingQuTxt"].text.text = string.format(Language.Activity.ShengYuTxt, ToColorStr(self.reward_time_num, color_get))

	self.node_list["ListView"].scroller:ReloadData(0)

	local str = string.format(Language.Activity.DanBiChongZhiTips, self.data.charge_value)
	RichTextUtil.ParseRichText(self.node_list["TxtTipsChongZhiNum"].rich_text, str, 20)

	if self.reward_type then
		self.node_list["TxtTipsLoginCenGet"].text.text = Language.Activity.ChongZhiDesc2
	else
		self.node_list["TxtTipsLoginCenGet"].text.text = Language.Activity.ChongZhiDesc
	end
end

function KuanHuanDanBiChongZhiCell:GetNumberOfCells()
	local reward_item = self.data.reward_item
	self.cfg = ItemData.Instance:GetGiftItemListByProf(reward_item.item_id)
	local num = GetListNum(self.cfg)
	return num
end

function KuanHuanDanBiChongZhiCell:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local list_cell = self.cell_list[cell]
	if nil == list_cell then
		list_cell = KuanHuanDanBiChongZhiItem.New(cell)
		self.cell_list[cell] = list_cell
	end

	list_cell:SetData(self.cfg[data_index])
end

function KuanHuanDanBiChongZhiCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

------------------------------KuanHuanDanBiChongZhiItem---------------
KuanHuanDanBiChongZhiItem = KuanHuanDanBiChongZhiItem or BaseClass(BaseCell)

function KuanHuanDanBiChongZhiItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function KuanHuanDanBiChongZhiItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function KuanHuanDanBiChongZhiItem:OnFlush()
	if nil == self.data then
		return
	end

	self.item_cell:SetData(self.data)
end