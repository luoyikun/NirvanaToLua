ShengXiaoMijiView = ShengXiaoMijiView or BaseClass(BaseView)

FEECTBYLEVEL = {
	[0] = "baoshi_lanse",
	[1] = "baoshi_zi",
	[2] = "baoshi_huang",
}

function ShengXiaoMijiView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengxiaoview_prefab", "ShengXiaoMiji"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function ShengXiaoMijiView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(1020, 616, 0)
	self.node_list["Txt"].text.text = Language.ShengXiao.ShengXiaoMiJi

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))
	self.node_list["BtnMiji"].button:AddClickListener(BindTool.Bind(self.OnTakeOffMiji, self))
	self.node_list["BtnLevelUp"].button:AddClickListener(BindTool.Bind(self.OnClickStudy, self))
	self.node_list["BtnClose1"].button:AddClickListener(BindTool.Bind(self.OnCloseDetail, self))
	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.OnCloseDetail, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnFunc"].button:AddClickListener(BindTool.Bind(self.OpenComposeView, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPanelFightNumber"])

	self:InitDetail()
	self.study_data = nil
	self.shengxiao_list = {}
	local list_delegate = self.node_list["ShengXiaoList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_index = 1

	self.miji_list = {}
	self.begin_index = 1
	self.turn_circle_count = 0
	self.is_rolling = false
	for i = 1, 8 do
		local slot_obj = self.node_list["IconList"].transform:FindHard("Obj" .. i .. "/Slot_1")
		local slot_cell = MijiCell.New(slot_obj)
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.miji_list, slot_cell)
	end

	self.time_space = 1
	self:Flush()
end

function ShengXiaoMijiView:InitDetail()
	self.node_list["PanelDetail"]:SetActive(false)
	self.check_seq = 0
end

function ShengXiaoMijiView:ReleaseCallBack()
	for k, v in ipairs(self.miji_list) do
		v:DeleteMe()
	end
	self.miji_list = {}
	for k, v in ipairs(self.shengxiao_list) do
		v:DeleteMe()
	end
	self.shengxiao_list = {}
	self.fight_text = nil
end

function ShengXiaoMijiView:OpenCallBack()
	self.begin_index = 1
	self:SetShowIndex(1)
	self:Flush()
end

function ShengXiaoMijiView:CloseCallBack()
	self.study_data = nil
	self.node_list["BtnPlus"]:SetActive(true)
	self.node_list["BtnMiji"]:SetActive(false)

	if self.anim_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.anim_countdown)
		self.anim_countdown = nil
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CALC_CAPACITY)
		self.turn_circle_count = 0
		self.time_space = 1
		self.is_rolling = false
		self:ClearSelect()
	end
end

local count = 0
local turn_count = 1
function ShengXiaoMijiView:StarRoller()
	if self.anim_countdown == nil then
		count = 0
		turn_count = self.begin_index
		self.anim_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowAnim, self), 0.04)
	end
end

function ShengXiaoMijiView:FlushDetailView()
	self.node_list["PanelDetail"]:SetActive(true)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.check_seq)
	local item_cfg = ItemData.Instance:GetItemConfig(miji_cfg.item_id)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = miji_cfg.capacity
	end
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(data)
		end
	end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.node_list["TxtPanelName"].text.text = name_str
	self.node_list["TxtPanelAttr1"].text.text = miji_cfg.type_name
	self.node_list["CellPanelItem"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
end

function ShengXiaoMijiView:FlushMijiInfo()
	local miji_data_list = ShengXiaoData.Instance:GetZodiacMijiList(self.list_index)
	local cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.list_index)
	for k, v in ipairs(self.miji_list) do
		local miji_data = {}
		miji_data.value = miji_data_list[k]
		local limit_level = ShengXiaoData.Instance:GetKongIsOpenByIndex(k)
		miji_data.lock_state = cur_level < limit_level
		v:SetData(miji_data)
		self.node_list["ImgActiveList" .. k]:SetActive(miji_data_list[k] >= 0)
	end
end

function ShengXiaoMijiView:FlushShengXiaoList()
	for k,v in pairs(self.shengxiao_list) do
		v:OnFlush()
	end
end

function ShengXiaoMijiView:FlushStudyIcon()
	if self.study_data then
		local item_cfg = ItemData.Instance:GetItemConfig(self.study_data.item_id)
		local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.study_data.cfg_index)
		self.node_list["BtnMiji"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
		self.node_list["Effect"]:ChangeAsset(ResPath.GetMijiEffect(FEECTBYLEVEL[miji_cfg.level]))
	end
end

function ShengXiaoMijiView:OnFlush(param_list)
	self:FlushMijiInfo()
	self:FlushShengXiaoList()
end

function ShengXiaoMijiView:GetNumberOfCells()
	return 12
end

function ShengXiaoMijiView:GetSelectIndex()
	return self.list_index
end

function ShengXiaoMijiView:SetSelectIndex(index)
	self.list_index = index
end

function ShengXiaoMijiView:FlushListHL()
	for k,v in pairs(self.shengxiao_list) do
		v:FlushHL()
	end
end

function ShengXiaoMijiView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local shengxiao_cell = self.shengxiao_list[cell]
	if shengxiao_cell == nil then
		shengxiao_cell = ShengXiaoListItem.New(cell.gameObject)
		shengxiao_cell.root_node.toggle.group = self.node_list["ShengXiaoList"].toggle_group
		shengxiao_cell.shengxiao_miji_view = self
		self.shengxiao_list[cell] = shengxiao_cell
	end

	shengxiao_cell:SetItemIndex(data_index)
	shengxiao_cell:SetData({})
end

function ShengXiaoMijiView:SetShowIndex(index)
	self.begin_index = index

	for i = 1, 8 do
		self.node_list["ImgHightList" .. i]:SetActive(false)
	end
	self.node_list["ImgHightList" .. self.begin_index]:SetActive(true)
end

function ShengXiaoMijiView:ShowAnim()
	count = count + 1
	if turn_count > 1 then
		if turn_count < 9 then
			if count * turn_count < 9 then
				return
			end
		elseif turn_count  > 40 + ShengXiaoData.Instance:GetEndIndex() - 8 and count < 20 then
			if count * (41 + ShengXiaoData.Instance:GetEndIndex() - turn_count) < 9 then
				return
			end
		end
	end
	count = 0
	self.is_rolling = true
	self.time_space = self.time_space - 0.1
	
	if self.begin_index == 8 then
		self.turn_circle_count = self.turn_circle_count + 1
	end
	self:SetShowIndex(self.begin_index + 1 > 8 and 1 or self.begin_index + 1)
	turn_count = turn_count + 1
	if turn_count > 40 and self.begin_index == ShengXiaoData.Instance:GetEndIndex() then
		if self.anim_countdown ~= nil then
			GlobalTimerQuest:CancelQuest(self.anim_countdown)
			self.anim_countdown = nil
		end
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CALC_CAPACITY)
		self.turn_circle_count = 0
		self.time_space = 1
		self.is_rolling = false
		self:ClearSelect()
		self:Flush()
	end
end


function ShengXiaoMijiView:SlotClick(index, cell, data)
	if cell:IsLock() then
		local open_level = ShengXiaoData.Instance:GetKongIsOpenByIndex(index)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.MijiOpen, open_level))
		return
	end
	if data.value < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMiji)
		return
	end
	self.check_seq = data.value
	self:FlushDetailView()
end

function ShengXiaoMijiView:OnClickClose()
	self:Close()
end

function ShengXiaoMijiView:SetStudyData(data)
	self.study_data = data
	self:FlushStudyIcon()
	self.node_list["BtnPlus"]:SetActive(false)
	self.node_list["BtnMiji"]:SetActive(true)
end

function ShengXiaoMijiView:OnClickPlus()
	if self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
		return
	end
	local bag_list = ShengXiaoData.Instance:GetBagMijiList()
	if next(bag_list) then
		ShengXiaoData.Instance:SetMijiShengXiaoIndex(self.list_index)
		ViewManager.Instance:Open(ViewName.MijiBagView)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoBagItem)
	end
end

function ShengXiaoMijiView:ClearSelect()
	self.study_data = nil
	self.node_list["BtnPlus"]:SetActive(true)
	self.node_list["BtnMiji"]:SetActive(false)
end

function ShengXiaoMijiView:OnTakeOffMiji()
	if self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
		return
	end
	self:OnClickPlus()
end

function ShengXiaoMijiView:OnClickStudy()
	if self.study_data ~= nil and self.is_rolling == false then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_PUT_MIJI, self.list_index - 1, self.study_data.cfg_index)
	elseif self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseMijiFirst)
	end
end

function ShengXiaoMijiView:GetIsRolling()
	return self.is_rolling
end

function ShengXiaoMijiView:OnCloseDetail()
	self.node_list["PanelDetail"]:SetActive(false)
end

function ShengXiaoMijiView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(178)
end

function ShengXiaoMijiView:OpenComposeView()
	ViewManager.Instance:Open(ViewName.MiJiComposeView)
end

---------------------ShengXiaoListItem--------------------------------
ShengXiaoListItem = ShengXiaoListItem or BaseClass(BaseCell)

function ShengXiaoListItem:__init()
	self.shengxiao_miji_view = nil
	self.node_list["MijiItem"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function ShengXiaoListItem:__delete()
	self.shengxiao_miji_view = nil
end

function ShengXiaoListItem:SetItemIndex(index)
	self.item_index = index
end

function ShengXiaoListItem:OnFlush()
	self:FlushHL()
	local miji_count = ShengXiaoData.Instance:GetMijiCountByindex(self.item_index)
	local shengxiao_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.item_index)
	local miji_open_cfg = ShengXiaoData.Instance:GetMijiOpenCfgByIndex(self.item_index)

	self.node_list["Txtlevel"]:SetActive(ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))
	self.node_list["TxtOpenCondition"]:SetActive(not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))
	self.node_list["TxtMiJi"]:SetActive(ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))
	self.node_list["ImgIcon"]:SetActive(ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))
	self.node_list["ImgLock"]:SetActive(not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))

	if not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index) then
		local last_miji_count = ShengXiaoData.Instance:GetMijiLimitCount(self.item_index)
		local cfg =  ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index - 1, 1)
		self.node_list["TxtOpenCondition"].text.text = string.format(Language.ShengXiao.NoOpen, self:trim(cfg.name), last_miji_count)
	end
	self.node_list["Txtlevel"].text.text = string.format(Language.ShengXiao.XingZuoLevel, shengxiao_level)
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShengXiaoIcon(self.item_index))
	self.node_list["TxtMiJi"].text.text = string.format(Language.ShengXiao.HaveMijiCount, miji_count)
end

-- 去除字符串两边的空格
function ShengXiaoListItem:trim(s) 
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function ShengXiaoListItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.shengxiao_miji_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end
		if not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index) then
			return
		end
		if self.shengxiao_miji_view:GetIsRolling() then
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
			return
		end
		self.shengxiao_miji_view:SetSelectIndex(self.item_index)
		self.shengxiao_miji_view:FlushListHL()
		self.shengxiao_miji_view:FlushMijiInfo()
	end
end

function ShengXiaoListItem:FlushHL()
	local select_index = self.shengxiao_miji_view:GetSelectIndex()
	self.node_list["ImgHL"]:SetActive(select_index == self.item_index)
end

-----------------------MijiCell---------------------------
MijiCell = MijiCell or BaseClass(BaseRender)
function MijiCell:__init()
	self.lock_state = true
	self.node_list["PanelSlot"].button:AddClickListener(BindTool.Bind(self.Click, self))
end

function MijiCell:__delete()
end

function MijiCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
end

function MijiCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function MijiCell:SetIndex(index)
	self.index = index
end

function MijiCell:GetIndex()
	return self.index
end

-- data里面有个协议发的东西就够了
function MijiCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data
	self.lock_state = self.data.lock_state
	self.node_list["ImgSlot"]:SetActive(data.value >= 0 and not self.lock_state)
	if data.value >= 0 then
		local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(data.value)
		local item_cfg = ItemData.Instance:GetItemConfig(miji_cfg.item_id)
		self.node_list["ImgSlot"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
		self.node_list["Effect"]:ChangeAsset(ResPath.GetMijiEffect(FEECTBYLEVEL[miji_cfg.level]))
	end
	self.node_list["ImgLock"]:SetActive(self.lock_state)
end

function MijiCell:GetData()
	return self.data
end

function MijiCell:IsLock()
	return self.lock_state
end
