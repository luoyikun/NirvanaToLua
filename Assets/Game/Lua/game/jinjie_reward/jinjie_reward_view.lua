JinJieRewardView = JinJieRewardView or BaseClass(BaseView)

function JinJieRewardView:__init()
	self.ui_config = {{"uis/views/tips/jinjiereward_prefab", "JinJieRewardView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function JinJieRewardView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnActive"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	self.node_list["BtnLingQu"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnStopHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickStopHuanHua, self))
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:SetData(nil)
	self.item_cell:SetIsShowTips(false)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TextFightPower"])
end

function JinJieRewardView:ReleaseCallBack()
	self.fight_text = nil
	
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self:RemoveCountDown()
end

function JinJieRewardView:CloseCallBack()
	self:RemoveCountDown()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function JinJieRewardView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:GetRelatedCfg()
	self:FlushDes()
	self:Flush()
	self:FlushModle()
end

--设置打开面板类型
function JinJieRewardView:SetData(system_type)
	self.system_type = system_type
	JinJieRewardData.Instance:SetCurSystemType(system_type)
	if self.system_type then
		self:Open()
	end
end

--获取相关配置
function JinJieRewardView:GetRelatedCfg()
	self.system_cfg = JinJieRewardData.Instance:GetSingleRewardCfg(self.system_type)
	local img_id = self.system_cfg and self.system_cfg.param_0 
	if img_id then
		self.huan_hua_cfg = JinJieRewardData.Instance:GetSystemSpecialImageCfg(self.system_type, img_id)
	end
end

--设置不变的相关显示
function JinJieRewardView:FlushDes()
	if nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
		return
	end

	local huan_hua_item_id = self.huan_hua_cfg.item_id
	self.item_cell:SetData({item_id = huan_hua_item_id, is_bind = 0})
	self.item_cell:SetInteractable(false)

	local equip_type = Language.JinJieReward.SystemName[self.system_type] or ""
	self.node_list["TxtTitle"].text.text = string.format(Language.JinJieReward.Equip_Type, equip_type)

	local cfg = JinJieRewardData.Instance:GetSingleAttrCfg(self.system_type)
	local per = cfg.add_per or 0
	local item_per = per/100
	local str = item_per .."%"
	local effect_des = string.format(Language.JinJieReward.EffectDes, equip_type, str)
	self.node_list["EffectDes"].text.text = effect_des

	local need_gold = self.system_cfg.cost or 0
	self.node_list["TextCost"].text.text = need_gold

	local icon_bundle, icon_asset = ResPath.GetJinJieBg(self.system_type)
	if icon_bundle and icon_asset then
		self.node_list["ImgIcon"].image:LoadSprite(icon_bundle, icon_asset .. ".png")
	end

	local reward_grade = self.system_cfg.grade 						--服务端的奖励阶数，客户端显示需减一
	if reward_grade then
		self.node_list["TxtLevel"].text.text = reward_grade - 1
	end

	local item_cfg = ItemData.Instance:GetItemConfig(huan_hua_item_id)
	if item_cfg == nil then
		return 
	end

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = SOUL_NAME_COLOR[item_color] and SOUL_NAME_COLOR[item_color] or SOUL_NAME_COLOR[1]
	local name = item_cfg.name or ""
	local name_str = ToColorStr(name, color)
	self.node_list["TExtEquipName"].text.text = name_str
end

--设置属性值和战力
function JinJieRewardView:SetAttrAndPower() 
	local hp = 0
	local gong_ji= 0
	local fang_yu = 0
	local img_id = self.system_cfg and self.system_cfg.param_0
	local huanhua_cfg = JinJieRewardData.Instance:GetSystemSpecialImageLevelCfg(self.system_type, img_id)
	if huanhua_cfg ~= nil then
		hp =  huanhua_cfg.maxhp or 0
		gong_ji = huanhua_cfg.gongji or 0
		fang_yu = huanhua_cfg.fangyu or 0
	end

	self.node_list["TxtHpValue"].text.text = string.format(Language.JinJieReward.Hp, hp)
	self.node_list["TxtAttackValue"].text.text = string.format(Language.JinJieReward.Attack, gong_ji)
	self.node_list["TxtDefValue"].text.text = string.format(Language.JinJieReward.Def, fang_yu)

	local fight_power = JinJieRewardData.Instance:GetSystemSpecialImageFightPower(self.system_type, huanhua_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
end

--刷新按钮状态
function JinJieRewardView:FlushButtonState()
	local is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(self.system_type)
	local is_get_active_item = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(self.system_type)
	local is_huanhua = JinJieRewardData.Instance:GetSystemIsUseCurSpecialImage(self.system_type)
	local is_can_free_get = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(self.system_type)
	local is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(self.system_type)
	
	self.node_list["BtnBuy"]:SetActive(not is_can_free_get)
	self.node_list["BtnLingQu"]:SetActive(is_can_free_get)
	self.node_list["TextCost"]:SetActive(not is_can_free_get)
	self.node_list["ImgFreeDes"]:SetActive(not is_end)
	self.node_list["TxtFreeTime"]:SetActive(not is_end)
	self.node_list["ImgFree"]:SetActive(not is_end)
	self.node_list["BtnActive"]:SetActive(not is_active)
	self.node_list["BtnHuanHua"]:SetActive(is_active and (not is_huanhua))
	self.node_list["BtnStopHuanHua"]:SetActive(is_active and is_huanhua)

	local bag_have_active_item = JinJieRewardData.Instance:BagIsHaveActiveNeedItem(self.system_type)
	local is_get_active_need_item = is_active or is_get_active_item or bag_have_active_item
	self.node_list["IsActive"]:SetActive(not is_get_active_need_item)
	self.node_list["ActiveGroup"]:SetActive(is_get_active_need_item)
	self.node_list["TextCost"]:SetActive(not is_get_active_need_item)
	self.node_list["ImgRed"]:SetActive(bag_have_active_item)

	self:RemoveCountDown()

	if is_end then
		self.node_list["TimeValue"].text.text = ""
		self.node_list["ImgFreeDes"]:SetActive(false)
		self.node_list["TxtFreeTime"]:SetActive(false)
		self.node_list["ImgFree"]:SetActive(false)
			return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(self.system_type)
	self:FulshFreeTime(end_time)
end

function JinJieRewardView:OnFlush()
	self:FlushButtonState()
	self:SetAttrAndPower()
end

--免费时间刷新
function JinJieRewardView:FulshFreeTime(end_time)
	if end_time == 0 then
		self.free_time:SetValue("")
		self.node_list["TimeValue"].text.text = ""
		self.node_list["ImgFreeDes"]:SetActive(false)
		self.node_list["TxtFreeTime"]:SetActive(false)
		self.node_list["ImgFree"]:SetActive(false)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:RemoveCountDown()
	self:SetTime(rest_time)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)
	else
		self:RemoveCountDown()
		self.node_list["TimeValue"].text.text = ""
		self.node_list["ImgFreeDes"]:SetActive(false)
		self.node_list["TxtFreeTime"]:SetActive(false)
		self.node_list["ImgFree"]:SetActive(false)
	end	
end

--移除计时器
function JinJieRewardView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--设置时间
function JinJieRewardView:SetTime(time)
	if time > 0 then
		local show_time_str = TimeUtil.FormatSecond(time, 10)
		if self.node_list["TimeValue"] and self.node_list["TimeValue"].text then
			-- self.node_list["TimeValue"].text.text = string.format(Language.Advance.LimitTime, show_time_str)
			self.node_list["TimeValue"].text.text = show_time_str
		end
	else
		self:RemoveCountDown()
		self.node_list["TimeValue"].text.text = ""
		self.node_list["ImgFreeDes"]:SetActive(false)
		self.node_list["TxtFreeTime"]:SetActive(false)
		self.node_list["ImgFree"]:SetActive(false)
		self:Flush()
	end
end

--购买(不能免费领取)
function JinJieRewardView:OnClickBuy()
	if nil == self.system_cfg or nil == self.system_cfg.cost or nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
		return
	end

	local need_gold = self.system_cfg.cost
	local is_enough = JinJieRewardData.Instance:GoldIsEnough(need_gold)
	if not is_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local item_id = self.huan_hua_cfg.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return 
	end

	local function ok_callback()
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY, self.system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	end

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = ITEM_COLOR[item_color] and ITEM_COLOR[item_color] or TEXT_COLOR.GREEN_SPECIAL_1
	local name = item_cfg.name or ""
	local name_str = ToColorStr(name, color)
	local des = string.format(Language.JinJieReward.BuyTip, need_gold, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

--领取(达到条件可免费领取)
function JinJieRewardView:OnClickLingQu()
	JinJieRewardCtrl.Instance:SendJinJieRewardOpera(JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH, self.system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
end

--激活(得到激活道具后激活)
function JinJieRewardView:OnClickActive()
	local bag_is_have_active_item, index, sub_type = JinJieRewardData.Instance:BagIsHaveActiveNeedItem(self.system_type)
	if bag_is_have_active_item and index ~= -1 and sub_type ~= -1 then
		PackageCtrl.Instance:SendUseItem(index, 1, sub_type, 0)
		return
	end

	--通过活动得到了道具 但是可能由于XX原因丢弃了
	if not bag_is_have_active_item then
		if nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
			return
		end

		local item_id = self.huan_hua_cfg.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil then
			return 
		end

		local name = item_cfg.name or ""
		local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
		local name_str = ToColorStr(name, color)
		local str = string.format(Language.JinJieReward.BagNotHaveActiveItem, name_str)
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end

--幻化(当前形象已激活)
function JinJieRewardView:OnClickHuanHua()
	if nil == self.system_cfg or nil == self.system_cfg.param_0 then
		return
	end
	local use_img_id = self.system_cfg.param_0 + GameEnum.MOUNT_SPECIAL_IMA_ID
	JinJieRewardCtrl.Instance:SendHuanHuaUseOrCancle(self.system_type, use_img_id)
end

--取消幻化(当前形象已激活)
function JinJieRewardView:OnClickStopHuanHua()
	local item_id = JinJieRewardData.Instance:GetSystemCurJinJieGradeImageId(self.system_type)
	if item_id ~= 0 then
		JinJieRewardCtrl.Instance:SendHuanHuaUseOrCancle(self.system_type, item_id, true)
	end
end

function JinJieRewardView:OnClickClose()
	self:Close()
end

--模型
function JinJieRewardView:FlushModle()
	if nil == self.huan_hua_cfg or nil == self.model then
		return
	end
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	self.model:ClearModel()
	self.model:ResetRotation()
	self.model:SetRotation(Vector3(0, 0, 0))
	local prof = PlayerData.Instance:GetRoleBaseProf() 

	-- if system_type ~= JINJIE_TYPE.JINJIE_TYPE_MOUNT and system_type ~= JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT and display_role ~= DISPLAY_TYPE.LING_QI then
	-- 	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	-- end

	local res_id = self.huan_hua_cfg.res_id or 0
	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	if self.system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 						-- 坐骑
		local bundle, asset = ResPath.GetMountModel(res_id)
		local fun = function ()
			if res_id == 7035001 then
				self.model:SetLocalPosition(Vector3(0, 0, -3))
			else
				self.model:SetLocalPosition(Vector3(0, 0, 0))
			end
		end
		self.model:SetRotation(Vector3(0, -60, 0))
		self.model:SetMainAsset(bundle, asset, fun)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 					-- 羽翼
		self.model:SetRoleResid(role_res_id)
		self.model:SetWingResid(res_id)
		if prof == GameEnum.ROLE_PROF_3 or prof == GameEnum.ROLE_PROF_2 then
			self.model:SetRotation(Vector3(0, -160, 0))
		elseif prof == GameEnum.ROLE_PROF_1 then
			self.model:SetRotation(Vector3(0, 170, 0))
		else
			self.model:SetRotation(Vector3(0, -170, 0))
		end
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.halo_res_id = res_id
		self.model:SetGoddessModelResInfo(info)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then					-- 伙伴法阵
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.fazhen_res_id = res_id
		self.model:SetGoddessModelResInfo(info, true)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		self.model:SetRoleResid(role_res_id)
		self.model:SetHaloResid(res_id)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then				-- 足迹
		self.model:SetRoleResid(role_res_id)
		self.model:SetFootResid(res_id)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		self.model:SetRotation(Vector3(0, -90, 0))
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then				-- 战骑
		local bundle, asset = ResPath.GetFightMountModel(res_id)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -35, 0))
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_MASK then					-- 面饰
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
		info.appearance.mask_used_imageid = image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

		self.model:ResetRotation()
		self.model:SetModelResInfo(info, true, true, true, true, true, true)
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_YAOSHI then					-- 腰饰
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
		info.appearance.yaoshi_used_imageid = image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

		self.model:ResetRotation()
		self.model:SetModelResInfo(info, true, true, true, true, true, true)
		self.model:SetRotation(Vector3(0, 45, 0))
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_TOUSHI then					-- 头饰
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
		info.appearance.toushi_used_imageid = image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

		self.model:ResetRotation()
		self.model:SetModelResInfo(info, true, true, true, true, true, true)
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_QILINBI then					-- 麒麟臂
		local qilinbi_res_id = self.huan_hua_cfg["res_id" .. main_vo.sex .. "_h"] or 0
		local bundle, asset = ResPath.GetQilinBiModel(qilinbi_res_id, main_vo.sex)
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset)
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_LINGZHU then					-- 灵珠
		local bundle, asset = ResPath.GetLingZhuModel(res_id, true)
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_XIANBAO then					-- 仙宝
		local bundle, asset = ResPath.GetXianBaoModel(res_id)
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_WEIYAN then					-- 尾焰
		self:SetWeiYanModel(res_id)
		self.model:SetRotation(Vector3(0, 150, 0))
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_LINGCHONG then				-- 灵宠
		if self.huan_hua_cfg.res_id_h then
			local bundle1, asset1 = ResPath.GetLingChongModel(self.huan_hua_cfg.res_id_h)
			self.model:ResetRotation()
			self.model:SetMainAsset(bundle1, asset1)
			self.model:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
			return
		end
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_LINGGONG then				-- 灵弓
		if self.huan_hua_cfg.res_id_h then
			local bundle, asset = ResPath.GetLingGongModel(self.huan_hua_cfg.res_id_h)
			self.model:ResetRotation()
			self.model:SetMainAsset(bundle, asset)
		end
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_LINGQI then					-- 灵骑
		local bundle, asset = ResPath.GetLingQiModel(res_id)
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -45, 0))
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHOUHUAN then				-- 手环
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
		info.appearance.shouhuan_used_imageid = image_id
		self.model:SetModelResInfo(info, true, true, true, true, true, true)
		self.model:SetRotation(Vector3(0, 90, 0))
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_TALT then					-- 尾巴
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
		info.appearance.tail_used_imageid = image_id
		self.model:SetModelResInfo(info, true, true, true, true, true, true)
		if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
			self.model:SetRotation(Vector3(0, 130, 0))
		else
			self.model:SetRotation(Vector3(0, 160, 0))
		end
		return
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FLYPET then				-- 飞宠
		local bundle, asset = ResPath.GetFlyPetModel(res_id)
		self.model:ResetRotation()
		self.model:SetMainAsset(bundle, asset)
		self.model:SetRotation(Vector3(0, -35, 0))
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FABAO then					-- 法宝
		local bundle, asset = ResPath.GetFaBaoModel(res_id)
		self.model:SetMainAsset(bundle, asset)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FASHION then 					-- 时装
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.is_normal_fashion = false
		info.shizhuang_part_list = {{image_id = 0},{image_id = image_id}}
		self.model:SetModelResInfo(info, true, true, true, true, true)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHENBING then 					-- 神兵
		local image_id = self.huan_hua_cfg.image_id or 0
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.shizhuang_part_list = {{image_id = image_id}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
		self.model:SetModelResInfo(info, true, false, true, true)
		self.model:SetTrigger(ANIMATOR_PARAM.FIGHT)
		if prof == GameEnum.ROLE_PROF_4 then
			rotation = Quaternion.Euler(0, -45, 0)
		else
			rotation = Quaternion.Euler(0, 0, 0)
		end
	end
end

--物品变化回调
function JinJieRewardView:ItemDataChangeCallback()
	self:Flush()
end

function JinJieRewardView:SetWeiYanModel(res_id)
	if nil == res_id then
		return
	end

	local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	local use_res_id = 0
	if mulit_mount_res_id > 0 then
		use_res_id = mulit_mount_res_id
	else
		local mount_image_id = MountData.Instance:GetUsedImageId()
		local mount_res_id = MountData.Instance:GetMountResIdByImageId(mount_image_id)
		use_res_id = mount_res_id
	end
	
	if use_res_id <= 0 then
		return
	end

	local bundle, asset = ResPath.GetMountModel(use_res_id)
	self.model:SetMainAsset(bundle, asset, function()
		local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("appearance_mount_weiyan", use_res_id)
		if advance_transform_cfg then
			self.model:SetLocalPosition(Vector3(advance_transform_cfg.position.x + 2, advance_transform_cfg.position.y, advance_transform_cfg.position.z))
		else
			self.model:SetLocalPosition(Vector3(0, 0, 0))
		end
		self.model:SetWeiYanResid(res_id, use_res_id)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	end)
end