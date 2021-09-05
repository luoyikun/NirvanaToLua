FuBenWeaponRollView = FuBenWeaponRollView or BaseClass(BaseView)
function FuBenWeaponRollView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "WeaponFinishView"}}
	self.active_close = false
	self.fight_info_view = true
	self.is_modal = true									-- 是否模态
	self.star_pos_list = {}
	self.sequence = {}
	self.select_list = {}
	self.count_free_times = 0
	self.count_cost_times = 0
end
function FuBenWeaponRollView:__delete()

end

function FuBenWeaponRollView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end

	if self.delay_timer3 then
		GlobalTimerQuest:CancelQuest(self.delay_timer3)
		self.delay_timer3 = nil
	end

	if self.delay_timer4 then
		GlobalTimerQuest:CancelQuest(self.delay_timer4)
		self.delay_timer4 = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.star_timer_reqest then
		GlobalTimerQuest:CancelQuest(self.star_timer_reqest)
		self.star_timer_reqest = nil
	end

	for k,v in pairs(self.sequence) do
		v = nil
	end
	self.sequence = {}

	self.cover_item = {}
	self.item_name = {}
	self.req_index_queue = {}
	self.select_list = {}
	self.select_card_index = nil
	self.tweener1 = nil
	self.tweener2 = nil
end

function FuBenWeaponRollView:LoadCallBack()
	self.select_card_index = 0
	self.auto_roll = false
	self.item_list = {}
	self.cover_item = {}
	self.item_name = {}
	self.req_index_queue = {}
	self.is_on_close = false

	for i = 1, 8 do
		local image = self.node_list["Image" .. i]
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(image.transform:Find("RightItem" .. i))
		self.star_pos_list[i] = self.node_list["CardItem" .. i].transform.anchoredPosition
		self.node_list["CardItem" .. i].button:AddClickListener(BindTool.Bind2(self.OnSendRollCard,self,i))
		self.cover_item[i] = image.transform:Find("cover")
		self.item_name[i] = image.transform:Find("ItemName"):GetComponent(typeof(UnityEngine.UI.Text))
	end
	-- self.node_list["ImgSward"]:SetActive(false)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.AutoFanPai, self))
	self.node_list["BlackClick"].button:AddClickListener(BindTool.Bind(self.JumpAnimation, self))
end

function FuBenWeaponRollView:OnClickClose(is_on)
	if is_on then
		if self.delay_timer3 then
			GlobalTimerQuest:CancelQuest(self.delay_timer3)
			self.delay_timer3 = nil
		end
		self.delay_timer3 = GlobalTimerQuest:AddDelayTimer(
		function()
			self:Close()
			FuBenCtrl.Instance:SendExitFBReq()
		end, 2)
	else
		self:Close()
		FuBenCtrl.Instance:SendExitFBReq()
	end
end

function FuBenWeaponRollView:CloseCallBack()
	self.req_index_queue = {}
	self.select_list = {}
	self.isnt_play_action = nil
	self.is_on_close = false
	if self.delay_timer3 then
		GlobalTimerQuest:CancelQuest(self.delay_timer3)
		self.delay_timer3 = nil
	end
	FuBenCtrl.Instance:SendNeqRollReq(3)
end

function FuBenWeaponRollView:OpenCallBack()
	self.auto_roll = false
	self.is_on_close = false
	self.node_list["BlackClick"]:SetActive(true)
	
	local roll_info = FuBenData.Instance:GetNeqRollInfo()
	if roll_info == nil or roll_info == "" then return end
	self.count_free_times = roll_info.max_free_roll_times - roll_info.free_roll_times
	self.count_cost_times = #FuBenData.Instance:GetWeaponCfgRollCost() or 0
end

function FuBenWeaponRollView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "reward" then
			local reward_info = FuBenData.Instance:GetNeqRollPool()
			for k,v in pairs(reward_info) do
				if self.item_list[k] then
					self.item_list[k]:SetData(v)
					local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
					if v.num == 1 then
						self.item_name[k].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) ..  "*"  .. v.num
					elseif v.num == 2 then
						self.item_name[k].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) .. string.format(Language.FuBen.WeaponColor, v.num)
					else
						self.item_name[k].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) .. string.format(Language.FuBen.WeaponRedColor, v.num)
					end
					self.cover_item[k].gameObject:SetActive(false)
				end
			end
			self.is_roll_card = false
			self:SetCountDown()
			self:OnFlushStart()
		elseif k == "rollreward" then
			self:OnFlushReward()
		end
	end

	local roll_info = FuBenData.Instance:GetNeqRollInfo()
	local cost_num = FuBenData.Instance:GetWeaponRollCost()
	local cost_cfg = FuBenData.Instance:GetWeaponCfgRollCost()
	if roll_info == nil or roll_info == "" then return end
	local free_times = roll_info.max_free_roll_times - roll_info.free_roll_times

	self.node_list["FreeTimes"]:SetActive(free_times > 0 and free_times ~= 3)
	self.node_list["TipsTxt"]:SetActive(free_times == 3)
	self.node_list["ChargeTimes"]:SetActive(free_times <= 0 and (#cost_cfg - roll_info.gold_roll_times) > 0)
	self.node_list["NotTimes"]:SetActive(#cost_cfg == roll_info.gold_roll_times)

	self.node_list["FreeTimes"].text.text = string.format(Language.FuBen.FreeTimes, free_times) 
	self.node_list["ChargeTimes"].text.text = string.format(Language.FuBen.GoldTimes, (#cost_cfg - roll_info.gold_roll_times)) 
	self.node_list["GoldNum"].text.text = cost_num
end

function FuBenWeaponRollView:SetCountDown()
	local function Countdown(elapse_time, total_time)
		local time = math.floor(total_time - elapse_time)
		self.node_list["CountTime"].text.text = time

		local roll_info = FuBenData.Instance:GetNeqRollInfo()
		local free_num = roll_info.max_free_roll_times - roll_info.free_roll_times
		-- 自动翻牌
		if time <= 0 then
			if free_num > 0 then
				self.auto_roll = true
				for i = 1, 3 do
					local is_on = true
					if self:GetReqIndexQueue(i) then
						is_on = false
					end
					if is_on then
						if self.count_down then
							CountDown.Instance:RemoveCountDown(self.count_down)
							self.count_down = nil
						end
						free_num = roll_info.max_free_roll_times - roll_info.free_roll_times
						if free_num > 0 then
							if i <= free_num then
								self:SendRollCard(i)
							end
						end
					end
				end
				self:OnClickClose(true)
			else
				self:OnClickClose()
			end
		end
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	local diff_time = 31
	self.count_down = CountDown.Instance:AddCountDown(diff_time, 1, Countdown)
end

function FuBenWeaponRollView:JumpAnimation()
	if next(self.sequence) then
		for k,v in pairs(self.sequence) do
			v:Kill()
			v = nil
		end
		self.sequence = {}

		for i = 1, 8 do
			if self.cover_item[i] and self.node_list["CardItem" .. i] then
				self.node_list["CardItem" .. i].transform.anchoredPosition = self.star_pos_list[i]
			end
		end
	else
		self.isnt_play_action = true
	end

	for i = 1, 8 do
		if self.cover_item[i] and not self:GetReqIndexQueue(i) then
			self.cover_item[i].gameObject:SetActive(true)
		end
	end
	self.is_roll_card = true
	self.node_list["BlackClick"]:SetActive(false)
end

function FuBenWeaponRollView:AutoFanPai()
	if self.is_on_close then
		-- FuBenCtrl.Instance:SendExitFBReq()
		-- self:OnClickClose(false)
		return
	end
	self.is_on_close = true
	local roll_info = FuBenData.Instance:GetNeqRollInfo()
	local free_times = roll_info.max_free_roll_times - roll_info.free_roll_times
	if free_times > 0 then
		if self.delay_timer then
			CountDown.Instance:RemoveCountDown(self.delay_timer)
			self.delay_timer = nil
		end

		-- if next(self.sequence) then
		-- 	for k,v in pairs(self.sequence) do
		-- 		v:Kill()
		-- 		v = nil
		-- 	end
		-- 	self.sequence = {}

		-- 	for i = 1, 8 do
		-- 		if self.cover_item[i] and self.node_list["CardItem" .. i] then
		-- 			-- self.cover_item[i].gameObject:SetActive(true)
		-- 			self.node_list["CardItem" .. i].transform.anchoredPosition = self.star_pos_list[i]
		-- 		end
		-- 	end
		-- else
		-- 	self.isnt_play_action = true
		-- end

		-- for i = 1, 8 do
		-- 	if self.cover_item[i] and not self:GetReqIndexQueue(i) then
		-- 		self.cover_item[i].gameObject:SetActive(true)
		-- 	end
		-- end
		self:JumpAnimation()

		if self.delay_timer4 then
			GlobalTimerQuest:CancelQuest(self.delay_timer4)
			self.delay_timer4 = nil
		end

		local send_index = 1
		self.delay_timer4 = GlobalTimerQuest:AddRunQuest(function()
			local is_send = true
			if self:GetReqIndexQueue(send_index) then
				is_send = false
			end
			if is_send and free_times > 0 then 
				self:SendRollCard(send_index)
				free_times = free_times - 1
			end
			send_index = send_index + 1

			if send_index > 3 or free_times <= 0 then
				if self.delay_timer4 then
					GlobalTimerQuest:CancelQuest(self.delay_timer4)
					self.delay_timer4 = nil
					-- local scene_type = Scene.Instance:GetSceneType()
					-- if scene_type == 0 then
						self:OnClickClose(true)
					-- end
					
				end
			end
		end, 0.1)
	else
		self:OnClickClose(false)
	end
end

function FuBenWeaponRollView:OnFlushStart()
	local pass_info = FuBenData.Instance:GetNeqPassInfo()
	for i = 1, 3 do
		if i > pass_info.pass_star then
			UI:SetGraphicGrey(self.node_list["Star" .. i], true)
		else
			UI:SetGraphicGrey(self.node_list["Star" .. i], false)
		end
	end

	self:PlayHasStar(pass_info.pass_star)

	local function PlayerAnimation()
		for i = 1, 8 do
			if not self.is_on_close and not self:GetReqIndexQueue(i) then
				self.cover_item[i].gameObject:SetActive(true)
			end
			self:DoWashCardAction(self.node_list["CardItem" .. i].transform, i)
		end
		self.node_list["BlackClick"]:SetActive(false)

		self.is_roll_card = true
	end
	if self.delay_timer then
		CountDown.Instance:RemoveCountDown(self.delay_timer)
		self.delay_timer = nil
	end

	self.delay_timer = GlobalTimerQuest:AddDelayTimer(PlayerAnimation, 2)
end

function FuBenWeaponRollView:DoWashCardAction(transform, index)
	if self.isnt_play_action then
		return
	end

	local TWEEN_TIME = 0.4

	local start_pos = transform.anchoredPosition
	local end_pos = Vector2(0, 0)
	local tween_in = transform:DOLocalMove(end_pos, TWEEN_TIME)
	tween_in:SetEase(DG.Tweening.Ease.Linear)
	local tween_out = transform:DOLocalMove(start_pos, TWEEN_TIME)
	tween_out:SetEase(DG.Tweening.Ease.Linear)

	self.sequence[index] = DG.Tweening.DOTween.Sequence()
	self.sequence[index]:Append(tween_in)
	self.sequence[index]:Append(tween_out)
	self.sequence[index]:SetEase(DG.Tweening.Ease.Linear)
end

function FuBenWeaponRollView:PlayHasStar(star_num)
	if nil == star_num then return end
	local pos = {}
	local time = 0
	for i = 1, 3 do
		self.node_list["Star"..i]:SetActive(false)
		local now_pos = {}
		now_pos.x, now_pos.y = self.node_list["Star" .. i].transform.localScale.x, self.node_list["Star" .. i].transform.localScale.y
		self.node_list["Star" .. i].transform.localScale = Vector3(5, 5, 5)
		table.insert(pos, now_pos)
	end

	local one_first = true
	local second_first = true
	local third_first = true
	local four_first = true
	self.star_timer_reqest = GlobalTimerQuest:AddRunQuest(function()
		if time < 0.3 then
			if one_first then
				one_first = false
				-- self.node_list["ImgSward"]:SetActive(true)
				-- UITween.MoveShowPanel(self.node_list["ImgSward"].transform, Vector3(-266, 195, 0), 0.3)
			end
		elseif time >= 0.3 and time < 0.6 then
			if second_first then
				second_first = false
				local tween_1 = self.node_list["Star1"].transform:DOScale(Vector3(pos[1].x, pos[1].y, 0), 0.3)
				local tween1 = self.node_list["Star1"].transform:DORotate(Vector3(0, 0, -360 * 3), 0.3, DG.Tweening.RotateMode.FastBeyond360)
				UITween.MoveShowPanel(self.node_list["Star1"].transform, Vector3(307, 258, 0), 0.3)
				self.node_list["Star1"]:SetActive(1 <= star_num)
			end
		elseif time >= 0.6 and time < 0.9 then
			if third_first then
				third_first = false
				self.node_list["Effect1"]:SetActive(true)
				local tween2 = self.node_list["Star2"].transform:DOScale(Vector3(pos[2].x, pos[2].y, 0), 0.3)
				local tween_2 = self.node_list["Star2"].transform:DORotate(Vector3(0, 0, -360 * 3), 0.3, DG.Tweening.RotateMode.FastBeyond360)
				UITween.MoveShowPanel(self.node_list["Star2"].transform, Vector3(382, 258, 0), 0.3)
				self.node_list["Star2"]:SetActive(2 <= star_num)
			end
		elseif time >= 0.9 and time < 1.2 then
			if four_first then
				four_first = false
				self.node_list["Effect2"]:SetActive(true)
				local tween3 = self.node_list["Star3"].transform:DOScale(Vector3(pos[3].x, pos[3].y, 0), 0.3)
				local tween_3 = self.node_list["Star3"].transform:DORotate(Vector3(0, 0, -360 * 3), 0.3, DG.Tweening.RotateMode.FastBeyond360)
				UITween.MoveShowPanel(self.node_list["Star3"].transform, Vector3(458, 258, 0), 0.3)
				self.node_list["Star3"]:SetActive(3 <= star_num)
			end
		elseif time >= 1.2 then
			if self.node_list then
				self.node_list["Effect3"]:SetActive(true)
			end
		end
		if time > 0.2 then
			--self.node_list["ImgEffect"]:SetActive(true)
		end
		if time > 1.5 then
			for i = 1,3 do
				self.node_list["Effect" .. i]:SetActive(false)
			end
			if self.star_timer_reqest then
				GlobalTimerQuest:CancelQuest(self.star_timer_reqest)
				self.star_timer_reqest = nil
			end
		end
		time = time + 0.1
	end, 0.1)
end

function FuBenWeaponRollView:OnSendRollCard(index)
	if not self.is_roll_card then return end
	if self:GetReqIndexQueue(index) then
		return
	end

	if not self.auto_roll then
		local roll_info = FuBenData.Instance:GetNeqRollInfo()
		local cost_cfg = FuBenData.Instance:GetWeaponCfgRollCost()
		if roll_info.gold_roll_times >= #cost_cfg then
			return
		end 
		local free_times = roll_info.max_free_roll_times - roll_info.free_roll_times
		local function ok_fun()
			self.count_cost_times = self.count_cost_times - 1
			self:SendRollCard(index)
		end
		local cost_num = FuBenData.Instance:GetWeaponRollCost()
		local des = string.format(Language.FuBen.WeaponRoll, cost_num)
		if free_times > 0 and self.count_free_times > 0 then
			self.count_free_times = self.count_free_times - 1
			self:SendRollCard(index)
		elseif self.count_cost_times > 0 then
			TipsCtrl.Instance:ShowCommonAutoView("fanpai", des, ok_fun)
		end
	end
end

function FuBenWeaponRollView:SendRollCard(index)
	-- 翻牌费用不足
	local roll_info = FuBenData.Instance:GetNeqRollInfo()
	if (roll_info.max_free_roll_times - roll_info.free_roll_times) <= 0 then
		local cost_num = FuBenData.Instance:GetWeaponRollCost()
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		if role_vo.gold < cost_num and role_vo.bind_gold < cost_num then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	end

	local can_add = true
	if self:GetReqIndexQueue(index) then
		can_add = false
	end

	if can_add then
		table.insert(self.req_index_queue, index)
		self.select_card_index = index
		self.select_list[index] = true
		FuBenCtrl.Instance:SendNeqRollReq(0)
	end
end

--刷新道具
function FuBenWeaponRollView:OnFlushReward()
	local function play_fanpai(index)
		local roll_info = FuBenData.Instance:GetNeqRollInfo()
		if -1 == roll_info.hit_seq or self.select_card_index == 0 then
			return
		end
		local item_pool = FuBenData.Instance:GetNeqRollPool()
		local card_item = self.item_list[index]
		local item_vo = item_pool[roll_info.hit_seq + 1]

		if nil ~= card_item then
			if nil ~= item_vo then
				card_item:SetData(item_vo)
				local item_cfg = ItemData.Instance:GetItemConfig(item_vo.item_id)
				if item_vo.num == 1 then
					self.item_name[index].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) .. "*"  .. item_vo.num
				elseif item_vo.num == 2 then
					self.item_name[index].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) .. string.format(Language.FuBen.WeaponColor, item_vo.num)
				else
					self.item_name[index].text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]) .. string.format(Language.FuBen.WeaponRedColor, item_vo.num)
				end
			end
		end

		self.is_rotation = true
		self.node_list["CardItem" .. index].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.node_list["CardItem" .. index].rect:DOScale(target_scale, 0.5)

		local func = function()
			self.cover_item[index].gameObject:SetActive(false)
			self.tweener2 = self.node_list["CardItem" .. index].rect:DOScale(target_scale2, 0.5)
			self.tweener2:OnComplete(function ()
				self.is_rotation = false
			end)
			
			if self.auto_roll then
				local roll_info = FuBenData.Instance:GetNeqRollInfo()
				if (roll_info.max_free_roll_times - roll_info.free_roll_times) > 0 then
					for i = 1, 3 do
						local is_on = true
						if self:GetReqIndexQueue(i) then
							is_on = false
						end

						if is_on then
							self:SendRollCard(i)
						end
					end
					self:OnClickClose(true)
				else
					self:OnClickClose(true)
				end
			end
		end

		if self.delay_timer2 then
			GlobalTimerQuest:CancelQuest(self.delay_timer2)
			self.delay_timer2 = nil
		end
		self.tweener1:OnComplete(func)
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func, 1)
	end

	for k, v in pairs(self.select_list) do
		if v then
			self.select_list[k] = false
			play_fanpai(k)
		end
	end
end

function FuBenWeaponRollView:GetReqIndexQueue(index)
	if self.req_index_queue and self.req_index_queue ~= "" then
		for _, v in pairs(self.req_index_queue) do
			if v and v == index then
				return true
			end
		end
	end
	return false
end