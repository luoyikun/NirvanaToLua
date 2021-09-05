AdvancedReturnTwoView = AdvancedReturnTwoView or BaseClass(BaseView)

function AdvancedReturnTwoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
		{"uis/views/advancedreturn_prefab", "AdvancedReturnView"},

	}
	self.play_audio = true
	-- self.is_flush = true
	self.is_stop_load_effect = false
	self.is_modal = true									-- 是否模态
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
end

function AdvancedReturnTwoView:__delete()

end

function AdvancedReturnTwoView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.act_item then
		self.act_item:DeleteMe()
		self.act_item = nil
	end
	self:CancelMountMoveTimeQuest()
end

function AdvancedReturnTwoView:LoadCallBack()

	self.degree_data = {}
	self.cell_list = {}
	self.res_id = 0
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list_delegate1 = self.node_list["ActListView"].list_simple_delegate
	list_delegate1.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate1.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.display_camera_init_pos = self.node_list["UICamera"].transform.position

	self.act_item = ItemCell.New()
	self.act_item:SetInstanceParent(self.node_list["ActItemCell"])

	self.node_list["ShopBtn"].button:AddClickListener(BindTool.Bind(self.GoShoplevelDan, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OpenJinJieView, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function AdvancedReturnTwoView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
end

function AdvancedReturnTwoView:CloseCallBack()
	self:CancelMountMoveTimeQuest()
end

function AdvancedReturnTwoView:OnRoleDrag(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AdvancedReturnTwoView:GoShoplevelDan()
	local act_item , act_grade = AdvancedReturnTwoData.Instance:GetReturnShowItemCfg()
	local item_cfg = ItemData.Instance:GetItemConfig(act_item) 
	if item_cfg == nil then
		return
	end
	local price = AdvancedReturnTwoData.Instance:GetReturnNeedGoldCfg()
	local role_money = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	local func = function ()
		if role_money >= price then
				if bags_grid_num >= 1 then
					AdvancedReturnTwoCtrl.Instance:SendRandShopBuyReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2,act_item)
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
				end
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.AdvancedReturnTips, price, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name))
end

function AdvancedReturnTwoView:OnClickClose()
	self:Close()
end
function AdvancedReturnTwoView:FlushTextInfo()
	local upgrade_return_info = AdvancedReturnTwoData.Instance:GetUpGradeReturnInfo()
	self.act_type = upgrade_return_info.act_type

	local info_grade, bubble, asset, res_id = AdvancedReturnTwoData.Instance:GetImageResPath(self.act_type)
	if nil == info_grade then
		return
	end
	self.current_grade = info_grade > 1 and info_grade - 1 or 1
	if self.res_id ~= res_id then
		self:SetMainAsset(bubble, asset,res_id)
		 self.res_id = res_id
	end
	self.node_list["CurrentLevel"].text.text = string.format(Language.Activity.AdvancedReturnName[self.act_type], self.current_grade)
end

function AdvancedReturnTwoView:SetMainAsset(bundle, asset ,res_id)
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local main_role = Scene.Instance:GetMainRole()
		local info = {}
		info.prof = PlayerData.Instance:GetRoleBaseProf(main_vo.prof)
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_vo.appearance.fashion_body
		info.appearance.fashion_wuqi = main_vo.appearance.fashion_wuqi > 0 and main_vo.appearance.fashion_wuqi or 1
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -60, 0))
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetWingResid(res_id)
			if info.prof == GameEnum.ROLE_PROF_1 then      --男剑
				self.model:SetRotation(Vector3(0, -200, 0))
			elseif info.prof == GameEnum.ROLE_PROF_2 then  --男琴
				self.model:SetRotation(Vector3(0, -157, 0))
			elseif info.prof == GameEnum.ROLE_PROF_3 then  --女剑
				self.model:SetRotation(Vector3(0, -190, 0))
			elseif info.prof == GameEnum.ROLE_PROF_4 then  -- 小萝莉
				self.model:SetRotation(Vector3(0, -170, 0))
			end
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		self.model:SetRoleResid(main_role:GetRoleResId())
		local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(info.appearance.fashion_wuqi + 1) 
		local image_cfg = FashionData.Instance:GetWuQiImageID()
		local model_data = image_cfg[wuqi_grade_cfg.image_id] 
		local modela = model_data["resouce" .. info.prof .. info.sex] -- 当前角色神兵id 
		if info.prof ~= GameEnum.ROLE_PROF_3 then
			self.model:SetWeaponResid(modela)
		else
			local temp = Split(modela, ",")
			local weapon_id1 = tonumber(temp[1])
			local weapon_id2 = tonumber(temp[2])
			self.model:SetWeaponResid(weapon_id1)
			self.model:SetWeapon2Resid(weapon_id2)
		end
		self.model:SetTrigger(ANIMATOR_PARAM.FIGHT)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetFootResid(res_id)
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			self.model:SetRotation(Vector3(0, -90, 0))
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(res_id)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
			self.model:SetRoleResid(res_id)
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
			self.model:SetMainAsset(bundle, asset)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
			self.model:SetMainAsset(bundle, asset)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
			self.model:SetMainAsset(bundle, asset)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
			self.model:SetMainAsset(bundle, asset)
			self.model:SetRotation(Vector3(0, -45, 0))
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
			local info = {}
			info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
			info.halo_res_id = res_id
			self.model:SetGoddessModelResInfo(info)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
			local info = {}
			info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
			info.fazhen_res_id = res_id
			self.model:SetGoddessModelResInfo(info)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
			self.model:SetMainAsset(bundle, asset)
			self.model:SetRotation(Vector3(0, -45, 0))
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
			local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
			local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
			if mount_res_id <= 0 then
				return
			end
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
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -40, 0))
	else
		self.model:SetMainAsset(bundle, asset)
	end
end

--移动坐骑，达到尾焰拖尾效果
function AdvancedReturnTwoView:UpdateMountPosition()
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

function AdvancedReturnTwoView:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
end

function AdvancedReturnTwoView:OpenJinJieView()
	local index = 0
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fabao_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.role_shenbing)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.foot_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fashion_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	elseif self.act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_toushi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_mask)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_waist)
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_qilinbi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingtong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_linggong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingqi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shenyi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_flypet)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_weiyan)							
	end
	self:OnClickClose()
end

function AdvancedReturnTwoView:OnClickClose()
	self:Close()
end

function AdvancedReturnTwoView:GetNumberOfCells()
	local list = AdvancedReturnTwoData.Instance:GetUpGradeReturnList()
	return #list or 0
end

function AdvancedReturnTwoView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.cell_list[cell]
	if reward_cell == nil then
		reward_cell = ReturnRewardsItem2.New(cell.gameObject)
		reward_cell.parent_view = self
		self.cell_list[cell] = reward_cell
	end
	local data_list = AdvancedReturnTwoData.Instance:GetUpGradeReturnList()
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(data_list[data_index])
end

function AdvancedReturnTwoView:OnFlush()
	self:FlushTextInfo()
	self:SetReMainTime()
	local act_type = AdvancedReturnTwoData.Instance:GetUpGradeReturnActType()
	self.node_list["Name"].text.text = Language.Activity.UpGradeReturn[act_type]
	local is_show = AdvancedReturnTwoData.Instance:ActivetyFuanHuanIsShow()
	local max_grade = AdvancedReturnTwoData.Instance:GetMaxLevelGrade()
	if is_show and max_grade > self.current_grade then
		self.node_list['ActItemList']:SetActive(true)
		self.node_list['ItemList']:SetActive(false)
		self.node_list['MyactLayer']:SetActive(true)
		local act_itemid, act_grade = AdvancedReturnTwoData.Instance:GetReturnShowItemCfg()
		if act_grade > 0 then
			if act_grade <= 10 then
				self.node_list["JieNum2"]:SetActive(false)
				self.node_list["JieNum1"]:SetActive(true)
				self.node_list["JieNum1"].image:LoadSprite("uis/views/advancedreturn/images_atlas", "img_" .. act_grade)
			else
				self.node_list["JieNum2"]:SetActive(true)
				self.node_list["JieNum1"]:SetActive(true)
				local index = act_grade % 10
				self.node_list["JieNum2"].image:LoadSprite("uis/views/advancedreturn/images_atlas", "img_10")
				self.node_list["JieNum1"].image:LoadSprite("uis/views/advancedreturn/images_atlas", "img_".. index)
			end
		end
		self.act_item:SetData({item_id = tonumber(act_itemid)})
		local act_info = AdvancedReturnTwoData.Instance:GetUpGradeReturnInfo()
		UI:SetButtonEnabled(self.node_list["ShopBtn"], act_info.sign ~= 1 )
		if act_info.sign == 1 then
			self.node_list["ShopText"].text.text = Language.Activity.ButtonText2
		end
		local need_gold = AdvancedReturnTwoData.Instance:GetReturnNeedGoldCfg()
		self.node_list['NeedGoldText'].text.text = need_gold
	else
		self.node_list['ActItemList']:SetActive(false)
		self.node_list['ItemList']:SetActive(true)
		self.node_list['MyactLayer']:SetActive(false)
	end
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self.node_list["ActListView"].scroller:RefreshAndReloadActiveCellViews(true)
end

function AdvancedReturnTwoView:SetReMainTime()
	local sever_time_ta = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local sever_time = sever_time_ta.hour * 3600 + sever_time_ta.min * 60 + sever_time_ta.sec
	local diff_time = 24 * 3600 - sever_time
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
			local time_str = TimeUtil.FormatSecond(left_time, 3)
			self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, time_str)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

ReturnRewardsItem2 = ReturnRewardsItem2 or BaseClass(BaseCell)

function ReturnRewardsItem2:__init()
	self.node_list["RewardButton"].button:AddClickListener(BindTool.Bind(self.OnGetReward, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemList"])
	self.item:SetData(nil)
	self.item_dan = ItemCell.New()
	self.item_dan:SetInstanceParent(self.node_list["ItemCell"])
	
end

function ReturnRewardsItem2:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.item_dan then
		self.item_dan:DeleteMe()
		self.item_dan = nil
	end
	self.parent_view = nil
end

function ReturnRewardsItem2:OnGetReward()
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_FETCH, self.data.seq)
end

function ReturnRewardsItem2:OnFlush()
	if self.data == nil and self.parent_view.act_type == nil then
		return
	end
		self.node_list["Txtneedlevle"].text.text = string.format(Language.Activity.NeedGrade, Language.Activity.UpGradeReturnGrade[self.parent_view.act_type],self.data.need_grade)
		self.item:SetData(self.data.reward_item)
		if tonumber(self.data.fetch_reward_flag) == 1 then
			self.node_list["BtnText"].text.text = Language.Activity.QuanMinYiLingQu
			-- self.node_list["Effect"]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["RewardButton"], true)
			UI:SetButtonEnabled(self.node_list["RewardButton"], false)

		elseif tonumber(self.data.fetch_reward_flag) == 0 and self.parent_view.current_grade < self.data.need_grade then
			self.node_list["BtnText"].text.text = Language.Activity.QuanMinLingQu
			-- self.node_list["Effect"]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["RewardButton"], true)
			UI:SetButtonEnabled(self.node_list["RewardButton"], false)

		elseif tonumber(self.data.fetch_reward_flag) == 0 and self.parent_view.current_grade >= self.data.need_grade then
			self.node_list["BtnText"].text.text = Language.Activity.QuanMinLingQu
			-- self.node_list["Effect"]:SetActive(true)
			UI:SetGraphicGrey(self.node_list["RewardButton"], false)
			UI:SetButtonEnabled(self.node_list["RewardButton"], true)
		end
		self.node_list["ImgHasGet"]:SetActive(self.data.fetch_reward_flag == 1)
		self.node_list["RewardButton"]:SetActive(self.data.fetch_reward_flag ~= 1)
		self.node_list["OtherShop"]:SetActive(false)
		self.node_list["FanHuan"]:SetActive(true)

end