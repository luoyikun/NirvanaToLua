CoupleHomeData = CoupleHomeData or BaseClass()

function CoupleHomeData:__init()
	if CoupleHomeData.Instance then
		print_error("[CoupleHomeData] Attempt to create singleton twice!")
		return
	end

	local spouse_home_cfg = ConfigManager.Instance:GetAutoConfig("spouse_home_cfg_auto")
	self.other_cfg = spouse_home_cfg.other[1]

	CoupleHomeData.Instance = self
	RemindManager.Instance:Register(RemindName.FiftyPercent, BindTool.Bind(self.GetFiftyPercentRemind, self))
	RemindManager.Instance:Register(RemindName.BuyOneGetOne, BindTool.Bind(self.GetBuyOneGetOneRemind, self))
end

function CoupleHomeData:__delete()
	CoupleHomeData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.FiftyPercent)
	RemindManager.Instance:UnRegister(RemindName.BuyOneGetOne)
end

function CoupleHomeData:GetOtherCfg()
	return self.other_cfg
end

function CoupleHomeData:GetFiftyPercentRemind()
	if not OpenFunData.Instance:CheckIsHide("couplehomeview") then
		return 0
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		local is_show = RemindManager.Instance:RemindToday(RemindName.FiftyPercent)
		return is_show and 0 or 1
	else
		return 0
	end
end

function CoupleHomeData:GetBuyOneGetOneRemind()
	if not OpenFunData.Instance:CheckIsHide("couplehomeview") then
		return 0
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE) then
		local is_show = RemindManager.Instance:RemindToday(RemindName.BuyOneGetOne)
		return is_show and 0 or 1
	else
		return 0
	end
end