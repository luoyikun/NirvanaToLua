PlayerTitleHuanhuaView = PlayerTitleHuanhuaView or BaseClass(BaseView)

local CLOTHES_TOGGLE = 1
local WEAPONS_TOGGLE = 0

function PlayerTitleHuanhuaView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/player_prefab", "TitleHuanHuaView"}
	}
	self.cell_list = {}
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = 1
	self.current_title_id = 0
	self.title_obj_list = {}
	self.is_modal = true
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function PlayerTitleHuanhuaView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(894, 560, 0)
	self.node_list["Txt"].text.text = Language.Title.TitleHuanHua
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNum"])

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHuanhuaCell, self)

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnActivity"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["UpGradeButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["ButtonUse"].button:AddClickListener(BindTool.Bind(self.OnAdronClick, self))
	self.node_list["RawImgBg"].raw_image:LoadSprite("uis/rawimages/bg_title_huanhua", "bg_title_huanhua.jpg", function()
			self.node_list["RawImgBg"]:SetActive(true)
			self.node_list["RawImgBg"].raw_image:SetNativeSize()
		end)

	local cur_upgrade_cfg_list = TitleData.Instance:GetUpgradeList()
	if cur_upgrade_cfg_list and cur_upgrade_cfg_list[1] then
		self.current_title_id = cur_upgrade_cfg_list[1].title_id
	end
end

function PlayerTitleHuanhuaView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	self.title_obj_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = nil

	self.fight_text = nil
end

function PlayerTitleHuanhuaView:OpenCallBack()
	self:SetNotifyDataChangeCallBack()
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = 1
	self:Flush()
end

function PlayerTitleHuanhuaView:CloseCallBack()
	self:RemoveNotifyDataChangeCallBack()
end

function PlayerTitleHuanhuaView:OnClickActivate()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id)
	local data_list = ItemData.Instance:GetBagItemDataList()
	if not cfg or not upgrade_cfg then return end
	local item_id = cfg.stuff_id
	for k, v in pairs(data_list) do
		if v.item_id == item_id and v.num >= upgrade_cfg.stuff_num then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end

	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	return
end

function PlayerTitleHuanhuaView:OnClickClose()
	self:Close()
end

function PlayerTitleHuanhuaView:OnClickUpGrade()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id, true)
	if not next_upgrade_cfg then return end
	local item_id = next_upgrade_cfg.stuff_id
	if ItemData.Instance:GetItemNumInBagById(item_id) >= next_upgrade_cfg.stuff_num then
		TitleCtrl.Instance:SendUpgradeTitleReq(next_upgrade_cfg.title_id)
	else
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	end
end

function PlayerTitleHuanhuaView:OnAdronClick()
	if not TitleData.Instance:GetIsUsed(self.current_title_id) then
		local used_title_list = {self.current_title_id, 0, 0}
		TitleCtrl.Instance:SendCSUseTitle(used_title_list)
	end
end

function PlayerTitleHuanhuaView:GetNumberOfCells()
	return #self.cur_upgrade_cfg_list or 0
end

function PlayerTitleHuanhuaView:RefreshHuanhuaCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	if not huanhua_cell then
		huanhua_cell = TitleHuanhuaItem.New(cell)
		self.cell_list[cell] = huanhua_cell
		huanhua_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	end
	huanhua_cell:SetData(self.cur_upgrade_cfg_list[data_index + 1])
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickHuanhuaCell, self, self.cur_upgrade_cfg_list[data_index + 1], data_index, huanhua_cell))
	huanhua_cell:SetHighLight(self.cur_cell_index == (data_index + 1))
end

function PlayerTitleHuanhuaView:OnClickHuanhuaCell(cfg, index, huanhua_cell)
	self.cur_cell_index = index + 1
	huanhua_cell:SetHighLight(true)
	self:SetHuanhuaInfo(index, cfg)
	self.current_title_id = cfg.title_id
end

-- 设置幻化面板显示
function PlayerTitleHuanhuaView:SetHuanhuaInfo(index, cfg)
	self.cur_cell_index = self.cur_cell_index or index
	local cfg = cfg or self.cur_upgrade_cfg_list[self.cur_cell_index]
	if not cfg then return end
	local upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id)
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id, true)
	if not upgrade_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(upgrade_cfg.stuff_id)
	if item_cfg then
		local title_cfg = TitleData.Instance:GetTitleCfg(cfg.title_id)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(title_cfg.name or "").."</color>"
		self.node_list["TxtNameIma"].text.text = name_str
	end
	self.node_list["TxtNameIma2"]:SetActive(TitleData.Instance:GetTitleActiveState(cfg.title_id))
	self.node_list["TxtNameIma2"].text.text = string.format("LV.%s", upgrade_cfg.level) 

	local bag_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.stuff_id)
	if next_upgrade_cfg then
		local bag_num_str = bag_num < next_upgrade_cfg.stuff_num and string.format(Language.Mount.ShowRedNum, bag_num) or string.format(Language.Mount.ShowGreenNum, bag_num)
 		self.node_list["Lable"].text.text = ToColorStr(bag_num_str, TEXT_COLOR.GREEN) .. ToColorStr(" / " .. next_upgrade_cfg.stuff_num, TEXT_COLOR.GREEN)
	else
 		self.node_list["Lable"].text.text = Language.Common.MaxLevelDesc
	end
	local attr_list = CommonDataManager.GetAttributteNoUnderline(upgrade_cfg)
	self.node_list["TxtGongJi"].text.text = attr_list.gongji or 0
	self.node_list["TxtFangYu"].text.text = attr_list.fangyu or 0
	self.node_list["TxtShengMing"].text.text = attr_list.maxhp or 0
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(attr_list)
	end

	local data = {item_id = upgrade_cfg.stuff_id}
	self.item:SetData(data)
	self:SetButtonsState()
	self:SetModel()
end

function PlayerTitleHuanhuaView:SetModel()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	if cfg then
		if self.title_obj_list[self.res_id] then
			self.title_obj_list[self.res_id]:SetActive(false)
		end

		if self.title_obj_list[cfg.title_id] then
			self.title_obj_list[cfg.title_id]:SetActive(true)
		else
			local bundle, asset = ResPath.GetTitleModel(cfg.title_id)
			local async_loader = AllocAsyncLoader(self, "title_loader_" .. cfg.title_id)
			async_loader:Load(bundle, asset, function(obj)
				if not IsNil(obj) then
					obj.transform:SetParent(self.node_list["TitleRoot"].transform, false)
					obj.transform.localScale = Vector3(1.6, 1.6, 1.6)

					TitleData.Instance:LoadTitleEff(obj, cfg.title_id, true)
					obj:SetActive(self.res_id == cfg.title_id)
				end
			end)
			self.title_obj_list[cfg.title_id] = async_loader
		end

		self.res_id = cfg.title_id
	end
end

function PlayerTitleHuanhuaView:SetButtonsState()
	local cur_cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local is_active = TitleData.Instance:GetTitleActiveState(cur_cfg.title_id)
	local use_title_id = TitleData.Instance:GetUsedTitle()
	self.node_list["UpGradeButton"]:SetActive(is_active)
	self.node_list["ButtonUse"]:SetActive(is_active and use_title_id ~= cur_cfg.title_id)
	self.node_list["ImgUse"]:SetActive(use_title_id == cur_cfg.title_id)
	self.node_list["BtnActivity"]:SetActive(not is_active)

	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cur_cfg.title_id, true)
	if nil ~= next_upgrade_cfg then
		UI:SetButtonEnabled(self.node_list["UpGradeButton"], true)
		UI:SetGraphicGrey(self.node_list["UpGradeButton"], false)
		self.node_list["TxtUpGradeButton"].text.text = Language.Common.UpGrade
	else
		UI:SetButtonEnabled(self.node_list["UpGradeButton"], false)
		UI:SetGraphicGrey(self.node_list["UpGradeButton"], true)
		self.node_list["TxtUpGradeButton"].text.text = Language.Common.YiManJi
	end
end

function PlayerTitleHuanhuaView:OnFlush(param)
	self.cur_upgrade_cfg_list = TitleData.Instance:GetUpgradeList()

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end

	self:SetHuanhuaInfo(self.cur_cell_index, self.cur_upgrade_cfg_list[self.cur_cell_index])
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

--移除物品回调
function PlayerTitleHuanhuaView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function PlayerTitleHuanhuaView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function PlayerTitleHuanhuaView:ItemDataChangeCallback()
	self:Flush()
end

------------------------------------------------------------------------
TitleHuanhuaItem = TitleHuanhuaItem or BaseClass(BaseCell)

function TitleHuanhuaItem:__init(instance)

end

function TitleHuanhuaItem:__delete()
end

function TitleHuanhuaItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function TitleHuanhuaItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function TitleHuanhuaItem:OnFlush()
	if not self.data then return end
	local cfg = TitleData.Instance:GetTitleCfg(self.data.title_id)
	if not cfg then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.stuff_id)
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(self.data.title_id, true)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(cfg.name or "").."</color>"
		self.node_list["Text"].text.text = name_str
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		
		self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	end
	self.node_list["RedPoint"]:SetActive((nil ~= next_upgrade_cfg) and ItemData.Instance:GetItemNumInBagById(self.data.stuff_id) >= next_upgrade_cfg.stuff_num)

	local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
	self.node_list["Quality"].image:LoadSprite(bundle1, asset1)
end

function TitleHuanhuaItem:ListenClick(handler)
	self.handler = handler
	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler or BindTool.Bind(self.Click, self))
end