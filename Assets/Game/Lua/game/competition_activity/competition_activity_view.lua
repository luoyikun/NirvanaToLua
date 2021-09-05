CompetitionActivityView = CompetitionActivityView or BaseClass(BaseView)
local PaiHangBang_Index = {
	-- 开服比拼活动(目前只开14个，注释后面两个)
	RANK_TAB_TYPE.MOUNT,			-- 坐骑进阶榜(开服活动)
	RANK_TAB_TYPE.WING,				-- 羽翼进阶榜(开服活动)
	RANK_TAB_TYPE.FIGHT_MOUNT,		-- 战骑战力榜(开服活动)
	RANK_TAB_TYPE.LINGTONG,			-- 灵童进阶榜(开服活动)
	RANK_TAB_TYPE.FABAO,			-- 法宝进阶榜(开服活动)
	RANK_TAB_TYPE.FLYPET,			-- 飞宠进阶榜(开服活动)
	RANK_TAB_TYPE.HALO,				-- 光环进阶榜(开服活动)
	RANK_TAB_TYPE.LINGQI,			-- 灵骑进阶榜(开服活动)
	RANK_TAB_TYPE.WEIYAN,			-- 尾焰进阶榜(开服活动)
	RANK_TAB_TYPE.QILINBI,			-- 麒麟臂进阶榜(开服活动)
	RANK_TAB_TYPE.SHENGONG,			-- 神弓仙环进阶榜(开服活动)
	RANK_TAB_TYPE.FOOT,				-- 足迹进阶榜(开服活动)
	RANK_TAB_TYPE.LINGGONG,			-- 灵弓进阶榜(开服活动)
	RANK_TAB_TYPE.SHENYI,			-- 神翼仙阵进阶榜(开服活动)
	-- RANK_TAB_TYPE.FASHION,			-- 时装进阶榜(开服活动)
	-- RANK_TAB_TYPE.SHENBING,			-- 神兵进阶榜(开服活动)	
}

function CompetitionActivityView:__init()
	self.ui_config = {
		{"uis/views/competitionactivityview_prefab", "CompetitionActivityView"},
	}
	self.play_audio = true
	self.item_list = {}
	self.cell_list = {}
	self.reward_item_list = {}
	self.show_item = {}
	self.show_select = {}
	self.day_type = 0
	self.rank_type = 8
	self.is_flush = true
	self.is_stop_load_effect = false
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
end

function CompetitionActivityView:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.temp_display_role = nil
end

function CompetitionActivityView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.equip_bg_effect_obj  ~= nil then
		ResMgr:Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	self.fight_text = nil

	self:CancelMountMoveTimeQuest()
end

function CompetitionActivityView:ShowIndexCallBack()
	CompetitionActivityCtrl.Instance:MainuiOpenCreate()
	RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type)
end

function CompetitionActivityView:LoadCallBack()
	self.node_list["BtnRank"].button:AddClickListener(BindTool.Bind(self.OnClickPaiHangBang, self))
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay() <= 14 and TimeCtrl.Instance:GetCurOpenServerDay() or 1
	self.node_list["ImgTitle"].image:LoadSprite("uis/views/competitionactivityview/images_atlas","title_bi_pin_" .. cur_day)
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i] = cell
	end

	self.display_camera_init_pos = self.node_list["UICamera"].transform.position
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["ModelDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	for i = 1, 2 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["RewardItem" .. i])
		self.reward_item_list[i] = cell
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnLingque"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))
	self.node_list["BtnZhiShengYiJie"].button:AddClickListener(BindTool.Bind(self.OnClickZhiShengYiJie, self))

	self.rank_type_list = RankData.Instance:GetRankTypeList()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtzhanliCount"])
	local act_type = COMPETITION_ACTIVITY_TYPE[cur_day]
	self:FlushModelDisplay(act_type)
end

function CompetitionActivityView:OpenCallBack()
	CompetitionActivityData.Instance:SetFirstOpenFlag()
	self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())
	local act_type = COMPETITION_ACTIVITY_TYPE[self.day_type]
	if ActivityData.Instance:GetActivityIsOpen(act_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(act_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	local end_act_day = 0--GameEnum.NEW_SERVER_DAYS - TimeCtrl.Instance:GetCurOpenServerDay()
	if end_act_day == 0 then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		self.node_list["TxtDay"]:SetActive(false)
		self.node_list["TxtTime"]:SetActive(true)
		self:SetRestTime(reset_time_s)
	else
		self.node_list["TxtDay"].text.text = string.format(Language.RemainActTime1, end_act_day)
		self.node_list["TxtDay"]:SetActive(true)
		self.node_list["TxtTime"]:SetActive(false)
	end

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

	RemindManager.Instance:Fire(RemindName.ShenmiShop)
	RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type)

	self:Flush()
end

function CompetitionActivityView:CloseCallBack()
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

function CompetitionActivityView:OnClickZhiShengYiJie()
	CompetitionActivityCtrl.Instance:MainuiOpenCreate()
	ViewManager.Instance:Open(ViewName.LeiJiDailyView)
end

function CompetitionActivityView:OnClickClose()
	self:Close()
end

-- 点击查看排行榜
function CompetitionActivityView:OnClickPaiHangBang()

		local index = PaiHangBang_Index[self.day_type]
		if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
			or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
			self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
			self.is_flush = false
		end
		RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type)
		ViewManager.Instance:Open(ViewName.Ranking,index)
end

function CompetitionActivityView:GetNumberOfCells()
	return 3-- #KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
end

function CompetitionActivityView:RefreshCell(cell, data_index)
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(self.activity_type)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelSixListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
		cell_item.parent_view = self
	end
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local is_get = KaifuActivityData.Instance:IsGetReward(data_index + 2, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(data_index + 2, self.activity_type)

	cell_item:SetData(cfg[data_index + 2], is_get, is_complete)
end

function CompetitionActivityView:OnClickGetReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, #cfg or 0)
end

function CompetitionActivityView:OnClickItem(day_type)
	self.is_flush = true

	for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
		if ActivityData.Instance:GetActivityIsOpen(v) and day_type == k then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			break
		end
	end

	RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type_list[PaiHangBang_Index[day_type]])

	if self.day_type == day_type then return end
	self.day_type = day_type
	self.rank_type = self.rank_type_list[PaiHangBang_Index[self.day_type]]
	self:FlushInfo(COMPETITION_ACTIVITY_TYPE[day_type])

	for i = 1, 7 do
		self.node_list["Select" .. i]:SetActive(i == day_type)
	end

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local can_reward = server_day == day_type

	
	self.node_list["ImgRedPoint"]:SetActive(can_reward)

	self.node_list["Txtzhanli"].text.text = Language.CompetitionActivity.TotalAttrDesc

	self:FlushBtnReward()
end

function CompetitionActivityView:OnClickItemNotOpen(i)
	if i == TimeCtrl.Instance:GetCurOpenServerDay() then
		self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())
		return
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.CompetitionActivity.HasNotOpen)
end


function CompetitionActivityView:FlushModelDisplay(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	--local item_gift_list = {}-- ItemData.Instance:GetGiftItemListByProf(cfg[1].reward_item[0].item_id)
	local item_list = {}
	for k, v in pairs(cfg[1].reward_item) do
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
	local display_role = 0
	local item_cfg = nil
	local item_id = 0
	local is_destory_effect = true
	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetGiftItemId(cfg[1].reward_item[0].item_id)
			for _, v2 in pairs(cfg[1].item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(false)
				v:SetActivityEffect()
			end

			v:SetData(item_list[k])
			item_cfg = ItemData.Instance:GetItemConfig(item_list[k].item_id)
		end
	end
	if display_role == 0 then
		item_cfg = ItemData.Instance:GetItemConfig(cfg[#cfg].reward_item[0].item_id)
		display_role = item_cfg and item_cfg.is_display_role or 0
	end
	local role_item_id = cfg[#cfg].reward_item[0].item_id
	self:SetRoleModel(display_role, role_item_id)
	self:SetFightPower(display_role, role_item_id)
end

function CompetitionActivityView:FlushInfo(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local type_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.activity_type)
	self.node_list["TextRank"].text.text = Language.Common.XuWeiYiDai
	if type_info then
		if type_info.top1_uid and type_info.top1_uid <= 0 then
			self.node_list["TxtPlayName"].text.text = Language.Activity.NoFirstRole
		else
			self.node_list["TxtPlayName"].text.text = string.format(Language.Activity.GetFirstRole, type_info.role_name or "")
		end
		if type_info.rank_info then
			if cfg and cfg[1] and type_info.rank_info[1] and type_info.rank_info[1].uid > 0 and type_info.rank_info[1].grade > cfg[1].cond3 then
				self.node_list["TextRank"].text.text = type_info.rank_info[1].name
				self.node_list["TextRank"]:SetActive(true)
			end
		end
	end

	local result = activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT and activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PERSON_CAPABILITY

	local type_list = RankData.Instance:GetRankTypeList()
	local cur_type = type_list[ACTIVITY_TYPE_TO_RANK_TYPE[self.activity_type]]
	local rank = RankData.Instance:GetMyInfoListByType(cur_type)
	local flag = rank == -1 or rank > 20
	if not flag then
		local rank_value = RankData.Instance:GetMyGradeInfoListByType(cur_type)
		if rank_value then
			if cfg and cfg[1] and rank_value <= cfg[1].cond3 then
				flag = true
			end
		end
	end
	self.node_list["TxtPlayerRank"].text.text = flag and Language.Common.NoRank or rank

	self.node_list["ImgZhisheng"]:SetActive(result)
	self.node_list["ImgXiangshi"]:SetActive(not result)
	
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	if self.activity_type == self.temp_activity_type then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			self.node_list["ListView"].scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type

	for k, v in pairs(self.cell_list) do
		v:SetRankType(self.activity_type)
		v:FlushRankInfo()
	end

	local item_gift_list = ItemData.Instance:GetGiftItemListByProf(cfg[1].reward_item[0].item_id)
	local item_list = {}
	local reward_list = cfg[#cfg].reward_item
	for k, v in pairs(reward_list) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
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

	for k, v in pairs(self.reward_item_list) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetData(item_list[k])
		end
	end

	self.node_list["TxtKeHuode"].text.text = string.format(Language.Competition.WhoCanGetDesc, cfg[#cfg].description)

	local day = self.day_type < GameEnum.NEW_SERVER_DAYS and self.day_type or 5
	local show_item_data = cfg[#cfg].reward_item[0]
	self.node_list["TxtWordReward"].text.text = ItemData.Instance:GetItemName(show_item_data.item_id)	--cfg[1].Language.BiPinActive[day]

	-- self.node_list["TxtWord"].text.text = cfg[1].activity_first_word
	local bundle, asset = "uis/views/competitionactivityview/images_atlas", "Competition_Activity_Get_all"  --.. cfg[1].seq_2
	self.node_list["ImageGet"].image:LoadSprite(bundle, asset, function()
				self.node_list["ImageGet"].image:SetNativeSize()
			end)
	self.node_list["TxtRewardDay"].text.text = cfg[1].activity_second_word
end


function CompetitionActivityView:FlushBtnReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)

	local is_reward = KaifuActivityData.Instance:IsGetReward(cfg[#cfg].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(cfg[#cfg].seq, self.activity_type)
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local can_reward = is_complete and not is_reward and server_day == self.day_type

	local str = is_reward and Language.HefuActivity.YiLingQu or Language.Common.LingQuJiangLi

	self.node_list["TxtBtn"].text.text = str
	self.node_list["ImgRedPoint"]:SetActive(can_reward)
	UI:SetButtonEnabled(self.node_list["BtnLingque"], can_reward) 
end

function CompetitionActivityView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime5, left_hour, left_min, left_sec)

		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function CompetitionActivityView:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
end


--移动坐骑，达到尾焰拖尾效果
function CompetitionActivityView:UpdateMountPosition()
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

function CompetitionActivityView:SetRoleModel(display_role, item_id)
	if display_role ==  DISPLAY_TYPE.WEIYAN then
		local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
			local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
			if mount_res_id <= 0 then
				return
			end
			local res_id = CompetitionActivityData.Instance:GetWeiYanRes(item_id)
			local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
			self.model:SetMainAsset(mount_bundle, mount_asset, function()
					local draw_root_obj = self.model.draw_obj:GetRoot()
				draw_root_obj.transform:SetParent(self.node_list["UICamera"].transform, true)
				if item_id == 22515 then
					self.model:SetLocalPosition(Vector3(0, -3.5, 14))--处理气球坐骑
				end
				self.model:SetWeiYanResid(res_id, mount_res_id,false)
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				self:CancelMountMoveTimeQuest()
				self:UpdateMountPosition()
				self.mount_move_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateMountPosition, self), 0.02)
			end)
			if item_id == 22515 then
				self.model:SetRotation(Vector3(0, 150, 0))
			else
				self.model:SetRotation(Vector3(0, 100, 0))
			end
		else
			self.model:ChangeModelByItemId(item_id)
		end
		local is_show = CompetitionActivityData.Instance:IsShowItemEffect(display_role)
		self.node_list["ModelEffect"]:SetActive(is_show)
end

function CompetitionActivityView:SetFightPower(display_role, item_id)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = ItemData.GetFightPower(item_id) or 0
	end
end

function CompetitionActivityView:SetModel(info, display_type)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info)
end


function CompetitionActivityView:OnFlush(param_list)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay() <= 14 and TimeCtrl.Instance:GetCurOpenServerDay() or 1
	self.node_list["ImgTitle"].image:LoadSprite("uis/views/competitionactivityview/images_atlas","title_bi_pin_" .. cur_day)
	self:FlushBtnReward()
	self:FlushInfo(COMPETITION_ACTIVITY_TYPE[self.day_type])
end



PanelSixListCell = PanelSixListCell or BaseClass(BaseRender)

function PanelSixListCell:__init(instance)
	self.cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		cell:SetShowOrangeEffect(true)
		self.cells[i] = cell
	end
	self.node_list["BtnActrank"].button:AddClickListener(BindTool.Bind(self.OnClickActPaiHangBang, self))
end

function PanelSixListCell:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.parent_view = nil
end

function PanelSixListCell:SetData(data, is_get, is_complete)
	if data == nil then return end
	self.data = data
	self.node_list["TxtKehuode"]:SetActive(data.seq > 3)
	self.node_list["TxtKehuode"].text.text = data.description	--string.format(Language.Competition.WhoCanGetDesc, data.description)
	self.node_list["ImgRank_2"]:SetActive(data.seq == 2)
	self.node_list["ImgRank_3"]:SetActive(data.seq == 3)
	self.node_list["BtnActrank"]:SetActive(false)
	-- self.node_list["TextRank"].text.text = Language.Common.XuWeiYiDai
	self.node_list["TextRank"]:SetActive(self.data.seq <= 3)
	self:FlushRankInfo()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}
	local gift_id = 0
	if self.data.seq == 4 then
		self.node_list["BtnActrank"]:SetActive(true)
	end

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

function PanelSixListCell:SetRankType(activity_type)
	self.activity_type = activity_type
end

function PanelSixListCell:FlushRankInfo()
	if self.data == nil then return end
	local type_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.activity_type)
	
	local bipin_rank_info = type_info and type_info.rank_info
	if bipin_rank_info then
		if self.data.seq == 2 and bipin_rank_info[2].uid and bipin_rank_info[2].uid > 0 and bipin_rank_info[2].grade > self.data.cond3 then
			self.node_list["TextRank"]:SetActive(true)
			self.node_list["TextRank"].text.text = bipin_rank_info[2].name
		elseif self.data.seq == 3 and bipin_rank_info[3].uid and bipin_rank_info[3].uid > 0 and bipin_rank_info[3].grade > self.data.cond3 then
			self.node_list["TextRank"]:SetActive(true)
			self.node_list["TextRank"].text.text = bipin_rank_info[3].name
		else
			self.node_list["TextRank"].text.text = Language.Common.XuWeiYiDai
		end
	end
	
end

-- 点击查看排行榜
function PanelSixListCell:OnClickActPaiHangBang()

		local index = PaiHangBang_Index[self.parent_view.day_type]
		if self.parent_view.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
			or self.parent_view.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
			self.parent_view.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		end
		RankCtrl.Instance:SendGetPersonRankListReq(self.parent_view.rank_type)
		ViewManager.Instance:Open(ViewName.Ranking,index)
end