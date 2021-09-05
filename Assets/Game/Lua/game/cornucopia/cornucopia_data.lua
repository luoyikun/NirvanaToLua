CornucopiaData = CornucopiaData or BaseClass()

function CornucopiaData:__init()
	if CornucopiaData.Instance then
		print_error("[CornucopiaData] Attemp to create a singleton twice !")
	end
	CornucopiaData.Instance = self
end

function CornucopiaData:__delete()
	CornucopiaData.Instance = nil
end
