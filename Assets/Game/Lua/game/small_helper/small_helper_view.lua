SmallHelperView = SmallHelperView or BaseClass(BaseView)

function SmallHelperView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/smallhelper_prefab", "HelpContent"}
	}	
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.play_audio = true
	self.close_tween = UITween.HideFadeUp
	self.cell_list = {}
	self.bind_gold = 0
	self.gold = 0
end

function SmallHelperView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.SmallHelper.Title
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	local list_delegate = self.node_list["Scroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnAllUse"].button:AddClickListener(BindTool.Bind(self.AllClick, self))
end

function SmallHelperView:__delete()
	if next(self.cell_list) then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil
end

function SmallHelperView:OpenCallBack()
	SmallHelperData.Instance:GetShowConfig()
	RemindManager.Instance:SetRemindToday(RemindName.SmallHelper)
	self:Flush()
end

function SmallHelperView:CloseCallBack()
	SmallHelperCtrl.Instance:FlushIcon()
end

function SmallHelperView:OnFlush()
	self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	local is_finish = self:GetNumberOfCells() <= 0
	self.node_list["AllFinish"]:SetActive(is_finish)
	self.node_list["Cost"]:SetActive(not is_finish)
	UI:SetButtonEnabled(self.node_list["BtnAllUse"], not is_finish)

	self:FlushGoldTxt()
end

--滚动条数量
function SmallHelperView:GetNumberOfCells()
	local info = SmallHelperData.Instance:GetItemData()
	return #info
end

function SmallHelperView:RefreshCell(cell, data_index)
	local index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = SmallHelperCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local data = SmallHelperData.Instance:GetItemData(index)
	-- local is_show = data ~= nil and SmallHelperData.Instance:IsShowBuyTxt(data.complete_type) or false
	cell_item:SetIsShowBuyTxt(true)
	cell_item:SetData(data)
	cell_item:SetFlushCallBack(BindTool.Bind(self.FlushGoldTxt, self))
end

function SmallHelperView:AllClick()
	local bind_pay = self.bind_gold 
	local unbind_pay = self.gold
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local des = ""
	local diff_gold = bind_pay - main_vo.bind_gold
	if diff_gold > 0 then
		des = string.format(Language.SmallHelper.Descripte4, diff_gold) 
		unbind_pay = unbind_pay + diff_gold
		bind_pay = main_vo.bind_gold
	end

	-- if unbind_pay > 0 then
		local ok_func = function()
				if unbind_pay > main_vo.gold then
					TipsCtrl.Instance:ShowLackDiamondView()
				else
					self:SendAllHelp()
				end
			end

	local describe = ""
	if unbind_pay > 0 then
		if bind_pay > 0 then
			describe = string.format(Language.SmallHelper.Descripte1, unbind_pay, bind_pay) 
		else
			describe = string.format(Language.SmallHelper.Descripte2, unbind_pay) 
		end
	else
		describe = string.format(Language.SmallHelper.Descripte3, bind_pay) 
	end
	local str = describe .. des
	if bind_pay > 0 or unbind_pay > 0 then
		SmallHelperData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE)
		TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
	else
		SmallHelperData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE)
		self:SendAllHelp()
	end
	-- else
		-- self:SendAllHelp()
	-- end
	
end

function SmallHelperView:SendAllHelp()
	local save_data = SmallHelperData.Instance:GetAllSaveData()	
	local count = 0
	-- for k, v in pairs(save_data) do
	-- 	if SmallHelperData.Instance:IsCanHelp(k) then
	-- 		count = count + 1
	-- 	end
	-- end
	local task_type_list = {}
	local param_list0 = {}
	local param_list1 = {}
	for k, v in pairs(save_data) do
		local param0 = v.has_times
		local param1 = 0
		if k == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB then
			param1 = v.has_times
			param0 = SmallHelperData.Instance:GetTowerDefendTimes()
		elseif k == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
			param1 = v.has_times
			param0 = 1
		end
		if SmallHelperData.Instance:IsCanHelp(k) then
			-- SmallHelperCtrl.Instance:SendHelperReq(k, param0, param1)
			count = count + 1
			
			task_type_list[count] = k
			param_list0[count] = param0
			param_list1[count] = param1
		end
	end 
	SmallHelperCtrl.Instance:SendReqAll(count, task_type_list, param_list0, param_list1)
	-- SmallHelperCtrl.Instance:SendHelperReq(-1)
end

function SmallHelperView:FlushGoldTxt()
	self.bind_gold = 0
	self.gold = 0
	local save_data = SmallHelperData.Instance:GetAllSaveData()
	for k, v in pairs(save_data) do
		if v ~= nil then
			self.bind_gold = self.bind_gold + v.bind_gold
			self.gold = self.gold + v.gold
		end
	end
	self.node_list["CostBind"].text.text = self.bind_gold
	self.node_list["CostGold"].text.text = self.gold
end

---------------------------------------------------------------
--滚动条格子
SmallHelperCell = SmallHelperCell or BaseClass(BaseCell)

function SmallHelperCell:__init()
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickFindMakeSure, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnAddClick, self))
	self.node_list["BtnDec"].button:AddClickListener(BindTool.Bind(self.OnDecClick, self))
	self.node_list["BtnMax"].button:AddClickListener(BindTool.Bind(self.OnMaxClick, self))
	-- self.node_list["BtnNum"].button:AddClickListener(BindTool.Bind(self.OnClickInputField, self))
	self.bind_gold = 0
	self.gold = 0
	self.has_times = 0
	self.can_buy_times = 0
	self.flush_callback = nil

	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function SmallHelperCell:__delete()
	if next(self.item_cell_list) then
		for k, v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
	end
	self.item_cell_list = nil
	self.flush_callback = nil
end

function SmallHelperCell:SetData(data)
	local save_data = SmallHelperData.Instance:GetSaveData(data.complete_type)
	self.has_times, self.can_buy_times = save_data.has_times, save_data.can_buy_times
	self.data = data

	self:FlushContent()
end

function SmallHelperCell:FlushContent()
	self.node_list["TxtName"].text.text = self.data.type_name
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = main_role_vo.prof or 0
	prof = prof % 10
	local reward_list = self.data["show_item_list_" .. prof] or {}
	for i = 1, 4 do
		local reward_item = reward_list[i - 1]
		self.node_list["ItemCell" .. i]:SetActive(reward_item ~= nil)
		if reward_item ~= nil then
			local item_cfg = ItemData.Instance:GetItemConfig(reward_item.item_id)
			if item_cfg.color > 4 then													--红装才显示星星
				reward_item.noindex_show_xianpin = true
				reward_item.param = {}
				reward_item.param.xianpin_type_list = {}
				if self.data.is_from_extreme > 0 then
					for j = 1, self.data.is_from_extreme do
						reward_item.param.xianpin_type_list[j] = j
					end
				end
			end
		end
		self.item_cell_list[i]:SetData(reward_item)
		
	end
	self:FlushGoldTxt()
end

function SmallHelperCell:SetIsShowBuyTxt(is_show)
	self.node_list["BuyNum"]:SetActive(is_show)
end

function SmallHelperCell:FlushGoldTxt()
	local save_data = SmallHelperData.Instance:GetSaveData(self.data.complete_type)
	self.has_times, self.can_buy_times = save_data.has_times, save_data.can_buy_times
	self.bind_gold, self.gold = save_data.bind_gold, save_data.gold
	self.node_list["TxtBind"].text.text = self.bind_gold
	self.node_list["TxtGold"].text.text = self.gold
	self.node_list["ImgBind"]:SetActive(self.bind_gold > 0)
	self.node_list["ImgGold"]:SetActive(self.gold > 0)
	self.node_list["Num"].text.text = self.has_times
	self.node_list["CanBuy"].text.text = self.can_buy_times
end

function SmallHelperCell:FlushParentTxt()
	if self.flush_callback ~= nil then
		self.flush_callback()
	end
end

function SmallHelperCell:OnAddClick()
	if self.can_buy_times <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.SmallHelper.AddError)
	else
		SmallHelperData.Instance:SetSaveData(self.data.complete_type, 1)
		self:FlushGoldTxt()
		self:FlushParentTxt()
	end
end

function SmallHelperCell:OnDecClick()
	if self.has_times <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.SmallHelper.DecError)
	else
		SmallHelperData.Instance:SetSaveData(self.data.complete_type, 0)
		self:FlushGoldTxt()
		self:FlushParentTxt()
	end
end

function SmallHelperCell:OnMaxClick()
	SmallHelperData.Instance:SetSaveData(self.data.complete_type, 2)
	
	self:FlushGoldTxt()
	self:FlushParentTxt()
end

function SmallHelperCell:SetFlushCallBack(callback)
	self.flush_callback = callback
end

function SmallHelperCell:OnClickInputField()
	local max_num = self.has_times + self.can_buy_times
	local ok_func = function (cur_str)
		self.has_times = tonumber(cur_str)
		self.can_buy_times = max_num - self.has_times
		SmallHelperData.Instance:SaveSetData(self.data.complete_type, self.has_times, self.can_buy_times)
		self:FlushGoldTxt()
		self:FlushParentTxt()
	end
	TipsCtrl.Instance:OpenCommonInputView(self.has_times, ok_func, nil, max_num)
end

function SmallHelperCell:ClickFindMakeSure()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local bind_pay = self.bind_gold 
	local unbind_pay = self.gold
	local des = ""
	local diff_gold = bind_pay - main_vo.bind_gold
	if diff_gold > 0 then
		des = string.format(Language.SmallHelper.Descripte4, diff_gold) 
		unbind_pay = unbind_pay + diff_gold
		bind_pay = main_vo.bind_gold
	end
	-- if main_vo.gold >= unbind_pay then
	local save_data = SmallHelperData.Instance:GetSaveData(self.data.complete_type)
	local param0 = save_data.has_times
	local param1 = 0
	if self.data.complete_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB then
		param1 = save_data.has_times
		-- param0 = param1 / 10
		-- local temp = param1 % 10 
		-- if temp > 0 then
		-- 	param0 = param0 + 1
		-- end
		param0 = SmallHelperData.Instance:GetTowerDefendTimes()
	elseif self.data.complete_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
		param1 = save_data.has_times
		param0 = 1
	end
	local describe = ""
	local ok_func = function()
				if unbind_pay > main_vo.gold then
					TipsCtrl.Instance:ShowLackDiamondView()
				else
					SmallHelperCtrl.Instance:SendHelperReq(self.data.complete_type, param0, param1)
					-- SmallHelperCtrl.Instance:SendHelperReq(-1)
				end
			end


	if unbind_pay > 0 then
		if bind_pay > 0 then
			describe = string.format(Language.SmallHelper.Descripte1, unbind_pay, bind_pay) 
		else
			describe = string.format(Language.SmallHelper.Descripte2, unbind_pay) 
		end
	else
		describe = string.format(Language.SmallHelper.Descripte3, bind_pay) 
	end
	local str = describe .. des
	if param0 > 0 then
		if bind_pay > 0 or unbind_pay > 0 then
			SmallHelperData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE)
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		else
			SmallHelperData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE)
			SmallHelperCtrl.Instance:SendHelperReq(self.data.complete_type, param0, param1)
			-- SmallHelperCtrl.Instance:SendHelperReq(-1)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.SmallHelper.SysError)
	end
	-- else
	-- 	TipsCtrl.Instance:ShowLackDiamondView()
	-- end
end