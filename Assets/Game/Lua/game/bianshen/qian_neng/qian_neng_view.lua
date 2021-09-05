-- 幻域-神魔-升级
QianNengView = QianNengView or BaseClass(BaseRender)
local SERIES = 4
function QianNengView:__init()
	
end

function QianNengView:ReleaseCallBack()

end

function QianNengView:LoadCallBack()
	self.list_index = 1
	self.consumable_item = ItemCell.New()
	self.consumable_item:SetInstanceParent(self.node_list["ItemCell"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNumber"])
	self.cell_list = {}

	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["ButtonUp"].button:AddClickListener(BindTool.Bind(self.OnClickUp, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))

	self.cur_select_index = 1
	self.select_index = BianShenData.Instance:GetSeqBySelectIndex(self.cur_select_index)
	
	self.item_list = {}
	self:InitCell()
	self:DestoryGameObject()
	self:UpdateList()
end

function QianNengView:OpenCallBack()
	self.cur_role_index = nil
	self.cur_select_index = 1
	self.select_index = BianShenData.Instance:GetSeqBySelectIndex(self.cur_select_index)
	self:OnClickSelect(1)
	self:CheckIsSelect()
end

function QianNengView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	if self.consumable_item then 
		self.consumable_item:DeleteMe()
		self.consumable_item = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	self.fight_text = nil
	self.cur_select_index = nil
	self.select_index = nil
end

function QianNengView:OnClickUp()
	BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_WASH, self.select_index - 1)
end

function QianNengView:InitCell()
	self.left_bar_list = {}
	for i = 1, 4 do
		self.left_bar_list[i] = {}
		self.left_bar_list[i].select_btn = self.node_list["SelectBtn" .. i]
		self.left_bar_list[i].list = self.node_list["List" .. i]
		self.left_bar_list[i].btn_text = self.node_list["BtnText" .. i]
		self.left_bar_list[i].red_state = self.node_list["RedPoint" .. i]
		self.left_bar_list[i].btn_text_high = self.node_list["TxtBtnHigh" .. i]
		self.node_list["SelectBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end
end

function QianNengView:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
	for i = 1, 4 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	self.node_list["BtnRightActive" .. self.list_index]:SetActive(true) 
end

function QianNengView:OnClickOpen()
	MarketData.Instance:SetPurchaseItemId(1)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 1})
end

function QianNengView:SetSelectItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetHighLight(self.cur_select_index)
		end
	end
end

function QianNengView:DestoryGameObject()
	if nil == next(self.item_list) then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end

function QianNengView:UpdateList()
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
	self.left_bar_list[self.list_index].list:SetActive(false)
	self.item_list = {}
	self.item_cell_list = {}

	for i = 1, SERIES do
		local bianshen_item_list = BianShenData.Instance:GetListByColorType(i + 2)
		self.left_bar_list[i].select_btn:SetActive(#bianshen_item_list > 0)
		self.left_bar_list[i].btn_text.text.text = Language.BianShen.ShengQiType[i]
		self.left_bar_list[i].btn_text_high.text.text = Language.BianShen.ShengQiType[i]
		self:LoadCell(i, bianshen_item_list)
	end
end

function QianNengView:LoadCell(index, bianshen_item_list)
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. index)
	res_async_loader:Load("uis/views/bianshen_prefab", "BianShenHeadItem", nil, function(prefab)
		if nil == prefab then
			return
		end
		local data_list = BianShenData.Instance:AfterSortList()
		for i = 1, #bianshen_item_list do
			local seq = bianshen_item_list[i].seq + 1
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.left_bar_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.left_bar_list[index].list.toggle_group
			local item_cell = BianShenHeadItem.New(obj)
			item_cell:SetTabIndex(2)
			local data = BianShenData.Instance:GetDatalistBySeq(bianshen_item_list[i].seq)
			item_cell:SetData(data)
			item_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, seq, data, item_cell))
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[seq] = item_cell
		end
		self:CheckIsSelect()
		self:Flush()
	end)
end

function QianNengView:CheckIsSelect()
	if self.left_bar_list[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
		return
	end
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
	self:SetSelectItem()
end

function QianNengView:GetSelectIndex()
	return self.cur_select_index
end

function QianNengView:OnClickRoleListCell(cell_index, cell_data, item_cell)
	if self.cur_select_index == cell_index then return end
	self.last_item_index = self.cur_select_index

	BianShenData.Instance:SetSelectIndex(cell_index)
	self.select_index = cell_data.seq + 1
	self.cur_select_index = cell_index
	self:FlushAllHl()
	self:SetSelectItem()
	self:Flush()
	BianShenCtrl.Instance:SetCurSelectIndex(self.select_index - 1)
end

function QianNengView:OnFlush(param_t)
	local select_cfg = BianShenData.Instance:GetSingleDataBySeq(self.select_index - 1)
	if not select_cfg then return end
	local select_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return end

	local is_max = select_info.potential_level >= BianShenData.Instance:GetMaxPotentialLevel(select_cfg.seq)
	local is_active = BianShenData.Instance:CheckGeneralIsActive(select_cfg.seq)

	local name_str = ToColorStr(select_cfg.name, ITEM_COLOR[select_cfg.color])
	self.node_list["Name"].text.text = string.format("%s·Lv.%s", name_str, select_info.potential_level)
	self.node_list["BtnBuy"]:SetActive(select_cfg.color > 3)

	local data_list = BianShenData.Instance:AfterSortList()
	for i = 1, #self.item_cell_list do
		local data = data_list[i]
		if data and data.seq and self.item_cell_list[data.seq + 1] then
			self.item_cell_list[data.seq + 1]:SetData(data)
		end
	end
	
	--配置表里的数据是升到此条等级所需的数据
	local upgrade_item, need_num = BianShenData.Instance:GetPotentialUpgradeItem(select_cfg.seq, select_info.potential_level + 1)
	local own_num = ItemData.Instance:GetItemNumInBagById(upgrade_item)
	local str = ToColorStr(own_num, own_num >= need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED)
	self.node_list["ItemNum"].text.text = is_max and Language.Common.MaxLevelDesc or (str .. " / ".. need_num)
	self.node_list["Red"]:SetActive(own_num >= need_num and not is_max and is_active)
	self.consumable_item:SetData({item_id = upgrade_item})
	self.node_list["NextText"]:SetActive(not is_max)
	UI:SetButtonEnabled(self.node_list["ButtonUp"], not is_max)
	self.node_list["TxtBtnup"].text.text = is_max and Language.BianShen.YiManJi or Language.BianShen.UpgradeLv

	local attr_data = BianShenData.Instance:GetPotentialAttr(select_cfg.seq,select_info.potential_level)
	local next_attr_data = BianShenData.Instance:GetPotentialAttr(select_cfg.seq,select_info.potential_level + 1)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(attr_data)
	end
	self.node_list["CurrAttack"].text.text = string.format(Language.BianShen.gongji, attr_data.gongji)
	self.node_list["CurrDef"].text.text = string.format(Language.BianShen.fangyu, attr_data.fangyu)
	self.node_list["CurrHp"].text.text = string.format(Language.BianShen.hp, attr_data.maxhp)
	self.node_list["NextAttack"].text.text = math.ceil(next_attr_data.gongji - attr_data.gongji)
	self.node_list["NextDef"].text.text = math.ceil(next_attr_data.fangyu - attr_data.fangyu)
	self.node_list["NextHp"].text.text = math.ceil(next_attr_data.maxhp - attr_data.maxhp)

	-- 技能信息
	local is_hava_special_skill = select_cfg.active_skill_type > 0
	self.node_list["TextTip"]:SetActive(not is_hava_special_skill)
	self.node_list["SkillInfo"]:SetActive(is_hava_special_skill)
	local other_cfg = BianShenData.Instance:GetOtherCfg()
	if is_hava_special_skill then
		local level = select_info.potential_level > 0 and select_info.potential_level or 1
		local potential_cfg = BianShenData.Instance:GetSinglePotentialCfg(select_cfg.seq, level)
		local special_skill_cfg = nil
		if potential_cfg and potential_cfg.special_skill_level and other_cfg then
			local skill_level = potential_cfg.special_skill_level <= 0 and 1 or potential_cfg.special_skill_level
			local skill_level = other_cfg.specialskill_max <= skill_level and skill_level or (skill_level + 1)
			special_skill_cfg = BianShenData.Instance:GetSpecialSkillInfoByTypeLevel(select_cfg.active_skill_type, skill_level)
		end

		if special_skill_cfg then
			self.node_list["IconSKill1"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. special_skill_cfg.icon_id))
			local upgrade_level = BianShenData.Instance:GetUpGradeByLevel(select_cfg.seq, level, potential_cfg.special_skill_level)
			local str = ""
			if other_cfg.specialskill_max <= potential_cfg.special_skill_level then
				str = string.format(Language.BianShen.UpgradeLvJinJieTwo, special_skill_cfg.skill_name)
			else
				str = string.format(Language.BianShen.UpgradeLvJinJie, special_skill_cfg.skill_name, upgrade_level)
			end
			self.node_list["SkillName"].text.text = str
			self.node_list["SkillDec"].text.text = special_skill_cfg.skill_tips
		end
	end

	if self.cur_role_index ~= self.select_index then
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			UIScene:SetRoleModelScale(1.3)
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end)
		local bundle, asset = ResPath.GetMingJiangRes(select_cfg.image_id)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		self.cur_role_index = self.select_index
	end

	for i = 1, SERIES do
		local is_show_red = BianShenData.Instance:ShowRemindQianNengByColor(i + 2)
		self.left_bar_list[i].red_state:SetActive(is_show_red)
	end

	for k, v in pairs(self.item_cell_list) do
		v:SetUpArrow()
	end
end

function QianNengView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function QianNengView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(312)
end

function QianNengView:UITween()
	UITween.MoveShowPanel(self.node_list["ListPanel"], Vector3(-200, -33, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(939, -27.5, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ListPanel"], Vector3(-800, -33, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["LvAndName"], Vector3(-85, 420, 0), 0.7)
end