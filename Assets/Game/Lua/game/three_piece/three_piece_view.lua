ThreePieceView = ThreePieceView or BaseClass(BaseView)

function ThreePieceView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/threepiece_prefab", "ThreePieceView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ThreePieceView:LoadCallBack()
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/randomact/threepiece/images_atlas", "threepiece_title" )
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	-- 监听
	self.node_list["Name"].text.text = Language.Title.DiPin
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"])

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self:InitScroller()
	
end

function ThreePieceView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.fight_text = nil
end

function ThreePieceView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	self.data = ThreePieceData.Instance:GetRechargeCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  ThreePieceCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end

end

function ThreePieceView:OpenCallBack()
	ThreePieceCtrl.SendRATotalCharge4Info()
	self:Flush()
end

function ThreePieceView:OnFlush(param_t)
	self.data = ThreePieceData.Instance:GetRechargeCfg()
	local cfg = {}
	if self.data[1] and self.data[1].show_item then
		self.model:ChangeModelByItemId(self.data[1].show_item)
		local power = ItemData.GetFightPower(self.data[1].show_item)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	else
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
	end

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local recharge_info = ThreePieceData.Instance:GetRechargeInfo()
	self.node_list["TxtTips"].text.text = string.format(Language.RandomActivity.TipsDescribe, 500)
	local num = 500 - recharge_info.cur_consume_reward
	self.node_list["TxtNum"].text.text = num .. Language.RandomActivity.TipsFlush
	if recharge_info.cur_consume_reward == 500 then
		self.node_list["TxtNum"].text.text = string.format(Language.Common.ShowRedStr, num) .. Language.RandomActivity.TipsFlush
	else
		self.node_list["TxtNum"].text.text = num .. Language.RandomActivity.TipsFlush
	end
	self.node_list["TxtRecharge"].text.text = recharge_info.cur_total_charge
end

function ThreePieceView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_NEW_THREE_SUIT)

	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.JinYinTa.ActEndTime, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtTime"].text.text = time_str

end

function ThreePieceView:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------------------------------------------
--滚动条格子 ThreePieceItem

ThreePieceCell = ThreePieceCell or BaseClass(BaseCell)

function ThreePieceCell:__init()
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end
end

function ThreePieceCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function ThreePieceCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)
	local is_special_list = {}
	if self.data.is_specil then
		is_special_list = Split(self.data.is_specil, ",")
	end
	if self.data.reward_item[1] == nil and #item_list > 0 then
		for k,v in pairs(self.reward_list) do
			if item_list[k] then
				v:SetData(item_list[k])
				if is_special_list[k] and tonumber(is_special_list[k]) == 1 then
					v:SetShowOrangeEffect(true)
				end
			end
			v.root_node:SetActive(item_list[k] ~= nil)
			v:SetInteractable(true)
		end
	else
		for k,v in pairs(self.reward_list) do
			if self.data.reward_item[k - 1] then
				v:SetData(self.data.reward_item[k - 1])
			end
			v.root_node:SetActive(self.data.reward_item[k - 1] ~= nil)
		end
	end

	self.node_list["TxtNumber"].text.text = self.data.need_chongzhi_num
end