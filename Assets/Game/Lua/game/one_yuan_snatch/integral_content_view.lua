IntegralContentView = IntegralContentView or BaseClass(BaseRender)

local display_List = {

}

local display_prof_List = {
	[1] = "huanzhuangshop_fashion_panel_jian2",
	[2] = "huanzhuangshop_fashion_panel_dao",
	[4] = "huanzhuangshop_fashion_panel_guzheng",
	[3] = "huanzhuangshop_fashion_panel_shanzi2",
}

local default_display = {
	[DISPLAY_TYPE.MOUNT] = "one_yuan_snatch_mount_panel",
	[DISPLAY_TYPE.WING] = "one_yuan_snatch_wing_panel",
	[DISPLAY_TYPE.FOOTPRINT] = "one_yuan_snatch_foot_panel",
	[DISPLAY_TYPE.FASHION] = "one_yuan_snatch_fashion_panel",
	[DISPLAY_TYPE.HALO] = "one_yuan_snatch_halo_panel",
	[DISPLAY_TYPE.SPIRIT] = "one_yuan_snatch_spirit_panel",
	[DISPLAY_TYPE.FIGHT_MOUNT] = "huanzhuangshop_fight_mount_panel2",
	[DISPLAY_TYPE.SHENGONG] = "huanzhuangshop_shengong_panel2",
	[DISPLAY_TYPE.SHENYI] = "one_yuan_snatch_shenyi_panel",
	[DISPLAY_TYPE.XIAN_NV] = "one_yuan_snatch_xian_nv_panel",
	[DISPLAY_TYPE.ZHIBAO] = "huanzhuangshop_zhibao_panel",
	[DISPLAY_TYPE.BIANSHEN] = "one_yuan_snatch_tianshen_panel",
}


function IntegralContentView:__init(instance)
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.node_list["BuyButton"].button:AddClickListener(BindTool.Bind(self.ExChangeClick, self))
end

function IntegralContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
	end
	self.cell_list = nil
end

function IntegralContentView:CloseCallBack()
	-- body
end

function IntegralContentView:OpenCallBack()
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO )

	self:Flush()
end

function IntegralContentView:OnFlush()
	if self.node_list["ListView"] and self.node_list["ListView"].scroller then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(false)
	end

	self:InitPanel()
end

function IntegralContentView:GetNumberOfCells()
	return OneYuanSnatchData.Instance:GetIntergralNum() or 0
end

function IntegralContentView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cfg = OneYuanSnatchData.Instance:GetIntergralGroupIndexCfg(data_index)
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = SnatchCellGroup.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell.view_type = "integral"
		the_cell:SetData(cfg)
	end
end

function IntegralContentView:InitPanel()
	local cfg = OneYuanSnatchData.Instance:GetShowModelCfg()
	local convert_info = OneYuanSnatchData.Instance:GetCloudPurchaseConvertInfo()
	local other_cfg = OneYuanSnatchData.Instance:GetOtherCfg()
	if cfg then
		self.node_list["TxtNeedScore"].text.text = string.format(Language.OneYuanSnatch.NeedScore, cfg.cost_score or 0)
		if cfg.show_id then
			self.model:ChangeModelByItemId(cfg.show_id)
		end

		self.node_list["TxtBtn"].text.text = Language.OneYuanSnatch.ExChange
		UI:SetButtonEnabled(self.node_list["BuyButton"], true)
		local item_info = OneYuanSnatchData.Instance:PurchaseConvertInfoByItemId(cfg.item_id)

		if item_info and item_info.convert_count and item_info.convert_count >= cfg.convert_count_limit then
			self.node_list["TxtBtn"].text.text = Language.OneYuanSnatch.isExChange
			UI:SetButtonEnabled(self.node_list["BuyButton"], false)
		end
	end

	if convert_info then
		self.node_list["TxtHasScore"].text.text = convert_info.score or 0
	end

	if other_cfg and other_cfg[1] then
		local num = other_cfg[1].score_per_gold or 0
		num = num * (other_cfg[1].ticket_gold_price or 0)
		self.node_list["TxtCanGetScore"].text.text = num or 0
	end
end

function IntegralContentView:ExChangeClick()
	local cfg = OneYuanSnatchData.Instance:GetMaxScoreCfg()
	if cfg and cfg.seq then
		OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT, cfg.seq, 1)
	end
end
