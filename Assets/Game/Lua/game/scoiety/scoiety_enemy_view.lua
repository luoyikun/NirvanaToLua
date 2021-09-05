ScoietyEnemyView = ScoietyEnemyView or BaseClass(BaseRender)
function ScoietyEnemyView:__init()
		-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	local scroller_delegate = self.node_list["EnemyList"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local enemy_cell = self.cell_list[cell]
		if enemy_cell == nil then
			enemy_cell = ScrollerEnemyCell.New(cell.gameObject)
			enemy_cell.root_node.toggle.group = self.node_list["EnemyList"].toggle_group
			enemy_cell.enemy_view = self
			self.cell_list[cell] = enemy_cell
		end

		enemy_cell:SetIndex(data_index)
		enemy_cell:SetData(self.scroller_data[data_index])
	end

	self.node_list["EnemyList"].button:AddClickListener(BindTool.Bind(self.ClickEmpty, self))
	self.node_list["EnemyList"].scroller.scrollerScrollingChanged = function ()
		ScoietyCtrl.Instance:CloseOperaList()
	end
end

function ScoietyEnemyView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ScoietyEnemyView:CloseEnemyView()
	self.select_index = nil
end

function ScoietyEnemyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyEnemyView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyEnemyView:ClickEmpty()
	ScoietyCtrl.Instance:CloseOperaList()
end

function ScoietyEnemyView:FlushEnemyView()
	self.scroller_data = ScoietyData.Instance:GetEnemyList()
	self.node_list["EnemyList"].scroller:RefreshAndReloadActiveCellViews(true)
end

----------------------------------------------------------------------------
--ScrollerEnemyCell 		仇人滚动条格子
----------------------------------------------------------------------------

ScrollerEnemyCell = ScrollerEnemyCell or BaseClass(BaseCell)

function ScrollerEnemyCell:__init()
	self.avatar_key = 0
	self.node_list["EnemyItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))


end

function ScrollerEnemyCell:__delete()
	self.avatar_key = 0
end

function ScrollerEnemyCell:LoadUserCallBack(user_id, raw_image_obj, path)
	if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
		return
	end

	if user_id ~= self.data.user_id then
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(self.data.user_id, false)
	end
	raw_image_obj.raw_image:LoadURLSprite(path, function ()
		if user_id ~= self.data.user_id then
			return
		end
		self.node_list["IconImage"]:SetActive(false)
		self.node_list["RawImage"]:SetActive(true)
	end)
end

function ScrollerEnemyCell:OnFlush()
	if not self.data or not next(self.data) or nil == self.data.gamename then return end
	self.node_list["NameTxt"].text.text = self.data.gamename

	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)
	
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["HatredTxt"].text.text = self.data.be_kill_count
	self.node_list["HatredTxt_win"].text.text = self.data.kill_count
	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1)
	self.node_list["ZhanLiTxt"].text.text = self.data.capability

	if self.data.is_online ~= 1 then
		UI:SetGraphicGrey(self.node_list["IconImage"], true)
		UI:SetGraphicGrey(self.node_list["RawImage"], true)
		UI:SetGraphicGrey(self.node_list["NameTxt"], true)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], true)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], true)
		UI:SetGraphicGrey(self.node_list["ZhanLiTxt"], true)
		UI:SetGraphicGrey(self.node_list["HatredTxt"], true)
		UI:SetGraphicGrey(self.node_list["HatredTxt_win"], true)
	else
		UI:SetGraphicGrey(self.node_list["IconImage"], false)
		UI:SetGraphicGrey(self.node_list["RawImage"], false)
		UI:SetGraphicGrey(self.node_list["NameTxt"], false)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], false)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], false)
		UI:SetGraphicGrey(self.node_list["ZhanLiTxt"], false)
		UI:SetGraphicGrey(self.node_list["HatredTxt"], false)
		UI:SetGraphicGrey(self.node_list["HatredTxt_win"], false)
	end

	-- 刷新选中特效
	local select_index = self.enemy_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerEnemyCell:ClickItem()
	-- if IS_ON_CROSSSERVER or (not IS_ON_CROSSSERVER and self.data.merge_server_id ~= GameVoManager.Instance:GetMainRoleVo().merge_server_id)then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
	-- 	return
	-- end
	self.root_node.toggle.isOn = true
	self.enemy_view:SetSelectIndex(self.index)
	local function canel_callback()
		if self.enemy_view then
			self.enemy_view:SetSelectIndex(0)
		end
		if self.root_node and self.root_node.toggle then
			self.root_node.toggle.isOn = false
		end
	end

	local click_obj = self.enemy_view.scroller
	local uuid = CommonStruct.UUID()
	uuid.plat_type = self.data.plat_type
	uuid.role_id = self.data.user_id
	ScoietyCtrl.Instance:ShowOperateListGlobal(ScoietyData.DetailType.EnemyType, uuid, click_obj, canel_callback)
end