FuBenDefenseTips = FuBenDefenseTips or BaseClass(BaseView)

function FuBenDefenseTips:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "DefenseFBTips"}}

	self.index = 0
	self.is_modal = false
	self.is_any_click_close = true
	self.defense_cell_list = {}
end

function FuBenDefenseTips:LoadCallBack()
	self.build_panel = self.node_list["BuildPanel"]
	self.desc_panel = self.node_list["DescPanel"]
	self.updata_panel = self.node_list["UpdataPanel"]
	self.reward_panel = self.node_list["RewardPanel"]
	self:InitUpdata()
	self.cell_list = {}
	self.item_list = {}
	local name_table = self.node_list["RewardPanel"]:GetComponent(typeof(UINameTable))
	local reward_node = U3DNodeList(name_table, self)
	for i = 1,5 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(reward_node["ItemCell" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function FuBenDefenseTips:__delete()

end

function FuBenDefenseTips:ReleaseCallBack()
	for k,v in pairs(self.defense_cell_list) do
		v:DeleteMe()
	end
	self.defense_cell_list = {}

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}

	self.desc_panel = nil
	self.build_panel = nil
	self.updata_panel = nil
	self.reward_panel = nil
	self.list_view = nil
	self.list_defence_view = nil
	self.desc_node_list = nil
	self.updata_node_list = nil
	self.pos_index = nil
	self.defense_obj = nil
	self.target_obj = nil
end

function FuBenDefenseTips:CloseCallBack()
	self:ShowIndexPanel(self.index, false)
	if self.defense_obj and self.defense_obj.HideAttackRangeRadius then
		self.defense_obj:HideAttackRangeRadius()
	end
	if self.target_obj and self.target_obj.HideTowerAttackRangeRadius then
		self.target_obj:HideTowerAttackRangeRadius()
	end
	self.pos_index = nil
	self.defense_obj = nil
	self.target_obj = nil
end

function FuBenDefenseTips:SetIndex(index)
	self.index = index
	self:Open()
	self:Flush("all")
end

function FuBenDefenseTips:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:ShowIndexPanel(self.index, true)
		elseif k == "updata" then
			self:UpdataFlush()
		elseif k == "update_reward" then
			if self.index == BuildTowerTipsView.RwardPanel and self.reward_panel then
				self:InitReward()
			end
		end
    end
end

function FuBenDefenseTips:ShowIndexPanel(index, hide)
	if self.build_panel and self.desc_panel and self.updata_panel then
		self.build_panel:SetActive(self.index == BuildTowerTipsView.BuildPanel)
		self.desc_panel:SetActive(self.index == BuildTowerTipsView.DescPanel)
		self.updata_panel:SetActive(self.index == BuildTowerTipsView.UpdataPanel)
		self.reward_panel:SetActive(self.index == BuildTowerTipsView.RwardPanel)
	end

	if self.index == BuildTowerTipsView.BuildPanel and self.build_panel then
		if hide then
			self:InitBuild()
		end
	elseif self.index == BuildTowerTipsView.DescPanel and self.desc_panel then
		if hide then
			self:InitDesc()
		end
	elseif self.index == BuildTowerTipsView.UpdataPanel and self.updata_panel then
		if hide then
			self:UpdataFlush()
		end
	elseif self.index == BuildTowerTipsView.RwardPanel and self.reward_panel then
		if hide then
			self:InitReward()
		end
	end
end

----------- 创建防御塔界面
function FuBenDefenseTips:InitBuild()
	local name_table = self.node_list["BuildPanel"]:GetComponent(typeof(UINameTable))
	-- self.node_list = U3DNodeList(name_table, self)	
	self.defense_cell_list = {}
	self.list_view = U3DObject(name_table:Find("ListView"))
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetDefenseNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.FlushDefenseCellView, self) 
	self:ShowIndexBuild()
end

function FuBenDefenseTips:GetDefenseNumberOfCells()
	return 3
end

function FuBenDefenseTips:FlushDefenseCellView(cell, data_index)
	data_index = data_index + 1
	local build_cell = self.defense_cell_list[cell]
	if build_cell == nil then
		self.defense_cell_list[cell] = DefenseBuildCell.New(cell.gameObject)
		self.defense_cell_list[cell]:SetClickCallBack(BindTool.Bind(self.OnClickCreateBuild, self))
		build_cell = self.defense_cell_list[cell]
	end
	local list_data = FuBenData.Instance:GetDefenseTowerOneLevelCfg()
	build_cell:SetIndex(data_index)
	build_cell:SetData(list_data[data_index])
end

function FuBenDefenseTips:ShowIndexBuild()
	if self.defense_obj and self.defense_obj.ShowAttackRangeRadius then
		self.defense_obj:ShowAttackRangeRadius()
	end
end

function FuBenDefenseTips:SetTargetObjData(target_obj)
	if target_obj == nil or target_obj:GetVo() == nil then return end

	self.defense_obj = target_obj
	self.pos_index = target_obj:GetVo().pos_index
end

function FuBenDefenseTips:OnClickCreateBuild(index)
	if self.pos_index == nil then return end
	FuBenCtrl.Instance:SendBuildTowerReq(BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_BUILD, self.pos_index, index-1)
	self:Close()
end

--------------------------------- 防御塔介绍界面--------------------------
function FuBenDefenseTips:InitDesc()
	local name_table = self.node_list["DescPanel"]:GetComponent(typeof(UINameTable))
	self.desc_node_list = U3DNodeList(name_table, self)
	self:DescFlush()
end

function FuBenDefenseTips:DescFlush()
	local desc_index = FuBenData.Instance:GetDescIndex()
	local desc_cfg = FuBenData.Instance:GetDefenseTowerOneLevelCfg()

	if desc_cfg == nil then return end
	self.desc_node_list["TextName"].text.text = desc_cfg[desc_index].tower_name
	self.desc_node_list["TextDesc"].text.text = desc_cfg[desc_index].preview

	local defense_data = FuBenData.Instance:GetBuildTowerFBInfo()
	local str = defense_data.douhun >= desc_cfg[desc_index].need_douhun and Language.DefenseFb.CanXiuJian or Language.DefenseFb.CanNotXiuJian
	local color = defense_data.douhun >= desc_cfg[desc_index].need_douhun and TEXT_COLOR.GREEN or TEXT_COLOR.RED

	self.desc_node_list["TextXiuJian"].text.text = ToColorStr(str, color)
	self.desc_node_list["TextCount"].text.text = string.format(Language.DefenseFb.NeedDouhun, ToColorStr(desc_cfg[desc_index].need_douhun, color))
end

----------------------------------防御升级---------------------------
function FuBenDefenseTips:InitUpdata()
	self.build_index = 1
	local name_table = self.node_list["UpdataPanel"]:GetComponent(typeof(UINameTable))
	self.updata_node_list = U3DNodeList(name_table, self)
	self.updata_node_list["BtnUpdata"].button:AddClickListener(BindTool.Bind(self.OnClickDefenseBtn, self, BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_UPGRADE, 0))
	self.updata_node_list["BtnDismantle"].button:AddClickListener(BindTool.Bind(self.OnClickDefenseBtn, self, BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_REMOVE, 0))
end

function FuBenDefenseTips:SetBuildTargetObjData(target_obj)
	if self.defense_pos_list == nil then
		self.defense_pos_list = FuBenData.Instance:GetDefensePosList()
	end
	if target_obj == nil or self.index ~= BuildTowerTipsView.UpdataPanel then return end

	self.target_obj = target_obj
	for k,v in ipairs(self.defense_pos_list) do
		if v.pos_x == self.target_obj.vo.pos_x and v.pos_y == self.target_obj.vo.pos_y then
			self.build_index = v.pos_index
			if self.target_obj and self.target_obj.ShowTowerAttackRangeRadius then
				self.target_obj:ShowTowerAttackRangeRadius()
			end
			break
		end
	end
end

function FuBenDefenseTips:UpdataFlush()
	if self.build_index == nil then return end

	local defense_data = FuBenData.Instance:GetBuildTowerFBInfo()
	local defense_douhun = defense_data.douhun or 0
	local tower_info_list = defense_data.tower_info_list

	if tower_info_list[self.build_index] == nil then
		return
	end

	local defense_tower = tower_info_list[self.build_index]
	local now_defense, next_defense = FuBenData.Instance:GetDefenseTowerNextCfg(defense_tower.tower_type, defense_tower.tower_level)

	if now_defense then
		local monster_config = BossData.Instance:GetMonsterInfo(now_defense.monster_id)
		if nil ~= monster_config then
			self.updata_node_list["TextName"].text.text = (monster_config.name)
		end
	end

	if next_defense ~= nil then
		self.updata_node_list["BtnUpdata"]:SetActive(true)
		local color = defense_douhun < next_defense.need_douhun and COLOR.RED or COLOR.WHITE
		self.updata_node_list["TextCount"].text.text = ToColorStr(next_defense.need_douhun, color)
		self.updata_node_list["TextTower2"].text.text = (next_defense.instruction)
	else
		self.updata_node_list["BtnUpdata"]:SetActive(false)
		self.updata_node_list["TextCount"].text.text = (Language.DefenseFb.TowerMaxLevel)
		self.updata_node_list["TextTower2"].text.text = (Language.DefenseFb.TowerMaxLevel)
	end

	if now_defense ~= nil then
		self.updata_node_list["TextReturn"].text.text = (now_defense.return_douhun)
		self.updata_node_list["TextTower1"].text.text = (now_defense.instruction)
	end
end

function FuBenDefenseTips:OnClickDefenseBtn(operate_type, param2)
	local defense_data = FuBenData.Instance:GetBuildTowerFBInfo()
	if self.build_index == nil or self.defense_pos_list == nil or defense_data == nil then return end

	local tower_info_list = defense_data.tower_info_list
	local defense_tower = tower_info_list[self.build_index]
	local now_defense, next_defense = FuBenData.Instance:GetDefenseTowerNextCfg(defense_tower.tower_type, defense_tower.tower_level)
	if operate_type ~= BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_REMOVE and defense_data and defense_data.douhun >= next_defense.need_douhun then
		for k,v in ipairs(self.defense_pos_list) do
			if self.build_index == v.pos_index and self.target_obj and self.target_obj:GetRoot() then
				EffectManager.Instance:PlayControlEffect(self.target_obj, "effects/prefab/boss/2045_prefab", "FYT_SJ", self.target_obj:GetRoot().transform.position)
			end
		end
	end

	FuBenCtrl.Instance:SendBuildTowerReq(operate_type, self.build_index, param2)
	if operate_type == BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_REMOVE then
		self:Close()
	end
end

----------------------------------掉落统计---------------------------
function FuBenDefenseTips:InitReward()
	local name_table = self.node_list["RewardPanel"]:GetComponent(typeof(UINameTable))
	-- local reward_node = U3DNodeList(name_table, self)
	-- local reward_list = FuBenData.Instance:GetBuildTowerRewardList()
	self.list_defence_view = U3DObject(name_table:Find("List"))
	local list_view_delegate = self.list_defence_view.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	local data = FuBenData.Instance:GetBuildTowerRewardByNum()
	local num = FuBenData.Instance:GetBuildTowerRewardNum()
	local flag = num < 5
	U3DObject(name_table:Find("BG")):SetActive(flag)
	U3DObject(name_table:Find("Scroll")):SetActive(not flag)
	if data and num < 5 then
		for k,v in pairs(self.item_list) do
			if data[k] then
				v:SetData(data[k])
				v:SetParentActive(true)
			else
				v:SetParentActive(false)
			end
		end
	end
end

function FuBenDefenseTips:GetNumberOfCells()
	local num = FuBenData.Instance:GetBuildTowerRewardNum()
	return num
end

function FuBenDefenseTips:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = DefenseItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data = FuBenData.Instance:GetBuildTowerRewardByNum()
	if data then
		group_cell:SetData(data[data_index + 1])
	end
end

--------------------------掉落cell--------------
DefenseItemCell = DefenseItemCell or BaseClass(BaseCell)
function DefenseItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function DefenseItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DefenseItemCell:OnFlush()
	if nil == self.data then return end
	self.item_cell:SetData(self.data)
end

---------------------------------防御塔cell
DefenseBuildCell = DefenseBuildCell or BaseClass(BaseCell)
function DefenseBuildCell:__init()
	self.node_list["BtnBuild"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function DefenseBuildCell:__delete()

end

function DefenseBuildCell:OnFlush()
	if self.data == nil then return end

	self.node_list["TextName"].text.text = self.data.tower_name
	self.node_list["TextCount"].text.text = self.data.need_douhun
	self.node_list["TextBuild"].text.text = self.data.tower_spec

	local bundle, asset = ResPath.GetDefenseIcon(self.data.tower_type + 1)
	self.node_list["BtnBuild"].image:LoadSprite(bundle, asset)
end

function DefenseBuildCell:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function DefenseBuildCell:OnClick()
	if self.click_callback then
		self.click_callback(self.data.tower_type + 1)
	end
end