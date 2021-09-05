require("game/four_grade_equip/four_grade_equip_data")
require("game/four_grade_equip/four_grade_equip_view")

FourGradeEquipCtrl = FourGradeEquipCtrl or BaseClass(BaseController)

function FourGradeEquipCtrl:__init()
	if FourGradeEquipCtrl.Instance then
		print_error("[FourGradeEquipCtrl]:Attempt to create singleton twice!")
	end
	FourGradeEquipCtrl.Instance = self

	self.view = FourGradeEquipView.New(ViewName.FourGradeEquip)
	self.data = FourGradeEquipData.New()

	self:RegisterAllProtocols()
end

function FourGradeEquipCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	FourGradeEquipCtrl.Instance = nil
end

function FourGradeEquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCZeroGiftGodCostumeInfo, "OnSCZeroGiftGodCostumeInfo")
end

function FourGradeEquipCtrl:OnSCZeroGiftGodCostumeInfo(protocol)
	self.data:SetFourGradeEquipInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.FourGradeEquip)
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "four_grade_equip")
end
