IncreaseSuperiorView = IncreaseSuperiorView or BaseClass(BaseView)

function IncreaseSuperiorView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
	{"uis/views/increasesuperior_prefab", "IncreaseSuperior"},
	{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},}
	self.contain_cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
  	self.close_tween = UITween.HideFadeUp
end

function IncreaseSuperiorView:__delete()
	-- body
end

function IncreaseSuperiorView:LoadCallBack()
	self.node_list["Name"].text.text = Language.IncreaseSuperior.PanelName
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.reward_list = IncreaseSuperiorData.Instance:GetRewardListDataByDay()
	self.coset_list =  IncreaseSuperiorData.Instance:GetCostListByDay()
end

-- 销毁前调用
function IncreaseSuperiorView:ReleaseCallBack()

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function IncreaseSuperiorView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.IncreaseSuperior)
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
    local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3)
    self:SetTime(time)
    self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
			time = time - 1
            self:SetTime(time)
        end)
end

-- 关闭前调用
function IncreaseSuperiorView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function IncreaseSuperiorView:SetTime(time)
	local str = ""
	if time > 3600 * 24 then 
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	elseif time > 3600 then 
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 0))
	else
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 0))
	end 
	self.node_list["Txt"].text.text = str
end

-- 刷新
function IncreaseSuperiorView:OnFlush(param_list)
	-- override
end

function IncreaseSuperiorView:GetNumberOfCells()
	return #self.reward_list
end

function IncreaseSuperiorView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = IncreaseSuperiorCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCost(self.coset_list[cell_index])
	contain_cell:Flush()
end

function IncreaseSuperiorView:CloseView()
	self:Close()
end

----------------------------IncreaseSuperiorCell---------------------------------
IncreaseSuperiorCell = IncreaseSuperiorCell or BaseClass(BaseCell)

function IncreaseSuperiorCell:__init()
	self.reward_data = {}
	self.item_cell_list = {}
	self.node_list["Btn_2"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end
end

function IncreaseSuperiorCell:__delete()
	self.item_cell_obj = nil

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function IncreaseSuperiorCell:SetItemData(data)
	if data then
		local item_data_list = {}
		self.reward_data = data
		local item_data = ItemData.Instance:GetItemConfig(self.reward_data.item_id)
		for i = 1, 4 do
			item_data_list[i] = {}
			item_data_list[i].item_id = item_data["item_"..i.."_id"]
			item_data_list[i].num = item_data["item_"..i.."_num"]
			item_data_list[i].is_bind = item_data["is_bind_"..i]
			self.item_cell_list[i]:SetData(item_data_list[i])
			if not next(item_data_list[i]) then
				self.item_cell_list[i]:SetItemActive(false)
			else
				self.item_cell_list[i]:SetItemActive(true)
			end
		end
	end
end

function IncreaseSuperiorCell:SetCost(num)
	self.cost_count = num
end

function IncreaseSuperiorCell:OnFlush()
	local str = string.format(Language.IncreaseCapablity.Tips, self.cost_count)
	self.node_list["Txt"].text.text = str
end

function IncreaseSuperiorCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
