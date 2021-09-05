FuBenVipView = FuBenVipView or BaseClass(BaseRender)

function FuBenVipView:__init(instance)

	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.list = {}

end

function FuBenVipView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = nil
end

function FuBenVipView:GetNumberOfCells()
	return FuBenData.Instance:MaxVipFB()
end

function FuBenVipView:RefreshMountCell(cell, data_index)
	local vip_view = self.list[cell]
	if vip_view == nil then
		vip_view = VipListView.New(cell.gameObject)
		self.list[cell] = vip_view
	end
	local vip_fb_cfg = FuBenData.Instance:GetVipFBLevelCfg()
	local fb_info = FuBenData.Instance:GetVipFBInfo()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = {}
	if fb_info and next(fb_info) then
		data.had_active = vip_fb_cfg[data_index + 1].enter_level <= game_vo.vip_level
		data.show_red_point = fb_info[data_index + 1].today_times <= 0
		data.small_key = "vip"..vip_fb_cfg[data_index + 1].raw_image
		data.big_key = "Vip"..vip_fb_cfg[data_index + 1].raw_image
		data.fb_name = vip_fb_cfg[data_index + 1].fb_name
		data.is_pass = FuBenData.Instance:GetVipFBIsPass(data_index + 1)
		vip_view:SetData(data)
		for i = 1, 3 do
			local item_data = {}
			item_data = vip_fb_cfg[data_index + 1].reward_item[i - 1]
			vip_view:SetItemCellData(i, item_data)
		end
	end
	vip_view:ListenClick(BindTool.Bind(self.OnClickChallenge, self, data_index))
end



function FuBenVipView:OnClickChallenge(index)
	local fb_info = FuBenData.Instance:GetVipFBInfo()
	if fb_info[index + 1] and fb_info[index + 1].today_times >= 1 then
		return
	end

	if FuBenData.Instance:GetVipFBIsPass(index + 1) then
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_VIPFB, index + 1)
		return
	end

	PlayerPrefsUtil.SetInt("vipindex", index)
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_VIPFB, index + 1)
	ViewManager.Instance:Close(ViewName.FuBen)
end

function FuBenVipView:FlushView()

	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end


VipListView = VipListView or BaseClass(BaseRender)

function VipListView:__init(instance)
	self.item_cells = {}
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function VipListView:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function VipListView:ListenClick(handler)
	--是否需要清除绑定事件
	self.node_list["ButtonChallenge"].button:AddClickListener(handler)
end

function VipListView:SetItemCellData(i, item_data)
	self.item_cells[i]:SetData(item_data)
end

function VipListView:SetData(data)
	if not data then return end
	self.node_list["RawImage"]:SetActive(data.had_active)
	self.node_list["ButtonChallenge"]:SetActive( data.had_active)
	self.node_list["LevelOpen"]:SetActive(not data.had_active)
	self.node_list["RedPoint"]:SetActive(data.show_red_point)
	self.node_list["ButtonChallenge"]:SetActive( data.show_red_point)
	self.node_list["HadChallenge"]:SetActive(not data.show_red_point)
	local bundle, asset = ResPath.GetFubenRawImage(data.small_key, data.big_key)
	self.node_list["RawImage"].raw_image:LoadSprite(bundle, asset, function ()
		self.node_list["RawImage"].raw_image:SetNativeSize()
	end)
	self.node_list["FbName" ].text.text = data.fb_name

	if data.is_pass then
		self.node_list["ButtonName" ].text.text = Language.Common.SaoDang
	else
		self.node_list["ButtonName" ].text.text = Language.Common.TiaoZhan
	end
end
