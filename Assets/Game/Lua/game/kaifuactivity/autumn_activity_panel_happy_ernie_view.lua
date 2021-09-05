AutumnHappyErnieView = AutumnHappyErnieView or BaseClass(BaseRender)

local MAX_RARE_SHOW_NUM = 6
local MAX_BUTTON_NUM = 3

local HAPPYERNIE_OPERATE_PARAM = {
	[1] = RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_1,
	[2] = RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_10,
	[3] = RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_30,
}
local HAPPYERNIE_CHESTSHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1,
	[2] = CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10,
	[3] = CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30,
}

function AutumnHappyErnieView:__init()
   	--self.timer = self:FindVariable("timer")
	--self.free_time = self:FindVariable("free_timer")
	--self.total_count = self:FindVariable("total_count")
	--self.key_num = self:FindVariable("key_num")
	--self.is_have_key = self:FindVariable("is_have_key")
	--self.red_point = self:FindVariable("is_red_point")
	self.next_free_time = true
	self.is_free = false
	--self.diamond_num_list = {}
	self.draw_lot_ani = {}
	for i = 1, 3 do
		--self.diamond_num_list[i] = self:FindVariable("diamond_num_"..i)
		self.draw_lot_ani[i] = self.node_list["draw_lot_"..i]
	end

	-- 保底奖励
	self.reward_list = self.node_list["ShowListView"]
	local list_delegate = self.reward_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLengthsOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.happy_ernie_reward_item_list = {}

	-- 珍稀展示
	self.rare_reward_list = {}
	for i = 1, MAX_RARE_SHOW_NUM do
		self.rare_reward_list[i] = ItemCell.New()
		local obj = self.node_list["total_reward_"..i]
		self.rare_reward_list[i]:SetInstanceParent(obj)
		self.rare_reward_list[i]:SetIndex(i)
	end

	for i = 1, MAX_BUTTON_NUM do
		--self:ListenEvent("OnClick"..i, BindTool.Bind(self.OnClickDraw, self, i))
		self.node_list["OnClick"..i].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self, i))
	end
	
	self:Flush()
	self.node_list["OnWareHoseClick"].button:AddClickListener(BindTool.Bind(self.OnWareHoseClick, self, i))
	self.node_list["OnLuckerClick1"].button:AddClickListener(BindTool.Bind(self.OnClickLucker, self))
	self.node_list["OnLuckerClick2"].button:AddClickListener(BindTool.Bind(self.OnClickLucker, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
	--self:ListenEvent("OnCloseClick", BindTool.Bind(self.OnCloseClick, self))
	--self:ListenEvent("OnWareHoseClick", BindTool.Bind(self.OnWareHoseClick, self))
	--self:ListenEvent("OnLuckerClick", BindTool.Bind(self.OnClickLucker, self))
end

function AutumnHappyErnieView:OpenCallBack()
	
end

function AutumnHappyErnieView:__delete()
   	--self.timer = nil
	--self.free_time = nil
	--self.total_count = nil
	--self.key_num = nil
	--self.is_have_key = nil
	--self.red_point = nil
	self.next_free_time = true
	self.is_free = false

	for i=1, 3 do
		--self.diamond_num_list[i] = nil
		self.draw_lot_ani[i] = nil
	end
	--self.diamond_num_list = {}
	self.draw_lot_ani = {}

	for k,v in pairs(self.rare_reward_list) do
		v:DeleteMe()
	end
	self.rare_reward_list = {}

	for k,v in pairs(self.happy_ernie_reward_item_list) do
		v:DeleteMe()
	end
	self.happy_ernie_reward_item_list = {}
	self.reward_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self:ClearClickDelay()
end

function AutumnHappyErnieView:GetLengthsOfCell()
	return #KaifuActivityData.Instance:GetHappyErnieRewardItemConfig()
end

--刷新奖励格子
function AutumnHappyErnieView:RefreshCell(cell, cell_index)
	local item_cell = self.happy_ernie_reward_item_list[cell]
	if nil == item_cell then
		item_cell = AutumnHappyErnieRewardItem.New(cell.gameObject, self)
		self.happy_ernie_reward_item_list[cell] = item_cell
	end
	local data_list = KaifuActivityData.Instance:GetHappyErnieRewardItemConfig()
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data_list[cell_index + 1])
end

--刷新
function AutumnHappyErnieView:OnFlush()
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	--读取消费的钻石数量
	local draw_gold_list = KaifuActivityData.Instance:GetHappyErnieDrawCost()
	if nil ~= draw_gold_list then
		self.node_list["diamond_num_1"].text.text = draw_gold_list.once_gold
		self.node_list["diamond_num_2"].text.text = draw_gold_list.tenth_gold
		self.node_list["diamond_num_3"].text.text = draw_gold_list.thirtieth_gold
	end

	--读取珍稀展示配置
	local ernie_rare_show = KaifuActivityData.Instance:GetHappyErnieCfgByList()
	for i = 1, MAX_RARE_SHOW_NUM do
		if ernie_rare_show == nil or nil == ernie_rare_show[i] then
			break
		end
		self.rare_reward_list[i]:SetData(ernie_rare_show[i].reward_item )
	end

	self.reward_list.scroller:ReloadData(0)

	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	--抽奖次数进度
	local draw_times = KaifuActivityData.Instance:GetChouTimes() or 0
	self.node_list["total_count"].text.text = draw_times
	local key_num, key_cfg = KaifuActivityData.Instance:GetHappyErnieKeyNum()
	if nil ~= key_cfg then
		local can_active = key_num > 0
		self.node_list["GoldText0"]:SetActive(not can_active)
		self.node_list["key_num"]:SetActive(can_active)
		local key_color = key_cfg.color
		local key_name = key_cfg.name
		local key_str = ToColorStr(key_name.."X"..key_num, SOUL_NAME_COLOR[key_color])
		self.node_list["key_num"].text.text = key_str
	end

	--免费次数
	local next_free_tao_timestamp = KaifuActivityData.Instance:GetNextFreeTaoTimestamp()
	if next_free_tao_timestamp == 0 then
		self.next_free_time = false
		self.is_free = false
		self.node_list["GoldText"]:SetActive(not self.is_free)
		self.node_list["FreeText"]:SetActive(self.is_free)
		self.node_list["free_timer"]:SetActive(false)
		self.node_list["is_red_point"]:SetActive(false)
	elseif next_free_tao_timestamp ~= nil then
		self.next_free_time = true
		-- self.node_list["free_timer"]:SetActive(not self.is_free)
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time - next_free_tao_timestamp >= 0 then
			self:FlushFreeTime()
		else
			self.count_down = CountDown.Instance:AddCountDown(next_free_tao_timestamp - server_time, 1, BindTool.Bind(self.FlushCountDown, self))
		end
	end
end

--计时器
function AutumnHappyErnieView:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self.node_list["is_red_point"]:SetActive(false)
		self.is_free = false
		self.node_list["GoldText"]:SetActive(not self.is_free)
		self.node_list["FreeText"]:SetActive(self.is_free)
		self.node_list["free_timer"]:SetActive(true)
		self.node_list["free_timer"].text.text = TimeUtil.FormatSecond2HMS(time_interval) .. Language.HappyErnie.FreeTime
	else
		self:FlushFreeTime()
	end
end

function AutumnHappyErnieView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2)
end

function AutumnHappyErnieView:FlushFreeTime()
	self.is_free = true
	self.node_list["GoldText"]:SetActive(not self.is_free)
	self.node_list["FreeText"]:SetActive(self.is_free)
	self.node_list["free_timer"]:SetActive(not self.is_free)
	self.node_list["is_red_point"]:SetActive(true)
	self.node_list["free_timer"].text.text = Language.HappyErnie.TreasureHunt[1]
end

function AutumnHappyErnieView:GetRewardCount()
	return #KaifuActivityData.Instance:GetHappyErnieRewardItemConfig()
end

function AutumnHappyErnieView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_str = ""
	time_str = TimeUtil.FormatSecond(time, 10)
	-- if time > 3600*24 then
	-- 	time_str = TimeUtil.FormatSecond(time, 7)
	-- elseif time > 3600 then
	-- 	time_str = TimeUtil.FormatSecond(time, 1)
	-- else
	-- 	time_str = TimeUtil.FormatSecond(time, 4)
	-- end
	self.node_list["timer"].text.text = string.format("<color=#00ff06>%s</color>", time_str)
end


function AutumnHappyErnieView:OnCloseClick()
	self:Close()
end

function AutumnHappyErnieView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function AutumnHappyErnieView:ClearClickDelay()
	if self.send_delay then
		GlobalTimerQuest.CancelQuest(self.send_delay)
		self.send_delay = nil
	end
end

function AutumnHappyErnieView:OnClickDraw(index)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2
	local operate_type = RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO
	local param_1 = HAPPYERNIE_OPERATE_PARAM[index]
	KaifuActivityData.Instance:SetChestShopMode(HAPPYERNIE_CHESTSHOP_MODE[index])
	self.draw_lot_ani[index].animator:SetTrigger("draw")

	self:ClearClickDelay()
	self.send_delay = GlobalTimerQuest:AddDelayTimer(function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, operate_type, param_1)
		end, 0.4)
end

function AutumnHappyErnieView:OnClickLucker()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2)
	self:Flush()
end


-------------------------------------------保底奖励-------------------------------------------------------
AutumnHappyErnieRewardItem = AutumnHappyErnieRewardItem or BaseClass(BaseCell)
function AutumnHappyErnieRewardItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])

	--self.accumulate_times = self:FindVariable("AccumulateTimes")
	--self.is_got = self:FindVariable("IsGot")
	--self.can_get = self:FindVariable("CanGet")

	--self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickReward, self))
	self.node_list["CanGet"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.seq = 0
end

function AutumnHappyErnieRewardItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AutumnHappyErnieRewardItem:SetIndex(index)
	self.index = index
end

function AutumnHappyErnieRewardItem:SetData(data)
	if nil == data then return end
	self.item_cell:SetData(data.reward_item)

	self.seq = data.index
	local is_got = KaifuActivityData.Instance:GetIsFetchFlag(self.seq)
	local can_get_times = KaifuActivityData.Instance:GetCanFetchFlagByIndex(self.seq)
	local draw_times = KaifuActivityData.Instance:GetChouTimes()
	self.node_list["IsGot"]:SetActive(is_got)
	self.node_list["CanGet"]:SetActive(draw_times >= can_get_times and not is_got)
	self.node_list["AccumulateTimes"].text.text = string.format(Language.Activity.CiShu, can_get_times)
end

function AutumnHappyErnieRewardItem:OnClickReward()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_FETCH_REWARD, self.seq)
end