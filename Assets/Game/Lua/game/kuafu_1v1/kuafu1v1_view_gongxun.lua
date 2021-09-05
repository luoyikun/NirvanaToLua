KuaFu1v1ViewGongXun = KuaFu1v1ViewGongXun or BaseClass(BaseRender)

function KuaFu1v1ViewGongXun:__init(instance)

	if instance == nil then
		return
	end
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}
end

function KuaFu1v1ViewGongXun:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function KuaFu1v1ViewGongXun:OpenCallBack()
	self:Flush()
end


function KuaFu1v1ViewGongXun:GetNumberOfCells()
	return KuaFu1v1Data.Instance:GetGongXunRewardCount()
end

function KuaFu1v1ViewGongXun:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1
	local jifen_reward = KuaFu1v1Data.Instance:GetJiFenReward()
	local target_cell = self.cell_list[cell]
	if target_cell == nil then
		target_cell = GongXunItemCell.New(cell.gameObject)
		self.cell_list[cell] = target_cell
	end
	target_cell:SetData(jifen_reward[cell_index])
end


function KuaFu1v1ViewGongXun:OnFlush()
	if self.node_list["ListView"].scroller.ScrollPosition ~= 0 then
		self.node_list["ListView"].scroller:ReloadData(0)
	else
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

---------------------------GongXunItemCell----------------------
GongXunItemCell = GongXunItemCell or BaseClass(BaseCell)

function GongXunItemCell:__init()
	self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))

	self.items_list = {}

	for i = 1, 4 do
		self.items_list[i] = ItemCell.New()
		self.items_list[i]:SetInstanceParent(self.node_list["Items"])
	end
end

function GongXunItemCell:__delete()
	for k, v in pairs(self.items_list) do
		v:DeleteMe()
	end
	self.items_list = {}
end

function GongXunItemCell:ClickReward()
	KuaFu1v1Ctrl.Instance:SendGetCross1V1RankRewardReq(CROSS_1V1_FETCH_REWARD_TYPE.CROSS_1V1_FETCH_REWARD_TYPE_SCORE, self.data.seq)
end

function GongXunItemCell:OnFlush()
	self.node_list["TxtShow"]:SetActive(true)
	local item_data = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)
	for i = 1, 4 do
		local cell = self.items_list[i]
		local data = item_data[i]
		if data then
			cell:SetActive(true)
			cell:SetData(data)
		else
			cell:SetActive(false)
		end
	end
	local gongxun_num = KuaFu1v1Data.Instance:GetInfoGongXun()
	local list = KuaFu1v1Data.Instance:GetGongXunRewardIsGet()
	if list[32 - self.data.seq] ~= 1 and gongxun_num >= self.data.need_score then
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["NoFinish"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["ImgIcon"], true)
		gongxun_num = ToColorStr(gongxun_num, TEXT_COLOR.GREEN)
		self.node_list["TxtShow"].text.text = Language.Common.LingQuJiangLi
	else
		gongxun_num = ToColorStr(gongxun_num, TEXT_COLOR.RED)
		if list[32 - self.data.seq] == 1 then
			self.node_list["ImgIcon"]:SetActive(true)
			self.node_list["NoFinish"]:SetActive(false)
			self.node_list["TxtShow"].text.text = Language.Common.YiLingQu
			UI:SetButtonEnabled(self.node_list["ImgIcon"], false)
		else
			self.node_list["ImgIcon"]:SetActive(false)
			self.node_list["NoFinish"]:SetActive(true)
		end
	end

	self.node_list["GongXunNum"].text.text = string.format(Language.Kuafu1V1.GongXunMuBiao, self.data.need_score, gongxun_num, self.data.need_score)
end