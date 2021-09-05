require("game/yunbiao/yunbiao_view_main")

YunbiaoView = YunbiaoView or BaseClass(BaseView)

function YunbiaoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/escortview_prefab", "EscortView"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.close_deal_callback = nil
	self.guide_husong_color = 0
	self.close_time_stamp = 0
end

function YunbiaoView:__delete()
	self.close_deal_callback = nil
end

function YunbiaoView:ReleaseCallBack()
	self.main_view:DeleteMe()
	self.main_view = nil
end

function YunbiaoView:SetHusongGuideEntrance(close_deal_callback, guide_husong_color)
	self.close_deal_callback = close_deal_callback
	self.guide_husong_color = guide_husong_color
end

function YunbiaoView:LoadCallBack()
	self.main_view = YunbiaoViewMain.New(self.node_list["MainPanel"])
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TitleText"].text.text = Language.YunBiao.Title
end

function YunbiaoView:OpenCallBack()
	AssetBundleMgr:ReqHighLoad()
	self:Flush()
	self.main_view:SetGuideHusongColor(self.guide_husong_color)
end

function YunbiaoView:CloseCallBack()
	AssetBundleMgr:ReqLowLoad()
	if nil ~= self.close_deal_callback then
		self.close_deal_callback()
		self.close_deal_callback = nil
	end
	self.guide_husong_color = 0

	self.close_time_stamp = Status.NowTime
end

function YunbiaoView:OnFlush()
	self.main_view:Flush()
end

function YunbiaoView:GetCloseTimeStamp()
	return self.close_time_stamp
end