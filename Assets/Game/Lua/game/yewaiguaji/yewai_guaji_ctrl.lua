require("game/yewaiguaji/yewai_guaji_view")
require("game/yewaiguaji/yewai_guaji_data")
require("game/guaji/guaji_ctrl")
require("game/guaji/guaji_data")
require("game/yewaiguaji/guaji_map_tips")
YewaiGuajiCtrl = YewaiGuajiCtrl or BaseClass(BaseController)

function YewaiGuajiCtrl:__init()
	if nil ~= YewaiGuajiCtrl.Instance then
		print_error("[YewaiGuajiCtrl] Attemp to create a singleton twice !")
		return
	end
	YewaiGuajiCtrl.Instance = self
	
	self.yewai_guaji_ctrl_view = YewaiGuajiView.New(ViewName.YewaiGuajiView)
	self.yewai_guaji_ctrl_data = YewaiGuajiData.New()
	self.guajimap_tips = GuajiMapTips.New(ViewName.GuajiMapTips)
end

function YewaiGuajiCtrl:__delete()
	if self.yewai_guaji_ctrl_view ~= nil then
		self.yewai_guaji_ctrl_view:DeleteMe()
		self.yewai_guaji_ctrl_view = nil
	end
	if self.yewai_guaji_ctrl_data ~= nil then
		self.yewai_guaji_ctrl_data:DeleteMe()
		self.yewai_guaji_ctrl_data = nil
	end
	if self.guajimap_tips ~= nil then
		self.guajimap_tips:DeleteMe()
		self.guajimap_tips = nil
	end
	YewaiGuajiCtrl.Instance = nil
end

function YewaiGuajiCtrl:GoGuaji(scene_id, x, y)
	GuajiCtrl.Instance:StopGuaji()
	MoveCache.end_type = MoveEndType.Auto
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	self.yewai_guaji_ctrl_view:CloseView()

end