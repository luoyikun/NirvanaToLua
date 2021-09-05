DisCountView = DisCountView or BaseClass(BaseView)

local PAGE_ROW = 2					--行
local PAGE_COLUMN = 2				--列
local MAX_COUNT = 2					--一个阶段最多显示个数

local display_cfg = {
	{position = Vector3(0, 0.51, 2.09),can_rotate = true },
}

function DisCountView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/discount_prefab", "DisCountView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
}

	self.is_modal = true
	self.is_any_click_close = true
	self.play_audio = true
end

function DisCountView:__delete()

end

function DisCountView:ReleaseCallBack()
	for k, v in pairs(self.tab_cell_list) do
		v:DeleteMe()
	end
	self.tab_cell_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.model_store then
		self.model_store:DeleteMe()
		self.model_store = nil
	end
	self:RemoveCountDown()
end

function DisCountView:LoadCallBack()
	DisCountData.Instance:SetIsFirstEnter(false)
	--普通模型
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	--宝石专用模型(材质贴图不一样)
	self.model_store = RoleModel.New()
	self.model_store:SetDisplay(self.node_list["DisplayStore"].ui3d_display)

	self.show_display_store = false
	self.show_model_img = false
	self.show_effect_model = false
	self.show_effect = false
	self.show_point_effect_list = false

	-- 物品列表
	self.list_data = {}
	self.cell_list = {}

	local scroller_delegate_1 = self.node_list["ListView"].list_simple_delegate
	scroller_delegate_1.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate_1.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)

	-- 左边tab列表
	self.select_tab_index = 1					--标签默认选择index
	self.select_tab_phase = 0					--选择的阶段
	self.tab_list_data = {}
	self.tab_cell_list = {}

	local scroller_delegate_2 = self.node_list["LeftTabList"].list_simple_delegate
	self.list_view_height = self.node_list["LeftTabList"].rect.rect.height
	self.tab_cell_height = scroller_delegate_2:GetCellViewSize(self.node_list["LeftTabList"].scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.tab_list_spacing = self.node_list["LeftTabList"].scroller.spacing											--间距
	scroller_delegate_2.NumberOfCellsDel = BindTool.Bind(self.GetTabNumber, self)
	scroller_delegate_2.CellRefreshDel = BindTool.Bind(self.RefreshTabDel, self)

	-- 监听按钮点击事件
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ItemImage"].button:AddClickListener(BindTool.Bind(self.OnItemImage, self))
	RemindManager.Instance:SetRemindToday(RemindName.DisCount)
end

function DisCountView:OpenCallBack()
	-- 复活(处理从全屏界面打开一折的时候出现死亡复活不了的问题)
	if ReviveView.FreeReviveEnble() then
		local role_vo = PlayerData.Instance:GetRoleVo()
		if role_vo.hp <= 0 then
			GuajiCtrl.Instance:OnMainRoleDead()
		end
	end

	DisCountData.Instance:SetHaveNewDiscount(false)
	DisCountData.Instance:SetRefreshList()
	DisCountData.Instance:SetIsFirstFresh(false)
	RemindManager.Instance:Fire(RemindName.DisCount)
	-- 一折抖动
	local is_active = DisCountData.Instance:GetActiveState()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DisCount, is_active and OpenFunData.Instance:CheckIsHide("DisCount"))		
end

function DisCountView:CloseCallBack()
	DisCountData.Instance:ClearDiscountList()
	DisCountData.Instance:SetIsFirstFresh(true)
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self.timer_quest = nil
	self:StopCountDown()
	self:RemoveCountDown()
	self.model_show = nil
end

-- 卧槽，谁特么那么垃圾写了一大串垃圾代码！！！搞到后面改都不好改！ 坑太深，太深，太深！！！！
function DisCountView:SetModel()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self.timer_quest = nil
	local data = DisCountData.Instance:GetDiscountInfoByType(self.select_tab_phase)
	if nil == data then
		return
	end
	if self.model and self.model_show ~= data.model_show then
		self.model:ClearModel()
		self.model:SetFootResid(0)
		self.model:ResetRotation()
		self.model:SetLocalPosition(Vector3(0, 0, 0))
		self.model:SetRotation(Vector3(0, -30, 0))
		self.model:SetScale(Vector3(1, 1, 1))
		self.model:ClearCallBackFun()
		self.model_store:ClearModel()
		self.show_display_store = false
		self.show_model_img = false
		self.show_point_effect_list = false
		self.show_effect_model = false
		self:JudgeState()

		if data.model_show == 0 and data.special_show == 0 then
			return
		end

		self.model_show = data.model_show
		local model_show = self.model_show
		local split_tbl = Split(model_show, ",")
		local cfg_pos = display_cfg[1]
		self.node_list["Display"].raw_image.raycastTarget = cfg_pos.can_rotate
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_vo.appearance.fashion_body
		self.node_list["Effect"]:SetActive(false)
		self.node_list["ShowImgPanle"]:SetActive(false)

		self.small_target_open_flag = nil
		self.select_small_system_type = nil
		self.node_list["JinJieSmallTarget"]:SetActive(false)
		if data.show_title ~= -1 then
			self:ShowSmallTarget(tonumber(data.show_title))
			self.small_target_open_flag = 1
			self.select_small_system_type = tonumber(data.show_title)
		elseif data.class_a_jump ~= -1 then
			self:ShowClassASmallTarget(tonumber(data.class_a_jump), tonumber(data.icon))
			self.small_target_open_flag = 2
			self.select_small_system_type = tonumber(data.class_a_jump)
		end 

		if data.special_show == 1 then
			if string.find(data.effect_bundle, "lingzhu") then -- 这个22是用来判断是否是灵珠的
				-- 灵珠
				self.model:SpecialSetMainAsset(data.effect_bundle, data.effect_asset)
			else

				self.node_list["Effect"]:SetActive(true)
				self.node_list["Effect"]:ChangeAsset(data.effect_bundle, data.effect_asset)
				local pos = Split(data.effect_pos, ",")
				local scale = Split(data.effect_scale, ",")
				self.node_list["Effect"].transform.localPosition = Vector3(pos[1], pos[2], pos[3])
				self.node_list["Effect"].transform.localScale = Vector3(scale[1], scale[2], scale[3])
			end
			return
		elseif data.special_show == 2 then
			local scale = Split(data.effect_scale, ",")
			self.node_list["ShowImgPanle"]:SetActive(true)
			self.node_list["ShowImg"].image:LoadSprite(split_tbl[1], split_tbl[2], function()
				self.node_list["ShowImg"].image:SetNativeSize()
				self.node_list["ShowImg"].transform.localScale = Vector3(scale[1], scale[2], scale[3])
			end)
			if data.effect_bundle ~= "" and data.effect_asset ~= "" then
				self.node_list["ImgEffect"]:ChangeAsset(data.effect_bundle, data.effect_asset)
				local scale = Split(data.effect_scale, ",")
				self.node_list["ImgEffect"].transform.localScale = Vector3(scale[1], scale[2], scale[3])
			end
			return
		elseif data.special_show == 3 then
			local prof = PlayerData.Instance:GetRoleBaseProf(main_vo.prof)
			local prof_show = Split(model_show, ";")
			split_tbl = Split(prof_show[prof], ",")
			self.model:SpecialSetMainAsset(split_tbl[1], split_tbl[2], function()
				local transform = nil
				if prof == 1 then
					transform = {position = Vector3(0, -0.5, 4.9), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 2 then
					transform = {position = Vector3(0, 0.15, 4.5), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 4 then
					transform = {position = Vector3(0, -0.2, 4), rotation = Quaternion.Euler(0, 180, 0)}
				elseif prof == 3 then
					transform = {position = Vector3(0, -0.1, 1.78), rotation = Quaternion.Euler(0, 180, 0)}
				end
				self.model:SetCameraSetting(transform)
			end)
			return
		end
		if string.find(model_show, "huobanhalo") then
			--仙环
			local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_vo.use_xiannv_id)
			local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
			info = {}
			info.role_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
			-- local split = Split(split_tbl[3],"_")
			info.halo_res_id = tonumber(split_tbl[2])
			self.model:SetGoddessModelResInfo(info)
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "halo") then
			-- 主角光环
			local split = Split(split_tbl[2], "_")
			local halo_id = split[2] or split_tbl[2]
			self.model:SetModelResInfo(info)
			self.model:SetHaloResid(tonumber(halo_id))
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "footprint") then
			--足迹
			local split = Split(split_tbl[2],"_")
			self.model:SetModelResInfo(info)
			self.model:SetFootResid(tonumber(split[2]))
			self.model:SetRotation(Vector3(0, -90, 0))
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		elseif string.find(model_show, "arm") then
			--麒麟臂
			local bundle, asset = split_tbl[1], split_tbl[2]
			self.model:SpecialSetMainAsset(bundle, asset)
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "mask") then
			--面饰
			self.model:SetModelResInfo(info)
			self.model:SetMaskResid(tonumber(split_tbl[2]))
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "headband") then
			--头饰
			self.model:SetModelResInfo(info)
			self.model:SetTouShiResid(tonumber(split_tbl[2]))
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "huobanfz") then
			--仙阵
			local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_vo.use_xiannv_id)
			local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
			info = {}
			info.role_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
			info.fazhen_res_id = tonumber(split_tbl[2])
			self.model:SetGoddessModelResInfo(info, true)
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "belt") then
			--腰饰
			self.model:SetModelResInfo(info)
			self.model:SetWaistResid(tonumber(split_tbl[2]))
			self.model:SetRotation(Vector3(0, 30, 0))
		elseif string.find(model_show, "weapon") then
			--神兵
			local prof = PlayerData.Instance:GetRoleBaseProf(main_vo.prof)
			local prof_show = Split(model_show, ";")
			split_tbl = Split(prof_show[prof], ",")
			self.model:SetModelResInfo(info)
			self.model:SetWeaponResid(split_tbl[2])
			self.model:SetTrigger(ANIMATOR_PARAM.FIGHT)
		elseif string.find(model_show, "role") then
			--时装
			local prof = PlayerData.Instance:GetRoleBaseProf(main_vo.prof)
			local prof_show = Split(model_show, ";")
			split_tbl = Split(prof_show[prof], ",")
			local bundle, asset = ResPath.GetFashionShizhuangModel(split_tbl[2])
			self.model:SpecialSetMainAsset(bundle, asset)
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "goddess") then
			--女神
			self.model:SetGoddessHaloResid(-1)
			self.model:SetGoddessResid(tonumber(split_tbl[2]))
			self.model:SetTrigger("show_idle_1")
			self.model:SetRotation(Vector3(0, 0, 0))
		elseif string.find(model_show, "rawimages") then
			--图片资源
			self.show_model_img = true
			self:JudgeState()
			self.node_list["ImgModel"].raw_image:LoadSprite(split_tbl[1], split_tbl[2], function() 
				self.node_list["ImgModel"].raw_image:SetNativeSize() end)

			if string.find(model_show, "shengxiao") then
				self.show_point_effect_list = true
				self:JudgeState()
			end
		elseif string.find(model_show, "wing") then
			--羽翼
			self.model:SetModelResInfo(info)
			self.model:SetWingResid(tonumber(split_tbl[2]))

			local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_wing", tonumber(split_tbl[2]))
			if advance_transform_cfg then
				self.model:SetLocalPosition(advance_transform_cfg.position)
				self.model:SetLocalRotation(advance_transform_cfg.rotation)
			else
				self.model:SetRotation(Vector3(0, -180, 0))
			end
		elseif string.find(model_show, "weiba") then
			-- 尾巴
			self.model:SetModelResInfo(info)
			self.model:SetTailResid(tonumber(split_tbl[2]))
			self.model:SetRotation(Vector3(0, 120, 0))
		elseif string.find(model_show, "shouhuan") then
			-- 手环
			self.model:SetModelResInfo(info)
			self.model:SetShouHuanResid(split_tbl[2])
			self.model:SetRotation(Vector3(0, 45, 0))
		else
			local model = self.model
			local trigger_name = ""
			local function SpecialSetMainAsset(model, trigger_name)
				if string.find(model_show, "huoban") then
					model:SetRotation(Vector3(0, 0, 0))
				elseif string.find(model_show, "fightmount") then
					model:SetRotation(Vector3(0, -35, 0))
				end

				if trigger_name and trigger_name ~= "" then
					model:SetTrigger(trigger_name)
					if self.timer_quest == nil then
						self.timer_quest = GlobalTimerQuest:AddRunQuest(function() model:SetTrigger(trigger_name) end, 15)
					end
				end
				local bundle, asset = split_tbl[1], split_tbl[2]
				local function complete_callback()
					if split_tbl[3] and data.special_show == 4 then
						-- 尾焰
						model:SetWeiYanResid(tonumber(split_tbl[3]), tonumber(asset), false)
						model:SetRotation(Vector3(0, 150, 0))
					elseif string.find(model_show, "mount") and data.special_show ~= 4 then
						local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_mount", tonumber(asset))
						if advance_transform_cfg then
							model:SetLocalPosition(advance_transform_cfg.position)
							model:SetLocalRotation(advance_transform_cfg.rotation)
						else
							model:SetLocalPosition(Vector3(0, 0, 0))
							model:SetRotation(Vector3(0, -60, 0))
						end
					elseif string.find(model_show, "lingbao") then
						model:SetRotation(Vector3(0, 5, 0))
					elseif string.find(model_show, "forge") then
						local transform = {position = Vector3(0, 0.75, 1.6), rotation = Quaternion.Euler(0, 180, 0)}
						model:SetCameraSetting(transform)

					elseif string.find(model_show, "mingjiang") then
						local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_mingjiang", tonumber(asset))
						if advance_transform_cfg then
							model:SetLocalPosition(advance_transform_cfg.position)
							model:SetLocalRotation(advance_transform_cfg.rotation)
							model:ShowRest()
						end
					elseif string.find(model_show, "spirit") then
						-- 宠物
						local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_spirit", tonumber(asset))
						if advance_transform_cfg then
							model:SetLocalPosition(advance_transform_cfg.position)
							model:SetLocalRotation(advance_transform_cfg.rotation)
						end
					elseif string.find(model_show, "baoju") then
						-- 法宝
						local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_baoju", tonumber(asset))
						if advance_transform_cfg then
							model:SetLocalPosition(advance_transform_cfg.position)
							model:SetLocalRotation(advance_transform_cfg.rotation)
						end
					elseif string.find(model_show, "pet") then
						-- 小宠物
						local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("discount_pet", tonumber(asset))
						if advance_transform_cfg then
							model:SetLocalPosition(advance_transform_cfg.position)
							model:SetLocalRotation(advance_transform_cfg.rotation)
						end
					end
				end
				if split_tbl[3] and data.special_show == 4 then
					model:SetMainAsset(bundle, asset, complete_callback)
				elseif string.find(model_show, "spirit") then
					model:SetMainAsset(bundle, asset, complete_callback)
				else
					model:SpecialSetMainAsset(bundle, asset, complete_callback)
				end
			end
			if string.find(model_show, "gather") then
				--采集物
				if tonumber(split_tbl[2]) == 6037 then
					--特殊采集物（需要更换反射贴图）
					model = self.model_store
					self.show_display_store = true
					self:JudgeState()
				end
			elseif string.find(model_show, "mount") then
				--坐骑
				trigger_name = "rest"
				
			elseif string.find(model_show, "hunqi") then
				local function complete_callback()
					if self.model then
						self.model:ShowAttachPoint(AttachPoint.Weapon, false)
						self.model:ShowAttachPoint(AttachPoint.Weapon2, true)
					end
				end
				local bundle, asset = split_tbl[1], split_tbl[2]
				self.model:SpecialSetMainAsset(bundle, asset, complete_callback)
				return
			end
			SpecialSetMainAsset(model, trigger_name)
		end
		if not string.find(model_show, "footprint") then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		end
	end
end

function DisCountView:JudgeState()
	self.node_list["Display"]:SetActive((not self.show_display_store) and (not self.show_model_img) and (not self.show_effect_model))
	self.node_list["DisplayStore"]:SetActive(self.show_display_store and (not self.show_model_img) and (not self.show_effect_model))
	self.node_list["ImgModel"]:SetActive(self.show_model_img and (not self.show_effect_model))
	self.node_list["PointEffectList"]:SetActive(self.show_point_effect_list)
	self.node_list["EffectModel"]:SetActive(self.show_effect_model)
end


function DisCountView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function DisCountView:StartCountDown()
	self:StopCountDown()
	local info = DisCountData.Instance:GetDiscountInfoByType(self.select_tab_phase)
	if nil == info then
		return
	end

	local close_timestamp = info.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			self.node_list["TxtLeftTimes"].text.text = string.format(Language.OneDiscount.RemainTimes, time_des)

		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	self.node_list["TxtLeftTimes"].text.text = string.format(Language.OneDiscount.RemainTimes, time_des)
	self.node_list["TxtLeftTimes"]:SetActive(left_times > 0)
end

function DisCountView:GetTabNumber()
	return #self.tab_list_data
end

function DisCountView:RefreshTabDel(cell, data_index)
	data_index = data_index + 1
	local tab_cell = self.tab_cell_list[cell]
	if not tab_cell then
		tab_cell = TabItemCell.New(cell.gameObject)
		tab_cell:SetToggleGroup(self.node_list["LeftTabList"].toggle_group)
		tab_cell:SetClickCallBack(BindTool.Bind(self.TabClick, self))
		self.tab_cell_list[cell] = tab_cell
	end

	tab_cell:SetIndex(data_index)

	if self.select_tab_index == data_index then
		tab_cell:SetToggleIsOn(true)
	else
		tab_cell:SetToggleIsOn(false)
	end

	tab_cell:SetData(self.tab_list_data[data_index])
end

function DisCountView:TabClick(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()
	if nil == data then
		return
	end

	local index = cell:GetIndex()
	if index == self.select_tab_index then
		return
	end

	self.select_tab_phase = data.phase
	self.select_tab_index = index

	--处理相关数据
	self:FlushRight(true)
end

function DisCountView:GetCellNumber()
	return math.ceil(#self.list_data / (PAGE_ROW * PAGE_COLUMN))
end

function DisCountView:RefreshDel(cell, data_index)
	local discount_group_cell = self.cell_list[cell]
	if not discount_group_cell then
		discount_group_cell = DisCountGroupCell.New(cell.gameObject)
		self.cell_list[cell] = discount_group_cell
	end

	local grid_count = PAGE_COLUMN * PAGE_ROW
	for i = 1, grid_count do
		local index = data_index * grid_count + i
		discount_group_cell:SetIndex(i, index)
		discount_group_cell:SetClickCallBack(i, BindTool.Bind1(self.ClickCallBack, self))

		self.Sortlist = DisCountData.Instance:Sort(self.list_data)
		local data = DisCountData.Instance:GetDiscountInfoByType(self.select_tab_phase)
		if data and data.class_a_jump ~= -1 then
			self:ShowClassASmallTarget(tonumber(data.class_a_jump), tonumber(data.icon))
		end
		discount_group_cell:SetData(i, self.Sortlist[index])
	end
end

function DisCountView:ClickCallBack()
	self:OnItemImage()
end

function DisCountView:FlushLeft(is_init)
	if is_init then
		self.tab_list_data = DisCountData.Instance:GetNewPhaseList()
		local max_hight = (self.tab_cell_height + self.tab_list_spacing) * (#self.tab_list_data) - self.tab_list_spacing
		local not_see_height = math.max(max_hight - self.list_view_height, 0)
		local bili = 0
		if not_see_height > 0 then
			bili = math.min(((self.tab_cell_height + self.tab_list_spacing) * (self.select_tab_index - 1)) / not_see_height, 1)
		end
		self.node_list["LeftTabList"].scroller:ReloadData(bili)
	else
		self.tab_list_data = DisCountData.Instance:GetRefreshList()
		self.node_list["LeftTabList"].scroller:RefreshActiveCellViews()
	end
end

function DisCountView:FlushRight(is_init)
	self.list_data = DisCountData.Instance:GetItemListByPhase(self.select_tab_phase)
	if nil == self.list_data then
		return
	end

	if is_init then
		local page = math.ceil(#self.list_data / (PAGE_COLUMN * PAGE_ROW))
		self.node_list["ListView"].list_page_scroll:JumpToPageImmidate(0)
		self.node_list["ListView"].list_page_scroll:SetPageCount(page)
		self.node_list["ListView"].scroller:ReloadData(0)
		self:SetPageActive(page)
	else
		local page = math.ceil(#self.list_data / (PAGE_COLUMN * PAGE_ROW))
		self.node_list["ListView"].list_page_scroll:SetPageCount(page)
		self:SetPageActive(page)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	self:StartCountDown()
	self:SetModel()
end

function DisCountView:SetPageActive(Page)
	for i = 1, 10 do
		self.node_list["Toggle" .. i]:SetActive(Page >= i)
	end
end

function DisCountView:InitView()
	self:FlushLeft(true)
	self:FlushRight(true)
end

function DisCountView:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

function DisCountView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "index" then
			local data = DisCountData.Instance:GetNewPhaseList()
			if data == nil then
				return
			end

			local index = v[1] ~= "all" and v[1]
			if not index then
				local max_index = #data
				self.select_tab_phase = data[max_index].phase
				self.select_tab_index = max_index
			else
				local phase = data[index] and data[index].phase
				self.select_tab_phase = phase or 0
				self.select_tab_index = index
			end
			self:InitView()
		else
			self:FlushView()
		end
	end
end

-- 外部打开传过来的Index
function DisCountView:JumpToViewIndex(index)
	self.select_tab_index = index
end

function DisCountView:ShowSmallTarget(system_type, index)
	if system_type == nil then return end

	local is_show_small_target = JinJieRewardData.Instance:IsShowSmallTarget(system_type)
	-- self.node_list["JinJieSmallTarget"]:SetActive(is_show_small_target)

	local target_type = 0
	if is_show_small_target then --小目标
		target_type = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		self:SmallTargetConstantData(system_type, target_type)
		self:SmallTargetNotConstantData(system_type, target_type)
	else
		self:RemoveCountDown()
	end

end

--小目标固定显示
function DisCountView:SmallTargetConstantData(system_type, target_type)
	-- if self.set_small_target then
	-- 	return 
	-- end

	-- self.set_small_target = true
	local small_target_title_image = JinJieRewardData.Instance:GetSingleRewardCfgParam0(system_type, target_type)
	local bundle, asset = ResPath.GetTitleIcon(small_target_title_image)
	self.node_list["ItemImage"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["ItemImage"], small_target_title_image or 0, true)

	local power = JinJieRewardData.Instance:GetSmallTargetTitlePower(target_type)
	self.node_list["Power"].text.text = string.format(Language.Advance.AddFightPower, power)
end

--小目标 变动显示
function DisCountView:SmallTargetNotConstantData(system_type, target_type)
	local is_free_end = JinJieRewardData.Instance:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	-- UI:SetGraphicGrey(self.node_list["ItemImage"], not is_can_free)
	-- UI:SetGraphicGrey(self.node_list["BtnBigTarget"], not is_can_free)
	self.node_list["FreeTime"]:SetActive(not is_free_end)
	-- self.node_list["Panel1"].animator:SetBool("IsShake1", is_can_free)
	-- self.node_list["little_goal_redpoint"]:SetActive(is_can_free)
	self:RemoveCountDown()

	if is_free_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--刷新免费时间
function DisCountView:FulshJinJieFreeTime(end_time, target_type)
	if end_time == 0 then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetJinJieFreeTime(rest_time, target_type)
	self:RemoveCountDown()
	if rest_time >= 0 and nil == self.least_time_timer then
		self.node_list["JinJieSmallTarget"]:SetActive(true)
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetJinJieFreeTime(rest_time, target_type)
		end)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
	end
end

function DisCountView:SetJinJieFreeTime(time, target_type)
	if time > 0 then
		local time_str = TimeUtil.FormatSecond(time, 10)
		self:FreeTimeShow(time_str, target_type)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
	end
end

--免费时间显示
function DisCountView:FreeTimeShow(time, target_type)
	if time then --小目标
		self.node_list["FreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

function DisCountView:ClearJinJieFreeData(target_type)
	self.node_list["FreeTime"].text.text = ""
	self.node_list["FreeTime"]:SetActive(false)
	self.node_list["JinJieSmallTarget"]:SetActive(false)
end

function DisCountView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

-------系统类型A的大小目标
function DisCountView:ShowClassASmallTarget(system_type, item_id)
	local goal_info = DisCountData.Instance:GetClassASmallTargetInfo(system_type)
	if nil == next(goal_info) then return end

	if goal_info.fetch_flag[0] == 0 then
		local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, system_type)
		if is_show_little_goal then
			local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, system_type)
			if nil == goal_cfg_info or nil == goal_cfg_info.reward_show then
				return
			end
			local item_cfg = ItemData.Instance:GetItemConfig(goal_cfg_info.reward_item[0].item_id)
			if item_cfg then
				local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
				if title_cfg == nil then
					return
				end				
				local bundle, asset = ResPath.GetTitleIcon(title_cfg.title_id)
				self.node_list["ItemImage"].image:LoadSprite(bundle, asset)
				TitleData.Instance:LoadTitleEff(self.node_list["ItemImage"], title_cfg.title_id or 0, true)
				self.node_list["JinJieSmallTarget"]:SetActive(true)

				local zhanli = CommonDataManager.GetCapabilityCalculation(title_cfg)
				self.node_list["Power"].text.text = Language.Goal.PowerUp .. zhanli
			end
			
			if self.cell_list and item_id then
				for k,v in pairs(self.cell_list) do
					v:SetHightLight(item_id)
				end
			end

			local diff_time = goal_info.open_system_timestamp - TimeCtrl.Instance:GetServerTime()
			diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600

			self:RemoveCountDown()
			if self.least_time_timer == nil then
				function diff_time_func(elapse_time, total_time)
					local left_time = math.floor(diff_time - elapse_time + 0.5)
					if left_time <= 0 then
						if self.least_time_timer ~= nil then
							self:ClearJinJieFreeData()
							CountDown.Instance:RemoveCountDown(self.least_time_timer)
							self.least_time_timer = nil

							if self.cell_list then
								for k,v in pairs(self.cell_list) do
									v:SetHightLight(0)
								end
							end
						end
						return
					end
					if left_time > 0 then
						self.node_list["FreeTime"]:SetActive(true)
						self.node_list["FreeTime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
					else
						self:ClearJinJieFreeData()
					end
				end

				diff_time_func(0, diff_time)
				self.least_time_timer = CountDown.Instance:AddCountDown(
					diff_time, 0.5, diff_time_func)
			end
		end
	end
end

function DisCountView:OnItemImage()
	if nil == self.small_target_open_flag then return end

	local open_cfg
	if 1 == self.small_target_open_flag then
		local function callback()
			local param1 = self.select_small_system_type
			local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
			local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

			local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
			if is_can_free then
				req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
			end
			self:ClearJinJieFreeData()
			JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
		end
		local data = JinJieRewardData.Instance:GetSmallTargetShowData(self.select_small_system_type, callback)
		TipsCtrl.Instance:ShowTimeLimitTitleView(data)
		if open_cfg then
			ViewManager.Instance:Open(open_cfg.view_name, open_cfg.tab_index)
			self:Close()
		end
	elseif 2 == self.small_target_open_flag  then
		local sever_time = TimeCtrl.Instance:GetServerTime() or 0
		local goal_info = DisCountData.Instance:GetClassASmallTargetInfo(self.select_small_system_type) or {}
		local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, self.select_small_system_type) or {}

		if goal_info == nil or next(goal_info) == nil or goal_cfg_info == nil or next(goal_cfg_info) == nil then return end

		local fun = function(click_type)
			RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, self.select_small_system_type, click_type)
			self:ClearJinJieFreeData()
		end

		local goal_data = {}
		local diff_time = goal_info.open_system_timestamp - sever_time
		local item_id = goal_cfg_info.reward_item[0].item_id
		goal_data.item_id = item_id
		goal_data.cost = goal_cfg_info.cost
		goal_data.can_fetch = goal_info.active_flag[0] == 1
		goal_data.from_panel = ""
		goal_data.call_back = fun
		goal_data.left_time = diff_time + goal_cfg_info.free_time_since_open * 3600
		TipsCtrl.Instance:ShowGoalTimeLimitTitleView(goal_data, false, self.select_small_system_type)
	end
end

function GoddessInfoView:OpenTipsTitleLimit(is_model)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
end

-------------------------------------------------
--------------TabItemCell

TabItemCell = TabItemCell or BaseClass(BaseCell)
function TabItemCell:__init()
	self.node_list["DiscountTab"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function TabItemCell:__delete()

end

function TabItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TabItemCell:SetToggleIsOn(state)
	self.root_node.toggle.isOn = state
end

function TabItemCell:OnFlush()
	if self.data == nil then
		return
	end

	self.node_list["TxtHide"].text.text = self.data.phase_desc
	self.node_list["TxtHL"].text.text = self.data.phase_desc
	local bundle, asset = ResPath.GetImages(self.data.tab_act_icon)
	if bundle and asset then
		self.node_list["ImgNomal"].image:LoadSprite(bundle, asset)
	end
	
	local bundle2, asset2 = ResPath.GetImages(self.data.tab_act_icon .. "_select")
	if bundle2 and asset2 then
		self.node_list["ImgHightLight"].image:LoadSprite(bundle2, asset2)
	end

	local flag = DisCountData.Instance:GetIsFreeShowRedPointByPhase(self.data.phase)
	self.node_list["RedPoint"]:SetActive(flag)
	--判断该阶段状态
	local server_time = TimeCtrl.Instance:GetServerTime()
	local close_timestamp = self.data.close_timestamp
	local des = ""
	self.is_time_out = false
	self.is_sell_out = false
	if close_timestamp - server_time <= 0 then
		des = Language.Common.HadOverdue
		self.is_time_out = true
	else
		local phase_item_list = self.data.phase_item_list
		self.is_sell_out = true
		for _, v in ipairs(phase_item_list) do
			if v.buy_count < v.buy_limit_count then
				self.is_sell_out = false
				break
			end
		end
		if self.is_sell_out then
			des = Language.Common.SellOut
		end
	end
	self.node_list["Img"]:SetActive(des ~= "")
	self.node_list["Txt"].text.text = des
end

DisCountGroupCell = DisCountGroupCell or BaseClass(BaseRender)

function DisCountGroupCell:__init()
	self.cell_list = {}
	for i = 1, PAGE_ROW * PAGE_COLUMN do
		local cell = DisCountItemCell.New(self.node_list["Cell" .. i])
		table.insert(self.cell_list, cell)
	end
end

function DisCountGroupCell:__delete()
	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function DisCountGroupCell:SetClickCallBack(i, callback)
	self.cell_list[i]:SetClickCallBack(callback)
end

function DisCountGroupCell:SetHightLight(item_id)
	self.target_id = item_id

	for k,v in pairs(self.cell_list) do
		v:SetHightLight(item_id)
	end
end

function DisCountGroupCell:SetActive(i, enable)
	self.cell_list[i]:SetActive(enable)
end

function DisCountGroupCell:SetIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function DisCountGroupCell:SetData(i, data)
	self.cell_list[i]:SetData(data)
	self.cell_list[i]:SetHightLight(self.target_id)
end

-------------------------DisCountItemCell-----------------------------------------
DisCountItemCell = DisCountItemCell or BaseClass(BaseCell)

function DisCountItemCell:__init()
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
	self.node_list["SmallTarget"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetShowOrangeEffect(true)
	self.item_cell:SetData(nil)
end

function DisCountItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DisCountItemCell:OnFlush()
	if self.data == nil then
		self:SetActive(false)
		return
	end
	self:SetActive(true)
	local reward_data = self.data.reward_item
	self.item_cell:SetData(reward_data)
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = item_cfg.color or GameEnum.ITEM_COLOR_WHITE
	local item_name = item_cfg.name or ""
	item_name = ToColorStr(item_name, ITEM_COLOR[item_color])
	self.node_list["NText"].text.text = item_name

	self.node_list["TxtPrice1"].text.text = self.data.show_price
	local flag = self.data.price <= 0
	self.node_list["TxtPrice2"].text.text = flag and Language.Common.Free or self.data.price

	self.node_list["FreeGetTab"]:SetActive(flag)
	self.node_list["ImgYunbao2"]:SetActive(not flag)
	self.node_list["TxtPrice2"]:SetActive(not flag)
	self.node_list["Free"]:SetActive(flag)
	local limit_num = self.data.buy_limit_count - self.data.buy_count
	local limit_str = tostring(limit_num)
	if limit_num <= 0 then
		limit_str = ToColorStr(limit_num, TEXT_COLOR.RED_4)
	end
	local xg_text = flag and string.format(Language.OneDiscount.LimitLingQuTimes, limit_str) or string.format(Language.OneDiscount.LimitBuyTimes, limit_str)
	self.node_list["XGText"].text.text = xg_text
	if not (limit_num <= 0) then
		if self.data.price <= 0 then
			self.node_list["Txtbuy"].text.text = Language.Common.LingQu
		else
			self.node_list["Txtbuy"].text.text = Language.OpenServer.Buy
		end
	else
		if self.data.price <= 0 then
			self.node_list["Txtbuy"].text.text = Language.Common.YiLingQu
		else
			self.node_list["Txtbuy"].text.text = Language.OpenServer.SellAll
		end
	end
	UI:SetButtonEnabled(self.node_list["BtnBuy"], not (limit_num <= 0))
	self.node_list["RedPoint"]:SetActive(limit_num > 0 and flag and self.data.has_time_out == 0)
end

function DisCountItemCell:ClickBuy()
	if self.data == nil then
		return
	end
	local reward_data = self.data.reward_item
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = GameEnum.ITEM_COLOR_WHITE
	local item_name = ""
	if item_cfg then
		item_color = item_cfg.color
		item_name = item_cfg.name
	end
	if self.data.price <= 0 then
		DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
	else
		local des = string.format(Language.Common.UsedGoldToBuySomething, ToColorStr(self.data.price, TEXT_COLOR.GREEN), ToColorStr(item_name, ITEM_COLOR[item_color]))
		local function ok_callback()
			DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
		end
		TipsCtrl.Instance:ShowCommonAutoView("dis_count", des, ok_callback)
	end
end

function DisCountItemCell:SetHightLight(item_id)
	if self.node_list["SmallTarget"] and item_id and self.data and self.data.reward_item then
		local reward_id = self.data.reward_item.item_id or 0 
		self.node_list["SmallTarget"]:SetActive(reward_id == item_id)
	end
end

function DisCountItemCell:SetClickCallBack(callback)
	self.click_callback = callback
end

function DisCountItemCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end