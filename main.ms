bind(player_spawn, array(priority: high), null, @event,
    assign(@world, pinfo()[7])
    assign(@closure, closure(
        _home_tp(@event['player'], @world)
    ))
    
    # We need a delay, as tp'ing immediately has no affect.
    set_timeout(500, @closure)
)