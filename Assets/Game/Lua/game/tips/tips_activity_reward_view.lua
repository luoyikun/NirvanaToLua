TipsActivityRewardView = TipsActivityRewardView or BaseClass(BaseView)

function TipsActivityRewardView:__init()
	self.ui_config = {{"uis/views/tips/rewardtips_prefab", "ActivityRewardTips"}}
	self.item_list = {}
	self.data = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.id = 0
	self.activity_type = 0
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsActivityRewardView:ReleaseCallBack()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
end

function TipsActivityRewardView:CloseCallBack()
	if self.ok_callback then
		self.ok_callback()
	end
end

function TipsActivityRewardView:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.ClickConfirm, self))
	self.node_list["BtnXianMengShuChu"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))

	self.cell_list = {}
	for i = 1, 5 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
	local list_view_delegate = self.node_list["List"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function TipsActivityRewardView:GetNumberOfCells()
	local num = #self.data.reward_list or 0
	return num
end

function TipsActivityRewardView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = RewardItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local data = self.data.reward_list
	if data then
		group_cell:SetData(data[data_index + 1])
	end
end

function TipsActivityRewardView:CloseView()
	self:Close()
end

function TipsActivityRewardView:ClickConfirm()
	self:Close()
end

-- 打开仙盟输出展示面板
function TipsActivityRewardView:OnClickGuildShowView()
	self:Close()
	GuildCtrl.Instance:OpenGuildShowView(self.activity_type)
end

-- id为传过来的活动id
function TipsActivityRewardView:SetData(data, id, ok_callback, activity_type)
	self.id = id or 0
	self.data = data or {}
	self.ok_callback = ok_callback
	self.activity_type = activity_type or 0
	self:Open()
	self:Flush()
end

function TipsActivityRewardView:OnFlush()
	if self.data.reward_list then
		local reward_list = self.data.reward_list or {}
		for k,v in pairs(self.item_list) do
			if reward_list[k] then
				v:SetData(reward_list[k])
			end
			v:SetParentActive(reward_list[k] ~= nil)
		end
		self.node_list["Rewards"]:SetActive(#self.data.reward_list <= 5)
		self.node_list["Scroll"]:SetActive(#self.data.reward_list > 5)
	end


	local text = self.data.reward_text or ""
	self.node_list["TxtRewardText"].text.text = text

	self.node_list["ImgActivityEnd"]:SetActive(self.id == 0)
	self.node_list["ImgFinish"]:SetActive(self.id == 1)

	self.node_list["BtnXianMengShuChu"]:SetActive(false)
	if self.activity_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		self.node_list["BtnXianMengShuChu"]:SetActive(true)
	end
end

----------RewardItemCell----------
RewardItemCell = RewardItemCell or BaseClass(BaseCell)
function RewardItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function RewardItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RewardItemCell:OnFlush()
	if nil == self.data then return end
	self.item_cell:SetData(self.data)
end
