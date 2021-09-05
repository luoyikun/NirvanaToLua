
TipsBarView = TipsBarView or BaseClass(BaseView)

function TipsBarView:__init()
	self.ui_config = {{"uis/views/tips/bartips_prefab", "BarTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.time = 1
	self.types = 1
	self.callback = nil
end

function TipsBarView:__delete()
end

function TipsBarView:ReleaseCallBack()
	self.gather_bar = nil
	self.callback = nil
end

function TipsBarView:LoadCallBack()
	self.gather_bar = self.node_list["GatherBar"].slider
end

function TipsBarView:OpenCallBack()
	TaskCtrl.Instance:SetAutoTalkState(false)
end

function TipsBarView:SetData(time, types, callback)
	self.time = time or 1
	self.types = types or 1
	self.callback = callback
	self:Flush()
end

function TipsBarView:OnFlush()
	self:OnSetGatherTime()
end

function TipsBarView:OnSetGatherTime()
	self.node_list["Text"].text.text = Language.Tips.BarTipsType[self.types]
	self.gather_bar.value = 0
	local tweener = self.gather_bar:DOValue(1, self.time, false)
	tweener:SetEase(DG.Tweening.Ease.Linear)
	tweener:OnComplete(function ()
		self:Close()
		self.callback()
		TaskCtrl.Instance:SetAutoTalkState(true)
	end)
	self.node_list["Object"].transform.rotation = Vector3(0, 0, 0)
	local tween1 = self.node_list["Object"].transform:DORotate(Vector3(0, 0, -360),
		self.time,
		DG.Tweening.RotateMode.FastBeyond360)
	tween1:SetEase(DG.Tweening.Ease.Linear)
end