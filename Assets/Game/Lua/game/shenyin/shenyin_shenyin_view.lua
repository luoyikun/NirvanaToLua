
ShenYinShenYinView = ShenYinShenYinView or BaseClass(BaseRender)

local MAX_BAG_GRID_NUM = 260
local COLUMN_NUM = 4
local ROW_NUM = 5
local BAG_PAGE_COUNT = 20
local MOVE_TIME = 0.5	-- 界面动画时间
local MOVE_LOOP = 1
function ShenYinShenYinView:UIsMove()
	UITween.ScaleShowPanel(self.node_list["Left1"] ,Vector3(0.8 , 0.8 , 0.8 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Left2"] , Vector3(0 , -250 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Left1"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(500 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(67 , 690 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function ShenYinShenYinView:__init(instance)
	self.cell_list = {}
	self.goal_data = {}
	self.node_list["RecycleBtn"].button:AddClickListener(BindTool.Bind(self.RecycleBtn, self))
	self.node_list["AutomaticBtn"]:SetActive(false)
	-- self.node_list["AutomaticBtn"].button:AddClickListener(BindTool.Bind(self.AutomaticBtn, self))
	self.node_list["Helpbtn"].button:AddClickListener(BindTool.Bind(self.Helpbtn,self))
	self.node_list["AllAttrBtn"].button:AddClickListener(BindTool.Bind(self.AllAttrBtn,self))
	self.node_list["AllSuit"].button:AddClickListener(BindTool.Bind(self.AllSuit,self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.BtnClose,self))
	self.node_list["BtnCloseRecycle"].button:AddClickListener(BindTool.Bind(self.BtnClose,self))
	-- self.node_list["Exchange"].button:AddClickListener(BindTool.Bind(self.Exchange,self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))
	self.node_list["GoGet"].button:AddClickListener(BindTool.Bind(self.GotoGet, self))

	self.slot_cell_list = {}
	self.data_list = {}
	for i = 1, ShenYinEnum.SHENYIN_SYSTEM_MAX_YINJI do
	self.slot_cell_list[i] = YinJiCell.New(self.node_list["SlotCell"..i])
	self.slot_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickShenGeCell, self, i))
	self.slot_cell_list[i]:SetIndex(i - 1)
	end
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].list_view:JumpToIndex(0)
	self.show_recycle = false
	-- self.node_list["RecyclePanel"]:SetActive(false)
	-- self.recycle_view = ShenYinRecycleView.New(self.node_list["RecyclePanel"], instance, self)
	self.global_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_SHENYIN_BAG, BindTool.Bind(self.FlushBagView, self))

	self.global_event2 = GlobalEventSystem:Bind(OtherEventType.FLUSH_RECYCLE_SHENYIN_COLOR, BindTool.Bind(self.FlushColorChange, self))
	local start_pos = Vector3(30 , -30 , 0)
	local end_pos = Vector3(30 , 0 , 0)
	UITween.MoveLoop(self.node_list["UpArrow"], start_pos, end_pos, MOVE_LOOP)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerTxt"])

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

end

function ShenYinShenYinView:GotoGet()
	-- ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang3)
	ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.luandou_zhanchang)
end

function ShenYinShenYinView:__delete()
	self.fight_text = nil
	UITween.KillMoveLoop(self.node_list["UpArrow"])
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end
	-- if self.recycle_view then
	-- 	self.recycle_view:DeleteMe()
	-- 	self.recycle_view = nil
	-- end
	self.slot_cell_list = {}
	self.data_list = {}

	if nil ~= self.global_event then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	if nil ~= self.global_event2 then
		GlobalEventSystem:UnBind(self.global_event2)
		self.global_event2 = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ShenYinShenYinView:OpenCallBack()
	-- if self.recycle_view then
	-- 	self.recycle_view:OpenCallBack()
	-- end
	-- self:BtnClose()
	-- ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SORT)
end

function ShenYinShenYinView:ItemDataChangeCallback(item_id)
	self:Flush()
end

function ShenYinShenYinView:CloseCallBack()
	-- if self.recycle_view then
	-- 	self.recycle_view:CloseCallBack()
	-- end
end

function ShenYinShenYinView:FlshGoalContent()
	self.goal_info = ShenYinData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1

					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function ShenYinShenYinView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN, is_other_item)
end

function ShenYinShenYinView:RecycleBtn()
	self.show_recycle = true
	--self.node_list["RecycleBtn"]:SetActive(false)
	--self.node_list["BtnCloseRecycle"]:SetActive(true)
	--self.node_list["RecyclePanel"]:SetActive(true)
	--if self.recycle_view then
	-- 	self.recycle_view:SetShenYinJingHuaRecycleList()
	--end
	ShenYinCtrl.Instance:ShowRecycleView()
	self:FlushBagView()
end

function ShenYinShenYinView:BtnClose()
	-- if self.recycle_view then
	-- 	self.recycle_view:ReSetShenYinRecycleList()
	-- end
	self.show_recycle = false
	self.node_list["RecycleBtn"]:SetActive(true)
	-- self.node_list["BtnCloseRecycle"]:SetActive(false)
	--self.node_list["RecyclePanel"]:SetActive(false)
	self:FlushBagView()
end

-- 点击整理背包
function ShenYinShenYinView:AutomaticBtn()
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SORT)
	if self.show_recycle then
		self:BtnClose()
		--self:RecycleBtn()
	end
end

function ShenYinShenYinView:Helpbtn()
	local tips_id = 239
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenYinShenYinView:AllAttrBtn()
	local total_attr = ShenYinData.Instance:GetShenYinTotalAttr()
	TipsCtrl.Instance:ShowAttrView(total_attr)
end

function ShenYinShenYinView:AllSuit()
	ViewManager.Instance:Open(ViewName.ShenYinSuitAttrView)
end

function ShenYinShenYinView:Exchange()
	-- ShenYinCtrl.Instance:ChangeToShenYinViewByIndex(TabIndex.shenyin_exchange)
end

function ShenYinShenYinView:OnClickShenGeCell(index)
	if self.slot_cell_list[index] == nil then
		return
	end
	local call_back = function(data)
		if data then 
			ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_EQUIT, data.param1, data.imprint_slot)
		end
	end
	local list_data = ShenYinData.Instance:GetShenYinBySlot(index - 1)
	if self.slot_cell_list[index].data == nil or next(self.slot_cell_list[index].data) == nil or not self.slot_cell_list[index].data.is_have_mark  then 
		if list_data == nil or list_data[1] == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.ShenYinError)
		else
			ShenYinCtrl.Instance:ShowSelectView(call_back , self.slot_cell_list[index].data)
		end
		return 
	end
	ShenYinCtrl.Instance:OpenYinJiTip(self.slot_cell_list[index].data, ShenYinYinJiTipView.FromView.ShenYinSlot)
end

function ShenYinShenYinView:ClickBagCell(index, data, cell)
	cell:SetHighLight(false)

	if nil == data or not next(data) or data.item_id == nil then
		return
	end
	-- if self.show_recycle then
	-- 	local is_select = ShenYinData.Instance:GetHasShenYinRecycle(data.param1)
	-- 	if not is_select then
	-- 		ShenYinData.Instance:AddShenYinRecycleList(data)
	-- 		cell:SetIconGrayScale(true)
	-- 	end
	-- 	GlobalEventSystem:Fire(OtherEventType.FLUSH_RECYCLE_SHENYIN_BAG)
	-- else
		if 1 == data.item_type then
			ShenYinCtrl.Instance:OpenYinJiTip(data, ShenYinYinJiTipView.FromView.ShenYinBag)
			-- TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG)	
		else
			cell:OnClickItemCell()
		end
	-- end
end

function ShenYinShenYinView:GetNumberOfCells()
	self.data_list = ShenYinData.Instance:GetMarkBagInfo()
	return MAX_BAG_GRID_NUM
end

function ShenYinShenYinView:RefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenYinItemCell.New(cellObj.gameObject)
		self.cell_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / ROW_NUM) + 1 - page * COLUMN_NUM
	local cur_row = math.floor(index % ROW_NUM) + 1
	local grid_index = (cur_row - 1) * COLUMN_NUM - 1 + cur_colunm  + page * ROW_NUM * COLUMN_NUM + 1

	-- local data_list = ShenYinData.Instance:GetMarkBagInfo()
	local data = self.data_list[grid_index]
	-- cell:ListenClick(BindTool.Bind(self.ClickBagCell, self, grid_index, data, cell))
	cell:ListenClick(BindTool.Bind(self.ClickBagCell, self, data and data.bag_index or -1, data, cell))
	cell:SetInteractable(nil ~= data and nil ~= next(data))
	if data then
		data.from_view = TipsFormDef.FROM_SHENYIN_BAG
	end
	cell:SetData(data , self.node_list["UpArrow"])
	if data and data.param1 then
		cell:SetIndex(data.param1)
	end
end

function ShenYinShenYinView:SetSlotState()
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	for i = 1, #PASTURE_SPIRIT_MAX_IMPRINT_SLOT_TYPE do
		self.slot_cell_list[i]:SetData(data[i - 1])
	end
end

function ShenYinShenYinView:OnFlush(param_list)
	self:SetSlotState()
	self:FlshGoalContent()
	local mark_slot_info = ShenYinData.Instance:GetMarkSlotInfo()
	local total_attr_list = CommonStruct.Attribute()
	local capability = 0 
	for i = 1, ShenYinEnum.SHENYIN_SYSTEM_MAX_YINJI do
		local slot_info = mark_slot_info[i - 1] or {}
		local attr_list =  ShenYinData.Instance:GetShenYinCapabilitySlot(i - 1, true)
		total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, attr_list)
	end
	total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, ShenYinData.Instance:GetShenYinSuitAttrCapability())
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = (CommonDataManager.GetCapability(total_attr_list))
	end

	self.node_list["ScoreTxt"].text.text = string.format(Language.ShenYin.StorageExp, ShenYinData.Instance:GetPastureSpiritImprintScoreInfo())
	-- if self.recycle_view then
	-- 	self.recycle_view:Flush()
	-- end
	self:FlushBagView()
	self.node_list["AddTxt"].text.text = string.format(Language.ShenYin.AddShuXing,ShenYinData.Instance:GetAllGroupActiveNum())

	local suit_attr = ShenYinData.Instance:GetTaoZhuangAttr()
	local cap = CommonDataManager.GetCapability(suit_attr)
	if cap > 0 then
		self.node_list["SuitCapBg"]:SetActive(true)
		self.node_list["SuitCap"].text.text = string.format(Language.Common.GaoZhanLi, cap)
		self.node_list["GaoPer"]:SetActive(false)
	else
		self.node_list["SuitCapBg"]:SetActive(false)
		self.node_list["SuitCap"].text.text = ""
		self.node_list["GaoPer"]:SetActive(true)
	end
end

function ShenYinShenYinView:FlushBagView(index)	
	if self.node_list["ListView"] and nil ~= self.node_list["ListView"].list_view
		and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
		-- self.node_list["ListView"].list_view:JumpToIndex() 
	end
end

function ShenYinShenYinView:FlushColorChange(color, is_select)
	local data_list = ShenYinData.Instance:GetMarkBagInfo()
	if is_select then
		for k,v in pairs(data_list) do
			if v.quanlity == color then
				ShenYinData.Instance:AddShenYinRecycleList(v)
			end
		end
	else
		for k,v in pairs(data_list) do
			if v.quanlity == color then
				ShenYinData.Instance:RemoveShenYinRecycleList(v.param1)
			end
		end
	end
	self:FlushBagView()
end

-- 印记槽
YinJiCell = YinJiCell or BaseClass(BaseRender)

function YinJiCell:__init()
	self.handler = nil
	self.index = 0
	self.data = {}
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.item:SetIsShowTips(false)
	self.item:SetInteractable(false)
	self.item:ListenClick(BindTool.Bind(self.OnClickCell, self))
end

function YinJiCell:ListenClick(handler)
	self.node_list["yinjiBtn"].button:AddClickListener(handler)
	-- self:ListenEvent("Click", handler)
	self.handler = handler
end

function YinJiCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item_ = nil
	end
end

function YinJiCell:SetClickHander(handler)

end

function YinJiCell:SetIndex(index)
	self.index = index 
end

function YinJiCell:OnClickCell(index)
	if self.handler then
		self.handler()
	end
	self.item:SetHighLight(false)
end

function YinJiCell:GetData()
	return self.data
end

function YinJiCell:SetData(data)
	self.data = data
	if data == nil or next(data) == nil or not data.is_have_mark then
		self.node_list["IconImg"]:SetActive(true)
		local bundle, asset = ResPath.GetShenYinIcon(self.index)
			self.node_list["IconImg"].image:LoadSprite(bundle, asset)
		self.item:ShowQuality(false)
		UI:SetGraphicGrey(self.node_list["IconImg"],true)
		self.item:SetData(data)
		if data.imprint_slot then 
			local red_point = ShenYinData.Instance:GetShenYinBagCapabilityBySlot(data.imprint_slot , false)
			self.item:SetRedPoint(red_point)
		else
			self.item:SetRedPoint(false)
		end
	else
		self.node_list["IconImg"]:SetActive(false)
		self.item:ShowQuality(true)
		UI:SetGraphicGrey(self.node_list["IconImg"],false)
		self.item:SetData(data)
		local red_point = ShenYinData.Instance:GetShenYinBagCapabilityBySlot(data.imprint_slot , true)
		self.item:SetRedPoint(red_point)
		--ShenYinData.Instance:GetShenYinBagCapabilityBySlot(data , true)
	end
	
end

ShenYinItemCell = ShenYinItemCell or BaseClass(BaseCell)

function ShenYinItemCell:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["item"])
end

function ShenYinItemCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function ShenYinItemCell:SetData(data , anim_obj)
	self.data = data
	self.item:SetData(data)
	if not data then
		self.item:ShowQuality(false)
		--self.node_list["ShowBtn"]:SetActive(false)
		self.node_list["UpArrow"]:SetActive(false)
		self:AnimLoop(false , anim_obj)
		--self.item:SetShowUpArrow(false)
		return
	end
	--local up_flag = false
	local power1 = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilityByData(data, true))
	local power2 = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilitySlot(data.imprint_slot))
	local up_flag = power1 > power2 and nil ~= next(data) and data.item_type == 1
	self.item:ShowQuality(data and nil ~= next(data))
	--self.node_list["ShowBtn"]:SetActive(up_flag)
	self.node_list["UpArrow"]:SetActive(up_flag)
	self:AnimLoop(up_flag , anim_obj)
	--self.item:SetShowUpArrow(up_flag)
	self:SetIconGrayScale(ShenYinData.Instance:GetHasShenYinRecycle(self.data.param1))
end

function ShenYinItemCell:AnimLoop(active , anim_obj)
	if active then 
		UITween.AddChildMoveLoop(self.node_list["UpArrow"] , anim_obj)
	else
		UITween.ReduceChildMoveLoop(self.node_list["UpArrow"] , anim_obj)
	end
end

function ShenYinItemCell:ListenClick(handler)
	self.item:ListenClick(handler)
end

function ShenYinItemCell:SetInteractable(flag)
	self.item:SetInteractable(flag)
end

function ShenYinItemCell:SetHighLight(flag)
	self.item:SetHighLight(flag)
end

function ShenYinItemCell:SetIconGrayScale(flag)
	self.item:SetIconGrayScale(flag)
	self.item:ShowQuality(self.data and nil ~= self.data.item_id and not flag)
end

function ShenYinItemCell:OnClickItemCell()
	self.item:OnClickItemCell()
end

