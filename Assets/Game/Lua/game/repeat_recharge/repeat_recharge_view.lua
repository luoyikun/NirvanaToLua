
RepeatRechargeView = RepeatRechargeView or BaseClass(BaseView)

function RepeatRechargeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/repeatrecharge_prefab", "RepeatRecharge"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
		{"uis/views/randomact/repeatrecharge_prefab", "RepeatRechargeLeftDisplay"},
	}
	self.play_audio = true
	self.full_screen = false

	self.is_show = false
	self.show_display = nil
	self.title = nil
	self.fashion_role_model = nil
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RepeatRechargeView:LoadCallBack()

	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/randomact/repeatrecharge/images_atlas", "title_bg" )
	-- self.node_list["ImgTitle"].image:SetNativeSize()

	self.node_list["Name"].text.text = Language.Title.XunHuan
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGetReard"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.node_list["Effet"]:SetActive(true)
	self.node_list["BtnAddGold"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi,self))

	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.item_list, item)
	end
	
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount2"])
end

function RepeatRechargeView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RepeatRechargeView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.item_list = {}
	self.fight_text = nil
end

function RepeatRechargeView:OpenCallBack()
	RepeatRechargeCtrl.Instance:SendAllInfoReq()
	self:Flush()
	self:FlushModel()
end

function RepeatRechargeView:CloseCallBack()
end

-- click callback -----------------------------------------------------
function RepeatRechargeView:OnClickGetReward()
	RepeatRechargeCtrl.Instance:SendGetReward()
end

-- flush func ---------------------------------------------------------

local cfg_index_t = {"wuqi_index" , "taozhuang_index" , "zuji_index", "guanghuan_index", "chibang_res"}
function RepeatRechargeView:OnFlush()
	-- 活动剩余时间刷新
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	-- 当前充值 
	local chongzhi_info = RepeatRechargeData.Instance:GetCirculationChongzhiInfo()
	local total_recharge = chongzhi_info.total_chongzhi or 0
	self.node_list["TxtActTime2"].text.text = CommonDataManager.ConverMoney(total_recharge)

	local day_cfg = RepeatRechargeData.Instance:GetCirculationChongzhiRewardShowData()
	self.node_list["TxtLimit"].text.text = day_cfg.need_chongzhi_gold or 0 
	
	local cur_chongzhi = chongzhi_info.cur_chongzhi or 0
	local num = math.floor(cur_chongzhi / day_cfg.need_chongzhi_gold)
	self.node_list["TxtCanGet"].text.text =string.format(Language.RepeatRecharge.TextNumber, num)
	self.node_list["ImgProgressBG"].slider.value = cur_chongzhi / day_cfg.need_chongzhi_gold
	self.node_list["TxtHasRecharge"].text.text = string.format(Language.RepeatRecharge.TodayRecharge, cur_chongzhi, day_cfg.need_chongzhi_gold or 0)

	-- 礼包展示
	local reward_item_list = ItemData.Instance:GetGiftItemList(day_cfg.reward_item.item_id)
	for i = 1, 4 do
		if nil ~= reward_item_list[i] then
			self.item_list[i]:SetActive(true)
			self.item_list[i]:SetData(reward_item_list[i])
		else
			self.item_list[i]:SetActive(false)
		end
	end

	-- 按钮特效展示
	local is_can_get_reward = chongzhi_info.cur_chongzhi >= day_cfg.need_chongzhi_gold
	UI:SetButtonEnabled(self.node_list["BtnGetReard"], is_can_get_reward)
	self.node_list["ImgeRemind"]:SetActive(is_can_get_reward)
	local show_power = 0
	for k,v in pairs(cfg_index_t) do
		if day_cfg[v] then
			show_power = show_power + ItemData.GetFightPower(day_cfg[v])
		end
	end
	if day_cfg.res_id > 0 then
		show_power = show_power + ItemData.GetFightPower(day_cfg.res_id)
	end
 	self.node_list["TxtCount"].text.text = show_power
 	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = show_power
	end
end

function RepeatRechargeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.JinYinTa.ActEndTime,time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtActTime1"].text.text = time_str

end

function RepeatRechargeView:FlushModel()
	local day_cfg = RepeatRechargeData.Instance:GetCirculationChongzhiRewardShowData()
	-- 形象展示
	if day_cfg.show_type == "people" then
		local main_role = Scene.Instance:GetMainRole()
		self.model:SetRoleResid(main_role:GetRoleResId())
		if day_cfg.wuqi_index and day_cfg.wuqi_index > 0 then
			self:ChangeModule(self.model, day_cfg.wuqi_index)
		end

		if day_cfg.taozhuang_index and day_cfg.taozhuang_index > 0 then
			self:ChangeModule(self.model, day_cfg.taozhuang_index)
		end

		if day_cfg.zuji_index and day_cfg.zuji_index > 0 then
			self:ChangeModule(self.model, day_cfg.zuji_index)
		end

		if day_cfg.guanghuan_index and day_cfg.guanghuan_index > 0 then
			self:ChangeModule(self.model, day_cfg.guanghuan_index)
		end

		if day_cfg.chibang_res and day_cfg.chibang_res > 0 then
			self:ChangeModule(self.model, day_cfg.chibang_res)
		end
	else
		ItemData.ChangeModel(self.model, day_cfg.res_id or 22301)
	end
end

function RepeatRechargeView:ChangeModule(model, item_id, item_id2)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	
	if display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		model:SetWingResid(res_id)
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetFootResid(res_id)
			model.display:SetRotation(Vector3(0, -45, 0))
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
					model:SetRoleResid(res_id)
				else
					weapon_res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]

					if weapon_res_id == 0 then
						weapon_res_id = main_role:GetWeaponResId()
						weapon2_res_id = main_role:GetWeapon2ResId()
					end

					model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						model:SetWeapon2Resid(weapon2_res_id)
					end
				end
			end
		end
	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
		local image_cfg = nil
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
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
			model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	end
	if bundle and asset and model then
		model:SetMainAsset(bundle, asset)
	end

end
