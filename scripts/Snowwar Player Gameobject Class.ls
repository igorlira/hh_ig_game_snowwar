on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  me.removeControllingAvatar()
  return(1)
  exit
end

-- TODO: Revise this

on define(me, tGameObject)
  executeMessage(#ig_store_gameplayer_info, tGameObject)
  return(1)
  exit
end

-- End revise

on removeControllingAvatar(me)
  return(me.getGameSystem().executeGameObjectEvent(me.getProp(#pGameObjectSyncValues, #human_id), #reset_player))
  exit
end
