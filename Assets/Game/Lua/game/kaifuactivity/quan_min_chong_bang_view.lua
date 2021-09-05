QuanMinChongBangView = QuanMinChongBangView or BaseClass(BaseRender)

local rank_type_list ={
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL ,			--战力榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, 					--坐骑榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, 					--羽翼榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO, 					--光环榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING, 		--精灵总榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY, 		--女神总榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, 				--神弓榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI, 					--神翼榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM, 				--每日魅力榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--全身装备强化总等级榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--全身宝石总等级榜
}

local RankType = {
	-- EQUIP = 1,
	ZHANLI = 1,
	MOUNT = 4,
	WING = 5,
	HALO = 6,
	FIGHT_MOUNT = 7,
	SPIRIT = 8,
	GODDESS = 9,
	-- SHENGONG = 10,
	-- SHENYI = 11,
	-- STRENGTH = 13,
	-- STONE = 14,

}

local PaiHangBang_Index = {
	RankType.MOUNT,
	RankType.WING,
	RankType.GODDESS,
	RankType.HALO,
	RankType.SPIRIT,
	RankType.FIGHT_MOUNT,
	RankType.ZHANLI,
	-- RankType.SHENGONG,
	-- RankType.SHENYI,
	-- RankType.HALO,
	-- RankType.STRENGTH,
	-- RankType.STONE,
}


function QuanMinChongBangView:__init()
	self.play_audio = true
	self.item_list = {}
	self.reward_item_list = {}
	self.item_first_list = {}
	self.item_second_list = {}
	self.day_type = 0
	self.rank_type = 8
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtzhanliCount"])
end

function QuanMinChongBangView:__delete()
	self.activity_type = nil
	self.temp_display_role = nil

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}


	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.item_first_list) do
		v:DeleteMe()
	end
	self.item_first_list = {}

	for k, v in pairs(self.item_second_list) do
		v:DeleteMe()
	end
	self.item_second_list = {}


	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self.fight_text = nil
end


function QuanMinChongBangView:LoadCallBack()
	for i = 1, 4 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i] = cell
	end


	for i = 1, 2 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["RewardItem" .. i])
		self.reward_item_list[i] = cell
	end

	self.node_list["BtnLingque"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))

end

function QuanMinChongBangView:OpenCallBack()
	CompetitionActivityData.Instance:SetFirstOpenFlag()
	self:OnClickReward(TimeCtrl.Instance:GetCurOpenServerDay())
	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(reset_time_s)
	self.least_time_timer = CountDown.Instance:AddCountDown(reset_time_s, 1, function ()
			reset_time_s = reset_time_s - 1
			self:SetTime(reset_time_s)
	end)

end


function QuanMinChongBangView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.temp_display_role = nil

	self.day_type = 0


	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end


function QuanMinChongBangView:OnClickGetReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, #cfg or 0)
end

-- 领取奖励
function QuanMinChongBangView:FlushBtnReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local is_reward = KaifuActivityData.Instance:IsGetReward(cfg[#cfg].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(cfg[#cfg].seq, self.activity_type)
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local can_reward = is_complete and not is_reward and server_day == self.day_type
	UI:SetButtonEnabled(self.node_list["BtnLingque"], can_reward) 
	if is_complete and not is_reward and server_day == self.day_type then
		self.node_list["TxtBtn"].text.text = Language.Common.LingQu
	else
		self.node_list["TxtBtn"].text.text = Language.Common.YiLingQu
	end
end

-- 设置时间
function QuanMinChongBangView:SetTime(diff_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str
	if temp.day > 0 then
		str = string.format(Language.Activity.ActivityTime8, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, temp.hour, temp.min,temp.s)
	end

	self.node_list["TxtActTime"].text.text = str
end

-- 设置战力
function QuanMinChongBangView:SetFightPower(item_id)
	local fight_power = 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local cfg = TitleData.Instance:GetTitleCfg(item_cfg and item_cfg.param1 or 0)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end
end

-- 设置头像
function QuanMinChongBangView:SetTouXiang()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local active_rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(COMPETITION_ACTIVITY_TYPE[server_day])
	if nil == active_rank_info or nil == next(active_rank_info) or active_rank_info.top1_uid <= 0 then return end

	self.node_list["TxtPlayName"].text.text = active_rank_info.role_name

	local user_id = active_rank_info.top1_uid
	local prof = active_rank_info.role_prof
	local sex = active_rank_info.role_sex
	AvatarManager.Instance:SetAvatarKey(user_id, active_rank_info.avatar_key_big, active_rank_info.avatar_key_small)
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["raw_image_obj"], self.node_list["image_obj"], sex, prof, false)

	CheckCtrl.Instance:SendQueryRoleInfoReq(user_id)
end

-- 奖励信息
function QuanMinChongBangView:OnClickReward(day_type)
	for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
		if ActivityData.Instance:GetActivityIsOpen(v) and day_type == k then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			break
		end
	end
	if self.day_type == day_type then return end
	self.day_type = day_type
	self:FlushInfo(COMPETITION_ACTIVITY_TYPE[day_type])
end

function QuanMinChongBangView:FlushInfo(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)


	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	if self.activity_type == self.temp_activity_type then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			self.node_list["ListView"].scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type

	local item_gift_list = ItemData.Instance:GetGiftItemListByProf(cfg[1].reward_item[0].item_id)
	local display_role = 0
	local item_cfg = nil
	local item_id = 0
	local is_destory_effect = true

	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_gift_list[k])
		if item_gift_list[k] then
			v:SetGiftItemId(cfg[1].reward_item[0].item_id)
			for _, v2 in pairs(cfg[1].item_special or {}) do
				if v2.item_id == item_gift_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(false)
				v:SetActivityEffect()
			end
			v:SetData(item_gift_list[k])
			item_cfg = ItemData.Instance:GetItemConfig(item_gift_list[k].item_id)
			if display_role == 0 then
				display_role = item_cfg and item_cfg.is_display_role or 0
				item_id = item_gift_list[k].item_id
			end
		end
	end

	self:SetFightPower(item_id)
	local item_list = {}
	local reward_list = cfg[#cfg].reward_item
	for k, v in pairs(reward_list) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	for k, v in pairs(self.reward_item_list) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetData(item_list[k])
		end
	end
	sself.node_list["TxtHead3"].text.text = string.format(cfg[#cfg].description)
end

function QuanMinChongBangView:GetNumberOfCells()
	return (#KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type) - 2)
end

function QuanMinChongBangView:RefreshCell(cell, data_index)
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(self.activity_type)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = QuanMinChongBangCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local is_get = KaifuActivityData.Instance:IsGetReward(data_index + 2, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(data_index + 2, self.activity_type)

	cell_item:SetData(cfg[data_index + 2], is_get, is_complete)
	-- cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 2], is_get, is_complete))
end

function QuanMinChongBangView:OnFlush(param_list)
	self:SetTouXiang()
	self:FlushBtnReward()
end



QuanMinChongBangCell = QuanMinChongBangCell or BaseClass(BaseRender)

function QuanMinChongBangCell:__init(instance)

	self.cells = {}
	for i = 1, 4 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["CellItem_" .. i])
		self.cells[i] = cell
	end
end

function QuanMinChongBangCell:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function QuanMinChongBangCell:SetData(data, is_get, is_complete)
	if data == nil then return end
	self.node_list["TxtHead"].text.text = string.format(Language.Competition.WhoCanGetDesc, data.description)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}
	local gift_id = 0

	for k, v in pairs(data.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	local is_destory_effect = true
	for k, v in pairs(self.cells) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			for _, v2 in pairs(data.item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end

			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end
end
