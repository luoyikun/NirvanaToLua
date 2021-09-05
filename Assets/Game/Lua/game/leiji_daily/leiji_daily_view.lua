LeiJiDailyView = LeiJiDailyView or BaseClass(BaseView)

local WINGRESID = {
	RES_1 = 8104001,
	RES_2 = 8108001,
}

local LEIJI_REWARD_MAX_NUM = 4
local ACTIVE_REWARD_MAX_NUM = 5

function LeiJiDailyView:__init()
	self.ui_config = {{"uis/views/leijirechargeview_prefab", "LeiJiDailyView"}}
	self.full_screen = false
	self.play_audio = true
	self.auto_close_time = 0
	self.is_stop_task = false
	self.temp_select_index = -1
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LeiJiDailyView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnDraw"].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self))
	self.node_list["BtnDrawActive"].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self))
	self.person_glal_change_handle = GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE, BindTool.Bind(self.Flush, self))

	self.cell_list = {}
	self.items_list = {}

	self.current_index = 1
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for i = 1, LEIJI_REWARD_MAX_NUM do
		self.items_list[i] = ItemCell.New()
		self.items_list[i]:SetInstanceParent(self.node_list["Item"..i])
		self.items_list[i]:SetShowOrangeEffect(true)
	end

	self.active_flag = true
	self.active_items_list = {}
	for i = 1, ACTIVE_REWARD_MAX_NUM do
		self.active_items_list[i] = ItemCell.New()
		self.active_items_list[i]:SetInstanceParent(self.node_list["ActiveItem"..i])
		self.active_items_list[i]:SetShowOrangeEffect(true)
		self.active_items_list[i]:ShowHighLight(false)
	end
end

function LeiJiDailyView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.items_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.active_items_list) do
		v:DeleteMe()
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.items_list = {}
	self.cell_list = {}
	self.active_items_list = {}
	self.fight_text = nil

	self.active_flag = nil
	if self.person_glal_change_handle then
		GlobalEventSystem:UnBind(self.person_glal_change_handle)
		self.person_glal_change_handle = nil
	end
end

function LeiJiDailyView:GetNumberOfCells()
	local cfg = DailyChargeData.Instance:GetTotalLeijiDailyReward()
	return #cfg
end

function LeiJiDailyView:RefreshCell(cell, cell_index)
	-- 默认活跃奖励放第一个
	cell_index = cell_index + 1
	local target_cell = self.cell_list[cell]
	if target_cell == nil then
		target_cell = LeiJIRechargeCell.New(cell.gameObject)
		target_cell.view = self
		self.cell_list[cell] = target_cell
	end

	local data_list = DailyChargeData.Instance:GetTotalLeijiDailyReward()
	target_cell:SetIndex(cell_index)
	target_cell:SetData(data_list[cell_index])
end

function LeiJiDailyView:OpenCallBack()
	-- RemindManager.Instance:SetTodayDoFlag(RemindName.DailyLeiJi)
	self.current_index = DailyChargeData.Instance:GetLeijiDailyViewCurIndex()
	self.is_open_active_reward = DailyChargeData.Instance:GetIsOpenActiveReward2()

	if self.is_open_active_reward and self.current_index == 1 then
		self.active_flag = true
	else
		self.active_flag = false
	end

	self:Flush()
end

function LeiJiDailyView:OnClickClose()
	self:Close()
end

function LeiJiDailyView:OnClickDraw()
	if self.is_open_active_reward and self.current_index == 1 then
		self:DrawActiveReward()
	else
		self:DrawLeiJiReward()
	end
end

function LeiJiDailyView:DrawLeiJiReward()
	local cfg = DailyChargeData.Instance:GetTotalLeijiDailyReward()
	local info = DailyChargeData.Instance:GetChongZhiInfo()
	if next(cfg) == nil or next(info) == nil then
		return
	end
	local list = info.daily_chongzhi_fetch_reward2_flag
	local today_recharge = info.today_recharge
	local cur_cfg = cfg[self.current_index]
	if list[32 - cur_cfg.seq] ~= 1 and today_recharge < cur_cfg.need_chongzhi then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
		ViewManager.Instance:Close(ViewName.LeiJiDailyView)
	else
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY2, cur_cfg.seq, 0)
	end
end

function LeiJiDailyView:DrawActiveReward()
	local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCH_ACTIVE_REWARD_IN_LEIJI_DAILY_VIEW, active_reward_info.cur_index - 1)
end

function LeiJiDailyView:SetNextCurrentIndex()
	local reward_info = DailyChargeData.Instance:GetDailyLeiJiRewardDay()
	local active_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	local open_flag = DailyChargeData.Instance:GetIsOpenActiveReward2()
	local reward_count = #reward_info
	if next(reward_info) == nil then
		return
	end

	-- 出现活跃度奖励
	if open_flag then
		if next(active_info) == nil then
			return
		end
		if self.current_index == 1 and ZhiBaoData.Instance:IsShowActiveRewardRedPoint() then
			return
		end
		if self.current_index == 1 and DailyChargeData.Instance:IsLeijiRewardRedPoint() == false then
			if ZhiBaoData.Instance:IsShowActiveRewardRedPoint() then
				return
			end
		end
	end
	-- 每日累充奖励有红点情况下的跳转
	local index = open_flag and 2 or 1
	reward_count = open_flag and reward_count + 1 or reward_count
	for i = index, reward_count do
		if DailyChargeData.Instance:GetDailyChargeRedPointByIndex(i) then
			self.current_index = i
			return
		end
	end
	-- 每日累充奖励没有红点情况下的跳转
	local leiji_reward_index = DailyChargeData.Instance:GetDailyChargeNowIndex()
	if leiji_reward_index == -1 then
		if open_flag and active_info.reward_on_day_flag_list[5] == 0 then
			self.current_index = 1
		end
		return
	end
	self.current_index = leiji_reward_index
end

function LeiJiDailyView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "list_index" then
			self:SetCurrentIndex(v.list_index)
		end
	end
	
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self:FlushLeftList()
	self:SetModel()

	self.active_flag = self.current_index == 1 and DailyChargeData.Instance:GetIsOpenActiveReward2()
	self.node_list["PlaneRight"]:SetActive(not self.active_flag)
	self.node_list["PlaneActive"]:SetActive(self.active_flag)
	self.node_list["RewardBg"]:SetActive(self.active_flag)
	if self.active_flag then
		self:FlushActiveContent()
	else
		self:FlushRightContent()
	end
end

function LeiJiDailyView:SetCurrentIndex(index)
	if self.current_index == index then 
		return
	end
	self.current_index = index or 1

	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self:FlushLeftList()

	self.active_flag = self.current_index == 1 and DailyChargeData.Instance:GetIsOpenActiveReward2()
	self.node_list["PlaneRight"]:SetActive(not self.active_flag)
	self.node_list["PlaneActive"]:SetActive(self.active_flag)
	self.node_list["RewardBg"]:SetActive(self.active_flag)
	if self.active_flag then
		self:FlushActiveContent()
	else
		self:FlushRightContent()
	end
end

function LeiJiDailyView:FlushLeftList()
	for k,v in pairs(self.cell_list) do
		v:FlushIsSelected(self.current_index)
	end
end

function LeiJiDailyView:FlushRightContent()
	local cfg, max_seq = DailyChargeData.Instance:GetTotalLeijiDailyReward()
	local cur_cfg = cfg[self.current_index]
	if cur_cfg == nil or next(cur_cfg) == nil or next(cfg) == nil then
		return
	end

	-- 设置item
	local effect_list = Split(cur_cfg.item_effect, ",")
	for k, v in pairs(self.items_list) do
		if cur_cfg.reward_item[k - 1] then
			v:SetData(cur_cfg.reward_item[k - 1])
			if tonumber(effect_list[k]) == 1 then
				-- v:ShowSpecialEffect(true)
				local bunble, asset = ResPath.GetItemActivityEffect()
				v:SetSpecialEffect(bunble, asset)
			end
			v:SetActive(true)
			self.node_list["Item"..k]:SetActive(true)
		else
			v:SetActive(false)
			self.node_list["Item"..k]:SetActive(false)
		end
	end
	if cur_cfg.reward_item and #cur_cfg.reward_item == 2 then
		self.node_list["Taizi3"]:SetActive(true)
		self.node_list["Taizi4"]:SetActive(false)
	elseif cur_cfg.reward_item and #cur_cfg.reward_item == 3 then
		self.node_list["Taizi3"]:SetActive(false)
		self.node_list["Taizi4"]:SetActive(true)
	end

	-- 设置按钮
	local seq_list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	if seq_list[32 - cur_cfg.seq] ~= 1 and today_recharge >= cur_cfg.need_chongzhi then
		self.node_list["TxtBtn"].text.text = Language.Common.LingQuJiangLi
		UI:SetButtonEnabled(self.node_list["BtnDraw"], true)
	elseif seq_list[32 - cur_cfg.seq] == 1 then
		self.node_list["TxtBtn"].text.text = Language.Common.YiLingQu
		UI:SetButtonEnabled(self.node_list["BtnDraw"], false)
	else
		self.node_list["TxtBtn"].text.text = Language.Recharge.GoReCharge
		UI:SetButtonEnabled(self.node_list["BtnDraw"], true)
	end
	self.node_list["TxtRecharge"].text.text = cur_cfg.need_chongzhi
	self.node_list["HasGoldText"].text.text = today_recharge
end

function LeiJiDailyView:FlushActiveContent()
	local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	if next(active_reward_info) == nil then
		return
	end

	local total_degree = active_reward_info.total_degree
	local max_reward_num = #active_reward_info.reward_list
	local degree_limit = active_reward_info.reward_list[active_reward_info.cur_index].degree_limit
	local has_reach = max_reward_num
	for i,v in ipairs(active_reward_info.reward_list) do
		if v.degree_limit > total_degree then
			has_reach =  i - 1
			break
		end
	end

	local flag = total_degree >= degree_limit and active_reward_info.reward_on_day_flag_list[has_reach] == 0
	self.node_list["TxtActiveBtn"].text.text = Language.Common.LingQuJiangLi
	UI:SetButtonEnabled(self.node_list["BtnDrawActive"], flag)

	self.node_list["TxtSlider"].text.text = total_degree
	local show_all = active_reward_info.reward_on_day_flag_list[max_reward_num] == 1
	self.node_list["TxtCanGet"]:SetActive(not show_all)
	self.node_list["TxtAllGet"]:SetActive(show_all)
	-- 进度条(换算到精准位置)
	local pro_conver_list = {{0, 0}, {20, 0.2}, {40, 0.4}, {60, 0.6}, {80, 0.8}, {100, 1.0}}
	local pro_list_limit = pro_conver_list[#pro_conver_list][1]
	for i = #pro_conver_list,1,-1 do
		if total_degree >= pro_conver_list[i][1] and total_degree < pro_list_limit then
			local diff = total_degree - pro_conver_list[i][1]
			local bili = (pro_conver_list[i+1][2] - pro_conver_list[i][2]) / (pro_conver_list[i+1][1] - pro_conver_list[i][1])
			local pro = diff * bili + pro_conver_list[i][2]
			self.node_list["Slider"].slider.value = pro
			break
		elseif total_degree == pro_list_limit then
			self.node_list["Slider"].slider.value = pro_conver_list[#pro_conver_list][2]
		elseif total_degree > pro_list_limit then
			self.node_list["Slider"].slider.value = 1
		end
	end
	
	for i = 1, #self.active_items_list do
		self.active_items_list[i]:SetData(active_reward_info.reward_list[i].item)
		self.node_list["ImageHasGot" .. i]:SetActive(active_reward_info.reward_on_day_flag_list[i] == 1)
		self.node_list["Effect" .. i]:SetActive(i <= has_reach and active_reward_info.reward_on_day_flag_list[i] == 0)
		local effect_flag = (i <= has_reach and active_reward_info.reward_on_day_flag_list[i] == 0)
		local click_func = nil
		if effect_flag == true then
			click_func = function()
			if nil == i then return end
			ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCH_ACTIVE_REWARD_IN_LEIJI_DAILY_VIEW, i - 1)
			AudioService.Instance:PlayRewardAudio()
			end
		else
			click_func = function() TipsCtrl.Instance:OpenItem(active_reward_info.reward_list[i].item) end
		end
		self.active_items_list[i]:ListenClick(click_func)
	end

	if has_reach <= max_reward_num then
		local reach = has_reach == max_reward_num and max_reward_num or (has_reach + 1)
		local diff = active_reward_info.reward_list[reach].degree_limit - total_degree
		diff = diff > 0 and diff or 0
		self.node_list["TxtActiveNum"].text.text = diff
	end
end

function LeiJiDailyView:SetModel()
	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	local now_reward_cfg = DailyChargeData.Instance:GetLeijiDailyShowModelItemId()
	local model_show = now_reward_cfg.model_show
	if model_show == "" then
		local model_item_id = now_reward_cfg.model_item_id or 0
		local cfg = ItemData.Instance:GetItemConfig(model_item_id)
		if cfg == nil then
			return
		end

		if cfg.is_display_role == DISPLAY_TYPE.HEAD_FRAME then
			self.node_list["Ani"]:SetActive(false)
			self.node_list["Display"]:SetActive(false)
			self.node_list["HeadImg"]:SetActive(true)
			local index = HeadFrameData.Instance:GetPrefabByItemId(model_item_id)
			if index >= 0 then
				self.node_list["HeadImg"].image:LoadSprite(ResPath.GetHeadFrameIcon(index))
			end

		elseif cfg.is_display_role == DISPLAY_TYPE.BUBBLE then
			self.node_list["Display"]:SetActive(false)
			self.node_list["HeadImg"]:SetActive(false)
			self.node_list["Ani"]:SetActive(true)						
			local index = CoolChatData.Instance:GetBubbleIndexByItemId(model_item_id)
			if index > 0 then
				local PrefabName = "BubbleChat" .. index
				local async_loader = AllocAsyncLoader(self, "bubble_chat_load")
				local bundle = "uis/chatres/bubbleres/bubble" .. index .. "_prefab"
				async_loader:Load(bundle, PrefabName, function(obj)
					if not IsNil(obj) then
						obj.transform:SetParent(self.node_list["Ani"].transform, false)
					end
				end)
			end
		else
			self.node_list["Ani"]:SetActive(false)
			self.node_list["HeadImg"]:SetActive(false)
			self.node_list["Display"]:SetActive(true)
			self.model:ClearFoot()
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			self.model:ChangeModelByItemId(model_item_id)
			--LeiJiDailyView.ChangeModel(self.model, model_item_id)			
		end

		self.node_list["TxtTabName"].text.text = cfg.name
		local power_text = ItemData.GetFightPower(model_item_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power_text
		end
	else
		self.node_list["Ani"]:SetActive(false)
		self.node_list["HeadImg"]:SetActive(false)
		self.node_list["Display"]:SetActive(true)		
		if now_reward_cfg.model_name then
			self.node_list["TxtTabName"].text.text = now_reward_cfg.model_name
		end
		local split_tbl = Split(model_show, ",")
		local model_path = split_tbl[1]
		local model_id = split_tbl[2]
		self.model:SetMainAsset(split_tbl[1], split_tbl[2])
		if self.fight_text and self.fight_text.text and now_reward_cfg.fightpower then
			self.fight_text.text.text = now_reward_cfg.fightpower
		end		
	end
	local text = 0
	if now_reward_cfg.need_chongzhi >= 10000 then
		self.node_list["ImageWan"]:SetActive(true)
		self.node_list["TxtNeedGold"]:SetActive(false)
		text = math.ceil(now_reward_cfg.need_chongzhi / 10000)
	else
		self.node_list["TxtNeedGold"]:SetActive(true)
		self.node_list["ImageWan"]:SetActive(false)
		text = now_reward_cfg.need_chongzhi
	end
	self.node_list["TxtNeedGold"].text.text = text
	self.node_list["WanTxtNeedGold"].text.text = text
end

function LeiJiDailyView.ChangeModel(model, item_id, item_id2)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	local rotation = 0
	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	if model then
		local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
		model.display:SetRotation(Vector3(0, 0, 0))
		if display_role ~= DISPLAY_TYPE.FOOTPRINT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				rotation = -45
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetFootResid(res_id)
			model.display:SetRotation(Vector3(0, -90, 0))
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfg()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
				else
					weapon_res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
			end
		end
		if res_id == 0 then
			res_id = main_role:GetRoleResId()
		end
		if weapon_res_id == 0 then
			weapon_res_id = main_role:GetWeaponResId()
			weapon2_res_id = main_role:GetWeapon2ResId()
		end
		model:SetRoleResid(res_id)
		model:SetWeaponResid(weapon_res_id)
		if weapon2_res_id then
			model:SetWeapon2Resid(weapon2_res_id)
		end
	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
		local image_cfg = nil
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == item_id then
				image_cfg = v
				break
			end
		end
		if image_cfg then
			local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
			local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
			model:SetRoleResid(res_id)
		end
	elseif display_role == DISPLAY_TYPE.HALO then
		for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		model:SetRoleResid(main_role:GetRoleResId())
		model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id and v.item_id== item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.weapon_res_id = v.res_id
				ItemData.SetModel(model, info)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.wing_res_id = v.res_id
				ItemData.SetModel(model, info)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
			end
			res_id = xiannv_resid
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == item_id then
				bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
				res_id = v.image_id
				break
			end
		end
	end
	if bundle and asset and model then
		model:SetMainAsset(bundle, asset, function()
			if rotation ~= 0 then
				model:SetRotation(Vector3(0,rotation,0))
				model:SetLocalPosition(Vector3(0,0,-0.9))
			else
				model:SetRotation(Vector3(0,0,0))
				model:SetLocalPosition(Vector3(0,0,0))
			end
		end)
		if display_role == DISPLAY_TYPE.XIAN_NV or
			display_role == DISPLAY_TYPE.SPIRIT then
			model:SetTrigger("show_idle_1")
		elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
		end
	end
end


LeiJIRechargeCell = LeiJIRechargeCell or BaseClass(BaseCell)

function LeiJIRechargeCell:__init(obj, i)
	self.view = nil
	self.node_list["BtnCell"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["ImgHL"]:SetActive(false)
end

function LeiJIRechargeCell:__delete()
	self.data = nil
	self.view = nil
end

function LeiJIRechargeCell:SetIndex(index)
	self.index = index
end

function LeiJIRechargeCell:SetData(data)

	local open_flag = DailyChargeData.Instance:GetIsOpenActiveReward2()
	if open_flag and self.index == 1 then
		self:SetActiveData(data)
		return
	end
	self.data = data
	local text = 0
	if self.data.need_chongzhi >= 10000 then
		text = self.data.need_chongzhi / 10000 .. Language.Recharge.Wan
	else
		text = self.data.need_chongzhi
	end
	self.node_list["TxtGold"].text.text = text
	self.node_list["NormalGoldText"].text.text = text
	--self.node_list["Gold"]:SetActive(true)
	--self.node_list["NormalGold"]:SetActive(true)
	self.node_list["NormalGoldText"]:SetActive(true)
	self.node_list["GoldImg"]:SetActive(true)
	self.node_list["TxtGold"]:SetActive(true)
	self.node_list["RewardTxt"]:SetActive(false)
	self:FlushIsSelected(self.view.current_index)

	-- 标签红点
	local seq_list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
	local has_got = seq_list[32 - self.data.seq] == 1
	self.node_list["ImgHasGot"]:SetActive(has_got)
	self.node_list["ImgRedPoint"]:SetActive(DailyChargeData.Instance:GetDailyChargeRedPointByIndex(self.index))
end

function LeiJIRechargeCell:SetActiveData(data)
	self.node_list["TxtGold"]:SetActive(false)
	self.node_list["NormalGoldText"]:SetActive(false)
	self.node_list["Gold"]:SetActive(false)
	self.node_list["NormalGold"]:SetActive(false)
	self.node_list["GoldImg"]:SetActive(false)
	self.node_list["RewardTxt"]:SetActive(true)
	self:FlushIsSelected(self.view.current_index)

	local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	self.node_list["ImgHasGot"]:SetActive(active_reward_info.reward_on_day_flag_list[5] == 1)
	self.node_list["ImgRedPoint"]:SetActive(ZhiBaoData.Instance:IsShowActiveRewardRedPoint())
end

function LeiJIRechargeCell:OnClick()
	self.view:SetCurrentIndex(self.index)
end

function LeiJIRechargeCell:FlushIsSelected(index)
	self.node_list["ImgHL"]:SetActive(index == self.index)
	-- self.node_list["TxtGold"]:SetActive(index == self.index)
	-- self.node_list["NormalGoldText"]:SetActive(not (index == self.index) )
end