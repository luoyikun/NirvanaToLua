XianShiLianChongData = XianShiLianChongData or BaseClass()

function XianShiLianChongData:__init()
	if XianShiLianChongData.Instance then
		print_error("[XianShiLianChongData] Attempt to create singleton twice!")
		return
	end
	XianShiLianChongData.Instance = self

	self.lianchong_2_point = true
	RemindManager.Instance:Register(RemindName.XianShiLianChong, BindTool.Bind(self.XianShiLianChongRedPoint, self))
end

function XianShiLianChongData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XianShiLianChong)
	XianShiLianChongData.Instance = nil
end

function XianShiLianChongData:SetChongZhInfo(protocol)
	self.chongzhi_info = protocol
end

function XianShiLianChongData:GetChongZhInfo()
	return self.chongzhi_info
end


-- 连充特惠高配置
function XianShiLianChongData:ChongZhiCfgInfo()
	local list_gao = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiList()
	if nil == cfg then
		return
	end

	if ServerActivityData.Instance then
		for k, v in pairs(cfg.continue_chonghzi_2) do
			if v.open_server_day == today then
				table.insert(temp_table, cfg.continue_chonghzi_2[k])

			end
		end
		self.teihuigao = temp_table
	end

	if nil ~= self:GetChongZhInfo() then
		local has_reward_falg = bit:d2b(self:GetChongZhInfo().has_fetch_reward_falg)
		local can_reward = {}
		local has_reward = {}

		for i = #self.teihuigao, 1, -1  do
			if has_reward_falg[32 - self.teihuigao[i].day_index] == 1 then
				table.insert(list_gao, self.teihuigao[i])
			else
				table.insert(list_gao, 1, self.teihuigao[i])
			end
		end
	end
	return list_gao
end

function XianShiLianChongData:ChongZhiList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG)

	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_2) do
		if (openday - activity_day + 1) <= v.open_server_day then
			return v.open_server_day
		end
	end
end

function XianShiLianChongData:LianChongRedPoint()
	local chongzhi_info = self:GetChongZhInfo()
	local cfg = self:ChongZhiCfgInfo() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end
	if chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if v.day_index == chongzhi_info.continue_chongzhi_days then
				is_red = true
			end
		end
	elseif chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		-- 今日充值没达到指定额度提示红点
		if not self.lianchong_2_point then
			return false
		end

		if cfg[1] and chongzhi_info.today_chongzhi < cfg[1].need_chongzhi and self.lianchong_2_point then
			is_red = true
		else
			is_red = false
		end
	end

	return is_red
end

function XianShiLianChongData:SetLianchongRedPointState(value)
	self.lianchong_2_point = value
end


function XianShiLianChongData:XianShiLianChongRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG) then
		return 0
	end
	local remind_num = self:LianChongRedPoint() and 1 or 0
	return remind_num
end