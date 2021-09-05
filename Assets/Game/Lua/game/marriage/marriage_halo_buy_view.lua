MarriageHaloBuyView = MarriageHaloBuyView or BaseClass(BaseView)

local AttrList = {
	"maxhp",
	"gongji",
	"fangyu",
	"mingzhong",
	"shanbi",
	"baoji",
	"jianren",
}

function MarriageHaloBuyView:__init(instance, mother_view)
	self.ui_config = {
		{"uis/views/marriageview_prefab", "HaloBuyView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MarriageHaloBuyView:__delete()

end

function MarriageHaloBuyView:ReleaseCallBack()
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

	local count = 0
	for k, v in pairs(self.cell_list_halo_buy) do
		v:DeleteMe()
		count = count + 1
	end
	self.cell_list_halo_buy = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end


function MarriageHaloBuyView:Buy()
	-- 全局搜这个枚举QINGYUAN_COUPLE_HALO_REQ_TYPE，有两个重名，不知道哪个挖的坑，现在写死3，买光环类型
	local yes_func = function()
		MarriageCtrl.Instance:SendUpgradeSpirit(3, self.select_index)

		if self.is_cell_active and self.is_scroll_create and self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
			if self.is_first_jump == false then
				local has_create_role_day = MarriageData.Instance:GetHasCreateDay()
				if has_create_role_day >= 0 then
					local halo_type = MarriageData.Instance:GetIsHasBuyTeJiaHalo()
					local off_price = 0
					local main_vo = GameVoManager.Instance:GetMainRoleVo()
					local gold = main_vo.gold
					local cfg = MarriageData.Instance:GetRewardCfgByType(self.select_index)
					if cfg and cfg.off_price then
						off_price = cfg.off_price
					end
					-- 如果当前选择的类型是打折，并且下一个打折存在，并且够钱		
					if halo_type == self.select_index and self.select_index + 1 <= MarriageData.Instance:GetMaxDay() and gold >= off_price then
						self.select_index = MarriageData.Instance:GetIsHasBuyTeJiaHalo() + 1
						-- self.node_list["ListView"].scroller:JumpToDataIndex(self.select_index - 1)
						self.is_first_jump = true
					end
				end
			end
		end	
	end
	local cfg = MarriageData.Instance:GetRewardCfgByType(self.select_index)
	local is_show = MarriageData.Instance:GetIsSaling(self.select_index)
	local has_create_role_day = MarriageData.Instance:GetHasCreateDay()
	local gold_txt = 0
	if has_create_role_day >= 0 and cfg then
		gold_txt = is_show and cfg.off_price or cfg.normal_price
	else
		gold_txt = cfg.normal_price
	end
	local describe = string.format(Language.Marriage.BuyCountByGold, gold_txt)
	TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil 								--有其他地方莫名其妙把""设为true
	TipsCtrl.Instance:ShowCommonAutoView("xunyou_red", describe, yes_func, nil, nil, nil, nil, nil, nil, true)
end

function MarriageHaloBuyView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.Buy, self))

	self.my_model = RoleModel.New()
	self.my_model:SetDisplay(self.node_list["MyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.lover_model = RoleModel.New()
	self.lover_model:SetDisplay(self.node_list["LoverDisPlay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.effect_model = RoleModel.New()
	self.effect_model:SetDisplay(self.node_list["ModelDisPlay"].ui3d_display)

	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))

	self.cell_list_halo_buy = {}
	self.list_data = {}
	self.list_data = MarriageData.Instance:GetCoupleHaloLevelBuyList()
	self.list_view_width = self.node_list["ListView"].rect.rect.width

	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.node_list["ListView"].scroller:ReloadData(0)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetShowOrangeEffect(true)
end

function MarriageHaloBuyView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if not self.is_scroll_create then
		if self.is_cell_active and self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
			self.is_scroll_create = true
			self:FlushListView()
		end
	end
end

function MarriageHaloBuyView:OpenCallBack()
	local max_num = MarriageData.Instance:GetMaxNum()
	local has_create_role_day = MarriageData.Instance:GetHasCreateDay()
	if has_create_role_day >= 0 then
		-- self.select_index = has_create_role_day + 1
		self.select_index = MarriageData.Instance:GetIsHasBuyTeJiaHalo()
	else
		self.select_index = 1
	end
	self.is_first_jump = true

	self:FlushMyModel()
	self:FlushLoverModel()
	self:FlushRoleContent()
	self:FlushEffectModel()
	-- self:Flush()
end

function MarriageHaloBuyView:CloseCallBack()
	MarriageCtrl.Instance:FlushHaloInfo()
end

function MarriageHaloBuyView:OnRoleDragSelf(data)
	-- if self.my_model then
	-- 	self.my_model:Rotate(0, -data.delta.x * 0.25, 0)
	-- end
	if self.effect_model then
		self.effect_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageHaloBuyView:OnRoleDragLover(data)
	if self.lover_model then
		self.lover_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageHaloBuyView:FlushMyModel()
	-- if self.my_model then
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local role_vo = {}
	-- 	role_vo.prof = main_role_vo.prof
	-- 	role_vo.sex = main_role_vo.sex
	-- 	role_vo.appearance = {}
	-- 	role_vo.appearance.fashion_body = 2
	-- 	self.my_model:SetModelResInfo(role_vo, true)
		
	-- 	self.my_model:SetDisplay(self.node_list["MyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	-- end
end

function MarriageHaloBuyView:FlushLoverModel()
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
	-- 	else
	-- 		self.lover_model:ClearModel()
	-- 	end
	-- end
end

function MarriageHaloBuyView:FlushRoleContent()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	--设置我的信息
	local level = main_role_vo.level
	local bundle, asset = ResPath.GetMarrySexRes(main_role_vo.sex)

	--设置伴侣的信息
	if main_role_vo.lover_uid > 0 then
		local lover_sex = main_role_vo.sex == 1 and 0 or 1
		bundle, asset = ResPath.GetMarrySexRes(lover_sex)
		self.node_list["ImgLover"]:SetActive(false)
	else
		local sex = GameVoManager.Instance:GetMainRoleVo().sex ~= 0
		self.node_list["Img1"]:SetActive(sex)
		self.node_list["Img2"]:SetActive(not sex)
		self.node_list["ImgLover"]:SetActive(true)
	end
end

function MarriageHaloBuyView:GetNumberOfCells()
	return #self.list_data
end

function MarriageHaloBuyView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.cell_list_halo_buy[cell]
	if nil == icon_cell then
		icon_cell = MarryHaloBuyCell.New(cell.gameObject)
		icon_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		icon_cell:SetClickCallBack(BindTool.Bind(self.IconCellClick, self))
		self.cell_list_halo_buy[cell] = icon_cell
	end
	icon_cell:SetToggleIsOn(self.select_index == data_index)
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(self.list_data[data_index])

	self.is_cell_active = true
end

function MarriageHaloBuyView:IconCellClick(cell)
	if nil == cell then return end
	local data = cell:GetData()
	if nil == data then return end

	local index = cell:GetIndex()
	if index == self.select_index then
		return
	end
	self.select_index = index
	local halo_type = self.select_index
	self.curr_halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	self.curr_halo_now_exp = MarriageData.Instance:GetHaloExpByType(halo_type)

	self:FlushListView()
	self:FlushName()
	--刷新模型
	self:FlushEffectModel()
end

function MarriageHaloBuyView:FlushName()
	local halo_info = MarriageData.Instance:GetHaloInfo(self.select_index, 1)
	self.node_list["ItemName"].text.text = halo_info.halo_name
	self.node_list["FightPowerNumber"].text.text = CommonDataManager.GetCapabilityCalculation(halo_info) * 2
	local cfg = MarriageData.Instance:GetRewardCfgByType(self.select_index)
	if cfg and cfg.reward_item then
		self.item_cell:SetActive(true)
		self.item_cell:SetData(cfg.reward_item[0])

		self.node_list["TextYuanJia"].text.text = cfg.normal_price
		self.node_list["TextTeJia"].text.text = cfg.off_price
	else
		self.item_cell:SetActive(false)
		self.node_list["TextYuanJia"].text.text = ""
		self.node_list["TextTeJia"].text.text = ""	
	end

	local has_create_role_day = MarriageData.Instance:GetHasCreateDay()
	if has_create_role_day >= 0 then
		local is_show = MarriageData.Instance:GetIsSaling(self.select_index)
		self.node_list["TeJia"]:SetActive(is_show)
		self.node_list["ChaCha"]:SetActive(is_show)
	else
		self.node_list["TeJia"]:SetActive(false)
		self.node_list["ChaCha"]:SetActive(false)
	end
end

function MarriageHaloBuyView:OnFlush()
	self.list_data = MarriageData.Instance:GetCoupleHaloLevelBuyList()	
	self:FlushListView()
	self:FlushName()
end

function MarriageHaloBuyView:ShowIndexCallBack()
	self:FlushListView()
	self:FlushName()
end

function MarriageHaloBuyView:FlushEffectModel()
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

		local halo_info = MarriageData.Instance:GetHaloInfo(self.select_index, 1)

		self.effect_model:SetMarriageModel(role_vo, halo_info, lover_vo)
	end
end

function MarriageHaloBuyView:FlushListView()
	if self.is_cell_active and self.is_scroll_create and self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
		if self.is_first_jump then
			--self.node_list["ListView"].scroller:JumpToDataIndex(self.select_index - 1)
			if self.select_index - 1 > 0 then
				self.node_list["ListView"].scroller:ReloadData(1)
			else
				self.node_list["ListView"].scroller:ReloadData(0)
			end
			self.is_first_jump = false
		end
	end
end

--------------------------------------
-------光环列表 MarryHaloBuyCell
MarryHaloBuyCell = MarryHaloBuyCell or BaseClass(BaseCell)
function MarryHaloBuyCell:__init()
	self.node_list["HaloIconCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MarryHaloBuyCell:__delete()
	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function MarryHaloBuyCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MarryHaloBuyCell:SetToggleIsOn(is_on)
	self.node_list["HL"]:SetActive(is_on)
	self.node_list["IconHL"]:SetActive(is_on)
	self.root_node.toggle.isOn = is_on
end

function MarryHaloBuyCell:OnFlush()
	if self.data == nil then
		return
	end

	local level = self.data
	local halo_type = self.index
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, level)
	if nil ~= halo_info then
		local res_id = halo_info.res_id
		local sex = GameVoManager.Instance:GetMainRoleVo().sex
		local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local bundle, asset = ResPath.GetMarryImage("FQGH_0" .. res_id)
		self.node_list["ImgIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgIcon"].image:SetNativeSize()
		end)
		
		local name = halo_info.halo_name
		name = ToColorStr(name, ITEM_COLOR[item_cfg.color])
		self.node_list["Txt"].text.text = name

		--判断是否该显示折扣
		local has_create_role_day = MarriageData.Instance:GetHasCreateDay()
		if has_create_role_day >= 0 then
			-- local is_show = MarriageData.Instance:GetIsSaling(halo_type, has_create_role_day + 1)
			local is_show = MarriageData.Instance:GetIsSaling(halo_type)
			self.node_list["DaZhe"]:SetActive(is_show)
			self.node_list["Time"]:SetActive(is_show)

			if self.count_down_timer then
				CountDown.Instance:RemoveCountDown(self.count_down_timer)
				self.count_down_timer = nil
			end
			local server_time = TimeCtrl.Instance:GetServerTime()
			-- local count_down_time = TimeUtil.NowDayTimeEnd(server_time) - server_time
			local count_down_time = MarriageData.Instance:GetHaloBuyInvalidTime() - server_time
			local time = TimeUtil.FormatSecond(count_down_time, 10)
			self.node_list["Time"].text.text = time
			if self.count_down_timer == nil and is_show then
				self.count_down_timer = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.UpdateTimerCallback, self), BindTool.Bind(self.CompleteTimerCallback, self))
			end
		else
			self.node_list["Time"]:SetActive(false)
			self.node_list["DaZhe"]:SetActive(false)
		end
	end
end

function MarryHaloBuyCell:UpdateTimerCallback(elapse_time, total_time)
	if self.node_list and self.node_list["Time"] and self.node_list["Time"].text and self.node_list["Time"].text.text then
		local time = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 10)
		self.node_list["Time"].text.text = time
	end
end

function MarryHaloBuyCell:CompleteTimerCallback()
	if self.node_list and self.node_list["Time"] and self.node_list["Time"].text and self.node_list["Time"].text.text then
		self.node_list["Time"].text.text = "00:00:00"
	end
end