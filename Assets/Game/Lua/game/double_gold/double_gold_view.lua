DoubleGoldView = DoubleGoldView or BaseClass(BaseView)

function DoubleGoldView:__init()
	self.ui_config = {
		{"uis/views/serveractivity/doublegold_prefab", "DoubleGoldContent"},
	}
	self.contain_cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function DoubleGoldView:__delete()
	-- body
end

function DoubleGoldView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.double_gold_list = DoubleGoldData.Instance:GetDoubleGoldList()
end

-- 销毁前调用
function DoubleGoldView:ReleaseCallBack()

end

function DoubleGoldView:OnFlush()
	self.double_gold_list = DoubleGoldData.Instance:GetDoubleGoldList()
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	if self.double_gold_list and self.double_gold_list[1] then
		self.node_list["TextDesc"].text.text = self.double_gold_list[1].desc
	end
end

function DoubleGoldView:OpenCallBack()
	DoubleGoldData.Instance:SetActiveState(true)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DOUBLE_GOLD)
	self:SetTime(time)
	self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
			time = time - 1
			self:SetTime(time)
		end)
	self:OnFlush()
end

-- 关闭前调用
function DoubleGoldView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	-- MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, false)
end

function DoubleGoldView:SetTime(time)
	local str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 10))
	self.node_list["TxtTime"].text.text = str
end

function DoubleGoldView:GetNumberOfCells()
	return #self.double_gold_list
end

function DoubleGoldView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = DobuleGoldCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetData(self.double_gold_list[cell_index])
	contain_cell:Flush()
end

function DoubleGoldView:CloseView()
	self:Close()
end

----------------------------DobuleGoldCell---------------------------------
DobuleGoldCell = DobuleGoldCell or BaseClass(BaseCell)

function DobuleGoldCell:__init()
	self.node_list["BtnChongzhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
end

function DobuleGoldCell:__delete()

end

function DobuleGoldCell:OnFlush()
	if nil == self.data then
		return
	end 
	self.node_list["TextChongzhi"].text.text = self.data.havechongzhi == 0 and Language.DoubleGold.GoReCharge or Language.DoubleGold.YiChongZhi
	UI:SetButtonEnabled(self.node_list["BtnChongzhi"], self.data.havechongzhi == 0)
	local bundle, name = ResPath.GetDoubleGoldIcon(self.data.gold_icon)
	self.node_list["GoldIcon"].image:LoadSprite(bundle, name)
	self.node_list["TextChongZhiDesc"].text.text = string.format(Language.DoubleGold.ChongZhi, self.data.chongzhi_value)
	self.node_list["TextNeedValue"].text.text = self.data.chongzhi_value
	self.node_list["TextRewardValue"].text.text = "+ " .. self.data.reward_gold
	self.node_list["TextFinallyRewardValue"].text.text =  string.format(Language.DoubleGold.RewardGold, self.data.reward_gold)
end

function DobuleGoldCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
