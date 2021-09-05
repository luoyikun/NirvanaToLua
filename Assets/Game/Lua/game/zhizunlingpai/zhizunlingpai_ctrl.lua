require("game/zhizunlingpai/zhizunlingpai_data")
require("game/zhizunlingpai/zhizunlingpai_view")

 ZhiZunLingPaiCtrl = ZhiZunLingPaiCtrl or BaseClass(BaseController)

function ZhiZunLingPaiCtrl:__init()
	if ZhiZunLingPaiCtrl.Instance ~= nil then
		ErrorLog("[ZhiZunLingPaiCtrl] attempt to create singleton twice!")
		return
	end
	ZhiZunLingPaiCtrl.Instance = self

	self.view = ZhiZunLingPaiView.New(ViewName.ZhiZunLingPaiView)
	self.data = ZhiZunLingPaiData.New()
	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)
 end

 function ZhiZunLingPaiCtrl:__delete()
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

	ZhiZunLingPaiCtrl.Instance = nil

 end

function ZhiZunLingPaiCtrl:Flush()
	if self.view then
		self.view:Flush()
	end
end

-- 跨服3v3令牌请求
 function ZhiZunLingPaiCtrl:SendCross3v3LingPai(oper_type,card_seq)
	 local send_protocol = ProtocolPool.Instance:GetProtocol(CSMultiuserChallengeWearCardReq)
	 send_protocol.opr_type = oper_type or 0
	 send_protocol.card_seq = card_seq or 0
	 send_protocol:EncodeAndSend()
 end

 function ZhiZunLingPaiCtrl:RoleChangeCallBack(key, value, old_value)
 	if key == "base_fangyu" or key == "base_gongji" then
 		if self.view:IsOpen() then
 			self.view:Flush()
 		end
 	end
end