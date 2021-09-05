VersionsActivityData = VersionsActivityData or BaseClass()

function VersionsActivityData:__init()
	if VersionsActivityData.Instance ~= nil then
		print_error("[VersionsActivityData] Attemp to create a singleton twice !")
		return
	end
	VersionsActivityData.Instance = self
end

function VersionsActivityData:__delete()

	VersionsActivityData.Instance = nil
end
