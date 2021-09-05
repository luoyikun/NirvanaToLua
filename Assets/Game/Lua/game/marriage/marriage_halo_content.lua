MarriageHaloContent = MarriageHaloContent or BaseClass(BaseRender)

local AttrList = {
	"maxhp",
	"gongji",
	"fangyu",
	-- "mingzhong",
	-- "shanbi",
	-- "baoji",
	-- "jianren",
}
function MarriageHaloContent:__init(instance, mother_view)
	self.select_index = 1
	self.is_auto_buy_stone = 0
	self.last_level = 0
	self.my_model = RoleModel.New()
	self.my_model:SetDisplay(self.node_list["MyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.lover_model = RoleModel.New()
	self.lover_model:SetDisplay(self.node_list["LoverDisPlay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.effect_model = RoleModel.New()
	self.effect_model:SetDisplay(self.node_list["ModelDisPlay"].ui3d_display)

	self:FlushMyModel()
	self:FlushLoverModel()

	--属性列表
	self.attr_cell_list = {}
	for K, v in ipairs(AttrList) do
		local cell = MarryHaloAttrCell.New(self.node_list["Attr" .. K])
		self.attr_cell_list[v] = cell
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.list_data = {}
	self.cell_list = {}
	self.node_list["AutoBuy"].toggle.isOn = false
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])

	self.list_view_width = self.node_list["ListView"].rect.rect.width
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	self.cell_width = scroller_delegate:GetCellViewSize(self.node_list["ListView"].scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.list_spacing = self.node_list["ListView"].scroller.spacing										--间距
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.node_list["BtnSelect"].button:AddClickListener(BindTool.Bind(self.ClickSelect, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ClickLeft, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ClickRight, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.ClickLevelUp, self))
	self.node_list["BtnToBuyView"].button:AddClickListener(BindTool.Bind(self.OnBtnToBuyView, self))
	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self:FlushRoleContent()
	self:InitView()
end

function MarriageHaloContent:__delete()
	if self.my_model then
		self.my_model:DeleteMe()
		self.my_model = nil
	end

	if self.lover_model then
		self.lover_model:DeleteMe()
		self.lover_model = nil
	end

	if self.effect_model then
		self.effect_model:DeleteMe()
		self.effect_model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for _, v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
	self.attr_cell_list = {}

	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end
	self.fight_text = nil
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function MarriageHaloContent:CloseCallBack()
	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function MarriageHaloContent:OnRoleDragSelf(data)
	-- if self.my_model then
	-- 	self.my_model:Rotate(0, -data.delta.x * 0.25, 0)
	-- end
	if self.effect_model then
		self.effect_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageHaloContent:OnRoleDragLover(data)
	if self.lover_model then
		self.lover_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

-- 物品不足，购买成功后刷新物品数量
function MarriageHaloContent:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushLeft()
	self:FlushRight()
end

--列表滑动时
function MarriageHaloContent:OnValueChanged(position)
	local x = position.x
	self.node_list["BtnLeft"]:SetActive(x > 0.05)
	self.node_list["BtnRight"]:SetActive(x < 0.95)
end

function MarriageHaloContent:GetNumberOfCells()
	return #self.list_data
end

function MarriageHaloContent:RefreshCell(cell, data_index)

	data_index = data_index + 1
	local icon_cell = self.cell_list[cell]
	if nil == icon_cell then
		icon_cell = MarryHaloIconCell.New(cell.gameObject)
		icon_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		icon_cell:SetClickCallBack(BindTool.Bind(self.IconCellClick, self))
		self.cell_list[cell] = icon_cell
	end
	icon_cell:SetToggleIsOn(self.select_index == data_index)
	-- if self.select_index == data_index then
	-- 	icon_cell:SetToggleIsOn(true)
	-- else
	-- 	icon_cell:SetToggleIsOn(false)
	-- end
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(self.list_data[data_index])
end

function MarriageHaloContent:IconCellClick(cell)
	if nil == cell then return end
	local data = cell:GetData()
	if nil == data then return end

	local index = cell:GetIndex()
	if index == self.select_index then
		return
	end

	if index == 1 then
		self.node_list["Slider"]:SetActive(true)
	else
		self.node_list["Slider"]:SetActive(false)
	end

	self.select_index = index
	local halo_type = self.select_index - 1
	self.curr_halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	self.curr_halo_now_exp = MarriageData.Instance:GetHaloExpByType(halo_type)

	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(false)
	--刷新模型
	self:FlushEffectModel()

	self:FlushLeftContent()
	self:FlushRight(true)
end

function MarriageHaloContent:FlushMyModel()
	-- if self.my_model then
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local role_vo = {}
	-- 	role_vo.prof = main_role_vo.prof
	-- 	role_vo.sex = main_role_vo.sex
	-- 	role_vo.appearance = {}
	-- 	role_vo.appearance.fashion_body = 2
	-- 	self.my_model:SetModelResInfo(role_vo, true)
		
	-- 	self.my_model:SetDisplay(self.node_list["MyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	-- 	-- self.my_model:SetScale(Vector3(1.2,1.2,1.2))
	-- end
end

function MarriageHaloContent:FlushLoverModel()
	-- if self.lover_model then
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	if main_role_vo.lover_uid > 0 then
	-- 		local lover_vo = {}
	-- 		lover_vo.prof = MarriageData.Instance:GetLoverProf()
	-- 		lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
	-- 		lover_vo.appearance = {}
	-- 		lover_vo.appearance.fashion_body = 2
	-- 		self.lover_model:SetModelResInfo(lover_vo, true)

	-- 		self.lover_model:SetDisplay(self.node_list["LoverDisPlay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	-- 		-- self.lover_model:SetScale(Vector3(1.2,1.2,1.2))
	-- 	else
	-- 		self.lover_model:ClearModel()
	-- 	end
	-- end
end

function MarriageHaloContent:FlushRoleContent()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	--设置我的信息
	local level = main_role_vo.level
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["TxtMyLevel"].text.text = PlayerData.GetLevelString(level)
	-- self.node_list["TxtName"].text.text = main_role_vo.name
	local bundle, asset = ResPath.GetMarrySexRes(main_role_vo.sex)
	-- self.node_list["ImgName"].image:LoadSprite(bundle, asset .. ".png")
	-- self.node_list["ImgName"].image:SetNativeSize()

	--设置伴侣的信息
	-- local lover_level_des = ""
	if main_role_vo.lover_uid > 0 then
		-- lv, zhuan = PlayerData.GetLevelAndRebirth(MarriageData.Instance:GetLoverLevel())
		-- lover_level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		local lover_sex = main_role_vo.sex == 1 and 0 or 1
		bundle, asset = ResPath.GetMarrySexRes(lover_sex)
		-- self.node_list["ImgBg"].image:LoadSprite(bundle, asset .. ".png")
		-- self.node_list["ImgBg"].image:SetNativeSize()
		-- self.node_list["ImgBg1"]:SetActive(true)
		self.node_list["ImgLover"]:SetActive(false)
	else
		-- self.node_list["ImgBg1"]:SetActive(false)
		-- local id = main_role_vo.sex == 1 and 1 or 2
		-- local bundle, asset = ResPath.GetMarryRawImage("marry_icon_" .. id)
		-- self.node_list["ImgNotMarry"].raw_image:LoadSprite(bundle, asset, function ()
		-- 	self.node_list["ImgNotMarry"].raw_image:SetNativeSize()
		-- end)
		local sex = GameVoManager.Instance:GetMainRoleVo().sex ~= 0
		self.node_list["Img1"]:SetActive(sex)
		self.node_list["Img2"]:SetActive(not sex)
		self.node_list["ImgLover"]:SetActive(true)
	end
	self.node_list["TxtLoverLevel"].text.text = PlayerData.GetLevelString(MarriageData.Instance:GetLoverLevel())
	-- self.node_list["TextName"].text.text = main_role_vo.lover_name
end

function MarriageHaloContent:ClickSelect()
	MarriageCtrl.Instance:SendUpgradeSpirit(QINGYUAN_COUPLE_HALO_REQ_TYPE.QINGYUAN_COUPLE_REQ_TYPE_USE ,self.select_index - 1)
end

function MarriageHaloContent:ClickLeft()
	self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition = 0
end

function MarriageHaloContent:ClickRight()
	self.node_list["ListView"].scroll_rect.verticalNormalizedPosition = 0
end

function MarriageHaloContent:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(215)
end

function MarriageHaloContent:ClickLevelUp()
	local halo_type = self.select_index - 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	self.last_level = halo_level --保留上一级
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)

	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		self.node_list["AutoBuy"].toggle.isOn = is_buy_quick and true or false
	end

	self.is_auto_buy_stone = self.node_list["AutoBuy"].toggle.isOn and 1 or 0

	if have_num <= 0 and self.is_auto_buy_stone <= 0 then
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end
		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	else
		MarriageCtrl.Instance:SendUpgradeSpirit(QINGYUAN_COUPLE_HALO_REQ_TYPE.QINGYUAN_COUPLE_REQ_TYPE_UP_LEVEL ,self.select_index - 1,self.is_auto_buy_stone)
	end
end

function MarriageHaloContent:SetHaloBuyIconShake(flag)
	if self.node_list["ShakePanel"] and self.node_list["ShakePanel"].animator and self.node_list["ShakePanel"].animator.isActiveAndEnabled then
		self.node_list["ShakePanel"].animator:SetBool("IsShake", flag)
	end
end

function MarriageHaloContent:OnBtnToBuyView()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		PlayerPrefsUtil.SetInt("MarriageHaloBuyView" .. main_role_id, cur_day)
		RemindManager.Instance:Fire(RemindName.MarryCoupHalo)
	end
	MarriageCtrl.Instance:OpenMarriageHaloBuyView()

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarriageHaloBuyView" .. main_role_id) or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day and MarriageData.Instance:IsShowSaleRemind() then
		self.node_list["RedPoint"]:SetActive(true)
		self:SetHaloBuyIconShake(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
		self:SetHaloBuyIconShake(false)
	end
end


function MarriageHaloContent:FlushListView(is_init)
	self.list_data = MarriageData.Instance:GetCoupleHaloLevelList()
	if is_init then
		local max_width = (self.cell_width + self.list_spacing) * (#self.list_data) - self.list_spacing
		local not_see_width = math.max(max_width - self.list_view_width, 0)
		local bili = 0
		if not_see_width > 0 then
			bili = math.min(((self.cell_width + self.list_spacing) * (self.select_index - 1)) / not_see_width, 1)
		end
		self.node_list["ListView"].scroller:ReloadData(bili)
	else
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

function MarriageHaloContent:FlushEffectModel()
	if self.effect_model then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local role_vo = {}
		role_vo.prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		role_vo.sex = main_role_vo.sex
		role_vo.appearance = {}
		role_vo.appearance.fashion_body = 2

		local lover_vo = {}
		if main_role_vo.lover_uid > 0 then
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 2
		end

		local halo_info = MarriageData.Instance:GetHaloInfo(self.select_index - 1, 1)

		self.effect_model:SetMarriageModel(role_vo, halo_info, lover_vo)
	end
end

function MarriageHaloContent:FlushLeftContent(is_init)
	local used_halo_type = MarriageData.Instance:GetEquipCoupleHaloType()
	local halo_type = self.select_index - 1

	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local active_level = MarriageData.Instance:GetActiveHaloLevel(halo_type)
	self.node_list["BtnSelect"]:SetActive(halo_level >= active_level and not (used_halo_type == halo_type))
	self.node_list["NoteIsSelectImg"]:SetActive(used_halo_type == halo_type)

end

function MarriageHaloContent:FlushLeft(is_init)
	self:FlushListView(is_init)
	self:FlushLeftContent(is_init)
end

function MarriageHaloContent:FlushRight(is_init)
	local halo_type = self.select_index - 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)
	if halo_info == nil then
		return
	end

	--设置消耗显示
	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = halo_info.stuff_count
	self.item_cell:SetData({item_id = item_id, is_bind = 0})
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	--设置光环名字展示
	local name_des = string.format("Lv.%s %s", halo_level, halo_info.halo_name)
	name_des = ToColorStr(name_des, ITEM_COLOR[item_cfg.color])
	self.node_list["TxtRightName"].text.text = name_des

	--设置进度条展示
	local now_exp = MarriageData.Instance:GetHaloExpByType(halo_type)
	local max_exp = halo_info.stuff_count
	self.node_list["TxtSlider"].text.text = string.format("%s/%s", now_exp, max_exp)
	local cost_color = TEXT_COLOR.GREEN
	if have_num < max_exp then
		cost_color = TEXT_COLOR.RED
	end

	if self.select_index == 1 then
		self.node_list["Slider"]:SetActive(true)
	else
		self.node_list["Slider"]:SetActive(false)
	end

	local str = ToColorStr(have_num, cost_color)
	self.node_list["TxtItemCell"].text.text = str .. " / " .. max_exp
	local pro_value = now_exp / max_exp
	if self.last_level ~= halo_level then
		self.node_list["Slider"].slider.value = 1
	end
	if is_init then
		self.node_list["Slider"].slider.value = pro_value
	else
		 if not self.curr_halo_level then
		 	local halo_type = self.select_index - 1
		 	self.curr_halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
		 	self.curr_halo_now_exp = MarriageData.Instance:GetHaloExpByType(halo_type)
		end
		if self.curr_halo_level < halo_level and self.curr_halo_now_exp <= 0 then
			self.curr_halo_level = halo_level
			if not self.loop_time_quest then
				self.loop_time_quest = GlobalTimerQuest:AddDelayTimer(function()
					local next_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level + 1)
					if next_halo_info == nil then
						self.node_list["Slider"].slider.value = 1
					else
						self.node_list["Slider"].slider.value = pro_value
						GlobalTimerQuest:CancelQuest(self.loop_time_quest)
						self.loop_time_quest = nil
					end
				end, 0.2)
			end
		else
			self.curr_halo_now_exp = now_exp
			self.node_list["Slider"].slider.value = pro_value
		end
	end

	--设置激活描述
	local is_active_image = halo_info.is_active_image
	local active_str = Language.Marriage.ActiveHaloDes
	local active_color = TEXT_COLOR.ORANGE_4
	--先判断是否有前置光环条件
	local pre_halo_level = halo_info.pre_halo_level
	local above_halo_type = halo_type - 1
	local above_halo_level = MarriageData.Instance:GetHaloLevelByType(above_halo_type)
	local above_level_enough = true
	if pre_halo_level > 0 then
		if above_halo_level < pre_halo_level then
			above_level_enough = false
			local above_halo_info = MarriageData.Instance:GetHaloInfo(above_halo_type, 1)
			if nil ~= above_halo_info then
				active_str = string.format(Language.Marriage.AboveHaloActiveDes, above_halo_info.halo_name, pre_halo_level)
				if have_num < max_exp then
					active_color = TEXT_COLOR.WHITE
				else
					active_color = TEXT_COLOR.WHITE
				end
			end
		end
	end
	if above_level_enough and is_active_image == 0 then
		local active_level = MarriageData.Instance:GetActiveHaloLevel(halo_type)
		if active_level == 1 then
			active_str = Language.Marriage.NotActiveHaloDes2
		else
			active_str = string.format(Language.Marriage.NotActiveHaloDes, active_level)
		end
		if have_num < max_exp then
			active_color = TEXT_COLOR.WHITE
		else
			active_color = TEXT_COLOR.WHITE
		end
	end
	active_str = active_str
	local active_des = ToColorStr(active_str, active_color)
	self.node_list["TxtActiveDes"].text.text = active_des

	--设置属性描述
	for k, v in pairs(self.attr_cell_list) do
		local value = halo_info[k] or 0
		v:SetData({key = k, value = value})
	end

	--设置战斗力
	if halo_level == 0 then
		local temp_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, 1)
		local capability = CommonDataManager.GetCapabilityCalculation(temp_halo_info)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end

		for k, v in pairs(self.attr_cell_list) do
			local value = temp_halo_info[k] or 0
			v:SetData({key = k, value = value})
		end
	else
		local capability = CommonDataManager.GetCapabilityCalculation(halo_info)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	end


	--判断是否已满级
	local next_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level + 1)
	if next_halo_info == nil then
		UI:SetButtonEnabled(self.node_list["BtnUp"], false)
		self.node_list["TxtUpBtn"].text.text = Language.Common.YiManJi
		self.node_list["TxtSlider"].text.text = Language.Common.YiManJi
		self.node_list["TxtItemCell"].text.text = Language.Common.MaxLevelDesc
		self.node_list["Slider"].slider.value = 1
	else
		UI:SetButtonEnabled(self.node_list["BtnUp"], true and above_level_enough)
		if is_active_image ~= 0 or self.select_index < 2 then
			self.node_list["TxtUpBtn"].text.text = Language.Common.UpGrade
		else
			self.node_list["TxtUpBtn"].text.text = Language.Common.Activate
		end
	end
end

function MarriageHaloContent:InitView()
	--初始化的时候默认选中已装备的光环
	local equip_halo_type = MarriageData.Instance:GetEquipCoupleHaloType()
	self.select_index = equip_halo_type > 0 and equip_halo_type + 1 or 1

	self:FlushLeft(true)
	self:FlushLoverModel()
	self:FlushRight(true)
	self:FlushEffectModel()
end

function MarriageHaloContent:FlushView()
	self:FlushLeft()
	self:FlushRight()

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarriageHaloBuyView" .. main_role_id) or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day and MarriageData.Instance:IsShowSaleRemind() then
		self.node_list["RedPoint"]:SetActive(true)
		self:SetHaloBuyIconShake(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
		self:SetHaloBuyIconShake(false)
	end	

	local count_down_flag = MarriageData.Instance:GetHasCreateDay()
	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
	if count_down_flag > 0 then
		local halo_buy_time = MarriageData.Instance:GetHaloBuyInvalidTime()
		local server_time = TimeCtrl.Instance:GetServerTime()
		local count_down_time = halo_buy_time - server_time
		self.count_down_timer = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.UpdateTimerCallback, self), 
			BindTool.Bind(self.CompleteTimerCallback, self))
	else
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconBtnHalo"]:SetActive(false)
	end
end

function MarriageHaloContent:UpdateTimerCallback(elapse_time, total_time)
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		local time = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 10)
		self.node_list["BuyTime"].text.text = time
		self.node_list["SaleEffect"]:SetActive(true)
		self.node_list["IconBtnHalo"]:SetActive(true)
	end
end

function MarriageHaloContent:CompleteTimerCallback()
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconBtnHalo"]:SetActive(false)
	end
end

----------------------------MarryHaloIconCell-----------------------------
MarryHaloIconCell = MarryHaloIconCell or BaseClass(BaseCell)
function MarryHaloIconCell:__init()
	self.node_list["HaloIconCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MarryHaloIconCell:__delete()

end

function MarryHaloIconCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MarryHaloIconCell:SetToggleIsOn(is_on)
	-- if self.is_show_effect then
	-- 	self.node_list["ShowEffect"]:SetActive(is_on)
	-- 	self.root_node.toggle.isOn = is_on
	-- 	self.node_list["HL"]:SetActive(false)
	-- else
	self.node_list["HL"]:SetActive(is_on)
	self.node_list["IconHL"]:SetActive(is_on)
		-- self.node_list["ShowEffect"]:SetActive(false)
	-- end
end

function MarryHaloIconCell:OnFlush()
	if self.data == nil then
		return
	end

	local level = self.data
	local halo_type = self.index - 1
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, level)
	if nil ~= halo_info then
		local res_id = halo_info.res_id
		local sex = GameVoManager.Instance:GetMainRoleVo().sex
		local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetMarryImage("FQGH_0" .. res_id))
		self.node_list["ImgIcon"].image:SetNativeSize()
		local name = halo_info.halo_name .. "lv." .. level
		name = ToColorStr(name, ITEM_COLOR[item_cfg.color])
		self.node_list["Txt"].text.text = name
		-- UI:SetGraphicGrey(self.node_list["ImgIcon"], halo_info.is_active_image ~= 1)
		self.node_list["Lock"]:SetActive(halo_info.is_active_image ~= 1)
		--判断是否该显示红点
		local is_show = false
		-- self.node_list["Bg"].image:LoadSprite(ResPath.GetMarryImage("bghalo_" .. Common_Five_Rank_Color[item_cfg.color])) 
		local next_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, level + 1)
		if next_halo_info and next_halo_info.stuff_count and ItemData.Instance:GetItemNumInBagById(item_id) >= next_halo_info.stuff_count then
			--先判断是否满级
			if nil ~= next_halo_info then				--判断是否存在下一级光环属性
				--前置光环是否达到等级
				local pre_halo_level = halo_info.pre_halo_level
				if pre_halo_level > 0 then
					local above_halo_type = halo_type - 1
					local above_halo_level = MarriageData.Instance:GetHaloLevelByType(above_halo_type)
					if above_halo_level >= pre_halo_level then
						is_show = true
					end
				else
					is_show = true
				end
			end
		end
		self.node_list["ImgRedPoint"]:SetActive(is_show)
		-- local used_halo_type = MarriageData.Instance:GetEquipCoupleHaloType()
		-- self.node_list["ImgYiHuanHua"]:SetActive(used_halo_type == halo_type)
	end
end

----------------------------MarryHaloAttrCell-----------------------------
MarryHaloAttrCell = MarryHaloAttrCell or BaseClass(BaseCell)
function MarryHaloAttrCell:__init()

end

function MarryHaloAttrCell:__delete()

end

function MarryHaloAttrCell:OnFlush()
	if self.data == nil then
		return
	end

	local attr_name = Language.Common.AttrNameNoUnderline[self.data.key] or ""
	local attr_des = attr_name .. ":"
	self.node_list["AttrTxt"].text.text = attr_des
	self.node_list["Txt"].text.text = ToColorStr(self.data.value, TEXT_COLOR.ORANGE_4) 
end