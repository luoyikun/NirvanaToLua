SuitCollecIconView = SuitCollecIconView or BaseClass(BaseRender)
function SuitCollecIconView:__init()
	
end

function SuitCollecIconView:__delete()

end

function SuitCollecIconView:LoadCallBack()
	self.node_list["SuitViewIcon"].button:AddClickListener(BindTool.Bind(self.OpenSuitCollectView, self))
end


function SuitCollecIconView:OpenSuitCollectView()
	-- ViewManager.Instance:Open(ViewName.SuitCollection, TabIndex.orange_suit_collect)
	ViewManager.Instance:Open(ViewName.SuitCollection)
end

function SuitCollecIconView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			UITween.MoveShowPanel(self.node_list["SuitViewIcon"], Vector3(-412, 80, 0), 0.5, DG.Tweening.Ease.InOutSine)
		elseif k == "remind" then
			if not OpenFunData.Instance:CheckIsHide("suitcollect") then
				self.node_list["SuitViewIcon"]:SetActive(false)
				return
			else
				self.node_list["SuitViewIcon"]:SetActive(true)
			end

			if 1 == SuitCollectionData.Instance:GetOrangeSuitCollectionRemind() or 1 == SuitCollectionData.Instance:GetRedSuitCollectionRemind() then
				self.node_list["IconRemind"]:SetActive(true)
			else
				self.node_list["IconRemind"]:SetActive(false)
			end
		end
	end
end


