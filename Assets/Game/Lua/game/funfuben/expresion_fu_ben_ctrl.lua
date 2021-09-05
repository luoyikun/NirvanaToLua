
require("game/funfuben/eqxpresion_fu_ben_data")

ExpresionFuBenCtrl = ExpresionFuBenCtrl or BaseClass(BaseController)

function ExpresionFuBenCtrl:__init()
	if ExpresionFuBenCtrl.Instance ~= nil then
		print_error("[ExpresionFuBenCtrl] Attemp to create a singleton twice !")
		return
	end
	ExpresionFuBenCtrl.Instance = self
	
	self:RegisterAllProtocols()
end

function ExpresionFuBenCtrl:__delete()
	ExpresionFuBenCtrl.Instance = nil

end

function ExpresionFuBenCtrl:RegisterAllProtocols()

end

-- 坐骑副本信息返回
function ExpresionFuBenCtrl:GetFunOpenMountInfo(protocol)
	self.expresion_fu_ben_data:SetMountFuBenInfo(protocol)

	if ViewManager.Instance:IsOpen(ViewName.MountFuBenView) then
		self.mount_fu_ben_view:Flush()
	end
	if protocol.is_finish == 1 then
	end
end

-- 羽翼副本信息返回
function ExpresionFuBenCtrl:GetWingFuBenInfo(protocol)
	self.expresion_fu_ben_data:SetWingFuBenInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.WingFuBenView) then
		self.wing_fu_ben_view:Flush()
	end
	if protocol.is_finish == 1 then

	end
end

-- 精灵副本信息返回
function ExpresionFuBenCtrl:GetJingLingFuBenInfo(protocol)
	self.expresion_fu_ben_data:SetJingLingFuBenInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
		self.jingling_fu_ben_view:Flush()
	end

end


function ExpresionFuBenCtrl:CloseFuBenView()
	if ViewManager.Instance:IsOpen(ViewName.MountFuBenView) then
		self.mount_fu_ben_view:Release()
	elseif ViewManager.Instance:IsOpen(ViewName.WingFuBenView) then
		self.wing_fu_ben_view:Release()
	elseif ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
		self.jingling_fu_ben_view:Release()
	end
end

-- 进入副本时，返回信息
function ExpresionFuBenCtrl:GetFBSceneLogicInfoReq(protocol)

end

function ExpresionFuBenCtrl:SceneLoadComplete(scene_id)

end