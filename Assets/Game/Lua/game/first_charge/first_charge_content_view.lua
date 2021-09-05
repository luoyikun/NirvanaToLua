FirstChargeContentView = FirstChargeContentView or BaseClass(BaseRender)

function FirstChargeContentView:__init(instance)
	FirstChargeContentView.Instance = self
	self.node_list["charge_toggle_10"].toggle:AddClickListener(BindTool.Bind(self.ChongZhiClick1, self))
	self.node_list["charge_toggle_99"].toggle:AddClickListener(BindTool.Bind(self.ChongZhiClick2, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OnChongZhiClick, self))
	self.node_list["reward_btn"].button:AddClickListener(BindTool.Bind(self.OnRewardClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanLi"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtZhanLi_1"])

	self.item_list = {}
	self.image_list = {}
	self.select_item_info = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end
	self:InitModel()
end

function FirstChargeContentView:__delete()
	if self.model_l then
		self.model_l:DeleteMe()
		self.model_l = nil
	end

	if self.model_r then
		self.model_r:DeleteMe()
		self.model_r = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.fight_text = nil
	self.fight_text2 = nil
end

function FirstChargeContentView:InitModel()
	local reward_cfg =DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.model_l = RoleModel.New()
	self.model_l:SetDisplay(self.node_list["display_l"].ui3d_display)
	local num_str = string.format("%02d", reward_cfg.wepon_index)
	local weapon_show_id = "100" .. (main_role_vo.prof % 10) .. num_str
	local bundle, asset = ResPath.GetWeaponShowModel(weapon_show_id)
	self.model_l:SetMainAsset( bundle, asset, function ()
		local part = self.model_l.draw_obj:GetPart(SceneObjPart.Main)
		part:SetTrigger("action")
	end)

	self.model_r = RoleModel.New()
	self.model_r:SetDisplay(self.node_list["display_r"].ui3d_display)


	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
	local res_id = 0
	for k,v in pairs(fashion_cfg) do
		if reward_cfg.fashion_index == v.index and v["resouce" .. (main_role_vo.prof % 10) .. main_role_vo.sex] then
			res_id = v["resouce" .. (main_role_vo.prof % 10) .. main_role_vo.sex]
		end
	end
	self.model_r:SetMainAsset(ResPath.GetRoleModel(res_id))
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[(main_role_vo.prof % 10)]
	if role_job ~= nil then
		local weapon_res_id = role_job["right_red_weapon" .. main_role_vo.sex]
		local weapon2_res_id = role_job["left_red_weapon" .. main_role_vo.sex]
		self.model_r:SetWeaponResid(weapon_res_id)
		self.model_r:SetWeapon2Resid(weapon2_res_id)
	end

	local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
	if item_info_list and item_info_list[1] then
		local gifts_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10).first_reward_item
		local gift_id = gifts_info and gifts_info.item_id or 0
		local data = CommonStruct.ItemDataWrapper()
		data.item_id = item_info_list[1].item_id
		data.param = CommonStruct.ItemParamData()
		data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = EquipData.Instance:GetEquipLegendFightPowerByData(data,false, true, nil)
		end
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = 2500
	end
	-- end
end

function FirstChargeContentView:OpenCallBack()
		self:ChongZhiClick1(true)
	self:FlushRedPoints()
end

function FirstChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.node_list["TxtChargeGoldBtn_1"].text.text = reward_cfg[1].need_total_chongzhi
	self.node_list["TxtChargeGoldBtn_2"].text.text = reward_cfg[2].need_total_chongzhi
	
end

function FirstChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self:FlushItemDesc(1)
	end
end

function FirstChargeContentView:ChongZhiClick2(is_click)
end

function FirstChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function FirstChargeContentView:OnFlush()
	self:FlushRedPoints()
	self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
end

function FirstChargeContentView:OnRewardClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		UI:SetButtonEnabled(self.node_list["reward_btn"], false)
		self.node_list["reward_btn"].image:LoadSprite("uis/images_atlas", "Button_7Login01" .. ".png")
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_FIRST, DailyChargeData.Instance:GetRewardSeq(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10), 0)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function FirstChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(chongzhi_state)
	local gifts_info = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).first_reward_item
	for i = 1, 3 do
		if item_info_list[i] then
			self.item_list[i]:SetGiftItemId(gifts_info.item_id)
			self.item_list[i]:SetData(item_info_list[i])
			self.node_list["image_" .. i]:SetActive(true)
		else
			self.node_list["image_" .. i]:SetActive(false)
		end
	end
end

function FirstChargeContentView:FlushRedPoints()
	local Chongzhi10State = DailyChargeData.Instance:GetFirstChongzhi10State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	if Chongzhi10State then
		if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
			self.node_list["ImgRedPoint"]:SetActive(false)
		else
			self.node_list["ImgRedPoint"]:SetActive(true)
		end
	else
		self.node_list["ImgRedPoint"]:SetActive(false)
	end

end

function FirstChargeContentView:OnFlushRewardBtn(money)
	local Chongzhi10State = DailyChargeData.Instance:GetFirstChongzhi10State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	UI:SetButtonEnabled(self.node_list["reward_btn"], true)
	self.node_list["reward_btn"].image:LoadSprite("uis/images_atlas", "Button_7Login01" .. ".png")
	if money == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
		if Chongzhi10State then
			if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then

				self.node_list["reward_btn"]:SetActive(false)
				self.node_list["BtnRecharge"]:SetActive(true)
			else
				self.node_list["reward_btn"]:SetActive(true)
				self.node_list["BtnRecharge"]:SetActive(false)
			end
		else
			self.node_list["reward_btn"]:SetActive(true)
			self.node_list["BtnRecharge"]:SetActive(false)
			self.node_list["reward_btn"].image:LoadSprite("uis/images_atlas", "Button_7Login01" .. ".png")
			UI:SetButtonEnabled(self.node_list["reward_btn"], false)
		end
	end
end

function FirstChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function FirstChargeContentView:FlushItemDesc(index)
	for i = 1, 3 do
		self.node_list["TxtImage" .. i].text.text = Language.FirstCharge.ItemName[i][index]
		self.node_list["TxtImage_" .. i].text.text = Language.FirstCharge.ItemDesc[i][index]
	end
end