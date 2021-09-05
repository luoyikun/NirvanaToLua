--进阶 UpgradeContent
SymbolUpgradeView = SymbolUpgradeView or BaseClass(BaseRender)

local SYMBOL_COUNT = 5					-- 元素之灵的个数
local EFFECT_CD = 1.8

function SymbolUpgradeView:__init()

	self.cur_select_index = 0			--当前所选中的元素的索引 0 开始
	self.last_model_index = -1			--上一个模型的索引
	self.attribute_cell_list = {}		--属性的list表
	self.tabbar_cell_list = {}			--TabBar的格子list表
	self.wuxing_list_active = {}		--五行的激活情况
	self.attribute_list_data = {}		--属性list data数据
	self.jinjie_next_time = 0
	self.is_one_key = false
	self.is_auto_buy = false
	self.is_auto = false
	self.is_can_auto = true
	self.temp_grade = -1 				--上一等级

	self:InitSymbolModel()

	self.consume_img = ItemCell.New()
	self.consume_img:SetInstanceParent(self.node_list["Consume_Img"])
	self.node_list["JinjieBtn"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self))
	self.node_list["AutoBtn"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function SymbolUpgradeView:__delete()
	self.fight_text = nil
	
	for i,v in ipairs(self.attribute_cell_list) do
		v:DeleteMe()
	end
	self.attribute_cell_list = {}

	for i,v in ipairs(self.tabbar_cell_list) do
		v:DeleteMe()
	end
	self.tabbar_cell_list = {}

	if self.symbol_model then
		self.symbol_model:DeleteMe()
		self.symbol_model = nil
	end

	--清理对象和变量
	self.consume_img:DeleteMe()
	self.consume_img = nil

	self.tab_item_list = {}
	self.last_model_index = -1
	self.jinjie_next_time = nil
	self.temp_grade = -1
end

function SymbolUpgradeView:OpenCallBack()
	local right_pos = self.node_list["RightPanel"].transform.anchoredPosition
	local left_pos = self.node_list["LeftPanel"].transform.anchoredPosition
	local up_help_pos = self.node_list["BtnHelp"].transform.anchoredPosition
	local up_name_pos = self.node_list["UpMove"].transform.anchoredPosition
	local under_pos = self.node_list["NodePreText"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(up_help_pos.x, up_help_pos.y + 200, up_help_pos.z))
	UITween.MoveShowPanel(self.node_list["UpMove"], Vector3(up_name_pos.x, up_name_pos.y + 200, up_name_pos.z))
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(right_pos.x + 600, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["LeftPanel"], Vector3(left_pos.x - 200, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["NodePreText"], Vector3(under_pos.x, under_pos.y - 100, under_pos.z))

	local data_list = SymbolData.Instance:GetElementList()
	if #data_list == 0 then return end

	if SymbolData.Instance:GetElementInfo(0).grade <= 0 then
		self:SetEnableStated(true)
	else
		self:SetEnableStated(false)
		self.node_list["CenterDisplay"]:SetActive(true)
		self:SetSymbolModelData(SymbolData.Instance:GetElementInfo(0).wuxing_type)
	end
	self.cur_select_index = 0
	self.node_list["EffectRoot"]:SetActive(false)

	self:InitTabBarListView()
end

function SymbolUpgradeView:CloseCallBack()
	self.temp_grade = -1
	self:CancelTheQuest()
end

function SymbolUpgradeView:OnFlush(param_t)
	local data_list = SymbolData.Instance:GetElementList()
	if #data_list == 0 then return end

	for k,v in pairs(data_list) do
		if v.id ~= 0 then
			local limit_cfg = SymbolData.Instance:GetUpgradeLimitById(v.id)
			local last_cfg = SymbolData.Instance:GetElementInfo(v.id - 1)
			if v.grade > 0 and last_cfg.grade >= limit_cfg.last_element_level + 1 then
				self.wuxing_list_active[k] = true
			else
				self.wuxing_list_active[k] = false
			end
		else
			if v.grade <= 0 then
				self.wuxing_list_active[k] = false
			else
				self.wuxing_list_active[k] = true
			end
		end
	end
	self:LeftFlush()
	self:RightFlush()
end

function SymbolUpgradeView:LeftFlush()
	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if element_info.grade <=0 then return end
	--当级属性
	local cur_info_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade)
	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_info_cfg)

	self.node_list["TxtHP"].text.text = cur_attr.maxhp
	self.node_list["TxtGongJi"].text.text = cur_attr.gongji
	self.node_list["TxtFangYu"].text.text = cur_attr.fangyu
	self.node_list["TxtMingZhong"].text.text = cur_attr.mingzhong
	self.node_list["TxtShanBi"].text.text = cur_attr.shanbi
	self.node_list["TxtBaoJi"].text.text = cur_attr.baoji
	self.node_list["Txrkangbao"].text.text = cur_attr.jianren

	local next_info_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade + 1)
	if next_info_cfg then
		local next_attr = CommonDataManager.GetAttributteNoUnderline(next_info_cfg)
		self.node_list["ArrowGongJi"]:SetActive(true)
		self.node_list["ArrowFangYu"]:SetActive(true)
		self.node_list["ArrowHp"]:SetActive(true)
		self.node_list["TxtGongJiAddValue"].text.text = next_attr.gongji - cur_attr.gongji
		self.node_list["TxtFangYuAddValue"].text.text = next_attr.fangyu - cur_attr.fangyu
		self.node_list["TxtHpAddValue"].text.text = next_attr.maxhp - cur_attr.maxhp
	else
		self.node_list["ArrowGongJi"]:SetActive(false)
		self.node_list["ArrowFangYu"]:SetActive(false)
		self.node_list["ArrowHp"]:SetActive(false)
	end

	if SymbolData.Instance:GetElementMaxGrade() <= element_info.grade then return end
	if self.temp_grade < 0 then
		self.temp_grade = element_info.grade
	else
		if self.temp_grade < element_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["EffectRoot"]:SetActive(false)
				self.node_list["EffectRoot"]:SetActive(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end
		end
		self.temp_grade = element_info.grade
	end
end

function SymbolUpgradeView:RightFlush()
	local cfg = SymbolData.Instance:GetYHStuffCfg()
	local cur_have = ItemData.Instance:GetItemNumInBagById(cfg.item_id)
	local data = {item_id = cfg.item_id}
	self.consume_img:SetData(data)

	if not self.wuxing_list_active[self.cur_select_index] then		--如果还没激活就初始化数据
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
		self.node_list["ImgProgressBG"].slider.value = 0
		self.node_list["TxtLevel"].text.text = ""
		self.node_list["TxtConsume"].text.text = cur_have .. "/0"
		self.node_list["TxtProgressBG"].text.text = "0/0"
		return
	end

	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)

	--当级属性
	local cur_info_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade)
	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_info_cfg)

	local show_color = TEXT_COLOR.GREEN_4
	if cur_have < cur_info_cfg.need_item_num then
		show_color = TEXT_COLOR.RED_4
	end

	local show_num = ToColorStr(cur_have, show_color)
	self.node_list["TxtConsume"].text.text = show_num .. " / " .. cur_info_cfg.need_item_num

	local cur_bless = element_info.bless
	local need_bless = cur_info_cfg.bless_val_limit
	local percent = 0
	local str = Language.Common.NumToChs[element_info.grade - 1]
	local next_str = Language.Common.NumToChs[element_info.grade]

	if element_info.grade >= SymbolData.Instance:GetElementMaxGrade() then
		percent = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade).add_texture_percent_attr / 100
		self.node_list["TxtProgressBG"].text.text = Language.Common.YiMan
		self.node_list["ImgProgressBG"].slider.value = 1
		self.node_list["TxtExplain"].text.text = Language.Symbol.DangQianJieShu .. Language.Symbol.TiSheng
		self.node_list["NodeBuy"]:SetActive(false)
	else
		percent = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade + 1).add_texture_percent_attr / 100
		self.node_list["TxtProgressBG"].text.text = element_info.bless .. "/" .. cur_info_cfg.bless_val_limit
		self.node_list["ImgProgressBG"].slider.value = cur_bless / need_bless
		self.node_list["TxtExplain"].text.text = next_str.. Language.Symbol.Jie .. Language.Symbol.TiSheng
		self.node_list["NodeBuy"]:SetActive(true)
	end

	self.node_list["TxtPercent"].text.text = percent .. "%"
	local percent2 = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade).add_texture_percent_attr / 100
	self.node_list["TxtPercent2"].text.text = percent2 .. "%"
	self.node_list["TxtLevel"].text.text = str .. Language.Symbol.Jie
	local capability = CommonDataManager.GetCapabilityCalculation(cur_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
	local color = (element_info.grade / 3 + 1) >= 5 and 5 or math.floor(element_info.grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color] .. ">" .. Language.Symbol.ElementsName[element_info.wuxing_type] .. "</color>"
	self.node_list["TxtName"].text.text = name_str

	self.node_list["TabBarListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self:SetAutoButtonGray()
end

function SymbolUpgradeView:InitTabBarListView()
	self.tabbar_list_data = SymbolData.Instance:GetElementList()		--TabBar List 的 data数据
	local tabbar_list_delegate = self.node_list["TabBarListView"].list_simple_delegate
	tabbar_list_delegate.NumberOfCellsDel = function ()
		return #self.tabbar_list_data + 1
	end

	tabbar_list_delegate.CellRefreshDel = function(cell_obj, index)
		index = index + 1
		local cell = self.tabbar_cell_list[cell_obj]

		if nil == cell then
			cell = TabBarCell.New(cell_obj.gameObject)
			cell:SetToggleGroup(self.node_list["TabBarListView"].toggle_group)
			self.tabbar_cell_list[cell_obj] = cell
		end

		cell:SetIndex(index)
		cell:SetData(self.tabbar_list_data[index - 1])
		cell:IsOn(index - 1 == self.cur_select_index)
		cell:SetClickCallBack(BindTool.Bind(self.TabItemClick, self, cell))
	end
end

--初始化模型
function SymbolUpgradeView:InitSymbolModel()
	if not self.symbol_model then
		self.symbol_model = RoleModel.New()
		self.symbol_model:SetDisplay(self.node_list["CenterDisplay"].ui3d_display)
	end
end

--设置模式数据
function SymbolUpgradeView:SetSymbolModelData(index)
	if self.last_model_index == index then return end

	self.last_model_index = index
	local bubble,asset = ResPath.GetSpiritModel(SymbolData.ELEMENT_MODEL[index])
	self.symbol_model:SetMainAsset(bubble, asset)
	self.symbol_model:SetScale(Vector3(1.7, 1.7, 1.7))
end

--进阶一次
function SymbolUpgradeView:OnStartAdvance()
	if not self.wuxing_list_active[self.cur_select_index] then return end

	local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	local cfg = SymbolData.Instance:GetYHStuffCfg()
	local item_id = cfg.item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local need_item_num =  SymbolData.Instance:GetElementHeartCfgByGrade(info.grade).need_item_num
	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)

	local cur_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade + 1)

	if num < need_item_num and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
		end

		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["AutoToggle"].toggle.isOn = true
			end
		end
		local need = need_item_num - num
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, need)
		return
	end

	local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
	local pack_num = 1
	local next_time = 0.1

	if info.grade and SymbolData.Instance:GetElementHeartCfgByGrade(info.grade) then
		local info_up_grade_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(info.grade)
		pack_num = info_up_grade_cfg.need_item_num
	end

	SymbolCtrl.Instance:SendUpgradeGhostReq(info.id, self.is_one_key and pack_num or 1, is_auto_buy)
	self.jinjie_next_time = Status.NowTime + next_time

	self.node_list["TabBarListView"].scroller:RefreshAndReloadActiveCellViews(true)
end

function SymbolUpgradeView:SetAutoButtonGray()
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if info.grade == nil then return end

	local max_grade = SymbolData.Instance:GetElementMaxGrade() or 0
	if not info or not info.grade or info.grade <= 0
		or info.grade >= max_grade then
		self.node_list["TxtAutoJinjie"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["JinjieBtn"], false)
		UI:SetButtonEnabled(self.node_list["AutoBtn"], false)
		return
	end
	if self.is_auto then
		self.node_list["TxtAutoJinjie"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["JinjieBtn"], false)
		UI:SetButtonEnabled(self.node_list["AutoBtn"], true)
	else
		self.node_list["TxtAutoJinjie"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["JinjieBtn"], true)
		UI:SetButtonEnabled(self.node_list["AutoBtn"], true)
	end
end

--自动进阶
function SymbolUpgradeView:OnAutomaticAdvance()
	if not self.wuxing_list_active[self.cur_select_index] then return end
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)

	if info.grade == 0 then
		return
	end
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end
	ok_callback()
end

--时间延迟监听 自动进阶一次
function SymbolUpgradeView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnStartAdvance, self), jinjie_next_time)
	end
end

function SymbolUpgradeView:CancelTheQuest()
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.node_list["TxtAutoJinjie"].text.text = Language.Common.ZiDongJinJie
end

--服务端自动进阶返回监听
function SymbolUpgradeView:ElementHeartUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

--根据tabitem的index来判断点击事件
function SymbolUpgradeView:TabItemClick(cell)
	cell:OnLockClick()
	if self.wuxing_list_active[cell.index - 1] then
		self.cur_select_index = cell.index - 1
		self.temp_grade = -1
		local element_info = SymbolData.Instance:GetElementInfo(cell.index - 1)
		self:SetEnableStated(false)
		self.node_list["CenterDisplay"]:SetActive(true)
		self:SetSymbolModelData(element_info.wuxing_type)
		self:Flush()
	end
end

function SymbolUpgradeView:OnClickHelp()
	local tip_id = 248
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 设置激活状态
function SymbolUpgradeView:SetEnableStated(show_jihuo)
	self.node_list["ImgLevel"]:SetActive(not show_jihuo)
	self.node_list["ImgYuanSu"]:SetActive(show_jihuo)
	self.node_list["ImgName"]:SetActive(not show_jihuo)
	-- self.node_list["NodePreText"]:SetActive(not show_jihuo)
	self.node_list["BtnJiHuo"]:SetActive(not show_jihuo)
	self.node_list["TxtTip"]:SetActive(show_jihuo)
end

----------------------元素标签头像格子-YuanshuLeftCell-----------------------
TabBarCell = TabBarCell or BaseClass(BaseCell)

function TabBarCell:__init()
	self.model_index = 0
	self.node_list["ToggleCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	--self.node_list["BtnLock"].button:AddClickListener(BindTool.Bind(self.OnLockClick, self))
end

function TabBarCell:__delete()

end

function TabBarCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function TabBarCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TabBarCell:Lock(value)
	self.node_list["ToggleCell"].toggle.interactable = not value
	self.node_list["ImgIcon"]:SetActive(not value) 
	self.node_list["BtnLock"]:SetActive(value)
end

function TabBarCell:OnLockClick()
	local cfg = SymbolData.Instance:GetUpgradeLimitById(self.data.id)
	local tabbar_list_data = SymbolData.Instance:GetElementList()
	local tabbar_data = tabbar_list_data[self.data.id - 1]
	if tabbar_data and tabbar_data.grade - 1 < cfg.last_element_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.XuYao .. cfg.last_element_level .. Language.Symbol.Jie)
		return
	end
	if self.data and self.data.grade <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.HasNotFeed)
	end
end

function TabBarCell:SetModelIndex(index)
	self.model_index = index
end

function TabBarCell:GetModelIndex()
	return self.model_index
end

function TabBarCell:OnFlush()
	if nil == self.data then return end

	--红点提示
	self.node_list["ImgRed"]:SetActive(false)
	local item_id = SymbolData.Instance:GetYHStuffCfg().item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local need_item_num = -1

	if self.data.grade > 0 then
		need_item_num = SymbolData.Instance:GetElementHeartCfgByGrade(self.data.grade).need_item_num
		self.node_list["ImgRed"]:SetActive(num >= need_item_num and self.data.grade < SymbolData.Instance:GetElementMaxGrade() or false)
		local color = (self.data.grade / 3 + 1) >= 5 and 5 or math.floor(self.data.grade / 3 + 1)
		local str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. Language.Common.NumToChs[self.data.grade - 1] .. Language.Symbol.Jie .. "</color>"
		self.node_list["TxtName"].text.text = str
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. self.data.wuxing_type))
	else
		self.node_list["TxtName"].text.text = ""
	end
	if self.data.id == 0 then
		if self.data.grade <= 0 then
			self:Lock(true)
		else
			self:Lock(false)
		end
		return
	end

	local limit_cfg = SymbolData.Instance:GetUpgradeLimitById(self.data.id)
	local last_cfg = SymbolData.Instance:GetElementInfo(self.data.id - 1)
	if last_cfg.grade >= limit_cfg.last_element_level + 1 and self.data.grade > 0 then
		self:Lock(false)
	else
		self.node_list["ImgRed"]:SetActive(false)
		self.node_list["TxtName"].text.text = ""
		self:Lock(true)
	end
end
