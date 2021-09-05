local CommonFunc = require("game/tips/tips_common_func")

TipsDisplayPropModleView = TipsDisplayPropModleView or BaseClass(BaseView)

local FIX_SHOW_TIME = 8
function TipsDisplayPropModleView:__init()
	self.ui_config = {{"uis/views/tips/proptips_prefab", "DisplayModleTip"}}
	self.view_layer = UiLayer.Pop
	self.button_handle = {}
	self.get_way_list = {}
	self.button_label = Language.Tip.ButtonLabel
	
	self.can_reset_ani = true
	self.play_audio = true

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	-- 有些模型需要手动循环播放动画 把模型类型加在下表中即可 [模型类型] = {播放动作参数, 完成动作回调参数(可以为空)}
	self.need_loop_model = {
		[DISPLAY_TYPE.ZHIBAO] = {"bj_rest", "rest_stop"}			--宝具
	}
end

function TipsDisplayPropModleView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["TxtShowText1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["Icon1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["TxtShowText2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["Icon2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["TxtShowText3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["Icon3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["LingQu"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))

	local event_trigger = self.node_list["ModelEventTriger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragMan, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.item:SetIsShowTips(false)
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.button_list = {}
	for i =1 ,5 do
		local button = self.node_list["Btn" .. i]
		local btn_text = self.node_list["BtnText" .. i]
		self.button_list[i] = {btn = button, text = btn_text}
	end

	self.icon_list = {}
	self.icon_name_list = {}
	self.bg_node_list = {}
	for i = 1,3 do
		self.icon_list[i] = self.node_list["Icon" .. i]
		self.icon_name_list[i] = self.node_list["ImgName" .. i]
		self.bg_node_list[i] = self.node_list["IconBg" .. i]
	end


	self.fix_show_time = 8
	self.display_camera_init_pos = self.node_list["UICamera"].transform.position

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
end

function TipsDisplayPropModleView:OnClickReward()
	self:CountInputEnd(1)
end

function TipsDisplayPropModleView:CountInputEnd(str)
	local cost_num = tonumber(str)
	local bag_index = MojieData.Instance:GetModelGiftBagIndex()
	if bag_index ~= -1 then
		PackageCtrl.Instance:SendUseItem(bag_index, cost_num, self.handle_param_t.select_index - 1)
	end
	self:Close()
	ViewManager.Instance:Close(ViewName.ModelGift)
end

function TipsDisplayPropModleView:ReleaseCallBack()
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
	self.fight_text = nil
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	self.get_way_list = {}
	self.icon_list = {}
	self.icon_name_list = {}
	self.button_list = {}

	self.fix_show_time = nil
	self.can_reset_ani = nil
	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
	self:CancelMountMoveTimeQuest()

	self:RemoveCountDown()

	if self.xiaogui_data_change then
		GlobalEventSystem:UnBind(self.xiaogui_data_change)
		self.xiaogui_data_change = nil
	end
	
end

function TipsDisplayPropModleView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.model:ClearModel()
	self.model:ClearFoot()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	self.can_reset_ani = true

	if self.model then
		self.model:SetFootResid(0)
	end
	self:CancelMountMoveTimeQuest()
end

function TipsDisplayPropModleView:OnRoleDragMan(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function TipsDisplayPropModleView:CloseView()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self:Close()
end

function TipsDisplayPropModleView:OnClickWay(index)
	if nil == index or nil == self.get_way_list[index] then return end
	if self.get_way_list[index] == "DisCount" then
		local _, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(self.data.item_id)
		if not phase then
			SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
			return
		end

		local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
		if info then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo.level < info.active_level then
				SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
				return
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityNotStart)
			return
		end

		if info and info.close_timestamp then
			if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
				return
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityEnd)
				return
			end
		end
	elseif self.get_way_list[index] == "MolongMibaoView" then
		if OpenFunData.Instance:CheckIsHide("molongmibaoview") then
			if MolongMibaoData.Instance:IsOpenMoLongMiBao() then
				ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
				ViewManager.Instance:CloseAll()
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityEnd)
			end
			return
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.OneDiscount.ActivityEnd)
			return
		end
	end
	ViewManager.Instance:CloseAll()
	self:Close()
	ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
end

function TipsDisplayPropModleView:ShowTipContent()

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtEquipName"].text.text = name_str
	self.node_list["ImgTitle"]:SetActive(false)
	self.node_list["ImageModel"]:SetActive(false)
	
	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = string.format(Language.Tips.JiZhuan,level_befor,level_behind)
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and string.format(level_zhuan)
					or string.format(Language.Mount.ShowRedStr, level_zhuan)

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
		local bundle, asset = ResPath.GetTitleIcon(item_cfg.param1)
		self.node_list["ImgTitle"].image:LoadSprite(bundle, asset, function ()
			self.node_list["ImgTitle"]:SetActive(true)
			self.node_list["ImgTitle"].image:SetNativeSize()
		end)
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], item_cfg.param1, true)
	elseif item_cfg.search_type == GameEnum.COUPLE_HOME_SEARCH_TYPE or item_cfg.search_type == GameEnum.COUPLE_HOME_FURNITURE_TYPE then
		self.node_list["ImageModel"]:SetActive(true)
		local asset_name = "furniture_" .. self.data.item_id
		local bundle, asset = ResPath.GetRawImage(asset_name)
		self.node_list["ImageModelAsset"].raw_image:LoadSprite(bundle, asset, function()
			self.node_list["ImageModelAsset"].raw_image:SetNativeSize()
		end)
	end
	self.node_list["GetWay"]:SetActive(item_cfg.sub_type ~= 205)

	self.node_list["TxtLevel"].text.text = string.format(Language.Tip.DengJi,level_str) 
	local desc = item_cfg.description or ""
	if self.data.item_id == 64100 or self.data.item_id == 64101 or self.data.item_id == 64200 then
		local exstr = "\n".."   "
		desc = string.gsub(desc or "", "\n", exstr)
	end
	self.node_list["TxtDesc"].text.text = "   " .. desc
	self.node_list["TxtEquipType"].text.text = string.format(Language.Tip.ZhuangBeiLeiXing ,Language.Common.PROP_TYPE[item_cfg.is_display_role])

	self:SetXiaoguiTime()
	
	self.item:SetData(self.data)
	self.item:SetInteractable(false)

	self:SetRoleModel(item_cfg.is_display_role)
	self:SetFightPower(item_cfg.is_display_role)
	self.node_list["FightPower"]:SetActive(true)
	-- self.node_list["FightPower"]:SetActive(item_cfg.power >= 0)		--被动消耗类隐藏,主动消耗类显示
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if nil == self.from_view then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then return end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)

	for k ,v in pairs(self.button_list) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if nil ~= tx then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			local is_special = nil ~= IsSpecialHandlerType[handler_type]
			local asset = is_special and "btn_tips_side_yellow" or "btn_tips_side_blue"
			self.node_list["Btn" .. k].image:LoadSprite("uis/images_atlas", asset)
			self.button_handle[k] = self.node_list["Btn" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TipsDisplayPropModleView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					local part = self.model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger(ANIMATOR_PARAM.REST)
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function TipsDisplayPropModleView:OnClickHandle(handler_type)
	if nil == self.data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then return end
	if item_cfg.use_type and (handler_type == TipsHandleDef.HANDLE_EQUIP or handler_type == TipsHandleDef.HANDLE_USE) then
		local is_advance, is_jump, model_name = AdvanceData.Instance:GetjumpModel(item_cfg)
		if is_advance then
			self:SetJump(item_cfg, item_cfg.param1)
			return
		else
			if is_jump and model_name then
				ViewManager.Instance:Open(model_name, nil, "all",{id = item_cfg.id})
				self:Close()
				return
			elseif WingData.Instance:IsShenCiHuanhuaIdAndCanJumpByItemId(item_cfg.id) then
				ViewManager.Instance:Open(ViewName.ShenCiWingHuanHua, TabIndex.shenci_wing_huan_hua, "winghuanhua", {id = item_cfg.id})
			elseif MountData.Instance:IsShenCiHuanhuaIdAndCanJumpByItemId(item_cfg.id) then
				ViewManager.Instance:Open(ViewName.ShenCiMountHuanHua, TabIndex.shenci_mount_huan_hua, "mounthuanhua", {id = item_cfg.id})
			end
		end
	end

	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

function TipsDisplayPropModleView:SetJump(item_cfg, param1)
	local jump_info = AdvanceData.Instance:GetJumpInfo(item_cfg.use_type, param1)
	if jump_info and jump_info.tabIndex and jump_info.fulingType and jump_info.flush_view then
		if jump_info.tabIndex == TabIndex.wing_huan_hua and WingData.Instance:IsShenCiHuanhuaIdByItemId(self.data.item_id) then
			ViewManager.Instance:Open(ViewName.ShenCiWingHuanHua, TabIndex.shenci_wing_huan_hua, jump_info.flush_view, {id = item_cfg.id})
		elseif jump_info.tabIndex == TabIndex.mount_huan_hua and MountData.Instance:IsShenCiHuanhuaIdByItemId(item_cfg.id) then
			ViewManager.Instance:Open(ViewName.ShenCiMountHuanHua, TabIndex.shenci_mount_huan_hua, jump_info.flush_view, {id = item_cfg.id})
		else
			AdvanceData.Instance:SetHuanHuaType(jump_info.tabIndex)
			AdvanceData.Instance:SetImageFulingType(jump_info.fulingType)
			ViewManager.Instance:Open(ViewName.AdvanceHuanhua, TabIndex.mount_huanhua, jump_info.flush_view, {jump_info.talent_type})
			AdvanceCtrl.Instance:FlushView(jump_info.flush_view, {id = item_cfg.id})
		end
	end
	self:Close()
end

function TipsDisplayPropModleView:SetRoleModel(display_role)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	self.display_role = display_role
	self.node_list["Ani"]:SetActive(false)
	self.node_list["HeadImg"]:SetActive(false)
	self.node_list["Display"]:SetActive(true)
	local draw_root_obj = self.model.draw_obj:GetRoot()
	draw_root_obj.transform:SetParent(self.node_list["FitScale"].transform, true)
	self.model:SetLocalPosition(Vector3(0, 0, 0))
	self.model:SetRotation(Vector3(0, 0, 0))
	self.model:SetScale(Vector3(1, 1, 1))

	if self.model and nil == self.node_list["ImgTitle"].image then
		self.model:ClearModel()

		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		self.model.display:SetRotation(Vector3(0, 0, 0))

		if display_role ~= DISPLAY_TYPE.FOOTPRINT then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
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
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if display_role == DISPLAY_TYPE.MOUNT then
		local multi_id = MultiMountData.Instance:GetMountIdByItemId(self.data.item_id)
		if multi_id > 0 then
			res_id = MultiMountData.Instance:GetMulitMountResId(multi_id)
			bundle,asset = ResPath.GetMountModel(res_id)
		end
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		local fun = function ()
			self.model:ResetRotation()
			-- 根据形象资源ID来展示UI中某些比较特殊的形象需要单独调position和rotation的
			-- 注意！！！只能调小部分几个，否则你们活哥叼你们就准备受死吧。
			local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount_huanhua", res_id)
			if advance_transform_cfg then
				self.model:SetLocalPosition(advance_transform_cfg.position)
			elseif multi_id > 0 then
				local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "multimount")
				self.model:SetCameraSetting(transform)
			else
				self.model:SetLocalPosition(Vector3(0, 0, 0))
			end
		end
		self.model:SetRotation(Vector3(0, -60, 0))
		self.model:SetMainAsset(bundle, asset,fun)
		return
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetWingResid(res_id)
		self.model:SetTrigger(ANIMATOR_PARAM.STATUS)
		if prof == GameEnum.ROLE_PROF_1 then      --男剑
			self.model:SetRotation(Vector3(0, 158, 0))
		elseif prof == GameEnum.ROLE_PROF_2 then  --男琴
			self.model:SetRotation(Vector3(0, -155, 0))
		elseif prof == GameEnum.ROLE_PROF_3 then  --女剑
			 self.model:SetRotation(Vector3(0, 169, 0))
		elseif prof == GameEnum.ROLE_PROF_4 then  -- 小萝莉
			self.model:SetRotation(Vector3(0, -170, 0))
		else
			self.model:SetRotation(Vector3(0, -170, 0))
		end
		self.can_reset_ani = false
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == self.data.item_id then
				local weapon_res_id = 0
				local weapon2_res_id = 0
				res_id = main_role:GetRoleResId()
				weapon_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
				local temp = Split(weapon_res_id, ",")
				weapon_res_id = temp[1]
				weapon2_res_id = temp[2]
				self.model:SetRoleResid(res_id)
				self.model:SetWeaponResid(weapon_res_id)
				if weapon2_res_id then
					self.model:SetWeapon2Resid(weapon2_res_id)
				end
				break
			end
		end
		if prof == GameEnum.ROLE_PROF_4 then
			self.model:SetRotation(Vector3(0, -45, 0))
		else
			self.model:SetRotation(Vector3(0, 0, 0))
		end
		self.model:SetTrigger(ANIMATOR_PARAM.FIGHT)
	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
		local image_cfg = nil
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == self.data.item_id then
				image_cfg = v
				break
			end
		end
		if image_cfg then
			local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
			local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
			self.model:SetRoleResid(res_id)
			self.model:SetRotation(Vector3(0, 0, 0))
		end
		self.can_reset_ani = false
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(res_id)
			self.model:SetRotation(Vector3(0, 0, 0))
		self.can_reset_ani = false
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetFootResid(res_id)
			self.model.display:SetRotation(Vector3(0, -90, 0))
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		self.can_reset_ani = false
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		self.model:SetRotation(Vector3(0, -25, 0))
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		for k, v in pairs(BaobaoData.Instance:GetLongFenCfg()) do
			if v.active_item_id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.modleID)
				res_id = v.modleID
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LITTLEPET then
		for k, v in pairs(LittlePetData.Instance:GetLittlePetCfg()) do
			if v.active_item_id == self.data.item_id then
				bundle, asset = ResPath.GetLittlePetModel(v.using_img_id)
				res_id = v.active_item_id
				break
			end
		end
		self.model:SetRotation(Vector3(0, -60, 0))
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		self.model:SetRotation(Vector3(0, -35, 0))
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.halo_res_id = v.res_id
				self:SetModel(info, DISPLAY_TYPE.SHENGONG)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.fazhen_res_id = v.res_id
				self:SetModel(info, DISPLAY_TYPE.SHENYI, true)
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
					if v.active_item == self.data.item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == self.data.item_id then
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
				self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
				return
			end
			res_id = xiannv_resid
		end
	elseif display_role == DISPLAY_TYPE.BUBBLE then
		self.node_list["Ani"]:SetActive(true)
		self.node_list["Display"]:SetActive(false)
		self.node_list["HeadImg"]:SetActive(false)

		local index = CoolChatData.Instance:GetBubbleIndexByItemId(self.data.item_id)
		if index > 0 then
			local PrefabName = "BubbleChat" .. index
			local bundle = "uis/chatres/bubbleres/bubble" .. index .. "_prefab"
			local async_loader = AllocAsyncLoader(self, "chatres_prefab_loader")
			async_loader:Load(bundle, PrefabName, function(obj)
				if not IsNil(obj) then
					obj.transform.localScale = Vector3(1.6, 1.6, 1.6)
					obj.transform:SetParent(self.node_list["Ani"].transform, false)
				end
			end)
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == self.data.item_id then
				bundle, asset = ResPath.GetFaBaoModel(v.image_id)
				res_id = v.image_id
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.HEAD_FRAME then
		self.node_list["Ani"]:SetActive(false)
		self.node_list["Display"]:SetActive(false)
		self.node_list["HeadImg"]:SetActive(true)
		local index = HeadFrameData.Instance:GetPrefabByItemId(self.data.item_id)
		if index >= 0 then
			self.node_list["HeadImg"].image:LoadSprite(ResPath.GetHeadFrameIcon(index))
		end
	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetFaBaoModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		local fun = function ()
			self.model:ResetRotation()
		end
		self.model:SetMainAsset(bundle, asset, fun)
		self.model:SetLoopAnimal("bj_rest")
		self.model:SetRotation(Vector3(0, 0, 0))
		return
	elseif display_role == DISPLAY_TYPE.TOUSHI then
		for k, v in pairs(TouShiData.Instance:GetSpecialImageCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetTouShiResid(res_id)
		self.model:SetRotation(Vector3(0, 0, 0))
	elseif display_role == DISPLAY_TYPE.MASK then
		for k, v in pairs(MaskData.Instance:GetSpecialImage()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetMaskResid(res_id)
		self.model:SetRotation(Vector3(0, 0, 0))
	elseif	display_role == DISPLAY_TYPE.WAIST then
		for k, v in pairs(WaistData.Instance:GetSpecialImage()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetWaistResid(res_id)
		self.model:SetRotation(Vector3(0, 48, 0))
	elseif display_role == DISPLAY_TYPE.QILINBI then
		for k, v in pairs(QilinBiData.Instance:GetSpecialImage()) do
			if v.item_id == self.data.item_id then
				res_id = v["res_id" .. game_vo.sex .. "_h"]
				break
			end
		end
		local bundle, asset = ResPath.GetQilinBiModel(res_id, game_vo.sex)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, 0, 0))
	elseif display_role == DISPLAY_TYPE.XIAOGUI then
		local item_id = self.data.item_id 
		if self.data.item_id == 64101 then	--对限时免费小鬼拿64100的配置
			item_id = 64100
		end
		local cfg = EquipData.GetXiaoGuiCfgById(item_id)
		if cfg then
			res_id = cfg.res_id
			local bundle, asset = ResPath.GetShouHuXiaoGuiModel(res_id)
			self.model:SetMainAsset(bundle, asset)
		end
	elseif display_role == DISPLAY_TYPE.LINGZHU then
		for k, v in pairs(LingZhuData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingZhuModel(res_id, true)
		self.model:SetMainAsset(bundle, asset)
	elseif display_role == DISPLAY_TYPE.XIANBAO then
		for k, v in pairs(XianBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetXianBaoModel(res_id)
		self.model:SetMainAsset(bundle, asset)
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		for k, v in pairs(LingChongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id_h
				break
			end
		end
		local bundle, asset = ResPath.GetLingChongModel(res_id)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		for k, v in pairs(LingGongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id_h
				break
			end
		end
		local bundle, asset = ResPath.GetLingGongModel(res_id)
		self.model:SetMainAsset(bundle, asset)
	elseif display_role == DISPLAY_TYPE.LINGQI then
		for k, v in pairs(LingQiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingQiModel(res_id, true)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -45, 0))
	elseif display_role == DISPLAY_TYPE.WEIYAN then
		for k, v in pairs(WeiYanData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
		local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
		if mount_res_id <= 0 then
			return
		end

		local bundle, asset = ResPath.GetMountModel(mount_res_id)
		self.model:SetMainAsset(bundle, asset, function()
			local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("appearance_mount_weiyan", mount_res_id)
			if advance_transform_cfg then
				self.model:SetLocalPosition(Vector3(advance_transform_cfg.position.x + 2, advance_transform_cfg.position.y, advance_transform_cfg.position.z))
			else
				self.model:SetLocalPosition(Vector3(0, 0, 0))
			end
			--把模型节点设置为摄像机的子节点（方便统一移动）
			local draw_root_obj = self.model.draw_obj:GetRoot()
			draw_root_obj.transform:SetParent(self.node_list["UICamera"].transform, true)
			
			self.model:SetWeiYanResid(res_id, mount_res_id)

			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)

			self:CancelMountMoveTimeQuest()
			self:UpdateMountPosition()
			self.mount_move_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateMountPosition, self), 0.02)
		end)
		self.model:ResetRotation()
		self.model:SetRotation(Vector3(0, 160, 0))
		
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
		for k, v in pairs(ShouHuanData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetShouHuanResid(res_id)
		self.model:SetRotation(Vector3(0, 90, 0))
	elseif display_role == DISPLAY_TYPE.TAIL then
		for k, v in pairs(TailData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetTailResid(res_id)
		local role_prof = PlayerData.Instance:GetRoleBaseProf()
		if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
			rotation = Vector3(0, 130, 0)
		else
			rotation = Vector3(0, 160, 0)
		end
		self.model:SetRotation(rotation)
	elseif display_role == DISPLAY_TYPE.FLYPET then
		for k, v in pairs(FlyPetData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetFlyPetModel(res_id)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -35, 0))
	elseif display_role == DISPLAY_TYPE.BIANSHEN then	-- 变身
		local greate_cfg = BianShenData.Instance:GetGeneralConfig().level
		for k, v in pairs(greate_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.image_id
				break
			end
		end
		local bundle, asset = ResPath.GetMingJiangRes(res_id)
		self.model:SetMainAsset(bundle, asset, function()
			self.model:SetLocalPosition(Vector3(0, 0, 0))
			self.model:SetRotation(Vector3(0, 0, 0))
			self.model:SetScale(Vector3(1.2, 1.2, 1.2))
		end)
	end

	-- self.can_reset_ani = display_role ~= DISPLAY_TYPE.FIGHT_MOUNT
	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset, function ()
			if display_role == DISPLAY_TYPE.SPIRIT then
				self.model:SetLocalPosition(Vector3(-0.1, 0.1, 0))
			elseif display_role == DISPLAY_TYPE.LITTLEPET then
				self.model:SetLocalPosition(Vector3(0, -0.1, 0))
			end
		end)
		local is_loop, ani_name_tbl = self:CheckIsNeedLoop()
		if is_loop then
			self.model:SetLoopAnimal(ani_name_tbl[1], ani_name_tbl[2])
		elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self.model:SetTrigger(ANIMATOR_PARAM.REST)
		end
	end
end

function TipsDisplayPropModleView:SetFightPower(display_role)
	local fight_power = 0
	local cfg = {}
	cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	fight_power = cfg.power
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION or display_role == DISPLAY_TYPE.SHIZHUANG then
		local part_type = display_role == DISPLAY_TYPE.FASHION and SHIZHUANG_TYPE.WUQI or DISPLAY_TYPE.BODY
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == self.data.item_id then
				if part_type == SHIZHUANG_TYPE.WUQI then
					cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				else
					cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(v.image_id, 1)
				end
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					cfg = FootData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == self.data.item_id then
				cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(v.active_image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LITTLEPET then
		for k, v in pairs(LittlePetData.Instance:GetLittlePetCfg()) do
			if v.active_item_id == self.data.item_id then
				local list = {
				maxhp = v.attr_value_0,
				gongji = v.attr_value_1,
				fangyu = v.attr_value_2,
				mingzhong = v.attr_value_3,
				shanbi = v.attr_value_4,
				baoji = v.attr_value_5,
				kangbao = v.attr_value_6,
				}
				cfg = TableCopy(list)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == self.data.item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(self.data.item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		cfg = ZhiBaoData.Instance:FindZhiBaoHuanHuaByStuffID(self.data.item_id)
		if cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
		end
	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = FaBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAOGUI then
		local item_id = self.data.item_id
		if self.data.item_id == 64101 then	--对限时免费小鬼拿64100的配置
			item_id = 64100
		end
		local cfg = EquipData.GetXiaoGuiCfgById(item_id)
		local cfg_temp = {}
		if cfg then
			for k, v in pairs(cfg) do
				cfg_temp[k] = v
				-- cfg.per_mianshang = 0 				--子豪说这个伤属性算战力设为零
			end
		end
		cfg_temp.per_mianshang = 0
		fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg_temp))
	elseif display_role == DISPLAY_TYPE.TOUSHI then
		local toushi_special_cfg = TouShiData.Instance:GetSpecialImageCfg()
		for k, v in pairs(toushi_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = TouShiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.MASK then
		local mask_special_cfg = MaskData.Instance:GetSpecialImageCfg()
		for k, v in pairs(mask_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = MaskData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WAIST then
		local waist_special_cfg = WaistData.Instance:GetSpecialImageCfg()
		for k, v in pairs(waist_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = WaistData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.QILINBI then
		local qilinbi_special_cfg = QilinBiData.Instance:GetSpecialImageCfg()
		for k, v in pairs(qilinbi_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = QilinBiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGZHU then
		local lingzhu_special_cfg = LingZhuData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingzhu_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = LingZhuData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIANBAO then
		local xianbao_special_cfg = XianBaoData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(xianbao_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = XianBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		local lingchong_special_cfg = LingChongData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingchong_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = LingChongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		local linggong_special_cfg = LingGongData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(linggong_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = LingGongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGQI then
		local lingqi_special_cfg = LingQiData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingqi_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = LingQiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WEIYAN then
		local weiyan_special_cfg = WeiYanData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(weiyan_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = WeiYanData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
		local shouhuan_special_cfg = ShouHuanData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(shouhuan_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = ShouHuanData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.TAIL then
		local tail_special_cfg = TailData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(tail_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = TailData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FLYPET then
		local flypet_special_cfg = FlyPetData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(flypet_special_cfg) do
			if v.item_id == self.data.item_id then
				cfg = FlyPetData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.TITLE then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if not item_cfg then return end
		local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1)
		if title_cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(title_cfg))
		end
	elseif display_role == DISPLAY_TYPE.BIANSHEN then
	-- 变身
		local greate_cfg = BianShenData.Instance:GetGeneralConfig().level
		if not greate_cfg then return end
		for k, v in pairs(greate_cfg) do
			if v.item_id == self.data.item_id then
				cfg = BianShenData.Instance:GetImageInfoByImgId(v.image_id)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
end

function TipsDisplayPropModleView:OnFlush(param_t)
	self:ShowTipContent()
	if nil ~= self.model then
		self.node_list["Display"].ui3d_display:ResetRotation()
	end
	showHandlerBtn(self)
	if self.can_reset_ani then
		self:SetModleRestAni()
	end

	local bag_index = MojieData.Instance:GetModelGiftBagIndex()
	self.node_list["LingQu"]:SetActive(self.from_view == TipsFormDef.FROM_LINGQU and nil ~= bag_index)
	self:SetWay()
	-- self:SetImgFuLingTips()
end

function TipsDisplayPropModleView:SetData(data, from_view, param_t, close_call_back)
	if not data then return end

	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end

	self.close_call_back = close_call_back

	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsDisplayPropModleView:SetModel(info, display_type, is_hide_effect)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info, is_hide_effect)

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	local cfg = nil
	if display_type == DISPLAY_TYPE.XIAN_NV then
		self:CalToShowAnim(true)
	elseif display_type == DISPLAY_TYPE.SHENYI then
		self:CalToShowAnim(true, true)
	end
end

function TipsDisplayPropModleView:CalToShowAnim(is_change_tab, is_shenyi)
	self:PlayAnim(is_change_tab)
end

function TipsDisplayPropModleView:PlayAnim(is_change_tab)
	self.model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
end

function TipsDisplayPropModleView:SetWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.bg_node_list) do
		v:SetActive(false)
		self.node_list["TxtShowText" .. k]:SetActive(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.node_list["NodeIcons"]:SetActive(true)
				self.node_list["NodeTexts"]:SetActive(false)
				if tonumber(v) == 0 then
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon("Icon_System_Shop")
					self.icon_list[k].image:LoadSprite(bundle,asset, function()
						-- self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon(getway_cfg_k.icon)
					self.icon_list[k].image:LoadSprite(bundle,asset, function()
						-- self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["NodeTexts"]:SetActive(true)
				self.node_list["NodeIcons"]:SetActive(false)
				if tonumber(v) == 0 then
					self.node_list["TxtShowText" .. k]:SetActive(true)
					self.node_list["TxtShowText" .. k].text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.node_list["TxtShowText" .. k]:SetActive(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.node_list["TxtShowText" .. k].text.text = getway_cfg_k.button_name
					else
						self.node_list["TxtShowText" .. k].text.text = getway_cfg_k.discription
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.node_list["NodeTexts"]:SetActive(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.node_list["NodeIcons"]:SetActive(false)
		for k, v in pairs(msg) do
			self.node_list["TxtShowText" .. k]:SetActive(true)
			self.node_list["TxtShowText" .. k].text.text = v
		end
	end
end

function TipsDisplayPropModleView:SetImgFuLingTips()
	local img_fuling_type = ImageFuLingData.Instance:GetImgFuLingTypeByDisplayType(self.display_role) or -1
	local stuff_cfg = ImageFuLingData.Instance:GetImgFuLingAllUpStuffCfg(img_fuling_type)

	if nil == img_fuling_type or nil == stuff_cfg or nil == stuff_cfg[self.data.item_id] then
		self.node_list["TxtImgFuLing"].text.text = ""
		return
	end

	local is_open_img_fuling = OpenFunData.Instance:CheckIsHide("img_fuling")
	local cfg = OpenFunData.Instance:GetSingleCfg("img_fuling")
	local str = Language.Advance.ImgFuLingTips
	if not is_open_img_fuling then
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(cfg.trigger_param)
		-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		str = str .. "<color=#ff0000>" .. PlayerData.GetLevelString(cfg.trigger_param) .. Language.Common.Open .. "</color>"
	end
	self.node_list["TxtImgFuLing"].text.text = str
end

function TipsDisplayPropModleView:CheckIsNeedLoop()
	for k,v in pairs(self.need_loop_model) do
		if self.display_role == k then
			return true, v
		end
	end
	return nil, nil
end

function TipsDisplayPropModleView:SetXiaoguiTime()
	self:RemoveCountDown()
	if nil == self.data then
		return
	end

	local index = self.data.index or 0
	local item_cfg, _ = ItemData.Instance:GetItemConfig(self.data.item_id)
	local is_xiaogui = EquipData.IsXiaoguiEqType(item_cfg.sub_type)
	if not is_xiaogui then return end
	self.node_list["TxtEquipType"]:SetActive(is_xiaogui)
	if nil == self.xiaogui_data_change then
		self.xiaogui_data_change = GlobalEventSystem:Bind(OtherEventType.IMP_GUARD, BindTool.Bind(self.SetXiaoguiTime, self))
	end
	local time_left = 0

	if self.from_view == TipsFormDef.FROM_PLAYER_INFO then
		local xiaogui_info = EquipData.Instance:GetImpGuardInfo()
		if not xiaogui_info[index] then return end
		time_left = xiaogui_info[index].item_wrapper.invalid_time - TimeCtrl.Instance:GetServerTime()
	elseif self.from_view == TipsFormDef.FROM_BAG then
		time_left = self.data.invalid_time - TimeCtrl.Instance:GetServerTime()
	end
	
	if time_left > 0 then
		local time_text = TimeUtil.FormatSecond(time_left, 4)
		if time_left > (60 * 60 * 24) then
			time_text = TimeUtil.FormatSecond(time_left, 15)
		elseif time_left > 60 * 60 then
			time_text = TimeUtil.FormatSecond(time_left, 1)
		end
		self.node_list["TxtEquipType"].text.text = string.format(Language.Player.ImpText, time_text)
		self.count_down = CountDown.Instance:AddCountDown(time_left, 1, BindTool.Bind(self.CountDown, self))
	else
		self.node_list["TxtEquipType"].text.text = Language.Player.ImpDated
	end
end

-- 倒计时函数
function TipsDisplayPropModleView:CountDown(elapse_time, total_time)
	local time_left = total_time - elapse_time
	local time_text = TimeUtil.FormatSecond(time_left, 4)
	if time_left > (60 * 60 * 24) then
		time_text = TimeUtil.FormatSecond(time_left, 15)
	elseif time_left > 60 * 60 then
		time_text = TimeUtil.FormatSecond(time_left, 1)
	end
	self.node_list["TxtEquipType"].text.text = string.format(Language.Player.ImpText, time_text)

	if elapse_time >= total_time then
		self.node_list["TxtEquipType"].text.text = Language.Player.ImpDated
		self:RemoveCountDown()
	end
end

function TipsDisplayPropModleView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsDisplayPropModleView:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
end

--移动坐骑，达到尾焰拖尾效果
function TipsDisplayPropModleView:UpdateMountPosition()
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
	local step_target_pos = self.node_list["UICamera"].transform.position + (draw_root_obj.transform.forward * 0.2)

	self.node_list["UICamera"].transform.position = step_target_pos
end