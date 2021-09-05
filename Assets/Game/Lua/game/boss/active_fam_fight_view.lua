ActiveFamFightView = ActiveFamFightView or BaseClass(BaseView)
local TIRED_ITEM_ID = 24859 				--简单疲劳卡
local FLUSH_ITEM_ID = 24605 				--BOSS刷新卡
function ActiveFamFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "ActiveFamFightView"}}
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.item_t = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function ActiveFamFightView:__delete()

end

function ActiveFamFightView:ReleaseCallBack()
	if BossData.Instance then
		BossData.Instance:RemoveListener(BossData.ACTIVE_BOSS, self.dabao_info_event)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
	-- 清理变量和对象
end

function ActiveFamFightView:LoadCallBack()
	self.node_list["BtnTeam"].toggle.onValueChanged:AddListener(BindTool.Bind(self.BossClick, self))
	self.node_list["BtnTask"].toggle.onValueChanged:AddListener(BindTool.Bind(self.BossClick, self))
	self.node_list["TiredCard"].button:AddClickListener(BindTool.Bind(self.ClickTiredCard, self))
	self.node_list["FlushCard"].button:AddClickListener(BindTool.Bind(self.ClickFlushCard, self))
	-- self.node_list["Btn_rank"].button:AddClickListener(BindTool.Bind(self.OnClickOpenActiveBossDpsRankView, self))
	BossData.Instance:AddListener(BossData.ACTIVE_BOSS, self.dabao_info_event)
	self.rank_view = ActiveBossRankView.New(self.node_list["ScoreRank"])
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	local item_cfg = ItemData.Instance:GetItemConfig(TIRED_ITEM_ID)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ImgCardIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgCardIcon"].image:SetNativeSize()
		end)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(FLUSH_ITEM_ID)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ImgFlushCardIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgFlushCardIcon"].image:SetNativeSize()
		end)
	end
end

function ActiveFamFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function ActiveFamFightView:ClickTiredCard()
	local data = ItemData.Instance:GetItem(TIRED_ITEM_ID)
	local item_cfg = ItemData.Instance:GetItemConfig(TIRED_ITEM_ID)
	local des = ""
	if data and item_cfg then
		local name = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"
		des = string.format(Language.Boss.IsUseTiredCard, name)
		local func = function()
			PackageCtrl.Instance:SendUseItem(data.index, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	end
end

function ActiveFamFightView:ClickFlushCard()
	local scene_id = Scene.Instance:GetSceneId()
	BossData.Instance:UseFlushCard(scene_id)
end

function ActiveFamFightView:BossClick(is_click)
	if is_click then
		self:Flush()
	end
end

function ActiveFamFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end
end

function ActiveFamFightView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	local item_num = ItemData.Instance:GetItemNumInBagById(TIRED_ITEM_ID)
	self.node_list["TiredCard"]:SetActive(item_num > 0 and BossData.Instance:IsActiveBossScene(scene_id))
	local item_num_2 = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	self.node_list["FlushCard"]:SetActive(item_num_2 > 0 and BossData.Instance:IsActiveBossScene(scene_id))

	self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)

	local info = nil
	info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
	if info then
		local callback = function()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end

	if info then
		local list = self:GetDataList()
		if list then
			for k,v in pairs(list) do
				if info.bossID == v.bossID then
					self.cur_index = k
					self.select_boss_id = v.bossID
				end
			end
		end
	end

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller then
		if self.cur_index and self.cur_index > 1 then
			self.node_list["TaskList"].scroller:ReloadData(self.cur_index / #self:GetDataList())
		else
			self.node_list["TaskList"].scroller:ReloadData(0)
		end
	end
end

function ActiveFamFightView:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == TIRED_ITEM_ID then
		local scene_id = Scene.Instance:GetSceneId()
		self.node_list["TiredCard"]:SetActive(new_num > 0 and BossData.Instance:IsActiveBossScene(scene_id))
	elseif item_id == FLUSH_ITEM_ID then
		local scene_id = Scene.Instance:GetSceneId()
		self.node_list["FlushCard"]:SetActive(new_num > 0 and BossData.Instance:IsActiveBossScene(scene_id))
	end
end

function ActiveFamFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["TaskParent"]:SetActive(state)
end

function ActiveFamFightView:OnFlush(param_t)
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.rank_view then
		self.rank_view:Flush()
	end

	local max_wearry = BossData.Instance:GetActiveBossMaxWeary()
	local weary = max_wearry - BossData.Instance:GetActiveBossWeary()
	local pi_lao_text = ""
	if weary <= 0 then
		-- self.node_list["Text_tip"].text.text = Language.Boss.NoWearyTip 
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
	else
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.GREEN)
	end
	self.node_list["Text_tip"]:SetActive(weary <= 0)
	local max_text = ToColorStr(tostring(max_wearry), TEXT_COLOR.GREEN)
	self.node_list["TextWeary"].text.text = string.format(Language.Boss.ActiveBossPiLaoValue, pi_lao_text .. " / " .. max_text)

	local num = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	local scene_id = Scene.Instance:GetSceneId()
	self.node_list["FlushCard"]:SetActive(num > 0 and BossData.Instance:IsActiveBossScene(scene_id))

	local num2 = ItemData.Instance:GetItemNumInBagById(TIRED_ITEM_ID)
	self.node_list["TiredCard"]:SetActive(num2 > 0 and BossData.Instance:IsActiveBossScene(scene_id))
end

function ActiveFamFightView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function ActiveFamFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = ActiveBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function ActiveFamFightView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	return BossData.Instance:GetActiveBossList(scene_id)
end

function ActiveFamFightView:GetCurIndex()
	return self.cur_index
end

function ActiveFamFightView:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function ActiveFamFightView:SetCurIndex(index)
	self.cur_index = index
end

function ActiveFamFightView:GetCurBossId()
	return self.select_boss_id
end

function ActiveFamFightView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

function ActiveFamFightView:OnClickOpenActiveBossDpsRankView()
	ViewManager.Instance:Open(ViewName.ActiveBossRankRewardView)
end

function ActiveFamFightView:SetIsActiveBossRange(is_active)
	if self.node_list["BtnTeam"] == nil or self.node_list["BtnTask"] == nil then
		return
	end
	-- self.node_list["Btn_rank"]:SetActive(is_active)
	self.node_list["BtnTeam"].toggle.isOn = is_active
	self.node_list["BtnTask"].toggle.isOn = not is_active

end

----------------------------打宝bossItem
ActiveBossItem = ActiveBossItem or BaseClass(BaseRender)

function ActiveBossItem:__init(instance, parent)

	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function ActiveBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
end

function ActiveBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.bossID)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 0, 0)
	self.parent:FlushAllHl()
	return
end

function ActiveBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function ActiveBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = BossData.Instance:GetActiveBossList(scene_id)
	for k,v in pairs(boss_info) do
		if v.bossID == boss_id then
			return v
		end
	end
end

function ActiveBossItem:SetItemIndex(index)
	self.index = index
end

function ActiveBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		self.node_list["TextLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
	end
	self.node_list["Desc"].text.text = self.data.scene_show
	local boss_data = self:GetBossData(self.data.bossID)
	if boss_data then
		self.flush_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
		self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
		if self.flush_time <= 0 then
			self.time = Language.Boss.CanKill
			self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
		else
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
	end
	self:FlushHl()
end

function ActiveBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.bossID)
	end
end

function ActiveBossItem:OnBossUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = Language.Boss.CanKill
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
	else
		self.time = TimeUtil.FormatSecond(time)
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
	end
end

----------------------排行View----------------------
ActiveBossRankView = ActiveBossRankView or BaseClass(BaseRender)
function ActiveBossRankView:__init()
	-- 获取控件
	self.rank_data_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function ActiveBossRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function ActiveBossRankView:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function ActiveBossRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = ActiveBossRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function ActiveBossRankView:OnFlush()
	local info = BossData.Instance:GetActiveBossPersonalHurtInfo()
	if info.my_rank > 0 and info.my_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(info.my_rank)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["rank"].text.text = (info.my_rank > 5 or info.my_rank == 0) and Language.Boss.NotOnRank or info.my_rank
		self.node_list["rank"]:SetActive(true)
		self.node_list["Img_rank"]:SetActive(false)
	end
	self.node_list["name"].text.text = PlayerData.Instance.role_vo.name
	self.node_list["hurt"].text.text = CommonDataManager.ConverMoney2(info.my_hurt)
	self.rank_data_list = info.rank_list
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

ActiveBossRankItem = ActiveBossRankItem or BaseClass(BaseRender)

function ActiveBossRankItem:__init()
end

function ActiveBossRankItem:SetIndex(index)
	if index <= 3 then
		local bundle, asset = ResPath.GetRankIcon(index)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"]:SetActive(true)
		self.node_list["rank"].text.text = index
	end
end

function ActiveBossRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function ActiveBossRankItem:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["name"].text.text = self.data.name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt)
end