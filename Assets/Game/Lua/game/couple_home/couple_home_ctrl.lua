require("game/couple_home/couple_home_view")
require("game/couple_home/couple_home_preview_view")
-- require("game/couple_home/couple_home_theme_buy_view")
require("game/couple_home/couple_home_packet_view")
require("game/couple_home/couple_home_total_attr_view")
require("game/couple_home/couple_home_data")

CoupleHomeCtrl = CoupleHomeCtrl or BaseClass(BaseController)

function CoupleHomeCtrl:__init()
	if CoupleHomeCtrl.Instance ~= nil then
		print_error("[CoupleHomeCtrl] attempt to create singleton twice!")
		return
	end

	CoupleHomeCtrl.Instance = self

	self.view = CoupleHomeView.New(ViewName.CoupleHomeView)
	self.pre_view = CoupleHomePreView.New(ViewName.CoupleHomePreView)
	-- self.theme_buy_view = CoupleHomeThemeBuyView.New(ViewName.CoupleHomeThemeBuyView)
	self.packet_view = CoupleHomePacketView.New(ViewName.CoupleHomePacketView)
	self.total_attr_view = CoupleHomeTotalAttrView.New(ViewName.CoupleHomeTotalAttrView)

	self.data = CoupleHomeData.New()
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
end

function CoupleHomeCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.pre_view ~= nil then
		self.pre_view:DeleteMe()
		self.pre_view = nil
	end

	if self.packet_view ~= nil then
		self.packet_view:DeleteMe()
		self.packet_view = nil
	end

	if self.total_attr_view ~= nil then
		self.total_attr_view:DeleteMe()
		self.total_attr_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	CoupleHomeCtrl.Instance = nil
end

--打开预览界面
function CoupleHomeCtrl:ShowPreView(theme_type)
	self.pre_view:SetThemeType(theme_type)
	self.pre_view:Open()
end

--打开储物箱界面
function CoupleHomeCtrl:ShowPacketView(select_house_index, furniture_index, callback)
	self.packet_view:SetSelectHouseClientIndex(select_house_index)
	self.packet_view:SetFurnitureIndex(furniture_index)
	self.packet_view:SetCallBack(callback)
	self.packet_view:Open()
end

--打开总属性面板
function CoupleHomeCtrl:ShowTotalAttrView(select_house_index)
	self.total_attr_view:SetSelectHouseClientIndex(select_house_index)
	self.total_attr_view:Open()
end

function CoupleHomeCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME or 
		activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE then
		if self.view:IsOpen() then
			self.view:FlushIcon()
		end
		RemindManager.Instance:Fire(RemindName.FiftyPercent)
		RemindManager.Instance:Fire(RemindName.BuyOneGetOne)
	end
end