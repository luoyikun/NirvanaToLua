GoldTurntableView = GoldTurntableView or BaseClass(BaseRender)

function GoldTurntableView:__init()
	self.cell_list = {}
	self.item_cell_col_list = {}
	for i = 1, 14 do
		self.item_cell_col_list[i] = self.node_list["Item_" .. i]
	end

	self.turn_do_tween = self.node_list["DoTween"]
	self.ani_toggle = self.node_list["AniToggle"]
	self.last_demond_num = 0

	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelpButton, self))
	self.node_list["AniToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickCloseAni, self))

	self.current_index = 0
	self.turn_num = 0
	self.change_time = 0
	self.roll_time = 0
	self.item_turn = false
	self.is_close_ani = false
	self:InitItemCellList()
	self:InitScroller()
	self:SetRolltime()
	self:Flush()
	
end

function GoldTurntableView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.scroller_list) do
		v.obj = nil
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	if self.time_roll_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_roll_quest)
	end

	self.turn_do_tween = nil
	self.ani_toggle = nil
end

function GoldTurntableView:CloseCallBack()
	TipsFloatingManager.Instance:StartFloating()
end

--设置奖励次数
function GoldTurntableView:SetRewardCount(value)
	UI:SetButtonEnabled(self.node_list["BtnReward"], value > 0)
	self.node_list["TxtRewardCount"].text.text = Language.Welfare.TurnableChouTimes .. value
end

--设置转盘按钮激活状态
function GoldTurntableView:SetRewardBtnAction()
	local count = WelfareData.Instance:GetTurnTableRewardCount()
	if count <= 0 then
		UI:SetButtonEnabled(self.node_list["BtnReward"], false)
	else
		UI:SetButtonEnabled(self.node_list["BtnReward"], true)
	end	
end

--初始化奖品
function GoldTurntableView:InitItemCellList()
	self.cell_list = {}
	local count = 1
	local item_cell_list = WelfareData.Instance:GetGoldTurnTableCfg()
	local count_num = #self.item_cell_col_list
	if item_cell_list and next(item_cell_list) then
		self.gold_turntable_item = {}
		for i = 1, count_num do
			self.gold_turntable_item[i] = GoldTurntableItem.New(self.item_cell_col_list[i])
			self.cell_list[count] = ItemCell.New()
			self.cell_list[count]:SetInstanceParent(self.gold_turntable_item[i]:GetCellObj())
			self.cell_list[count]:SetActive(true)

			local item_data = item_cell_list[i].item
			if item_data.item_id ~= 0 then
				self.cell_list[count]:SetData(item_data)
			elseif item_cell_list[i].jianchi_per == 0 then
				local data = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_GOLD, is_bind = item_data.is_bind, num = item_cell_list[i].zhuanshi}
				self.cell_list[count]:SetData(data)
			elseif item_cell_list[i].jianchi_per ~= 0 then
				local data = {item_id = item_cell_list[i].jiangchi_icon, is_bind = item_data.is_bind, num = item_data.num}
				self.cell_list[count]:SetData(data)
			end

			if item_cell_list[i].is_value == 1 then
				self.cell_list[count]:ShowGetEffect(true)
			end
			
			count = count + 1
		end
	end
end

--初始化老虎机
function GoldTurntableView:InitScroller()
	self.scroller_list = {}
	for i = 1, 7 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self.node_list["Scroller_" .. i]
		self.scroller_list[i].cell = TurntableScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
	end
end

--老虎机转动
function GoldTurntableView:StartRoll(value)
	local scollernum = value
	local speed = 1
	local isturn = WelfareData.Instance:GetIsTurn()
	if not isturn then	
		speed = 0
	end
	for i = 7, 1, -1 do
		self.scroller_list[i].cell:StartScoller(speed, scollernum % 10)
		scollernum = math.floor(scollernum / 10)
	end
	WelfareData.Instance:SetTurnTableIsTurn(false)
end

function GoldTurntableView:SetRolltime()
	self.time_roll_quest = GlobalTimerQuest:AddRunQuest(function()
		self.roll_time = self.roll_time + UnityEngine.Time.deltaTime
		if self.roll_time > 10 then
			WelfareCtrl.Instance:SendTurntableReward(Yuan_Bao_Zhuanpan_OPERATE_TYPE.SET_JC_ZhUANSHI_NUM)
			self.roll_time = 0
		end
	end, 0)
end

function GoldTurntableView:SetYuanbaoNum(demond_num,reward_num)
	if reward_num then
		self:SetRewardCount(reward_num)
	end		

	if demond_num == nil then
		return
	elseif demond_num ~= self.last_demond_num then
		self:StartRoll(demond_num)
		self.last_demond_num = demond_num
	end
end

function GoldTurntableView:StartTurn(value, time)
	if value == nil or self.item_turn then	
		return
	end
	self.item_turn = true
	self.last_index = 1
	value = value + 1
	for k,v in pairs(self.gold_turntable_item) do
		v:SetShowEffect(false)
	end	

	if self.is_close_ani then

		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_YUANBAO_ZHUANPAN)
		TipsFloatingManager.Instance:StartFloating()
		self.gold_turntable_item[value]:SetShowEffect(true)
		self.item_turn = false
		self:SetRewardBtnAction()
	else
		self.turn_do_tween.transform.position = Vector3(self.current_index + 1, 0, 0)
		local tween = self.turn_do_tween.transform:DOMoveX(14 * 2 + value, time)
		tween:SetEase(DG.Tweening.Ease.InOutQuad)
		self.turn_time = 0
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.change_time = self.change_time + UnityEngine.Time.deltaTime
			self.turn_time = self.turn_time + UnityEngine.Time.deltaTime
			if self.change_time > 0.01 then
				self.current_index = math.floor(self.turn_do_tween.transform.position.x % 14 + 0.5)
				if self.current_index == 0 then
					self.current_index = 14
				end
				self.gold_turntable_item[self.last_index]:SetShowEffect(false)
				self.gold_turntable_item[self.current_index]:SetShowEffect(true)
				self.last_index = self.current_index
				self.change_time = 0
			end	
			if self.turn_time > time then
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
				self.item_turn = false
				self:SetRewardBtnAction()

				ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_YUANBAO_ZHUANPAN)
				TipsFloatingManager.Instance:StartFloating()
			end
		end, 0)
	end
	self:FlsuhToggle()
end


function GoldTurntableView:OnClickGetReward()
	if not self.item_turn then
		TipsFloatingManager.Instance:PauseFloating()
		WelfareCtrl.Instance:SendTurntableReward(Yuan_Bao_Zhuanpan_OPERATE_TYPE.CHOU_JIANG)
	end
end

function GoldTurntableView:OnClickHelpButton()
	TipsCtrl.Instance:ShowHelpTipView(185)
end

function GoldTurntableView:OnClickCloseAni()
	self.is_close_ani = not self.is_close_ani
	self:FlsuhToggle()
end

function GoldTurntableView:FlsuhToggle()
	self.ani_toggle.toggle.isOn = self.is_close_ani
end

----道具格子---
GoldTurntableItem = GoldTurntableItem or BaseClass(BaseCell)
function GoldTurntableItem:__init()
end

function GoldTurntableItem:__delete()
end

function GoldTurntableItem:SetShowEffect(enable)
	self.node_list["ImgIsShowEffect"]:SetActive(enable)
end

function GoldTurntableItem:GetCellObj()
	return self.node_list["ItemCell"]
end

-----老虎机格子-----
TurntableScroller = TurntableScroller or BaseClass(BaseCell)

local IconCount = 10
-- 每个格子的高度
local cell_hight = 46
-- 每个格子之间的间距
local distance = 10
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 1289

function TurntableScroller:__init(instance)
	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.rect = self.node_list["Rect"]
	self.do_tween_obj = self.node_list["DoTween"]
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = cell_hight - (original_hight - (cell_hight + 2 * distance)) / 2
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/welfare_prefab", "Icon", nil, function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, IconCount + 3 do
			local obj = U3DObject(ResMgr:Instantiate(prefab))
			local obj_transform = obj.transform
			obj_transform:SetParent(self.rect.transform, false)
			obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
			local res_id = i - 1
			if res_id > IconCount then
				res_id = res_id % IconCount
			end
			if res_id == 10 then
				res_id = 0
			end
			local name_table = obj:GetComponent(typeof(UINameTable))
		local text_icon = U3DObject(name_table:Find("TxtIcon"))
			text_icon.text.text = res_id         
		end
	end)
	self.target_x = 0
	self.target = 1
end

function TurntableScroller:__delete()
	self:RemoveCountDown()
end

function TurntableScroller:OnValueChange(value)
	local x = value.y
end

function TurntableScroller:StartScoller(time, target)
	self.do_tween_obj.transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.do_tween_obj.transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function TurntableScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
	end
end

function TurntableScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function TurntableScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function TurntableScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

---------------------------------------------------------------------
TurntableInfoCell = TurntableInfoCell or BaseClass(BaseCell)
function TurntableInfoCell:__init(instance)
end

function TurntableInfoCell:__delete()
end

function TurntableInfoCell:LoadCallBack()
	self.node_list["Turntable"].button:AddClickListener(BindTool.Bind(self.ClickTurntalbe, self))
end

function TurntableInfoCell:ClickTurntalbe()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

function TurntableInfoCell:SetShowEffect(enable)
	if self.node_list["Effect"] then
		self.node_list["Effect"]:SetActive(enable)
	end
end

function TurntableInfoCell:SetShow(enable)
	if self.node_list["Turntable"] then
		self.node_list["Turntable"]:SetActive(enable)
	end
end