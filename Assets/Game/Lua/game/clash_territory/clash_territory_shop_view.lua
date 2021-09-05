
ClashTerritoryShopView = ClashTerritoryShopView or BaseClass(BaseView)

local ListViewDelegate = ListViewDelegate

function ClashTerritoryShopView:__init()
	self.ui_config = {{"uis/views/clashterritory_prefab", "ClashTerritoryShopView"}}
end

--初始化滚动条
function ClashTerritoryShopView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	local shop_cfg = ClashTerritoryData.Instance:GetTerritoryShopCfg()
	if #shop_cfg == 0 then
		return
	end

	self.cell_list = {}
	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/clashterritory_prefab", "ShopItem", nil, function (obj)
		if nil == obj then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)

	self.info_change_callback = BindTool.Bind(self.Flush, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	
	self.reset_pos = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_RESET_POS, BindTool.Bind(self.Close, self))
	self.effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE, BindTool.Bind(self.OnFightEffectChange, self))
	self:Flush()
end

function ClashTerritoryShopView:ReleaseCallBack()
	if ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	end
	if nil ~= self.reset_pos then
		GlobalEventSystem:UnBind(self.reset_pos)
		self.reset_pos = nil
	end
	if nil ~= self.effect_change then
		GlobalEventSystem:UnBind(self.effect_change)
		self.effect_change = nil
	end
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.list_view_delegate = nil
	self.enhanced_cell_type = nil
end

--滚动条数量
function ClashTerritoryShopView:GetNumberOfCells()
	return #ClashTerritoryData.Instance:GetTerritoryShopCfg()
end

--滚动条大小
function ClashTerritoryShopView:GetCellSize(data_index)
	return 235
end

--滚动条刷新
function ClashTerritoryShopView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)

	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = TerritoryShopScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell:ListenAllEvent()
	end
	local shop_cfg = ClashTerritoryData.Instance:GetTerritoryShopCfg()
	local data = shop_cfg[data_index + 1]
	cell:SetData(data)
	return cell_view
end

function ClashTerritoryShopView:OnFlush()
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()

	if nil ~= data.current_credit then
		self.node_list["TxtGuildScore"].text.text = string.format(Language.ClashTerritory.RemainScore, data.current_credit)
	else
		self.node_list["TxtGuildScore"].text.text = ""
	end

	self.node_list["Scroller"].scroller:RefreshActiveCellViews()
end

function ClashTerritoryShopView:OnFightEffectChange(is_main_role)
	if is_main_role then
		self:Flush()
	end
end

---------------------------------------------------- TerritoryShopScrollCell ----------------------------------------------------

TerritoryShopScrollCell = TerritoryShopScrollCell or BaseClass(BaseCell)
TerritoryShopScrollCell.Res = {
	[1] = {
			[0] = {
					[0] = {[0] = "territory_car_1_0", "territory_car_2_0", "territory_car_3_0"},
					[1] = {[0] = "territory_car_1_1", "territory_car_2_1", "territory_car_3_1"},
				},
			[1] = {[0] = "territory_attack_drug", "territory_revive_drug"},
			[2] = {[0] = "territory_mine_fire", "territory_mine_ice"},
		},
	[2] = {[0] = "territory_buff", "territory_portal_1", "territory_portal_0"}
}
function TerritoryShopScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.timer_format = Language.ClashTerritory.LimitTime
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)

	self.last_res = ""
end

function TerritoryShopScrollCell:__delete()
	GlobalTimerQuest:CancelQuest(self.time_coundown)
	self.model:DeleteMe()
	self.model = nil
end

function TerritoryShopScrollCell:Flush()
	if self.data == nil then
		return
	end
	GlobalTimerQuest:CancelQuest(self.time_coundown)
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()
	local image = "territory_buff"
	self.over_time = 0
	if nil ~= self.data.type then
		if self.data.type == 0 then
			image = TerritoryShopScrollCell.Res[1][self.data.type][data.side][self.data.goods_id]
		else
			image = TerritoryShopScrollCell.Res[1][self.data.type][self.data.goods_id]
		end
		if self.data.type == 1 and self.data.goods_id == 0 then
			local main_effs = FightData.Instance:GetMainRoleShowEffect()
			for k,v in pairs(main_effs) do
				if v.info.client_effect_type == 3000 then
					self.over_time = v.info.cd_time + TimeCtrl.Instance:GetServerTime()
					self.timer_format = Language.ClashTerritory.LimitTime
					break
				end
			end
			if self.over_time <= 0 then
				self.node_list["Time"].text.text = ""
			end
		elseif self.data.type == 2 and self.data.goods_id == 0 then
			local other_cfg = ConfigManager.Instance:GetAutoConfig("territorywar_auto").other[1]
			local color = other_cfg.fire_landmine_num_limit > data.fire_landmine_count and "b7d3f9" or "b7d3f9"
			self.node_list["Time"].text.text = string.format(Language.ClashTerritory.BringLimit, color, data.fire_landmine_count .. "/" .. other_cfg.fire_landmine_num_limit)
		elseif self.data.type == 2 and self.data.goods_id == 1 then
			local other_cfg = ConfigManager.Instance:GetAutoConfig("territorywar_auto").other[1]
			local color = other_cfg.ice_landmine_num_limit > data.ice_landmine_count and "b7d3f9" or "b7d3f9"
			self.node_list["Time"].text.text = string.format(Language.ClashTerritory.BringLimit, color, data.ice_landmine_count .. "/" .. other_cfg.ice_landmine_num_limit)
		else
			self.node_list["Time"].text.text = ""
		end
	else
		image = TerritoryShopScrollCell.Res[2][self.data.goods_id]
		if self.data.goods_id == 0 then
			self.over_time = data.side == 0 and data.m_blue_next_can_buy_tower_wudi or data.m_read_next_can_buy_tower_wudi
			self.timer_format = Language.ClashTerritory.CDTime
		else
			self.node_list["Time"].text.text = ""
		end
	end

	local score_color = data.current_credit < self.data.cost_credit and "#F9463B" or "#b7d3f9"
	local score = self.data.cost_credit

	self.node_list["Cost"].text.text = string.format(Language.ClashTerritory.CostScore, score_color, score)


	self.node_list["Image"].image:LoadSprite(ResPath.GetClashterritory(image))
	local res = self.data.type and (data.side == 0 and self.data.image_id or self.data.image_id2) or ""
	self.node_list["Display"]:SetActive(res and res ~= "")
	self.node_list["Image"]:SetActive(not res and res ~= "")
	if res and res ~= "" and res ~= self.last_res then
		self.last_res = res
		if self.data.type == 0 then
			self.model:SetMainAsset(ResPath.GetMonsterModel(res))
		elseif self.data.type == 2 then
			self.model:SetMainAsset(ResPath.GetTriggerModel(res))
		end
	end
	self.node_list["Name"].text.text = self.data.name

	if self.over_time > 0 then
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnShopUpdate, self), 1, self.over_time - TimeCtrl.Instance:GetServerTime())
		self:OnShopUpdate()
	end
end

function TerritoryShopScrollCell:OnShopUpdate()
	local time = math.max(0, self.over_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.node_list["Time"].text.text = ""
		GlobalTimerQuest:CancelQuest(self.time_coundown)
	else
		self.node_list["Time"].text.text = string.format(self.timer_format, TimeUtil.FormatSecond(time, 2))
	end

end

function TerritoryShopScrollCell:ListenAllEvent()
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function TerritoryShopScrollCell:OnClickCell()
	if self.data == nil then
		return
	end

	if nil ~= self.data.type then
		ClashTerritoryCtrl.Instance:SendTerritoryWarReliveFightBuy(self.data.type, self.data.goods_id)
	else
		ClashTerritoryCtrl.Instance:SendTerritoryWarReliveShopBuy(self.data.goods_id)
	end
end