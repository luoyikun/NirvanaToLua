BiPingActivityView = BiPingActivityView or BaseClass(BaseView)
function BiPingActivityView:__init()
	self.ui_config = {
		{"uis/views/bipingact_prefab", "ActivitbiPin"},
	}
	self.play_audio = true
	self.item_list = {}
	self.cell_list = {}
	self.reward_item_list = {}
	self.show_item = {}
	self.show_select = {}
	self.day_type = 3
	self.rank_type = 8
	self.is_flush = true
	self.is_stop_load_effect = false
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = true
end

function BiPingActivityView:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.temp_display_role = nil
end

function BiPingActivityView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.fight_text = nil

	if self.equip_bg_effect_obj  ~= nil then
		ResMgr:Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self:CancelMountMoveTimeQuest()
end

function BiPingActivityView:LoadCallBack()
	self.node_list["BtnRank"].button:AddClickListener(BindTool.Bind(self.OnClickPaiHangBang, self))
	self.node_list["BtnZhiShengYiJie"].button:AddClickListener(BindTool.Bind(self.OnClickLucktips, self))
	
	self.node_list["ImgTitle"].image:LoadSprite("uis/views/bipingact/images_atlas","img_biping")
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i] = cell
	end
	self.display_camera_init_pos = self.node_list["UICamera"].transform.position
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["ModelDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtzhanliCount"])

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function BiPingActivityView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_IMAGE_COMPETITION)
	local open_day = BiPingActivityData.Instance:GetOpenDayCfg()
	self:OnClickItem(open_day)
	self:FlushActivityTimeCountDown()
	self:Flush()
	self.is_loading = true

	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_tongyongbaoju_1")
	local async_loader = AllocAsyncLoader(self, "tongyong_loader")
	async_loader:Load(bundle_name, asset_name, function(obj)
		if not IsNil(obj) then
			if self.is_stop_load_effect then
				self.is_stop_load_effect = false
				self.is_loading = false
				return
			end

			if self.equip_bg_effect_obj  ~= nil then
				ResMgr:Destroy(self.equip_bg_effect_obj)
				self.equip_bg_effect_obj = nil
			end

			local transform = obj.transform
			transform:SetParent(self.node_list["ModelEffect"].transform, false)
			transform.localScale = Vector3(3, 3, 3)

			self.equip_bg_effect_obj = obj.gameObject
			self.color = 0
			self.is_loading = false
		end
	end)	
end

function BiPingActivityView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.temp_display_role = nil

	self.day_type = 0

	if self.equip_bg_effect_obj  ~= nil then
		ResMgr:Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end

	if self.is_loading then
		self.is_stop_load_effect = true
	end
	self:CancelMountMoveTimeQuest()
end

function BiPingActivityView:OnClickClose()
	self:Close()
end


-- 点击查看排行榜
function BiPingActivityView:OnClickPaiHangBang()
	BiPingActivityCtrl.Instance:OpenRankView()
end

function BiPingActivityView:GetNumberOfCells()
	return BiPingActivityData.Instance:GetBiPinRankNum() 
end

function BiPingActivityView:RefreshCell(cell, data_index)
	local activity_info = BiPingActivityData.Instance:GetBiPinCfgAuto(data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = BiPinPanelSixListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	cell_item:SetData(activity_info,data_index, activity_info.rank_interval)
end



function BiPingActivityView:OnClickItem(day_type)
	self.is_flush = true
	self.day_type = day_type
	self:FlushInfo(self.day_type)
	self.node_list["Txtzhanli"].text.text = Language.CompetitionActivity.TotalAttrDesc
end




function BiPingActivityView:FlushInfo(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = BiPingActivityData.Instance:GetBiPinCfg(self.activity_type)
	
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	-- if self.activity_type == self.temp_activity_type then
	-- 	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	-- else
	-- 	if self.node_list["ListView"].scroller.isActiveAndEnabled then
	-- 		self.node_list["ListView"].scroller:ReloadData(0)
	-- 	end
	-- end
	local my_rank, my_level = BiPingActivityData.Instance:GetImageMyRankCfg()
	local item_id = BiPingActivityData.Instance:BiPinItemName()
	local item_name = ItemData.Instance:GetItemName(item_id)
	if my_rank ~= -1 then
		self.node_list["MyRank"].text.text = my_rank
		self.node_list["MyRank"]:SetActive(false)
		self.node_list["MyRankTwo"]:SetActive(true)
		self.node_list["MyRankTwo"].text.text = my_rank

	else
		self.node_list["MyRankTwo"]:SetActive(false)
		self.node_list["MyRank"].text.text = Language.Activity.BiPinMyRank
		self.node_list["MyRank"]:SetActive(true)
	end	
	self.node_list["Mylevel"].text.text = my_level

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.show_id)
	local display_role = item_cfg.is_display_role
	if display_role == DISPLAY_TYPE.MOUNT then
		if cfg.competition_id then
			local level = MountData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		if cfg.competition_id then
			local level = WingData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		if cfg.competition_id then
			local level = FashionData.Instance:GetSingleSpecialImageGrade(cfg.competition_id, SHIZHUANG_TYPE.WUQI)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
		if cfg.competition_id then
			local level = FashionData.Instance:GetSingleSpecialImageGrade(cfg.competition_id, SHIZHUANG_TYPE.BODY)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
		if cfg.competition_id then
			local level = HaloData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		if cfg.competition_id then
			local level = FightMountData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		if cfg.competition_id then
			local level = ShengongData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		if cfg.competition_id then
			local level = ShenyiData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		if cfg.competition_id then
			local level = GoddessData.Instance:GetXianNvHuanHuaLevel(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
		if cfg.competition_id then
			local level = FootData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.FABAO then
		if cfg.competition_id then
			local level = FaBaoData.Instance:GetSingleSpecialImageGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.TOUSHI then
		if cfg.competition_id then
			local level = TouShiData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.MASK then
		if cfg.competition_id then
			local level = MaskData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.WAIST then
		if cfg.competition_id then
			local level = WaistData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.QILINBI then
		if cfg.competition_id then
			local level = QilinBiData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		if cfg.competition_id then
			local level = LingChongData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		if cfg.competition_id then
			local level = LingGongData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGQI then
		if cfg.competition_id then
			local level = LingQiData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
		if cfg.competition_id then
			local level = ShouHuanData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.TAIL then 
		if cfg.competition_id then
			local level = TailData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.FLYPET then
		if cfg.competition_id then
			local level = FlyPetData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	elseif display_role == DISPLAY_TYPE.WEIYAN then
		if cfg.competition_id then
			local level = WeiYanData.Instance:GetHuanHuaGrade(cfg.competition_id)
			if level then
				self.node_list["Mylevel"].text.text = level
			end
		end
	end

	self.node_list["Namelevel"].text.text = string.format(Language.Activity.BiPinName,item_name)
	self:SetRoleModel(cfg.show_id,cfg.add_specil)
	self:SetFightPower(cfg.show_id)

	self.node_list["TxtWordReward"].text.text = ItemData.Instance:GetItemName(cfg.show_id)	--cfg[1].Language.BiPinActive[day]
end


function BiPingActivityView:OnClickLucktips()
	ViewManager.Instance:Open(ViewName.LuckWishingView)
end

function BiPingActivityView:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
end

--移动坐骑，达到尾焰拖尾效果
function BiPingActivityView:UpdateMountPosition()
	if nil == self.model.draw_obj then
		self:CancelMountMoveTimeQuest()
		return
	end

	local transform = self.node_list["UICamera"].transform
	local init_position = self.display_camera_init_pos


	if GameMath.GetDistance(transform.position.x, transform.position.y, init_position.x, init_position.y) > 10000000 then
		self.node_list["UICamera"].transform.position = init_position
	end

	local draw_root_obj = self.model.draw_obj:GetRoot()
	local step_target_pos = self.node_list["UICamera"].transform.position + (draw_root_obj.transform.forward * 0.08)
	local mount_pos = draw_root_obj.transform.position + (draw_root_obj.transform.forward * 0.08)

	self.node_list["UICamera"].transform.position = step_target_pos
	draw_root_obj.transform.position = mount_pos
end



function BiPingActivityView:SetRoleModel(item_id,add_specil)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local display_role = item_cfg and item_cfg.is_display_role or 0
	if display_role == DISPLAY_TYPE.WEIYAN then
			local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
			local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
			if mount_res_id <= 0 then
				return
			end
			local res_id = BiPingActivityData.Instance:GetWeiYanRes(item_id)
			local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
			self.model:SetMainAsset(mount_bundle, mount_asset, function()
				local draw_root_obj = self.model.draw_obj:GetRoot()
				draw_root_obj.transform:SetParent(self.node_list["UICamera"].transform, true)
			
				self.model:SetWeiYanResid(res_id, mount_res_id,false)
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				self:CancelMountMoveTimeQuest()
				self:UpdateMountPosition()
				self.mount_move_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateMountPosition, self), 0.02)
			end)
			self.model:SetRotation(Vector3(0, 100, 0))
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
			self.model:ChangeModelByItemId(item_id)
			self.model:SetRotation(Vector3(0, 90, 0))
	else
		self.model:ChangeModelByItemId(item_id)
	end
	self.node_list["ModelEffect"]:SetActive(add_specil > 0)
end

function BiPingActivityView:SetFightPower(item_id)
	local fight_power = 0
	local cfg = {}
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	if self.fight_text and self.fight_text.text then
		fight_power = ItemData.GetFightPower(item_id) or 0
		self.fight_text.text.text = fight_power
	end
end

function BiPingActivityView:SetModel(info, display_type)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info)
end

function BiPingActivityView:OnFlush()
	local open_day = BiPingActivityData.Instance:GetOpenDayCfg()
	self:FlushInfo(open_day)
	self:FlushActivityTimeCountDown()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
			self.node_list["ListView"].scroller:ReloadData(0)
	end
end

--刷新活动剩余时间
function BiPingActivityView:FlushActivityTimeCountDown()
	self:CancelTimeQuest()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function BiPingActivityView:FlushNextTime()
	local time = BiPingActivityData.Instance:GetActivitytimes()
	if time <= 0 then
		self:CancelTimeQuest()
	end
	timer = TimeUtil.FormatSecond(time, 10)
	self.node_list["TxtTime"].text.text = timer
end

function BiPingActivityView:CancelTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end


BiPinPanelSixListCell = BiPinPanelSixListCell or BaseClass(BaseRender)

function BiPinPanelSixListCell:__init(instance)

	self.cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		self.cells[i] = cell
	end
end

function BiPinPanelSixListCell:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function BiPinPanelSixListCell:SetData(data, is_get, rank_interval)
	if data == nil then return end
	local item_id = BiPingActivityData.Instance:BiPinItemName()
	local item_name = ItemData.Instance:GetItemName(item_id)
	self.node_list["TxtKehuode"].text.text = string.format(Language.Activity.BiPinRankTitle, rank_interval, item_name,data.limit_grade) 	--string.format(Language.Competition.WhoCanGetDesc, data.description)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}
	local gift_id = 0

	for k, v in pairs(data.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	local is_destory_effect = true
	for k, v in pairs(self.cells) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			for _, v2 in pairs(data.item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end
			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end
end
