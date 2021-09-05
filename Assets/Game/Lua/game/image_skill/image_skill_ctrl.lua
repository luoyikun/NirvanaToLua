require("game/image_skill/image_skill_data")
require("game/image_skill/image_skill_view")
ImageSkillCtrl = ImageSkillCtrl or BaseClass(BaseController)
function ImageSkillCtrl:__init()
	if ImageSkillCtrl.Instance then
		print_error("[ImageSkillCtrl] Attemp to create a singleton twice !")
	end
	ImageSkillCtrl.Instance = self
	self.data = ImageSkillData.New()
	self.view = ImageSkillView.New(ViewName.ImageSkillView)
	self:RegisterProtocol(SCBaiBeiFanLi2Info, "OnSCBaiBeiFanLiInfo")

	self.is_buy = true
end

function ImageSkillCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	ImageSkillCtrl.Instance = nil
end

function ImageSkillCtrl:OnSCBaiBeiFanLiInfo(protocol)
	self:SetBuyMark(protocol.is_buy)
	self.data:SetActivityTime(protocol)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_IMAGESKILL_BUTTON, self.is_buy)
	RemindManager.Instance:Fire(RemindName.ImageSkill)	
end

function ImageSkillCtrl:SetBuyMark(is_buy)
	if is_buy ~= nil and is_buy == 0 then
		self.is_buy = true
	else
		self.is_buy = false
		if self.view:IsOpen() then
			self.view:Close()
		end
	end
end

function ImageSkillCtrl:GetBuyState()
	return self.is_buy
end


function ImageSkillCtrl:SendBaiBeiFanLiBuy()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBaiBeiFanLi2Buy)
	protocol:EncodeAndSend()
end