SanShengSanShiView = SanShengSanShiView or BaseClass(BaseRender)
-- 三生三世

-- 最大
local MAX_NUM = 3

function SanShengSanShiView:__init()
	self.contain_cell_list = {}
	self.name_list = {}
end

function SanShengSanShiView:__delete()
	if self.contain_cell_list then
		for k , v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end
end

function SanShengSanShiView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2193, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE)
	-- 结婚名字
	self.name_list = KaifuActivityData.Instance:GetPerfectLoverInfo().ra_perfect_lover_name_list

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)

	self.node_list["TxtChongZhiCount"].text.text = KaifuActivityData.Instance:GetDayChongZhiCount()
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	self.node_list["BtnGoMarry"].button:AddClickListener(BindTool.Bind(self.ClickGoToMarry, self))
	self.node_list["BtnProgress"].button:AddClickListener(BindTool.Bind(self.OpenProgressView, self))
end

function SanShengSanShiView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function SanShengSanShiView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function SanShengSanShiView:ClickGoToMarry()
	ViewManager.Instance:Open(ViewName.Marriage)
end


function SanShengSanShiView:GetNumberOfCells()
	return #self.name_list
end

function SanShengSanShiView:RefreshCell(cell, cell_index)
	
	local contain_cell = self.contain_cell_list[cell]
	
	if contain_cell == nil then
		contain_cell = SanShengSanShiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.name_list[cell_index])
	contain_cell:Flush()
end

function SanShengSanShiView:SetTime(rest_time)
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
		str = string.format(Language.Activity.ActivityTime8, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, temp.hour, temp.min,temp.s)
	end

	self.node_list["TxtActTime"].text.text = str
end

function SanShengSanShiView:OnFlush()
	local now_pro = self:GetTheProgress()
	self.node_list["TxtProgress"].text.text = string.format(Language.Activity.NowProgress, now_pro, MAX_NUM)
	self.node_list["TxtChongZhiCount"].text.text = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	
end

function SanShengSanShiView:GetTheProgress()
	local info = KaifuActivityData.Instance:GetPerfectLoverInfo()
	local count = 0
	if info then
		local bit_list = bit:d2b(info.perfect_lover_type_record_flag)
		for i = 1 , MAX_NUM do
			local is_reach = bit_list[32 - (i - 1)] == 1
			if is_reach then
				count = count + 1
			end
		end
	end
	return count
end

function SanShengSanShiView:OpenProgressView()
	ViewManager.Instance:Open(ViewName.SanShengProgView)
end

------------------------------SanShengSanShiCell-------------------------------------
SanShengSanShiCell = SanShengSanShiCell or BaseClass(BaseCell)

function SanShengSanShiCell:__init()

end

function SanShengSanShiCell:__delete()

end

function SanShengSanShiCell:OnFlush()
	self.data = self:GetData()
	local top_three_flag = self.index <= 3

	self.node_list["ImgRankBack"]:SetActive(false)
	self.node_list["ImgRankIcon"]:SetActive(false)

	if top_three_flag then
		self.node_list["ImgRankBack"].image:LoadSprite(ResPath.GetOpenGameActivityNoPackRes("rank_3s3s_" .. self.index))
		self.node_list["ImgRankIcon"].image:LoadSprite(ResPath.GetOpenGameActivityRes("rank_act_" .. self.index))
	end
	self.node_list["ImgRankBack"]:SetActive(top_three_flag)
	self.node_list["ImgRankIcon"]:SetActive(top_three_flag)
	self.node_list["TxtRank"]:SetActive(not top_three_flag)
	self.node_list["TxtRank"].text.text = self.index

	local str1 = self.data[1] ~= "" and self.data[1] or Language.LingKunBattle.ZanWuZhanLing
	local str2 = self.data[2] ~= "" and self.data[2] or Language.LingKunBattle.ZanWuZhanLing
	self.node_list["TxtGirlName"].text.text = str2
	self.node_list["TxtBoyName"].text.text = str1
end

