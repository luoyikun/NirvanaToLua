RankMingRenView = RankMingRenView or BaseClass(BaseRender)

--摄像机坐标
local pos_cfg = {
	{position = Vector3(0, 1.2, -3.5), rotation = Vector3(0, 0, 0)},
	}

function RankMingRenView:__init(instance)
	self.cell_list = {}
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.ming_cfg = RankData.Instance:GetMingCfg()
end

function RankMingRenView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.ming_cfg = nil
end

function RankMingRenView:GetNumberOfCells()
	local num = #RankData.Instance:GetMingCfg()
	return num == nil and 0 or num
end

function RankMingRenView:OnToggleClick()
	if is_click and self.node_list["list_view"] and self.node_list["list_view"].gameObject.activeInHierarchy then
		self.node_list["list_view"].scroller:ReloadData(0)
	end
end

function RankMingRenView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankMingRenItem.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index)
	the_cell:SetData(self.ming_cfg[cell_index])
end

function RankMingRenView:ReloadRankList()
	if self.node_list["list_view"] and self.node_list["list_view"].scroller then
		self.node_list["list_view"].scroller:ReloadData(0)
	end
end

-----------------------------------------------------
RankMingRenItem = RankMingRenItem or BaseClass(BaseCell)

function RankMingRenItem:__init(instance)
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	--self.model_view:SetScale(Vector3(0.85, 0.85, 0.85))

end

function RankMingRenItem:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self:UnBindQuery()
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
end

function RankMingRenItem:RoleInfoReturn(role_id, info)
	if self.index == 0 or nil == self.data then
		return
	end

	local minren_id = RankData.Instance:GetIdByIndex(self.data.mingrentang_type)
	if minren_id == role_id then
		self:FlushItemCell(info)
	end
end

function RankMingRenItem:UnBindQuery()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function RankMingRenItem:OnFlush()
	if self.index == 0 or nil == self.data then
		return
	end
	local minren_id = RankData.Instance:GetIdByIndex(self.data.mingrentang_type)
	if not minren_id or minren_id == 0 then
		self:FlushItemCell()
	else
		self:UnBindQuery()
		self.role_event_system = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoReturn, self))
		CheckCtrl.Instance:SendQueryRoleInfoReq(minren_id)
	end
end

function RankMingRenItem:FlushItemCell(info)

	if not self.node_list["Display"] or IsNil(self.node_list["Display"].gameObject) then
		return
	end

	local mingren_cfg = RankData.Instance:GetMingCfgByType(self.data.mingrentang_type)
	if mingren_cfg == nil and not next(mingren_cfg) then
		return
	end

	local title = mingren_cfg.title_id
	local bundle, asset = ResPath.GetTitleIcon(title)
	self.node_list["ImgTitle"].image:LoadSprite(bundle, asset .. ".png")
	TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], title, true)
	self.node_list["TxtDesc"].text.text = mingren_cfg.desc

	self.node_list["Display"]:SetActive(info ~= nil)
	self.node_list["ImgFigure"]:SetActive(info == nil)
	if info then
		local name = info.role_name
		local temp_info = TableCopy(info)
		temp_info.appearance = {}
		temp_info.appearance.mask_used_imageid = info.mask_info.used_imageid
		temp_info.appearance.toushi_used_imageid = info.head_info.used_imageid
		temp_info.appearance.yaoshi_used_imageid = info.waist_info.used_imageid
		temp_info.appearance.qilinbi_used_imageid = info.arm_info.used_imageid
		temp_info.appearance.shouhuan_used_imageid = info.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN].used_imageid
		temp_info.appearance.tail_used_imageid = info.upgrade_sys_info[UPGRADE_TYPE.TAIL].used_imageid

		local fashion_info = info.shizhuang_part_list[2]
		local wuqi_info = info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		temp_info.is_normal_fashion = is_used_special_img == 0
		temp_info.is_normal_wuqi = wuqi_info.use_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
		temp_info.appearance.fashion_wuqi = wuqi_id
		temp_info.appearance.fashion_body = fashion_id

		self.model_view:SetModelResInfo(temp_info, false, false, false, false, false, false)
		--self.model_view:SetRotation(Vector3(0, 180, 0))
		--self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
		--self.model_view.display.transform:FindHard("UICamera").transform.localPosition = pos_cfg[1].position
		self.node_list["TxtName"].text.text = name
	else
		self.node_list["TxtName"].text.text = ""
	end
end