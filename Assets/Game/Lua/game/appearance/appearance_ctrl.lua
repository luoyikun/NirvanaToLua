require("game/appearance/appearance_view")
require("game/appearance/appearance_data")
require("game/appearance/appearance_equip_view")

local HAS_TIPS_CLEAR_BLESS_T = {}
AppearanceCtrl = AppearanceCtrl or BaseClass(BaseController)

function AppearanceCtrl:__init()
	if AppearanceCtrl.Instance ~= nil then
		ErrorLog("[AppearanceCtrl] attempt to create singleton twice!")
		return
	end
	AppearanceCtrl.Instance = self
	self.data = AppearanceData.New()
	self.appearance_equip_view = AppearanceEquipView.New(ViewName.AppearacneEquipView)		-- 外观装备
	self:RegisterAllProtocols()
	self.view = AppearanceView.New(ViewName.AppearanceView)
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.TipHiddenAppearance, self))
end

function AppearanceCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.appearance_equip_view then
		self.appearance_equip_view:DeleteMe()
		self.appearance_equip_view = nil
	end

	AppearanceCtrl.Instance = nil
end

-- 协议注册
function AppearanceCtrl:RegisterAllProtocols()

end

function AppearanceCtrl:ClearTipsBlessT()
	HAS_TIPS_CLEAR_BLESS_T = {}
end

function AppearanceCtrl:FlushView(key)
	if self.view:IsOpen() then
		self.view:Flush(key)
	end
end

function AppearanceCtrl:FlushEquipView(...)
	if self.appearance_equip_view:IsOpen() then
		self.appearance_equip_view:Flush(...)
	end
end

--根据不同界面判断是否打开清除祝福值提示
function AppearanceCtrl:OpenClearBlessView(view_index, call_back)
	local clear_bless_tip_view = ViewManager.Instance:GetView(ViewName.ClearBlessTipView)
	if nil == clear_bless_tip_view then
		return
	end

	local data = {}
	local info = {}
	local grade_cfg = nil
	local grade = 0
	if view_index == TabIndex.appearance_waist then
		info = WaistData.Instance:GetYaoShiInfo()
		_, grade = WaistData.Instance:GetClearBlessGradeLimit()
		grade_cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_toushi then
		info = TouShiData.Instance:GetTouShiInfo()
		_, grade = TouShiData.Instance:GetClearBlessGradeLimit()
		grade_cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_qilinbi then
		info = QilinBiData.Instance:GetQilinBiInfo()
		_, grade = QilinBiData.Instance:GetClearBlessGradeLimit()
		grade_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_mask then
		info = MaskData.Instance:GetMaskInfo()
		_, grade = MaskData.Instance:GetClearBlessGradeLimit()
		grade_cfg = MaskData.Instance:GetMaskGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_lingzhu then
		info = LingZhuData.Instance:GetLingZhuInfo()
		_, grade = LingZhuData.Instance:GetClearBlessGradeLimit()
		grade_cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_xianbao then
		info = XianBaoData.Instance:GetXianBaoInfo()
		_, grade = XianBaoData.Instance:GetClearBlessGradeLimit()
		grade_cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade()
		
	elseif view_index == TabIndex.appearance_lingtong then
		info = LingChongData.Instance:GetLingChongInfo()
		_, grade = LingChongData.Instance:GetClearBlessGradeLimit()
		grade_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_linggong then
		info = LingGongData.Instance:GetLingGongInfo()
		_, grade = LingGongData.Instance:GetClearBlessGradeLimit()
		grade_cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_lingqi then
		info = LingQiData.Instance:GetLingQiInfo()
		_, grade = LingQiData.Instance:GetClearBlessGradeLimit()
		grade_cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_weiyan then
		info = WeiYanData.Instance:GetWeiYanInfo()
		_, grade = WeiYanData.Instance:GetClearBlessGradeLimit()
		grade_cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_shouhuan then
		info = ShouHuanData.Instance:GetShouHuanInfo()
		_, grade = ShouHuanData.Instance:GetClearBlessGradeLimit()
		grade_cfg = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_tail then
		info = TailData.Instance:GetTailInfo()
		_, grade = TailData.Instance:GetClearBlessGradeLimit()
		grade_cfg = TailData.Instance:GetTailGradeCfgInfoByGrade()

	elseif view_index == TabIndex.appearance_flypet then
		info = FlyPetData.Instance:GetFlyPetInfo()
		_, grade = FlyPetData.Instance:GetClearBlessGradeLimit()
		grade_cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade()
	end

	if not HAS_TIPS_CLEAR_BLESS_T[view_index] and
		grade_cfg and grade_cfg.is_clear_bless == 1 and info and info.grade_bless_val and info.grade_bless_val > 0 then
		data.view_name = ViewName.AppearanceView
		data.view_index = view_index
		data.call_back = call_back
		data.max_val = grade_cfg.bless_val_limit
		data.cur_val = info.grade_bless_val
		data.grade_name = grade
		clear_bless_tip_view:SetData(data)
		HAS_TIPS_CLEAR_BLESS_T[view_index] = true
	else
		if call_back then
			call_back()
		else
			ViewManager.Instance:Close(ViewName.AppearanceView)
		end
	end
end

function AppearanceCtrl:IsHiddenAppearance()	
	if WingData.Instance:IsHidden() then
		return true
	elseif FaBaoData.Instance:IsHidden() then
		return true
	elseif FootData.Instance:IsHidden() then
		return true
	elseif FootData.Instance:IsHidden() then
		return true
	elseif HaloData.Instance:IsHidden() then
		return true
	elseif CloakData.Instance:IsHidden() then
		return true
	elseif TouShiData.Instance:IsHidden() then
		return true
	elseif MaskData.Instance:IsHidden() then
		return true
	elseif WaistData.Instance:IsHidden() then
		return true
	elseif QilinBiData.Instance:IsHidden() then
		return true
	elseif ShouHuanData.Instance:IsHidden() then
		return true
	elseif TailData.Instance:IsHidden() then
		return true
	elseif FlyPetData.Instance:IsHidden() then
		return true
	end

	return false
end

function AppearanceCtrl:TipHiddenAppearance()
	local is_hidden = self:IsHiddenAppearance()
	if is_hidden then
		local str = Language.Common.HiddenAppearance
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end