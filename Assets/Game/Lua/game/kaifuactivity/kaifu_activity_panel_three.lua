KaifuActivityPanelThree = KaifuActivityPanelThree or BaseClass(BaseRender)

local MAX_GROUP_NUM = 6

function KaifuActivityPanelThree:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.cell_list = {}
	self.cur_index = 1
	self.cur_cond = 1
	self.activity_type = -1
	self.temp_activity_type = 0

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnRechargePlus"].button:AddClickListener(BindTool.Bind(self.OnClickChongzhi,self))
end

function KaifuActivityPanelThree:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.cur_index = nil
	self.cur_cond = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaifuActivityPanelThree:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN, 0)
	self:Flush()
end

function KaifuActivityPanelThree:GetNumberOfCells()
	return #self:GetShowCfgList(self.cur_cond)
end

function KaifuActivityPanelThree:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = RechanageCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local temp1, cond = 0, 0

	if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
		temp1, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end
	local type_list = KaifuActivityData.Instance:SortList(self.activity_type, self:GetShowCfgList(self.cur_cond))
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[data_index + 1].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[data_index + 1].seq, self.activity_type)
	cell_item:SetData(type_list[data_index + 1], cond, is_get_reward, is_complete, self.activity_type)
	cell_item:SetRoleCount(cond)
end

function KaifuActivityPanelThree:OnClickChongzhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KaifuActivityPanelThree:OnClickBtn(index, cond)
	self.cur_index = index
	self.cur_cond = cond
	self.node_list["ScrollerListView"].scroller:ReloadData(0)
	self:FlushListView()
end

function KaifuActivityPanelThree:GetShowCfgList(cond)
	local list = {}
	if not cond then return list end
	local activity_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	for k, v in pairs(activity_list) do
		if v.cond2 == cond then
			table.insert(list, v)
		end
	end
	return list
end

function KaifuActivityPanelThree:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)

	if activity_info == nil then return end
	local activity_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local temp_list = {}
	local cond_list = {}

	for k, v in pairs(activity_list) do
		if not temp_list[v.cond2] then
			temp_list[v.cond2] = v.cond2
			table.insert(cond_list, v.cond2)
		end
	end

	table.sort(cond_list, function(a, b)
		return a < b
	end)

	if self.temp_activity_type ~= activity_type then
		for k, v in pairs(cond_list) do
			self.node_list["BtnGroupPurchase" .. k].toggle:AddClickListener(BindTool.Bind(self.OnClickBtn, self, k, v))
		end
	end

	for i = 1, MAX_GROUP_NUM do
		if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) and cond_list[i] then
			self.node_list["TxtGroupNum" .. i].text.text = string.format(Language.Activity.FirstGroupBuy, cond_list[i])
			self.node_list["TxtHightGroupNum" .. i].text.text = string.format(Language.Activity.FirstGroupBuy, cond_list[i])
		end
	end

	self.cur_cond = cond_list[self.cur_index]
	self.node_list["BtnGroupPurchase" .. self.cur_index].toggle.isOn = true

	for i = 1, MAX_GROUP_NUM do
		self.node_list["ImgRedPoint" .. i]:SetActive(false)
	end

	for k, v in pairs(cond_list) do
		local list = self:GetShowCfgList(v)
		for i , j in ipairs(list) do
			if not KaifuActivityData.Instance:IsGetReward(j.seq, self.activity_type) and
				KaifuActivityData.Instance:IsComplete(j.seq, self.activity_type) then
				self.node_list["ImgRedPoint" .. k]:SetActive(true)
				break
			end
		end
	end

	local temp1, cond = 0, 0
	if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
		temp1, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end
	local gold_num = CommonDataManager.ConverMoney(temp1)
	self.node_list["TxtPersonNum"].text.text =  cond
	self.node_list["TxtCurDiamonds"].text.text = gold_num

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)
	self:FlushListView()
end

function KaifuActivityPanelThree:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local diff_time = math.floor(diff_time - elapse_time + 0.5)

			if diff_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time = TimeUtil.FormatSecond(diff_time, 10)
			self.node_list["TxtChongZhiLastTime"].text.text =  time
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function KaifuActivityPanelThree:FlushListView()
	if self.activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type
end



RechanageCell = RechanageCell or BaseClass(BaseRender)

function RechanageCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["CellRewardItem"])
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function RechanageCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function RechanageCell:OnClickGet()
	if KaifuActivityData.Instance:IsComplete(self.data.seq, self.activity_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.data.seq)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function RechanageCell:SetData(data, cond, is_get_reward, is_complete, activity_type)
	if data == nil then return end
	self.data = data
	self.activity_type = activity_type
	local title_description = string.gsub(data.description, "%[.-%]", function (title_description)
			local change_str = data[string.sub(title_description, 2, -2)]
			return change_str
		end)

	local description = ""

	if data.cond1 == 0 then
		description = data.description_1
	else
		description = string.gsub(data.description_1, "%[.-%]", function (description)
			local change_str = data[string.sub(description, 2, -2)]
			return change_str
		end)
	end

	title_description = string.format(title_description, cond)
	self.node_list["TxtMainDescride"].text.text = description
	self.node_list["TxtTitleDescride"].text.text = title_description

	if is_get_reward ~= nil then
		self.node_list["ImgLingQu"]:SetActive(is_get_reward)
		self.node_list["BtnGetReward"]:SetActive(not is_get_reward)

	end

	self.item:SetData(data.reward_item[0])
	self.node_list["NodeEffect"]:SetActive(not is_get_reward and is_complete)
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], is_complete)
end



function RechanageCell:SetRoleCount(cond)
	if cond == nil then return end
	self.node_list["TxtRechangeNum"].text.text =  cond
end
