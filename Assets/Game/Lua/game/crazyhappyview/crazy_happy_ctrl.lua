require("game/crazyhappyview/crazy_happy_data")
require("game/crazyhappyview/crazy_happy_view")
CrazyHappyCtrl = CrazyHappyCtrl or BaseClass(BaseController)

function CrazyHappyCtrl:__init()
	if CrazyHappyCtrl.Instance ~= nil then
		print_error("[CrazyHappyCtrl] Attemp to create a singleton twice !")
	end

	CrazyHappyCtrl.Instance = self
	
	self.data = CrazyHappyData.New()
	self.view = CrazyHappyView.New(ViewName.CrazyHappyView)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function CrazyHappyCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	

	CrazyHappyCtrl.Instance = nil
end

function CrazyHappyCtrl:ActivityCallBack(activity_type, status)
	for i = 1, 3 do
		if activity_type == LEIJI_CHARGE_LIST[i] then
			if status == 2 then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(LEIJI_CHARGE_LIST[i], RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
			elseif status == 0 then
				 CrazyHappyData.Instance:ClearData(LEIJI_CHARGE_LIST[i])
			end
			return
		elseif  activity_type == DANBI_CHARGE_LIST[i] then
			if status == 2 then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(DANBI_CHARGE_LIST[i], RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
			elseif status == 0 then
				 CrazyHappyData.Instance:ClearSingleChargeData(DANBI_CHARGE_LIST[i])
			end
			return
		end
	end
end

function CrazyHappyCtrl:MainuiOpenCreate()
	for i = 1, 3 do
		if LEIJI_CHARGE_LIST[i] then
			if ActivityData.Instance:GetActivityIsOpen(LEIJI_CHARGE_LIST[i]) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(LEIJI_CHARGE_LIST[i], RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
			end
		end
	end
end

function CrazyHappyCtrl:GetView()
	return self.view
end

function CrazyHappyCtrl:RegisterAllProtocols()
	-- 累计充值
	self:RegisterProtocol(SCRATotalChargeMultiInfo, "OnSCRATotalChargeMultiInfo")
	self:RegisterProtocol(SCSingleChargeInfoMulti, "OnSCSingleChargeInfoMulti")
end

function CrazyHappyCtrl:OnSCRATotalChargeMultiInfo(protocol)
	self.data:SetAllRANewTotalChargeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.CrazyHappyView)
	if self.view:IsOpen() then
		self.view:Flush()
		if protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE then
			self.view:FlushLeiJiOneChongZhi()
		elseif protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO then
			self.view:FlushLeiJiTwoChongZhi()
		elseif protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE then
			self.view:FlushLeiJiThreeChongZhi()
		end
	end
	MainUICtrl.Instance:GetView():FlushIconGroupThree()
end

function CrazyHappyCtrl:OnSCSingleChargeInfoMulti(protocol)
	self.data:SetAllRANewSingleChargeInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
		if protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE then
			self.view:FlushDanBiOneChongZhi()
		elseif protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO then
			self.view:FlushDanBiTwoChongZhi()
		elseif protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE then
			self.view:FlushDanBiThreeChongZhi()
		end
	end
	MainUICtrl.Instance:GetView():FlushIconGroupThree()
end


function CrazyHappyCtrl:OnKaifuActivityInfo()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end


function CrazyHappyCtrl:FlushKaifuView()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--关闭界面
function CrazyHappyCtrl:CloseKaiFuView()
	self.view:Close()
end

