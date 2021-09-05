TipsTimeCountDownView = TipsTimeCountDownView or BaseClass(BaseView)

function TipsTimeCountDownView:__init()
	self.ui_config = {{"uis/views/tips/timecountdowntip_prefab", "TimeCountDownTips"}}
	self.des_value = ""
	self.view_layer = UiLayer.MainUIHigh
	self.reset_time = 0
end

function TipsTimeCountDownView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsTimeCountDownView:LoadCallBack()
end

function TipsTimeCountDownView:ReleaseCallBack()
end

function TipsTimeCountDownView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time_value = 0
	self.des_value = ""
	self.reset_time = 0
end

function TipsTimeCountDownView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value or self.reset_time > 0 then
		return
	end
	self:Close()
end

function TipsTimeCountDownView:DestoryTimeCountDownView()
	self:Close()
end

function TipsTimeCountDownView:OpenCallBack()
	self:Flush()
end

function TipsTimeCountDownView:SetTime(time_value)
	self.time_value = time_value or 0
end

-- function TipsTimeCountDownView:SetDes(des_value)
-- 	self.des_value = des_value or ""
-- end

function TipsTimeCountDownView:OnFlush()
	-- if type(self.des_value) ~= "string" then
	-- 	self.des_value = ""
	-- end
	-- self.node_list["TxtDes"].text.text = self.des_value

	if self.time_value > 0 and not self.count_down then
		local diff_time = self.time_value

		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			self.reset_time = left_time
			if left_time <= 0 then
				self.node_list["TxtTime"].text.text = 0

				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end

				self:Close()
				return
			end
			self.node_list["TxtTime"].text.text = left_time
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end