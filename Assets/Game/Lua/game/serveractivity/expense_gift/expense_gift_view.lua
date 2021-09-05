ExpenseNiceGift = ExpenseNiceGift or BaseClass(BaseRender)

function ExpenseNiceGift:__init(instance)
	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.reward_pool_panel = ExpenseRewardPoolPanel.New(ViewName.ExpenseNiceGiftRewardPool)

	self.scroller_list = {}
	for i = 1, 3 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self.node_list["Scroller" .. i]
		self.scroller_list[i].cell = ExpenseNiceGiftScroller.New(self.scroller_list[i].obj, i)	
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
	end
	self.node_list["OneBtn"].button:AddClickListener(BindTool.Bind(self.OneClick, self))
	self.node_list["RollBtn1"].button:AddClickListener(BindTool.Bind(self.OneClick, self))
	self.node_list["BtnShop"].button:AddClickListener(BindTool.Bind(self.GoToShop, self))
	self.node_list["TenBtn"].button:AddClickListener(BindTool.Bind(self.TenClick, self))
	--self.node_list["RewardBtn"].button:AddClickListener(BindTool.Bind(self.ReWardPoolClick, self))

	self.cancel_ani_toggle = self.node_list["CancelAniToggle"]
	self.left_roll_times = self.node_list["left_roll_times"]
	self.consume_gold = self.node_list["consume_gold"]
	self.act_time = self.node_list["act_time"]
	self.complete_list = {}
	self.ten_reward_list = {}
	self.ten_reward_gold_list = {}
	self.is_rolling = false
	self.roll_bar_anim = self.node_list["RollBar"]:GetComponent(typeof(UnityEngine.Animator))
	self.need_anim_back = false
	self.is_ten = false

end

function ExpenseNiceGift:__delete()
	if self.reward_pool_panel then
		self.reward_pool_panel:DeleteMe()
		self.reward_pool_panel = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.cell_list = nil
	end
	for k,v in pairs(self.scroller_list) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end

	self.ten_reward_list = {}

	self.ten_reward_gold_list = {}

	if self.time_count ~= nil then
		CountDown.Instance:RemoveCountDown(self.time_count)
		self.time_count = nil
	end
	self.roll_bar_anim = nil
end

function ExpenseNiceGift:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	local time = KaifuActivityData.Instance:GetDayTime()
	self:FlushNextTime(time)
	if self.time_count == nil then
		self.time_count = CountDown.Instance:AddCountDown(time, 1, 
		function (elapse_time, total_time)
			if total_time > elapse_time then
				local temptime = TimeUtil.FormatSecond(total_time - elapse_time)
				if self.node_list["act_time"] then
					self.node_list["act_time"].text.text = tostring(temptime)
				end
			end
		end)
	end
end

function ExpenseNiceGift:GoToShop()
	ViewManager.Instance:Open(ViewName.Shop)
end

function ExpenseNiceGift:FlushNextTime(time)
	time = time - 1
	local temptime = TimeUtil.FormatSecond(time - 1)
	if self.node_list["act_time"] then
		self.node_list["act_time"].text.text = tostring(temptime)
	end
end

function ExpenseNiceGift:RefreshView(cell, data_index)
	data_index = data_index + 1
	local cfg = ExpenseGiftData.Instance:GetExpenseGiftList()
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = ExpenseRewardCell.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg[data_index])
	end	
end

function ExpenseNiceGift:GetNumberOfCells()
	local expense_gift_cfg = ExpenseGiftData.Instance:GetExpenseGiftConfig()
	local num = expense_gift_cfg and GetListNum(expense_gift_cfg) or 0
	return num
end


function ExpenseNiceGift:ReWardPoolClick()
	ViewManager.Instance:Open(ViewName.ExpenseNiceGiftRewardPool)
end


function ExpenseNiceGift:OnFlush(param_list)
	if self.need_anim_back then
		self.roll_bar_anim:SetTrigger("Back")
		self.need_anim_back = false
	end
	if self.list_view and self.list_view.scroller then
		self.list_view.scroller:ReloadData(0)
	end
	local gift_info = ExpenseGiftData.Instance:GetExpenseNiceGiftInfo()
	if gift_info then
		local str = string.format(Language.Activity.ExpenseRewardNum, gift_info.left_roll_times)
		RichTextUtil.ParseRichText(self.left_roll_times.rich_text, str, 22)
		self.consume_gold.text.text = gift_info.consum_gold
	end
end

function ExpenseNiceGift:RollClick()
	if self.is_rolling then
		return
	end
	if not self.is_rolling then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL)
	end
	if self.can_roll then
		self.is_rolling = true
	end
end

function ExpenseNiceGift:OneClick()
	self.is_ten = false
	if self.is_rolling then
		return
	end
	if not self.is_rolling then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL)
	end
	if self.can_roll then
		self.is_rolling = true
	end
end

function ExpenseNiceGift:TenClick()
	self.is_ten = true
	if self.is_rolling then
		return
	end
	if not self.is_rolling then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL_TEN)
	end
	if self.can_roll then
		self.is_rolling = true
	end

end

-- 转动完毕回调
function ExpenseNiceGift:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.is_rolling = false
		self.complete_list = {}
		self.roll_bar_anim:SetTrigger("Back")
		if not self.is_real_open then
			self.need_anim_back = true
		end
		-- 动画播完后通知服务端下发奖励
		if self.is_ten then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL_REWARD_TEN)
			self.is_ten = false
		else
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL_REWARD)
		end
		
	end
end

-- 检查转盘是否全部滚动完毕
function ExpenseNiceGift:CheckComplete()
	local flag = true
	for i = 1, 2 do --动画3暂时不要
		if not self.complete_list[i] then
			flag = false
			break
		end
	end
	return flag
end

function ExpenseNiceGift:StartRoll()
	local data = ExpenseGiftData.Instance:GetRollGiftInfo()
	if not data then return end
	self.is_rolling = true
	local reward_gold = data.reward_gold
	local index = data.seq
	local cancel_ani = self.cancel_ani_toggle.toggle.isOn
	local num_list = {}
	while (reward_gold > 0) do
		table.insert(num_list, math.floor(reward_gold % 10))
		reward_gold = math.floor(reward_gold / 10)
	end
	for i = 1, 3 do
		local num = num_list[i] or 0
		num = num + 1
		local time = cancel_ani and 0 or 2 + 0.5 * i
		local movement_distance = i < 3 and 129 + 10 * i or 90 + 10 * i
		if i == 3 then
			num = index + 7
		end
		if i ~= 3 then --暂时只有一个物品先屏蔽物品的动画
			self.scroller_list[i].cell:StartScoller(time, num, movement_distance)
		end
		
	end
	if not cancel_ani then
		self.roll_bar_anim:SetTrigger("Roll")
	end
end

function ExpenseNiceGift:StartTenRoll()
	self.ten_reward_list, self.ten_reward_gold_list = ExpenseGiftData.Instance:GetRollGiftTenInfo()
	self.is_rolling = true
	local cancel_ani = self.cancel_ani_toggle.toggle.isOn
	local num_list = {}

	for i = 1, GameEnum.MAX_COUNT do
		while (self.ten_reward_gold_list[i] > 0) do
			table.insert(num_list, math.floor(self.ten_reward_gold_list[i] % 10))
			self.ten_reward_gold_list[i] = math.floor(self.ten_reward_gold_list[i] / 10)
		end
	end
	
	for i = 1, 3 do
		local num = num_list[i] or 0
		num = num + 1
		local time = cancel_ani and 0 or 2 + 0.5 * i
		local movement_distance = i < 3 and 129 + 10 * i or 90 + 10 * i
		if i == 3 then
			for i = 1 ,GameEnum.MAX_COUNT do
				num = self.ten_reward_list[i] + 7
			end
		end
		if i ~= 3 then --暂时只有一个物品先屏蔽物品的动画
			self.scroller_list[i].cell:StartScoller(time, num, movement_distance)
		end
		
	end
	if not cancel_ani then
		self.roll_bar_anim:SetTrigger("Roll")
	end
end

ExpenseRewardCell = ExpenseRewardCell or BaseClass(BaseCell)
local Btn_State = {
	ChongZhi = 1 , 
	CanGet = 2 , 
	HasGet = 3 , 
}

function ExpenseRewardCell:__init()
	self.cur_btn_state = Btn_State.ChongZhi

	self.chongzhi_value_text = self.node_list["chongzhi_value_text"]
	self.btn_text = self.node_list["Text"]

	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end

	self.node_list["ChargeBtn"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self))
end

function ExpenseRewardCell:__delete()
	if self.item_cell_list then
		for i = 1, 3 do
			if self.item_cell_list[i] then
				self.item_cell_list[i]:DeleteMe()
				self.item_cell_list[i] = nil
			end
		end
		self.item_cell_list = nil
	end
end

function ExpenseRewardCell:OnFlush()
	if not self.data then return end

	local need_gold  = self.data.need_gold or 0
	local reward_item = self.data.reward_item

	local str = string.format(Language.Activity.ExpenseRewardText, need_gold)
	RichTextUtil.ParseRichText(self.chongzhi_value_text.rich_text, str)
	--self.chongzhi_value_text.text.text = string.format(Language.Activity.ExpenseRewardText, need_gold)
	if reward_item then
		for i = 1, 3 do
			self.item_cell_list[i]:SetActive(reward_item[i - 1] ~= nil)
			if reward_item[i - 1] then
				self.item_cell_list[i]:SetData(reward_item[i - 1])
			end
		end
	end
	local gift_info = ExpenseGiftData.Instance:GetExpenseNiceGiftInfo()
	if gift_info then
		self.node_list["NodeEffect"]:SetActive(false)
		local flag = ExpenseGiftData.Instance:ExpenseInfoRewardCanFetchFlagByIndex(self.data.seq)
		if gift_info.consum_gold < need_gold then
			self.cur_btn_state = Btn_State.ChongZhi
			self.btn_text.text.text = Language.Common.WEIDACHENG
		elseif flag == 0 and gift_info.consum_gold >= need_gold then
			self.cur_btn_state = Btn_State.CanGet
			self.btn_text.text.text = Language.Common.ExpenseLingQu
			self.node_list["NodeEffect"]:SetActive(true)
		else
			self.cur_btn_state = Btn_State.HasGet
			self.btn_text.text.text = Language.Common.YiLingQu
		end
		self.node_list["ImgHasGet"]:SetActive(flag == 1)
		self.node_list["ChargeBtn"]:SetActive(flag ~= 1)
	end

	local flag = ExpenseGiftData.Instance:ExpenseInfoRewardCanFetchFlagByIndex(self.data.seq + 1)
	UI:SetButtonEnabled(self.node_list["ChargeBtn"], self.cur_btn_state == Btn_State.CanGet)
end

function ExpenseRewardCell:OnButtonClick()
	if (not self.data) or (not self.data.seq) then return end
	if self.cur_btn_state == Btn_State.ChongZhi then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif self.cur_btn_state == Btn_State.CanGet then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_FETCH, self.data.seq)
	end
end
-------------------------------------------------------------------------------------------------------------
------------------------------------------ExpenseNiceGiftScroller--------------------------------------------
-------------------------------------------------------------------------------------------------------------

ExpenseNiceGiftScroller = ExpenseNiceGiftScroller or BaseClass(BaseCell)

function ExpenseNiceGiftScroller:__init(instance, index)
	if instance == nil then
		return
	end
	self.IconCount = 10
	-- 每个格子的高度
	self.cell_hight = 35
	-- 每个格子之间的间距
	self.distance = 20

	self.item_cell_list = {}
	local size = self.cell_hight + self.distance
	self.rect = self.node_list["Rect"]
	self.do_tween_obj = self.node_list["DoTween"]
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = -10
	local hight = (self.IconCount + 3) * size + (self.cell_hight - offset * 2)
	local asset, bundle = "uis/views/jubaopen_prefab", "Icon"

	if index == 3 then
		self.cell_hight = 80
		self.distance = 35
		offset = -40
		local reward_cfg = ExpenseGiftData.Instance:GetRollReward()
		self.IconCount = reward_cfg and #reward_cfg or 0
		size = self.cell_hight + self.distance
		hight = (self.IconCount + 3) * size + (self.cell_hight - offset * 2)
		asset, bundle = "uis/views/serveractivity/expensenicegift_prefab", "SlotsCell"
	end
	self.percent = size / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(0, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load(asset, bundle, nil, function(prefab)
		if nil == prefab then
			 return
		end
		local cfg = ExpenseGiftData.Instance:GetRollReward()
		if cfg then
			for i = 1, self.IconCount + 3 do
				local obj = U3DObject(ResMgr:Instantiate(prefab))
				local obj_transform = obj.transform
				obj_transform:SetParent(self.rect.transform, false)
				obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)

				if index == 3 then
					self.item_cell_list[i] = ItemCell.New()
					self.item_cell_list[i]:SetInstanceParent(obj)
					local item = self.item_cell_list[i]
					if i > self.IconCount then
						i = i % self.IconCount
					end
					local reward_index = ExpenseGiftData.Instance:GetCurActTheme()
					local reward_cfg = ExpenseGiftData.Instance:GetRewardItemCfg(reward_index)
					if reward_cfg then
						item:SetData(reward_cfg)
					end
				else
					local res_id = i - 1
					if res_id > self.IconCount then
						res_id = res_id % self.IconCount
					end
					if res_id == 0 then
						res_id = self.IconCount
					end
					local name_table = obj:GetComponent(typeof(UINameTable))
					if name_table then
						local icon_obj = U3DObject(name_table:Find("Icon"), nil, self)
						icon_obj.image:LoadSprite(ResPath.GetExpenseNiceGiftIcon(res_id))
					end
			    end
	        end
	    end
    end)
    self.target_x = 0
    self.target = 1
end

function ExpenseNiceGiftScroller:__delete()
	self:RemoveCountDown()

	for _,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function ExpenseNiceGiftScroller:OnValueChange(value)
	local x = value.y
end

function ExpenseNiceGiftScroller:StartScoller(time, target, movement_distance)
	self.do_tween_obj.transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target - 1 or 1
	if self.target == 1 then
		self.target = self.IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.do_tween_obj.transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function ExpenseNiceGiftScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % self.IconCount)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % self.IconCount)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
	end
end

function ExpenseNiceGiftScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function ExpenseNiceGiftScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function ExpenseNiceGiftScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end