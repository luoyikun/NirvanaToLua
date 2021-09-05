ShenGeBlessView = ShenGeBlessView or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	[0] = -338,
	[1] = -293,
	[2] = -248,
	[3] = -203,
	[4] = -158,
	[5] = -113,
	[6] = -68,
	[7] = -23,
}
local MOVE_TIME = 0.5
function ShenGeBlessView:UIsMove()
	
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(0 , -100 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , -250 , 0 ) , MOVE_TIME )
	--UITween.MoveShowPanel(self.node_list["MiddleContent"] , Vector3(0 , -100 , 0 ) , 0.4 )
	UITween.AlpahShowPanel(self.node_list["Right1"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["Right1"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME )

end

function ShenGeBlessView:__init(instance)

	self.count = 0
	self.quality = 0
	self.types = 0
	self.caowei = 0
	self.is_click_once = true
	self.is_rolling = false

	self.node_list["PlayAniToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self.node_list["ImgCenter"].button:AddClickListener(BindTool.Bind(self.OnClickOnce, self))
	self.node_list["BtnOnce"].button:AddClickListener(BindTool.Bind(self.OnClickOnce, self))
	self.node_list["BtnTence"].button:AddClickListener(BindTool.Bind(self.OnClickTence, self))

	local show_icon_cfg = ShenGeData.Instance:GetShenGeBlessShowCfg()
	for i = 1, 8 do
		self.node_list["CellItem" .. i].button:AddClickListener(BindTool.Bind(self.OnClickItem, self, i))
		if show_icon_cfg[i] then
			local bundle, asset = ResPath.GetItemIcon(show_icon_cfg[i].icon_pic)
			self.node_list["BlessIcon" .. i].image:LoadSprite(bundle, asset)
		end
	end

	self.show_time = true
	self.show_free = true

	self.hour = 0
	self.min = 0
	self.sec = 0

	self:Flush()
end

function ShenGeBlessView:LoadCallBack()
	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function ShenGeBlessView:SetYiZheJumpTwo()
	local other_cfg = ShenGeData.Instance:GetCfgOther()
	if other_cfg then
		local key_item_id_one = other_cfg.replacement_id or 0
		local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

		if not phase then
			local key_item_id_two = other_cfg.open_box_30_use_itemid or 0
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
end

-- 寻宝钥匙，一折抢购跳转
function ShenGeBlessView:StartCountDown(data, node_list)
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
function ShenGeBlessView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ShenGeBlessView:__delete()
	self:StopCountDown()
	
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ShenGeBlessView:OnClickOnce()
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	function on_click()
		if self.is_rolling then
			return
		end
		
		self.is_click_once = true
	
		self:ResetVariable()
	
		self:ResetHighLight()
		
	
		--ShenGeData.Instance:SetBlessAniState(self.node_list["PlayAniToggle"].toggle.isOn)
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1)
	end

	local cfg = ShenGeData.Instance:GetCfgOther() or {}
	local once_card_num = ItemData.Instance:GetItemNumInBagById(cfg.replacement_id)
	if (self.show_free and not self.show_time) or once_card_num > 0 then 
		on_click()
	else
		local one_chou = other_cfg.one_chou_need_gold
		local tips = string.format(Language.ShenGe.ShenGeChoujiangOne, one_chou)
		TipsCtrl.Instance:ShowCommonTip(on_click, nil, tips, nil, nil, true, nil, "shenge_bless_1", 
				nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
end	

function ShenGeBlessView:OnClickTence()
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	function on_click_tence()
		if self.is_rolling then
			return
		end
		self.is_click_once = false
	
		self:ResetVariable()
		self:ResetHighLight()
	
		--ShenGeData.Instance:SetBlessAniState(self.node_list["PlayAniToggle"].toggle.isOn)
		
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10)
	end
	local ten_chou = other_cfg.ten_chou_need_gold
	local tips = string.format(Language.ShenGe.ShenGeChoujiangTen, ten_chou)
	local cfg = ShenGeData.Instance:GetCfgOther() or {}
	local ten_card_num = ItemData.Instance:GetItemNumInBagById(cfg.open_box_30_use_itemid)
	if ten_card_num > 0 then
		on_click_tence()
	else
		TipsCtrl.Instance:ShowCommonTip(on_click_tence, nil, tips, nil, nil, true, nil, "shenge_bless_10", 
			nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
	
end

function ShenGeBlessView:OnClickItem(index)
	local data = ShenGeData.Instance:GetShenGeBlessShowData(index - 1)
	if nil == data then return end

	ShenGeCtrl.Instance:ShowBlessPropTip(data)
end

function ShenGeBlessView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then
		self:ResetVariable()
		self:ResetHighLight()

		self:SetButtonData(param1, param3, bag_list)
		self:SetRestTime(param3, param1)

		self:SaveVariable(param2, bag_list)
		self:TrunPointer()

		if self.node_list["PlayAniToggle"].toggle.isOn then
			self:ShowRawardTip()
			self:ShowHightLight()
		end
	end
end

function ShenGeBlessView:OnToggleChange(is_on)
	ShenGeData.Instance:SetBlessAniState(is_on)
end

function ShenGeBlessView:SetBlessCost()
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		self.node_list["TxtLeftMoney"].text.text = 0
		self.node_list["TxtRightMoney"].text.text = 0
		return
	end
	self.node_list["TxtLeftMoney"].text.text = other_cfg.one_chou_need_gold
	self.node_list["TxtRightMoney"].text.text = other_cfg.ten_chou_need_gold
end

function ShenGeBlessView:SetButtonData(use_count, next_free_time)
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		return
	end

	if nil ~= use_count then
		local diff_time = math.floor(next_free_time - TimeCtrl.Instance:GetServerTime())
		self.show_time = use_count < other_cfg.free_choujiang_times and diff_time > 0
		self.show_free = use_count < other_cfg.free_choujiang_times
		
		self:JudgeState(self.show_time, self.show_free)

		return
	end

	local info = ShenGeData.Instance:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO)
	local had_use_time = info and info.param1 or 0
	local free_time = info and info.param3 or 0
	local diff_time = math.floor(free_time - TimeCtrl.Instance:GetServerTime())

	self.show_time = had_use_time < other_cfg.free_choujiang_times and diff_time > 0
	self.show_free = had_use_time < other_cfg.free_choujiang_times
	self:JudgeState(self.show_time, self.show_free)
end

function ShenGeBlessView:SetRestTime(time, use_count)
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		return
	end

	local info = ShenGeData.Instance:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO)
	local next_free_time = info and info.param3 or 0
	local had_use_time = info and info.param1 or 0

	local diff_time = math.floor(next_free_time - TimeCtrl.Instance:GetServerTime())

	if had_use_time >= other_cfg.free_choujiang_times then
		return
	end

	if nil ~= use_count and use_count >= other_cfg.free_choujiang_times then
		return
	end

	if nil ~= time then
		diff_time = math.floor(time - TimeCtrl.Instance:GetServerTime())
	end

	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				local show_time = TimeUtil.FormatSecond(left_time)
				self.node_list["TxtTime"].text.text = string.format("%s后免费", show_time)

				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.show_time = false
				self.show_free = true

				self:JudgeState(self.show_time, self.show_free)

				return
			end
			local show_time = TimeUtil.FormatSecond(left_time)
			self.node_list["TxtTime"].text.text = string.format("%s后免费", show_time)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function ShenGeBlessView:TrunPointer()
	if self.is_rolling then
		return
	end
	if self.node_list["PlayAniToggle"].toggle.isOn then
		local angle = 0
		angle = POINTER_ANGLE_LIST[self.caowei]
		self.node_list["CenterPointer"].transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ShowHightLight()
		self:ShowRawardTip()
		return
	end
	self.is_rolling = true
	local time = 0
	local tween = self.node_list["CenterPointer"].transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 and self.count > 0 then
			tween:Pause()
			local angle = 0
			angle = POINTER_ANGLE_LIST[self.caowei]
			local tween1 = self.node_list["CenterPointer"].transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self.is_rolling = false
				self:ShowHightLight()
				self:ShowRawardTip()
			end)
		end
	end)
end

function ShenGeBlessView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
	self.caowei = ShenGeData.Instance:GetShenGeBlessCaoWei(self.quality, self.types) or 0
end

function ShenGeBlessView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
	self.caowei = 0
end

function ShenGeBlessView:ResetHighLight()
	self.node_list["ImgHighLight1"]:SetActive(false)
	self.node_list["ImgHighLightCell1"]:SetActive(false)

	self.node_list["ImgHighLight2"]:SetActive(false)
	self.node_list["ImgHighLightCell2"]:SetActive(false)

	self.node_list["ImgHighLight3"]:SetActive(false)
	self.node_list["ImgHighLightCell3"]:SetActive(false)

	self.node_list["ImgHighLight4"]:SetActive(false)
	self.node_list["ImgHighLightCell4"]:SetActive(false)

	self.node_list["ImgHighLight5"]:SetActive(false)
	self.node_list["ImgHighLightCell5"]:SetActive(false)

	self.node_list["ImgHighLight6"]:SetActive(false)
	self.node_list["ImgHighLightCell6"]:SetActive(false)

	self.node_list["ImgHighLight7"]:SetActive(false)
	self.node_list["ImgHighLightCell7"]:SetActive(false)

	self.node_list["ImgHighLight0"]:SetActive(false)
	self.node_list["ImgHighLightCell0"]:SetActive(false)
end

function ShenGeBlessView:JudgeState(ShowTime, ShowFree)
	local cfg = ShenGeData.Instance:GetCfgOther() or {}
	local once_card_num = ItemData.Instance:GetItemNumInBagById(cfg.replacement_id)
	self.node_list["ImgRedPoint"]:SetActive((ShowFree and (not ShowTime)) or once_card_num > 0)
	self.node_list["TxtTime"]:SetActive(ShowTime)
	self.node_list["TxtFree"]:SetActive((not ShowTime) and ShowFree)
	self.node_list["Effect"]:SetActive((not ShowTime) and ShowFree)
	self.node_list["ImgIcon"]:SetActive((ShowTime or (not ShowFree)) and not (once_card_num > 0))
	self.node_list["KeyOne"]:SetActive(once_card_num > 0 and (ShowTime or (not ShowFree)))
end




function ShenGeBlessView:ShowRawardTip()
	if self.is_click_once then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1)
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10)
	end
end

function ShenGeBlessView:ShowHightLight()
	local index = self.types or 0
	if index >= 10 then
		self.node_list["ImgHighLight" .. self.caowei]:SetActive(true)
		self.node_list["ImgHighLightCell" .. self.caowei]:SetActive(true)

	else
		index = self.quality
		self.node_list["ImgHighLight" .. self.caowei]:SetActive(true)
		self.node_list["ImgHighLightCell" .. self.caowei]:SetActive(true)
	end
end

function ShenGeBlessView:SetKeyState()
	local cfg = ShenGeData.Instance:GetCfgOther() or {}
	local once_card_num = ItemData.Instance:GetItemNumInBagById(cfg.replacement_id)
	local once_card_cfg = ItemData.Instance:GetItemConfig(cfg.replacement_id)

	-- self.node_list["ImgRedPoint"]:SetActive(once_card_num > 0)
	-- self.node_list["ImgIcon"]:SetActive(not (once_card_num > 0))
	if once_card_num > 0 and once_card_cfg then
		self.node_list["KeyOneTxt"].text.text = "X " .. once_card_num 
	end

	local ten_card_num = ItemData.Instance:GetItemNumInBagById(cfg.open_box_30_use_itemid)
	local ten_card_cfg = ItemData.Instance:GetItemConfig(cfg.open_box_30_use_itemid)

	self.node_list["KeyTen"]:SetActive(ten_card_num > 0)
	self.node_list["ImgRedPoint2"]:SetActive(ten_card_num > 0)
	self.node_list["ImgIconTen"]:SetActive(not (ten_card_num > 0))
	if ten_card_num > 0 and ten_card_cfg then
		self.node_list["KeyTenTxt"].text.text = "X " .. ten_card_num 
	end
end

function ShenGeBlessView:OnFlush(param_list)
	self:SetBlessCost()
	self:SetButtonData()
	self:SetRestTime()
	self:ResetHighLight()
	self:SetKeyState()
end