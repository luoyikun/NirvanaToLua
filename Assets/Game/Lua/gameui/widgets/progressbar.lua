----------------------------------------------------
-- 进度条，对原始进度条的进一步封装，实现动画
----------------------------------------------------
TweenType = {
	IncreaseOnly = 1,
	DecreaseOnly = 2,
	DoubleWay = 3,
}

ProgressBar = ProgressBar or BaseClass()

function ProgressBar:__init(instance)
	self.progress = instance

	self.tween_type = TweenType.IncreaseOnly
	self.tween_time = 2
	self.cur_value = 0
	self.is_first_set = true
end

function ProgressBar:__delete()
	self:RemoveCountDown()
	self.progress = nil
end

function ProgressBar:SetTweenTime(tween_time)
	self.tween_time = tween_time
end

function ProgressBar:SetTweenType(tween_type)
	self.tween_type = tween_type
end

function ProgressBar:GetValue()
	return self.cur_value
end

function ProgressBar:SetValue(value)
	self.target_value = value

	if self.tween_time <= 0 or self.is_first_set then
		self.is_first_set = false
		self.progress.slider.value = value
		self.cur_value = value
	else
		self:StartTween()
	end
end

function ProgressBar:SetCompleteCallback(complete_callback)
	self.complete_callback = complete_callback
end

function ProgressBar:SetUpdateCallback(update_callback)
	self.update_callback = update_callback
end

function ProgressBar:StartTween()
	self.start_value = self.cur_value
	self.distance = self.target_value - self.cur_value

	if math.abs(self.distance) <= 0.01 then	-- 间隔太小不处理处画
		self:StopTween(true)
	else
		local tween_time = math.abs(self.distance) * self.tween_time
		if tween_time <= 0 then tween_time = 0.1 end

		self:RemoveCountDown()

		if TweenType.IncreaseOnly == self.tween_type and self.distance <= 0 then
			self.progress.slider.value = self.target_value
			self.cur_value = self.target_value
		elseif TweenType.DecreaseOnly == self.tween_type and self.distance >= 0 then
			self.progress.slider.value = self.target_value
			self.cur_value = self.target_value
		else
			self.countdown_id = CountDown.Instance:AddCountDown(tween_time, 0.01, 
				BindTool.Bind1(self.OnTweening, self), 
				BindTool.Bind1(self.StopTween, self))
		end
	end
end

function ProgressBar:StopTween(is_ignore_limit)
	if nil == self.countdown_id and not is_ignore_limit then
		return
	end

	self:RemoveCountDown()
	self.cur_value = self.target_value

	if self.cache_target_value ~= nil then --继续从头开始
		self.cur_value = 0
		self.target_value = self.cache_target_value
		self.cache_target_value = nil
		self.progress.slider.value = 0
		if self.target_value > 0 then
			self:StartTween()
		end
	else
		self.progress.slider.value = self.target_value
		if self.complete_callback then
			self.complete_callback()
		end
	end
end

function ProgressBar:OnTweening(elapse_time, tween_time)
	self.cur_value = self.start_value + elapse_time / tween_time * self.distance
	if (self.distance > 0 and self.cur_value >= self.target_value) 
		or (self.distance < 0 and self.cur_value <= self.target_value) then		
		self:StopTween()
	else
		self.progress.slider.value = self.cur_value
		if nil ~= self.update_callback then
			self.update_callback(self.cur_value)
		end
	end
end

function ProgressBar:RemoveCountDown()
	if self.countdown_id ~= nil then
		CountDown.Instance:RemoveCountDown(self.countdown_id)
		self.countdown_id = nil
	end
end
