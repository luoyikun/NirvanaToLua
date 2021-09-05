BaoBaoGuardView = BaoBaoGuardView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local MOVE_TIME = 0.5
local CELL_SIZE = 145
local CELL_HIGHT = 40
function BaoBaoGuardView:UIsMove()
	-- UITween.AlpahShowPanel(self.node_list["MiddleLeftSW"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	-- UITween.MoveShowPanel(self.node_list["MountInfoSW"] , Vector3(300 , -28 , 0 ) , MOVE_TIME )
	-- UITween.MoveShowPanel(self.node_list["BtnShuXing"] , Vector3(72 , 150 , 0 ) , MOVE_TIME )
	
end
function BaoBaoGuardView:__init(instance, mother_view)
	self.sprite_level = 0
	self.sprite_index = 0
	self.selectindex = 1
	self:InitScroller()
	self.node_list["BtnUpGradeSW"].button:AddClickListener(BindTool.Bind(self.AutoUpGradeClick, self))
	self.node_list["BtnShuXing"].button:AddClickListener(BindTool.Bind(self.ClickSpriteAttr, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ChangePage, self , PageLeft))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ChangePage, self , PageRight))
	self.fight_text_middle = CommonDataManager.FightPower(self, self.node_list["FightNumSW"])
	for i = 1, 2 do
		self.node_list["ClickSprite" .. i].toggle:AddClickListener(BindTool.Bind(self.ClickSprite, self , i - 1))
	end
	self.node_list["HelpTips"].button:AddClickListener(BindTool.Bind(self.ClickSpirteTips, self))
	self.sprite_title = ""
	self.spritelevel = {}
	self.spritegrade = {}
	self.fight_text = {}
	-- self.spritename = {}
	self.temp_grade = {}
	for i = 1, 2 do
		self.spritelevel[i] = self.node_list["SpriteLevel" .. i]
		self.spritegrade[i] = self.node_list["Grade" .. i]
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["Power" .. i])
		-- self.spritename[i] = self.node_list["Txt_name" .. i]
		self.temp_grade[i] = - 1
	end
	self.sprite_cell = ItemCell.New()
	self.sprite_cell:SetInstanceParent(self.node_list["Sprite"])
	self.show_sprite_red = {}
	for i = 0, 1 do
		self.show_sprite_red[i] = self.node_list["ShowSpriteRed" .. i]
	end
	self.progress_value = ProgressBar.New(self.node_list["ProgressBG"])
	self.cell_list = {}
	self.list_view_delegate = self.node_list["AttrContentSW"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.list_view_delegate.CellSizeDel = BindTool.Bind(self.CellSize, self)

	self.old_sprite_level = {}
end

function BaoBaoGuardView:__delete()
	if nil ~= self.progress_value then
		self.progress_value:DeleteMe()
		self.progress_value = nil
	end
	if nil ~= self.sprite_obj_transform then
		ResMgr:Destroy(self.sprite_obj_transform.gameObject)
		self.sprite_obj_transform = nil   
	end

	if self.sprite_cell then
		self.sprite_cell:DeleteMe()
	end
	self.sprite_cell = nil

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.baobao_cell_list then
		for k,v in pairs(self.baobao_cell_list) do
			v:DeleteMe()
		end
	end
	self.baobao_cell_list = {}

	self.auo_btn_name = nil
	self.show_sprite_red = nil
	self.spritelevel = nil
	self.spritegrade = nil
	self.spritename = nil

	self.sprite_title = nil
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.old_sprite_level = {}

	for k,v in pairs(self.fight_text) do
		v = nil
	end
	self.fight_text = nil
	self.fight_text_middle = nil
end

--初始化滚动条
function BaoBaoGuardView:InitScroller()
	self.baobao_cell_list = {}

	self.baobao_list_view_delegate = ListViewDelegate()
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/marriageview/baobao_prefab", "BaoBaoGuardItem", nil , function (prefab)
		if nil == prefab then
			return
		end
		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["Scroller"].scroller.Delegate = self.baobao_list_view_delegate
		self.baobao_list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfBaobaoCells, self)
		self.baobao_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.baobao_list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
	self.node_list["Scroller"].scroller.scrollerScrolled = function ()
		self:ReSetBtnVisible()
	end
end

--滚动条数量
function BaoBaoGuardView:GetNumberOfBaobaoCells()
	return #BaobaoData.Instance:GetListBabyData()
end

function BaoBaoGuardView:CellSize(index)
	return CELL_HIGHT
end

--滚动条大小
function BaoBaoGuardView:GetCellSize()
	return CELL_SIZE
end

--滚动条刷新
function BaoBaoGuardView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1

	if nil == self.baobao_cell_list[cell] then
		self.baobao_cell_list[cell] = BaoBaoGuardScrollerItem.New(cell.gameObject)
		self.baobao_cell_list[cell].parent = self
	end

	local data_list = BaobaoData.Instance:GetListBabyData()
	if data_list[data_index] then
		self.baobao_cell_list[cell]:SetIndex(data_list[data_index].baby_index + 1)
		self.baobao_cell_list[cell]:SetData(data_list[data_index])
		self.baobao_cell_list[cell]:ShowHight(BaobaoData.Instance:GetSelectedBabyIndex())
	end
	return cell
end

--设置按钮是否可见
function BaoBaoGuardView:ReSetBtnVisible()

	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local disable_height = self.node_list["Scroller"].scroller.ScrollSize                       --listview不可见的画布长度

	if disable_height < 10 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(false)
		return
	end
	self.node_list["BtnLeft"]:SetActive(true)
	self.node_list["BtnRight"]:SetActive(true)

	if position <= 0 then
		self.node_list["BtnLeft"]:SetActive(false)
	elseif disable_height - position <= 10 or position > disable_height then
		self.node_list["BtnRight"]:SetActive(true)
	end
end

function BaoBaoGuardView:ChangePage(value)
	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local disable_height = self.node_list["Scroller"].scroller.ScrollSize						--listview不可见的画布长度
	local visible_height = self.node_list["Scroller"].scroller.ScrollRectSize					--listview可见的画布长度
	self.node_list["BtnLeft"]:SetActive(true)
	self.node_list["BtnRight"]:SetActive(true)

	local temp_position = 0
	if value == PageLeft then
		temp_position = position - visible_height
		if temp_position < 0 then
			temp_position = 0
			self.node_list["BtnLeft"]:SetActive(false)
		end
	else
		temp_position = position + visible_height
		if temp_position > disable_height then
			temp_position = disable_height
			self.node_list["BtnRight"]:SetActive(false)
		end
	end

	local index = self.node_list["Scroller"].scroller:GetCellViewIndexAtPosition(temp_position)

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
	local scrollerTweenTime = 0
	local scroll_complete = nil
	self.node_list["Scroller"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end


function BaoBaoGuardView:ResetValue()
	for i = 1, 2 do
		 self.temp_grade[i] = - 1
	end
end

function BaoBaoGuardView:StartAnim()
	if nil ~= self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateAnim,self), 0)
end

function BaoBaoGuardView:UpdateAnim()
	-- self.node_list["SpriteImg"].transform:Rotate(UnityEngine.Vector3.forward,-0.5)
	-- local sprite = self.node_list["SpriteImg"].transform
	-- local an = self.node_list["ClickSprite1"].transform.localRotation
	-- local guang = self.node_list["ClickSprite2"].transform.localRotation
	-- local shui = self.node_list["ClickSprite3"].transform.localRotation
	-- local tu = self.node_list["ClickSprite4"].transform.localRotation
	-- self.node_list["ClickSprite1"].transform.localRotation = UnityEngine.Quaternion(an.x,an.y,-sprite.rotation.z,sprite.localRotation.w)
	-- self.node_list["ClickSprite2"].transform.localRotation = UnityEngine.Quaternion(guang.x,guang.y,-sprite.rotation.z,sprite.localRotation.w)
	-- self.node_list["ClickSprite3"].transform.localRotation = UnityEngine.Quaternion(shui.x,shui.y,-sprite.rotation.z,sprite.localRotation.w)
	-- self.node_list["ClickSprite4"].transform.localRotation = UnityEngine.Quaternion(tu.x,tu.y,-sprite.rotation.z,sprite.localRotation.w)
end

function BaoBaoGuardView:CloseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.is_auto_upgrade then
		self:AutoUpGradeClick()
	end

	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.node_list["EffectSW"]:SetActive(false)
end

function BaoBaoGuardView:GetNumberOfCells()
	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	local count = 0
	local cur_attr = {}

	if baby_select_index ~= nil and all_baby_sprite_list[baby_select_index - 1]
					 and all_baby_sprite_list[baby_select_index - 1][self.sprite_index or 0] then
					 self.sprite_index = self.sprite_index or 0

		local spirit_level = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_level or 0
		cur_attr = BaobaoData.Instance:GetBabySpiritAttr(self.sprite_index, spirit_level)
	end

	count = #cur_attr or 0
	return count
end

function BaoBaoGuardView:RefreshView(cell,data_index)
	data_index = data_index +1 
	local attr_cell = self.cell_list[cell]

	if nil == attr_cell then
		attr_cell = SpriteAttrCell.New(cell.gameObject)
		self.cell_list[cell] = attr_cell
	end

	local attribute = CommonStruct.Attribute()
	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()

	if nil ~= baby_select_index and all_baby_sprite_list[baby_select_index - 1]
					 and all_baby_sprite_list[baby_select_index - 1][self.sprite_index or 0] then
					 self.sprite_index = self.sprite_index or 0

		local spirit_level = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_level
		local cur_attr = BaobaoData.Instance:GetBabySpiritAttr(self.sprite_index, spirit_level)
		attr_cell:SetData(cur_attr[data_index])
	end
end

function BaoBaoGuardView:AutoUpGradeClick()
	-- self.is_auto_upgrade = not self.is_auto_upgrade
	-- self:IsMaxValue()
	-- if self.is_auto_upgrade then
	--    self:AutoUpGradeOnce()
 --   end

 	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if nil == baby_select_index then return end
	local baby_info = BaobaoData.Instance:GetBabyInfo(baby_select_index)
	if nil == baby_info then return end

	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	if all_baby_sprite_list[baby_select_index - 1] and all_baby_sprite_list[baby_select_index - 1][self.sprite_index] then
		local spirit_level = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_level
		if spirit_level == 0 then
			spirit_level = 1
		end
		BaobaoCtrl.SendBabyTrainSpiritReq(baby_select_index - 1, self.sprite_index, 0, 1)
	end

end

function BaoBaoGuardView:AutoUpGradeOnce()
	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if nil == baby_select_index then return end
	local baby_info = BaobaoData.Instance:GetBabyInfo(baby_select_index)
	if nil == baby_info then return end
	self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()-- 记录谁被进阶
	local used_item_id = self.used_item_id or 0
	local have_item_num = ItemData.Instance:GetItemNumInBagById(used_item_id)
	if have_item_num < 1 and not self.node_list["AutoBuySW"].toggle.isOn then
		self.is_auto_upgrade = false
		self:AutoBuyConfirm(used_item_id)
		return
	end
	
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	if self.is_auto_upgrade then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpGradeClick,self,true), jinjie_next_time)
	end
end

function BaoBaoGuardView:UpGradeClick(is_on)
	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if nil == baby_select_index then return end
	local baby_info = BaobaoData.Instance:GetBabyInfo(baby_select_index)
	if nil == baby_info then return end

	local used_item_id = self.used_item_id or 0
	local have_item_num = ItemData.Instance:GetItemNumInBagById(used_item_id)
	if have_item_num < 1 and not self.node_list["AutoBuySW"].toggle.isOn then
		self:AutoBuyConfirm(used_item_id)
		return
	end
	local next_time = 0.1
	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	if all_baby_sprite_list[baby_select_index - 1] and all_baby_sprite_list[baby_select_index - 1][self.sprite_index] then
		local spirit_level = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_level
		if spirit_level == 0 then
			spirit_level = 1
		end
		local cfg = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, spirit_level)
		local is_auto_buy = self.node_list["AutoBuySW"].toggle.isOn and 1 or 0
		if cfg.pack_num then
			BaobaoCtrl.SendBabyTrainSpiritReq(baby_select_index - 1, self.sprite_index, is_auto_buy, cfg.pack_num)
			self.jinjie_next_time = Status.NowTime + next_time
		end
	end
end

function BaoBaoGuardView:AutoBuyConfirm(item_id)
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
	MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	self.node_list["AutoBuySW"].toggle.isOn = is_buy_quick
	end
  
	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, BindTool.Bind2(self.TipsCancelCallback, self), 1)
	return true
end

function BaoBaoGuardView:TipsCancelCallback()
	self.is_auto_upgrade = false
	self.node_list["TxtUpGradeSW"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
end

function BaoBaoGuardView:OnOperateResult(operate, result, param1, param2)
	if 0 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
			self.node_list["TxtUpGradeSW"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		end
	elseif 1== result then
		self:AutoUpGradeOnce()    
	elseif 2 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
			self.node_list["TxtUpGradeSW"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		end
	elseif 3 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
		end
		self:FlushView()
	end
end

function BaoBaoGuardView:ClickSpriteAttr()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	local attr_data = BaobaoData.Instance:GetBabyTotalSpriteAttr()
	TipsCtrl.Instance:ShowAttrView(attr_data, nil, "baobao_guard")
	self:FlushView()
end

function BaoBaoGuardView:ClickSprite(index)
	self.sprite_index = index
	BaobaoData.Instance:SetCurSpiritIndex(index)
	self:FlushView()
	self:UpdateSprite()
	self.node_list["AttrContentSW"].scroller:RefreshAndReloadActiveCellViews(true)
end

function BaoBaoGuardView:FlushSpriteRed(index)
	local _, red_t = BaobaoData.Instance:SetBaobaoRedPoint(index)
	for i = 0, 1 do
		self.show_sprite_red[i]:SetActive(red_t[i] == true)
	end
end

function BaoBaoGuardView:UpdateSprite()
	if nil ~= self.sprite_obj_transform then
		ResMgr:Destroy(self.sprite_obj_transform.gameObject)
		self.sprite_obj_transform = nil
	end
end

function BaoBaoGuardView:ClickSpirteTips()
	local tip_id = 281
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 监听物品变化
function BaoBaoGuardView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local cur_cfg = BaobaoData.Instance:GetBabySpiritCfg(self.sprite_index, self.sprite_level + 1)
	if cur_cfg and cur_cfg.consume_item == item_id then
		self:FlushView()
		BaobaoCtrl.Instance:FlushImageViewRed()
	end
end

function BaoBaoGuardView:IsMaxValue()
   return BaobaoData.Instance:GetBabySpiritCfg(self.sprite_index, self.sprite_level + 1) == nil
end
function BaoBaoGuardView:OnFlush()
	self:FlushView()
end

function BaoBaoGuardView:FlushView()
	self.node_list["TxtUpGradeSW"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:StartAnim()
	if self.sprite_obj_transform == nil then
		self:UpdateSprite()
	end
	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	self:FlushSpriteRed(baby_select_index)
	local max_level = BaobaoData.Instance:GetBabySpiritMaxLevel()
	if nil ~= baby_select_index and all_baby_sprite_list[baby_select_index - 1] 
	  and all_baby_sprite_list[baby_select_index - 1][self.sprite_index or 0] then
		self.sprite_index = self.sprite_index or 0
		self.sprite_level = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_level
		local attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, self.sprite_level)
		if self.sprite_level == 0 then
			attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, 1)
		end
		local data = {item_id = attr.consume_item}
		self.sprite_cell:SetData(data)
		self.sprite_order = attr.order

		local cur_attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, self.sprite_level)
		local next_attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, self.sprite_level + 1)
		if nil ~= next_attr.consume_item then
			local item_num = ItemData.Instance:GetItemNumInBagById(next_attr.consume_item)
			self.used_item_id = next_attr.consume_item       --记录当前需要消耗的材料id
			local item_name = ItemData.Instance:GetItemName(next_attr.consume_item) or ""
			local color = item_num < 1 and "#ff0000" or "#89F201"
			local consume_num = 1                            --消耗的精灵材料个数为1(看了下配置表，并没有消耗材料的字段，好像是写死1的)
			self.node_list["TxtStuffSW"].text.text = string.format(Language.Marriage.BaobaoStuff, color,item_num,consume_num)
		else
			self.used_item_id = 0
			local str = Language.Marriage.BaobaoSpriteMaxLevel or ""
			self.node_list["TxtStuffSW"].text.text = str
		end
		local cur_train_val = all_baby_sprite_list[baby_select_index - 1][self.sprite_index].spirit_train
		UI:SetButtonEnabled(self.node_list["BtnUpGradeSW"], nil ~= next_attr.train_val)

		for i = 1, 2 do
			if self.sprite_index + 1 == i then
				local cur_level = all_baby_sprite_list[baby_select_index - 1][i - 1].spirit_level
				if self.temp_grade[i] ~= - 1 then
					if self.temp_grade[i] < cur_level then
						-- 升级特效
						if not self.effect_cd or self.effect_cd <= Status.NowTime then
							self.node_list["EffectSW"]:SetActive(false)
							self.node_list["EffectSW"]:SetActive(true)
							self.effect_cd = EFFECT_CD + Status.NowTime
						end
					end
				end
				self.temp_grade[i] = cur_level
			end
			local attr = BaobaoData.Instance:GetBabySpiritAttrCfg(i - 1, all_baby_sprite_list[baby_select_index - 1][i - 1].spirit_level)
			
			self.spritelevel[i].text.text = "Lv".. all_baby_sprite_list[baby_select_index - 1][i - 1].spirit_level.. "·" .. attr.title
			self.spritegrade[i].text.text = string.format(Language.Marriage.Grade, attr.order)
			local cur_attr = BaobaoData.Instance:GetBabySpiritAttrCfg(i - 1, all_baby_sprite_list[baby_select_index - 1][i - 1].spirit_level)
			if self.fight_text[i] and self.fight_text[i].text then
				self.fight_text[i].text.text = CommonDataManager.GetCapability(cur_attr)
			end
			-- self.spritename[i].text.text = attr.name
		end

		if nil ~= next_attr.train_val then
			local percent = cur_train_val / next_attr.train_val
			--self.node_list["ProgressBG"].slider.value = percent
			self.progress_value:SetValue(percent)
			self.node_list["TxtProgress"].text.text = cur_train_val .. " / " .. next_attr.train_val

		else
			self.node_list["TxtProgress"].text.text = Language.Common.MaxLv
			self.node_list["TxtUpGradeSW"].text.text = Language.Advance.MaxGradeText
			self.node_list["TxtStuffSW"].text.text = Language.Common.MaxLevelDesc
			--self.node_list["ProgressBG"].slider.value = 1.0
			self.progress_value:SetValue(1.0)
		end

		self.sprite_title = ToColorStr(attr.title  .. "·" .. string.format(Language.Marriage.Grade, self.sprite_order), BAOBAO_SPRITE_COLOR[self.sprite_index + 1])
		self.node_list["CurLevel"].text.text = self.sprite_title
		if self.fight_text_middle and self.fight_text_middle.text then
			self.fight_text_middle.text.text = CommonDataManager.GetCapability(cur_attr)
		end
		self.node_list["TxtUpGradeSW"].text.text = Language.Marriage.BaoBaoSwBtnText[self.sprite_index]
	end

	if not self.old_sprite_level[self.sprite_index] or self.sprite_level and self.old_sprite_level[self.sprite_index] < self.sprite_level then
		self.node_list["AttrContentSW"].scroller:RefreshAndReloadActiveCellViews(true)
		self.old_sprite_level[self.sprite_index] = self.sprite_level
	else
		self.node_list["AttrContentSW"].scroller:RefreshActiveCellViews()
	end

	-- self.node_list["AttrContentSW"].scroller:ReloadData(0)

	if self.selectindex ~= BaobaoData.Instance:GetSelectedBabyIndex() then
		self.is_auto_upgrade = false
		self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()
		self:FlushView()
	end
end

--------------------------------------------AttrCell---------------------------------------------------------------
SpriteAttrCell = SpriteAttrCell or BaseClass(BaseCell)

function SpriteAttrCell:__init()

end

function SpriteAttrCell:FlushAttr()
	self.node_list["CurAttr"].text.text = Language.Common.AttrName[self.data.name].."：".."<size=22>".."<color=".."#ffffff"..">"..self.data.cur_value.."</color>".."</size>"
	if self.data.next_value > 0 then
		self.node_list["NextAttr"].text.text = "<size=22>"..self.data.next_value.."</size>"
	end
	--self.node_list["AttrIcon"].image:LoadSprite(ResPath.GetBaseAttrIcon(self.data.name))
	local cur_level = BaobaoData.Instance:GetCurSpiritLevel()
	self.node_list["NextIcon"]:SetActive(cur_level ~= BaobaoData.Instance:GetBabySpiritMaxLevel())
end

function SpriteAttrCell:OnFlush()
	if nil == self.data then return end
	self:FlushAttr()
end


--宝宝滚动条格子
BaoBaoGuardScrollerItem = BaoBaoGuardScrollerItem or BaseClass(BaseCell)
function BaoBaoGuardScrollerItem:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self.node_list["BaoBaoItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["Img_left_level"]:SetActive(true)
	self.node_list["Img_right_level"]:SetActive(true)
end

function BaoBaoGuardScrollerItem:ClickItem()
	self.root_node.toggle.isOn = true
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if select_index == self.index then
		return
	end

	BaobaoData.Instance:SetSelectedBabyIndex(self.index)
	-- 重置当前记录的宝宝守护精灵等级Fag
	BaobaoCtrl.Instance:ResetValue()
	ViewManager.Instance:FlushView(ViewName.MarryBaby)
end

function BaoBaoGuardScrollerItem:__delete()

end

function BaoBaoGuardScrollerItem:ShowHight(index)
	self.node_list["ShowHight"]:SetActive(self.index == index)
end

function BaoBaoGuardScrollerItem:OnFlush()
	if not self.data then return end
	self.node_list["Name"].text.text = self.data.baby_name
	-- 刷新选中特效
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()

	local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
	if all_baby_sprite_list == nil and all_baby_sprite_list[self.index - 1] == nil then
		return
	end
	local wen_level = all_baby_sprite_list[self.index - 1][0].spirit_level or 0
	local wu_level = all_baby_sprite_list[self.index - 1][1].spirit_level or 0
	self.node_list["Txt_left_level"].text.text = wen_level
	local max_level = BaobaoData.Instance:GetbabyspiritMaxLevel()
	self.node_list["Txt_right_level"].text.text = wu_level .. " / " .. max_level
	if wu_level ~= 0 then
		self.node_list["Img_right_level"].slider.value = wu_level / max_level
	else
		self.node_list["Img_right_level"].slider.value = 0
	end


	local bundle, asset = ResPath.GetBabyIcon("baby_icon_" .. self.data.baby_id)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	local red = BaobaoData.Instance:SetBaobaoRedPoint(self.index)
	local cur_tab_index = BaobaoData.Instance:GetCurTabIndex()
	if cur_tab_index == TabIndex.marriage_baobao_guard then
		self.node_list["RedPoint"]:SetActive(red > 0)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end

   if self.data.lover_name ~= BaobaoData.Instance:GetLoveID() then
   		self.node_list["ShowLihun"]:SetActive(true)
   	else
   		self.node_list["ShowLihun"]:SetActive(false)
   end
end
