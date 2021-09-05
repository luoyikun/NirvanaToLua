LingKunBattleBossView = LingKunBattleBossView or BaseClass(BaseView)

local MAX_REWARD_NUM = 6
function LingKunBattleBossView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_2"},
		{"uis/views/lingkunbattleview_prefab", "LingKunBossPanel"},
	}

	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.boss_list = {}
	self.cell_list = {}

	self.select_boss_id = 10
	self.select_index = 1
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LingKunBattleBossView:ReleaseCallBack()
	for k, v in pairs(self.boss_list) do
		v:DeleteMe()
	end
	self.boss_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.cell_list = {}
	self.model_display = nil
end

function LingKunBattleBossView:OpenCallBack()

end

function LingKunBattleBossView:LoadCallBack()
	self.lingkun_cfg = LingKunBattleData.Instance:GetBossInfomationCfg()
	self.boss_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.node_list["Bg"].rect.sizeDelta = Vector3(960, 605, 0)
	self.node_list["Bg1"].rect.sizeDelta = Vector3(960, 605, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.LingKunBattle.BossInformation

	self:ChangeShowPanel(1)
	local list_delegate = self.node_list["BossList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BossList"].scroller:ReloadData(0)

	for i = 1 , MAX_REWARD_NUM do
		self.cell_list[i] = ItemCell.New()
		self.cell_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.ChangeShowPanel, self, 1))
	self.node_list["BtnBoss"].button:AddClickListener(BindTool.Bind(self.ChangeShowPanel, self, 0))

	self:Flush()
end

function LingKunBattleBossView:GetNumberOfCells()
	return #self.lingkun_cfg
end

function LingKunBattleBossView:ChangeShowPanel(index)
	self.node_list["NodeItem"]:SetActive(index == 1)
	self.node_list["BtnBoss"]:SetActive(index == 1)
	self.node_list["NodeDisplay"]:SetActive(index ~= 1)
	self.node_list["BtnDrop"]:SetActive(index ~= 1)
end


function LingKunBattleBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.boss_list[cell]
	if boss_cell == nil then
		boss_cell = LingKunBossItem.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.boss_list[cell] = boss_cell
	end
	local data = self.lingkun_cfg[data_index]
	self.boss_list[cell]:SetIndex(data_index)
	self.boss_list[cell]:SetData(data)

end

function LingKunBattleBossView:CloseWindow()

	self:Close()
end

function LingKunBattleBossView:ClickRecharge()

end


function LingKunBattleBossView:OnFlush()
	self:FlushInfoList()
end


function LingKunBattleBossView:GetSelectIndex()
	return self.select_index or 1
end

function LingKunBattleBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function LingKunBattleBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function LingKunBattleBossView:FlushAllHL()
	for k,v in pairs(self.boss_list) do
		v:FlushHL()
	end
end

function LingKunBattleBossView:FlushInfoList()
	if self.select_boss_id ~= 0 then
		self:FlushItemList(self.select_index)
		self:FlushModel()
		-- self:FlushTextLimit()
	end
end

function LingKunBattleBossView:FlushModel()
	local boss_id = LingKunBattleData.Instance:GetMonsterID(self.select_index)
	local bundle, asset = ResPath.GetMonsterModel(boss_id)

	local boss_cfg_id = LingKunBattleData.Instance:GetMonsterIDInCfg(self.select_index)
	local boss_data = BossData.Instance:GetMonsterInfo(boss_cfg_id)
	self.model:SetMainAsset(bundle, asset, function()
		if boss_data then
			self.model:SetScale(Vector3(boss_data.ui_scale, boss_data.ui_scale, boss_data.ui_scale))
			self.model:SetLocalPosition(Vector3(0, boss_data.ui_position_y, 0))
			self.model:SetRotation(Vector3(0, -53.78, 0))
		end
	end)
end


function LingKunBattleBossView:FlushItemList(index)
	local cfg = LingKunBattleData.Instance:GetRewardCfg(index)
	for i = 1 , MAX_REWARD_NUM do
		self.cell_list[i]:SetData(cfg[i])
	end
end

-------------LingKunBossItem---------------
LingKunBossItem = LingKunBossItem or BaseClass(BaseCell)

function LingKunBossItem:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function LingKunBossItem:__delete()
	self.boss_view = nil
end

function LingKunBossItem:ClickItem(is_click)
	if is_click then
		local select_index = self.boss_view:GetSelectIndex()
		local boss_id = self.data.boss_id
		self.boss_view:SetSelectBossId(boss_id)
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function LingKunBossItem:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if nil ~= monster_cfg and monster_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		-- self.node_list["ImgName"].text.text = monster_cfg.name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_1")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
	end
	self.node_list["TxtLevel"].text.text = "Lv." .. monster_cfg.level
	self:FlushHL()
end

function LingKunBossItem:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

-------------LingKunBossItem-END--------------