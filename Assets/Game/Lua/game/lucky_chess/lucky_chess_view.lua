LuckyChessView = LuckyChessView or BaseClass(BaseView)

local OUT_SIDE_COUNT = 25
local IN_SIDE_COUNT = 13

-- 0元宝，1物品，2内圈，3双开
local REWARD_TYPE = {
	GOLD = 0,
	ITEM = 1,
	INSIDE = 2,
	DOUBLE = 3,
}

-- 动画圈数，时间
local ANI_LOOP = 2
local ANI_TIME = 6

function LuckyChessView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/randomact/luckychess_prefab", "LuckyChessView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.auto_buy_flag_list = {
		["auto_type_1"] = false,
		["auto_type_10"] = false,
	}
end

function LuckyChessView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	
	BaseView.Open(self)
end

function LuckyChessView:LoadCallBack()
	-- local bundle, asset = "uis/views/randomact/luckychess/images_atlas", "icon_title"
	-- self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.node_list["Name"].text.text = Language.Title.ZhenBao
	--获取外部格子
	self.out_side_cell_list = {}
	self.out_cell_select_list = {}
	local out_side_cfg = LuckyChessData.Instance:GetLuckOutsideReward()
	if out_side_cfg then
		for i = 0, OUT_SIDE_COUNT do
			local cell = LuckyChessCell.New(self.node_list["OutCell" .. i].gameObject)
			cell:SetData(out_side_cfg[i])
			self.out_side_cell_list[i] = {cell = cell, obj = self.node_list["OutCell" .. i]}
			self.out_cell_select_list[i] = self.node_list["SelectImg" .. i]
		end
	end

	--获取内部格子
	self.in_side_cell_list = {}
	self.in_cell_select_list = {}
	local in_side_cfg = LuckyChessData.Instance:GetLuckInsideReward()
	if in_side_cfg then
		for i = 0, IN_SIDE_COUNT do
			local cell = LuckyChessCell.New(self.node_list["InCell" .. i].gameObject)
			cell:SetData(in_side_cfg[i])
			self.in_side_cell_list[i] = {cell = cell, obj = self.node_list["InCell" .. i]}
			self.in_cell_select_list[i] = self.node_list["InSelectImg" .. i]
		end
	end

	self.list_data = LuckyChessData.Instance:GetReturnRewardCfg()
	self.cell_list = {}
	local list_simple_delegate = self.node_list["ListView"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnOne"].button:AddClickListener(BindTool.Bind(self.ClickOne, self))
	self.node_list["BtnTen"].button:AddClickListener(BindTool.Bind(self.ClickTen, self))
	self.node_list["BtnOpen"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self.node_list["AniToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickCloseAni, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickTip, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
	
	self.turn_do_tween = self.node_list["TurnObj"]
	self.turn_do_tween1 = self.node_list["TurnObj1"]
	self.turn_do_tween2 = self.node_list["TurnObj2"]
	self.change_time = 0
	self.change_time_1 = 0
	self.change_time_2 = 0
	self.target_index = 0
	self.is_out_side_type = true
	self.is_close_ani = false
	self.cur_cell_list = {}
	self:OnFlush()
	self.new_speed = 1
end

function LuckyChessView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in ipairs(self.out_side_cell_list) do
		v.cell:DeleteMe()
	end
	self.out_side_cell_list = {}

	for _, v in ipairs(self.in_side_cell_list) do
		v.cell:DeleteMe()
	end
	self.in_side_cell_list = {}
	self.out_cell_select_list = {}
	self.in_cell_select_list = {}
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_1 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_1)
	end

	if self.time_quest_22 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
	end

	if self.time_quest_21 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
	end

	self.turn_do_tween = nil
	self.turn_do_tween1 = nil
	self.turn_do_tween2 = nil
	self.target_index = 0
	self.is_out_side_type = true
	self.cur_cell_list = {}
	self.is_onclick_req = false
end

function LuckyChessView:GetCellNumber()
	return #self.list_data
end

function LuckyChessView:OnClickCloseAni()
	self.is_close_ani = not self.is_close_ani
	self:FlsuhToggle()
end

function LuckyChessView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
end

function LuckyChessView:FlsuhToggle()
	self.node_list["AniToggle"].toggle.isOn = self.is_close_ani
end

function LuckyChessView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.cell_list[cell]
	if nil == reward_cell then
		reward_cell = LuckyChessRewardCell.New(cell.gameObject)
		self.cell_list[cell] = reward_cell
	end
	-- local data = self.list_data[data_index] or {}
	local data = LuckyChessData.Instance:GetReturnReward()
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(data[data_index])
end

function LuckyChessView:CloseWindow()
	self:Close()
end

function LuckyChessView:ClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(209))
end

function LuckyChessView:ClickOne()
	local is_free_time = LuckyChessData.Instance:GetIsFree()
	if is_free_time then
		self.is_onclick_req = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
					ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, 
					RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 1)
	else
		local func = function(is_auto)
			self.auto_buy_flag_list["auto_type_1"] = is_auto
			self.is_onclick_req = true
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
					ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, 
					RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 1)
		end

		if self.auto_buy_flag_list["auto_type_1"] then
			func(true)
		else
			local init_data = LuckyChessData.Instance:GetInitData()
			local str = string.format(Language.Fanfanzhuan.CostTip, init_data.money_one, CommonDataManager.GetDaXie(1))
			TipsCtrl.Instance:ShowCommonAutoView("luck_chess_auto1", str, func)
		end
	end
end

function LuckyChessView:ClickTen()
	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_10"] = is_auto
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
				RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 30)
	end

	local init_data = LuckyChessData.Instance:GetInitData()
	local item_num = ItemData.Instance:GetItemNumInBagById(init_data.times_use_item)

	if self.auto_buy_flag_list["auto_type_10"] or item_num > 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, 
				RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 30)
	else
		local init_data = LuckyChessData.Instance:GetInitData()
		local str = string.format(Language.Fanfanzhuan.CostTip, init_data.money_ten, 30)--CommonDataManager.GetDaXie(10))
		TipsCtrl.Instance:ShowCommonAutoView("luck_chess_auto10", str, func)
	end
end

function LuckyChessView:OnClickOpen()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function LuckyChessView:OpenCallBack()
	self.is_close_ani = false
	local data = LuckyChessData.Instance:GetDayDayUpStartData()
	self.target_index = data.target_index or 0
	LuckyChessCtrl.Instance:SendAllInfoReq()
	self:OpenBtn()
	self.node_list["AniToggle"].toggle.isOn = false
	-- self.node_list["HL3"]:SetActive(false)
	-- self.node_list["HL4"]:SetActive(false)
end

function LuckyChessView:CloseCallBack()
	self.node_list["AniToggle"].toggle.isOn = false
end

function LuckyChessView:OnFlush(param_t)
	for i = 1, OUT_SIDE_COUNT do
		self.out_cell_select_list[i]:SetActive(false)
	end
	for i = 1, IN_SIDE_COUNT do
		self.in_cell_select_list[i]:SetActive(false)
	end

	local data = LuckyChessData.Instance:GetDayDayUpStartData()
	self.is_out_side_type = data.start_pos.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE
	self.cur_cell_list = self.is_out_side_type and self.out_side_cell_list or self.in_side_cell_list
	self.target_index = data.target_index or 0
	-- self.node_list["HL4"]:SetActive(false)
	if self.is_onclick_req then
		self.is_onclick_req = false

		local target_cell_data = self.cur_cell_list[self.target_index].cell:GetData()
		if self.is_close_ani then
			if self.cur_cell_list == self.out_side_cell_list then 
				self.out_cell_select_list[self.target_index]:SetActive(true)
			else
				self.in_cell_select_list[self.target_index]:SetActive(true)
			end
			-- self.node_list["HL3"]:SetActive(true)
			-- self.node_list["HL3"].transform.position = self.cur_cell_list[self.target_index].obj.transform.position

			if target_cell_data.reward_type == REWARD_TYPE.DOUBLE then
				local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
				local target_index = double_data.reward_info_list[1].target_index or 0
				local target_index2 = double_data.reward_info_list[2].target_index or 0
				self.out_cell_select_list[self.target_index]:SetActive(false)
				self.out_cell_select_list[target_index]:SetActive(true)
				self.out_cell_select_list[target_index2]:SetActive(true)
				-- self.node_list["HL4"]:SetActive(true)
				-- self.node_list["HL3"].transform.position = self.cur_cell_list[target_index].obj.transform.position
				-- self.node_list["HL4"].transform.position = self.cur_cell_list[target_index2].obj.transform.position
			end
		else
			self:PlayAnimation(target_cell_data.reward_type == REWARD_TYPE.DOUBLE)
		end
	end

	-- 花费显示
	local init_data = LuckyChessData.Instance:GetInitData()
	self.node_list["TxtMoney1"].text.text = init_data.money_one or 0
	self.node_list["TxtMoney2"].text.text = init_data.money_ten or 0

	--钥匙显示
	local item_num = ItemData.Instance:GetItemNumInBagById(init_data.times_use_item)
	self:SetShowKeyStr(item_num > 0)

	local is_free = LuckyChessData.Instance:GetIsFree()
	self:SetShowGold(is_free)
	self.node_list["ImgPointRed"]:SetActive(is_free)
	
	local item_cfg = ItemData.Instance:GetItemConfig(init_data.times_use_item)
	if item_cfg then
		local name_str = "X" .. item_num
		self.node_list["TxtKeyNember"].text.text = name_str
	end

	self:FlushLeftContent()

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local count = LuckyChessData.Instance:GetRewardCount() or 0
	self.node_list["TxtNumberTimes"].text.text = ToColorStr(count, "#89f201")

	self:FlsuhToggle()
end

function LuckyChessView:FlushLeftContent()
	-- 左边列表刷新
	self.list_data = LuckyChessData.Instance:GetReturnRewardCfg()
	if self:IsOpen() then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end
function LuckyChessView:SetShowGold(is_show)
	self.node_list["TxtFree"]:SetActive(is_show)
	self.node_list["GoldLable"]:SetActive(not is_show)
end
function LuckyChessView:SetShowKeyStr(is_show)
	self.node_list["ImgPointRedCan"]:SetActive(is_show)
	self.node_list["TxtKeyLable"]:SetActive(is_show)
	self.node_list["ImgGoldLableTen"]:SetActive(not is_show)
	self.node_list["ImgIconDiscount"]:SetActive(not is_show)
end

function LuckyChessView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond(time, 6)
	else
		self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond(time, 7)
	end

end

function LuckyChessView:PlayAnimation2(index, show_select, call_back)
	local cur_index = 0
	local time = 5.5
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	self.turn_time = 0
	self.turn_do_tween.transform.position = Vector3(cur_index, 0, 0)
	local tween = self.turn_do_tween.transform:DOMoveX(count * ANI_LOOP + index, time)
	tween:SetEase(DG.Tweening.Ease.InOutQuad)

	self.time_quest_1 = GlobalTimerQuest:AddRunQuest(function ()
		self.change_time = self.change_time + UnityEngine.Time.deltaTime
		self.turn_time = self.turn_time + UnityEngine.Time.deltaTime
		if self.change_time > 0.01 then
			if show_select[cur_index] then
				show_select[cur_index]:SetActive(false)
			end
			cur_index = math.floor(self.turn_do_tween.transform.position.x % count + 0.5) + 1
			show_select[cur_index]:SetActive(true)
			self.change_time = 0
		end

		if self.turn_time >= time then
			-- show_select[cur_index]:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.time_quest_1)
			self.time_quest_1 = nil
		end
	end,0)

	if call_back then
		tween:OnComplete(call_back)
	end
end

function LuckyChessView:PlayAnimation21(index, show_select, call_back)
	local cur_index = 1
	local last_inex = 1
	local time = 5.5
	self.select_index_1 = nil
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	self.turn_time_1 = 0
	self.turn_do_tween1.transform.position = Vector3(cur_index, 0, 0)
	local tween = self.turn_do_tween1.transform:DOMoveX(count * ANI_LOOP + index, time)
	tween:SetEase(DG.Tweening.Ease.InOutQuad)
	self.time_quest_21 = GlobalTimerQuest:AddRunQuest(function ()
		self.change_time_1 = self.change_time_1 + UnityEngine.Time.deltaTime
		self.turn_time_1 = self.turn_time_1 + UnityEngine.Time.deltaTime
		if self.change_time_1 > 0.01 then
			if show_select[last_inex] and last_inex ~= self.select_index_2 then
				show_select[last_inex]:SetActive(false)
			end
			show_select[cur_index]:SetActive(true)
			last_inex = cur_index
			cur_index = math.floor(self.turn_do_tween1.transform.position.x % count + 0.5) + 1
			self.change_time_1 = 0
		end

		if self.turn_time_1 > time then
			-- show_select[cur_index]:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.time_quest_21)
			self.time_quest_21 = nil
			self.select_index_1 = cur_index
		end
	end,0)

	if call_back then
		tween:OnComplete(call_back)
	end
end

function LuckyChessView:PlayAnimation22(index, show_select, call_back)
	local cur_index = 1
	local last_inex = 1
	local time = 5.5
	self.select_index_2 = nil
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	self.turn_time_2 = 0
	self.turn_do_tween2.transform.position = Vector3(cur_index, 0, 0)
	local tween = self.turn_do_tween2.transform:DOMoveX(count * ANI_LOOP + index, time)
	tween:SetEase(DG.Tweening.Ease.InOutQuad)
	self.time_quest_22 = GlobalTimerQuest:AddRunQuest(function ()
		self.change_time_2 = self.change_time_2 + UnityEngine.Time.deltaTime
		self.turn_time_2 = self.turn_time_2 + UnityEngine.Time.deltaTime
		if self.change_time_2 > 0.01 then
			if show_select[last_inex] and last_inex ~= self.select_index_1 then
				show_select[last_inex]:SetActive(false)
			end
			show_select[cur_index]:SetActive(true)
			last_inex = cur_index
			cur_index = math.floor(self.turn_do_tween2.transform.position.x % count + 0.5) + 1
			self.change_time_2 = 0
		end

		if self.turn_time_2 > time then
			-- show_select[cur_index]:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.time_quest_22)
			self.time_quest_22 = nil
			self.select_index_2 = cur_index
		end
	end,0)

	if call_back then
		tween:OnComplete(call_back)
	end
end

-- 播放动画
function LuckyChessView:PlayAnimation(is_doublt)
	-- self.node_list["HL3"]:SetActive(false)
	self:CloseBtn()
	local path_list = {}
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	--两圈
	for i = 1,ANI_LOOP do
		for i = 0, count do
			local cell = self.cur_cell_list[i]
			table.insert(path_list, cell.obj.transform.position)
		end
	end
	for i = 0, self.target_index do
		local cell = self.cur_cell_list[i]
		table.insert(path_list, cell.obj.transform.position)
	end
	-- 获取高亮底高亮顺序
	local show_select = {}
	for k,v in pairs(path_list) do
		for i = 0, OUT_SIDE_COUNT do
			if v == self.out_cell_select_list[i].transform.position then
				table.insert(show_select, self.out_cell_select_list[i])
			end
		end
		for i = 0, IN_SIDE_COUNT do 
			if v == self.in_cell_select_list[i].transform.position then
				table.insert(show_select, self.in_cell_select_list[i])
			end
		end
	end

	local function complete_func()
		-- self.node_list["HL3"]:SetActive(true)
		-- self.node_list["HL3"].transform.position = self.cur_cell_list[self.target_index].obj.transform.position
		-- 双开动画
		if is_doublt then
			local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
			if nil ~= double_data.reward_info_list[1] and double_data.split_position ~= 0 then
				self:PlayDoubleAnimation(self.target_index, double_data.reward_info_list[1].target_index or 0, double_data.reward_info_list[2].target_index or 0)
			end
		else
			self:OpenBtn()
		end
	end
	self:PlayAnimation2(self.target_index, show_select, complete_func)
end

-- 播放双开动画
function LuckyChessView:PlayDoubleAnimation(start_index, target_index, target_index2)
	-- self.node_list["HL4"]:SetActive(false)
	-- self.node_list["HL3"]:SetActive(false)
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	count = count + 1
	-- 光环1动画
	local path_list1 = {}
	local left_index = target_index >= start_index and (target_index - start_index) or (count - start_index + target_index)
	local all_index = count * ANI_LOOP + left_index
	for i = 0, all_index do
		local index = (start_index + i) % count
		local cell = self.cur_cell_list[index]
		if cell then
			table.insert(path_list1, cell.obj.transform.position)
		end
		
	end
	-- 获取高亮底1高亮顺序
	local show_select_1 = {}
	for k,v in pairs(path_list1) do
		for i = 0, OUT_SIDE_COUNT do
			if v == self.out_cell_select_list[i].transform.position then
				table.insert(show_select_1, self.out_cell_select_list[i])
			end
		end
	end
	self:PlayAnimation21(left_index, show_select_1)

	local function complete_func()
		-- self.node_list["HL4"]:SetActive(true)
		-- self.node_list["HL3"]:SetActive(true)
		-- self.node_list["HL3"].transform.position = self.cur_cell_list[target_index].obj.transform.position
		-- self.node_list["HL4"].transform.position = self.cur_cell_list[target_index2].obj.transform.position
		-- 是否再双开
		local target_cell_data1 = self.cur_cell_list[target_index].cell:GetData()
		local target_cell_data2 = self.cur_cell_list[target_index2].cell:GetData()
		if target_cell_data1.reward_type == REWARD_TYPE.DOUBLE or target_cell_data2.reward_type == REWARD_TYPE.DOUBLE then
			local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
			if nil ~= double_data.reward_info_list[1] and double_data.split_position ~= 0 then
				local start_index = 0
				if target_cell_data1.reward_type == REWARD_TYPE.DOUBLE then
					start_index = target_index
				else
					start_index = target_index2
				end
				self:PlayDoubleAnimation(start_index, double_data.reward_info_list[1].seq, double_data.reward_info_list[2].seq)
			end
		else
			self:OpenBtn()
		end
	end
	-- 光环2动画
	local path_list2 = {}
	local left_index_2 = target_index2 >= start_index and (count - target_index2 + start_index) or (start_index - target_index2)
	local all_index_2 = count * ANI_LOOP + left_index_2
	for i = 0, all_index_2 do
		local index = (start_index - i) % count
		index = index < 0 and (count + index) or index
		local cell = self.cur_cell_list[index]
		table.insert(path_list2, cell.obj.transform.position)
	end
	-- 获取高亮底2高亮顺序
	local show_select_2 = {}
	for k,v in pairs(path_list2) do
		for i = 0, OUT_SIDE_COUNT do
			if v == self.out_cell_select_list[i].transform.position then
				table.insert(show_select_2, self.out_cell_select_list[i])
			end
		end
	end
	self:PlayAnimation22(left_index_2, show_select_2, complete_func)
end

function LuckyChessView:CloseBtn()
	UI:SetButtonEnabled(self.node_list["BtnOne"], false)
	UI:SetButtonEnabled(self.node_list["BtnTen"], false)
end

function LuckyChessView:OpenBtn()
	UI:SetButtonEnabled(self.node_list["BtnOne"], true)
	UI:SetButtonEnabled(self.node_list["BtnTen"], true)
end

--奖励格子
LuckyChessCell = LuckyChessCell or BaseClass(BaseCell)

function LuckyChessCell:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
end

function LuckyChessCell:__delete()
	self.item = nil
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function LuckyChessCell:OnFlush()
	if nil == self.data then
		return
	end
	local num = 0
	local reward_type = self.data.reward_type
	if reward_type == REWARD_TYPE.ITEM then
		self.node_list["ImgImage"]:SetActive(false)
		self.node_list["ItemCell"]:SetActive(true)
		self.item:SetData(self.data.reward_item)
	else
		local init_data = LuckyChessData.Instance:GetInitData()
		local res_name = ""
		if reward_type == REWARD_TYPE.GOLD then
			local reward_gold = self.data.reward_gold_rate or 0
			local get_gold = init_data.money_one + reward_gold
			local multiple = get_gold / init_data.money_one
			-- res_name = "Multiple0" .. (multiple * 10)
			res_name = "Multiple0"
			num = num + 1
			self:LoadCell(num, multiple)
		elseif reward_type == REWARD_TYPE.INSIDE then
			res_name = "LuckyInside"
		elseif reward_type == REWARD_TYPE.DOUBLE then
			res_name = "LuckyTwo"
		else
			res_name = "LuckyStart"
		end
		local bundle, asset = ResPath.GetRandomActLuckyChessRes(res_name)
		self.node_list["ImgImage"].image:LoadSprite(bundle, asset .. ".png", function()
			self.node_list["ImgImage"].image:SetNativeSize()
		end)
	end
end

function LuckyChessCell:LoadCell(index, sub_type)
	local res_async_loader = AllocResAsyncLoader(self, "loader_" .. index .. "_" .. sub_type)
	res_async_loader:Load("uis/views/randomact/luckychess_prefab", "ItemCellText", nil, function (prefab)
		if nil == prefab then
			return
		end
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["ImgImage"].transform, true)
			obj_transform.localPosition = Vector3(0, 0, 0)
			obj_transform.localScale = Vector3(1, 1, 1)
			obj_transform:Find("TxtGiftName"):GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(Language.LuckChess.BeiShu, sub_type)
	end)
end

--奖励列表格子
LuckyChessRewardCell = LuckyChessRewardCell or BaseClass(BaseCell)

function LuckyChessRewardCell:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.Click, self))
end

function LuckyChessRewardCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function LuckyChessRewardCell:SetShowHasGetReward(is_show)
	self.node_list["TxtText1"]:SetActive(not is_show)
	self.node_list["TxtText2"]:SetActive(not is_show)
	self.node_list["ImgBgGray"]:SetActive(is_show)
end

function LuckyChessRewardCell:OnFlush()
	if nil == self.data then return end
	-- local is_get_reward = LuckyChessData.Instance:GetIsGetReward(self.index - 1)
	local is_get_reward = self.data.fetch_flag == 1
	local cur_times = LuckyChessData.Instance:GetRewardCount()
	local times_limit = self.data.cfg.play_times
	local role_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	
	local flag = cur_times >= times_limit and role_vip >= self.data.cfg.vip_limit
	local time_desc = flag and "" or string.format(Language.Common.LuckyChessReward, times_limit)
	self.node_list["TxtText2"].text.text = time_desc

	local text_vip_level = flag and "" or "VIP" .. self.data.cfg.vip_limit
	self.node_list["TxtText"].text.text = text_vip_level

	local str = flag and ToColorStr(Language.LuckChess.Desc2, TEXT_COLOR.WHITE) or Language.LuckChess.Desc1
	self.node_list["TxtText1"].text.text = str
	self:SetShowHasGetReward(is_get_reward)

	local show_highlight = flag and not is_get_reward
	self.node_list["ImgHighLight"]:SetActive(show_highlight)
	self.node_list["Effect"]:SetActive(show_highlight)
	self.item:SetData(self.data.cfg.reward_item)
end

function LuckyChessRewardCell:Click()
	if nil == self.data then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
			ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, 
			RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_MAX, self.data.cfg.seq)
end




