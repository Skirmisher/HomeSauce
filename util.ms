proc(_home_get, @player, @world,
    if(_home_exists(@player, @world),
        assign(@info, get_value('skirmisher.chhomes.homes.' . to_lower(@world) . '.' . to_lower(@player)))
        return(@info)
    )
    
    return(false)
)

proc(_home_getall,
    assign(@info, get_values('skirmisher.chhomes.homes'))
    return(@info)
)

proc(_home_getallworld, @world,
    assign(@info, get_values('skirmisher.chhomes.homes.' . to_lower(@world)))
    return(@info)
)

proc(_home_remove, @player, @world,
    assign(@player, to_lower(@player))
    assign(@world, to_lower(@world))
    
    if(has_value('skirmisher.chhomes.homes.' . @world . '.' . @player),
        clear_value('skirmisher.chhomes.homes.' . @world . '.' . @player)
        return(true)
    , # else
        return(false)
    )
)

proc(_home_set, @player, @world, @loc,
    assign(@id, 'skirmisher.chhomes.homes.' . to_lower(@world) . '.' . to_lower(@player))
    store_value(@id, @loc)
)

proc(_home_exists, @player, @world,
    assign(@id, 'skirmisher.chhomes.homes.' . to_lower(@world) . '.' . to_lower(@player))
    return(has_value(@id))
)

proc(_home_has_perm, @perm,
    # UBERCOMPLICATEDPERMCHECKINGTHINGY
    # Doesn't this style of permission folding work already? (having xyz.* assumes you have xyz.abc) -EntityReborn
    if(equals_ic(player(), '~console') || pisop(),
        return(true)
    )
    
    assign(@split, reg_split('.', @perm))
    assign(@permchecks, array(has_permission('chhomes.*')))
    
    foreach(@split, @i,
        if((length(@split) - 1) == @i,
            array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @i)], '.'), '.self')))
            array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @i)], '.'))))
        )
        array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @1)], '.'), '.*')))
    )
    
    if(array_contains(@permchecks, true),
        return(true)
    )
    
    return(false)
)