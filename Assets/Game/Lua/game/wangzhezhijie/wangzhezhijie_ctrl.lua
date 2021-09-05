require("game/wangzhezhijie/wangzhezhijie_data")
require("game/wangzhezhijie/wangzhezhijie_view")

 WangZheZhiJieCtrl = WangZheZhiJieCtrl or BaseClass(BaseController)

function WangZheZhiJieCtrl:__init()
	if WangZheZhiJieCtrl.Instance ~= nil then
		ErrorLog("[WangZheZhiJieCtrl] attempt to create singleton twice!")
		return
	end
	WangZheZhiJieCtrl.Instance = self

	self.view = WangZheZhiJieView.New(ViewName.WangZheZhiJieView)
	self.data = WangZheZhiJieData.New()
	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)
 end

 function WangZheZhiJieCtrl:__delete()
 	if self.view then
 		self.view:DeleteMe()
 		self.view = nil
 	end

 	if self.data then
 		self.data:DeleteMe()
 		self.data = nil
 	end

 	if self.role_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
		self.role_change_callback = nil
	end

	WangZheZhiJieCtrl.Instance = nil

 end

function WangZheZhiJieCtrl:Flush()
	if self.view then
		self.view:Flush()
	end
end

-- 跨服1v1匹配请求
 function WangZheZhiJieCtrl:SendCrossMatch1V1Req(oper_type,ring_seq)
	 local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1WearRingReq)
	 send_protocol.opr_type = oper_type or 0
	 send_protocol.ring_seq = ring_seq or 0
	 send_protocol:EncodeAndSend()
 end

function WangZheZhiJieCtrl:RoleChangeCallBack(key, value, old_value)
 	if key == "base_fangyu" or key == "base_gongji" then
 		if self.view:IsOpen() then
 			self.view:Flush()
 		end
 	end
end