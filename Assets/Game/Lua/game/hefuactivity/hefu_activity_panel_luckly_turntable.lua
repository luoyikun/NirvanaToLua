LucklyTurntable = LucklyTurntable or BaseClass(BaseRender)
--幸运转盘 panel_2 
local Max_Reward_Num = 7

function LucklyTurntable:__init()
	self.info_list = HefuActivityData.Instance:GetLucklyTurnTableInfo()
end

function LucklyTurntable:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	RemindManager.Instance:SetRemindToday(RemindName.LucklyTurn)

	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL)
	self:SetTime(rest_time)

	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)

	self.needle_is_role = false
	self.reward_cell_list = {}
	self.hight_light_list = {}
	self.hight_frame_list = {}
	for i = 0, Max_Reward_Num do
		local rewardCell = self.node_list["NodeItemList"].transform:GetChild(i).gameObject
		rewardCell = LucklyTurntableRewardCell.New(rewardCell)
		rewardCell:SetIndex(i+1)
		rewardCell:SetData(self.info_list[i].reward_item)
		table.insert(self.reward_cell_list, rewardCell)
		local hight_light = self.node_list["NodeHightLights"].transform:GetChild(i).gameObject
		hight_light:SetActive(false)
		table.insert(self.hight_light_list, hight_light)
		--当选中的时候框发光
		local hight_frame = self.node_list["NodeItemList"].transform:GetChild(i).transform:GetChild(0).gameObject
		hight_frame:SetActive(false)
		table.insert(self.hight_frame_list,hight_frame)
	end

	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickAddMoney, self))

	local chongzhi_count, total_chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()
	local left_times = math.floor(chongzhi_count / HefuActivityData.Instance:GetRollCost())

	local left_times_color = left_times 	--ToColorStr(left_times, TEXT_COLOR.GREEN)
	if left_times <= 0 then
		left_times_color = left_times  	--ToColorStr(left_times, TEXT_COLOR.RED)
	end
	
	self.node_list["TxtHasRecharge"].text.text = CommonDataManager.ConverMoney(total_chongzhi_count)
	self.node_list["TxtLastTurnCount"].text.text = string.format(Language.HefuActivity.CanTurnCount, left_times_color or 0) 
	self.has_click = false 
end

function LucklyTurntable:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end

	self.hight_frame_list = {}

	self.reward_cell_list = nil
end

function LucklyTurntable:SetTime(rest_time)
	local time_str = ""
	if rest_time > 3600 * 24 then
		time_str = ToColorStr(TimeUtil.FormatSecond(rest_time, 6), TEXT_COLOR.GREEN_4)
	else
		time_str = ToColorStr(TimeUtil.FormatSecond(rest_time, 0), TEXT_COLOR.GREEN_4)
	end
	self.node_list["TxtRestTime"].text.text = time_str
end

function LucklyTurntable:ShowAnimation(index, time)
	if self.node_list["ToggleSkipAnim"].toggle.isOn then
		-- 如果屏蔽了动画 
		self.node_list["NodeCenterPoint"].transform.localRotation = Quaternion.Euler(0, 0, -(index-1) * 45 - 67.5)
		self:OnComplete(index)
		self.hight_light_list[index + 1]:SetActive(true)
		self.hight_frame_list[index + 1]:SetActive(true)
		return
	end

	if self.needle_is_role == true then
		return
	end
	self.needle_is_role = true
	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	if nil == time then
		time = 4
	end

	local angle = (index-1) * 45 + 67.5
	self.tween = self.node_list["NodeCenterPoint"].transform:DORotate(
		Vector3(0, 0, -360 * time - angle),
		time,
		DG.Tweening.RotateMode.FastBeyond360)
	
	self.tween:SetEase(DG.Tweening.Ease.OutQuart)
	self.tween:OnComplete(function ()
		TipsFloatingManager.Instance:StartFloating()
		self.needle_is_role = false
		self.hight_light_list[index + 1]:SetActive(true)
		self.hight_frame_list[index + 1]:SetActive(true)
		self:OnComplete(index)
	end)
end

function LucklyTurntable:OnComplete(reward_index)
	local item_data = self.info_list[reward_index]
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.reward_item.item_id)
	local str = string.format(Language.HefuActivity.AddItem, SPRITE_SKILL_LEVEL_COLOR[item_cfg.color], item_cfg.name, item_data.reward_item.num)
	TipsCtrl.Instance:ShowFloatingLabel(str)
	
	if item_data.is_broadcast == 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL, CSA_ROLL_OPERA.CSA_ROLL_OPERA_BROADCAST, item_data.reward_item.item_id)
	end
end

function LucklyTurntable:ClickReChange()
	if self.needle_is_role == true then
		return
	end

	if self.has_click == true then
		return 
	end

	local chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()

	if chongzhi_count >= HefuActivityData.Instance:GetRollCost() then
		self.has_click = true
	else
		self.has_click = false
	end

	HefuActivityData.Instance:SetLucklyTurnClick(false)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL, CSA_ROLL_OPERA.CSA_ROLL_OPERA_ROLL)
end

function LucklyTurntable:ClickAddMoney()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LucklyTurntable:OnFlush(parm_t)
	local has_click = HefuActivityData.Instance:GetLucklyTurn()
	if self.has_click == true then
		self:FlushNeedle()
	end

	if has_click == true then
		self:FlushNeedle()
	end

	if self.node_list["ToggleSkipAnim"] then
		HefuActivityData.Instance:SetLucklyTurnToggle(self.node_list["ToggleSkipAnim"].toggle.isOn)
	end
	


	local chongzhi_count, total_chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()
	local left_times = math.floor(chongzhi_count / HefuActivityData.Instance:GetRollCost())

	local left_times_color = ToColorStr(left_times, TEXT_COLOR.GREEN)
	if left_times <= 0 then
		left_times_color = ToColorStr(left_times, TEXT_COLOR.RED)
	end

	self.node_list["TxtHasRecharge"].text.text = CommonDataManager.ConverMoney(total_chongzhi_count)
	self.node_list["TxtLastTurnCount"].text.text = string.format(Language.HefuActivity.CanTurnCount, left_times_color or 0) 
end

function LucklyTurntable:FlushNeedle()
	self.has_click = false
	for k,v in pairs(self.hight_light_list) do
		v:SetActive(false)
	end

	for k,v in pairs(self.hight_frame_list) do
		v:SetActive(false)
	end

	self:ShowAnimation(HefuActivityData.Instance:GetTurntableIndex())
end

----------------------------------------LucklyTurntableRewardCell---------------------------------------------------
LucklyTurntableRewardCell = LucklyTurntableRewardCell or BaseClass(BaseCell)

function LucklyTurntableRewardCell:__init()
	self.node_list["ToggleCellItem"].button:AddClickListener(BindTool.Bind(self.OnClick,self))
	self.data_click = nil
end

function LucklyTurntableRewardCell:OnFlush()
	self.data = self:GetData()
 	if next(self.data) then
 		self:SetData(self.data)
 	end
end

function LucklyTurntableRewardCell:SetData(data)
	if nil == data then
		return
	end
	self.data_click = data
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle,asset)
end

function LucklyTurntableRewardCell:OnClick()
	--直接使用父类的点击方法
	local data = self.data_click
	if data == nil then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end

	local from_view = data.from_view
	local param_t = data.param_t
	local close_call_back = data.close_call_back
	
	TipsCtrl.Instance:OpenItem(data, from_view, param_t, close_call_back, self.show_the_random, self.gift_id, self.is_check_item, self.is_tian_sheng)
end

