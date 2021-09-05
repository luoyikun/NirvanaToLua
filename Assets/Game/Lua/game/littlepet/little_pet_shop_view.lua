--宠物商店
LittlePetShopView = LittlePetShopView or BaseClass(BaseRender)

local CellCount = 10							-- 转盘上面的奖励格子数量
local ModleNum = 2

function LittlePetShopView:__init()
	self.one_need_gold = 0
	self.ten_need_gold = 0
	self.choujiang_type = 0
	self.item_list = {}
	self.reward_data_list = {}
	self.is_rolling = false
	self.is_free = 0
	
	self.red_point_list = {
		[RemindName.LittlePetWarehouse] = self.node_list["ShowWarehouseRedPoint"],
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["Power1"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["Power2"])
	self.center_pointer = self.node_list["CenterPointer"]
	self.play_ani_toggle = self.node_list["PlayAniToggle"].toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))

	self.node_list["ButtonHandleBook"].button:AddClickListener(BindTool.Bind(self.OnClickHandleBook, self))
	self.node_list["BtnCenter"].button:AddClickListener(BindTool.Bind(self.OnClickOneChou, self))
	self.node_list["ButtonOneChou"].button:AddClickListener(BindTool.Bind(self.OnClickOneChou, self))
	self.node_list["ButtonTenChou"].button:AddClickListener(BindTool.Bind(self.OnClickTenChou, self))
	self.node_list["ButtonWarehouse"].button:AddClickListener(BindTool.Bind(self.OnClickWarehouse, self))
	self:GetRewardData()
	self:InitModle()
	self:InitRewardItem()
end

function LittlePetShopView:LoadCallBack()
	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function LittlePetShopView:SetYiZheJumpTwo()
	local key_item_id_one = LittlePetData.Instance:GetReplaceOneID() or 0
	local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

	if not phase then
		local key_item_id_two = LittlePetData.Instance:GetReplaceTenID() or 0
		select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_two)
		if not phase then
			return
		end
	end

	local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
	if not info then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level < info.active_level then
		return
	end

	if info.close_timestamp then
		if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
			local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
				end)
				self:StartCountDown(info, node_list)
			end
			CommonDataManager.SetYiZheBtnJumpTwo(self, self.node_list["BtnYiZheJumpTwo"], callback)
		end
	end
end

-- 寻宝钥匙，一折抢购跳转
function LittlePetShopView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 寻宝钥匙，一折抢购跳转
function LittlePetShopView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function LittlePetShopView:__delete()
	self:StopCountDown()

	if self.model_view_right ~= nil then
		self.model_view_right:DeleteMe()
		self.model_view_right = nil
	end

	if self.model_view_left ~= nil then
		self.model_view_left:DeleteMe()
		self.model_view_left = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.center_pointer = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function LittlePetShopView:OpenCallBack()
	self:RecoverData()
	self:GetRewardData()
	self:DoPanelTweenPlay()
	self:FlushModel()
	self:Flush()
end

function LittlePetShopView:CloseCallBack()
	self.choujiang_type = 0
	self.is_rolling = false
	
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

function LittlePetShopView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-140, 356, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Boom"], Vector3(17, -200, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveAlpahShowPanel(self.node_list["Top"], Vector3(0, -92.5, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function LittlePetShopView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] ~= nil then
		self.red_point_list[remind_name]:SetActive(num > 0)
		RemindManager.Instance:Fire(RemindName.LittlePetShop)
	end
end

function LittlePetShopView:InitModle()
	self.model_view_right = RoleModel.New()
	self.model_view_right:SetDisplay(self.node_list["ShopDisplay1"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model_view_right:SetRotation(Vector3(0, -30, 0))

	self.model_view_left = RoleModel.New()
	self.model_view_left:SetDisplay(self.node_list["ShopDisplay2"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model_view_left:SetRotation(Vector3(0, 30, 0))
end

function LittlePetShopView:InitRewardItem()
	for i = 1, CellCount do
		local handler = function()
			local close_call_back = function()
				self.item_list[i]:SetToggle(false)
				self.item_list[i]:ShowHighLight(false)
			end
			self.item_list[i]:SetToggle(true)
			self.item_list[i]:ShowHighLight(true)
			LittlePetCtrl.Instance:ShowShopPropTip(self.reward_data_list[i], close_call_back)
		end

		local data = {}
		data.item_id = self.reward_data_list[i] and self.reward_data_list[i].icon_pic
		data.name_color = self.reward_data_list[i] and self.reward_data_list[i].name_color
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["ShopItem" .. i])
		self.item_list[i]:SetData(data)
		self.item_list[i]:SetQualityByColor(data.name_color)
		self.item_list[i]:ListenClick(handler)
		table.insert(self.item_list, item)
	end
end

function LittlePetShopView:RecoverData()
	self.one_need_gold = 0
	self.ten_need_gold = 0
	self.choujiang_type = 0
	self.is_rolling = false
	self:RecoverPointer()
end

function LittlePetShopView:RecoverPointer()
	if self.center_pointer then
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, -20)
		self.node_list["HLIndex1"]:SetActive(true)
		for i = 2, CellCount do
			self.node_list["HLIndex" .. i]:SetActive(false)
		end
	end
end

function LittlePetShopView:GetRewardData()
	self.reward_data_list = LittlePetData.Instance:GetShopShowCfg() or {}
end

function LittlePetShopView:SetOneAndTenChouGold()
	local other_cfg = LittlePetData.Instance:GetOtherCfg()
	self.one_need_gold = other_cfg[1] and other_cfg[1].one_chou_consume_gold or 0
	self.ten_need_gold = other_cfg[1] and other_cfg[1].ten_chou_consume_gold or 0
	self.node_list["OneChouPrice"].text.text = self.one_need_gold
	self.node_list["TenChouPrice"].text.text = self.ten_need_gold
end

function LittlePetShopView:FlushModel()
	local res_id_list = LittlePetData.Instance:GetShowRandomZhenXiUseImgId()
	if #res_id_list < ModleNum then return end 

	local bundle_1, asset_1 = ResPath.GetLittlePetModel(res_id_list[1].using_img_id)
	local bundle_2, asset_2 = ResPath.GetLittlePetModel(res_id_list[2].using_img_id)
	local power_1 = LittlePetData.Instance:CalPetBaseFightPower(false, res_id_list[1].active_item_id)
	local power_2 = LittlePetData.Instance:CalPetBaseFightPower(false, res_id_list[2].active_item_id)

	self.model_view_left:SetMainAsset(bundle_1, asset_1)
	self.model_view_right:SetMainAsset(bundle_2, asset_2)
	self.model_view_left:SetTrigger("rest")
	self.model_view_right:SetTrigger("rest")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model_view_right:SetTrigger("rest")
		self.model_view_left:SetTrigger("rest")
	end, 10)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = power_2
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = power_1
	end
end

function LittlePetShopView:OnToggleChange(is_on)
	LittlePetData.Instance:SetChouJiangAniState(is_on)
end

function LittlePetShopView:GetChouJiangRewardByInfo()
	self:ClearChouJiangData()
	self:IsShowFree()
	self:TrunPointer()
end

function LittlePetShopView:ClearChouJiangData()
	self:SetHightLightState(-1)
end

function LittlePetShopView:SetHightLightState(index)
	local light_index = index or -1
	for i = 1, CellCount do
		if light_index == i then 
			self.node_list["HLIndex" .. i]:SetActive(true)
		else
			self.node_list["HLIndex" .. i]:SetActive(false)
		end
	end
end

function LittlePetShopView:ShowRawardTip()
	if self.choujiang_type == LITTLE_PET_CHOUJIANG_TYPE.ONE then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1)
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10)
	end
end


function LittlePetShopView:IsCanChouJiang(price, choujiang_type)
	if self.is_rolling then
		TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.ShowChoujiangZhongTips)
		return false
	end
	
	local is_havekey_one = LittlePetData.Instance:ErnieRedPointOne()
	local is_havekey_ten = LittlePetData.Instance:ErnieRedPointTen()
	if choujiang_type == LITTLE_PET_CHOUJIANG_TYPE.ONE and is_havekey_one then
		return true
	end

	if choujiang_type == LITTLE_PET_CHOUJIANG_TYPE.TEN and is_havekey_ten then
		return true
	end

	local golo_enough = LittlePetData.Instance:GetChouJiangGoldIsEnough(price)
	if not golo_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return false
	end

	return true
end

function LittlePetShopView:OnClickOneChou()
	local is_can_chou = self:IsCanChouJiang(self.one_need_gold, LITTLE_PET_CHOUJIANG_TYPE.ONE)
	if not is_can_chou then return end

	self:ClearChouJiangData()

	local chou_jiang_call_back = function()
		self.choujiang_type = LITTLE_PET_CHOUJIANG_TYPE.ONE
		LittlePetData.Instance:SetChouJiangAniState(self.play_ani_toggle.isOn)
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = self.choujiang_type
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
	end

	local is_havekey_one = LittlePetData.Instance:ErnieRedPointOne()
	if is_havekey_one then
		chou_jiang_call_back()
	else
		local need_gold = self.one_need_gold
		local tip_text = string.format(Language.LittlePet.TiShiOnce, need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back, nil, nil, nil, nil, nil, true, true)
	end
end

function LittlePetShopView:OnClickTenChou()
	local is_can_chou = self:IsCanChouJiang(self.ten_need_gold, LITTLE_PET_CHOUJIANG_TYPE.TEN)
	if not is_can_chou then return end

	self:ClearChouJiangData()
	local chou_jiang_call_back = function()
		self.choujiang_type = LITTLE_PET_CHOUJIANG_TYPE.TEN
		LittlePetData.Instance:SetChouJiangAniState(self.play_ani_toggle.isOn)
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = self.choujiang_type
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
	end
	local is_havekey_ten = LittlePetData.Instance:ErnieRedPointTen()
	if is_havekey_ten then
		chou_jiang_call_back()
	else
		local need_gold = self.ten_need_gold
		local tip_text = string.format(Language.LittlePet.TiShiTence, need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back, nil, nil, nil, nil, nil, true, true)
	end

end

function LittlePetShopView:TrunPointer()
	if self.is_rolling then return end
	
	local angle_seq = LittlePetData.Instance:GetChouJiangAngleSeq()
	angle_seq = angle_seq + 1
	local angle = 15 - 36 * angle_seq
	if self.play_ani_toggle.isOn then
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ChouJiangComplete(angle_seq)
		return
	end

	self.is_rolling = true
	local time = 0
	local tween = self.center_pointer.transform:DORotate(Vector3(0, 0, -360 * 20), 20, DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local tween1 = self.center_pointer.transform:DORotate(Vector3(0, 0, -360 * 3 + angle), 2, DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self:ChouJiangComplete(angle_seq)
			end)
		end
	end)
end

function LittlePetShopView:ChouJiangComplete(angle_seq)
	self.is_rolling = false
	self:SetHightLightState(angle_seq)
	self:ShowRawardTip()
end

function LittlePetShopView:OnFlush()
	self:IsShowFree()
	self:SetOneAndTenChouGold()
end

function LittlePetShopView:IsShowFree()
	self.is_free = LittlePetData.Instance:IsHaveFreeTimesByInfo()
	local is_havekey_one = LittlePetData.Instance:ErnieRedPointOne()
	local is_havekey_ten = LittlePetData.Instance:ErnieRedPointTen()
	self.node_list["OneChou"]:SetActive(not is_havekey_one)
	self.node_list["TenChou"]:SetActive(not is_havekey_ten)
	self.node_list["TimeText"]:SetActive(self.is_free > 0)
	self.node_list["FreeTimeText"]:SetActive(self.is_free <= 0)
	self.node_list["Effect"]:SetActive(self.is_free <= 0)
	self.node_list["Remind"]:SetActive(is_havekey_one)
	self.node_list["RemindTen"]:SetActive(is_havekey_ten)
	self.node_list["ItemNumOne"]:SetActive(is_havekey_one and not (self.is_free <= 0))
	self.node_list["ItemNumTen"]:SetActive(is_havekey_ten)

	local replacement_id = LittlePetData.Instance:GetReplaceOneID()
	local item_count_one = ItemData.Instance:GetItemNumInBagById(replacement_id)
	local open_box_30_use_itemid = LittlePetData.Instance:GetReplaceTenID()
	local item_count_Ten = ItemData.Instance:GetItemNumInBagById(open_box_30_use_itemid)
	self.node_list["TextKeyNumOne"].text.text = "X " .. item_count_one
	self.node_list["TextKeyNumTen"].text.text = "X " .. item_count_Ten

	local diff_time = self.is_free or 0
	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.node_list["TimeText"]:SetActive(false)
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.node_list["TimeText"].text.text = string.format(Language.Browse.TimeTxt,left_hour,left_min,left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LittlePetShopView:OnClickHandleBook()
	ViewManager.Instance:Open(ViewName.LittlePetHandleBookView)
end

function LittlePetShopView:OnClickWarehouse()
	ViewManager.Instance:Open(ViewName.LittlePetWarehouseView)
end