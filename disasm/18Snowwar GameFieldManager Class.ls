property pRoomGeometry, pMouseClickTimeon construct meme.registerEventProc(TRUE)return TRUEendon deconstruct meme.registerEventProc(FALSE)if managerExists(#sound_manager) then stopAllSounds()return TRUEendon Refresh me, tTopic, tdatacase tTopic of#objects_ready: me.processRoomReady()#snowwar_event_11: me.getGameSystem().executeGameObjectEvent(string(tdata[#int_machine_id]), #add_snowball)#snowwar_event_12: return me.moveBallsToUser(string(tdata[#int_machine_id]), string(tdata[#int_player_id]))otherwise: return error(me, "Undefined event!" && tTopic && "for" && me.pID, #Refresh)end casereturn TRUEendon processRoomReady metList = GetObject(#room_component).pPassiveObjListtTargetID = getThread(#room).getInterface().getID()tVisObj = GetObject("Room_visualizer")tBaseLocZ = tVisObj.getProperty(#locZ)tBaseLocZ = tVisObj.getSprById("floor").locZtHiliterLocZ = tVisObj.getSprById("hiliter").locZrepeat with tObject in tListtSprites = tObject.getSprites()if tSprites.count > 0 thentSpr = tSprites[1]tSpr.removeProcedure(#eventProcPassiveObj, tTargetID)tSpr.registerProcedure(#eventProcRoom, me.getID(), #mouseDown)tSpr.registerProcedure(#eventProcRoom, me.getID(), #mouseUp)if tSpr.member.name contains "sw_backround" thentSpr.locZ = (tBaseLocZ + 1)if tSpr.locZ >= tHiliterLocZ thentVisObj.getSprById("hiliter").locZ = (tHiliterLocZ + 1)end ifend ifend ifend repeatendon registerEventProc me, tBooleantRoomThread = getThread(#room)if tRoomThread = FALSE then return FALSEtRoomInt = tRoomThread.getInterface()if tRoomInt = FALSE then return FALSEpRoomGeometry = tRoomInt.getGeometry()if pRoomGeometry = FALSE then return FALSEtVisObj = tRoomInt.getRoomVisualizer()if tVisObj = FALSE then return FALSEtSprList = tVisObj.getProperty(#spriteList)if tBoolean thencall(#removeProcedure, tSprList, #mouseDown)call(#removeProcedure, tSprList, #mouseUp)call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)elseif listp(tSprList) thencall(#removeProcedure, tSprList, #mouseDown)call(#removeProcedure, tSprList, #mouseUp)end ifend ifendon eventProcRoom me, tEvent, tSprID, tParamtloc = pRoomGeometry.getWorldCoordinate(the mouseH, the mouseV)if not listp(tloc) then return TRUEtRoomInt = GetObject(#room_interface)if tRoomInt = FALSE then return FALSEif tRoomInt.getComponent().getSpectatorMode() then return TRUEif tEvent = #mouseUp thentMouseDownTime = (the milliSeconds - pMouseClickTime) / 1000if the optionDown thenpMouseClickTime = -1return me.sendThrowBall(tloc, 2)end ifif the shiftDown thenif tMouseDownTime >= 1 then return me.sendThrowBall(tloc, 2)else return me.sendThrowBall(tloc, 1)end ifpMouseClickTime = -1return TRUEend ifif tEvent = #mouseDown thenif the shiftDown then pMouseClickTime = the milliSecondselse if not the optionDown then return(me.sendMoveGoal(tloc))return TRUEend ifendon sendThrowBall me, tloc, tTrajectorytFramework = me.getGameSystem()if tFramework = FALSE then return FALSEtGameState = tFramework.getGamestatus()if tGameState = #game_started thentWorldLoc = tFramework.convertTileToWorldCoordinate(tloc[1], tloc[2])if not GetObject(#session).exists("user_game_index") then return FALSEtMyId = GetObject(#session).GET("user_game_index")tFramework.executeGameObjectEvent(tMyId, #send_throw_at_loc, [#targetloc: tWorldLoc, #trajectory: tTrajectory])return TRUEend ifendon sendMoveGoal me, tloctFramework = me.getGameSystem()if tFramework = FALSE then return FALSEtGameState = tFramework.getGamestatus()if tGameState = #game_started thenif not GetObject(#session).exists("user_game_index") then return FALSEtMyId = GetObject(#session).GET("user_game_index")return(tFramework.executeGameObjectEvent(tMyId, #send_set_target_tile, [#tile_x: tloc[1], #tile_y: tloc[2]]))elsereturn tFramework.sendHabboRoomMove(tloc[1], tloc[2])end ifendon moveBallsToUser me, tMachineID, tUserIDtMachineObject = me.getGameSystem().getGameObject(tMachineID)if tMachineObject = FALSE then return FALSEtMachineBallCount = tMachineObject.getGameObjectProperty(#snowball_count)tUserObject = me.getGameSystem().getGameObject(tUserID)if tUserObject = FALSE then return FALSEtUserBallCount = tUserObject.getGameObjectProperty(#snowball_count)tMaxBallCount = getIntVariable("snowwar.snowball.maximum")if tMachineBallCount > 0 and tUserBallCount < tMaxBallCount thenme.getGameSystem().executeGameObjectEvent(tUserID, #set_ball_count, [#value: (tUserBallCount + 1)])me.getGameSystem().executeGameObjectEvent(tMachineID, #remove_snowball)end ifreturn TRUEend