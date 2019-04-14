property pRoomObject, pMaxBallcounton construct mepMaxBallcount = getIntVariable("snowwar.object_snowball_machine.maximum_ballcount", 5)return TRUEendon deconstruct metWorld = me.getGameSystem().getWorld()if tWorld <> 0 thentWorld.clearObjectFromTileSpace(me.getObjectId())end ifme.removeRoomObject()return TRUEendon define me, tdatatTileLoc = me.getGameSystem().convertworldtotilecoordinate(tdata[#objectDataStruct][#x], tdata[#objectDataStruct][#y])if tTileLoc = FALSE thenreturn error(me, "Invalid location, tile not found!" & RETURN & tdata[#objectDataStruct], #createRoomObject)end iftdata.setaProp(#tile_x, tTileLoc[#x])tdata.setaProp(#tile_y, tTileLoc[#y])me.setGameObjectProperty(#tile_x, tTileLoc[#x])me.setGameObjectProperty(#tile_y, tTileLoc[#y])me.reserveSpaceForObject()return me.createRoomObject(tdata)endon executeGameObjectEvent me, tEvent, tdatacase tEvent of#add_snowball:if me.setBallCount((me.getBallCount() + 1)) thenreturn me.renderBallCreation()end if#remove_snowball:if me.setBallCount((me.getBallCount() - 1)) then -- jump 16return me.renderBallCount()end casereturn FALSEendon getBallCount mereturn me.getProp(#pGameObjectSyncValues, #snowball_count)endon setBallCount me, tValueif tValue < 0 then return FALSEif tValue > pMaxBallcount then return FALSEreturn me.setGameObjectSyncProperty(#snowball_count, tValue)endon renderBallCreation meif pRoomObject = FALSE then return FALSEreturn pRoomObject.animate(me.getBallCount())endon renderBallCount meif pRoomObject = FALSE then return FALSEreturn pRoomObject.render(me.getBallCount())endon createRoomObject me, tDataStructpRoomObject = createObject(#temp, getClassVariable("snowwar.object_snowball_machine.roomobject.wrapper.class"))if pRoomObject = FALSE thenreturn error(me, "Cannot create roomobject wrapper for human!", #createRoomObject)end ifpRoomObject.define(tDataStruct)pRoomObject.render(me.getBallCount())return TRUEendon removeRoomObject meif objectp(pRoomObject) then pRoomObject.deconstruct()pRoomObject = FALSEreturn TRUEendon reserveSpaceForObject metWorld = me.getGameSystem().getWorld()if tWorld = FALSE then return FALSEtWorld.clearObjectFromTileSpace(me.getObjectId())if not tWorld.reserveTileForObject(me.getGameObjectProperty(#tile_x), me.getGameObjectProperty(#tile_y), me.getObjectId(), me.getGameObjectProperty(#gameobject_height)) thenreturn error(me, "Unable to reserve tile for snowballmachine in:" && me.pGameObjectSyncValues, #reserveSpaceForObject)end ifreturn TRUEend