require("game/baoju/jingjie/jingjie_data")
--------------------------------------------------------------
--境界
--------------------------------------------------------------
JingJieCtrl = JingJieCtrl or BaseClass(BaseController)
function JingJieCtrl:__init()
	if JingJieCtrl.Instance then
		print_error("[JingJieCtrl] 尝试生成第二个单例模式")
	end
	JingJieCtrl.Instance = self
	self.data = JingJieData.New()
	self.view = nil
	self:RegisterAllProtocols()
end

function JingJieCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	JingJieCtrl.Instance = nil
end

function JingJieCtrl:RegisterView(view)
	self.view = view
end

function JingJieCtrl:UnRegisterView()
	self.view = nil
end

function JingJieCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRoleJingJie, "OnRoleJingJie")
end

function JingJieCtrl:OnRoleJingJie(protocol)
	self.data:SetjingjieInfo(protocol)
	Scene.Instance:GetMainRole():SetAttr("JingJie", protocol.jingjie_level)

	RemindManager.Instance:Fire(RemindName.ZhiBao_jingjie)
	RemindManager.Instance:Fire(RemindName.Baoju)
	if self.view then
		self.view:Flush()
	end
end

--请求境界信息
function JingJieCtrl.SendJingJieGetInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSJingJieGetInfo)
	protocol:EncodeAndSend()
end

--境界升级请求
function JingJieCtrl:SendUpJingJie(is_auto_buy)
	JingJieCtrl.SendRoleJingJieReq(JingJieData.OPERA.PROMOTE_LEVEL, is_auto_buy)
end

--境界升级请求
function JingJieCtrl.SendRoleJingJieReq(opera_type, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleJingJieReq)
	protocol.opera_type = opera_type
	protocol.is_auto_buy = is_auto_buy or 0
	protocol:EncodeAndSend()
end