property pRoomObject, pMaxBallcount

on construct(me)
  pMaxBallcount = getIntVariable("snowwar.object_snowball_machine.maximum_ballcount", 5)
  return(1)
  exit
end

on deconstruct(me)
  tWorld = me.getGameSystem().getWorld()
  if tWorld <> 0 then
    tWorld.clearObjectFromTileSpace(me.getObjectId())
  end if
  me.removeRoomObject()
  return(1)
  exit
end

on define(me, tdata)
  tTileLoc = me.getGameSystem().convertworldtotilecoordinate(tdata.getAt(#objectDataStruct).getAt(#x), tdata.getAt(#objectDataStruct).getAt(#y))
  if tTileLoc = 0 then
    return(error(me, "Invalid location, tile not found!" & "\r" & tdata.getAt(#objectDataStruct), #createRoomObject))
  end if
  tdata.setaProp(#tile_x, tTileLoc.getAt(#x))
  tdata.setaProp(#tile_y, tTileLoc.getAt(#y))
  me.setGameObjectProperty(#tile_x, tTileLoc.getAt(#x))
  me.setGameObjectProperty(#tile_y, tTileLoc.getAt(#y))
  me.reserveSpaceForObject()
  return(me.createRoomObject(tdata))
  exit
end

on executeGameObjectEvent(me, tEvent, tdata)
  if tEvent = #add_snowball then
    if me.setBallCount(me.getBallCount() + 1) then
      return(me.renderBallCreation())
    end if
  else
    if tEvent = #remove_snowball then
      if me.setBallCount(me.getBallCount() - 1) then
        return(me.renderBallCount())
      end if
    end if
  end if
  return(0)
  exit
end

on getBallCount(me)
  return(me.getProp(#pGameObjectSyncValues, #snowball_count))
  exit
end

on setBallCount(me, tValue)
  if tValue < 0 then
    return(0)
  end if
  if tValue > pMaxBallcount then
    return(0)
  end if
  return(me.setGameObjectSyncProperty(#snowball_count, tValue))
  exit
end

on renderBallCreation(me)
  if pRoomObject = 0 then
    return(0)
  end if
  return(pRoomObject.animate(me.getBallCount()))
  exit
end

on renderBallCount(me)
  if pRoomObject = 0 then
    return(0)
  end if
  return(pRoomObject.render(me.getBallCount()))
  exit
end

on createRoomObject(me, tDataStruct)
  pRoomObject = createObject(#temp, getClassVariable("snowwar.object_snowball_machine.roomobject.wrapper.class"))
  if pRoomObject = 0 then
    return(error(me, "Cannot create roomobject wrapper for human!", #createRoomObject))
  end if
  pRoomObject.define(tDataStruct)
  pRoomObject.render(me.getBallCount())
  return(1)
  exit
end

on removeRoomObject(me)
  if objectp(pRoomObject) then
    pRoomObject.deconstruct()
  end if
  pRoomObject = 0
  return(1)
  exit
end

on reserveSpaceForObject(me)
  tWorld = me.getGameSystem().getWorld()
  if tWorld = 0 then
    return(0)
  end if
  tWorld.clearObjectFromTileSpace(me.getObjectId())
  if not tWorld.reserveTileForObject(me.getGameObjectProperty(#tile_x), me.getGameObjectProperty(#tile_y), me.getObjectId(), me.getGameObjectProperty(#gameobject_height)) then
    return(error(me, "Unable to reserve tile for snowballmachine in:" && me.pGameObjectSyncValues, #reserveSpaceForObject))
  end if
  return(1)
  exit
end
