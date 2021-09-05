SecondChargeContentView = SecondChargeContentView or BaseClass(BaseRender)

local MAX_REWARD_NUM = 6
local MAX_TOGGLE_NUM = 3
local ONE_TIME = 3600 * 1.5
local THREE_TIME = 3600 * 24
function SecondChargeContentView:__init(instance)
	self.node_list["charge_toggle_10"].toggle:AddValueChangedListener(BindTool.Bind(self.ChongZhiClick1, self))
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnChongZhiClick, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnRewardClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Txtzhanlinum"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["Txtzhanlinum_1"])
	self.item_list = {}
	self.image_list = {}
	self.select_item_info = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	self.btn_name = {}
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()

	for i = 1, MAX_REWARD_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
		self.item_list[i]:SetShowOrangeEffect(true)
	end

	self:InitModel() 
end

function SecondChargeContentView:__delete()
	if self.model_l then
		self.model_l:DeleteMe()
		self.model_l = nil
	end

	if self.model_r then
		self.model_r:DeleteMe()
		self.model_r = nil
	end

	if self.test_model then
		self.test_model:DeleteMe()
		self.test_model = nil
	end	

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	if self.one_give_timer then
		CountDown.Instance:RemoveCountDown(self.one_give_timer)
		self.one_give_timer = nil
	end
	if self.three_give_timer then
		CountDown.Instance:RemoveCountDown(self.three_give_timer)
		self.three_give_timer = nil
	end
	self.item_list = {}
	self.btn_name = {}
	self.fight_text = nil
	self.fight_text2 = nil
end

function SecondChargeContentView:InitModel()
	local reward_cfg = DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.model_l = RoleModel.New()
	self.model_l:SetDisplay(self.node_list["DisplayLeft"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model_r = RoleModel.New()
	self.model_r:SetDisplay(self.node_list["DisplayRight"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	if nil == self.test_model then
		self.test_model = RoleModel.New()
		self.test_model:SetDisplay(self.node_list["DisplayIcon"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
		local bundle, asset = "actors/forge/100022_prefab", 100022
		self.test_model:SetMainAsset(bundle, asset, function()
			local transform = {position = Vector3(0, 0.38, 4.2), rotation = Quaternion.Euler(0, 180, 30)}
			self.test_model:SetCameraSetting(transform)
		end)
	end	

	self:SetModelRes()
end

local Model_Type = { ["Weapon"] = 1, ["Mount"] = 2, ["Wing"] = 3}
function SecondChargeContentView:SetModelRes()

	self.model_r:SetWingResid(0)
	self.model_r:SetMountResid(0)
	self.model_r:ClearModel()
	self.model_l:ResetRotation()
	self.model_r:ResetRotation()
	self.model_l:ClearCallBackFun()
	self.model_r:ClearCallBackFun()
	if self.chongzhi_state == nil then
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	local data = DailyChargeData.Instance:GetThreeChongZhiReward(self.chongzhi_state)
	if not data then
		return
	end
	local fashon_img = FashionData.Instance:GetUsedClothingIndex() <= 1 and 1 or (FashionData.Instance:GetUsedClothingIndex() - 1)
	local fashion_imgtwo = FashionData.Instance:GetShizhuangUseSpecialImg()
	local fashion_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(data and data.index)

	if data and data.type == Model_Type.Wing then
		if fashion_imgtwo > 0 then
			fashion_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(fashion_imgtwo)
		else
			fashion_cfg = FashionData.Instance:GetShizhuangImg(fashon_img)
		end
	end
	if fashion_cfg then
		local res_id = fashion_cfg["resouce" .. prof .. main_role_vo.sex]
		local bundle, asset = ResPath.GetFashionShizhuangModel(res_id)
		if data and (data.type ~= Model_Type.Weapon and data.type ~= Model_Type.Mount) then
			self.model_r:SpecialSetMainAsset(bundle, asset, function()
				if data.type == Model_Type.Mount then
					self.model_r:SetScale(Vector3(1, 1, 1))
					self.model_r:SetCameraSetting(RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount"))

					self.model_r:SetRotation(Vector3(0, -20, 0))
					self.model_r:SetLocalPosition(Vector3(0, -0.5, 0))
				end
				if data.type == Model_Type.Wing then
					self.model_r:SetMountResid(0)
					if prof == 1 then
						self.model_r:SetRotation(Vector3(0, -205, 0))
					elseif prof == 2 then
						self.model_r:SetRotation(Vector3(0, -160, 0))
					elseif prof == 3 then
						self.model_r:SetRotation(Vector3(0, -195, 0))
					elseif prof == 4 then
						self.model_r:SetRotation(Vector3(0, -170, 0))						
					end
					self.model_r:SetLocalPosition(Vector3(0, 0, 0))
				end
			end)
		end

	end


	local weapon_list = DailyChargeData.Instance:GetThreeRechargeAuto()[1]
	local weapon_show_id = weapon_list["model" .. prof]
	if type(weapon_show_id) == "string" then
		local temp_table = Split(weapon_show_id, ",")
		if temp_table then
			self.weapon_res_id = temp_table[1]
			self.weapon2_res_id = temp_table[2]
		end
	elseif type(weapon_show_id) == "number" then
		self.weapon_res_id = weapon_show_id
	end
	if data.type == Model_Type.Weapon then
		local weapon_show_id = "100" .. prof .. "02"
		local bundle, asset = ResPath.GetWeaponShowModel(tonumber(weapon_show_id), "100" .. prof .. "01")
		self.model_l:SpecialSetMainAsset(bundle, asset, function ()
			local transform = nil
			if prof == 1 then
				transform = {position = Vector3(0.0, 0.8, 3.2), rotation = Quaternion.Euler(0, 180, 0)}
			elseif prof == 2 or prof == 4 then
				transform = {position = Vector3(0.0, 1.5, 3), rotation = Quaternion.Euler(0, 180, 0)}
			elseif prof == 3 then
				transform = {position = Vector3(0.0, 1.3, 3), rotation = Quaternion.Euler(0, 180, 0)}
			end
			self.model_l:SetCameraSetting(transform)
			self.model_l:SetRotation(Vector3(0, 0, 0))
			self.model_l:SetLocalPosition(Vector3(0, 0, 0))
		end)

		local fashion_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(data.index)
		local res_id = fashion_cfg["resouce" .. prof .. main_role_vo.sex]
		local bundle, asset =  ResPath.GetFashionShizhuangModel(res_id)
		self.model_r:SpecialSetMainAsset(bundle, asset, function ()
			self.model_r:SetMountResid(0)
			self.model_r:SetRotation(Vector3(0, 0, 0))
			self.model_r:SetLocalPosition(Vector3(0, 0, 0))
		end)
		self.model_r:SetScale(Vector3(1, 1, 1))

	elseif data.type == Model_Type.Wing then
		local show_id = data["model" .. prof]
		local bundle, asset = ResPath.GetWingModel(show_id)
		self.model_l:SpecialSetMainAsset(bundle, asset, function ()
			local part = self.model_l.draw_obj:GetPart(SceneObjPart.Main)
			part:SetTrigger("action")
			self.model_l:SetRotation(Vector3(0, 0, 0))
			self.model_l:SetLocalPosition(Vector3(0, 0, 0))
		end)
		self.model_r:SetWingResid(show_id)
		self.model_r:SetScale(Vector3(1, 1, 1))

	elseif data.type == Model_Type.Mount then
		local show_id = data["model" .. prof]
		local bundle, asset = ResPath.GetMountModel(show_id)
		self.model_l:SpecialSetMainAsset(bundle, asset, function ()
			self.model_l:SetLoopAnimal("rest")
			self.model_l:SetRotation(Vector3(0, -20, 0))
			self.model_l:SetLocalPosition(Vector3(0, -0.5, 0))
		end)

		self.model_r:SetMountResid(show_id)
		-- 策划说那第二个奖励的翅膀显示
		local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(2)
		local data = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state)
		local show_id = data["model" .. prof]
		self.model_r:SetWingResid(show_id)
		self.model_r:SetRotation(Vector3(0, -20, 0))
		self.model_r:SetLocalPosition(Vector3(0, -0.5, 0))

		local fashion_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(data and data.index)
		if fashion_cfg then
			local res_id = fashion_cfg["resouce" .. prof .. main_role_vo.sex]
			local bundle, asset = ResPath.GetFashionShizhuangModel(res_id)
			self.model_r:SpecialSetMainAsset(bundle, asset, function()
				self.model_r:SetScale(Vector3(1, 1, 1))
				self.model_r:SetCameraSetting(RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount"))

				self.model_r:SetRotation(Vector3(0, -20, 0))
				self.model_r:SetLocalPosition(Vector3(0, -0.5, 0))
			end)
		end		
	end
end

function SecondChargeContentView:OpenCallBack()
	local chongzhi_state = 0
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()
	self:ChongZhiClick1(true)
	self:FlushRedPoints()
	for i = 1, MAX_TOGGLE_NUM do
		chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(i)
		local index = i > 1 and 2 or 1
		local text = index == 1 and Language.FirstCharge.BtnName[1] or string.format(Language.FirstCharge.BtnName[2], chongzhi_state)
		self.node_list["Txtcharge" .. i].text.text = text
		self.node_list["Txtcharge_" .. i].text.text = text
	end

end

function SecondChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	if not reward_cfg or not next(reward_cfg) then return end

	self.node_list["TxtChargeGoldBtn_10"].text.text = reward_cfg[1].need_total_chongzhi
	self.node_list["TxtChargeGoldBtn_99"].text.text = reward_cfg[2].need_total_chongzhi
end

function SecondChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
		self:FlushChongzhiItem(chongzhi_state)
		self:OnFlushRewardBtn(chongzhi_state)
		self:FlushItemDesc(self.select_index)
	end
end

function SecondChargeContentView:ChongZhiClick2(is_click)

end

function SecondChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function SecondChargeContentView:OnFlush()
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()
	self:FlushRedPoints()

	local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
	self.chongzhi_state = chongzhi_state
	self:FlushChongzhiItem(chongzhi_state)
	self:OnFlushRewardBtn()
	self:FlushItemDesc(self.select_index)
	self:SetModelRes()
	self:SetTitleAndPower()
end

function SecondChargeContentView:SetTitleAndPower()
	local left_bundle, left_asset = ResPath.GetFirsChargeSprite(1, self.select_index)
	local right_bundle, right_asset = ResPath.GetFirsChargeSprite(2, self.select_index)

	self:SetShowGiveTime()
	if self.select_index == 1 then
		self.node_list["ImageFirst"]:SetActive(true)
		self.node_list["ImgDesc"]:SetActive(false)
	else
		self.node_list["ImageFirst"]:SetActive(false)
		self.node_list["ImgDesc"]:SetActive(true)
		local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
		self.node_list["TxtChargeNum"].text.text = chongzhi_state
	end
	self.node_list["ImgEquipTipsLeft"].image:LoadSprite(left_bundle, left_asset, function() self.node_list["ImgEquipTipsLeft"].image:SetNativeSize() end)
	self.node_list["ImgEquipTipsRight"].image:LoadSprite(right_bundle, right_asset, function() self.node_list["ImgEquipTipsRight"].image:SetNativeSize() end)
	local cfg = DailyChargeData.Instance:GetThreeRechargeAuto()
	if cfg then
		local fight_power_l = cfg[self.select_index].power_left
		local fight_power_r = cfg[self.select_index].power_right
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = fight_power_l
		end
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = fight_power_r
		end
	end
end

function SecondChargeContentView:SetShowGiveTime()
	if self.select_index == 1 then
		self.node_list["OneTitleTips"]:SetActive(true)
		self.node_list["ThreeTitleTips"]:SetActive(false)
		local one_give_time = DailyChargeData.Instance:GetFirstChargeGiveTime(ONE_TIME, 1)
		if self.one_give_timer then
			CountDown.Instance:RemoveCountDown(self.one_give_timer)
			self.one_give_timer = nil
		end
		if one_give_time > 0 then
			function ChangeGiveTime(elapse_time, total_time)
				local time = math.floor(total_time - elapse_time + 0.5)
				if self.node_list["OneTime"] then
					local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(1)
					if active_flag == 1 then
						self.node_list["OneTime"].text.text = Language.Common.YiLingQu
					else
						self.node_list["OneTime"].text.text = TimeUtil.FormatSecond(time)
					end
				end
			end
			if self.node_list["OneTime"] then
				local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(1)
				if active_flag == 1 then
					self.node_list["OneTime"].text.text = Language.Common.YiLingQu
				else	
					self.node_list["OneTime"].text.text = TimeUtil.FormatSecond(one_give_time)
				end
			end			
			self.one_give_timer = CountDown.Instance:AddCountDown(one_give_time, 1, ChangeGiveTime, function ()
				if self.select_index == 1 then
					self:SetShowGiveTips(false)
				end
			end)
		else
			self:SetShowGiveTips(false)
		end
		self:SetShowGiveTips(one_give_time > 0)
	else
		self.node_list["OneTitleTips"]:SetActive(false)
		self.node_list["ThreeTitleTips"]:SetActive(true)
		local three_give_time = DailyChargeData.Instance:GetFirstChargeGiveTime(THREE_TIME, 3)
		if self.three_give_timer then
			CountDown.Instance:RemoveCountDown(self.three_give_timer)
			self.three_give_timer = nil
		end
		if three_give_time > 0 then
			function ChangeGiveTime(elapse_time, total_time)
				local time = math.floor(total_time - elapse_time + 0.5)
				if self.node_list["ThreeTime"] then
					local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(3)
					if active_flag == 1 then
						self.node_list["ThreeTime"].text.text = Language.Common.YiLingQu
					else
						self.node_list["ThreeTime"].text.text = TimeUtil.FormatSecond(time)
					end
				end
			end
			if self.node_list["ThreeTime"] then
				local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(3)
				if active_flag == 1 then
					self.node_list["ThreeTime"].text.text = Language.Common.YiLingQu
				else
					self.node_list["ThreeTime"].text.text = TimeUtil.FormatSecond(three_give_time)
				end
			end			
			self.three_give_timer = CountDown.Instance:AddCountDown(three_give_time, 1, ChangeGiveTime, function ()
				if self.select_index == 3 then
					self:SetShowGiveTips(false)
				end
			end)
		else
			self:SetShowGiveTips(false)
		end
		self:SetShowGiveTips(three_give_time > 0)
	end
end

function SecondChargeContentView:SetShowGiveTips(is_show)
	self.node_list["Title"]:SetActive(not is_show)
	self.node_list["LimitedTimeTitle"]:SetActive(is_show)
end

function SecondChargeContentView:OnRewardClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		UI:SetButtonEnabled(self.node_list["BtnReward"], false)
		-- self.node_list["BtnImage2"].text.text = Language.Common.YiLingQu
		UI:SetGraphicGrey(self.node_list["BtnImage2"], true)
		-- self.node_list["BtnReward"].image:LoadSprite("uis/images_atlas", "btn_special_1" .. ".png")
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_FIRST, self.select_index - 1, 0)

		local index = self:JumpNextPushIndex()
		if index ~= self.select_index then
			FirstChargeCtrl.Instance:FlusView()
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function SecondChargeContentView:JumpNextPushIndex()
	for i = self.select_index + 1, MAX_TOGGLE_NUM do
		local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(i)
		if active_flag == 1 and fetch_flag ~= 1 then
			DailyChargeData.Instance:SetShowPushIndex(i)
			return i
		end
	end

	for i = 1, self.select_index - 1 do
		local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(i)
		if active_flag == 1 and fetch_flag ~= 1 then
			DailyChargeData.Instance:SetShowPushIndex(i)
			return i
		end
	end

	return 0
end

function SecondChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward()
	local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
	for i = 1, MAX_REWARD_NUM do
		if item_info_list[i] then
			self.item_list[i]:SetGiftItemId(gifts_info.item_id)
			local item_cfg = ItemData.Instance:GetItemConfig(item_info_list[i].item_id)
			if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
				local data = TableCopy(item_info_list[i])
				data.is_from_extreme = 3
				self.item_list[i]:SetData(data)
			else
				self.item_list[i]:SetData(item_info_list[i])
			end
			self.node_list["ImgCell_" .. i]:SetActive(true)
		else
			self.node_list["ImgCell_" .. i]:SetActive(false)
		end
	end
end

function SecondChargeContentView:FlushRedPoints()
	local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	if Chongzhi99State then
		if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
			self.node_list["ImgRedPoint"]:SetActive(false)
		else
			self.node_list["ImgRedPoint"]:SetActive(true)
		end
	else
		self.node_list["ImgRedPoint"]:SetActive(false)
	end
	for i = 1, MAX_TOGGLE_NUM do
		local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(i)
		self.node_list["NodeRed" .. i]:SetActive(active_flag == 1 and fetch_flag ~= 1)
	end
end

function SecondChargeContentView:OnFlushRewardBtn()
	UI:SetButtonEnabled(self.node_list["BtnReward"], true)
	local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(self.select_index)

	local pttq_open = ResetDoubleChongzhiData.Instance:IsShowPuTianTongQing()
	self.node_list["DoubleFlag"]:SetActive(pttq_open)

	if active_flag == 1 and fetch_flag == 1 then
		self.node_list["Btn"]:SetActive(false)
		-- self.node_list["BtnImage2"].text.text = Language.Common.YiLingQu
		local bundle, asset = "uis/views/firstchargeview/images_atlas", "icon_yilingqu"
		self.node_list["BtnImage2"].image:LoadSprite(bundle, asset,function()
			self.node_list["BtnImage2"].image:SetNativeSize()
		end)
		self.node_list["BtnReward"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["BtnReward"], false)
	elseif active_flag == 1 and fetch_flag ~= 1 then
		self.node_list["Btn"]:SetActive(false)
		-- self.node_list["BtnImage2"].text.text = Language.Common.LingQuJiangLi
		local bundle, asset = "uis/views/firstchargeview/images_atlas", "icon_btn_text"
		self.node_list["BtnImage2"].image:LoadSprite(bundle, asset,function()
			self.node_list["BtnImage2"].image:SetNativeSize()
		end)
		self.node_list["BtnReward"]:SetActive(true)
	else
		self.node_list["Btn"]:SetActive(true)
		self.node_list["BtnReward"]:SetActive(false)
	end
end

function SecondChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function SecondChargeContentView:FlushItemDesc(index)
	for i = 1, MAX_TOGGLE_NUM do
		self.node_list["TxtFrame" .. i].text.text = Language.FirstCharge.ItemName[i][index]
		self.node_list["TxtFrame_" .. i].text.text = Language.FirstCharge.ItemDesc[i][index]
	end
end