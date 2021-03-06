property pReady, pHiliteSpriteNum, pFramework, pAvatarAction, pInvincible, pInvincibleCounter, pTeamId, pAvatarId, pDump, pActionPartList

on construct(me)
  pActionPartList = ["bd", "sh"]
  pReady = 0
  pDump = 0
  pAvatarAction = [:]
  pAvatarAction.setAt(#tag, "")
  if not objectp(me.ancestor) then
    return(0)
  end if
  return(me.ancestor.construct())
  exit
end

on deconstruct(me)
  pReady = 0
  if pHiliteSpriteNum > 0 then
    releaseSprite(pHiliteSpriteNum)
  end if
  if not objectp(me.ancestor) then
    return(1)
  end if
  return(me.ancestor.deconstruct())
  exit
end

on define(me, tdata)
  me.pPartClass = getVariableValue("snowwar.bodypart.class")
  pTeamId = string(tdata.getAt(#team_id))
  pAvatarId = string(tdata.getAt(#human_id))
  callAncestor(#define, me, tdata)
  if tdata[#activity_state] = 1 then
    me.gameObjectAction("start_create")
  else
    if tdata[#activity_state] = 2 then
      tParams = [:]
      tParams.addProp(#hit_direction, tdata.getAt(#body_direction))
      me.gameObjectAction("start_stunned", tParams)
      me.gameObjectAction("next_stunned")
    else
      if tdata[#activity_state] = 3 then
        me.gameObjectAction("start_invincible")
      end if
    end if
  end if
  pReady = 1
  me.setOwnHiliter(1)
  return(1)
  exit
end

on select(me)
  if pFramework = void() then
    pFramework = getObject(#snowwar_gamesystem)
  end if
  if pFramework.getGamestatus() <> #game_started then
    return(0)
  end if
  if pFramework.getSpectatorModeFlag() then
    return(0)
  end if
  if not getObject(#session).exists("user_game_index") then
    return(0)
  end if
  tUserIndex = getObject(#session).GET("user_game_index")
  if tUserIndex = 0 then
    return(error(me, "Own player missing the game object index!", #select))
  end if
  tIsOwnAvatar = pAvatarId = tUserIndex
  if tIsOwnAvatar then
    pFramework.executeGameObjectEvent(pAvatarId, #send_create_snowball)
  else
    if the shiftDown or the optionDown then
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id:pAvatarId, #trajectory:2])
    else
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id:pAvatarId, #trajectory:0])
    end if
  end if
  return(0)
  exit
end

on setAvatarEventListener(me, tTargetID)
  tsprite = me.pMatteSpr
  if not ilk(tsprite) = #sprite then
    return(0)
  end if
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseEnter)
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseLeave)
  return(1)
  exit
end

on gameObjectRefreshLocation(me, tX, tY, tH, tDirHead, tDirBody)
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  return(1)
  exit
end

on gameObjectNewMoveTarget(me, tX, tY, tH, tDirHead, tDirBody, tAction)
  me.pMoveTime = 300
  tX = integer(tX)
  tY = integer(tY)
  tH = integer(tH)
  me.resetValues(me.pLocX, me.pLocY, me.pLocH, tDirHead, tDirBody)
  me.setProp(#pAvatarAction, #tag, "")
  me.pMainAction = "wlk"
  me.pMoving = 1
  if me.pGeometry = 0 then
    return(0)
  end if
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.pMoveStart = the milliSeconds
  call(#defineAct, me.getDefinedPartList(pActionPartList), "wlk")
  me.Refresh(me.pLocX, me.pLocY, me.pLocH)
  return(1)
  exit
end

on gameObjectMoveDone(me, tX, tY, tH, tDirHead, tDirBody, tAction)
  me.pAnimCounter = 0
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  call(#reset, me.pPartList)
  me.setHumanSpriteLoc()
  me.setOwnHiliter(1)
  return(1)
  exit
end

on gameObjectAction(me, tAction, tdata)
  if tAction = "start_throw" then
    me.resetValues(me.pLocX, me.pLocY, me.pLocH, tdata, tdata)
    me.Refresh(me.pLocX, me.pLocY, me.pLocH)
    call(#defineAct, me.getDefinedPartList(pActionPartList), "tr1")
    me.pChanges = 1
    pAvatarAction.setAt(#tag, "throw")
    return(me.delay(100, #gameObjectAction, "next_throw"))
  else
    if tAction = "next_throw" then
      if pAvatarAction.getAt(#tag) <> "throw" then
        return(1)
      end if
      pAvatarAction.setAt(#tag, "")
      call(#reset, me.pPartList)
      me.pChanges = 1
      call(#defineAct, me.getDefinedPartList(pActionPartList), "tr2")
      if pDump then
        put("next_throw calling timer_reset_figure")
      end if
      return(me.delay(300, #gameObjectAction, "timer_reset_figure"))
    else
      if tAction = "timer_reset_figure" then
        if pAvatarAction.getAt(#tag) <> "" then
          return(1)
        end if
        me.gameObjectAction("reset_figure", tdata)
      else
        if tAction = "reset_figure" then
          me.pInvincible = 0
          me.pMainAction = "std"
          if pAvatarAction.findPos(#originaldirection) > 0 then
            me.pDirection = pAvatarAction.getAt(#originaldirection)
          end if
          pAvatarAction.setAt(#tag, "")
          if ilk(me.pSprite) = #sprite then
            me.pSprite.blend = 100
          end if
          me.resetValues(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
          me.arrangeParts()
          call(#reset, me.pPartList)
          me.pChanges = 1
        else
          if tAction = "start_create" then
            pAvatarAction.setAt(#tag, "")
            tDirection = me.pDirection - me.pDirection mod 2
            call(#defineDir, me.pPartList, tDirection)
            me.pMainAction = "pck"
            call(#defineAct, me.getDefinedPartList(pActionPartList), "pck")
            me.pChanges = 1
            me.arrangeParts()
            me.render()
          else
            if tAction = "start_stunned" then
              me.gameObjectMoveDone(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
              tBallDirection = tdata.getAt(#hit_direction) - tdata.getAt(#hit_direction) mod 2
              tMyDirection = me.pDirection - me.pDirection mod 2
              if tBallDirection <> tMyDirection and tBallDirection mod 4 = tMyDirection mod 4 then
                tDeathDirection = tMyDirection
                tFaceUp = 1
              else
                tDeathDirection = tBallDirection
                tFaceUp = 0
              end if
              pAvatarAction.setAt(#direction, tDeathDirection)
              pAvatarAction.setAt(#originaldirection, me.pDirection)
              pAvatarAction.setAt(#frame, 1)
              pAvatarAction.setAt(#tag, "dead")
              if tFaceUp then
                pAvatarAction.setAt(#facedown, 0)
                pAvatarAction.setAt(#member, "fb")
              else
                pAvatarAction.setAt(#facedown, 1)
                pAvatarAction.setAt(#member, "ff")
              end if
              me.pDirection = tDeathDirection
              call(#defineDir, me.pPartList, me.pDirection)
              call(#defineAct, me.getDefinedPartList(pActionPartList), pAvatarAction.getAt(#member) & "1")
              me.pMainAction = "std"
              me.arrangeParts()
              me.render()
              return(me.delay(80, #gameObjectAction, "next_stunned"))
            else
              if tAction = "next_stunned" then
                if pAvatarAction.getAt(#tag) <> "dead" then
                  return(me.gameObjectAction("reset_figure"))
                end if
                repeat with i = 1 to count(me.pPartList)
                  tPart = getAt(me.pPartList, i)
                  tPart.pAction = "foo"
                end repeat
                pAvatarAction.setAt(#frame, 2)
                call(#defineDirMultiple, me.pPartList, pAvatarAction.getAt(#direction), pActionPartList)
                call(#defineAct, me.getDefinedPartList(pActionPartList), pAvatarAction.getAt(#member) & "2")
                me.pChanges = 1
                me.arrangeParts()
                me.render()
              else
                if tAction = "start_invincible" then
                  pAvatarAction.setAt(#tag, "")
                  me.gameObjectAction("reset_figure")
                  me.pInvincible = 1
                  me.pInvincibleCounter = 0
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on prepare(me)
  if me.pInvincible then
    me.pInvincibleCounter = me.pInvincibleCounter + 1
    if me.pInvincibleCounter > 2 then
      me.setBlendInvincible()
      me.pInvincibleCounter = 0
    end if
  end if
  me.pAnimCounter = me.pAnimCounter + 1 mod 4
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime
    if tFactor > 0 then
      tFactor = 0
    end if
    me.pScreenLoc = me.pDestLScreen - me.pStartLScreen * tFactor + me.pStartLScreen
    me.pChanges = 1
  end if
  exit
end

on update(me)
  if pAvatarAction.getAt(#tag) = "dead" then
    return(1)
  end if
  me.pSync = not me.pSync
  if me.pSync then
    me.prepare()
  else
    me.render()
  end if
  exit
end

on render(me)
  if not me.pChanges then
    return(0)
  end if
  if not pReady then
    return(0)
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    tSize = me.getProp(#pCanvasSize, #std)
    me.pShadowSpr.castNum = getmemnum(me.pPeopleSize & "_sit_sd_001_" & me.getProp(#pFlipList, me.pDirection + 1) & "_0")
  else
    if me.pMainAction = "lay" then
      tSize = me.getProp(#pCanvasSize, #lay)
      me.pShadowSpr.castNum = 0
      me.pShadowFix = 0
    else
      tSize = me.getProp(#pCanvasSize, #std)
      if pAvatarAction.getAt(#tag) = "dead" then
        me.pShadowSpr.castNum = 0
        tSize = [62, 40, 32, 0]
        me.pMember.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
      else
        if me.pShadowSpr.member <> me.pDefShadowMem then
          me.pShadowSpr.member = me.pDefShadowMem
        end if
      end if
    end if
  end if
  if me.pBuffer.width <> tSize[1] or me.pBuffer.height <> tSize.getAt(2) then
    me.pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.pMember.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    me.pSprite.width = tSize.getAt(1)
    me.pSprite.height = tSize.getAt(2)
    me.pMatteSpr.width = tSize.getAt(1)
    me.pMatteSpr.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    repeat with i = 1 to count(me.pPartList)
      tPart = getAt(me.pPartList, i)
      tPart.resetMemberCache()
    end repeat
  end if
  me.pMember.regPoint = point(0, me.pMember.getProp(#regPoint, 2))
  -- 0.regPoint = point(me, pMember.getProp(#regPoint, 2))
  me.pShadowFix = 0
  if me.pSprite.flipH then
    me.pSprite.flipH = 0
    me.pMatteSpr.flipH = 0
    me.pShadowSpr.flipH = 0
  end if
  if pAvatarAction.getAt(#tag) = "dead" then
    if pAvatarAction.getAt(#frame) = 1 then
      if pAvatarAction.getAt(#facedown) then
        if pAvatarAction[#direction] = 0 then
          tpoint = point(-8, 0)
        else
          if pAvatarAction[#direction] = 2 then
            tpoint = point(-10, -2)
          else
            if pAvatarAction[#direction] = 4 then
              tpoint = point(35, -5)
            else
              if pAvatarAction[#direction] = 6 then
                tpoint = point(37, 0)
              end if
            end if
          end if
        end if
      else
        if pAvatarAction[#direction] = 0 then
          tpoint = point(10, -3)
        else
          if pAvatarAction[#direction] = 2 then
            tpoint = point(30, 0)
          else
            if pAvatarAction[#direction] = 4 then
              tpoint = point(0, 0)
            else
              if pAvatarAction[#direction] = 6 then
                tpoint = point(17, -3)
              end if
            end if
          end if
        end if
      end if
    else
      if pAvatarAction.getAt(#facedown) then
        if pAvatarAction[#direction] = 0 then
          tpoint = point(-15, -10)
        else
          if pAvatarAction[#direction] = 2 then
            tpoint = point(-12, -36)
          else
            if pAvatarAction[#direction] = 4 then
              tpoint = point(38, -36)
            else
              if pAvatarAction[#direction] = 6 then
                tpoint = point(42, -10)
              end if
            end if
          end if
        end if
      else
        if pAvatarAction[#direction] = 0 then
          tpoint = point(38, -27)
        else
          if pAvatarAction[#direction] = 2 then
            tpoint = point(37, -3)
          else
            if pAvatarAction[#direction] = 4 then
              tpoint = point(-7, -3)
            else
              if pAvatarAction[#direction] = 6 then
                tpoint = point(-10, -26)
              end if
            end if
          end if
        end if
      end if
    end if
    me.pMember.regPoint = me.pMember.regPoint + tpoint
  end if
  if me.pCorrectLocZ then
    tOffZ = me.pLocH + me.pRestingHeight * 1000 + 2
  else
    tOffZ = 2
  end if
  me.pSprite.locH = me.getProp(#pScreenLoc, 1)
  me.pSprite.locV = me.getProp(#pScreenLoc, 2)
  me.pMatteSpr.loc = me.pSprite.loc
  me.pShadowSpr.loc = me.pSprite.loc + [me.pShadowFix, 0]
  if me.pBaseLocZ <> 0 then
    me.pSprite.locZ = me.pBaseLocZ
  else
    me.pSprite.locZ = me.getProp(#pScreenLoc, 3) + tOffZ + me.pBaseLocZ
  end if
  me.pMatteSpr.locZ = me.pSprite.locZ + 1
  me.pShadowSpr.locZ =  me.pSprite.locZ - 3
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  me.setOwnHiliter(1)
  return(1)
  exit
end

on setHumanSpriteLoc(me)
  tOffZ = 2
  if ilk(me.pSprite) <> #sprite then
    return(0)
  end if
  me.pSprite.locH = me.getProp(#pScreenLoc, 1)
  me.pSprite.locV = me.getProp(#pScreenLoc, 2)
  me.pSprite.locZ = me.getProp(#pScreenLoc, 3) + tOffZ
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = me.pSprite.locZ + 1
  me.pShadowSpr.loc = me.pSprite.loc + [me.pShadowFix, 0]
  me.pShadowSpr.locZ = me.pSprite.locZ - 3
  return(1)
  exit
end

on Refresh(me, tX, tY, tH)
  call(#defineDir, me.pPartList, me.pDirection)
  me.arrangeParts()
  me.pChanges = 1
  return(1)
  exit
end

on resetValues(me, tX, tY, tH, tDirHead, tDirBody)
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  if me.pGeometry = void() then
    return(0)
  end if
  me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.pMoving = 0
  call(#reset, me.pPartList)
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pChanges = 1
  return(1)
  exit
end

on setBlendInvincible(me)
  tsprite = me.pSprite
  if ilk(tsprite) <> #sprite then
    return(0)
  end if
  if tsprite.blend < 100 then
    tsprite.blend = 100
  else
    tsprite.blend = 20
  end if
  return(1)
  exit
end

on arrangeParts(me)
  if me.pPartList = void() then
    return(0)
  end if
  if me.count(#pPartList) = 0 then
    return(0)
  end if
  if pAvatarAction.getAt(#tag) = "dead" then
    me.arrangeParts_Death()
  else
    if me.pMainAction = "pck" then
      me.arrangeParts_Pick()
    else
      callAncestor(#arrangeParts, me)
    end if
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on arrangeParts_Pick(me, tXFix, tYFix)
  if me.pPartList = void() then
    return(0)
  end if
  tDirection = me.pDirection - me.pDirection mod 2
  repeat with i = 1 to count(me.pPartList)
    tPart = getAt(me.pPartList, i)
    if pActionPartList.findPos(tPart.pPart) = 0 then
      tPart.pXFix = 3
      tPart.pYFix = 5
    end if
  end repeat
  me.pChanges = 1
  return(1)
  exit
end

on arrangeParts_Death(me)
  if me.pPartList = void() then
    return(0)
  end if
  if pAvatarAction.getAt(#facedown) then
    if pAvatarAction[#direction] = 0 then
      tHeadBelow = 1
      tFace = point(-3, 11)
    else
      if pAvatarAction[#direction] = 2 then
        tFace = point(1, 9)
      else
        if pAvatarAction[#direction] = 4 then
          tFace = point(3, 9)
        else
          if pAvatarAction[#direction] = 6 then
            tHeadBelow = 1
            tFace = point(-1, 10)
          end if
        end if
      end if
    end if
  else
    if pAvatarAction[#direction] = 0 then
      tHeadBelow = 1
      tFace = point(-2, 10)
    else
      if pAvatarAction[#direction] = 2 then
        tFace = point(19, 8)
      else
        if pAvatarAction[#direction] = 4 then
          tFace = point(18, 7)
        else
          if pAvatarAction[#direction] = 6 then
            tHeadBelow = 1
            tFace = point(-1, 10)
          end if
        end if
      end if
    end if
  end if
  tActionParts = []
  repeat with i = 1 to count(pActionPartList)
    tPart = getAt(pActionPartList, i)
    if not voidp(me.getProp(#pPartIndex, tPart)) then
      tActionParts.add(me.getProp(#pPartList, me.getProp(#pPartIndex, tPart)))
    end if
  end repeat
  i = me.count(#pPartList)
  repeat while i >= 1
    tPart = me.getProp(#pPartList, i)
    if pActionPartList.findPos(tPart.pPart) > 0 then
      me.pPartList.deleteAt(i)
    end if
    i = 255 + i
  end repeat
  tHeadBelow = 1
  i = 1
  repeat while i <= tActionParts.count
    tPart = tActionParts.getAt(i)
    if tHeadBelow then
      me.pPartList.append(tPart)
    else
      me.pPartList.addAt(i, tPart)
    end if
    i = 1 + i
  end repeat
  repeat with i = 1 to count(me.pPartList)
    tPart = getAt(me.pPartList, i)
    if pActionPartList.findPos(tPart.pPart) = 0 then
      tPart.pXFix = tFace.locH
      tPart.pYFix = tFace.locV
    end if
  end repeat
  me.pChanges = 1
  return(1)
  exit
end

on getPartListNameBase(me)
  return("snowwar.human.parts")
  exit
end

on setPartLists(me, tmodels)
  tmodels = me.fixSnowWarFigure(tmodels)
  callAncestor(#setPartLists, me, tmodels)
  return(1)
  exit
end

on fixSnowWarFigure(me, tFigure)
  repeat with i = 1 to count(pActionPartList)
    tPartSymbol = getAt(pActionPartList, i)
    if voidp(tFigure.getAt(tPartSymbol)) then
      tFigure.setAt(tPartSymbol, [])
    end if
    tFigure.getAt(tPartSymbol).setAt("model", "snowwar")
    tFigure.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
  end repeat
  if getObject(#session).GET("game_number_of_teams") > 1 then
    tTeamColor = rgb(string(getVariable("snowwar.teamcolors.team" & pTeamId)))
  else
    if not voidp(tFigure.getAt("ch")) then
      tTeamColor = tFigure.getAt("ch").getAt("color")
    else
      tTeamColor = rgb("EEEEEE")
    end if
  end if
  if not voidp(tFigure.getAt("sh")) then
    tFigure.getAt("sh").setAt("color", tTeamColor)
  end if
  return(tFigure)
  exit
end

on setOwnHiliter(me, tstate)
  if not getObject(#session).exists("user_index") then
    return(0)
  end if
  if me.getID() <> getObject(#session).GET("user_index") then
    return(0)
  end if
  if pHiliteSpriteNum = 0 then
    if not tstate then
      return(1)
    end if
    if pTeamId = void() then
      return(0)
    end if
    pHiliteSpriteNum = reserveSprite("sw_own_hiliter_" & me.getID())
    if pHiliteSpriteNum = 0 then
      return(0)
    end if
    tsprite = sprite(pHiliteSpriteNum)
    tmember = member(getmemnum("sw_avatar_hilite_team_" & pTeamId))
    if tmember.type = #bitmap then
      tsprite.member = tmember
    end if
    tsprite.visible = 1
    tsprite.ink = 36
  else
    tsprite = sprite(pHiliteSpriteNum)
    tsprite.visible = tstate
  end if
  tsprite.locZ = me.getProp(#pScreenLoc, 3) + 1
  -- me.getProp(#pScreenLoc, 1).loc = point(tsprite + member.width / 2, me.getProp(#pScreenLoc, 2))
  tsprite.loc = point(me.getProp(#pScreenLoc, 1) + (tsprite.member.width / 2), me.getProp(#pScreenLoc, 2))
  exit
end

on getPicture(me, tImg)
  return(me.getPartialPicture(#Full, tImg, 4, "sh"))
  exit
end

on getTeamId(me)
  return(pTeamId)
  exit
end

on getAvatarId(me)
  return(pAvatarId)
  exit
end

on action_mv(me, tProps)
  me.pMoveTime = 500
  me.pMainAction = "wlk"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = integer(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  if me.pGeometry = 0 then
    return(0)
  end if
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineAct, me.getDefinedPartList(pActionPartList), "wlk")
  exit
end
