ShengYinShengHun = ShengYinShengHun or BaseClass(BaseView)

local SOUL_TYPE_COUNT = 3

function ShengYinShengHun:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/player/shengyin_prefab", "ShenghunView"}
	}
	self.play_audio = true
	self.is_any_click_close = false
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengYinShengHun:LoadCallBack()
	self.start_one_key = false
	self.node_list["TitleText"].text.text = Language.Player.ShengHunViewName
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["OneKeyButton"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyUse, self))
	self.shenghun_item_list = {}
	for i = 1, SOUL_TYPE_COUNT do
		self.shenghun_item_list[i] = ShengHunItemView.New(self.node_list["Use" .. i])
	end
	self:Flush()
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE,
		BindTool.Bind(self.OnLevelChange, self))
end

function ShengYinShengHun:ReleaseCallBack()
	if self.shenghun_item_list then
		for k, v in pairs(self.shenghun_item_list) do
			v:DeleteMe()
		end
	end

	if self.level_change_event ~= nil then
		GlobalEventSystem:UnBind(self.level_change_event)
		self.level_change_event = nil
	end

	self.shenghun_item_list = {}
end

function ShengYinShengHun:__delete()

end

function ShengYinShengHun:CloseWindow()
	self:StopOneKey()
	self:Close()
end

function ShengYinShengHun:OnLevelChange()
	self:Flush()
end

function ShengYinShengHun:OnFlush()
	local soul_list = PlayerData.Instance:GetSoulCfg()
	self.use_seal_count_list = PlayerData.Instance:GetSealBaseInfo().soul_list or {}
	if soul_list ~= nil then
		for i = 1, SOUL_TYPE_COUNT do
	 		self.shenghun_item_list[i]:SetItemData(soul_list[i])
	 		self.shenghun_item_list[i]:SetItemIndex(i)
	 	end 	
	end
	local is_remind_soul = PlayerData.Instance:GetSealSoulRemind()
	self.node_list["Remind"]:SetActive(is_remind_soul > 0)

	local limit_level = PlayerData.Instance:GetUseLevel()
	local limit_str = string.format(Language.Player.LevelOpenLimit, limit_level)
	self.node_list["ButtomTip"].text.text = limit_str
	self.node_list["ButtomTip"]:SetActive(limit_level ~= 0)
end

-- 一键使用
function ShengYinShengHun:OnClickOneKeyUse()
	if self.start_one_key == false then	
		local use_max_num = PlayerData.Instance:GetUseMaxCount()
		local is_max_level = true
		for i = 1, SOUL_TYPE_COUNT do
			local shenghun_index = self.shenghun_item_list[i]:GetItemIndex()
			if self.use_seal_count_list then 
				use_num = self.use_seal_count_list[shenghun_index - 1] or 0			
				if use_num >= use_max_num then 
					is_max_level = true 
				else
					is_max_level = false
					break
				end
			end
		end	
		if is_max_level == false then
			self:StartOneKey()
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
			self:StopOneKey()
		end
	else
		self:StopOneKey()
	end

end

function ShengYinShengHun:StartOneKey()
	local soul_list = PlayerData.Instance:GetSoulCfg()
	local  err_num = 0
	
	local use_max_num = PlayerData.Instance:GetUseMaxCount()
	
	local  time = 0.3
	if nil ~= self.seal_one_key_upstar then
		GlobalTimerQuest:CancelQuest(self.seal_one_key_upstar)
		self.seal_one_key_upstar = nil
	end
	
	for i, v in pairs(soul_list) do
		local  item_count = ItemData.Instance:GetItemNumInBagById(v.soul_id)
		local use_num = 0
		if self.use_seal_count_list then 
			use_num = self.use_seal_count_list[i - 1] or 0			
		end
		if item_count > 0 and use_num < use_max_num then
			local use_count = use_max_num - use_num
			use_count = item_count > use_count and use_count or item_count
			PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_USE_SOUL, v.soul_type, use_count)
			self.start_one_key = true
			self.node_list["TxtOneKey"].text.text = Language.Player.StopUpgrade
		else
			err_num = err_num + 1
			if err_num == SOUL_TYPE_COUNT then
				SysMsgCtrl.Instance:ErrorRemind(Language.Player.Prop_No_Enough)
				self:StopOneKey()
				return
			end
		end
	end
	self:Flush()
	self.seal_one_key_upstar = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.StartOneKey, self), time)
end

function ShengYinShengHun:StopOneKey()
	if nil ~= self.seal_one_key_upstar then
		GlobalTimerQuest:CancelQuest(self.seal_one_key_upstar)
		self.seal_one_key_upstar = nil
	end
	self.start_one_key = false
	self.node_list["TxtOneKey"].text.text = Language.Player.OneKeyUse
end

ShengHunItemView = ShengHunItemView or BaseClass(BaseRender)

function ShengHunItemView:__init()
	self.item_shenghun = ItemCell.New()
	self.item_shenghun:SetInstanceParent(self.node_list["Item"])
	-- self.item_shenghun:SetBackground(true,{"uis/images_atlas","bg_item_quality_blue"})
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickUse , self))
	self.ProgressBar = ProgressBar.New(self.node_list["ProgressBG"])
	self.index = -1
end

function ShengHunItemView:__delete()
	if self.item_shenghun then 
		self.item_shenghun:DeleteMe()
		self.item_shenghun = nil
	end
	if nil ~= self.ProgressBar then
		self.ProgressBar:DeleteMe()
		self.ProgressBar = nil
	end
end

function ShengHunItemView:SetItemData(data)
	self.data = data
	local item_need_data = {item_id = self.data.soul_id}
	self.item_shenghun:SetData(item_need_data)
	self:Flush()
end

function ShengHunItemView:SetItemIndex(index)
	self.index = index
end

function ShengHunItemView:GetItemIndex()
	return self.index
end

function ShengHunItemView:OnFlush()
	local str1 = string.format(Language.Player.AtrrTip, self.data.gongji, self.data.fangyu, self.data.maxhp)
	self.node_list["AttrTxt1"].text.text = str1
	local str = string.format(Language.Player.SealBaseAtrrAdd, self.data.per_base_attr_jiacheng / 100)
	self.node_list["AttrTxt2"]:SetActive(self.data.per_base_attr_jiacheng > 0)
	self.node_list["AttrTxt2"].text.text = str
	local str = string.format(Language.Player.SealStrengthAtrrAdd, self.data.per_strength_attr_jiacheng / 100)
	self.node_list["AttrTxt3"].text.text = str
	self.node_list["AttrTxt3"]:SetActive(self.data.per_strength_attr_jiacheng > 0)

	local use_seal_count_list = PlayerData.Instance:GetSealBaseInfo().soul_list or {}
	local use_max_num = PlayerData.Instance:GetUseMaxCount()
	self.is_manji = false 
	if use_seal_count_list then 
		use_num = use_seal_count_list[self.index - 1] or 0			-- seld.index 是否正确
		if use_num == use_max_num then 
			self.is_manji = true 
		end
	end

	local item_count  = ItemData.Instance:GetItemNumInBagById(self.data.soul_id)
	if item_count == 0 then  
		self.node_list["NumText"].text.text = ToColorStr( item_count, COLOR.RED) .. ToColorStr( " / "  .. 1, COLOR.GREEN)
		self.node_list["Remind"]:SetActive(false)
	else
		item_count = CommonDataManager.ConverMoney(item_count)
		self.node_list["NumText"].text.text = ToColorStr( item_count, COLOR.GREEN) .. ToColorStr( " / "  .. 1, COLOR.GREEN)
		self.node_list["Remind"]:SetActive(true)
	end

	if self.is_manji == false then
		local upstar_percent = math.floor(use_num / use_max_num * 100)
		--self.node_list["ProgressBG"].slider.value = upstar_percent * 0.01
		self.ProgressBar:SetValue(upstar_percent * 0.01)
		self.node_list["SliderTxt"].text.text = use_num .. " / " ..use_max_num
		UI:SetButtonEnabled(self.node_list["Button"], true)
		self.node_list["BtnText"].text.text = Language.Common.Use

	else
		--self.node_list["ProgressBG"].slider.value = 1
		self.ProgressBar:SetValue(1.0)
		self.node_list["SliderTxt"].text.text = use_num .." / "..use_max_num
		self.node_list["Remind"]:SetActive(false)
		-- UI:SetGraphicGrey(self.node_list["Button"], true)
		UI:SetButtonEnabled(self.node_list["Button"], false)
		self.node_list["BtnText"].text.text = Language.Common.YiManJi
	end
end

function ShengHunItemView:OnClickUse()
	local item_count  = ItemData.Instance:GetItemNumInBagById(self.data.soul_id)
	if self.is_manji == true then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
	else
		if item_count > 0 then 
			PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_USE_SOUL, self.data.soul_type,1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Player.Prop_No_Enough)
		end
	end
end