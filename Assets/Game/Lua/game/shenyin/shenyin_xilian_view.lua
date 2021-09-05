--洗练
ShenYinXiLianView = ShenYinXiLianView or BaseClass(BaseRender)

local MAX_PAGE = 10
local PAGE_CELL_NUM = 5

local XILIANTYPE = {
	XILIAN_ATTR = 1,
	XILIAN_VALUE = 2,
	XILIAN_COUNT = 3,
	NOT_USE = 4,
}	
local MOVE_TIME = 0.5	-- 界面动画时间
local MOVE_LOOP = 1

function ShenYinXiLianView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(-150 , -21 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["HelpBtn"] , Vector3(-163 , 500 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , -200 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , -50 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["MiddleUp"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -200 , 0 ) , MOVE_TIME )
end

function ShenYinXiLianView:__init()
	self.cell_list = {}

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["Txtyuanzhanli"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["ZhanLiTxt"])
	self:InitScroller()

	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["Btnshuxing"].toggle:AddValueChangedListener(BindTool.Bind(self.OnxilianShuxing, self, XILIANTYPE.XILIAN_ATTR))
	self.node_list["ShuzhiToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnxilianShuxing, self, XILIANTYPE.XILIAN_VALUE))
	self.node_list["AddToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnxilianShuxing, self, XILIANTYPE.XILIAN_COUNT))
	self.node_list["XilianBtn"].button:AddClickListener(BindTool.Bind(self.OnClickXilian, self))
	self.node_list["OnSaveBtn"].button:AddClickListener(BindTool.Bind(self.OnSave, self))

	self.stuff_item = ItemCell.New()
	self.stuff_item:SetInstanceParent(self.node_list["stuff_item"])
	self.slot_item = ItemCell.New()
	self.slot_item:SetInstanceParent(self.node_list["yinji_item"])
	self.slot_item:ListenClick(BindTool.Bind(self.OnClickTip, self))
	self.lock_list = {}
	self.item_cell = {}
	self.cell_list = {}
	self.new_item_cell = {}
	self.cellattur_list = {}
	self.now_attr_list = {}
	self.new_attr_list = {}
	self.select_data = {}
	self.slot_info = {}
	self.slot_num = 0

	self.selcetec_xilian_type = XILIANTYPE.XILIAN_ATTR -- 洗练类型
	self.select_slot = 0
	self.attur_number = 0
	self.new_attur_number = 0

	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	local start_pos = Vector3(30 , -30 , 0)
	local end_pos = Vector3(30 , 0 , 0)
	UITween.MoveLoop(self.node_list["UpArrow"], start_pos, end_pos, MOVE_LOOP)
end

function ShenYinXiLianView:__delete()
	self.lock_list = {}
	UITween.KillMoveLoop(self.node_list["UpArrow"])
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.new_item_cell) do
		v:DeleteMe()
	end
	self.new_item_cell = {}

	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}

	if self.stuff_item ~= nil then
		self.stuff_item:DeleteMe()
		self.stuff_item = nil 
	end

	if self.slot_item ~= nil then
		self.slot_item:DeleteMe()
		self.slot_item = nil 
	end

	if self.cell_item then
		self.cell_item:DeleteMe()
		self.cell_item = nil
	end

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function ShenYinXiLianView:OpenCallBack()
	self:Flush()
	self.slot_info = {}
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local num = 0
	for k,v in pairs(data) do
		if v.is_have_mark then
			self.slot_info[num] = v
			num = num + 1
		end
	end
	if next(self.slot_info) then
		self.select_slot = self.slot_info[0].imprint_slot
	end
	self.slot_num = num
	RemindManager.Instance:Fire(RemindName.ShenYin_XiLian)
end

--初始化滚动条
function ShenYinXiLianView:InitScroller()
	self.scroller = self.node_list["Scroller"]

	self.list_view_delegate = self.scroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.attur = self.node_list["Attur"]
	self.list_view_attur = self.attur.list_simple_delegate

	self.list_view_attur.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAtturCells, self)
	self.list_view_attur.CellRefreshDel = BindTool.Bind(self.RefreshAtturView, self)

	self.new_attur = self.node_list["NewAttur"]
	self.new_list_view_attur = self.new_attur.list_simple_delegate

	self.new_list_view_attur.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfNewAtturCells, self)
	self.new_list_view_attur.CellRefreshDel = BindTool.Bind(self.RefreshNewAtturView, self)
end


function ShenYinXiLianView:OnItemDataChange(item_id)
	self:Flush()
end

function ShenYinXiLianView:OnFlush(param_t)
	if self.attur.scroller.isActiveAndEnabled then
		self.attur.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.new_attur.scroller.isActiveAndEnabled then
		self.new_attur.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushStuff()
	self:FlushXiLianSlot()
end
function ShenYinXiLianView:ClickLockCallBack(item, index)
	local list_close_num = 0
	for k,v in pairs(self.lock_list) do
		if k <= self.attur_number and v == false then 
			list_close_num = list_close_num + 1
		end
	end
	if list_close_num >= self.attur_number - 1 and self.lock_list[index] == true then 
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.CanNotLock)
		return
	end
	self.lock_list[index] = not self.lock_list[index]
	--item:FlushLock(self.lock_list[index])
	self:Flush()
end
function ShenYinXiLianView:ReSetLockState()
	self.lock_list = {}
	for k,v in pairs(self.lock_list) do
		self.lock_list[k] = true
	end
	--self.Flush()
end
function ShenYinXiLianView:OnClickTip()
	ShenYinCtrl.Instance:OpenYinJiTip(self.slot_item:GetData(), ShenYinYinJiTipView.FromView.ShenYinStrength)
end

function ShenYinXiLianView:FlushStuff()
	local item_list, need_num_list = ShenYinData.Instance:GetShenYinXiLianStuffCfg()
	local item_num = ItemData.Instance:GetItemNumInBagById(item_list[self.selcetec_xilian_type])
	local need_num = need_num_list[self.selcetec_xilian_type]
	local add_attr_cfg = ShenYinData.Instance:GetXilianAddCount()
	if self.selcetec_xilian_type == XILIANTYPE.XILIAN_COUNT then
		need_num = add_attr_cfg[self.attur_number + 1] and add_attr_cfg[self.attur_number + 1].consume_num or 0
	end

	
	local add_num = ShenYinData.Instance:GetLockConsume() or 0
	local add_need_count = 0 
	for k,v in pairs(self.lock_list) do
		if k <= self.attur_number and v == false then
			add_need_count = add_need_count + add_num
		end
	end
	local color = item_num >= need_num + add_need_count and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	self.node_list["ItemNumTxt"].text.text = ToColorStr(item_num, color) .. " / " .. (need_num + add_need_count)
	self.stuff_item:SetData({item_id = item_list[self.selcetec_xilian_type]})

	local success_rate = add_attr_cfg[self.attur_number + 1] and add_attr_cfg[self.attur_number + 1].rate or 0

	self.node_list["Txtsuccess"]:SetActive(self.selcetec_xilian_type == XILIANTYPE.XILIAN_COUNT and self.attur_number < #add_attr_cfg and 0 ~= self.slot_num)
	self.node_list["Txtsuccess"].text.text = string.format(Language.Forge.SuccRate, ToColorStr(success_rate .. "%", TEXT_COLOR.GREEN_4))

	self.node_list["RemindImg1"]:SetActive(ItemData.Instance:GetItemNumInBagById(
		0 ~= self.slot_num and item_list[XILIANTYPE.XILIAN_COUNT]) >= (add_attr_cfg[self.attur_number + 1] 
		and add_attr_cfg[self.attur_number + 1].consume_num or 0) and nil ~= add_attr_cfg[self.attur_number + 1])

	self.node_list["RemindImg2"]:SetActive(ItemData.Instance:GetItemNumInBagById(0 ~= self.slot_num 
		and item_list[XILIANTYPE.XILIAN_ATTR]) >= need_num_list[XILIANTYPE.XILIAN_ATTR])

	self.node_list["RemindImg3"]:SetActive(ItemData.Instance:GetItemNumInBagById(0 ~= self.slot_num 
		and item_list[XILIANTYPE.XILIAN_VALUE]) >= need_num_list[XILIANTYPE.XILIAN_VALUE])
end

function ShenYinXiLianView:GetNumberOfNewAtturCells()
	self:SetXiLianAttrList()
	return self.new_attur_number or 0
end

function ShenYinXiLianView:RefreshNewAtturView(cell, data_index)
	self.cell = self.new_item_cell[cell]
	if self.cell == nil then
		self.cell = AtturItemCell.New(cell.gameObject)
		self.new_item_cell[cell] = self.cell
	end
	if self.new_attr_list[data_index + 1] == nil then return end
	if nil == self.lock_list[data_index + 1] then 
		self.lock_list[data_index + 1] = true
	end
	self.new_item_cell[cell]:SetData(self.new_attr_list[data_index + 1], XILIANTYPE.NOT_USE)
	self.new_item_cell[cell]:SetIndex(data_index + 1)
end

function ShenYinXiLianView:GetNumberOfAtturCells(cell, data_index)
	self:SetXiLianAttrList()

	return self.attur_number or 0
end

function ShenYinXiLianView:RefreshAtturView(cell, data_index)
	self.cell_item = self.cellattur_list[cell]
	if self.cell_item == nil then
		self.cell_item = AtturItemCell.New(cell.gameObject)
		self.cellattur_list[cell] = self.cell_item
	end
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local select_data = data[self.select_slot]

	local data1 = {}
	for k,v in pairs(select_data.attr_param.value_list or {}) do
		if v > 0 and select_data.attr_param.type_list[k] >= 0 then
			data1[#data1 + 1] = {type = select_data.attr_param.type_list[k] , value = v}
		end
	end
	if self.now_attr_list[data_index + 1] == nil then return end
	if nil == self.lock_list[data_index + 1] then 
		self.lock_list[data_index + 1] = true
	end
	self.cellattur_list[cell]:SetData(self.now_attr_list[data_index + 1], self.selcetec_xilian_type, BindTool.Bind(self.ClickLockCallBack ,self), self.lock_list[data_index + 1])
	self.cellattur_list[cell]:SetIndex(data_index + 1)
end

--滚动条数量
function ShenYinXiLianView:GetNumberOfCells()
	return self.slot_num
end

--滚动条刷新
function ShenYinXiLianView:RefreshView(cell, data_index)
	local item_cell = self.cell_list[cell]
	if item_cell == nil then
		item_cell = ShenYinQiangHuaItemCell.New(cell.gameObject, self)
		self.cell_list[cell] = item_cell
		item_cell:SetFromView(1)
		self.cell_list[cell]:SetToggleGroup(self.scroller.toggle_group)
	end
	self.cell_list[cell]:SetData(self.slot_info[data_index] , self.node_list["UpArrow"])
	self.cell_list[cell]:SetClickHander(BindTool.Bind(self.ClickHander, self, self.slot_info[data_index]))
	self.cell_list[cell]:SetIndex(data_index + 1)
	item_cell:SetItemHL()
	item_cell:Flush()
end


function ShenYinXiLianView:OnClickHelp()
	local tips_id = 243
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenYinXiLianView:ClickHander(data)
	self.select_slot = data.imprint_slot
	self:ReSetLockState()
	self:Flush()
	
end

function ShenYinXiLianView:FlushXiLianSlot()
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local select_data = data[self.select_slot]
	if select_data == nil or next(select_data) == nil then return end
	self.slot_item:SetData(select_data)
	local bundle, asset = ResPath.GetShenYinIcon(self.select_slot + 1)
	if select_data.is_have_mark then
		self.slot_item:ShowQuality(true)
	else
		self.slot_item:ShowQuality(false)
	end

	local attr_key_list = CommonDataManager.GetAttrKeyList()
	local now_attr_cfg = {}
	for k,v in pairs(self.now_attr_list) do
		local key = attr_key_list[v.type + 1]
		if now_attr_cfg[key] then
			now_attr_cfg[key] = now_attr_cfg[key] + v.value
		else
			now_attr_cfg[key] = v.value
		end
	end

	local new_attr_cfg = {}
	for k,v in pairs(self.new_attr_list) do
		local key = attr_key_list[v.type + 1]
		if new_attr_cfg[key] then
			new_attr_cfg[key] = new_attr_cfg[key] + v.value
		else
			new_attr_cfg[key] = v.value
		end
	end
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = 0 ~= self.slot_num and CommonDataManager.GetCapability(now_attr_cfg) or 0
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = 0 ~= self.slot_num and CommonDataManager.GetCapability(new_attr_cfg) or 0
	end
	self.node_list["itemNode"]:SetActive(self.slot_num > 0)
	self.node_list["ImgTxt"]:SetActive(self.slot_num <= 0)
	UI:SetButtonEnabled(self.node_list["OnSaveBtn"],self.new_attur_number > 0)

end  

function ShenYinXiLianView:GetSelectIndex()
	return self.select_slot
end

function ShenYinXiLianView:SetXiLianAttrList()
	local data_info = ShenYinData.Instance:GetMarkSlotInfo()
	local select_data = data_info[self.select_slot] or {}
	local data1 = {}
	local data2 = {}
	local attur_number = 0
	local new_attur_number = 0
	if select_data and select_data.is_have_mark then
		for k,v in pairs(select_data.attr_param.value_list) do
			if v > 0 then
				data1[#data1 + 1] = {type = select_data.attr_param.type_list[k] , value = v}
				attur_number = attur_number + 1
			end
		end
	    self.now_attr_list = data1

		for k1,v1 in pairs(select_data.new_attr_param.value_list or {}) do
			if v1 > 0 then
				data2[#data2 + 1] = {type = select_data.new_attr_param.type_list[k1] , value = v1}
				new_attur_number = new_attur_number + 1
			end
		end
	    self.new_attr_list = data2

		self.attur_number = attur_number
		self.new_attur_number = new_attur_number
	else
		self.attur_number = 0
		self.new_attur_number = 0
	end
end

function ShenYinXiLianView:OnClickXilian()
	if self.selcetec_xilian_type == XILIANTYPE.XILIAN_ATTR then
		send_type = CS_SHEN_YIN_TYPE.IMPRINT_FLUSH_ATTR_TYPE
	elseif self.selcetec_xilian_type == XILIANTYPE.XILIAN_VALUE then
		send_type = CS_SHEN_YIN_TYPE.IMPRINT_FLUSH_ATTR_VALUE
	elseif self.selcetec_xilian_type == XILIANTYPE.XILIAN_COUNT then
		send_type = CS_SHEN_YIN_TYPE.IMPRINT_ADD_ATTR_COUNT
	end
	self:Flush()
	local add_attr_cfg = ShenYinData.Instance:GetXilianAddCount()
	if self.selcetec_xilian_type == XILIANTYPE.XILIAN_COUNT and self.attur_number == #add_attr_cfg then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.XiLianNumTip)
		return
	end
	local lock_flag = {}
	for i = 1, 32 do
		lock_flag[i] = 0
		lock_flag[i] = 0
	end
	local list_close_num = 0
	for k,v in pairs(self.lock_list) do
		if k <= self.attur_number and v == false then
			lock_flag[32 - k + 1] = 1
		else
			lock_flag[32 - k + 1] = 0
		end
	end
	lock_flag = bit:b2d(lock_flag)
	ShenYinCtrl.SendTianXiangOperate(send_type, self.select_slot, lock_flag)

end

function ShenYinXiLianView:OnSave()
	if self.attur_number ~= self.new_attur_number then 
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.DontSame)
	end
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_APLY_FLUSH, self.select_slot)
	--self:ReSetLockState()
	self:Flush()
end

function ShenYinXiLianView:OnxilianShuxing(flag)
	self.selcetec_xilian_type = flag
	--self:FlushStuff()
	self:ReSetLockState()
	self:Flush()
	
end

AtturItemCell = AtturItemCell or BaseClass(BaseRender)

function AtturItemCell:__init()
	self.index = 0
	self.node_list["BtnLock"].button:AddClickListener(BindTool.Bind(self.ChangeLockState, self))
	self.lock_state = true
	--self:ResetLockState()
end

function AtturItemCell:__delete()
	self.call_back = nil
	self.lock_state = true
end
function AtturItemCell:SetData(data , active , call_back, lock_state)
	self.data = data
	local attr_list = Language.ShenYin.atrr_fujia_list1
	local max_value = ShenYinData.Instance:GetXiLianMaxValueByAttrType(self.data.type)

	self.node_list["Imgvalue"].slider.value = (self.data.value / max_value)
	self.node_list["Txtshuxingvalue"].text.text = string.format("%s<color=#FF9E0EFF>+%d</color>",attr_list[self.data.type + 1],self.data.value)
	if active == XILIANTYPE.XILIAN_ATTR then
		self.node_list["BtnLock"]:SetActive(true)
	elseif active == XILIANTYPE.XILIAN_VALUE then
		self.node_list["BtnLock"]:SetActive(true)
	elseif active == XILIANTYPE.XILIAN_COUNT then
		self.node_list["BtnLock"]:SetActive(false)
	elseif active == XILIANTYPE.NOT_USE then 
		self.node_list["BtnLock"]:SetActive(false)
	end
	if nil == self.call_back then 
		self.call_back = call_back
	end
	self.lock_state = lock_state
	if nil == self.lock_state then
		self.lock_state = true 
	end
	self:FlushLock()
end

function AtturItemCell:ChangeLockState()
	if nil ~= self.call_back then 
		self.call_back(self, self.index)
	end
end
function AtturItemCell:FlushLock()
	self.node_list["Open_Lock"]:SetActive(self.lock_state)
	self.node_list["Close_Lock"]:SetActive( not self.lock_state)
end
function AtturItemCell:SetIndex(index)
	self.index = index
end

function AtturItemCell:GetIndex()
	return self.index
end