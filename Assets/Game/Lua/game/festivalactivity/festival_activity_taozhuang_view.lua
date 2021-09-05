FestivalequipmentView = FestivalequipmentView or BaseClass(BaseRender)

function FestivalequipmentView:__init()
	self.display_1 = self.node_list["DisPlay1"]
	self.display_2 = self.node_list["DisPlay2"]

	self.item_list = {}
	self.model_cfg = {}
	for i = 1, 5 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_cell_" .. i])
		-- self.item_list[i]:SetDefualtBgState(false)
	end

	self.node_list["ClickOpen"].button:AddClickListener(BindTool.Bind(self.ClickOpen,self))
	self.node_list["ButtonClick"].button:AddClickListener(BindTool.Bind(self.ButtonClick,self))
	
	self.seq = 0
	self.model_1 = RoleModel.New()
	self.model_2 = RoleModel.New()
	self.model_1:SetDisplay(self.display_1.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model_1:SetCameraSettingForce({position = Vector3(0, 2.65, 8), rotation = Quaternion.Euler(0, 180, 0)})
	self.model_2:SetDisplay(self.display_2.ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function FestivalequipmentView:__delete()
	self.display_1 = nil
	self.display_2 = nil

	if nil ~= self.model_1 then
		self.model_1:DeleteMe()
		self.model_1 = nil
	end

	if nil ~= self.model_2 then
		self.model_2:DeleteMe()
		self.model_2 = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.model_cfg = {}

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end
end

function FestivalequipmentView:OpenCallBack()
	self:GetCurSuitCfg()
	self:Flush()
end

function FestivalequipmentView:ButtonClick()
	if self.cur_suit_cfg and self.cur_suit_cfg.suit_index then
		ClothespressCtrl.Instance:ShowSuitAttrTipView(self.cur_suit_cfg.suit_index + 1)
	end
	-- FestivalActivityCtrl.Instance:SendEquipSeq(self.seq)
end

function FestivalequipmentView:GetCurSuitCfg()
	self.cur_suit_cfg = ClothespressData.Instance:GetFinallySuitCfg()

	if self.cur_suit_cfg and self.cur_suit_cfg.suit_effect and self.suit_des then
		self.node_list["SuitDes"].text.text = self.cur_suit_cfg.suit_effect
		self.node_list["SuitDes2"].text.text = self.cur_suit_cfg.suit_effect
	end
end

function FestivalequipmentView:ClickOpen()
	ViewManager.Instance:Open(ViewName.ClothespressView)
end

function FestivalequipmentView:OnFlush()
	self:ShowModelPlay()
	self:ShowItemList()
	local info = ActivityData.Instance:GetActivityStatuByType(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_SPECIAL_IMG_SUIT)

	if nil == info or nil == next(info) or nil == info.end_time then
		return
	end

	local end_time = info.end_time
	local svr_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = math.floor(end_time - svr_time)

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	if rest_time > 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
			local left_time = total_time - elapse_time

			if left_time <= 0 then
				left_time = 0
				if self.least_time_timer then
	    			CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    			self.least_time_timer = nil
	   			end

	   			self.node_list["TextTime"].text.text = ""
	   		else
				local time = TimeUtil.FormatSecond(left_time, 10)
		        self.node_list["TextTime"].text.text = time
		    end
	    end)
	end
end

function FestivalequipmentView:ShowItemList()
	if nil == self.cur_suit_cfg or nil == self.cur_suit_cfg.suit_index then
		return
	end

	local suit_index = self.cur_suit_cfg.suit_index + 1
	local cur_suit_all_part_cfg = ClothespressData.Instance:GetSingleSuitPartCfgBySuitIndex(suit_index)
	local active_flag_info = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(suit_index)
	local cur_suit_part_active_num = ClothespressData.Instance:GetSingleSuitActivePartNum(suit_index)

	for i = 1, 5 do
		if cur_suit_all_part_cfg[i] and active_flag_info[i] then
			local data_item_id = cur_suit_all_part_cfg[i].img_item_id or 0
			local active_flag = active_flag_info[i] or 0
			self.item_list[i]:SetData({item_id = data_item_id, is_bind = 0})
			self.item_list[i]:SetIconGrayScale(active_flag == 0)
		end
	end

	self.seq = cur_suit_part_active_num or 0
	self.node_list["TextNum"].text.text = string.format(Language.Activity.TaoZhuangNum, cur_suit_part_active_num)
end

function FestivalequipmentView:ShowModelPlay()
	local model_cfg = FestivalActivityData.Instance:GetHolidayCfg()
	local mount_res_id = 0
	local wing_res_id = 0
	if nil == model_cfg or nil == next(model_cfg) then
		return
	end
	if self.model_cfg ~= model_cfg then
		self.model_cfg = model_cfg
		local mount_cfg = MountData.Instance:GetSpecialImagesCfg()
		if mount_cfg ~= nil then
			for k, v in pairs(mount_cfg) do
				if v ~= nil and v.item_id == model_cfg.display_mount then
					mount_res_id = v.res_id
					break
				end
			end
		end
		local wing_cfg = WingData.Instance:GetSpecialImagesCfg()
		if wing_cfg ~= nil then
			for k, v in pairs(wing_cfg) do
				if v ~= nil and v.item_id == model_cfg.display_wing then
					wing_res_id = v.res_id
					break
				end
			end
		end

		ItemData.ChangeModel(self.model_1, model_cfg.display_shizhuang, model_cfg.display_weapon)
		self.model_1:RemoveMount()
		self.model_1:SetMountResid(mount_res_id)
		self.model_1:SetWingResid(wing_res_id)
		self.model_1.display:SetRotation(Vector3(0, -90, 0))

		ItemData.ChangeModel(self.model_2, model_cfg.display_xianchong)
	end

end