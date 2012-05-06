proc(_home_get, @player,
    assign(@player, to_lower(@player))
    if(_home_exists(@player),
        assign(@info, get_value(concat('skirmisher.chhomes.homes.', @player)))
        return(@info)
    )
    
    return(false)
)

proc(_home_getall,
    assign(@info, get_values('skirmisher.chhomes.homes'))
    
    return(@info)
)

proc(_home_remove, @player,
    if(has_value(concat('skirmisher.chhomes.homes.', @player)),
        clear_value(concat('skirmisher.chhomes.homes.', @player))
        return(true)
    , # else
        return(false)
    )
)

proc(_home_set, @player, @home,
    store_value(concat('skirmisher.chhomes.homes.', to_lower(@player)), @home)
)

proc(_home_exists, @name,
    if(not(has_value(concat('skirmisher.chhomes.homes.', to_lower(player())))),
        return(false)
    )
    
    return(true)
)

proc(_home_has_perm, @perm,
    # UBERCOMPLICATEDPERMCHECKINGTHINGY
    if(equals_ic(player(), '~console') || pisop(),
        return(true)
    )
    
    assign(@split, reg_split('.', @perm))
    assign(@permchecks, array(has_permission('chhomes.*')))
    
    foreach(@split, @i,
        if(((length(@split) - 1) == @i),
            array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @i)], '.'), '.self')))
            array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @i)], '.'))))
        )
        array_push(@permchecks, has_permission(concat('chhomes.', array_implode(@split[cslice(0, @1)], '.'), '.*')))
    )
    
    msg(color(green), @permchecks)
    
    if(array_contains(@permchecks, true),
        return(true)
    )
    
    return(false)
)