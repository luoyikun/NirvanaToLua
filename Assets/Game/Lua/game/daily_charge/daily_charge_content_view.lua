DailyChargeContentView = DailyChargeContentView or BaseClass(BaseRender)

function DailyChargeContentView:__init(instance)
	DailyChargeContentView.Instance = self
	self.node_list["charge_toggle_10"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ChongZhiClick1, self))
	self.node_list["charge_toggle_99"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ChongZhiClick2, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OnChongZhiClick, self))
	self.node_list["reward_btn"].button:AddClickListener(BindTool.Bind(self.OnRewardClick, self))
	self.node_list["BtnChange"].button:AddClickListener(BindTool.Bind(self.OnSelectRewardClick, self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.select_item_id = 1
	self.item_list = {}
	self.select_item_info = {}

	for i = 1, 5 do
		local handler = function()
			local close_call_back = function()
				self:CancelHighLight()
			end
			if self.item_list and self.item_list[i] then
				self.item_list[i]:ShowHighLight(true)
				TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
			end
		end
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
		self.item_list[i]:ListenClick(handler)
	end

	self.the_cell_list = {}
	self:InitListView()

end

function DailyChargeContentView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.the_cell_list) do
		v:DeleteMe()
	end
	self.the_cell_list = {}

	DailyChargeContentView.Instance = nil

end

function DailyChargeContentView:GetNumberOfCells()
	return #(DailyChargeData.Instance:GetDailyChongzhiTimesRewardAuto() or {})
end

function DailyChargeContentView:InitListView()
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiTimesRewardAuto()[1]
	if reward_cfg and reward_cfg.model_item_id and self.model then
		--self:SetModel(reward_cfg.queen_show_item1)
		self.model:ChangeModelByItemId(reward_cfg.model_item_id)
	end
end

function DailyChargeContentView:SetModel(res)
	self.model:ResetRotation()
	local a, b = ResPath.GetPifengModel(10005001)
	self.model:SetMainAsset(a, b .. "_P")
	self.model:SetRotation(Vector3(0, 180, 0))
end

function DailyChargeContentView:RefreshCell(cell, cell_index)
	local the_cell = self.the_cell_list[cell]
	if the_cell == nil then
		the_cell = AccumulateChargeItem.New(cell.gameObject, self)
		self.the_cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	the_cell:OnFlush(cell_index, CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
end

function DailyChargeContentView:OpenCallBack()
	self:OpenCallBackToDo()
end

function DailyChargeContentView:OpenCallBackToDo()
	local list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward_flag_list
	if list and list[32] == 1 and list[31] ~= 1 then
		self.node_list["charge_toggle_99"].toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99).select_reward_item[0]
	else
		self.node_list["charge_toggle_10"].toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10).select_reward_item[0]
	end
	self:FlushBtnState()
	-- self:SetBtnText()
	self:FlushRedPoints()

	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiTimesRewardAuto()[1]
	if reward_cfg and reward_cfg.model_item_id and self.model then
		--self:SetModel(reward_cfg.queen_show_item1)
		self.model:ChangeModelByItemId(reward_cfg.model_item_id)
	end

	if reward_cfg and reward_cfg.desc then
		local bundle, asset = ResPath.GetDailyChargeContentViewIcon(reward_cfg.desc)
		self.node_list["Image"].image:LoadSprite(bundle, asset, function()
			self.node_list["Image"].image:SetNativeSize()
		end)
	end
end

function DailyChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self:FlushBtnState()
	end
end

function DailyChargeContentView:ChongZhiClick2(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self:FlushBtnState()
	end
end

function DailyChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	-- DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function DailyChargeContentView:OnRewardClick()
	local seq = DailyChargeData.Instance:GetRewardSeq(self.chongzhi_state)
	RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY, seq, 1)
	self.click_chongzhi_state = self.chongzhi_state
end


function DailyChargeContentView:OnSelectRewardClick()
	local item_info_list = DailyChargeData.Instance:GetChongZhiReward(self.chongzhi_state).select_reward_item

	TipsCtrl.Instance:ShowDailySelectItemView(item_info_list,function(select_item_id)
		self.select_item_id = select_item_id

	end)
end

function DailyChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetDailyGiftInfoList(chongzhi_state)
	for i = 1, 5 do
		self.item_list[i]:SetData(item_info_list[i])
	end
	local select_item_list = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).select_reward_item

end

function DailyChargeContentView:OnFlush()
	self:FlushRedPoints()
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:RefreshActiveCellViews()
	end
	if self.click_chongzhi_state == self.chongzhi_state then
		self.click_chongzhi_state = nil
		self:OpenCallBackToDo()
	end
end

function DailyChargeContentView:FlushRedPoints()
	local recharge_cfg = DailyChargeData.Instance:GetChongZhiInfo()
	local recharge = recharge_cfg.daily_chongzhi_value or 0
	local reward_flag_list = recharge_cfg.daily_chongzhi_fetch_reward_flag_list or {}
	if self.node_list["RedPointL"] then
		self.node_list["RedPointL"]:SetActive(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and (next(reward_flag_list) and reward_flag_list[32 - 0] == 0))
	end

	if self.node_list["RedPointR"] then
		self.node_list["RedPointR"]:SetActive(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 and (next(reward_flag_list) and reward_flag_list[32 - 1] == 0))
	end
end

function DailyChargeContentView:FlushBtnState()
	local recharge_cfg = DailyChargeData.Instance:GetChongZhiInfo()
	local recharge = recharge_cfg.daily_chongzhi_value
	local reward_flag_list = recharge_cfg.daily_chongzhi_fetch_reward_flag_list
	local reward_auto_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	if recharge < self.chongzhi_state then
		self.node_list["BtnRecharge"]:SetActive(true)
		self.node_list["reward_btn"]:SetActive(false)
	else
		self.node_list["BtnRecharge"]:SetActive(false)
		self.node_list["reward_btn"]:SetActive(true)

		local index = self.chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and 0 or 1
		-- if self.chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
		-- 	index = 0
		-- elseif self.chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
		-- 	index = 1
		-- end
		if reward_flag_list[32 - index] == 0 then
			self.node_list["text"].text.text = string.format(Language.Common.LingQuJiangLi)
			UI:SetButtonEnabled(self.node_list["reward_btn"], true)
		else
			self.node_list["text"].text.text = string.format(Language.Common.YiLingQu)
			UI:SetButtonEnabled(self.node_list["reward_btn"], false)
		end
	end
	self:OnFlushCellBtn()
end

function DailyChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		if v then
			v:ShowHighLight(false)
		end
	end
end


function DailyChargeContentView:OnFlushCellBtn()
	for k,v in pairs(self.the_cell_list) do
		v:OnFlushBtn()
	end
end


-------------------------------------------------------------------
AccumulateChargeItem = AccumulateChargeItem or BaseClass(BaseCell)
function AccumulateChargeItem:__init()
	
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.node_list["reward_btn"].button:AddClickListener(BindTool.Bind(self.RewardOnClick, self))

	self.fixed_days = 0
	self.current_days = 0
	self.chongzhi_value = 0
	self.index = 0
end

function AccumulateChargeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AccumulateChargeItem:OnFlush(index, chongzhi_value)
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(index)
	if cfg == nil then return end
	self.index = index
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days or 0
	self.fixed_days = cfg.complete_days or 0
	self.chongzhi_value = chongzhi_value
	if current_days >= cfg.complete_days then
		current_days = cfg.complete_days
	end
	self.current_days = current_days
	self.node_list["TxtTitle"].text.text = string.format(Language.FirstCharge.DailyCellName, self.fixed_days, self.current_days, self.fixed_days)
	self.item_cell:SetData(cfg.reward_item)
	self:OnFlushBtn()
end

function AccumulateChargeItem:RewardOnClick()
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(self.index)
	if current_days >= cfg.complete_days then
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY_TIMES, self.index, 0)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.FirstCharge.LeiJiDayNOT)
	end
end

function AccumulateChargeItem:SetToggleGroup(toggle_group)
	self.item_cell:SetToggleGroup(toggle_group)
end

function AccumulateChargeItem:OnFlushBtn()
	local list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_times_fetch_reward_flag_list

	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(self.index)

	if list[32 - self.index] ~= 1 then
		self.node_list["Txtbtn"].text.text = Language.Common.LingQu
		UI:SetButtonEnabled(self.node_list["reward_btn"], current_days >= cfg.complete_days)
	else
		self.node_list["Txtbtn"].text.text = Language.Common.YiLingQu
		UI:SetButtonEnabled(self.node_list["reward_btn"], false)
	end
end







