require("game/player/shengyin/player_shenghun_view")
--require("game/player/shengyin/player_shengyin_tipview")
require("game/player/shengyin/player_shengyin_suit_view")
require("game/player/shengyin/player_shengyin_totle_attr")
require("game/player/shengyin/shengyin_fenjie_view")
require("game/player/shengyin/shengyin_qianghua_view")
require("game/player/shengyin/shengyin_equip_view")

ShengYinView = ShengYinView or BaseClass(BaseRender)
-- 圣印功能(合G21代码)
-- 常亮定义
local BAG_MAX_GRID_NUM = 336			-- 最大格子数
local BAG_PAGE_NUM = 14					-- 页数
local BAG_PAGE_COUNT = 24				-- 每页个数
local BAG_ROW = 6						-- 行数
local BAG_COLUMN = 4					-- 列数
local ITEM_CELL_NUM = 9				    -- 镶嵌栏格子数量(从0开始)

local POSQH = {-57, 17, 0}				-- 强化值位置
local POSRED = {-20, -12, 0}			-- 红点位置
local LASTPOSQH = {-73, 17, 0}			-- 最后一个强化位置
local LASTPOSRED = {-20, -22, 0}		-- 最后一个红点位置
local STRENGTHSIZE = Vector2(48, 35)	-- 强化文本框大小
local STRENGTHFONTSIZE = 25 			-- 强化字体大小
local EFFECTSIZE = Vector3(0.7, 0.7, 1)	-- 特效大小
local LASTEFFECTSIZE = Vector3(0.9, 0.9, 1)		-- 最后一个特效大小
local COLORNUM = 3  					-- 不显示特效的最高颜色索引

function ShengYinView:__init()
	-- 背包格子数据
	self.grid_list = nil
end

function ShengYinView:LoadCallBack()
	-- 背包格子数据
	self.grid_list = nil
	-- 圣印列表
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.bag_cell = {}
	-- 圣印格子位置
	self.shengyin_equip_list = {}
	self.gray_icon_list = {}
	self.mask_component = {}

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ScoreValue"])
	for i = 0, ITEM_CELL_NUM do
		-- self.shengyin_equip_list[i] = ShengYinSlotItemRender.New(self.node_list["Point" .. i + 1])
		-- self.mask_component[i] = self.node_list["Point" .. i + 1].gameObject:GetComponent(typeof(CircleImage))
		self.shengyin_equip_list[i] = ItemCell.New()
		self.shengyin_equip_list[i]:SetBackground(false)
		self.shengyin_equip_list[i]:ShowHighLight(false)
		-- self.shengyin_equip_list[i]:ShowQuality(false)
		-- self.shengyin_equip_list[i].shengyin_item_cell.root_node.rect.sizeDelta = Vector2(100, 100)
		self.shengyin_equip_list[i].root_node.rect.sizeDelta = Vector2(105, 105)
		if i == ITEM_CELL_NUM then
			-- self.shengyin_equip_list[i].shengyin_item_cell.root_node.rect.sizeDelta = Vector2(130, 130)
			self.shengyin_equip_list[i].root_node.rect.sizeDelta = Vector2(140, 140)
		end
		self.shengyin_equip_list[i]:SetInstanceParent(self.node_list["Item" .. i + 1 ])
		self.gray_icon_list[i] = self.node_list["Point" .. i + 1 ].transform:FindHard("IconImg") 
		-- self.gray_icon_list[i].gameObject:GetComponent(typeof(UnityEngine.UI.Button)):AddClickListener(BindTool.Bind(self.OnClickShengYinEquip, self, i + 1))
		UI:SetGraphicGrey(self.gray_icon_list[i], true)
	end

	-- 注册点击事件
	self:RegisterButtonEvent()							
	self:Flush()
	self.shenghun = ShengYinShengHun.New(ViewName.ShengHunView)
	self.shengyin_attr = ShengYinAttrTip.New()
	self.shengyin_fenjie = ShengYinReSolve.New()
	self.shengyin_qianghua = ShengYinStrength.New()
	self.shengyin_suit_see = ShengYinSuitView.New()
	self.shengyin_equip = ShengYinEquip.New(ViewName.ShengYinEquip)
end

function ShengYinView:__delete()
	----------------------------------------------------
	-- 圣印背包格子
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	-- 圣印装备
	for _, v in pairs(self.shengyin_equip_list) do
		v:DeleteMe()
	end
	self.shengyin_equip_list = {}
	self.gray_icon_list = {}
	-- 圣魂界面
	if self.shenghun then 
		self.shenghun:DeleteMe()
		self.shenghun = nil
	end
	-- 套装预览界面
	if self.shengyin_suit_see then 
		self.shengyin_suit_see:DeleteMe()
		self.shengyin_suit_see = nil
	end
	-- 圣印属性界面
	if self.shengyin_attr then 
		self.shengyin_attr:DeleteMe()
		self.shengyin_attr = nil
	end
	-- 圣印分解界面
	if self.shengyin_fenjie then 
		self.shengyin_fenjie:DeleteMe()
		self.shengyin_fenjie = nil
	end
	-- 圣印强化界面
	if self.shengyin_qianghua then 
		self.shengyin_qianghua:DeleteMe()
		self.shengyin_qianghua = nil
	end
	-- 装备圣印界面
	if self.shengyin_equip then
		self.shengyin_equip:DeleteMe()
		self.shengyin_equip = nil
	end
	-- 背包格子数据
	self.grid_list = nil
	self.mask_component = {}
	----------------------------------------------------
	self.fight_text = nil
end

-- 不继承,playerview界面第一次生成时调用，刷新背包
function ShengYinView:OpenCallBack()
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	RemindManager.Instance:Fire(RemindName.PlayerShengYin)
	self:FlushShengYinView()	
end

function ShengYinView:PlayTween()
	local under_pos = self.node_list["Down"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["Down"], Vector3(under_pos.x, under_pos.y - 214, under_pos.z))
	local right_pos = self.node_list["Right"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["Right"], Vector3(right_pos.x + 500, right_pos.y, right_pos.z))
	local up_btn_pos = self.node_list["UP"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["UP"], Vector3(up_btn_pos.x, up_btn_pos.y + 250, up_btn_pos.z))
	-- local up_score_pos = self.node_list["Score"].transform.anchoredPosition
	-- UITween.MoveShowPanel(self.node_list["Score"], Vector3(up_score_pos.x, up_score_pos.y + 250, up_score_pos.z))
	-- local left_scale = 0.7
	UITween.ScaleShowPanel(self.node_list["Left"], Vector3(0.7, 0.7, 0.7))
	UITween.AlpahShowPanel(self.node_list["Left"], true)
end

function ShengYinView:OnFlush()
	self:FlushBagView()
	self:FlushShengYinView()
	self:FlushChildView()

	-- self.node_list["ListView"].list_view:Reload()
end

-- 刷新子界面(后期优化，把不需要的刷新去掉)
function ShengYinView:FlushChildView()

	if self.shenghun:IsOpen() then 
		self.shenghun:Flush()
	elseif self.shengyin_fenjie:IsOpen() then 
		self.shengyin_fenjie:Flush()
	elseif self.shengyin_qianghua:IsOpen() then 
		self.shengyin_qianghua:Flush()
	elseif self.shengyin_attr:IsOpen() then 
		self.shengyin_attr:Flush()
	end

end
-- 点击装备，弹出面板
function ShengYinView:OnClickEquipOn(data)
	if data.item_id then 
		self.shengyin_equip:SetSlotIndex(data.slot_index)
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGYIN_EXCHANGE, nil)
	end
end
-- 刷新圣印的面板评分
function ShengYinView:FlushShengYinView()
	local sealslot_grid_list = PlayerData.Instance:GetSealSlotItemList()
	if sealslot_grid_list ~= nil then
		local has_cacul_suit = {}
		local enable_point_count = PlayerData.Instance:GetShenYinEnablePoints()
		local remind_list = PlayerData.Instance:GetSealEquipRemind()
		
		for k, v in pairs(self.shengyin_equip_list) do
			local data_item = sealslot_grid_list[k] or {}
			v:SetData(data_item)
			if data_item ~= {} and data_item.item_id ~= 0 and data_item.slot_index ~= -1 then 
				v:SetShengYinEffect(data_item.color > COLORNUM, data_item.color - COLORNUM, k == ITEM_CELL_NUM and LASTEFFECTSIZE or EFFECTSIZE)
				self.gray_icon_list[k].gameObject:SetActive(false)
				self.node_list["Point" .. k + 1].image.enabled = true
				v:ListenClick(BindTool.Bind(self.OnClickEquipOn, self, data_item))
				-- v:SetShengYinGrade(data_item.order)
				if data_item.level > 0 then
					self.node_list["StrengTxt" .. k].text.text = "+" .. data_item.level
					self.node_list["Streng" .. k]:SetActive(true)
					-- v:SetStrength()
					-- v:ShowStrengthLable(true, k == ITEM_CELL_NUM and LASTPOSQH or POSQH, STRENGTHSIZE, STRENGTHFONTSIZE)
				else
					self.node_list["Streng" .. k]:SetActive(false)
					-- v:ShowStrengthLable(false)
				end 
			else
				self.gray_icon_list[k].gameObject:SetActive(true)
				self.node_list["Point" .. k + 1].image.enabled = false
				v:ListenClick(BindTool.Bind(self.OnClickShengYinEquip, self, k + 1))
			end

			if k > (enable_point_count - 1) then
				self.node_list["Point" .. k + 1].image.enabled = false
				v:ListenClick(BindTool.Bind(self.OnClickEquipOn, self, data_item))
				self.gray_icon_list[k].gameObject:SetActive(false)
				v:SetShengYinLock(true)
			end
			if remind_list and remind_list[k] then
				v:SetRedPoint(remind_list[k], k == ITEM_CELL_NUM and LASTPOSRED or POSRED)
			end
			
		end
		-- 圣印评分
		local scord = 0
		local suit_scord = 0
		local per_suit_scord = 0
		local totle_attr_list = {}
		local totle_all_attr_list = CommonStruct.Attribute()
		for i,v in pairs(sealslot_grid_list) do
			if v.item_id ~= 0  then 
				local item_data = PlayerData.Instance:GetSealAttrData(v.slot_index, v.order)
				if item_data and next(item_data) then
					local attribute = CommonDataManager.GetAttributteByClass(item_data)

					local attr_add_list = PlayerData.Instance:GetSoulAttrValueBySlotIndex(v.slot_index)
					local attr_add_has_line = CommonDataManager.GetAttributteByClass(attr_add_list)
					attr_add_has_line = CommonDataManager.MulAttribute(attr_add_has_line, v.level)
					local attr_list = CommonDataManager.AddAttributeAttr(attribute, attr_add_has_line)
					if next(totle_attr_list) then 
						totle_attr_list = CommonDataManager.AddAttributeAttr(totle_attr_list, attr_list)
					else
						totle_attr_list = attr_list
					end

					local cacul = true
					local suit_data = PlayerData.Instance:GetItemByOrderAndPart(v.order,v.slot_index)
					if suit_data ~= nil then
						for k, v in pairs(has_cacul_suit) do
							if v == suit_data.suit_type then
								cacul = false
							end
						end
						if cacul then
							table.insert(has_cacul_suit, suit_data.suit_type) 
							local item_count = PlayerData.Instance:GetFinshSuitCountBySuitType(suit_data.suit_type)

							local suit_attr_list = PlayerData.Instance:GetSuitDataByItemSuitType(suit_data.suit_type)
							for k, v in pairs(suit_attr_list) do
								if item_count >= v.same_order_num then 
									local attr_line = CommonDataManager.GetAttributteByClass(v)
									totle_attr_list = CommonDataManager.AddAttributeAttr(totle_attr_list, attr_line)
									local per_attr_list = CommonDataManager.GetRolePercentAttr(v)
									totle_all_attr_list = CommonDataManager.AddAttributeAttr(totle_all_attr_list, attr_line)
									totle_all_attr_list = CommonDataManager.AddAttributeAttr(totle_all_attr_list, per_attr_list)
									suit_scord = CommonDataManager.GetCapabilityCalculation(per_attr_list)
									per_suit_scord = per_suit_scord + suit_scord
								end
							end
						end
					end
					--attribute = CommonDataManager.MulAttribute(attribute, v.level + 1)
				end
			end
		end
		scord = CommonDataManager.GetCapabilityCalculation(totle_attr_list)
		local all_suit_scord = CommonDataManager.GetCapability(totle_all_attr_list) + per_suit_scord
		--total_scord = total_scord + scord
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = scord
		end
		self.node_list["SuperPowerTxt"].text.text = string.format(Language.Common.GaoZhanLi, all_suit_scord)
		self.node_list["SuitCapBg"]:SetActive(all_suit_scord > 0)
		self.node_list["SuperPowerImg"]:SetActive(all_suit_scord <= 0)
	end
	-- 红点提醒
	local is_remind_soul = PlayerData.Instance:GetSealSoulRemind()
	self.node_list["RemindSH"]:SetActive(is_remind_soul > 0)

	local is_remind_strength = PlayerData.Instance:GetSealStrengthRemind()
	self.node_list["RemindQH"]:SetActive(is_remind_strength > 0)	

	local is_remind_fenjie = PlayerData.Instance:GetSealFenJieRemind()
	if is_remind_fenjie then
		self.node_list["FenJieRemind"]:SetActive(is_remind_fenjie > 0)
	end
end

-- function ShengYinView:FlushCellLock()
-- 	-- 只在某一两个固定等级提升的瞬间且处于圣印界面时才进行该循环,所以没必要使用
-- 	local enable_point_count = self:GetEnablePoints()
-- 	for i = 0, enable_point_count do
-- 		self.shengyin_equip_list[i]:SetLockImg(false)
-- 	end
-- end

--点击提示
function ShengYinView:OnClickTip()
	local tips_id = 275
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--点击圣魂
function ShengYinView:OnClickShengHun()
	ViewManager.Instance:Open(ViewName.ShengHunView)
end

--点击总属性
function ShengYinView:OnClickTotalAttr()
	PlayerData.Instance:SetSelectAttrView(1)
	self.shengyin_attr:Open()
end

--点击属性加成
function ShengYinView:OnClickAttrAdd()
	PlayerData.Instance:SetSelectAttrView(2)
	self.shengyin_attr:Open()
end

--点击套装预览
function ShengYinView:OnClickSuitPreview()
	self.shengyin_suit_see:Open()
end

--点击一键分解
function ShengYinView:OnClickOneKeyResoly()
	self.shengyin_fenjie:Open()
end

--点击圣印强化
function ShengYinView:OnClickShengYinStrength()
	self.shengyin_qianghua:OpenQiangHua()
	--self.shengyin_qianghua:Open()
end

-- 点击圣印镶嵌栏图标装备圣印
function ShengYinView:OnClickShengYinEquip(slot_index)
	if self.grid_list then
		for k, v in pairs(self.grid_list) do
			if v.slot_index == slot_index then
				self.shengyin_equip:SetSlotIndex(slot_index)
				return self.shengyin_equip:Open()
			end
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Player.ShengYinError)
	-- ViewManager.Instance:Open(ViewName.LingKunBattleDetailView)
end

function ShengYinView:FlushBagView()
	self.grid_list = PlayerData.Instance:GetSealBagItemList()
	self.node_list["ListView"].list_view:Reload()
end

-- 背包数量
function ShengYinView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

-- 刷新格子数据
function ShengYinView:BagRefreshCell(index, cellObj)

	-- 获取数据
	local grid_list = nil
	if not self.grid_list then 
		self.grid_list = PlayerData.Instance:GetSealBagItemList()
	end
	grid_list = self.grid_list
	grid_list = grid_list or{}
	--local cell_data = {} 
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.bag_cell.toggle_group)
		cell:SetItemNumVisible(false)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_PAGE_COUNT
	local guid_info = grid_list[grid_index + 1] or {}
	cell:SetData(guid_info, true)
	cell:SetIndex(grid_index + 1)
	cell:ShowHighLight(false)
	if guid_info.show_arrow and guid_info.show_arrow > 0 then
		cell:SetShowUpArrow(true)
	else
		cell:SetShowUpArrow(false)
	end
	-- if nil ~= guid_info.order and guid_info.order ~= 0 then
	-- 	cell:SetShengYinGrade(guid_info.order)
	-- end
	cell:SetHighLight(self.cur_index == guid_info.bag_index and nil ~= guid_info.item_id)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, guid_info, cell))
	--cell:SetInteractable((nil ~= grid_list[grid_index].item_id))
end

--点击格子事件
function ShengYinView:HandleBagOnClick(data, cell, is_click)
	if not is_click then return end
	local sealslot_grid_list = PlayerData.Instance:GetSealSlotItemList()
	cell:SetHighLight(true)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end 
	self.cur_index = data.bag_index or -1
	data.index = self.cur_index
	cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		PlayerData.Instance:SetShengYinBagIndex(self.cur_index)
		-- TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)	
		if PlayerData.Instance:IsShengYinJingHua(item_cfg1.id) then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENYIN_JINGHUA, nil, close_callback)	
		else
			local sealslot_data = sealslot_grid_list[data.slot_index - 1]
			if sealslot_data.item_id ~= nil and sealslot_data.item_id ~= 0 then
				TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGYIN_COMPARE, sealslot_data, close_callback)	
			else
				TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGYIN, nil, close_callback)	
			end		
		end
	end
end
--注册按钮事件
function ShengYinView:RegisterButtonEvent()
	self.node_list["BtnSuitSee"].button:AddClickListener(BindTool.Bind(self.OnClickSuitPreview, self))
	self.node_list["BtnSuitStrengthen"].button:AddClickListener(BindTool.Bind(self.OnClickShengYinStrength, self))
	self.node_list["BtnSuitDecompose"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyResoly, self))
	self.node_list["BtnSuitAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAttrAdd, self))           -- 属性加成
	self.node_list["BtnSuitAttrAll"].button:AddClickListener(BindTool.Bind(self.OnClickTotalAttr, self))
	self.node_list["BtnSuitSoul"].button:AddClickListener(BindTool.Bind(self.OnClickShengHun, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))
end

--圣印已装备的格子
-- ShengYinSlotItemRender = ShengYinSlotItemRender or BaseClass(BaseRender)

-- function ShengYinSlotItemRender:__init()
-- 	-- if ItemCell.New() == nil then
-- 	-- 	print("nil")
-- 	-- else
-- 	-- 	print("true")
-- 	-- end
-- 	self.shengyin_item_cell = ItemCell.New()
-- 	self.shengyin_item_cell:SetInstanceParent(self.node_list["IconImg"])
-- 	self.shengyin_item_cell:SetBackground(false)
-- 	self.shengyin_item_cell:ShowHighLight(false)
-- 	self.shengyin_item_cell:ShowQuality(false)
-- end

-- function ShengYinSlotItemRender:__delete()
-- 	if self.shengyin_item_cell then
-- 		self.shengyin_item_cell:DeleteMe()
-- 	end
-- 	self.shengyin_item_cell = nil
-- end

-- function ShengYinSlotItemRender:SetLockImg(islock)
-- 	if self.shengyin_item_cell then 
-- 		self.shengyin_item_cell:SetCellLock(islock)
-- 	end
-- end

-- function ShengYinSlotItemRender:GetItemCell()
-- 	return self.shengyin_item_cell 
-- end

-- function ShengYinSlotItemRender:SetRemindActive(bool)
-- 	self.node_list["Remind"]:SetActive(bool)
-- end

-- function ShengYinSlotItemRender:SetCellData(data)
-- 	self.shengyin_item_cell:SetData(data, true)
-- end

-- function ShengYinSlotItemRender:OnFlush()
	
-- 	if not self.data then return end

-- 	-- self.shengyin_item_cell:SetData()
-- end



