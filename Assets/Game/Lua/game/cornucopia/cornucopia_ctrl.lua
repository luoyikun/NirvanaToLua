require("game/cornucopia/cornucopia_view")
require("game/cornucopia/cornucopia_data")

CornucopiaCtrl = CornucopiaCtrl or  BaseClass(BaseController)

function CornucopiaCtrl:__init()
	if CornucopiaCtrl.Instance ~= nil then
		print_error("[CornucopiaCtrl] attempt to create singleton twice!")
		return
	end
	CornucopiaCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = CornucopiaView.New(ViewName.CornucopiaView)
	self.data = CornucopiaData.New()
end

function CornucopiaCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	CornucopiaCtrl.Instance = nil
end

function CornucopiaCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(CSRuneSystemDisposeOneKey)
	-- self:RegisterProtocol(SCRuneSystemBagInfo, "OnRuneSystemBagInfo")
end

function CornucopiaCtrl:RuneSystemReq(req_type, param1, param2, param3, param4)
	-- print_error(req_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneSystemReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end
