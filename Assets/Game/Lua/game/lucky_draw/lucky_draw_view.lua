LuckyDrawView = LuckyDrawView or BaseClass(BaseView)

local COLUMN = 23
local FreePay = 0
-- local FreeCount = 3
function LuckyDrawView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
	{"uis/views/luckydrawview_prefab", "LuckyDrawView"},
}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LuckyDrawView:__delete()
	-- body
end

function LuckyDrawView:LoadCallBack()
	self.data = LuckyDrawData.Instance
	self.can_add_lot_list_cfg = LuckyDrawData.Instance:GetCanAddLotCfg()

	local scroller_delegate = self.node_list["BottleList"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.contain_cell_list = {}
	self.item_cell_list = {}
	self.reward_item_list = {}

	local jiang_chi_list = LuckyDrawData.Instance:GetJiangChiList()
	if jiang_chi_list then
		for i = 1, COLUMN do
			self.item_cell_list[i] = ItemCell.New()
			self.item_cell_list[i]:SetInstanceParent(self.node_list["Item_" .. i])
			self.item_cell_list[i]:SetData(jiang_chi_list[i].reward_item)
		end
	end

	local reward_item_cfg = LuckyDrawData.Instance:GetRewardItemCfg()
	if reward_item_cfg then
		for i = 1, 6 do
			self.reward_item_list[i] = ItemCell.New()
			self.reward_item_list[i]:SetInstanceParent(self.node_list["reward_item_" .. i])
			self.reward_item_list[i]:SetData(reward_item_cfg[i].reward_item)
		end
	end
	self.node_list["Name"].text.text = Language.LuckyDraw.Title
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
	self.node_list["BtnReplacement"].button:AddClickListener(BindTool.Bind(self.ClickReplacement, self))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.ClickTip, self))
	self.node_list["BtnWareHouse"].button:AddClickListener(BindTool.Bind(self.ClickJump, self))
	self.node_list["BtnQuick"].button:AddClickListener(BindTool.Bind(self.ClickAuto, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
	self.node_list["BtnSide"].toggle:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self:Flush()
end

function LuckyDrawView:OpenCallBack()
	self.node_list["selcet_effect"]:SetActive(false)
	local time_tab = LuckyDrawData.Instance:GetRestTime()
	time_tab = TimeUtil.Format2TableDHMS(time_tab)
	if nil == self.upgrade_timer_quest then 
		self.upgrade_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimeUpdate,self), 1)
	end
end

function LuckyDrawView:TimeUpdate()
	local time_tab = LuckyDrawData.Instance:GetRestTime()
	local str = ""
	if time_tab <= 0 then 
		if self.upgrade_timer_quest then
			GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
			self.upgrade_timer_quest = nil
		end
	end
	if time_tab > 3600 * 24 then 
		if self.upgrade_timer_quest then
			GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
			self.upgrade_timer_quest = nil
		end
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 6))
	elseif time_tab > 3600 then 
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 0))
	else
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 0))
	end
	self.node_list["TxtTime"].text.text = str
end

function LuckyDrawView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	self.upgrade_timer_quest = nil
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.data = nil

	if nil ~= self.rotate_timer then
		GlobalTimerQuest:CancelQuest(self.rotate_timer)
	end

	if self.move_tween then
		self.move_tween:Pause()
		self.move_tween = nil
	end
end

function LuckyDrawView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW)
end

function LuckyDrawView:GetNumberOfCells()
	if not self.can_add_lot_list_cfg then return 0 end

	return #self.can_add_lot_list_cfg
end

function LuckyDrawView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LuckyDrawBottle.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetBottleIndex(cell_index - 1)

	if self.can_add_lot_list_cfg then
		contain_cell:SetData(self.can_add_lot_list_cfg[cell_index])
		contain_cell:Flush()
	end
end

function LuckyDrawView:OnFlush()
	-- 刷新次数
	local times = LuckyDrawData.Instance:GetAddLotTimes()
	self.node_list["AddLotTime"].text.text = string.format(Language.LuckyDraw.AddTimes, GameEnum.RA_TIANMING_ADD_LOT_TIMES - times)

	local need_pay_money = LuckyDrawData.Instance:GetNeedPayMoney()
	self.node_list["TxtGoldNeed"].text.text = need_pay_money
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	local free_time = LuckyDrawData.Instance:GetFreeChouTimes()
	local free_count = cfg.tianming_free_chou_times or 0
	if free_time < free_count then 
		self.node_list["TxtGoldNeed"].text.text = FreePay
		self.node_list["TxtSetGray"].text.text = Language.Common.LuckyFreePay
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["TxtSetGray"].text.text = Language.Common.LuckyPay
		self.node_list["RedPoint"]:SetActive(false)
	end
	local time_tab = LuckyDrawData.Instance:GetRestTime()
	--time_tab = TimeUtil.Format2TableDHMS(time_tab)
	if time_tab > 3600 * 24 then 
		if self.upgrade_timer_quest then
			GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
			self.upgrade_timer_quest = nil
		end
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 6))
	elseif time_tab > 3600 then 
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 0))
	else
		str = string.format(Language.LuckyDraw.LastTime, TimeUtil.FormatSecond(time_tab, 2))
	end
	self.node_list["TxtTime"].text.text = str
	self.node_list["BottleList"].scroller:RefreshAndReloadActiveCellViews(false)

	local auto_flag = LuckyDrawData.Instance:GetAutoFlag()
	local txt = auto_flag and Language.Common.Stop or Language.LuckyDraw.AutoDivination
	self.node_list["TxtBtnQuick"].text.text = txt
end

function LuckyDrawView:FlushAnimation()
	self.node_list["HightLight"].gameObject:SetActive(true)
	local index = self.now_index or 1
	local speed_index = index
	local result_index = (LuckyDrawData.Instance:GetRewardIndex()) + 1

	if result_index % COLUMN == 0 then
		result_index = COLUMN
	else
		result_index = result_index % COLUMN
	end
	if self.node_list["PlayAniToggle"].toggle.isOn then
		UI:SetButtonEnabled(self.node_list["BtnStart"], true)
		self.node_list["selcet_effect"]:SetActive(true)
		if nil == self.item_cell_list[result_index] then return end
		local posx = self.item_cell_list[result_index].root_node.transform.position.x
		local posy = self.item_cell_list[result_index].root_node.transform.position.y
		local posz = self.item_cell_list[result_index].root_node.transform.position.z
		self.node_list["HightLight"].transform.position = Vector3(posx, posy, posz)
		self.node_list["selcet_effect"].transform.position = Vector3(posx, posy, posz)
		self.now_index = result_index

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self:StartMove(self.item_cell_list[result_index].root_node.transform.parent.gameObject,self.item_cell_list[result_index])
		--TipsCtrl.Instance:ShowTreasureView(self.click_reward)
		return
	else
		UI:SetButtonEnabled(self.node_list["BtnStart"], false)
		self.node_list["selcet_effect"]:SetActive(false)
		local loop_num = GameMath.Rand(1, 2)

		local move_motion = function ()
				local quest = self.rotate_timer
				local quest_list = GlobalTimerQuest:GetRunQuest(quest)
				if nil == quest or nil == quest_list then return end

				if index == (loop_num * 23) + result_index then
					if nil == self.item_cell_list[result_index] then return end
					local posx = self.item_cell_list[result_index].root_node.transform.position.x
					local posy = self.item_cell_list[result_index].root_node.transform.position.y
					local posz = self.item_cell_list[result_index].root_node.transform.position.z
					self.node_list["HightLight"].transform.position = Vector3(posx, posy, posz)
					self.now_index = result_index

					self.node_list["selcet_effect"]:SetActive(true)
					self.node_list["selcet_effect"].transform.position = Vector3(posx, posy, posz)
					self:StartMove(self.item_cell_list[result_index].root_node.transform.parent.gameObject,self.item_cell_list[result_index])
					if nil ~= self.rotate_timer then
						GlobalTimerQuest:CancelQuest(self.rotate_timer)
						UI:SetButtonEnabled(self.node_list["BtnStart"], true)
					end
					return
				else
					local read_index = ((index + 1) == 23 and 23) or ((index + 1) % 23 == 0 and 23) or ((index + 1) % 23)
					local posx = self.item_cell_list[read_index].root_node.transform.position.x
					local posy = self.item_cell_list[read_index].root_node.transform.position.y
					local posz = self.item_cell_list[read_index].root_node.transform.position.z
					self.node_list["HightLight"].transform.position = Vector3(posx, posy, posz)
					-- 速度限制
					if index < speed_index + 3 then
						quest_list[2] = 0.18 -- 0.1 0.25 0.1 0.08
					elseif speed_index + 3 <= index and index <= speed_index + 6 then
							quest_list[2] = 0.08
					elseif index > ((loop_num * 23) + result_index) - 5 then
						quest_list[2] = 0.18
						if index > ((loop_num * 23) + result_index) - 2 then
							quest_list[2] = 0.24
						end
					else
						quest_list[2] = 0.064
					end
					index = index + 1
				end
			end

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self.rotate_timer = GlobalTimerQuest:AddRunQuest(move_motion, 0.08)
	end
end

function LuckyDrawView:StartMove(item_obj , item_cell)
	local target_obj = self.node_list["BtnWareHouse"]
	if nil == target_obj then
		return
	end
	if item_obj.gameObject.activeInHierarchy then
		local item_data = item_cell:GetData()
		TipsCtrl.Instance:OpenMoveItemView(item_data, item_obj, self.node_list["BtnWareHouse"], 1, true)
	end
end

function LuckyDrawView:FlushAutoAnimation()
	self.node_list["HightLight"].gameObject:SetActive(true)
	UI:SetButtonEnabled(self.node_list["BtnStart"], true)
	self.node_list["selcet_effect"]:SetActive(true)
	local result_index = (self.data:GetRewardIndex()) + 1
	if result_index % COLUMN == 0 then
		result_index = COLUMN
	else
		result_index = result_index % COLUMN
	end
	if nil == self.item_cell_list[result_index] then return end
	local posx = self.item_cell_list[result_index].root_node.transform.position.x
	local posy = self.item_cell_list[result_index].root_node.transform.position.y
	local posz = self.item_cell_list[result_index].root_node.transform.position.z
	self.node_list["HightLight"].transform.position = Vector3(posx, posy, posz)
	self.node_list["selcet_effect"].transform.position = Vector3(posx, posy, posz)
	self:StartMove(self.item_cell_list[result_index].root_node.transform.parent.gameObject,self.item_cell_list[result_index])
	self.now_index = result_index
end

function LuckyDrawView:OnClickOpen()
	local pos_x = self.node_list["BtnSide"].toggle.isOn and 406.7 or 706
		self.move_tween = self.node_list["RightList"].transform:DOLocalMoveX(
		pos_x, 0.5)
end

function LuckyDrawView:ActionComplete()
	if self.move_tween then
		self.move_tween:Pause()
		self.move_tween = nil
	end
	local pos_x = self.node_list["BtnSide"].toggle.isOn and 406.7 or 706
	local Position = self.node_list["RightList"].transform.localPosition
	self.node_list["RightList"].transform.localPosition = Vector3(pos_x, Position.y, Position.z)
end

function LuckyDrawView:CloseView()
	if LuckyDrawData.Instance:GetAutoFlag() then
		LuckyDrawData.Instance:SetStopFlag(true)
		LuckyDrawData.Instance:SetAutoFlag(false)
	end
	self:Close()
end

function LuckyDrawView:ClickAuto()
	local auto_flag = LuckyDrawData.Instance:GetAutoFlag()
	if auto_flag then
		LuckyDrawData.Instance:SetStopFlag(true)
		LuckyDrawData.Instance:SetAutoFlag(false)
	else
		ViewManager.Instance:Open(ViewName.LuckyDrawAutoPopView)
	end
end

function LuckyDrawView:ClickStart()
	local ok_fun = function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU, 0, 0)
	end
	local need_pay_money = LuckyDrawData.Instance:GetNeedPayMoney()
	local txt = string.format(Language.LuckyDraw.LuckyStart, need_pay_money)
	local free_time = LuckyDrawData.Instance:GetFreeChouTimes()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	local free_count = cfg.tianming_free_chou_times or 0
	if free_time < free_count then 
		txt = string.format(Language.LuckyDraw.LuckyStart, FreePay)
		ok_fun()
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, txt, nil, nil, true, false, "chongzhi1")
	end
	
end

function LuckyDrawView:ClickReplacement()
	local ok_fun = function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_RESET_ADD_LOT_TIMES, 0, 0)
	end
	local cfg = string.format(Language.LuckyDraw.Replacement)
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi2")
end

function LuckyDrawView:ClickReward()
	local bool = self.node_list["Content"].animator.animator:GetBool("open")
	bool = not bool
	self.node_list["Content"].animator.animator:SetBool("open", bool)
end

function LuckyDrawView:ClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(208))
end

function LuckyDrawView:ClickJump()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end


--------------------LuckyDrawBottle----------------------
LuckyDrawBottle = LuckyDrawBottle or BaseClass(BaseCell)
function LuckyDrawBottle:__init()
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function LuckyDrawBottle:__delete()
end

function LuckyDrawBottle:SetData(data)
	self.data = data
	self:Flush()
end

function LuckyDrawBottle:SetBottleIndex(cell_index)
	self.bottle_index = cell_index
end

function LuckyDrawBottle:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local add_lot_list = LuckyDrawData.Instance:GetAddLotList()
	self.node_list["TxtNum"].text.text ="x" .. add_lot_list[self.bottle_index]

	local consume_cfg = LuckyDrawData.Instance:GetConsumeCfg(add_lot_list[self.bottle_index])
	if consume_cfg then
		local pay_money = consume_cfg.add_consume_gold or -1
		self.node_list["TxtPayMoney"].text.text = pay_money
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	if nil == item_cfg then return end
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
end

function LuckyDrawBottle:OnClick()
	local ok_fun = function ()
			--self.node_list["Anim"].animator:SetTrigger("scale")
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_ADD_LOT_TIMES,
			self.bottle_index, param_3)
		end
	local add_lot_list = LuckyDrawData.Instance:GetAddLotList()
	local pay_money = LuckyDrawData.Instance:GetConsumeCfg(add_lot_list[self.bottle_index]).add_consume_gold
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local cfg = string.format(Language.LuckyDraw.AddLotTips, pay_money, item_cfg.name)
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi3")
end
