require("game/helper/helper_data")
HelperCtrl = HelperCtrl or BaseClass(BaseController)

function HelperCtrl:__init()
	if HelperCtrl.Instance then
		print_error("[HelperCtrl] Attemp to create a singleton twice !")
	end
	HelperCtrl.Instance = self
	self.data = HelperData.New()
end

function HelperCtrl:__delete()
	self.data:DeleteMe()
	HelperCtrl.Instance = nil
end

function HelperCtrl:GetData()
	return self.data
end