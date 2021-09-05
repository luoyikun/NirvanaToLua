--无双装备宝箱
TianshenhutiBoxView = TianshenhutiBoxView or BaseClass(BaseRender)

function TianshenhutiBoxView:__init()
	self.next_time = 0

	for i = 1, 3 do
		self.node_list["OnClickDraw" .. i].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self, i))
	end

	self.item_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TianshenhutiBoxView:LoadCallBack(instance)
	self.node_list["PlayAniToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickPlayAniToggle, self))

	local box_look_cfg = TianshenhutiData.Instance:GetBoxLookCfg()
	if box_look_cfg then
		self.item_look_list = {}
		for i = 1, #box_look_cfg do
			local item = ItemCell.New()
			item:SetInstanceParent(self.node_list["Item_" .. i])
			item:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, item))
			local equip_cfg = TianshenhutiData.Instance:GetEquipCfg(box_look_cfg[i].equip_id)
			if equip_cfg then
				local item_data = {}
				item_data.item_id = equip_cfg.item_id
				item_data.suit_id = equip_cfg.equip_id
				item:SetData(item_data)
			end
			self.item_look_list[i] = item
		end
	end
end

function TianshenhutiBoxView:OnClickEquipItem(item)
	local data = item:GetData()
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_TIANSHENHUTI_EQUIP)
end

function TianshenhutiBoxView:__delete()
	if self.free_timer then
		GlobalTimerQuest:CancelQuest(self.free_timer)
		self.free_timer = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TianshenhutiBoxView:OpenCallBack()
	self:ItemDataChangeCallback()
	self:Flush()
end

function TianshenhutiBoxView:CloseCallBack()

end

function TianshenhutiBoxView:UITween()
	UITween.MoveShowPanel(self.node_list["BgBottom"], Vector3(-53, -500, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ImageTip"], Vector3(-700, 67, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["IconXianShi"], Vector3(-363, 450, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["EquipShowPanel"], Vector3(900, 46, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["BoxIcon"], true, 0.5, DG.Tweening.Ease.InExpo)
end

function TianshenhutiBoxView:OnClickDraw(index)
	TianshenhutiCtrl.SendTianshenhutiRoll(index)
end

function TianshenhutiBoxView:OnClickPlayAniToggle()
	TianshenhutiData.Instance:SetPlayAniState(not self.node_list["PlayAniToggle"].toggle.isOn)
end

function TianshenhutiBoxView:GetNumberOfCells()
	local cfg = TianshenhutiData.Instance:GetRewardItemCfg()
	return #cfg
end

function TianshenhutiBoxView:RefreshCell(cell, data_index)
	local cfg = TianshenhutiData.Instance:GetRewardItemCfg()
	data_index = data_index + 1
	local the_cell = self.item_list[cell]

	if nil ~= cfg then
		if the_cell == nil then
			the_cell = RewardBoxItem.New(cell.gameObject)
			self.item_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg[data_index])
	end
end

function TianshenhutiBoxView:OnFlush(param_t)
	self.node_list["ListView"].scroller:ReloadData(0)
	local data = TianshenhutiData.Instance
	local other_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").other[1]
	local need_store = other_cfg.common_roll_cost
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	local zhekou = TianshenhutiData.Instance:GetBoxZheKou()
	local cur_score = data:GetRollScore()
	local color = need_store > cur_score and "#ff0000" or "#00ff00"
	self.node_list["ScoreText_1"].text.text = string.format(Language.Tianshenhuti.LuckyDrawStr, color, cur_score, need_store)
	local super_roll_cost = other_cfg.super_roll_cost
	local batch_roll_cost = other_cfg.batch_roll_cost

	if 0 == week_number or 6 == week_number then
		super_roll_cost = math.ceil(super_roll_cost * (zhekou / 100))
		batch_roll_cost = math.ceil(batch_roll_cost * (zhekou / 100))
	end

	local gold = GameVoManager.Instance:GetMainRoleVo().gold
	color = super_roll_cost > gold and "#ff0000" or "#00ff00"
	self.node_list["GoldStr"].text.text = string.format("<color=%s>%d</color>", color, super_roll_cost)
	color = batch_roll_cost > gold and "#ff0000" or "#00ff00"
	self.node_list["Gold5Str"].text.text = string.format("<color=%s>%d</color>", color, batch_roll_cost)

	local max_free_time = other_cfg.free_times
	local used_times = data:GetFreeTimes()
	local reward_times = data:GetRewardTimes()
	-- self.node_list["Scroll"]:SetActive(0 == week_number or 6 == week_number) 	--屏蔽累抽奖励
	self.node_list["Textzhekou"].text.text = zhekou / 10
	self.next_time = data:GetNextFlushTime()
	local free_count = self.next_time > TimeCtrl.Instance:GetServerTime() and 0 or max_free_time - used_times
	self.node_list["ScoreText_1"]:SetActive(free_count <= 0)
	self.node_list["ScoreText_3"]:SetActive(free_count > 0)

	self.node_list["reward_times"].text.text = reward_times
	self.node_list["CanScoreDraw"]:SetActive(free_count > 0 or cur_score >= need_store)
	if self.next_time > TimeCtrl.Instance:GetServerTime() and max_free_time - used_times > 0 then
		if self.free_timer == nil then
			self.free_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		if self.free_timer then
			GlobalTimerQuest:CancelQuest(self.free_timer)
			self.free_timer = nil
		end
		self.node_list["ScoreText_2"].text.text = ""
	end
end

-- 背包物品数量变化后调用
function TianshenhutiBoxView:ItemDataChangeCallback()
	local other_cfg = TianshenhutiData.Instance:GetTianshenhutiOherCfg()
	if other_cfg and other_cfg.super_roll_item_id and other_cfg.batch_roll_item_id and other_cfg.super_roll_item_num and other_cfg.batch_roll_item_num then
		local super_roll_item_num = ItemData.Instance:GetItemNumInBagById(other_cfg.super_roll_item_id)
		local is_have_key_one = super_roll_item_num >= other_cfg.super_roll_item_num
		self.node_list["Key_2"]:SetActive(is_have_key_one)
		self.node_list["Remind_2"]:SetActive(is_have_key_one)
		self.node_list["Gold_2"]:SetActive(not is_have_key_one)
		self.node_list["Text_Key_2"].text.text = tostring("X" .. super_roll_item_num)
		local batch_roll_item_num = ItemData.Instance:GetItemNumInBagById(other_cfg.batch_roll_item_id)
		local is_have_key_two = batch_roll_item_num >= other_cfg.batch_roll_item_num
		self.node_list["Key_3"]:SetActive(is_have_key_two)
		self.node_list["Remind_3"]:SetActive(is_have_key_two)
		self.node_list["Gold_3"]:SetActive(not is_have_key_two)
		self.node_list["Text_Key_3"].text.text = tostring("X" .. batch_roll_item_num)
	end
end

function TianshenhutiBoxView:FlushNextTime()
	local time = self.next_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 then
			self.node_list["ScoreText_2"].text.text = string.format(Language.Tianshenhuti.BoxFreeText, TimeUtil.FormatSecond(time, 1))
		else
			self.node_list["ScoreText_2"].text.text = string.format(Language.Tianshenhuti.BoxFreeText, TimeUtil.FormatSecond(time, 2))
		end
	else
		self:Flush()
	end
end

-------------------------------------------
RewardBoxItem = RewardBoxItem or BaseClass(BaseCell)
function RewardBoxItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function  RewardBoxItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RewardBoxItem:OnFlush()
	if nil == self.data then
		return
	end

	local reward_times = TianshenhutiData.Instance:GetRewardTimes()
	self.node_list["AccumulateTimes"].text.text = self.data.accumulate_times .. Language.Tianshenhuti.Ci
	self.item_cell:SetData(self.data.reward_show[0])
	if reward_times >= self.data.accumulate_times then
		self.item_cell:ShowHaseGet(true)
	end
end