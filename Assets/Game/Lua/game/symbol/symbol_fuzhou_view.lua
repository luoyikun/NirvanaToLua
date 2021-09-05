-- 附纹 FuzhouContent
SymbolFuzhouView = SymbolFuzhouView or BaseClass(BaseRender)

local SHEN_EQUIP_NUM = 10						-- 转职装部位数量

function SymbolFuzhouView:__init()
	--变量
	self.cur_equip_index = 1						--当前所选择装备 从1开始
	self.attribute_list_data = {}					--属性Item的数据
	self.cur_consume_select = 0 					--当前消耗品所选择的
	self.consume_list_data = {}						--消耗品的数据
	self.cur_wuxing_type = 0 						--当前五行
	self.wuxing_jihuo_list = {} 					--是否已激活元素之心
	self.shenzhuang_list = {}						--大天使的装备信息
	self.jinjie_next_time = 0
	self.upgrade_timer_quest = nil
	self.is_auto = false
	self.is_can_auto = true
	self.is_can_jinjie = true
	self.add_percent = 0 							--进阶的加成的百分比
	self.one_youxian_show = false						--最优先显示
	self.two_youxian_show = false

	self.equip_cell_list = {}		--装备下的ItemCell的list
	self.consume_cell_list = {}		--消耗品下的ItemCell的list
	self.attribute_cell_list = {}	--属性值下的AttributeCell的list
	self.show_line_list = {}		--显示线条的list

	self.last_model_index = -1 		--上一个模型的索引
	self.last_show_line_index = 1   --上一条line的索引

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtCount"])

	self:InitSymbolModel()
	self:SetShowJiHuo(true)

	for i = 1, SHEN_EQUIP_NUM do
		self.equip_cell_list[i] = ItemCell.New()
		self.equip_cell_list[i]:SetInstanceParent(self.node_list["EquipItem_" .. i])
		self.equip_cell_list[i]:SetToggleGroup(self.node_list["EquipToggleGroup"].toggle_group)
		self.equip_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickEquipItem,self, i))
		self.equip_cell_list[i]:SetInteractable(true)
		self.show_line_list[i] = self.node_list["ShowLine_" .. i]
	end

	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickJinjie, self))
	self.node_list["BtnAuto"].button:AddClickListener(BindTool.Bind(self.OnClickYiJian, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function SymbolFuzhouView:__delete()
	for i,v in ipairs(self.equip_cell_list) do
		v:DeleteMe()
	end
	self.equip_cell_list = {}

	for i,v in ipairs(self.consume_cell_list) do
		v:DeleteMe()
	end
	self.consume_cell_list = {}

	for i,v in ipairs(self.attribute_cell_list) do
		v:DeleteMe()
	end
	self.attribute_cell_list = {}

	if self.symbol_model then
		self.symbol_model:DeleteMe()
		self.symbol_model = nil
	end

	--清理对象和变量
	self.last_model_index = -1
	self.cur_wuxing_type = 0
	self.attribute_list_data = {}
	self.consume_list_data = {}
	self.wuxing_jihuo_list = {}
	self.shenzhuang_list = {}
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function SymbolFuzhouView:InitAttributeListView()
	local attribute_list_delegate = self.node_list["AttributeListView"].list_simple_delegate
	local wuxing_type = SymbolData.Instance:GetEquipByWuxing(self.cur_equip_index)
	if self.attribute_list_data[self.cur_equip_index] == nil then
		self.attribute_list_data[self.cur_equip_index] = {}
	end
	attribute_list_delegate.NumberOfCellsDel = function ( )
		return #self.attribute_list_data[self.cur_equip_index]
	end

	attribute_list_delegate.CellRefreshDel = function(cell_obj, index)
		index = index + 1
		local cell = self.attribute_cell_list[cell_obj]
		if nil == cell then
			cell = AttributeCell.New(cell_obj.gameObject)
			self.attribute_cell_list[cell_obj] = cell
		end
		cell:SetData(self.attribute_list_data[self.cur_equip_index][index])
	end
end

function SymbolFuzhouView:InitConsumeListView()
	self.consume_list_data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type)			--消耗品的数据
	local consume_list_delegate = self.node_list["ConsumeToggleGroup"].list_simple_delegate
	consume_list_delegate.NumberOfCellsDel = function()
		return #self.consume_list_data
	end

	consume_list_delegate.CellRefreshDel = function(cell_obj,index)
		self.consume_list_data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type)			--消耗品的数据
		index = index + 1
		local cell = self.consume_cell_list[cell_obj]
		if nil == cell then		--在判断是否为nil外设置数据，否则数据会错误引用
			cell = ConsumeCell.New(cell_obj.gameObject)
			self.consume_cell_list[cell_obj] = cell
		end
		cell:SetData(self.consume_list_data[index])
		cell:SetClickCallBack(BindTool.Bind(self.OnClickConsumeItem, self, index, cell))
		cell:SetToggleGroup(self.node_list["ConsumeToggleGroup"].toggle_group)

		cell:GetToggle().isOn = self.cur_consume_select == index or false
	end
end

function SymbolFuzhouView:OpenCallBack()
	self.shenzhuang_list = ForgeData.Instance:GetZhuanzhiEquipAll()
	local data = SymbolData.Instance:GetElementList()
	if nil == data then return end

	local right_pos = self.node_list["RightPanel"].transform.anchoredPosition
	local up_pos = self.node_list["BtnHelp"].transform.anchoredPosition
	local under_pos = self.node_list["NodeUpMove"].transform.anchoredPosition
	local under_power_pos = self.node_list["NodeZhanLiFrame"].transform.anchoredPosition
	local up_name_pos = self.node_list["ImgName"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["ImgName"], Vector3(up_name_pos.x, up_name_pos.y + 200, up_name_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeZhanLiFrame"], Vector3(under_power_pos.x, under_power_pos.y - 100, under_power_pos.z))
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(up_pos.x, up_pos.y + 200, up_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeUpMove"], Vector3(under_pos.x, under_pos.y - 100, under_pos.z))
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(right_pos.x + 600, right_pos.y, right_pos.z))

	local jihuo_wuxing = 0
	self.add_percent = 0
	local wuxing_list = {}

	for k,v in pairs(data) do
		wuxing_list[k+1] = {wuxing_type = v.wuxing_type, is_jihuo = v.grade >= 1 or false}
		if v.grade >=1 then
			jihuo_wuxing = v.wuxing_type
			--进阶的百分比加成
			self.add_percent = self.add_percent + (SymbolData.Instance:GetElementHeartCfgByGrade(v.grade).add_texture_percent_attr / 10000)
		end
	end

	self.wuxing_jihuo_list = ListToMapList(wuxing_list, "wuxing_type")
	--判断默认选择符合条件的第一个
	self.node_list["TxtLeftPanel"].text.text = Language.Symbol.NotDress
	self.node_list["TxtShowJiHuo"].text.text = Language.Symbol.NotDress
	self:SetShowJiHuo(true)

	for k,v in pairs(SymbolData.Instance:GetElementTextureInfoList()) do
		if v.grade > 0 and self.shenzhuang_list[k].item_id > 0 then
			self:OnClickEquipItem(k + 1)
			if self.one_youxian_show then
				break
			end
		end
	end

	self:InitAttributeListView()
	self:InitConsumeListView()

	self:Flush()
end

function SymbolFuzhouView:CloseCallBack()
	self:CancelTheQuest()
	self.one_youxian_show = false
	self.two_youxian_show = false
end

function SymbolFuzhouView:OnFlush()
	self:LeftFlush()
	self:RightFlush()
end

--左边面板刷新
function SymbolFuzhouView:LeftFlush()
	local all_zhanli = 0
	local equiplist = ForgeData.Instance:GetZhuanzhiEquipAll()
	for i = 1, SHEN_EQUIP_NUM do
		local index = i - 1
		if self.equip_cell_list[i] then
			--根据大天使装备赋值或上锁
			local equip_info = SymbolData.Instance:GetElementTextureInfo(index)
			local wuxing_type = SymbolData.Instance:GetEquipByWuxing(index)
			if nil == equip_info then return end

			if equiplist[index] and equiplist[index].item_id > 0 then
				self.equip_cell_list[i]:SetAsset(ResPath.GetItemIcon(equiplist[index].item_id))
			else
				local item_id = EquipData.Instance:GetZhuanzhiDefaultIcon(index)
				self.equip_cell_list[i]:SetAsset(ResPath.GetItemIcon(item_id))
			end
			self.equip_cell_list[i]:SetIconGrayScale(true)
			self.equip_cell_list[i]:ShowQuality(false)
			self.node_list["ImgNameBg" .. i]:SetActive(self.shenzhuang_list[i-1].item_id > 0)
			if self.shenzhuang_list[i-1].item_id > 0 then
				self.equip_cell_list[i]:SetIconGrayScale(false)
				local grade = equip_info.grade
				local max_level = EquipmentShenData.Instance:GetMaxShenzhuangCfgLevel()
				if equip_info.grade > max_level then
					grade = max_level
				end
				local color = EquipmentShenData.Instance:GetShenzhuangCfg(index, grade).color
				local bundle, asset = ResPath.GetSymbolImage("levelbg_" .. color)
				self.node_list["ImgNameBg" .. i].image:LoadSprite(bundle, asset, function()
						self.node_list["ImgNameBg" .. i].image:SetNativeSize()
					end)
				bundle, asset = ResPath.GetImages("icon_star_big" .. color)
				self.node_list["ImgStar" .. i].image:LoadSprite(bundle, asset, function()
						self.node_list["ImgStar" .. i].image:SetNativeSize()
					end)
				self.node_list["TxtName" .. i].text.text = equip_info.grade - 1
				self.equip_cell_list[i]:SetQualityByColor(color > 0 and color or 1)
				self.equip_cell_list[i]:ShowQuality(color > 0)
				if self.wuxing_jihuo_list[wuxing_type] ~= nil and self.wuxing_jihuo_list[wuxing_type][1].is_jihuo then
					local cfg = SymbolData.Instance:GetElementTextureLevel(wuxing_type, equip_info.grade)
					local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
					local capability = CommonDataManager.GetCapabilityCalculation(attr)
					all_zhanli = all_zhanli + (capability * (1 + self.add_percent))
				end
			end
		end
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = math.ceil(all_zhanli)
	end
	self:UpdataEquiptRedmin()
end

--右边面板刷新
function SymbolFuzhouView:RightFlush()
	--if not self.show_jihuo then return end
	
	self.equip_cell_list[self.cur_equip_index]:SetHighLight(true)
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	local wuxing_type = SymbolData.Instance:GetEquipByWuxing(self.cur_equip_index - 1)
	--未激活时为0读不到配置，1为了读配置显示名字
	if info.grade == 0 then
		info.grade = 1
	end
	--当前的属性
	local cur_cfg = SymbolData.Instance:GetElementTextureLevel(wuxing_type, info.grade)
	if nil == cur_cfg then return end
	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)

	--下一级的属性
	local next_cfg = SymbolData.Instance:GetElementTextureLevel(wuxing_type, info.grade + 1)
	local next_attr = CommonDataManager.GetAttributteNoUnderline(next_cfg)

	self.attribute_list_data[self.cur_equip_index] = {}
	local attr = {}
	if info.grade >= SymbolData.Instance:GetElementTextureMaxLevel() then
		attr = cur_attr
	else
		attr = next_attr
	end

	for k,v in pairs(attr) do
		if v > 0  then
			local attr = {} 		--有效的属性
			attr.cur_attr = cur_attr[k]
			attr.next_attr = next_attr[k]
			attr.attr_name = k
			table.insert(self.attribute_list_data[self.cur_equip_index], attr)
		end
	end

	--判断等级是否为最高等级
	if info.grade >= SymbolData.Instance:GetElementTextureMaxLevel() then
		self.node_list["ImgProgressBG"].slider.value = 1
		self.node_list["TxtProgressBG"].text.text = Language.Common.YiMan
	else
		self.node_list["ImgProgressBG"].slider.value = (info.exp / cur_cfg.exp_limit)
		self.node_list["TxtProgressBG"].text.text = (info.exp .. "/" .. cur_cfg.exp_limit)
	end

	self.node_list["TxtName"].text.text = Language.Symbol.ElementsName[wuxing_type]
	local name = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_equip_index - 1, 1).name
	self.node_list["TxtEquipName"].text.text = Language.Symbol.LvTxt .. (info.grade - 1) .. " " .. name

	local capability = CommonDataManager.GetCapabilityCalculation(cur_attr)
	capability = capability * (1 + self.add_percent)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = capability and math.ceil(capability) or 0
	end

	self:SetAutoButtonGray()

	if self.show_jihuo then
		self.node_list["AttributeListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.node_list["ConsumeToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
end

--初始化模型
function SymbolFuzhouView:InitSymbolModel()
	if not self.symbol_model then
		self.symbol_model = RoleModel.New()
		self.symbol_model:SetDisplay(self.node_list["CenterDisplay"].ui3d_display)
	end
end

--设置模型数据
function SymbolFuzhouView:SetSymbolModelData(index)
	if self.last_model_index == index then return end
	self.last_model_index = index
	local bubble, asset = ResPath.GetSpiritModel(SymbolData.ELEMENT_MODEL[index])
	self.symbol_model:SetMainAsset(bubble,asset)
	self.symbol_model:SetScale(Vector3(1.7, 1.7, 1.7))
end

--点击装备
function SymbolFuzhouView:OnClickEquipItem(index)
	self.one_youxian_show = false
	self.two_youxian_show = false
	self:CancelTheQuest()			--取消自动进阶
	self.cur_consume_select = 1
	--切换装备刷新右边面板
	local wuxing_type = SymbolData.Instance:GetEquipByWuxing(index - 1)
	self.cur_wuxing_type = wuxing_type
	self.cur_equip_index = index
	self.show_line_list[self.last_show_line_index]:SetActive(false)
	if self.wuxing_jihuo_list[wuxing_type] ~= nil then
		for k,v in pairs(self.wuxing_jihuo_list[wuxing_type]) do
			if v.wuxing_type == wuxing_type and v.is_jihuo and self.shenzhuang_list[index - 1].item_id > 0 then
				--1.大天使装备激活 对应的元素之心也激活
				self.one_youxian_show = true
				self.is_can_jinjie = true
				self.cur_equip_index = index
				self:SetSymbolModelData(wuxing_type)
				self.last_show_line_index = index
				self.show_line_list[index]:SetActive(true)
				self.node_list["TxtLeftPanel"].text.text = ""
				self.node_list["TxtShowJiHuo"].text.text = ""
				self:SetShowJiHuo(false)
				self:Flush()
				return
			end
		end
	end

	--3. 大天使装备激活  对应的元素之心未激活
	if self.shenzhuang_list[index - 1].item_id > 0 and not self.one_youxian_show then
		self.two_youxian_show = true
		self.is_can_jinjie = false
		self.node_list["TxtLeftPanel"].text.text = string.format(Language.Symbol.NotEnable,Language.Symbol.ElementsName[wuxing_type])
		self.node_list["TxtShowJiHuo"].text.text = string.format(Language.Symbol.NotEnable,Language.Symbol.ElementsName[wuxing_type])
		self:SetShowJiHuo(true)
		self:Flush()
		return
	end

	--4. 大天使装备未激活  对应的元素之心未激活
	if self.shenzhuang_list[index-1].item_id <= 0 and not self.one_youxian_show and not self.two_youxian_show then
		self.node_list["TxtLeftPanel"].text.text =  Language.Symbol.NotDress
		self.node_list["TxtShowJiHuo"].text.text =  Language.Symbol.NotDress
		self:SetShowJiHuo(true)
		self.is_can_jinjie = false
		self:Flush()
		return
	end
end

--点击消耗品
function SymbolFuzhouView:OnClickConsumeItem(index, cell)
	self.cur_consume_select = index
end

--点击进阶
function SymbolFuzhouView:OnClickJinjie()
	if self.cur_consume_select ~= 0 then
		self:SendJinjie()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.SelectGoods)
	end
	self:Flush()
end

function SymbolFuzhouView:SendJinjie()
	local item_id = self.consume_list_data[self.cur_consume_select].item_id
	self:SendUpgradeCharmReq(item_id)
end

function SymbolFuzhouView:SendAllJinjie()
	local data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type)
	local item_id = self.consume_list_data[self.cur_consume_select].item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	if num <= 0 then
		for k,v in pairs(data) do
			num = ItemData.Instance:GetItemNumInBagById(v.item_id)
			item_id = v.item_id
			self.cur_consume_select = 1
			if num > 0 then break end
		end
	end
	self:SendUpgradeCharmReq(item_id)
end

function SymbolFuzhouView:SendUpgradeCharmReq(item_id)
	local index = ItemData.Instance:GetItemIndex(item_id)
	local num = ItemData.Instance:GetItemNumInBagById(item_id)

	if num <=0 then
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

		local func = function(item_id2,item_num,is_bind,is_use,is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
	SymbolCtrl.Instance:SendUpgradeCharmReq(self.cur_equip_index - 1, index)
end

--自动进阶
function SymbolFuzhouView:OnClickYiJian()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	if info.grade == 0 then
		return
	end
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_auto = not self.is_auto
		self.is_can_auto = false
		self:AutoUpGradeOnce()
		self:SetAutoButtonGray()
	end

	ok_callback()

	self:Flush()
end

function SymbolFuzhouView:SetAutoButtonGray()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
	UI:SetButtonEnabled(self.node_list["BtnAuto"], false)
	if not info then return end

	local max_grade = SymbolData.Instance:GetElementTextureMaxLevel()
	if info.grade <= 0 or info.grade >= max_grade or not self.is_can_jinjie
		or self.shenzhuang_list[self.cur_equip_index - 1].item_id <= 0 then
		self.node_list["TxtOnButton"].text.text = Language.Common.AutoUpgrade
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		UI:SetButtonEnabled(self.node_list["BtnAuto"], false)
		return
	end
	if self.is_auto then
		self.node_list["TxtOnButton"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		UI:SetButtonEnabled(self.node_list["BtnAuto"], true)
	else
		self.node_list["TxtOnButton"].text.text = Language.Common.AutoUpgrade
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		UI:SetButtonEnabled(self.node_list["BtnAuto"], true)
	end
end

--时间监听 自动进阶一次
function SymbolFuzhouView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SendAllJinjie, self), jinjie_next_time)
	end
end

function SymbolFuzhouView:CancelTheQuest()
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.node_list["TxtOnButton"].text.text = Language.Common.ZiDongJinJie
end

--服务端 升级返回结果
function SymbolFuzhouView:ElementTextureUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

--更新装备上的红点
function SymbolFuzhouView:UpdataEquiptRedmin()
	for k,v in pairs(self.equip_cell_list) do
		v:SetRedPoint(false)
		local wuxing_type = SymbolData.Instance:GetEquipByWuxing(k-1)
		local num = 0
		for k1,v1 in pairs(SymbolData.Instance:GetYSStuffCfg(wuxing_type)) do
			num = num + ItemData.Instance:GetItemNumInBagById(v1.item_id)
			if num > 0 then break end
		end

		local info_grade = SymbolData.Instance:GetElementTextureInfo(k - 1).grade
		if self.wuxing_jihuo_list[wuxing_type] ~= nil then
			for k1,v1 in pairs(self.wuxing_jihuo_list[wuxing_type]) do
				if num > 0 and v1.wuxing_type == wuxing_type and v1.is_jihuo
					and self.shenzhuang_list[k - 1].item_id > 0 and info_grade < SymbolData.Instance:GetElementTextureMaxLevel() then
					v:SetRedPoint(true)
				end
			end
		end
	end
end

function SymbolFuzhouView:OnClickHelp()
	local tip_id = 247
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 设置物体显示隐藏
function SymbolFuzhouView:SetShowJiHuo(not_jihuo)
	local show_jihuo = not not_jihuo

	self.show_jihuo = show_jihuo
	self.node_list["CenterDisplay"]:SetActive(show_jihuo)
	self.node_list["ImgName"]:SetActive(show_jihuo)
	self.node_list["ImgtextBG"]:SetActive(show_jihuo)
	self.node_list["TxtBG"]:SetActive(show_jihuo)
	self.node_list["NodeZhanLiFrame"]:SetActive(show_jihuo)
	self.node_list["FightPower"]:SetActive(show_jihuo)
	self.node_list["AttributeListView"]:SetActive(show_jihuo)

	self.node_list["NotEnable"]:SetActive(not show_jihuo)
	self.node_list["TxtLeftPanel"]:SetActive(not show_jihuo)
	self.node_list["ImgShowJiHuo"]:SetActive(not show_jihuo)
end

----------------------属性的Item格子-----------------------------------
AttributeCell = AttributeCell or BaseClass(BaseCell)

function AttributeCell:__init()

end

function AttributeCell:__delete()

end

function AttributeCell:OnFlush()
	if nil == self.data then return end
	if self.data.next_attr > 0 then
		self.node_list["TxtAttrAdd"].text.text = self.data.next_attr - self.data.cur_attr
		self.node_list["ImgArrow"]:SetActive(true)
		self.node_list["TxtAttrAdd"]:SetActive(true)
		self.node_list["TxtAttr"].transform.anchoredPosition = Vector3(-68, 0, 0)
	else
		self.node_list["ImgArrow"]:SetActive(false)
		self.node_list["TxtAttrAdd"]:SetActive(false)
		self.node_list["TxtAttr"].transform.anchoredPosition = Vector3(0, 0, 0)
	end
	local name = ToColorStr(Language.Common.AttrNameUnderline[self.data.attr_name] .. "：", "#d0d8ff")
	self.node_list["TxtAttr"].text.text = name .. self.data.cur_attr
end

-----------------------消耗品格子-------------------------------------
ConsumeCell = ConsumeCell or BaseClass(BaseCell)

function ConsumeCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.root_node)
end

function ConsumeCell:__delete()
	self.item_cell:DeleteMe()
end

function ConsumeCell:SetData(data)
	self.data = data
	self:Flush()
end

function ConsumeCell:SetItemNum(str)
	self.item_cell:SetItemNum(str)
end

function ConsumeCell:SetToggleGroup(toggle_group)
	self.item_cell:SetToggleGroup(toggle_group)
end

function ConsumeCell:GetToggle()
	return self.item_cell.root_node.toggle
end

function ConsumeCell:SetClickCallBack(callback)
	self.item_cell:ListenClick(callback)
end

function ConsumeCell:OnFlush()
	local cell_data = {}
	cell_data.item_id = self.data.item_id
	cell_data.num = ItemData.Instance:GetItemNumInBagById(cell_data.item_id)
	self.item_cell:SetData(cell_data)

	if cell_data.num == 0 or cell_data.num == nil then
		self.item_cell:SetIconGrayScale(true)
		self.item_cell:ShowQuality(false)
	else
		self.item_cell:SetIconGrayScale(false)
		self.item_cell:ShowQuality(true)
	end
end