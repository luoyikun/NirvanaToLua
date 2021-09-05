require("game/couple_home/couple_home_home/couple_home_home_data")

CoupleHomeHomeCtrl = CoupleHomeHomeCtrl or BaseClass(BaseController)

function CoupleHomeHomeCtrl:__init()
	if CoupleHomeHomeCtrl.Instance ~= nil then
		print_error("[CoupleHomeHomeCtrl] attempt to create singleton twice!")
		return
	end

	CoupleHomeHomeCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = CoupleHomeHomeData.New()
end

function CoupleHomeHomeCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	CoupleHomeHomeCtrl.Instance = nil
end

-- 协议注册
function CoupleHomeHomeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSSpouseHomeOperaReq)
	self:RegisterProtocol(SCSpouseHomeRoomInfo, "OnSCSpouseHomeRoomInfo")
	self:RegisterProtocol(SCSpouseHomeSingleRoomInfo, "OnSpouseHomeSingleRoomInfo")
	self:RegisterProtocol(SCSpouseHomeFirendInfo, "OnSpouseHomeFirendInfo")
	self:RegisterProtocol(SCSpouseHomeGuildMemberInfo, "OnSpouseHomeGuildMemberInfo")
end

function CoupleHomeHomeCtrl:OnSCSpouseHomeRoomInfo(protocol)
	self.data:SetHouseUid(protocol.uid)
	self.data:SetPetId(protocol.pet_id)
	self.data:SetMaxFurnitureCount(protocol.room_furniture_limit)
	self.data:SetHouseList(protocol.house_list)

	--关闭购买界面
	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeThemeBuyView) then
		ViewManager.Instance:Close(ViewName.CoupleHomeThemeBuyView)
	end

	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeView) then
		if protocol.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
			ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "decorate", {is_self = false})
		else
			if #protocol.house_list > 0 then
				ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "decorate", {is_self = true})
			else
				ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "buy")
			end
		end
	end
end

function CoupleHomeHomeCtrl:OnSpouseHomeSingleRoomInfo(protocol)
	local house_uid = self.data:GetHouseUid()
	if house_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		--当前房子不是自己的不处理该数据
		return
	end

	self.data:SetPetId(protocol.pet_id)
	self.data:SetMaxFurnitureCount(protocol.room_furniture_limit)
	
	--关闭购买界面
	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeThemeBuyView) then
		ViewManager.Instance:Close(ViewName.CoupleHomeThemeBuyView)
	end

	local house_count_change = false
	local last_house_list = self.data:GetHouseList() or {}
	local last_house_count = #last_house_list

	--更新我的房子数据
	self.data:UpdateHouseList(protocol.house_info)

	local now_house_list = self.data:GetHouseList() or {}
	local now_house_count = #now_house_list
	if last_house_count < now_house_count then
		house_count_change = true
	end

	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeView) then
		ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "decorate", {is_self = true, house_count_change = house_count_change})
	end

	if ViewManager.Instance:IsOpen(ViewName.CoupleHomePacketView) then
		ViewManager.Instance:FlushView(ViewName.CoupleHomePacketView)
	end
end

function CoupleHomeHomeCtrl:OnSpouseHomeFirendInfo(protocol)
	self.data:SetFriendList(protocol.firend_info_list)

	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeView) then
		ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "friend")
	end
end

function CoupleHomeHomeCtrl:OnSpouseHomeGuildMemberInfo(protocol)
	self.data:SetGuildList(protocol.guild_member_info_list)

	if ViewManager.Instance:IsOpen(ViewName.CoupleHomeView) then
		ViewManager.Instance:FlushView(ViewName.CoupleHomeView, "guild")
	end
end

function CoupleHomeHomeCtrl:SendSpouseHomeOperaReq(opera_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSpouseHomeOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end