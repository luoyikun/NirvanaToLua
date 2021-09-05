OneYuanBuyView = OneYuanBuyView or BaseClass(BaseView)

local TAB_INDEX = {
	xingxiang = 0,
	shenmo = 1,
}

local POSITION = {
	[0] = Vector3(0, 0, 0),
	[1] = Vector3(385, 0, 0),
}

local PAGEMAXNUM = 3
function OneYuanBuyView:__init()
	self.ui_config = {
			{"uis/views/oneyuanbuyview_prefab", "OneYuanBuyView"},
	}

	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.tab_index = 0
end
 
function OneYuanBuyView:__delete()

end

function OneYuanBuyView:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	if self.countdown_time then
		CountDown.Instance:RemoveCountDown(self.countdown_time)
		self.countdown_time = nil
	end
end

function OneYuanBuyView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.cell_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ListView"].scroll_rect.horizontal = false
	for i=0,1 do
		self.node_list["Tab" .. i].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, i))
	end
	self:FlushTabRemind()
	self:SetTabShow()
end

function OneYuanBuyView:SetTabShow()
	self.node_list["Tab1"]:SetActive(OneYuanBuyData.Instance:GetOneYuanBuyShowCfg(TAB_INDEX.shenmo) > 0)
end

function OneYuanBuyView:ChangeToIndex(index)
	if self.tab_index == index then
		return
	end
	self.tab_index = index
	self.node_list["List"].transform.localPosition = POSITION[index]
	self.node_list["ListView"].scroller:ReloadData(0)
end

function OneYuanBuyView:GetNumberOfCells()
	local num = OneYuanBuyData.Instance:GetOneYuanBuyShowCfg(self.tab_index)
	return num
end

function OneYuanBuyView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.cell_list[cell]
	if target_cell == nil then
		target_cell = OneYuanBuyCell.New(cell.gameObject)
		self.cell_list[cell] = target_cell
	end
	target_cell:SetIndex(data_index)
	target_cell:SetData(self.tab_index)
end

function OneYuanBuyView:OpenCallBack()
	OneYuanBuyData.Instance:SetOneYuanBuyFirstOpen(false)
	MainUICtrl.Instance:GetView():ShowOneYuanBuyXianShi()

	self.node_list["Tab0"].toggle.isOn = true
	self:FlushTime()
end

function OneYuanBuyView:CloseWindow()
	self:Close()
end

-- -- 刷新
function OneYuanBuyView:OnFlush()
	if self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushTabRemind()
	self:FlushTime()
end

function OneYuanBuyView:FlushTabRemind()
	self.node_list["Remind0"]:SetActive(OneYuanBuyData.Instance:GetShowTabRemind() == 1)
	self.node_list["Remind1"]:SetActive(OneYuanBuyData.Instance:GetIsShowTabRemind(3) == 1)
end

function OneYuanBuyView:FlushTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
	if time > 0 then
		if nil == self.countdown_time then
			local diff_func = function(elapse_time, total_time)
				if elapse_time >= total_time then
					if self.countdown_time then
						CountDown.Instance:RemoveCountDown(self.countdown_time)
						self.countdown_time = nil
					end
					if self.node_list and self.node_list["RestTime"] then
						self.node_list["RestTime"]:SetActive(false)
					end
					return
				end
				local last_time = math.floor(total_time - elapse_time + 0.5)
				if self.node_list and self.node_list["RestTime"] then
					self.node_list["RestTime"]:SetActive(true)
					self.node_list["RestTime"].text.text = string.format(Language.OneYuanBuyView.RestTimes, TimeUtil.FormatSecond(last_time, 18))
				end
			end
			diff_func(0, time)
			self.countdown_time = CountDown.Instance:AddCountDown(time, 1, diff_func)
		end
	else
		self.node_list["RestTime"]:SetActive(false)
	end
end 

-------------------------------------------------------
OneYuanBuyCell = OneYuanBuyCell or BaseClass(BaseCell)

function OneYuanBuyCell:__init()
	self.cur_show_id = 0
	self.timestamp = 0
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.cfg = {}
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickAct, self, self.index))
end

function OneYuanBuyCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.cfg = {}
	self.cur_show_id = 0
	self.fight_text = nil
end

function OneYuanBuyCell:OnFlush()
	local buy_type = (self.data*PAGEMAXNUM + self.index) - 1
	local fetch_day = OneYuanBuyData.Instance:GetZeroBuyFetchDayByIndex(buy_type)
	self.cfg = OneYuanBuyData.Instance:GetOneYuanBuyShowCfgByTypeAndFetchDay(buy_type, fetch_day)
	if nil == self.cfg.buy_type then
		return
	end
	self:SetButtonIcon(self.index - 1)
	
	local flag_list = OneYuanBuyData.Instance:GetZeroBuyReturnFetchList(self.cfg.buy_type)
	local timestamp_list = OneYuanBuyData.Instance:GetZeroBuyReturnTimeStamp()
	local max_reward_day = OneYuanBuyData.Instance:GetMaxRewardDay(self.cfg.buy_type)
	if fetch_day > max_reward_day then
		fetch_day = max_reward_day
	end
	self.timestamp = timestamp_list and timestamp_list[self.cfg.buy_type] or 0
	self.node_list["LingQuText"]:SetActive(self.timestamp > 0)
	self.node_list["BuyText"]:SetActive(self.timestamp <= 0)

	local item_id = self.cfg.buy_reward and self.cfg.buy_reward.item_id or 0
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self:SetModel(item_id)
		local str = Language.Common.PROP_TYPE[item_cfg.is_display_role] or ""
		self.node_list["TxtName"].text.text = str .. "·" .. item_cfg.name
	end
	local max_num = OneYuanBuyData.Instance:GetMaxLeiJiRewardNumByIndex(self.cfg.buy_type) or 0
	local can_reward_num = OneYuanBuyData.Instance:GetOneYuanBuyCanRewardNum(self.cfg.buy_type, fetch_day)
	local num = 0
	local day = 0
	local str = ""
	if self.timestamp <= 0 then
		str = Language.OneYuanBuyView.LeiJiFanHuan
		self.node_list["TxtFanHuan"].text.text = string.format(str, max_reward_day + 1, max_num)
	else
		num, day = OneYuanBuyData.Instance:GetLeiJiRewardNumByIndex(self.cfg.buy_type)
		local color = num < max_num and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		str = Language.OneYuanBuyView.HasFanHuan

		local rest_reward_day = 0
		if can_reward_num - num <= 0 then
			rest_reward_day = max_reward_day + 1 - day
		else
			if fetch_day >= max_reward_day then
				rest_reward_day = 1
			else
				rest_reward_day = max_reward_day + 1 - day
			end
		end
		if rest_reward_day <= 0 then
			self.node_list["TxtFanHuan"].text.text = Language.OneYuanBuyView.BindGoldHasOut
		else
			self.node_list["TxtFanHuan"].text.text = string.format(str, ToColorStr(num, color), max_num, rest_reward_day)
		end
	end


	self.node_list["TxtBuyNum"].text.text = string.format(Language.OneYuanBuyView.BuyGold , self.cfg.need_gold or 0)
	local last_get_num = 0
	if can_reward_num - num <= 0 then
		if fetch_day >= max_reward_day then
			last_get_num = Language.OneYuanBuyView.HasGet
		else
			last_get_num = Language.OneYuanBuyView.NextDayReward
		end
	else
		last_get_num = string.format(Language.OneYuanBuyView.GetBindGold, can_reward_num - num)
	end
	self.node_list["TxtGetNum"].text.text = last_get_num

	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = ItemData.GetFightPower(item_id)
	end
	if flag_list and flag_list[32 - fetch_day] then
		local not_open = not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW) and self.timestamp <= 0
		if not_open then
			UI:SetButtonEnabled(self.node_list["BtnStart"], false)
			self.node_list["TxtBuyNum"].text.text = Language.OneYuanBuyView.HasTimeOut
			self.node_list["RedPoint"]:SetActive(false)
		else
			UI:SetButtonEnabled(self.node_list["BtnStart"], flag_list[32 - fetch_day] <= 0)
			self.node_list["RedPoint"]:SetActive(self.timestamp > 0 and flag_list[32 - fetch_day] <= 0)
		end
	end
end

function OneYuanBuyCell:SetModel(item_id)
	if self.cur_show_id == item_id then
		return
	end

	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	self.cur_show_id = item_id

	self.model:ClearModel()
	self.model:ChangeModelByItemId(item_id)
	if self.data == 1 then
		self.model:SetScale(Vector3(1.2, 1.2, 1.2))
	else
		self.model:SetScale(Vector3(0.8, 0.8, 0.8))
	end
end

function OneYuanBuyCell:OnClickAct()
	local func = function()
		if self.timestamp <= 0 then
			KaifuActivityCtrl:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW, RA_ZERO_BUY_RETURN_OPERA_TYPE.RA_ZERO_BUY_RETURN_OPERA_TYPE_BUY, self.cfg.buy_type)
		else
			KaifuActivityCtrl:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW, RA_ZERO_BUY_RETURN_OPERA_TYPE.RA_ZERO_BUY_RETURN_OPERA_TYPE_FETCH_YUANBAO, self.cfg.buy_type)
		end
	end
	if self.timestamp > 0 then
		func()
	else
		local str = ""
		if self.cfg then
			local item_id = self.cfg.buy_reward and self.cfg.buy_reward.item_id or 0
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg then
				local name = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"
				str = string.format(Language.OneYuanBuyView.BuyText, self.cfg.need_gold, name)
			end
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, str)
	end
end

function OneYuanBuyCell:SetButtonIcon(index)
	local bundle, asset = ResPath.GetOneYuanBtnImage(index)
	local ok_callback = function()
		self.node_list["BtnStart"].image:SetNativeSize()
	end
	self.node_list["BtnStart"].image:LoadSprite(bundle, asset, ok_callback)
end