VersionThreePieceView = VersionThreePieceView or BaseClass(BaseRender)

local ASSET = {
	[1] = 100101,
	[2] = 100201,
	[3] = 100301,
	[4] = 100401,
}

function VersionThreePieceView:__init()
	self.cell_list = {}
	self.res_id = 0
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TextCount"])
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	
	self.node_list["VipButton"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
	self.node_list["RechargeBtn"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
	self:InitScroller()
end

function VersionThreePieceView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.res_id = 0
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.fight_text = nil
end


function VersionThreePieceView:OpenCallBack()
	self:Flush()
end

function VersionThreePieceView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		local data = VersionThreePieceData.Instance:GetSanBaoCfg()
		return #data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		local data = VersionThreePieceData.Instance:GetSanBaoCfg()
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  VersionThreePieceCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(data[data_index])
	end
end

function VersionThreePieceView:GetDisplayName(modle_id)
	local display_name = "jxsanbao_panel"
	local cfg = ItemData.Instance:GetItemConfig(tonumber(modle_id))
	if cfg == nil then
		return display_name
	end

	if cfg.is_display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		display_name = "jxsanbao_fight_mount_panel"
	elseif cfg.is_display_role == DISPLAY_TYPE.MOUNT then
		display_name = "jxsanbao_mount_panel"
	elseif cfg.is_display_role == DISPLAY_TYPE.WING then
		display_name = "jxsanbao_wing_panel"
	end
	return display_name
end

function VersionThreePieceView:OnFlush(param_t)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = VersionThreePieceData.Instance:GetSanBaoCfg()
	local fight_power = 0
	local module_name = ""
	if data[1] and data[1].res_id == 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = main_role_vo.prof
		module_name = Language.Common.CommonEquipName
		local asset = ASSET[prof]
		local bundle = ResPath.GetSanBaoRedEquipment(asset)
		self.model:ClearModel()
		self.model:SetMainAsset(bundle, asset)
		self.node_list["ShowFightPower"]:SetActive(false)
	elseif data[1] and data[1].res_id ~= 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(data[1].res_id)
		if item_cfg == nil then
			return
		end

		local name = data[1].display_name
		if nil == name or "" == name then
			name = self:GetDisplayName(data[1].res_id)
		end
		if self.res_id ~= data[1].res_id then
			self.res_id = data[1].res_id
			self.model:ChangeModelByItemId(data[1].res_id)
		end
		fight_power = ItemData.GetFightPower(data[1].res_id)
		module_name = ToColorStr(item_cfg.name, item_cfg.color)
		self.node_list["ShowFightPower"]:SetActive(true)
	end

	self.node_list["TextName"].text.text = module_name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local recharge = VersionThreePieceData.Instance:GetSanBaoChargeValue()
	self.node_list["TextRecharge"].text.text = recharge
end

function VersionThreePieceView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TextTime"].text.text = time_str

end

function VersionThreePieceView:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------VersionThreePieceCell-----------------------
VersionThreePieceCell = VersionThreePieceCell or BaseClass(BaseCell)

function VersionThreePieceCell:__init()
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end
end

function VersionThreePieceCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function VersionThreePieceCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)
	if self.data.reward_item[1] == nil and #item_list > 0 then
		for k,v in pairs(self.reward_list) do
			if item_list[k] then
				v:SetData(item_list[k])
			end
			v.root_node:SetActive(item_list[k] ~= nil)
			v:SetInteractable(true)
		end
	else
		for k,v in pairs(self.reward_list) do
			if self.data.reward_item[k - 1] then
				v:SetData(self.data.reward_item[k - 1])
			end
			v:SetItemActive(self.data.reward_item[k - 1] ~= nil)
		end
	end

	self.node_list["TextRecharge"].text.text = self.data.need_chongzhi_num
end