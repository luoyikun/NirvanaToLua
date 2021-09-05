ShenGeZhangKongView = ShenGeZhangKongView or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	[0] = -135,
	[1] = 135,
	[2] = -50,
	[3] = 50,
}

local ATTR_NAME = {
	["gongji_pro"] = "gong_ji",
	["fangyu_pro"] = "fang_yu",
	["maxhp_pro"] = "max_hp",
	["shanbi_pro"] = "shan_bi",
	["baoji_pro"] = "bao_ji",
	["kangbao_pro"] = "jian_ren",
	["mingzhong_pro"] = "mingzhong_pro",
}
local MOVE_TIME = 0.5
function ShenGeZhangKongView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-500, 0, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right1"], Vector3(600 , 0 , 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right2"], Vector3(0 , 150 , 0), MOVE_TIME)
	--UITween.MoveShowPanel(self.node_list["MiddleContent"] , Vector3(0 , -100 , 0 ) , 0.4 )
	UITween.AlpahShowPanel(self.node_list["MiddleUp"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["MiddleUp"], Vector3(0, -50 , 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleDown"], Vector3(0, -100, 0), MOVE_TIME)
	UITween.ScaleShowPanel(self.node_list["MiddleScale"], Vector3(0.8, 0.8, 0.8), MOVE_TIME)
end

function ShenGeZhangKongView:__init(instance)
	self.bullet_count = 0
	self.is_tence = false
	self.cur_precent = nil
	self.shenge_cell = {}
	self.time_quest = {}
	self.bullet_list = {}
	self.bullet_active_list ={}
	for i = 1, 4 do
		if self.shenge_cell[i] == nil then
			self.shenge_cell[i] = ShenGeZhangKongCell.New(self.node_list["ShengeCell" .. i], i)
			self.shenge_cell[i]:OnFlush()
			self.shenge_cell[i]:SetIconClickListener(BindTool.Bind(self.SetSelectIndex, self, i - 1))
		end
	end

	--self.node_list["PlayAniToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self.node_list["TenceToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnTenceToggleChange, self))

	self.node_list["BtnCenter"].button:AddClickListener(BindTool.Bind(self.OnClickGo, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	--self.node_list["BtnCost"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	self.node_list["BtnCenter"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.HandleCenterStart, self))
	self.node_list["BtnCenter"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.HandleCenterStop, self))
	self.node_list["ButtonShouGou"].button:AddClickListener(BindTool.Bind(self.OnButtonShouGou, self))
	self:SetNotifyDataChangeCallBack()

	self:Flush()
	self:AutoSelectIndex()
	if nil == self.select_index then
		self:SetSelectIndex(3)
	end
end

function ShenGeZhangKongView:SetSelectIndex(index)
	self.select_index = index
	if nil == self.time_quest_auto then
		self.is_select_click = true
	end
	local angle = POINTER_ANGLE_LIST[self.select_index]
	self.node_list["CenterPointer"].transform.localRotation = Quaternion.Euler(0, 0, angle)
	for i = 1, 4 do
		self.shenge_cell[i]:SetIsShowSelectIcon(index == i - 1)
	end
end

function ShenGeZhangKongView:HandleCenterStart()
	self.set_toggle = GlobalTimerQuest:AddDelayTimer(function()
			-- self.node_list["PlayAniToggle"].toggle.isOn = true
			if nil == self.time_quest_auto then
				self.time_quest_auto = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnClickGo, self ), 0.2)
			end
		end, 0.5)
end

function ShenGeZhangKongView:OnButtonShouGou()
	MarketData.Instance:SetPurchaseItemId(9)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 9})
end

function ShenGeZhangKongView:HandleCenterStop()
	if self.set_toggle then
		GlobalTimerQuest:CancelQuest(self.set_toggle)
		self.set_toggle = nil
	end
	if self.time_quest_auto then 
		GlobalTimerQuest:CancelQuest(self.time_quest_auto)
	end
	self.time_quest_auto = nil
end

function ShenGeZhangKongView:OpenCallBack()
end

function ShenGeZhangKongView:__delete()
	self.bullet_list = {}
	self.bullet_active_list = {}
	for k,v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
	self:RemoveNotifyDataChangeCallBack()
	for i = 1, 4 do 
		if self.shenge_cell[i] ~= nil then 
			self.shenge_cell[i]:DeleteMe()
			self.shenge_cell[i] = nil
		end
	end

	-- if self.time_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- 	self.time_quest = nil
	-- end

	if self.changed_data then
		self.changed_data:DeleteMe()
	end
	self.cur_precent = nil
	if self.time_quest_auto then 
		GlobalTimerQuest:CancelQuest(self.time_quest_auto)
	end
	--self.time_quest = nil
end

function ShenGeZhangKongView:AutoSelectIndex()
	local cfg = ShenGeData.Instance:GetShenGeDataUplevelGridCfg()
	local is_select_index_max = ShenGeData.Instance:IsZhangkongMaxLevelByIndex(self.select_index)
	if nil == self.select_index or ItemData.Instance:GetItemNumInBagById(cfg[self.select_index].item_id) <= 0 or is_select_index_max then
		for i = 3, 0, -1 do
			local is_max = ShenGeData.Instance:IsZhangkongMaxLevelByIndex(i)
			if not self.is_select_click and not is_max then
				local item_count = ItemData.Instance:GetItemNumInBagById(cfg[i].item_id)
				if item_count > 0 then
					self:SetSelectIndex(i)
					return true
				end
			else
				self.is_select_click = false
			end
		end
	end
	return false
end

function ShenGeZhangKongView:OnClickGo()
	-- if not ShenGeData.Instance:GetShenGeZhangKongState() then
	-- 	return
	-- end
	--ShenGeData.Instance:SetZhangkongIsRolling(true, self.node_list["BtnCenter"])
	-- self:SetItemNum()
	-- local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	-- local buy_num = 1
	-- if self.is_tence == true then 
	-- 	buy_num = 10
	-- end
	-- if ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num and not is_auto_buy_toggle then
	-- 	-- 物品不足，弹出TIP框
	-- 	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	-- 	if item_cfg == nil then
	-- 		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
	-- 		-- self:SetItemNum()
	-- 		return
	-- 	end
	-- 	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
	-- 		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	-- 		if is_buy_quick then
	-- 			self.node_list["AutoToggle"].toggle.isOn = true
	-- 		end
	-- 	end
	-- 	if self.is_tence == true then
	-- 		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, buy_num - ItemData.Instance:GetItemNumInBagById(self.item_id))
	-- 	else
	-- 		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	-- 	end
	-- 	-- self:SetItemNum()
	-- 	ShenGeData.Instance:SetZhangkongIsRolling(false, self.node_list["BtnCenter"])
	-- 	return
	-- end
	if self:AutoSelectIndex() then
		return
	end

	if ShenGeData.Instance:IsZhangkongAllMaxLevel() then
		self:ShowMaxText()
		--ShenGeData.Instance:SetZhangkongIsRolling(false, self.node_list["BtnCenter"])
		return
	end
	--self:ResetVariable()
	--ShenGeData.Instance:SetZhangkongAniState(self.node_list["PlayAniToggle"].toggle.isOn)
	--if self.is_tence ~= nil then
		--ShenGeData.Instance:SetShenGeZhangKongState(false)
		--if self.is_tence == false then
	local cfg = ShenGeData.Instance:GetShenGeDataUplevelGridCfg()
	local item_id = cfg[self.select_index].item_id
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengeZhangkong.NotNeedItem)
		return
	end
	if self.select_index then
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG, self.select_index, 1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.ShengeZhangkong.NoSelectZhangkong)
	end
		--else
			--ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG, 1)
		--end
	--end
end

-- function ShenGeZhangKongView:OnToggleChange(is_on)
-- 	ShenGeData.Instance:SetZhangkongAniState(is_on)
-- end

-- function ShenGeZhangKongView:SetItemNum()
-- 	self.item_id = ShenGeData.Instance:GetZhangkongItemID()
-- 	local item_amount_val = ItemData.Instance:GetItemNumInBagById(self.item_id)
-- 	local item_amount_str = ""

-- 	self.node_list["TxtCost"].text.text = string.format("%s / 1", item_amount_val)
-- 	if item_amount_val == 0 then
-- 		item_amount_str = ToColorStr(item_amount_val, TEXT_COLOR.RED_4)
-- 	else
-- 		item_amount_str = ToColorStr(item_amount_val, TEXT_COLOR.GREEN_4)
-- 	end
-- 	self.node_list["TxtCost"].text.text = string.format("%s / 1", item_amount_str)
-- 	local color = ITEM_COLOR[ItemData.Instance:GetItemConfig(self.item_id).color]

-- 	self.node_list["BtnCost"].image:LoadSprite(ResPath.GetItemIcon(self.item_id))
-- 	if self.node_list["BtnCost"].image ~= nil then
-- 		self.node_list["BtnCost"].image:SetNativeSize()
-- 	end
-- end

function ShenGeZhangKongView:OnTenceToggleChange(is_on)
	self.is_tence = is_on
end

function ShenGeZhangKongView:DataFlush()
	local changed_data = ShenGeData.Instance:GetZhankongSingleChangeInfo()
	local is_level_up = true
	if changed_data ~= nil then 
		self:ResetVariable()
		self:SaveVariable(changed_data)
		if changed_data.level == ShenGeData.Instance:GetZhangkongInfoByGrid(changed_data.grid).level then
			is_level_up = false
		end
		--self:TurnPointer(is_level_up)
		self:PlayEffect(is_level_up)
	end
end

-- function ShenGeZhangKongView:TurnPointer(is_level_up)
-- 	local angle = POINTER_ANGLE_LIST[self.changed_data.grid]
-- 	if self.node_list["PlayAniToggle"].toggle.isOn == false then
-- 		ShenGeData.Instance:SetZhangkongIsRolling(true, self.node_list["BtnCenter"])
-- 		local time = 0
-- 		local tween = self.node_list["CenterPointer"].transform:DORotate(
-- 			Vector3(0, 0, -360 * 20),
-- 			20,
-- 			DG.Tweening.RotateMode.FastBeyond360)
-- 		tween:SetEase(DG.Tweening.Ease.OutQuart)
-- 		tween:OnUpdate(function ()
-- 			time = time + UnityEngine.Time.deltaTime
-- 			if time >= 1 then
-- 				tween:Pause()
-- 				local tween1 = self.node_list["CenterPointer"].transform:DORotate(
-- 						Vector3(0, 0, -360 * 3 + angle),
-- 						2,
-- 						DG.Tweening.RotateMode.FastBeyond360)
-- 				tween1:OnComplete(function ()
-- 					self:PlayEffect(is_level_up)
-- 				end)
-- 			end
-- 		end)
-- 	else
-- 		self.node_list["CenterPointer"].transform.localRotation = Quaternion.Euler(0, 0, angle)
-- 		self:PlayEffect(true)
-- 		--ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
-- 		-- self:ShowFlyText()
-- 		ShenGeData.Instance:SetZhangkongIsRolling(false, self.node_list["BtnCenter"])
-- 	end
-- end

function ShenGeZhangKongView:ShowLightEffect()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
end

function ShenGeZhangKongView:GridFlush()
	-- if ShenGeData.Instance:GetZhangkongIsRolling() then 
	-- 	return
	-- end
	local data_list = {}
	for i = 1, 4 do
		if self.shenge_cell[i] ~= nil then
			data_list[i] = ShenGeData.Instance:GetZhangkongInfoByGrid(i - 1)
			self.shenge_cell[i]:OnSingleDataChange(data_list[i], self.node_list["PlayAniToggle"].toggle.isOn)
		end
	end
end

function ShenGeZhangKongView:OnFlush(param_list)
	self:GridFlush()
	--self:SetCost()
	-- self:SetItemNum()
	for i = 1, 4 do
		if self.shenge_cell[i] ~= nil then
			self.shenge_cell[i]:OnFlush()
		end
	end

end

function ShenGeZhangKongView:SetCost()
	local cost = ShenGeData.Instance:GetZhangkongCost()
end

function ShenGeZhangKongView:SaveVariable(data)
	self.changed_data = data
end

function ShenGeZhangKongView:ResetVariable()
	if self.changed_data ~= nil then
		self.changed_data = nil
	end
end

function ShenGeZhangKongView:ShowZidan()
	self.node_list["Zidan"]:SetActive(true)
end

function ShenGeZhangKongView:ResetZidan()
	self.node_list["Zidan"]:SetActive(false)
	self.node_list["Zidan"].transform.position = self.node_list["StartPoint"].transform.position
end

function ShenGeZhangKongView:GetBulletObj()
	return next(self.bullet_list) == nil and true or false
end

function ShenGeZhangKongView:PlayEffect(is_level_up)
	local attach = self.node_list["Zidan"].gameObject:GetComponent(typeof(Game.GameObjectAttach))
	local bundle_name = attach.BundleName
	local asset_name = attach.AssetName
	if self:GetBulletObj() then 
		local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
		res_async_loader:Load(bundle_name, asset_name, nil, function(obj)
			if nil == obj then
				return
			end
			local obj = ResMgr:Instantiate(obj)
			self.bullet_count = self.bullet_count + 1
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["ZiDanParent"].transform, false)
			self:BulletMove(obj)
		end)
	else
		--print_error(next(self.bullet_list) , self.bullet_list)
		for k,v in pairs(self.bullet_list) do
			self:BulletMove(v)
			return
		end
		--self:BulletMove(self.bullet_list[1])
	end
end

function ShenGeZhangKongView:BulletMove(obj)
	obj.transform.position = self.node_list["StartPoint"].transform.position
	obj:SetActive(true)
	self.bullet_list[obj] = nil
	self.bullet_active_list[obj] = obj
	local close_view = function ()
		self.bullet_active_list[obj] = nil
		self.bullet_list[obj] = obj
		self.bullet_count = self.bullet_count - 1
		obj:SetActive(false)
		GlobalTimerQuest:CancelQuest(self.time_quest[obj])
		self.time_quest[obj] = nil
		if self.collective_flag then
			self:Close()
		end
		ShenGeData.Instance:SetZhangkongIsRolling(false, self.node_list["BtnCenter"])
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
	end

	self.time_quest[obj] = GlobalTimerQuest:AddDelayTimer(function()
			if nil == self.changed_data then return end

			local path = {}
			local timer = 0.5
			local item = obj
			table.insert(path, self.node_list["StartPoint"].transform.position)
			table.insert(path, self.shenge_cell[self.changed_data.grid + 1]:GetCellPoint().transform.position)
			self.tweener = item.transform:DOPath(path, timer, DG.Tweening.PathType.Linear, DG.Tweening.PathMode.TopDown2D, 1, nil)
			self.tweener:SetEase(DG.Tweening.Ease.Linear)
			self.tweener:SetLoops(0)
			self.tweener:OnComplete(close_view)
		end, 0)
end
--[[
-- function ShenGeZhangKongView:PlayEffect(is_level_up)
-- 	local close_view = function ()
-- 		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
-- 		self:ResetZidan()
-- 		-- self:ShowFlyText()
-- 		if is_level_up == false then
-- 			ShenGeData.Instance:SetZhangkongIsRolling(false)
-- 		end
-- 		GlobalTimerQuest:CancelQuest(self.time_quest)
-- 		self.time_quest = nil
-- 		if self.collective_flag then
-- 			self:Close()
-- 		end
-- 		ShenGeData.Instance:SetZhangkongIsRolling(false)
-- 	end
-- 	if nil ~= self.tweener then 
-- 		close_view()
-- 		self.tweener:Kill()
-- 	end
-- 	self:ShowZidan()
-- 	local timer = 0.5

-- 	if self.time_quest then
-- 		GlobalTimerQuest:CancelQuest(self.time_quest)
-- 		self.time_quest = nil
-- 	end

-- 	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
-- 		if nil == self.changed_data then return end
-- 		local path = {}
-- 		local item = self.node_list["Zidan"]
-- 		table.insert(path, self.node_list["StartPoint"].transform.position)
-- 		table.insert(path, self.shenge_cell[self.changed_data.grid + 1]:GetCellPoint().transform.position)
-- 		self.tweener = item.transform:DOPath(
-- 			path,
-- 			timer,
-- 			DG.Tweening.PathType.Linear,
-- 			DG.Tweening.PathMode.TopDown2D,
-- 			1,
-- 			nil)
-- 		self.tweener:SetEase(DG.Tweening.Ease.Linear)
-- 		self.tweener:SetLoops(0)
-- 		self.tweener:OnComplete(close_view)
-- 	end, 0)
-- end

-- function ShenGeZhangKongView:OnClickItem()
-- 	TipsCtrl.Instance:OpenItem({item_id = self.item_id})
-- end
--]]
function ShenGeZhangKongView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
			self.item_data_event = nil
		end
	end
end

function ShenGeZhangKongView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShenGeZhangKongView:ItemDataChangeCallback(item_id)
	local shen_data = LingRenData.Instance
	if item_id == ShenBingDanId.ZiZhiDanId then
		return
	end

	local item_id_list = {}
	for i = 1, 3 do
		if self.item_id ~= nil and item_id == self.item_id then
			self:Flush()
			return
		end
	end
end

function ShenGeZhangKongView:OnMoveEnd(obj)
	if not IsNil(obj) then
		ResMgr:Destroy(obj)
	end
end

function ShenGeZhangKongView:ShowMaxText()
	SysMsgCtrl.Instance:ErrorRemind(Language.ShengeZhangkong.AllLevelMax,1)
end

function ShenGeZhangKongView:QuestionClick()
	local tips_id = 189 
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------------
ShenGeZhangKongCell = ShenGeZhangKongCell or BaseClass(BaseCell)
function ShenGeZhangKongCell:__init(instance, index)
	self:CellInit(index)
	self.effect_cd = 0

	local cfg = ShenGeData.Instance:GetShenGeDataUplevelGridCfg()
	self.item_id = cfg[self.grid].item_id
	self.node_list["ImgCost"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])
end

function ShenGeZhangKongCell:CellInit(index)
	self.type = ""
	self.shenge_pro = ""
	self.grid = index - 1
end

function ShenGeZhangKongCell:__delete()
	self.fight_text = nil
	self:RemoveSliderTween()
	self.effect_cd = 0
end

function ShenGeZhangKongCell:GetCellPoint()
	return self.node_list["StartPoint"]
end

function ShenGeZhangKongCell:GetTextPosition()
	return self.node_list["TextPos"]
end

function ShenGeZhangKongCell:GetEndPoint(level)
	local index = level % 5
	if index == 0 then 
		index = 5
	end
	return self.node_list["Star" .. index]
end

function ShenGeZhangKongCell:SetExpValue(cur_exp, max_exp, is_level_change, is_tween, callback)
	if ShenGeData.Instance:IsZhangkongMaxLevelByIndex(self.grid) then
		self.node_list["Slider"].slider.value = 1
		return
	end
	if self.level ~= nil then
		if self.level < 200 then
			if (cur_exp ~= self.cur_exp or self.level ~= self.data.level) and self.node_list["BoomEffect"].gameObject.activeInHierarchy == false and self.cur_exp ~= nil then 
				local start_time = 0.2
				GlobalTimerQuest:AddDelayTimer(function()
					local attach = self.node_list["BoomEffect"].gameObject:GetComponent(typeof(Game.GameObjectAttach))
					local bundle_name = attach.BundleName
					local asset_name = attach.AssetName
					EffectManager.Instance:PlayAtTransformCenter(bundle_name, asset_name, self.node_list["Effect0"].transform, 0.5)
				end, start_time)
			end
		end
		self.cur_exp = cur_exp or self.cur_exp or 0
		self.max_exp = max_exp or self.max_exp or 0
		local flush_time = 0.2
		GlobalTimerQuest:AddDelayTimer(function()
				self.node_list["TxtExp"].text.text = self.cur_exp .. "/" .. self.max_exp
			end, flush_time)

		local target_percent = self.cur_exp / self.max_exp
		if is_level_change then
			target_percent = target_percent + 1
		end

		self:SetSliderValue(target_percent, is_tween, callback)
	end
end

function ShenGeZhangKongCell:SetSliderValue(target_percent, is_tween, callback)
	if nil == self.cur_precent or not is_tween or self.cur_precent == target_percent then
		self.cur_precent = target_percent
		self.cur_precent = self.cur_precent % 1
		self.node_list["Slider"].slider.value = self.cur_precent
		if nil ~= callback then
			callback()
		end
		return
	end
	self:RemoveSliderTween()
	self.slider_timer_quest = GlobalTimerQuest:AddRunQuest(function()

		self.cur_precent = math.min((self.cur_precent + 0.03), target_percent)
		local show_precent = self.cur_precent % 1
		self.node_list["Slider"].slider.value = show_precent

		if self.cur_precent >= target_percent then
			self:RemoveSliderTween()
			if nil ~= callback then
				callback()
			end
		end

	end, 0.03)
end

function ShenGeZhangKongCell:RemoveSliderTween()
	if nil ~= self.slider_timer_quest then
		GlobalTimerQuest:CancelQuest(self.slider_timer_quest)
		self.slider_timer_quest = nil
	end
end

function ShenGeZhangKongCell:SetStar(star, grade, is_tween)
	-- 第10阶开始复用月亮资源
	grade = grade or 0
	local pre_index = grade > 9 and (grade % 5 + 5) or grade
	local index = pre_index +1
	-- 5的倍数的时候特殊处理
	pre_index = (grade > 9 and grade % 5 == 0) and 10 or pre_index
	self.star = star or 0

	function showstar()
		for i = 1, 5 do
			if i < self.star then
				self.node_list["ImgStar" .. i].image:LoadSprite(ResPath.GetZhangkongStarRes(index))
			elseif i == self.star then
				self.node_list["ImgStar" .. i].image:LoadSprite(ResPath.GetZhangkongStarRes(index))
			elseif i > self.star then
				self.node_list["ImgStar" .. i].image:LoadSprite(ResPath.GetZhangkongStarRes(pre_index))
			end
		end
	end
end

function ShenGeZhangKongCell:CheckMaxLevel(level)
	if level >= 200 then 
		return true
	end
	return false
end

function ShenGeZhangKongCell:OnSingleDataChange(data, is_shield_play)
	if data ~= nil and self.grid == data.grid then
		self.data = data
		if self.item_id then
			self.node_list["ImgCost"].image:LoadSprite(ResPath.GetItemIcon(self.item_id))
			local count = ItemData.Instance:GetItemNumInBagById(self.item_id)
			local is_max = ShenGeData.Instance:IsZhangkongMaxLevelByIndex(self.grid)

			if is_max then
				self.node_list["TxtCost"].text.text = Language.Common.MaxLevelDesc
			else
				self.node_list["TxtCost"].text.text = count
			end
			
			self.node_list["RedPoint"]:SetActive(count > 0 and not is_max)
		end
		if self.level ~= data.level then
			self.node_list["TxtExp"]:SetActive(not self:CheckMaxLevel(data.level))
			self.node_list["ImgExp"]:SetActive(self:CheckMaxLevel(data.level))
			if is_shield_play then
				self:SetStar(data.star, data.grade, false)
				self:SetExpValue(data.exp, data.cfg_exp, true, false)
			else
				self:SetExpValue(data.exp, data.cfg_exp, true, true, function ()
						self:SetStar(data.star, data.grade, true)
					end)
			end
			self.level = data.level

			local value = data.shenge_pro / 100
			self.shenge_pro = value - value % 0.01
			self.node_list["TxtTittle"].text.text = data.name
			self.node_list["Level_Text"].text.text = string.format(Language.ShenGe.GradeNameDesc, data.grade)
			if self.grid == 0 or self.grid == 1 then
				self.node_list["Effect"].text.text = string.format(Language.ShenGe.XingHuiProfDesc, self.type, self.shenge_pro)
				if self.fight_text and self.fight_text.text then
					self.fight_text.text.text = self:GetZhanDouLiPro(self.grid)
				end
			else
				self.node_list["Effect"].text.text = ""
				if self.fight_text and self.fight_text.text then
					self.fight_text.text.text = self:GetZhandDouLi(data.attr_list)
				end
			end
			self:SetProText(data.attr_list)
		else
			self:SetExpValue(data.exp, data.cfg_exp, false, not is_shield_play)
		end
	end
end

function ShenGeZhangKongCell:GetZhanDouLiPro(grade)
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local attr_list, other_fight_power
	if grade == 0 then
		attr_list, other_fight_power = ShenGeData.Instance:GetInlayAttrListFightPower(cur_page, 3)
	else
		attr_list, other_fight_power = ShenGeData.Instance:GetInlayAttrListAndOtherFightPower(cur_page, 4)
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list) + other_fight_power
	return math.floor(power * (self.shenge_pro * 0.01))
end

function ShenGeZhangKongCell:GetZhandDouLi(data)
	local data_attr = {}
	for i,v in ipairs(data) do
		if v ~= nil then
			data_attr[ATTR_NAME[v.name]] = v.val
		end
	end
	return CommonDataManager.GetCapability(data_attr)
end

function ShenGeZhangKongCell:SetProText(text_list)
	if not text_list then return end

	if self.grid == 3 or self.grid == 2 then
		local text = ""
		for k,v in pairs(text_list) do
			if v ~= nil then
				if text ~= "" then 
					text = text .. "\n"
				end
				local name = Language.ShengeZhangkong.ProName[v.name]
				if self.level == 0 then
					text = text .. name .. "<color=#ffffff> +</color>" .. ToColorStr(0,TEXT_COLOR.WHITE)
				else
					text = text .. name .. "<color=#ffffff> +</color>" .. ToColorStr(v.val,TEXT_COLOR.WHITE)
				end
			end
		end
		self.node_list["Effect1"].text.text = text
	else
		self.node_list["Effect1"].text.text = ""
	end
end

function ShenGeZhangKongCell:OnFlush()
	local data = ShenGeData.Instance:GetZhangkongInfoByGrid(self.grid)
	self.type = Language.ShengeZhangkong.Type[self.grid]

	if data and data.level >= 0 then
		self.level = data.level
		self.node_list["TxtExp"]:SetActive(not self:CheckMaxLevel(data.level))
		self.node_list["ImgExp"]:SetActive(self:CheckMaxLevel(data.level))

		self.node_list["TxtTittle"].text.text = data.name
		self.node_list["Level_Text"].text.text = string.format(Language.ShenGe.GradeNameDesc, data.grade)
		self:SetExpValue(data.exp, data.cfg_exp, false, true)
		self.exp_val = data.exp
		self:SetStar(data.star, data.grade, false)
		local value = data.shenge_pro and (data.shenge_pro / 100) or 0
		self.shenge_pro = value - value % 0.01
		if self.grid == 1 or self.grid == 0 then
			self.node_list["Effect"].text.text = string.format(Language.ShenGe.XingHuiProfDesc, self.type, self.shenge_pro)
		else
			self.node_list["Effect"].text.text = ""
		end
		self:SetProText(data.attr_list)
		if self.level == 0 then
			self.fight_text.text.text = 0
		else
			if self.grid == 1 or self.grid == 0 then
				self.fight_text.text.text = self:GetZhanDouLiPro(self.grid)
			else
				self.fight_text.text.text = self:GetZhandDouLi(data.attr_list)
			end
		end
	end
end

function ShenGeZhangKongCell:SetIconClickListener(callback)
	self.node_list["BtnIcon"].button:AddClickListener(callback)
	self.node_list["BtnCell"].button:AddClickListener(callback)
end

function ShenGeZhangKongCell:SetIsShowSelectIcon(is_show)
	--self.node_list["ImgSelect"]:SetActive(is_show)
	self.node_list["NodeIsSelect"]:SetActive(is_show)
end

function ShenGeZhangKongCell:OnClickItem()
	TipsCtrl.Instance:OpenItem({item_id = self.item_id})
end