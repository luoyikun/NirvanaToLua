TipsMoLongMiBaoView = TipsMoLongMiBaoView or BaseClass(BaseView)

function TipsMoLongMiBaoView:__init()
	self.ui_config = {{"uis/views/molongmibao_prefab", "MoLongMiBaoTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.chapter_id = 0
end

function TipsMoLongMiBaoView:LoadCallBack()
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnCanel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnOk"].button:AddClickListener(BindTool.Bind(self.ClickOk, self))
end

function TipsMoLongMiBaoView:ReleaseCallBack()

end

function TipsMoLongMiBaoView:OpenCallBack()
	-- local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	-- for i = MolongMibaoData.Chapter, 1, -1 do
	-- 	if i <= cur_chapter + 1 and not MolongMibaoData.Instance:GetMibaoBigChapterHasReward(i - 1) then
	-- 		print_error(cur_chapter)
	-- 		self.chapter_id = i - 1
	-- 	end
	-- end
	
	
	self:Flush()
end

function TipsMoLongMiBaoView:OnFlush()
	local two_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(self.chapter_id, 1)
	local cur_jifen = MolongMibaoData.Instance:GetMibaoBigChapterScore(self.chapter_id) or 0 
	local level_jifen = two_max_score - cur_jifen
	level_jifen = level_jifen >= 0 and level_jifen or 0
	local des = string.format(Language.MoLongMiBao.LingQuDes, level_jifen)
	self.node_list["Text"].text.text = des
end

function TipsMoLongMiBaoView:CloseWindow()
	self:Close()
end

function TipsMoLongMiBaoView:SetChapterId(id)
	self.chapter_id = id
end

function TipsMoLongMiBaoView:ClickOk()
	MolongMibaoCtrl.SendMagicalPreciousChapterRewardReq(self.chapter_id, 0)
	self:Close()
end