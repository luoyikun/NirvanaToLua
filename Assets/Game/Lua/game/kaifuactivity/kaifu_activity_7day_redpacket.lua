KaifuActivity7DayRedpacket = KaifuActivity7DayRedpacket or BaseClass(BaseRender)

local HONGBAO_ZHUANGTAI_FLAG = {
	[1] = {true, false, false},
	[2] = {false, true, false},
	[3] = {false, false, true},
}

local MAX_RED_PACKET_NUM = 7

function KaifuActivity7DayRedpacket:__init()
	self.total_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.red_packet_list = {}
	--计数器
	self.count_down = nil

	for i = 1 , MAX_RED_PACKET_NUM do
		self.red_packet_list[i] = KaifuActivityRedpacketCell.New(self.node_list["CellRedPacket" .. i])
		self.red_packet_list[i]:FlushData(i, self.total_day)
	end

	self:FlushView()
end

function KaifuActivity7DayRedpacket:__delete()
	for i = 1, MAX_RED_PACKET_NUM do
		if self.red_packet_list[i]	then
			self.red_packet_list[i]:DeleteMe()
			self.red_packet_list[i] = nil
		end
	end

	if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
	end
end

function KaifuActivity7DayRedpacket:FlushView()
	local recharge_list = ActiviteHongBaoData.Instance:GetDiamondNum()
	local rebate_val =  ActiviteHongBaoData.Instance:GetRebateTotalVal()
	self.total_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if self.total_day >= 8 then
		self.node_list["NodeLeiji"]:SetActive(false)
		self.node_list["NodeDate"]:SetActive(false)
	end

	self.node_list["TxtLeiji"].text.text = recharge_list[self.total_day]
	self.node_list["TxtRebate"].text.text = rebate_val

	if self.total_day < 8 then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		local rebate_day = MAX_RED_PACKET_NUM - self.total_day
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:SetRestTime(reset_time_s,rebate_day)
	else
		self.node_list["TxtTime"].text.text ="<color = red>" .. Language.OpenServer.RollActivityEnd .. "</color>"
	end

	for i = 1 ,MAX_RED_PACKET_NUM do
		self.red_packet_list[i]:FlushData(i, self.total_day)
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivity7DayRedpacket:SetRestTime(diff_time,rebate_day)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_tab = TimeUtil.Format2TableDHMS(left_time)
			local time_str = nil
			if time_tab.day >= 1 then
				time_str = string.format(Language.JinYinTa.ActEndTime, time_tab.day, time_tab.hour)
			else
				time_str = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
			end
			self.node_list["TxtTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function KaifuActivity7DayRedpacket:OnFlush()
	self:FlushView()
end

-----红包cell
KaifuActivityRedpacketCell = KaifuActivityRedpacketCell or BaseClass(BaseRender)

function KaifuActivityRedpacketCell:__init()
	self.node_list["BtnOpen"].button:AddClickListener(BindTool.Bind(self.OnOpenButtonClick,self))
end

function KaifuActivityRedpacketCell:__delete()

end

function KaifuActivityRedpacketCell:FlushData(index, cur_day)
	self.day = index or self.day
	local rebate_val = ActiviteHongBaoData.Instance:GetRebateDayVal(index)
	local flag = 0
	self.node_list["TxtCanGet"].text.text = rebate_val
	self.node_list["TxtHadGet"].text.text = rebate_val
	if cur_day < 8 then
		if index < cur_day then
			self:SetAmountActive(true)
		elseif index == cur_day then
			self:SetAmountActive(true)
		else
			self:SetAmountActive(false)
			flag = 1
		end
	else
		if ActiviteHongBaoData.Instance:GetRebateDayVal(index) == 0 then
			self:SetAmountActive(true)
		else
			self:SetAmountActive(false)
			if ActiviteHongBaoData.Instance:GetFlag(index) == 0 then
				flag = 3
			else
				flag = 2
			end
		end
	end
	
	self:SetZhuangTai(flag)
end

function KaifuActivityRedpacketCell:SetZhuangTai(flag)
	if flag == 0 then
		return
	end
	self.node_list["ImgTips"]:SetActive(HONGBAO_ZHUANGTAI_FLAG[flag][1])
	self.node_list["NodeGot"]:SetActive(HONGBAO_ZHUANGTAI_FLAG[flag][2])
	self.node_list["BtnOpen"]:SetActive(HONGBAO_ZHUANGTAI_FLAG[flag][3])
end

function KaifuActivityRedpacketCell:SetAmountActive(is_show)
	self.node_list["ImgBottomRed"]:SetActive(is_show)
	self.node_list["NodeZhuangtai"]:SetActive(not is_show)
end

function KaifuActivityRedpacketCell:OnOpenButtonClick()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.day - 1)
end
