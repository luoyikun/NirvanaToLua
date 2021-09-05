JuBaoPenView = JuBaoPenView or BaseClass(BaseView)

function JuBaoPenView:__init()
	-- self.ui_config = {{"uis/views/jubaopen_prefab", "JuBaoPenView"}}
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelThree"},
		{"uis/views/jubaopen_prefab", "JuBaoPenView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function JuBaoPenView:__delete()

end

function JuBaoPenView:LoadCallBack()
	self.switch_roll = false
	self.is_rolling = false
	self.node_list["ImgTitle"].image:LoadSprite("uis/views/jubaopen/images_atlas","title_name",function()
			self.node_list["ImgTitle"].image:SetNativeSize()
		end)

	self.node_list["BtnRoll"].button:AddClickListener(BindTool.Bind(self.ClickRoll, self))
	self.node_list["RollBtn1"].button:AddClickListener(BindTool.Bind(self.ClickRoll, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["ImgBG"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change)
	self:InitScroller()
	self.scroller_list = {}
	for i = 1, 5 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self.node_list["Scroller" .. i]
		self.scroller_list[i].cell = JuBaoPenScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
	end
	self.roll_bar_anim = self.node_list["RollBar"]:GetComponent(typeof(UnityEngine.Animator))
	self.need_anim_back = false
	self.can_roll = false
	self.complete_list = {}

end

function JuBaoPenView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	if self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end

	if self.is_rolling then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO)
	end
	self.scroller_list = {}
	self.cell_list = {}
	self.roll_bar_anim = nil
	self:RemoveCountDown()
end

function JuBaoPenView:OpenCallBack()
	self:FlushPrice()
	self:FlushCharge()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO)
	self:FlushRestTime()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushRestTime, self))
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	JuBaoPenData.Instance:SetFirstOpen(false)
	RemindManager.Instance:Fire(RemindName.JuBaoPen)
	if self.need_anim_back then
		self.roll_bar_anim:SetTrigger("Back")
		self.need_anim_back = false
	end
end

-- function JuBaoPenView:CloseCallBack()
-- 	self:RemoveCountDown()
-- end

-- function JuBaoPenView:HandleAddGold()
-- 	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
-- 	ViewManager.Instance:Open(ViewName.VipView)
-- end

function JuBaoPenView:PlayerDataChangeCallback(attr_name, value, old_value)
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- if attr_name == "gold" then
	-- 	local count = vo.gold
	-- 	-- self.node_list["Txt"].text.text = CommonDataManager.ConverMoney(count)
	-- end
end

function JuBaoPenView:ClickRoll()
	-- if self.is_rolling then
	-- 	return
	-- end
	if self.can_roll then
		self.is_rolling = true
	-- else
	-- 	self.is_rolling = false
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Player.NoHaveShengYin)
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD)
end

function JuBaoPenView:FlushPrice()
	local cur_lun = JuBaoPenData.Instance:GetRewardLun()
	local price, max_gold = JuBaoPenData.Instance:GetNeedChargeByLun(cur_lun)
	-- self.node_list["TxtMaxGold"].text.text = max_gold
	self.node_list["TxtNeedCharge1"].text.text = max_gold
	self.node_list["MaxNum"].text.text = max_gold
	if max_gold > 0 then
		self.node_list["TxtNeedCharge"]:SetActive(true)
		self.node_list["Img"]:SetActive(true)
	end
end

-- 刷新当前充值金额
function JuBaoPenView:FlushCharge()
	local history_chongzhi = JuBaoPenData.Instance:GetHistoryChongZhi() or 0
	local cur_lun = JuBaoPenData.Instance:GetRewardLun()
	local price = JuBaoPenData.Instance:GetNeedChargeByLun(cur_lun)
	local color = TEXT_COLOR.WHITE
	if history_chongzhi < price then
		color = TEXT_COLOR.RED
	end
	self.node_list["TxtCharge"].text.text = ToColorStr(CommonDataManager.ConverMoney(history_chongzhi), color)
	self.node_list["TxtNeedCharge"].text.text = CommonDataManager.ConverMoney(price)
	if price == 0 then
		self.node_list["TxtNeedCharge"].text.text = Language.Common.IsAllGet
		self.node_list["TxtButton"].text.text = Language.JuBaoPen.TxtButton
		UI:SetButtonEnabled(self.node_list["BtnRoll"],false)
		-- UI:SetGraphicGrey(self.node_list["BtnRoll"], true)
		self.node_list["NeedCharge"]:SetActive(false)
		self.node_list["NeedCharge1"]:SetActive(false)
		self.node_list["Img"]:SetActive(false)
		
	end
	local need_charge = price - history_chongzhi
	if need_charge > 0 then
		self.can_roll = false
	else
		self.can_roll = true
	end
	need_charge = math.max(0, need_charge)
	self.node_list["TxtCharge"].text.text = CommonDataManager.ConverMoney(need_charge)
	if self.node_list["RewardScroller"].scroller.isActiveAndEnabled then
		self.node_list["RewardScroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function JuBaoPenView:StartRoll(reward_gold)
	if self.switch_roll then
		return
	end
	self.switch_roll = true
	local num_list = {}
	while (reward_gold > 0) do
		table.insert(num_list, math.floor(reward_gold % 10))
		reward_gold = math.floor(reward_gold / 10)
	end
	for i = 1, 5 do
		local num = num_list[i] or 0
		num = num + 1
		self.scroller_list[5 - i + 1].cell:StartScoller(2 + 0.5 * i, num, 129 + 10 * i)
	end
	self.roll_bar_anim:SetTrigger("Roll")
end

function JuBaoPenView:OnFlush(param_list)
	self:FlushPrice()
	for k,v in pairs(param_list) do
		if k == "roll" then
			self:StartRoll(v[1])
		elseif k == "charge" then
			self:FlushCharge()
		end
	end
end

function JuBaoPenView:FlushRestTime()
	if self:IsOpen() then
		local time = 0
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) then
		 time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) or 0
		end
			if time <= 0 then
			if self.time_quest then
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
			end
		end

		if time > 3600 * 24 then
			self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
		elseif time > 3600 then
			self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 1))
		else
			self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 4))
		end
	end
end

function JuBaoPenView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function JuBaoPenView:InitScroller()
	self.cell_list = {}
	self.node_list["RewardScroller"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["RewardScroller"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function JuBaoPenView:GetNumberOfCells()
	local record_list = JuBaoPenData.Instance:GetRecordList()
	return #record_list
end

function JuBaoPenView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = JuBaoPenRecordInfo.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local record_list = JuBaoPenData.Instance:GetRecordList()
	local data = record_list[data_index + 1]
	group_cell:SetData(data)
end

-- 转动完毕回调
function JuBaoPenView:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.is_rolling = false
		self.switch_roll = false
		self.complete_list = {}
		self.roll_bar_anim:SetTrigger("Back")
		if not self.is_real_open then
			self.need_anim_back = true
		end
		-- 动画播完后通知服务端下发奖励
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO)
	end
end

-- 检查转盘是否全部滚动完毕
function JuBaoPenView:CheckComplete()
	local flag = true
	for i = 1, 5 do
		if not self.complete_list[i] then
			flag = false
			break
		end
	end
	return flag
end
------------------------------------------JuBaoPenScroller--------------------------------------------

JuBaoPenScroller = JuBaoPenScroller or BaseClass(BaseCell)

local IconCount = 10
-- 每个格子的高度
local cell_hight = 45
-- 每个格子之间的间距
local distance = 15

function JuBaoPenScroller:__init(instance)
	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.node_list["DoTween"].transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = 0
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.node_list["Rect"].rect.sizeDelta = Vector2(self.node_list["Rect"].rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local async_loader = AllocAsyncLoader(self, "scroller_loader")
	async_loader:Load("uis/views/jubaopen_prefab", "Icon", function(prefab)
		if IsNil(prefab) then
			return
		end
		for i = 1, IconCount + 3 do
			local obj = U3DObject(ResMgr:Instantiate(prefab))
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["Rect"].transform, false)
			obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
			local res_id = i - 1
			if res_id > IconCount then
				res_id = res_id % IconCount
			end
			if res_id == 0 then
				res_id = IconCount
			end
			local name_table = obj:GetComponent(typeof(UINameTable))
			if name_table then
				local icon_obj = U3DObject(name_table:Find("Icon"), nil, self)
				icon_obj.image:LoadSprite(ResPath.GetJuBaoPenIcon(res_id))
			end
		end
	end)

	self.target_x = 0
	self.target = 1
end

function JuBaoPenScroller:__delete()
	self:RemoveCountDown()
end

function JuBaoPenScroller:OnValueChange(value)
	local x = value.y
end

function JuBaoPenScroller:StartScoller(time, target, movement_distance)
	target = target - 1
	self.node_list["DoTween"].transform.position = Vector3(self.target, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.node_list["DoTween"].transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function JuBaoPenScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.node_list["DoTween"].transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
	end
end

function JuBaoPenScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function JuBaoPenScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function JuBaoPenScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

------------------------------------------JuBaoPenRecordInfo--------------------------------------------

JuBaoPenRecordInfo = JuBaoPenRecordInfo or BaseClass(BaseCell)

function JuBaoPenRecordInfo:__init()
end

function JuBaoPenRecordInfo:__delete()

end

function JuBaoPenRecordInfo:OnFlush()
	if self.data then
		self.node_list["Txt"].text.text = string.format(Language.JuBaoPen.Info, self.data.user_name, self.data.need_put_gold, self.data.reward_gold)
	end
end