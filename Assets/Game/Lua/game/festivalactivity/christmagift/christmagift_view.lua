-- 礼物收割
-- ChristmaGiftView

ChristmaGiftView = ChristmaGiftView or BaseClass(BaseRender)

local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE
function ChristmaGiftView:__init()
	
	self.cell_list = {}
	self.left_list = self.node_list["LeftListView"]
	local left_list_delegate = self.left_list.list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.RrankRefreshCell, self)

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["To_kill"].button:AddClickListener(BindTool.Bind(self.OnToKill, self))

	self.item_awd_list = {} 
	local item = ChristmaGiftData.Instance:GetGiftAward()
	for k, v in pairs(item) do
		local item_cell = ItemCell.New()
		item_cell:SetData(item[k])
		item_cell:SetInstanceParent(self.node_list["item1"])
		self.item_awd_list[k] = item_cell
	end
end

function ChristmaGiftView:__delete()
	self.cell_list = nil
	self.task_list = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down_two then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end

	for k,v in pairs(self.item_awd_list) do
		v:DeleteMe()
	end
	self.item_awd_list = nil
end

function ChristmaGiftView:OpenCallBack()
	ChristmaGiftCtrl.Instance:RequestLiWuShouGeInfo()
	self:Flush()
end

function ChristmaGiftView:CloseCallBack()

end

--左边列表
function ChristmaGiftView:GetDataInfo()
	self.rank_data = ChristmaGiftData.Instance:GetRankData()
	self.me_info = ChristmaGiftData.Instance:GetMeData()
end

function ChristmaGiftView:GetNumberOfCells()
	return ChristmaGiftData.Instance:GetRankItemCount() or 0
end
function ChristmaGiftView:SetMeInfo()
	self.node_list["score"].text.text = self.me_info.get_score or 0
	self.node_list["me_rank"].text.text = self.me_info.rank or Language.Common.NoRank
	self.node_list["me_kill"].text.text = self.me_info.kill_num or 0
end

function ChristmaGiftView:RrankRefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = ChristmaViewItem.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	cell_item:SetData(self.rank_data.rank_lsit[data_index], data_index)
end

function ChristmaGiftView:GetTaskNumberOfCells()
	return #self.right_data_list or 0
end

function ChristmaGiftView:TaskRefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.task_list[cell]
	if cell_item == nil then
		cell_item = ChristmaViewItem.New(cell.gameObject)
		self.task_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(self.right_data_list[data_index])
end


function ChristmaGiftView:OnFlush()
	self:GetDataInfo()
	self:SetMeInfo()
	self.left_list.scroller:RefreshAndReloadActiveCellViews(false)
	self:FlushRightTime()
	self:FlushLeftTime()
end

function ChristmaGiftView:GetTime(timr)
	local h  = math.floor(timr / 100)
	local m  = math.floor(timr % 100)
	return TimeUtil.NowDayTimeStart(os.time()) + (h * 60 * 60) + (m * 60) 
end

function ChristmaGiftView:FlushLeftTime()
	local next_day = false
	if self.me_info.round == 0 then
		self.me_info.round = 1
		next_day = true
	end
	local time_cfg = ChristmaGiftData.Instance:GetRoundTime(self.me_info.round or 6)
	if time_cfg == nil then
		return
	end
	local open_time = self:GetTime(time_cfg.round_start_time)
	local end_time = self:GetTime(time_cfg.round_end_time)
	if next_day then
		open_time = open_time + (24 * 60 * 60)
		end_time = end_time + (24 * 60 * 60)
	end
	if self.count_down_two then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end

	local time_mode = 4
	 if open_time - os.time() >= 3600 then
		time_mode = 1
	 else
		time_mode = 4
	 end
	if open_time > os.time() then
		open_time = open_time - 1
		self.node_list["open_time"].text.text = TimeUtil.FormatSecond(open_time - os.time(), time_mode)
	else
		end_time = end_time - 1
		self.node_list["open_time"].text.text = TimeUtil.FormatSecond(end_time - os.time(), time_mode)
	end

	local mode = 4
	self.count_down_two = CountDown.Instance:AddCountDown(9999, 1, function ()
		 if open_time - os.time() >= 3600 then
			mode = 1
		 else
			mode = 4
		 end
		 if open_time > os.time() then
			self.node_list["open_time"].text.text = TimeUtil.FormatSecond(open_time - os.time(), mode)
			self.node_list["Ttile1"]:SetActive(true)
			self.node_list["Ttile2"]:SetActive(false)
		 else
			self.node_list["open_time"].text.text = TimeUtil.FormatSecond(end_time - os.time(), mode)
			self.node_list["Ttile1"]:SetActive(false)
			self.node_list["Ttile2"]:SetActive(true)
		 end
	end)
end

function ChristmaGiftView:FlushRightTime()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)
	local activity_end_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.node_list["count_down_time"].text.text = string.format(Language.ChristmaGift.ShengYuTime, TimeUtil.FormatSecond(activity_end_time, 10))
	self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
		activity_end_time = activity_end_time - 1
		self.node_list["count_down_time"].text.text = string.format(Language.ChristmaGift.ShengYuTime, TimeUtil.FormatSecond(activity_end_time, 10))
	end)
end

function ChristmaGiftView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(327)
end

function ChristmaGiftView:OnToKill()
	ChristmaGiftCtrl.Instance:SendEnterSceneOrEeqData(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE, RA_GIFT_HARVEST_OPERA_TYPE.RA_GIFT_HARVEST_OPERA_TYPE_ENTER_SCENE)
end

------------------------------------------------------------------------
-- ChristmaViewItem

ChristmaViewItem = ChristmaViewItem or BaseClass(BaseRender)

function ChristmaViewItem:__init(instance)
	self.item_cell_list = {}
end
function ChristmaViewItem:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil
 end
 function ChristmaViewItem:SetItem(data_index)
	local awk_cfg = ChristmaGiftData.Instance:GetRankItemAwk(data_index)
	for k,v in pairs(awk_cfg.reward_item) do
		local cell1 = self.item_cell_list[k]
		if cell1 == nil then
			cell1 = ItemCell.New()
		end
		cell1:SetInstanceParent(self.node_list["item1"])
		cell1:SetData(v)
		self.item_cell_list[k] = cell1
	end
 end
function ChristmaViewItem:SetData(data, data_index)
	self:SetItem(data_index)
	if data_index <= 3 then
		self.node_list["RankImage"]:SetActive(true)
		self.node_list["RankText"]:SetActive(false)
		self.node_list["RankImage"].image:LoadSprite(ResPath.GetRankIcon(data_index))
	else
		self.node_list["RankText"].text.text = data_index
		self.node_list["RankImage"]:SetActive(false)
		self.node_list["RankText"]:SetActive(true)
	end
	if data == nil then
		self.node_list["Name"].text.text = Language.Competition.NoRank
		self.node_list["num"].text.text = 0
		self.node_list["Image_res"].image:LoadSprite(ResPath.GetRoleIconBig(40))
		self.node_list["RawImage"]:SetActive(false)
		self.node_list["Image_res"]:SetActive(true)
		return
	end
	
	self.node_list["Name"].text.text = data.name
	self.node_list["num"].text.text = data.cur_get_score
	
	local function download_callback(path)
		if nil == self.node_list["RawImage"] or IsNil(self.node_list["RawImage"].gameObject) then
			return
		end
		
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.node_list["RawImage"].raw_image:LoadSprite(avatar_path,
		function()
			self.node_list["Image_res"]:SetActive(false)
		end)
	end
	CommonDataManager.NewSetAvatar(data.role_id, self.node_list["RawImage"], self.node_list["Image_res"], self.node_list["RawImage"], data.sex, data.prof, false, download_callback)
end