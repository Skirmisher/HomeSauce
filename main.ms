#bind(player_death, null, null, @event,
#    export(concat(to_lower(player()), '.world'), pworld())
#)

#bind(player_spawn, array(priority: high), null, @event,
#    import
#)