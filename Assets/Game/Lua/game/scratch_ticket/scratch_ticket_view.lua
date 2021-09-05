ScratchTicketView= ScratchTicketView or BaseClass(BaseView)

local TOUCH_STATE =
{
	DOWN = "down",
	UP = "up"
}

function ScratchTicketView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/scratchticket_prefab", "ScratchTicketView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.is_send = false
	self.stop_update = false
	self.is_modal = true
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ScratchTicketView:Update()
	if self.stop_update then
		return
	end
	--第一次按下
	if self:IsTouchDown() and self.old_touch_state ~= TOUCH_STATE.DOWN  then
		self:OnTouchBegin()
		return
	end

	if self.old_touch_state == TOUCH_STATE.DOWN then
		if self:IsTouchUp() then
			--松手
			self:OnTouchEnd()
		else
			--未松手
			if self.old_touch_state == TOUCH_STATE.DOWN then
				self:OnTouchMove()
				return
			end
		end
	end
end

function ScratchTicketView:IsTouchUp()
	return UnityEngine.Input.GetMouseButtonUp(0)
end

function ScratchTicketView:IsTouchDown()
	return UnityEngine.Input.GetMouseButtonDown(0) or UnityEngine.Input.touchCount > 0 --0是左键
end

function ScratchTicketView:IsInTouchArear()
	if nil == self.cur_uicamera then
		self.cur_uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		self.image_mark_pos = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.cur_uicamera, self.node_list["ImageMark"].transform.position)
	end

	local width = self.node_list["ImageMark"].transform.rect.width
	local height = self.node_list["ImageMark"].transform.rect.height

	local pos_x = self.image_mark_pos.x
	local pos_y = self.image_mark_pos.y

	local mouse_pos = UnityEngine.Input.mousePosition
	local is_in_arear = mouse_pos.x >= (pos_x - width / 2) and mouse_pos.x <= (pos_x + width / 2) 
							and mouse_pos.y >= (pos_y - height / 2) and mouse_pos.y <= (pos_y + height / 2)

	return is_in_arear
end

function ScratchTicketView:OnTouchBegin()
	self.old_touch_state = TOUCH_STATE.DOWN
	self.is_record = false
end

function ScratchTicketView:OnTouchEnd()
	self.old_touch_state = TOUCH_STATE.UP
	self.is_record = false
	--重置遮挡板alpha值
	
end

function ScratchTicketView:OnTouchMove()
	if self:IsInTouchArear() and self.node_list["ImageMark"].canvas_group.alpha > 0 then
		self.node_list["ImageMark"].canvas_group.alpha = self.node_list["ImageMark"].canvas_group.alpha - 0.02
		for i = 1, 3 do
			self.node_list["Image" .. i]:SetActive(false)
		end
		if self.node_list["ImageMark"].canvas_group.alpha <= 0.5 and not self.is_send then
			local function call_back()
				self:ResetView()
			end
			TipsCtrl.Instance:SetTreasureViewCloseCallBack(call_back)
			ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA,
														RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_ONE_TIME)
			self.is_send = true
			self.stop_update = true
		end
	end
end

function ScratchTicketView:ResetView()
	if self.node_list and self.node_list["ImageMark"] then
		self.node_list["ImageMark"].canvas_group.alpha = 1
		for i = 1, 3 do
			self.node_list["Image" .. i]:SetActive(false)
		end
		self.is_send = false
		self.stop_update = false
	end
end

function ScratchTicketView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function ScratchTicketView:LoadCallBack()
	self.gold_num_list = {}
	self.image_list = {}
	self.ScratchTicket_item_list = {}
	self.ScratchTicket_show_list = {}
	self.index_list = {}

	for i = 1, 3 do
		self.gold_num_list[i] = self.node_list["MoneyTxt" .. i]
		self.image_list[i] = self.node_list["Image" .. i]
	end

	self.node_list["ThirtyTimeText"]:SetActive(true)
	self.node_list["Name"].text.text = Language.ScratchTicket.Name
	
	local list_delegate = self.node_list["ShowListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list_delegatet_two = self.node_list["ItemListView"].list_simple_delegate
	list_delegatet_two.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsTwo, self)
	list_delegatet_two.CellRefreshDel = BindTool.Bind(self.RefreshCellTwo, self)

 
	self.node_list["Remind"]:SetActive(false)
	for i = 1, 3 do
		self.node_list["Image" .. i]:SetActive(false)
	end


	--绑定按钮点击事件
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickCangKu, self))
	self.node_list["Button2"].button:AddClickListener(BindTool.Bind(self.OnClickFifty, self))
	self.node_list["Button1"].button:AddClickListener(BindTool.Bind(self.OnClickTen, self))
	self.node_list["LeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["RightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.old_touch_state = TOUCH_STATE.UP
end

--刷新活动剩余时间
function ScratchTicketView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.node_list["TxtActTime"].text.text = TimeUtil.FormatSecond(time, 6)
	else
		self.node_list["TxtActTime"].text.text = TimeUtil.FormatSecond(time, 0)
	end
end

--获取展示格子的数量
function ScratchTicketView:GetNumberOfCells()
	return #ScratchTicketData.Instance:GetGuaGuaCfgByList()
end
--刷新展示格子
function ScratchTicketView:RefreshCell(cell, cell_index)
	local item_cell = self.ScratchTicket_show_list[cell]
	if nil == item_cell then
		item_cell = ScratchTicketViewShwoItem.New(cell.gameObject, self)
		self.ScratchTicket_show_list[cell] = item_cell
	end
	
	local data = ScratchTicketData.Instance:GetGuaGuaCfgByList()
	if data and data[cell_index + 1] then 
		item_cell:SetData(data[cell_index + 1])
	end
end


--获取奖励格子的数量
function ScratchTicketView:GetNumberOfCellsTwo()
	return GetListNum(ScratchTicketData.Instance:GetReturnReward())
end
--刷新奖励格子
function ScratchTicketView:RefreshCellTwo(cell, cell_index)
	local item_cell = self.ScratchTicket_item_list[cell]
	if nil == item_cell then
		item_cell = ScratchTicketViewItem.New(cell.gameObject, self)
		self.ScratchTicket_item_list[cell] = item_cell
	end
	-- local data = ScratchTicketData.Instance:GetGuaGuaRewardCfg()
	local data = ScratchTicketData.Instance:GetReturnReward()
	item_cell:SetIndex(cell_index + 1)
	item_cell:SetData(data[cell_index + 1])
end

--打开界面的回调
function ScratchTicketView:OpenCallBack()   
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_QUERY_INFO)
	self:Flush()
	Runner.Instance:AddRunObj(self, 16)

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	self:PlayerDataChangeCallback()
end

-- 元宝
function ScratchTicketView:PlayerDataChangeCallback(key, new_value, old_value)
	if key == "gold" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local cost = nil
		local guagua_config = ScratchTicketData.Instance:GetGuaGuaLeCfg()
		if guagua_config then
			local gold_config = guagua_config.other
			if gold_config then 
				cost = gold_config[1].guagua_once_gold
			end
		end
		if cost and vo.gold >= cost and not self.is_send then
			self.is_send = false
			self.stop_update = false
		end
	end
end

--关闭界面的回调
function ScratchTicketView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	Runner.Instance:RemoveRunObj(self)
end

--关闭界面释放回调
function ScratchTicketView:ReleaseCallBack()
	self.gold_num_list = {}
	self.image_list = {}
	self.index_list = {}
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	for k, v in pairs(self.ScratchTicket_item_list) do
		v:DeleteMe()
	end
	self.ScratchTicket_item_list = {}

	for k,v in pairs(self.ScratchTicket_show_list) do
		v:DeleteMe()
	end
	self.ScratchTicket_item_list = {}

	self.cur_uicamera = nil
end

function ScratchTicketView:ItemDataChangeCallback()
	self:Flush()
end

--刷新
function ScratchTicketView:OnFlush(param_list)
	-- 刷新钥匙
	local item_num = ScratchTicketData.Instance:GetThirtyKeyNum()
	self.node_list["ThirtyTimeText"]:SetActive(item_num <= 0)
	self.node_list["KeyLable"]:SetActive(item_num > 0)
	self.node_list["Remind"]:SetActive(item_num > 0)

	local item_id = ScratchTicketData.Instance:GetThirtyKeyItemID()
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	local asset, bundle = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgItem"].image:LoadSprite(asset, bundle)
	self.node_list["KeyTxtCount"].text.text = Language.Common.X .. item_num	

	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local cfg = ScratchTicketData.Instance:GetGuaGuaLeCfg()
	--读取配置表中的元宝数量
	if cfg then
		local gold_config_other = cfg.other
		if gold_config_other then 
			self.gold_num_list[1].text.text = gold_config_other[1].guagua_once_gold
			self.gold_num_list[2].text.text = gold_config_other[2].guagua_tentimes_gold
			self.gold_num_list[3].text.text = gold_config_other[3].guagua_thirtytimes_gold
		end
	end
	
	local num = ScratchTicketData.Instance:GetGuaGuaCount()
	self.node_list["CiShuTxt"].text.text = string.format(Language.ScratchTicket.LeiJi, num)
	--刮奖面板-------------------------------------------------------------------------------------------------------
	self.index_list = ScratchTicketData.Instance:GetGuaGuaIndex()
	local guagua_config = ScratchTicketData.Instance:GetGuaGuaCfg()
	if guagua_config == nil then
		return 
	end
	 
	local config_list = ListToMap(guagua_config,"seq") 
	if config_list == nil then
		return
	end

	if self.index_list and next(self.index_list) then
		local aaa = {}
		for i=1,3 do
			aaa["bundle"..i],aaa["asset"..i] = ResPath.GetScratchTicketRes("wuxing_0" .. config_list[self.index_list[0]]["icon" .. i .. "_id"] + 1)
			self.image_list[i].image:LoadSprite(aaa["bundle"..i],aaa["asset"..i])
		end
	end

	for i = 1, 3 do
		self.node_list["Image" .. i]:SetActive(true)
	end
	--刷新
	self.node_list["ItemListView"].scroller:ReloadData(0)

end


function ScratchTicketView:OnClickCangKu()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end


function ScratchTicketView:OnClickTen()
	ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_TEN_TIMES)
	self:ResetView()
end

function ScratchTicketView:OnClickFifty()
	ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_THIRTY_TIMES)
	self:ResetView()
end

function ScratchTicketView:OnClickLastButton()
	self.node_list["ItemListView"].scroll_rect.horizontalNormalizedPosition = 0
end

function ScratchTicketView:OnClickNextButton()
	self.node_list["ItemListView"].scroll_rect.horizontalNormalizedPosition = 1
end

function ScratchTicketView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
end

---------------------------------ScratchTicketViewItem（奖励格子）----------------------------------
ScratchTicketViewItem = ScratchTicketViewItem or BaseClass(BaseCell)
--初始化
function ScratchTicketViewItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:ShowHighLight(false)
end
--奖励格子的界面关闭回调
function ScratchTicketViewItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ScratchTicketViewItem:SetIndex(index)
	self.index = index
end

function ScratchTicketViewItem:OnFlush()
	if self.data == nil  then return end
	
	self.item_cell:SetData(self.data.cfg.reward_item[0])
	self.node_list["Text"].text.text = string.format(Language.ScratchTicket.LeiJi2, self.data.cfg.acc_count)
	-- self.item_cell:ShowGetEffectTwo(false)
	local count = ScratchTicketData.Instance:GetGuaGuaCount() or 0
	-- local flag = ScratchTicketData.Instance:GetCanFetchFlag(self.index)
	local flag = self.data.fetch_flag == 1
	if count >= self.data.cfg.acc_count and not flag then
		self.node_list["Effect"]:SetActive(true)
		self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
	else
		self.node_list["Effect"]:SetActive(false)
		self.item_cell:ListenClick()
	end

	self.node_list["ImgMask"]:SetActive(flag)

end
--点击奖励物品事件
function ScratchTicketViewItem:OnClick()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPREA_TYPE_FETCH_REWARD, self.data.cfg.index)
end

---------------------------------ScratchTicketViewShwoItem（展示格子）----------------------------------
ScratchTicketViewShwoItem = ScratchTicketViewShwoItem or BaseClass(BaseCell)
function ScratchTicketViewShwoItem:__init()
	self.image_list = {}
	for i=1,3 do
		self.image_list[i] = self.node_list["Image" .. i]
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["itemCell"])
end

function ScratchTicketViewShwoItem:__delete()
	self.image_list = {}
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ScratchTicketViewShwoItem:OnFlush()
	if self.data == nil  then return end
	if self.data.is_special == 1 then
		for i = 1, 3 do
			local bundle, asset = ResPath.GetScratchTicketRes("wuxing_0" .. self.data["icon" .. i .. "_id"] + 1)
			self.image_list[i].image:LoadSprite(bundle, asset)
		end
		self.item_cell:SetData(self.data.reward_item[0])
	end 
end