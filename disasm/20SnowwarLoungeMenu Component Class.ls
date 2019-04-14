property pFrameworkId, pUserTeamIndex

on construct me
pFrameworkId = getVariable("snowwar.loungesystem.id")
pUserTeamIndex = 0
tSetName = "human.partset.head.sh"
tPartList = []
if variableExists(tSetName) then
tPartList = getVariable(tSetName)
if ilk(tPartList) <> #list then tPartList = []
else tPartList = tPartList.duplicate()

end if
tPartList.add("bd")
tPartList.add("sh")
setVariable("snowwar.human.parts.sh", tPartList)
return TRUE

end

on deconstruct me
return TRUE

end

on getGameSystem me
return GetObject(pFrameworkId)

end

on getUserName me
return GetObject(#session).GET(#userName)

end

on isUserHost me
if me.getGameSystem() = FALSE then return FALSE

tdata = me.getGameSystem().getObservedInstance()
if tdata = FALSE then return FALSE

tHostName = tdata[#host][#name]
return(tHostName = me.getUserName())

end

on gameCanStart me
tdata = me.getGameSystem().getObservedInstance()
if tdata = FALSE then return FALSE

tGameCanStart = tdata[#teams].count = 1 and tdata[#teams][1][#players].count > 1
if tGameCanStart then return TRUE

tOneTeamOK = FALSE
repeat with tTeam in tdata[#teams]
if tTeam[#players].count > 0 then
if tOneTeamOK = TRUE then return TRUE

tOneTeamOK = TRUE

end if
end repeat
return FALSE

end

on observeInstance me, tIndexOnList
if me.getGameSystem() = FALSE then return FALSE

tList = me.getGameSystem().getInstanceList()
if tList = FALSE then return FALSE
if tIndexOnList > tList.count then return FALSE
if not listp(tList[tIndexOnList]) then return FALSE

tGameId = tList[tIndexOnList][#id]
if me.getGameSystem() = FALSE then return FALSE

return me.getGameSystem().observeInstance(tGameId)

end

on joinGame me, tTeamIndex
if me.getGameSystem() = FALSE then return FALSE

tParamList = me.getGameSystem().getJoinParameters()
if tTeamIndex = 0 then tTeamIndex = pUserTeamIndex

if tTeamIndex = 0 then tTeamIndex = me.getUserTeamIndex()

tInstance = me.getGameSystem().getObservedInstance()
tInstanceId = tInstance[#id]
if not listp(tParamList) then
return me.getGameSystem().initiateJoinGame(tInstanceId, tTeamIndex)

end if
return me.getGameSystem().joinGame(void(), tInstanceId, tTeamIndex, tParamList)

end

on checkUserWasKicked me
if pUserTeamIndex <> 0 then
if me.getUserTeamIndex() = FALSE then return TRUE

end if
return FALSE

end

on saveUserTeamIndex me
pUserTeamIndex = me.getUserTeamIndex()
return TRUE

end

on resetUserTeamIndex me
pUserTeamIndex = 0
return TRUE

end

on getUserTeamIndex me
return me.getPlayerTeamIndex([#name: me.getUserName()])

end

on getPlayerTeamIndex me, tSearchData
if me.getGameSystem() = FALSE then return FALSE

tdata = me.getGameSystem().getObservedInstance()
if tdata[#teams] = void() then return FALSE

repeat with tTeamNum = 1 to tdata[#teams].count -- jump 170 -- backjump 182 landing
tTeam = tdata[#teams][tTeamNum][#players]
if not listp(tTeam) then tTeam = []

repeat with tPlayer in tTeam
if tPlayer[#name] = tSearchData[#name] and tSearchData[#name] <> void() then
return tTeamNum

end if
if tPlayer[#id] = tSearchData[#id] and tSearchData[#id] <> void() then
return tTeamNum

end if
end repeat
end repeat
return FALSE

end
