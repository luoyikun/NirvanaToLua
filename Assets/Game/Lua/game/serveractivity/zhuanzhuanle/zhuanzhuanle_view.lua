ZhuangZhuangLeView = ZhuangZhuangLeView or BaseClass(BaseView)

local POINTER_ANGLE_LIST = {
	[1] = 0,
	[2] = -36,
	[3] = -72,
	[4] = -108,
	[5] = -144,
	[6] = -180,
	[7] = -216,
	[8] = -252,
	[9] = -288,
	[10] = -324,
}

function ZhuangZhuangLeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/serveractivity/zhuanzhuanle_prefab", "ZhuangZhuangLe"},
	}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
	self.click_reward = -1
	self.is_free = false 
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ZhuangZhuangLeView:__delete()
	
end

function ZhuangZhuangLeView:ReleaseCallBack()
	self.is_click_once = false

	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end

	for i = 1, 10 do
		self.item_list[i]:DeleteMe()
		self.item_list[i] = nil
	end

	for i = 1, 6 do
		self.reward_item_list[i]:DeleteMe()
		self.reward_item_list[i] = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end
end

function ZhuangZhuangLeView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_LOTTERY_TREE) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function ZhuangZhuangLeView:LoadCallBack()
	-- local bundle, asset = "uis/views/serveractivity/zhuanzhuanle/images_atlas", "title"
	-- self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.node_list["Name"].text.text = Language.Title.ShenDi
	self.node_list["PlayAniToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self.node_list["OneChouBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOnce, self))
	self.node_list["TenChouBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTence, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.close_button, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnHelpClick, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.item_list = {}
	for i = 1, 10 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item"..i])
	end
	self.reward_item_list = {}
	for i = 1, 6 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["rewarditem"..i])
		self.node_list["Button" .. i].button:AddClickListener(BindTool.Bind(self.GetAwardButton, self, i))
	end
	-- self:InitModle()
	self:FlushActEndTime()
end

function ZhuangZhuangLeView:OnToggleChange(is_on)
	ZhuangZhuangLeData.Instance:SetAniState(is_on)
end

-- function ZhuangZhuangLeView:InitModle()
-- 	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
-- 	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
-- 	for i, v in pairs(cfg) do
-- 		if open_day <= v.opengame_day then
-- 			local res_id = v.yaoqianshu_showmodel
-- 			self.model:ClearModel()
-- 			ItemData.ChangeModel(self.model, res_id, nil, ACTIVITY_TYPE.RAND_LOTTERY_TREE)
-- 			--self:ChangeModel(self.model, res_id)
-- 			break
-- 		end
-- 	end
-- end

function ZhuangZhuangLeView:SetModel()
	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	local reward_cfg = ZhuangZhuangLeData.Instance:GetCurDayConfig()
	local model_show = reward_cfg[1].model_show

	if model_show ~= nil and model_show ~= "" then
		local cfg_data = reward_cfg[1]
		if cfg_data.special_show == 2 then
			self.node_list["display"]:SetActive(false)	
			self.node_list["Anim"]:SetActive(true)
			local bundle = "uis/views/serveractivity/zhuanzhuanle/images/nopack_atlas"				-- 把策划配的图片放在自己的图集中,解除资源依赖
			local split_tb= Split(model_show, ",")
			self.node_list["ImgShow"].image:LoadSprite(bundle, split_tb[2])
			self.node_list["ImgShow"].image:SetNativeSize()
			-- self.node_list["Effect"]:SetActive(true)
			self.node_list["Effect"]:ChangeAsset(cfg_data.effect_bundle, cfg_data.effect_asset)
			local pos = Split(cfg_data.effect_pos, ",")
			local scale = Split(cfg_data.effect_scale, ",")
			self.node_list["Effect"].transform.localPosition = Vector3(pos[1], pos[2], pos[3])
			-- self.node_list["Effect"].transform.localScale = Vector3(scale[1], scale[2], scale[3])
			self.node_list["ImgShow"].transform.localScale = Vector3(scale[1], scale[2], scale[3])
		elseif cfg_data.special_show == 0 then
			self.node_list["display"]:SetActive(true)	
			self.node_list["Anim"]:SetActive(false)
			local main_role = Scene.Instance:GetMainRole()
			local game_vo = GameVoManager.Instance:GetMainRoleVo()
			local prof = game_vo.prof % 10
			local split_tb= Split(model_show, ";")
			local split_tbl = {}
			local is_resid = false
			if split_tb[2] ~= nil and split_tb[2] ~= "" then
				is_resid = true
				split_tbl = Split(split_tb[prof], ",")
			else
				is_resid = false
				split_tbl = Split(split_tb[1], ",")
			end
			local model_path = split_tbl[1]
			local model_id = split_tbl[2]
			if is_resid then
				self.model:ShowRest()
				self.model:SetRoleResid(model_id)
			else
				self.model:SetMainAsset(model_path, model_id)
			end
		end
	end
end

function ZhuangZhuangLeView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
end

-- function ZhuangZhuangLeView:ChangeModel(model, item_id, item_id2)
-- 	local cfg = ItemData.Instance:GetItemConfig(item_id)
-- 	if cfg == nil then
-- 		return
-- 	end

-- 	local display_role = cfg.is_display_role
-- 	local bundle, asset = nil, nil
-- 	local game_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local main_role = Scene.Instance:GetMainRole()
-- 	local res_id = 0

-- 	-- if model then
-- 	-- 	local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
-- 	-- 	local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
-- 	-- 	local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
-- 	-- 	model.display:SetRotation(Vector3(0, 0, 0))
-- 	-- 	if display_role ~= DISPLAY_TYPE.FOOTPRINT then
-- 	-- 		model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
-- 	-- 	end
-- 	-- 	if halo_part then
-- 	-- 		halo_part:RemoveModel()
-- 	-- 	end
-- 	-- 	if wing_part then
-- 	-- 		wing_part:RemoveModel()
-- 	-- 	end
-- 	-- 	if weapon_part then
-- 	-- 		weapon_part:RemoveModel()
-- 	-- 	end
-- 	-- end
-- 	if display_role == DISPLAY_TYPE.MOUNT then
-- 		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
-- 			if v.item_id == item_id then
-- 				bundle, asset = ResPath.GetMountModel(v.res_id)
-- 				res_id = v.res_id
-- 				model:SetRotation(Vector3(0, 45, 0))
-- 				break
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.WING then
-- 		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
-- 			if v.item_id == item_id then
-- 				bundle, asset = ResPath.GetWingModel(v.res_id)
-- 				res_id = v.res_id
-- 				break
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
-- 			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
-- 				if v.item_id == item_id then
-- 					res_id = v.res_id
-- 					break
-- 				end
-- 			end
-- 			model:SetRoleResid(main_role:GetRoleResId())
-- 			model:SetFootResid(res_id)
-- 			model.display:SetRotation(Vector3(0, -90, 0))
-- 			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
-- 	elseif display_role == DISPLAY_TYPE.FASHION then
-- 		local weapon_res_id = 0
-- 		local weapon2_res_id = 0
-- 		local item_id2 = item_id2 or 0
-- 		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
-- 			if v.item_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
-- 				if v.part_type == 1 then
-- 					res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
-- 				else
-- 					weapon_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
-- 					local temp = Split(weapon_res_id, ",")
-- 					weapon_res_id = temp[1]
-- 					weapon2_res_id = temp[2]
-- 				end
-- 			end

-- 		end
-- 		if res_id == 0 then
-- 			res_id = main_role:GetRoleResId()
-- 		end
-- 		if weapon_res_id == 0 then
-- 			weapon_res_id = main_role:GetWeaponResId()
-- 			weapon2_res_id = main_role:GetWeapon2ResId()
-- 		end

-- 		model:SetRoleResid(res_id)
-- 		model:SetWeaponResid(weapon_res_id)
-- 		if weapon2_res_id then
-- 			model:SetWeapon2Resid(weapon2_res_id)
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
-- 		local image_cfg = nil
-- 		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
-- 			if v.item_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
-- 				image_cfg = v
-- 				break
-- 			end
-- 		end
-- 		if image_cfg then
-- 			local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
-- 			local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
-- 			model:SetRoleResid(res_id)
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.HALO then
-- 			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
-- 				if v.item_id == item_id then
-- 					res_id = v.res_id
-- 					break
-- 				end
-- 			end
-- 			model:SetRoleResid(main_role:GetRoleResId())
-- 			model:SetHaloResid(res_id)
-- 	elseif display_role == DISPLAY_TYPE.SPIRIT then
-- 		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
-- 			if v.item_id and v.item_id== item_id then
-- 				bundle, asset = ResPath.GetSpiritModel(v.res_id)
-- 				res_id = v.res_id
-- 				break
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
-- 		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
-- 			if v.item_id == item_id then
-- 				bundle, asset = ResPath.GetFightMountModel(v.res_id)
-- 				res_id = v.res_id
-- 				break
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.SHENGONG then
-- 		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
-- 			if v.item_id == item_id then
-- 				res_id = v.res_id
-- 				local info = {}
-- 				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
-- 				info.weapon_res_id = v.res_id
-- 				self:SetModel(info)
-- 				return
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.SHENYI then
-- 		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
-- 			if v.item_id == item_id then
-- 				res_id = v.res_id
-- 				local info = {}
-- 				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
-- 				info.wing_res_id = v.res_id
-- 				self:SetModel(info)
-- 				return
-- 			end
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.XIAN_NV then
-- 		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
-- 		if goddess_cfg then
-- 			local xiannv_resid = 0
-- 			local xiannv_cfg = goddess_cfg.xiannv
-- 			if xiannv_cfg then
-- 				for k, v in pairs(xiannv_cfg) do
-- 					if v.active_item == item_id then
-- 						xiannv_resid = v.resid
-- 						break
-- 					end
-- 				end
-- 			end
-- 			if xiannv_resid == 0 then
-- 				local huanhua_cfg = goddess_cfg.huanhua
-- 				if huanhua_cfg then
-- 					for k, v in pairs(huanhua_cfg) do
-- 						if v.active_item == item_id then
-- 							xiannv_resid = v.resid
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end
-- 			if xiannv_resid > 0 then
-- 				local info = {}
-- 				info.role_res_id = xiannv_resid
-- 				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
-- 				self:SetModel(info)
-- 				return
-- 			end
-- 			res_id = xiannv_resid
-- 		end
-- 	elseif display_role == DISPLAY_TYPE.ZHIBAO then
-- 		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
-- 			if v.active_item == item_id then
-- 				bundle, asset = ResPath.GetFaBaoModel(v.image_id)
-- 				res_id = v.image_id
-- 				break
-- 			end
-- 		end
-- 	end

-- 	if bundle and asset and model then
-- 		model:SetMainAsset(bundle, asset)
-- 		if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
-- 			model:SetTrigger(ANIMATOR_PARAM.REST)
-- 		end
-- 	end

-- end

function ZhuangZhuangLeView:TipsClick()
	local tips_id = 194 -- 转转乐玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhuangZhuangLeView:GetLeijiReward(index)
	 -- local can_lin = ZhuangZhuangLeData.Instance:CanGetRewardBySeq(index)
	 -- if can_lin then
	local sort_list = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardSortData()
	if sort_list and sort_list[index] then
		local seq = sort_list[index].seq
		ZhuangZhuangLeData.Instance:SetLinRewardSeq(seq)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE , RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD , seq)	 
	end
end

function ZhuangZhuangLeView:ShowVipAndTime()
	-- local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardData()
	local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardSortData()
	local allaTreeTime = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	local used_time = ZhuangZhuangLeData.Instance:GetFreeTime() 
	local cfg_other = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local server_free_time = cfg_other .money_tree_free_times
	local server_total_money_tree_times = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	local need_once_money = cfg_other.money_tree_need_gold
	local need_tence_money = 30 * cfg_other.money_tree_need_gold
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	self.node_list["OnceMoneyTxt"].text.text = need_once_money
	self.node_list["TenceMonetTxt"].text.text = need_tence_money
	if server_free_time <= used_time then
		self.node_list["Dimonbg"]:SetActive(true)
		self.node_list["PointRed2"]:SetActive(false)
		self.node_list["FreeTimeTxt"]:SetActive(false)
		self.node_list["ShowTimeTxt"]:SetActive(false)
		self.is_free = false
	end
	for i = 1, 6 do
		if reward_cfg[i] then
			local vip_limit = reward_cfg[i].vip_limit or 0
			self.node_list["VipLevel" .. i].text.text = "VIP" .. vip_limit
			if allaTreeTime < reward_cfg[i].server_rock_times then
				self.node_list["BgEffect" .. i]:SetActive(false) 	
				self.node_list["IsTextVip" .. i]:SetActive(false)
				self.node_list["VipLevel" .. i]:SetActive(vip_limit > 0)
				self.node_list["CanRewardTxt" .. i]:SetActive(true)
				self.node_list["CanRewardTxt" .. i].text.text = string.format(Language.ZhuanZhuanLe.MiaoShu , server_total_money_tree_times , reward_cfg[i].server_rock_times)
			else 
				-- local flag = ZhuangZhuangLeData.Instance.server_reward_has_fetch_reward_flag[32 - i + 1]
				local flag = reward_cfg[i].fetch_reward_flag
				if 1 == flag then 
					self.node_list["CanRewardTxt" .. i].text.text = ""
					self.node_list["BgEffect" .. i]:SetActive(false)
					self.node_list["HasGetImg" .. i]:SetActive(true)
					self.node_list["VipLevel" .. i]:SetActive(false)
					self.node_list["IsTextVip" .. i]:SetActive(false)
					self.node_list["CanRewardTxt" .. i]:SetActive(true)
				else
					self.node_list["BgEffect" .. i]:SetActive(vip_level < reward_cfg[i].vip_limit and false or true)
					self.node_list["IsTextVip" .. i]:SetActive(true)
					self.node_list["VipLevel" .. i]:SetActive(false)
					self.node_list["CanRewardTxt" .. i]:SetActive(false)
					self.node_list["CanRewardTxt" .. i].text.text = Language.ZhuanZhuanLe.KeLingQu
				end
			end
		end
	end
end

function ZhuangZhuangLeView:SetItemImage()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = ZhuangZhuangLeData.Instance:GetOtherCfg()
	local cur_index = 0
	for i, v in pairs(other_cfg) do
		if open_time_day > v.opengame_day then
			cur_index = cur_index + 1
		else
			break
		end
	end
	for i = 1, 10 do
		self.item_list[i]:SetData(other_cfg[i + cur_index].reward_item)
	end

	-- local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardData()
	local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardSortData()
	for i = 1, 6 do
		if reward_cfg[i] then
			self.reward_item_list[i]:SetData(reward_cfg[i])
			self.node_list["rewarditem"..i]:SetActive(true)
		else
			self.node_list["rewarditem"..i]:SetActive(false)
		end
	end
end

function ZhuangZhuangLeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
end

function ZhuangZhuangLeView:CloseCallBack()
	self.click_reward = -1
	self.is_click_once = false
end

function ZhuangZhuangLeView:OnFlush() 
	self:show_reward_pool()
	self:FlushNextTime() 
	self:SetItemImage()
	self:ShowVipAndTime()
	if self.is_click_once and not self.node_list["PlayAniToggle"].toggle.isOn then
		self:TurnCell()
	elseif self.click_reward > -1 then
		local quick_use_time = 0
		if self.click_reward ~= CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
			TipsCtrl.Instance:ShowTreasureView(self.click_reward)
		end
		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end
		if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30 then
			quick_use_time = 3
		else
			quick_use_time = 1
		end
		self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)	
		end,quick_use_time)
		self.is_click_once = false
		self.node_list["PointRed2"]:SetActive(false)
		local reward_list = ZhuangZhuangLeData.Instance:GetRewardList()
		self:ResetHighLight()
		self:ShowHightLight()
		local angle = reward_list[1] and POINTER_ANGLE_LIST[reward_list[1] % 10 + 1] or 0
		self.node_list["center_point"].transform.localRotation = Quaternion.Euler(0, 0, angle)
	end
	self:SetModel()
	self:FlushKeyShow()
end

function ZhuangZhuangLeView:FlushKeyShow()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].money_tree_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.node_list["DimonImg"]:SetActive(item_num <= 0)
	self.node_list["KeyLableTxt"]:SetActive(item_num > 0)
	self.node_list["PointRed"]:SetActive(item_num > 0)

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["KeyTxt"].text.text = name_str
	self.node_list["YaoShiCount"].text.text = ToColorStr("X" .. item_num, TEXT_COLOR.GREEN)
end

function ZhuangZhuangLeView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	local time_str = JinYinTaData.Instance:GetActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
	local RunTick = time_tab.day >= 1 and 60 or 1
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), RunTick)
end

function ZhuangZhuangLeView:FlushUpdataActEndTime()
	local time_str = ZhuangZhuangLeData.Instance:GetActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
	if time_tab.day > 0 then
		self.node_list["ShenYuTimeTxt"].text.text = string.format(Language.ZhuanZhuanLe.ShenYuTime, time_tab.day, time_tab.hour)
	else
		self.node_list["ShenYuTimeTxt"].text.text = string.format("%02d:%02d:%02d", time_tab.hour, time_tab.min, time_tab.s)
	end
	if time_str <= 0 then
		-- 移除计时器
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end
		
	end
end

function ZhuangZhuangLeView:GetFreeTimes()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_other[1].free_time or 0
end

function ZhuangZhuangLeView:FlushNextTime()
	local cfg_time = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local uesd_times = ZhuangZhuangLeData.Instance:GetFreeTime() 

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
end

function ZhuangZhuangLeView:FlushCanNextTime()
	local time_str = ZhuangZhuangLeData.Instance:GetMianFeiTime()
	local cfg_time = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local next_free_time = cfg_time.money_tree_free_interval - time_str
	local uesd_times = ZhuangZhuangLeData.Instance:GetFreeTime() 
	local times = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_free_times
	self.is_free = false
	if uesd_times < times then
		--有免费次数
		if next_free_time <= 0 then
			-- 移除计时器
			if self.next_timer then
				GlobalTimerQuest:CancelQuest(self.next_timer)
				self.next_timer = nil
			end
			self.node_list["Dimonbg"]:SetActive(false)
			self.node_list["PointRed2"]:SetActive(true)
			self.node_list["FreeTimeTxt"]:SetActive(true)
			self.node_list["ShowTimeTxt"]:SetActive(false)
			self.is_free = true
		else
			self.node_list["Dimonbg"]:SetActive(true)
			self.node_list["PointRed2"]:SetActive(false)
			self.node_list["FreeTimeTxt"]:SetActive(false)
			self.node_list["ShowTimeTxt"]:SetActive(true)

			local time_tab = TimeUtil.Format2TableDHMS(next_free_time)
			self.node_list["ShowTimeTxt"].text.text = string.format(Language.ZhuanZhuanLe.Time, time_tab.hour, time_tab.min, time_tab.s) 
		end


	else
		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end 
		self.node_list["Dimonbg"]:SetActive(true)
		self.node_list["PointRed2"]:SetActive(false)
		self.node_list["FreeTimeTxt"]:SetActive(false)
		self.node_list["ShowTimeTxt"]:SetActive(false)
	end
end

function ZhuangZhuangLeView:TurnCell()
	local other_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()
	local reward_list = ZhuangZhuangLeData.Instance:GetRewardList()
	local quick_use_time = 0
	if is_rolling then return end
	self:ResetVariable()
	self:ResetHighLight()
	self.is_rolling = true 
	local time = 0
	local tween = self.node_list["center_point"].transform:DORotate(
	Vector3(0, 0, -360 * 20),20,
	DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local angle = POINTER_ANGLE_LIST[reward_list[1] % 10 + 1]
			local tween1 = self.node_list["center_point"].transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self.is_rolling = false
				self:ShowHightLight()
				TipsCtrl.Instance:ShowTreasureView(self.click_reward)
				if self.show_reward_panel then
					GlobalTimerQuest:CancelQuest(self.show_reward_panel)
					self.show_reward_panel = nil
				end
				if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30 then
					quick_use_time = 3
				else
					quick_use_time = 1
				end
				self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)	
					end,quick_use_time)
			end)
		end
	end)
end

function ZhuangZhuangLeView:show_reward_pool()
	self.node_list["RewardGoldTxt"].text.text = ZhuangZhuangLeData.Instance:GetServerMoneyTreePoolGold()
end

function ZhuangZhuangLeView:GetAwardButton(index)
	self.is_click_once = false
	self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD
	local allTreeTime = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	self:GetLeijiReward(index)
end

function ZhuangZhuangLeView:ShowHightLight()
	local reward_list = ZhuangZhuangLeData.Instance:GetRewardList()
	if reward_list == nil or reward_list[1] == nil then return end
	local hight_light_index = reward_list[1] % 10 + 1 or 1
	if self.node_list["LightEffect" .. hight_light_index] then
		self.node_list["LightEffect" .. hight_light_index]:SetActive(true)
	end
end

function ZhuangZhuangLeView:OnClickOnce()
	local ZhuanZhuanLeInfo =  ZhuangZhuangLeData.Instance:GetZhuanZhuanLeInfo()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold
	if self.is_rolling then
		return
	end
	if self.is_free then
		self.is_click_once = true
		ZhuangZhuangLeData.Instance:SetAniState(self.node_list["PlayAniToggle"].toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1
		self:PointerTrunAround(1)
	else 
		local func = function()
			self.is_click_once = true
			ZhuangZhuangLeData.Instance:SetAniState(self.node_list["PlayAniToggle"].toggle.isOn)
			self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1
			self:PointerTrunAround(1)
		end
		local tip_text = string.format(Language.ZhuanZhuanLe.TiShiOnce, need_diamon)
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, true)
	end
end

function ZhuangZhuangLeView:OnClickTence()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold * 30
	if self.is_rolling then
		return
	end

	local func = function()
		self.is_click_once = true
		self:OnOperate()
	end

	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].money_tree_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	if self.is_click_once or item_num > 0 then
		self:OnOperate()
	else
		 local tip_text = string.format(Language.ZhuanZhuanLe.TiShiTence, need_diamon )
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, true)
	end
end

function ZhuangZhuangLeView:OnOperate()
	ZhuangZhuangLeData.Instance:SetAniState(self.node_list["PlayAniToggle"].toggle.isOn)
	self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30
	self:PointerTrunAround(30)
end


function ZhuangZhuangLeView:OnHelpClick()
	local tips_id = 194
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhuangZhuangLeView:close_button()
	if self.is_rolling then
		return
	end
	self:Close()
end

function ZhuangZhuangLeView:PointerTrunAround(index)
	if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		if index == 1 then
			self.node_list["PointRed2"]:SetActive(false)
		end
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU, index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function ZhuangZhuangLeView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function ZhuangZhuangLeView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function ZhuangZhuangLeView:ResetHighLight()
	for i = 1, 10 do
		self.node_list["LightEffect" .. i]:SetActive(false)
	end
end
