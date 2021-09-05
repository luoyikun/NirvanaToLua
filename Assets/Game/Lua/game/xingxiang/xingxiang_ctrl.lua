require("game/xingxiang/xingxiang_data")
require("game/xingxiang/xingxiang_view")
require("game/xingxiang/xingxiang_info_view")
require("game/xingxiang/xingxiangfenjie_view")
XingXiangCtrl = XingXiangCtrl or BaseClass(BaseController)

function XingXiangCtrl:__init()
	if nil ~= XingXiangCtrl.Instance then
		print_error("[XingXiangCtrl] Attemp to create a singleton twice !")
	end

	XingXiangCtrl.Instance = self

	self.data = XingXiangData.New()
	self.view = XingXiangView.New(ViewName.XingXiangView)
	self.xing_xiang_fenjie_view = ShengXiaoRecycleView.New(ViewName.XingXiangRecycle)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self:RegisterAllProtocols()
end

function XingXiangCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.xing_xiang_fenjie_view then
		self.xing_xiang_fenjie_view:DeleteMe()
		self.xing_xiang_fenjie_view = nil
	end

	XingXiangCtrl.Instance = nil
end

function XingXiangCtrl:RegisterAllProtocols()
	-- 生肖星图
	self:RegisterProtocol(CSZodiacReq)										-- 请求
	self:RegisterProtocol(CSZodiacDecomposeReq)								-- 分解	
	self:RegisterProtocol(SCZodiacInfo, "OnZodiacInfo")						-- 生肖信息
	self:RegisterProtocol(SCZodiacBackpackInfo, "OnZodiacBackpackInfo")		-- 背包信息
	self:RegisterProtocol(SCZodiacBaseInfo, "OnSCZodiacBaseInfo")		-- 背包信息
end

function XingXiangCtrl:MainuiOpenCreate()
	
end


--发送生肖协议
function XingXiangCtrl:SendUseShengXiao(req_type, param1,param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSZodiacReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function XingXiangCtrl:SendShengXiaoDecom(req_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSZodiacDecomposeReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function XingXiangCtrl:SendRecycleXingXiang(num, recycle_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSZodiacDecomposeReq)
	protocol.decompose_num = num or 0
	protocol.decompose_backpack_index_list = recycle_list or {}
	protocol:EncodeAndSend()
end

function XingXiangCtrl:OnZodiacInfo(protocol)
	self.data:SetXingXiangData(protocol.zodiac_item)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.XingXiangView)
end

function XingXiangCtrl:OnZodiacBackpackInfo(protocol)
	self.data:SetXingXiangBagData(protocol.grid_list)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.xing_xiang_fenjie_view:IsOpen() then
		self.xing_xiang_fenjie_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.XingXiangView)
end
--打开星象分解背包
function XingXiangCtrl:OpenXingXiangBag()
	
end
--刷新星象分解背包
function XingXiangCtrl:FlushXingXiangBag()


end

--关闭星象分解背包
function XingXiangCtrl:CloseShengXiaoBag()
	
end


function XingXiangCtrl:OnSCZodiacBaseInfo(protocol)
	self.data:SetJingHuangNum(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.XingXiangView)
end



