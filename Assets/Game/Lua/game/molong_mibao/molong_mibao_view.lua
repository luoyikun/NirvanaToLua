require("game/molong_mibao/molong_mibao_chapter_view")
MolongMibaoView = MolongMibaoView or BaseClass(BaseView)

function MolongMibaoView:__init()
	self.def_index = 1
	self.ui_config = {
		{"uis/views/molongmibao_prefab", "MolongMibao"},
	}
	self.play_audio = true
	self.is_modal = true
	self.full_screen = false
end

function MolongMibaoView:__delete()

end

function MolongMibaoView:Open()
	if OpenFunData.Instance:CheckIsHide("molongmibaoview") then
		if MolongMibaoData.Instance:IsOpenMoLongMiBao() then
			BaseView.Open(self)
			return
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.MoLongMiBao.NotActive)
end

function MolongMibaoView:LoadCallBack()
	--self.node_list["Name"].text.text = Language.Title.SongShiZhuang
	MolongMibaoData.Instance:SetIsShow(true)
	self.chapter_view = MolongMibaoChapterView.New(self.node_list["ChapterView"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function MolongMibaoView:ReleaseCallBack()
	if self.chapter_view then
		self.chapter_view:DeleteMe()
		self.chapter_view = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function MolongMibaoView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.MoLongMiBao)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("molongmibao_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	end
	self.chapter_view:OpenCallBack()
	MolongMibaoCtrl.SendMagicalPreciousInfoReq()
	self:Flush()
end

function MolongMibaoView:ShowIndexCallBack(index)

end

function MolongMibaoView:CloseCallBack()
	self.chapter_view:CloseFire()
end

function MolongMibaoView:OnFlush(param_t)
	self.chapter_view:Flush()
end