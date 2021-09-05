require("game/gao_zhan_fu_ben/gao_zhan_data")
require("game/gao_zhan_fu_ben/gao_zhan_view")

GaoZhanCtrl = GaoZhanCtrl or BaseClass(BaseController)

function GaoZhanCtrl:__init()
	if GaoZhanCtrl.Instance ~= nil then
		ErrorLog("[GaoZhanCtrl] attempt to create singleton twice!")
		return
	end
	GaoZhanCtrl.Instance = self
	self.gao_zhan_data = GaoZhanData.New()
	self.gao_zhan_view = GaoZhanView.New(ViewName.GaoZhanFuBen)
	self:RegisterAllProtocols()
end

function GaoZhanCtrl:__delete()
	if self.gao_zhan_view ~= nil then
		self.gao_zhan_view:DeleteMe()
		self.gao_zhan_view = nil
	end

	if self.gao_zhan_data ~= nil then
		self.gao_zhan_data:DeleteMe()
		self.gao_zhan_data = nil
	end

	GaoZhanCtrl.Instance = nil
end

-- 协议注册
function GaoZhanCtrl:RegisterAllProtocols()

end

function GaoZhanCtrl:GetGaoZhanView()
	return self.gao_zhan_view
end

function GaoZhanCtrl:FlushView(param)
	self.gao_zhan_view:Flush(param)
end

function GaoZhanCtrl:FlushQualityFBIndex(index)
	if self.gao_zhan_view and self.gao_zhan_view.quality_view then
		self.gao_zhan_view.quality_view:JumpListIndex(index + 1)
	end
end

-- 获取爬塔面板
function GaoZhanCtrl:GetFuBenTowerView()
	return self.gao_zhan_view.tower_view
end

