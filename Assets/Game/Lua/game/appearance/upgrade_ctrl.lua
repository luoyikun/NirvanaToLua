require("game/appearance/ling_zhu/ling_zhu_data")				-- 灵珠
require("game/appearance/ling_zhu/ling_zhu_huan_hua_view")		-- 灵珠幻化
require("game/appearance/xian_bao/xian_bao_data")				-- 仙宝
require("game/appearance/xian_bao/xian_bao_huan_hua_view")		-- 仙宝幻化
require("game/appearance/ling_tong/ling_chong_data")			-- 灵童
require("game/appearance/ling_tong/ling_chong_huan_hua_view")	-- 灵童幻化
require("game/appearance/ling_gong/ling_gong_data")				-- 灵弓
require("game/appearance/ling_gong/ling_gong_huan_hua_view")  	-- 灵弓幻化
require("game/appearance/ling_qi/ling_qi_data")					-- 灵骑
require("game/appearance/ling_qi/ling_qi_huan_hua_view")	  	-- 灵骑幻化
require("game/appearance/wei_yan/wei_yan_data")					-- 尾焰
require("game/appearance/wei_yan/wei_yan_huan_hua_view")		-- 尾焰幻化
require("game/appearance/shou_huan/shou_huan_data")				-- 手环
require("game/appearance/shou_huan/shou_huan_huan_hua_view")	-- 手环幻化
require("game/appearance/tail/tail_data")						-- 尾巴
require("game/appearance/tail/tail_huan_hua_view")				-- 尾巴幻化
require("game/appearance/fly_pet/fly_pet_data")					-- 飞宠
require("game/appearance/fly_pet/fly_pet_huan_hua_view")		-- 飞宠幻化


UpgradeCtrl = UpgradeCtrl or BaseClass(BaseController)

function UpgradeCtrl:__init()
	if UpgradeCtrl.Instance ~= nil then
		ErrorLog("[UpgradeCtrl] attempt to create singleton twice!")
		return
	end

	UpgradeCtrl.Instance = self
	self.ling_zhu_data = LingZhuData.New()		-- 灵珠进阶
	self.ling_zhu_huan_hua_view = LingZhuHuanHuaView.New(ViewName.LingZhuHuanHua)		-- 灵珠幻化
	self.xian_bao_data = XianBaoData.New()		-- 仙宝进阶
	self.xian_bao_huan_hua_view = XianBaoHuanHuaView.New(ViewName.XianBaoHuanHua)		-- 仙宝幻化
	self.ling_chong_data = LingChongData.New()	-- 灵童进阶
	self.ling_chong_huan_hua_view = LingChongHuanHuaView.New(ViewName.LingChongHuanHua)	-- 灵童幻化
	self.ling_gong_data = LingGongData.New()	-- 灵弓进阶
	self.ling_gong_huan_hua_view = LingGongHuanHuaView.New(ViewName.LingGongHuanHua)	-- 灵弓幻化
	self.ling_qi_data = LingQiData.New()		-- 灵骑进阶
	self.ling_qi_huan_hua_view = LingQiHuanHuaView.New(ViewName.LingQiHuanHua)			-- 灵骑幻化
	self.weiyan_data = WeiYanData.New() 		-- 尾焰进阶
	self.wei_yan_huan_hua_view = WeiYanHuanHuaView.New(ViewName.WeiYanHuanHua) 			-- 尾焰幻化
	self.shouhuan_data = ShouHuanData.New()		-- 手环进阶
	self.shou_huan_huan_hua_view = ShouHuanHuanHuaView.New(ViewName.ShouHuanHuanHua)	-- 手环幻化
	self.tail_data = TailData.New()				-- 尾巴进阶
	self.tail_huan_hua_view = TailHuanHuaView.New(ViewName.TailHuanHua)					-- 尾巴幻化
	self.flypet_data = FlyPetData.New()			-- 飞宠进阶
	self.fly_pet_huan_hua_view = FlyPetHuanHuaView.New(ViewName.FlyPetHuanHua)			-- 飞宠幻化

	self:RegisterUpgradeProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function UpgradeCtrl:__delete()
	if self.ling_zhu_data then
		self.ling_zhu_data:DeleteMe()
		self.ling_zhu_data = nil
	end

	if self.ling_zhu_huan_hua_view then
		self.ling_zhu_huan_hua_view:DeleteMe()
		self.ling_zhu_huan_hua_view = nil
	end
	
	if self.xian_bao_data then
		self.xian_bao_data:DeleteMe()
		self.xian_bao_data = nil
	end

	if self.xian_bao_huan_hua_view then
		self.xian_bao_huan_hua_view:DeleteMe()
		self.xian_bao_huan_hua_view = nil
	end

	if self.ling_chong_data then
		self.ling_chong_data:DeleteMe()
		self.ling_chong_data = nil
	end

	if self.ling_chong_huan_hua_view then
		self.ling_chong_huan_hua_view:DeleteMe()
		self.ling_chong_huan_hua_view = nil
	end

	if self.ling_gong_data then
		self.ling_gong_data:DeleteMe()
		self.ling_gong_data = nil
	end

	if self.ling_gong_huan_hua_view then
		self.ling_gong_huan_hua_view:DeleteMe()
		self.ling_gong_huan_hua_view = nil
	end

	if self.ling_qi_data then
		self.ling_qi_data:DeleteMe()
		self.ling_qi_data = nil
	end

	if self.ling_qi_huan_hua_view then
		self.ling_qi_huan_hua_view:DeleteMe()
		self.ling_qi_huan_hua_view = nil
	end

	if self.weiyan_data then
		self.weiyan_data:DeleteMe()
		self.weiyan_data = nil
	end


	if self.wei_yan_huan_hua_view then
		self.wei_yan_huan_hua_view:DeleteMe()
		self.wei_yan_huan_hua_view = nil
	end

	if self.shouhuan_data then
		self.shouhuan_data:DeleteMe()
		self.shouhuan_data = nil
	end

	if self.shou_huan_huan_hua_view then
		self.shou_huan_huan_hua_view:DeleteMe()
		self.shou_huan_huan_hua_view = nil
	end

	if self.tail_data then
		self.tail_data:DeleteMe()
		self.tail_data = nil
	end

	if self.tail_huan_hua_view then
		self.tail_huan_hua_view:DeleteMe()
		self.tail_huan_hua_view = nil
	end

	if self.flypet_data then
		self.flypet_data:DeleteMe()
		self.flypet_data = nil
	end

	if self.fly_pet_huan_hua_view then
		self.fly_pet_huan_hua_view:DeleteMe()
		self.fly_pet_huan_hua_view = nil
	end

	UpgradeCtrl.Instance = nil
end

function UpgradeCtrl:RegisterUpgradeProtocols()
	self:RegisterProtocol(SCUpgradeInfo, "OnUpgradeInfo")
	self:RegisterProtocol(SCUpgradeAppeChange, "OnUpgradeAppeChange")
	self:RegisterProtocol(CSUpgradeOperaReq)
end

function UpgradeCtrl:OnUpgradeInfo(protocol)
	if protocol.upgrade_type == UPGRADE_TYPE.LING_ZHU then		-- 灵珠
		self.ling_zhu_data:SetLingZhuInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingzhu")
		end
		RemindManager.Instance:Fire(RemindName.LingZhu)

		if self.ling_zhu_huan_hua_view and self.ling_zhu_huan_hua_view:IsOpen() then
			self.ling_zhu_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.XIAN_BAO then 	-- 仙宝
		self.xian_bao_data:SetXianBaoInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "xianbao")
		end
		RemindManager.Instance:Fire(RemindName.XianBao)

		if self.xian_bao_huan_hua_view and self.xian_bao_huan_hua_view:IsOpen() then
			self.xian_bao_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_TONG then	-- 灵童
		self.ling_chong_data:SetLingChongInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingchong")
		end
		RemindManager.Instance:Fire(RemindName.LingTong)

		if self.ling_chong_huan_hua_view and self.ling_chong_huan_hua_view:IsOpen() then
			self.ling_chong_huan_hua_view:Flush()
		end

		AdvanceCtrl.Instance:FlushXunZhangView()

	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_GONG then -- 灵弓
		self.ling_gong_data:SetLingGongInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "linggong")
		end
		RemindManager.Instance:Fire(RemindName.LingGong)
		
		if self.ling_gong_huan_hua_view and self.ling_gong_huan_hua_view:IsOpen() then
			self.ling_gong_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_QI then 	-- 灵骑
		self.ling_qi_data:SetLingQiInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingqi")
		end
		RemindManager.Instance:Fire(RemindName.LingQi)
		
		if self.ling_qi_huan_hua_view and self.ling_qi_huan_hua_view:IsOpen() then
			self.ling_qi_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.WEI_YAN then	-- 尾焰
		self.weiyan_data:SetWeiYanInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "weiyan")
		end
		RemindManager.Instance:Fire(RemindName.WeiYan)

		if self.wei_yan_huan_hua_view and self.wei_yan_huan_hua_view:IsOpen() then
			self.wei_yan_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.SHOU_HUAN then -- 手环
		self.shouhuan_data:SetShouHuanInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "shouhuan")
		end
		RemindManager.Instance:Fire(RemindName.ShouHuan)

		if self.shou_huan_huan_hua_view and self.shou_huan_huan_hua_view:IsOpen() then
			self.shou_huan_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.TAIL then		-- 尾巴
		self.tail_data:SetTailInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "tail")
		end
		RemindManager.Instance:Fire(RemindName.Tail)

		if self.tail_huan_hua_view and self.tail_huan_hua_view:IsOpen() then
			self.tail_huan_hua_view:Flush()
		end

	elseif protocol.upgrade_type == UPGRADE_TYPE.FLY_PET then	-- 飞宠
		self.flypet_data:SetFlyPetInfo(protocol.info)
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "flypet")
			
		end
		RemindManager.Instance:Fire(RemindName.FlyPet)

		if self.fly_pet_huan_hua_view and self.fly_pet_huan_hua_view:IsOpen() then
			self.fly_pet_huan_hua_view:Flush()
		end
		AdvanceCtrl.Instance:FlushXunZhangView()
	end
	
	if ViewManager.Instance:IsOpen(ViewName.TipZiZhi) then
		AdvanceCtrl.Instance:FlushZiZhiTips()
	end

	if ViewManager.Instance:IsOpen(ViewName.TipSkillUpgrade) then
		AdvanceCtrl.Instance.tip_skill_upgrade_view:Flush()
	end

	if ViewManager.Instance:IsOpen(ViewName.TipChengZhang) then
		AdvanceCtrl.Instance:FlushChengZhangTips()
	end
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	AppearanceCtrl.Instance:FlushEquipView()
	RemindManager.Instance:Fire(RemindName.AppearanceEquip)
end

function UpgradeCtrl:OnUpgradeAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then return end

	local vo = obj:GetVo()
	if protocol.upgrade_type == UPGRADE_TYPE.LING_ZHU and obj then			-- 灵珠
		vo.appearance.lingzhu_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("lingzhu_used_imageid", protocol.upgrade_appeid)
	elseif protocol.upgrade_type == UPGRADE_TYPE.XIAN_BAO and obj then		-- 仙宝
		-- 仙宝只在ui界面展示
	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_TONG and obj then		-- 灵童
		vo.appearance.lingchong_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("lingchong_used_imageid",  protocol.upgrade_appeid)
	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_GONG and obj then		-- 灵弓
		vo.appearance.linggong_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("linggong_used_imageid",  protocol.upgrade_appeid)
	elseif protocol.upgrade_type == UPGRADE_TYPE.LING_QI and obj then		-- 灵骑
		vo.appearance.lingqi_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("lingqi_used_imageid",  protocol.upgrade_appeid)
	elseif protocol.upgrade_type == UPGRADE_TYPE.WEI_YAN and obj then		-- 尾焰
		vo.appearance.weiyan_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("weiyan_used_imageid", protocol.upgrade_appeid)
	elseif protocol.upgrade_type == UPGRADE_TYPE.SHOU_HUAN and obj then		-- 手环
		vo.appearance.shouhuan_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("appearance", vo.appearance)
	elseif protocol.upgrade_type == UPGRADE_TYPE.TAIL and obj then			-- 尾巴
		vo.appearance.tail_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("appearance", vo.appearance)
	elseif protocol.upgrade_type == UPGRADE_TYPE.FLY_PET and obj then		-- 飞宠
		vo.appearance.flypet_used_imageid = protocol.upgrade_appeid
		obj:SetAttr("appearance", vo.appearance)
	end
end

function UpgradeCtrl:SendUpgradeReq(upgrade_type, opera_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeOperaReq)
	send_protocol.upgrade_type = upgrade_type or 0
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end

function UpgradeCtrl:UpGradeResult(operate, result)
	if operate == MODULE_OPERATE_TYPE.OP_LING_ZHU then 			-- 灵珠
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingzhu_upgrade", {result})
		end

	elseif operate == MODULE_OPERATE_TYPE.OP_XIAN_BAO then 		-- 仙宝
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "xianbao_upgrade", {result})
		end

	elseif operate == MODULE_OPERATE_TYPE.OP_LING_TONG then  	-- 灵童
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingchong_upgrade", {result})
		end
		
	elseif operate == MODULE_OPERATE_TYPE.OP_LING_GONG then		-- 灵弓
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "linggong_upgrade", {result})
		end

	elseif operate == MODULE_OPERATE_TYPE.OP_LING_QI then 		-- 灵骑
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingqi_upgrade", {result})
		end

	elseif operate == MODULE_OPERATE_TYPE.OP_WEI_YAN then 		-- 尾焰
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "weiyan_upgrade", {result})
		end
	elseif operate == MODULE_OPERATE_TYPE.OP_SHOU_HUAN then 	-- 手环
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "shouhuan_upgrade", {result})
		end
	elseif operate == MODULE_OPERATE_TYPE.OP_TAIL then 			-- 尾巴
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "tail_upgrade", {result})
		end
	elseif operate == MODULE_OPERATE_TYPE.OP_FLY_PET then 			-- 飞宠
		if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
			ViewManager.Instance:FlushView(ViewName.AppearanceView, "flypet_upgrade", {result})
		end
	end
end

function UpgradeCtrl:MainuiOpenCreate()
	for i = 0, 8 do
		self:SendUpgradeReq(i, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_INFO)
	end
end