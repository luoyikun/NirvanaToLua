local CommonFunc = require("game/tips/tips_common_func")

ClotherpressTipsModleView = ClotherpressTipsModleView or BaseClass(BaseView)

local FIX_SHOW_TIME = 8
function ClotherpressTipsModleView:__init()
	self.ui_config = {{"uis/views/clothespress_prefab", "ClothespressModleTip"}}
	self.view_layer = UiLayer.Pop
	self.button_handle = {}
	self.get_way_list = {}
	self.data = {}
	self.button_label = Language.Tip.ButtonLabel
	
	self.can_reset_ani = true
	self.play_audio = true
	self.from_view = nil
	self.param_t = nil

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	-- 有些模型需要手动循环播放动画 把模型类型加在下表中即可 [模型类型] = {播放动作参数, 完成动作回调参数(可以为空)}
	self.need_loop_model = {
		[DISPLAY_TYPE.ZHIBAO] = {"bj_rest", "rest_stop"}			--宝具
	}
end

function ClotherpressTipsModleView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))

	local event_trigger = self.node_list["ModelEventTriger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragMan, self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.item_list = {}
	for i =1 ,5 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i]:ListenClick(BindTool.Bind(self.ShowTipContent, self, self.item_list[i]))
		self.item_list[i]:SetToggleGroup(self.node_list["ItemInfo"].toggle_group)
		self.item_list[i]:SetIsShowTips(false)
	end

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

	self.select_item_index = nil
	self.node_list["LingQu"].button:AddClickListener(BindTool.Bind(self.OnLingQuGift, self))
end

function ClotherpressTipsModleView:ReleaseCallBack()
	CommonFunc.DeleteMe()
	self.fight_text = nil
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.get_way_list = {}
	self.icon_list = {}
	self.icon_name_list = {}
	self.button_list = {}
	self.handle_param_t = {}
	self.from_view = nil
	self.param_t = nil
	self.fix_show_time = nil
	self.can_reset_ani = nil

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.select_item_index = nil

	self:CancelMountMoveTimeQuest()
end

function ClotherpressTipsModleView:OnRoleDragMan(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ClotherpressTipsModleView:CloseCallBack()
	self.model:ClearModel()
	self.model:ClearFoot()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)

	self:CancelMountMoveTimeQuest()

	if self.close_callback then
		self.close_callback()
		self.close_callback = nil
	end
	self.display_role = nil
	self.cur_data = {}
	self.from_view = nil
	self.param_t = nil
	self.handle_param_t = {}
end

function ClotherpressTipsModleView:OpenCallBack()
	self:Flush()
end

function ClotherpressTipsModleView:CloseView()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self:Close()
end

function ClotherpressTipsModleView:GetSingleSuitAllPartCfg()

end

function ClotherpressTipsModleView:SetCloseCallBack(data, from_view, param_t, close_call_back)
	self.cur_data = data
	self.from_view = from_view
	self.param_t = param_t
	self.handle_param_t = param_t or {}
	self.close_callback = close_call_back
end

function ClotherpressTipsModleView:OnFlush()
	if nil ~= self.model then
		self.node_list["Display"].ui3d_display:ResetRotation()
	end

	-- if self.can_reset_ani then
	-- 	self:SetModleRestAni()
	-- end

	local select_index = ClothespressData.Instance:GetSelectSuitIndex()
	local select_item_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	local single_suit_des_cfg = ClothespressData.Instance:GetSingleSuitDesCfg(select_index) or {}
	local single_suit_all_part_cfg = ClothespressData.Instance:GetSingleSuitPartCfgBySuitIndex(select_index) or {}

	for k,v in pairs(self.item_list) do
		if single_suit_all_part_cfg[k] then
			local data = {}
			data.item_id = single_suit_all_part_cfg[k].img_item_id or 0
			data.is_bind = 0
			v:SetIndex(k)
			v:SetData(data)
			v:SetHighLight(k == select_item_index)
		end
	end
	self.select_item_index = select_item_index

	local item_id = single_suit_all_part_cfg[select_item_index].img_item_id or 0
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then return end
	local data = {}
	data.item_id = item_id or 0
	data.is_bind = 0
	self.data = data
	self:SetRoleModel(item_cfg.is_display_role)
	self:SetWay()
	
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtEquipName"].text.text = name_str

	local desc = item_cfg.description or ""
	if self.data.item_id == 64100 or self.data.item_id == 64101 or self.data.item_id == 64200 then
		local exstr = "\n".."   "
		desc = string.gsub(desc or "", "\n", exstr)
	end
	self.node_list["TxtDesc"].text.text = "   " .. desc
	self.node_list["TxtSuitName"].text.text = single_suit_des_cfg.suit_name or ""

	local power = ItemData.Instance:SetFightPower(self.data.item_id) or 0
	self.fight_text.text.text = power
	self.node_list["FightPower"]:SetActive(true)

	self:ShowLingQuBtn()
	self:ShowHandlerBtn()
end

function ClotherpressTipsModleView:OnLingQuGift()
	local bag_index = MojieData.Instance:GetModelGiftBagIndex()
	if bag_index and bag_index ~= -1 and self.param_t then
		PackageCtrl.Instance:SendUseItem(bag_index, 1, self.param_t.select_index - 1)
	end
	self:Close()
	ViewManager.Instance:Close(ViewName.ModelGift)
end

function ClotherpressTipsModleView:ShowLingQuBtn()
	if self.from_view == TipsFormDef.FROM_LINGQU then
		local select_item_index = ClothespressData.Instance:GetSelectSuitItemIndex()
		local bag_index = MojieData.Instance:GetModelGiftBagIndex()
		self.node_list["LingQu"]:SetActive(bag_index and bag_index ~= -1 and select_item_index == self.select_item_index)
	else
		self.node_list["LingQu"]:SetActive(false)
	end
end

-- 根据不同情况，显示和隐藏按钮
function ClotherpressTipsModleView:ShowHandlerBtn()
	local data = {}
	local btn_is_show = true
	if self.from_view == TipsFormDef.FROM_BAG or self.from_view == TipsFormDef.FROM_BAG_ON_BAG_STORGE then
		data = ItemData.Instance:GetItem(self.data.item_id)
	elseif self.from_view == TipsFormDef.FROM_STORGE_ON_BAG_STORGE then
		data = ItemData.Instance:GetHouseItemInfo(self.data.item_id)
	elseif self.from_view == TipsFormDef.FROME_MARKET_GOUMAI and self.cur_data and self.data.item_id == self.cur_data.item_id then
		data = self.cur_data
	end

	if data == nil or next(data) == nil then
		btn_is_show = true
	else
		self.data = data
		btn_is_show = false
	end

	if nil == self.from_view or (btn_is_show and self.from_view ~= TipsFormDef.FROM_BAOXIANG) then 
		for k,v in pairs(self.button_list) do
			v.btn:SetActive(false)
		end
		return 
	end
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

function ClotherpressTipsModleView:OnClickHandle(handler_type)
	if nil == self.data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then return end
	if item_cfg.use_type then
		local is_advance, is_jump, model_name = AdvanceData.Instance:GetjumpModel(item_cfg)
		if is_advance and (handler_type == TipsHandleDef.HANDLE_EQUIP or handler_type == TipsHandleDef.HANDLE_USE) then
			self:SetJump(item_cfg, item_cfg.param1)
			return
		else
			if is_jump and model_name then
				ViewManager.Instance:Open(model_name, nil, "all",{id = item_cfg.id})
				self:Close()
				return
			end
		end
	end

	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end

	self:Close()
end

function ClotherpressTipsModleView:SetJump(item_cfg, param1)
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

function ClotherpressTipsModleView:ShowTipContent(cell, cell_index)
	if cell == nil then return end
	cell:SetHighLight(true)

	self.select_item_index = cell:GetIndex()
	self.data = cell:GetData()
	if self.data == nil or next(self.data) == nil then return end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtEquipName"].text.text = name_str
	self.node_list["ImgTitle"]:SetActive(false)
	self.node_list["ImageModel"]:SetActive(false)

	local desc = item_cfg.description or ""
	if self.data.item_id == 64100 or self.data.item_id == 64101 or self.data.item_id == 64200 then
		local exstr = "\n".."   "
		desc = string.gsub(desc or "", "\n", exstr)
	end
	self.node_list["TxtDesc"].text.text = "   " .. desc

	self:SetRoleModel(item_cfg.is_display_role)
	self:SetWay()

	local power = ItemData.Instance:SetFightPower(self.data.item_id) or 0
	self.fight_text.text.text = power
	self.node_list["FightPower"]:SetActive(true)

	self:ShowLingQuBtn()
	self:ShowHandlerBtn()
end

function ClotherpressTipsModleView:SetRoleModel(display_role)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	self.display_role = display_role
	self.node_list["Ani"]:SetActive(false)
	self.node_list["HeadImg"]:SetActive(false)
	self.node_list["Display"]:SetActive(true)
	self.model:ClearModel()
	self.model:ClearFoot()
	self.model:SetLocalPosition(Vector3(0, 0, 0))
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	if self.model and nil == self.node_list["ImgTitle"].image then
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
				self.model:SetRotation(Vector3(0, 0, 0))
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
	elseif display_role == DISPLAY_TYPE.MASK then
		for k, v in pairs(MaskData.Instance:GetSpecialImage()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetMaskResid(res_id)
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
				self.model:SetLocalPosition(Vector3(0, -0.2, 0))
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

function ClotherpressTipsModleView:SetModel(info, display_type, is_hide_effect)
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

function ClotherpressTipsModleView:SetWay()
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

function ClotherpressTipsModleView:CheckIsNeedLoop()
	for k,v in pairs(self.need_loop_model) do
		if self.display_role == k then
			return true, v
		end
	end
	return nil, nil
end

function ClotherpressTipsModleView:CalToShowAnim(is_change_tab, is_shenyi)
	self:PlayAnim(is_change_tab)
end

function ClotherpressTipsModleView:PlayAnim(is_change_tab)
	self.model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
end

function ClotherpressTipsModleView:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
end

--移动坐骑，达到尾焰拖尾效果
function ClotherpressTipsModleView:UpdateMountPosition()
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