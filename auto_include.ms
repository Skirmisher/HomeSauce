# skirmisher.chhomes
#     +-homes
#     |    +-<player> array
#     |        +-<location> vector
#     |        +-<facing> vector
#     |        +-<isprivate> boolean
#     |        +-<welcome> string
#     |        +-<sharedto> array
#     |            +-<player> string
#     |            +-<player> string
#     |            +-...
#     |
#     +-options

include('util.ms')
#include('dispatch.ms')

proc(_home_delete, @player, @world, 
    if(_home_exists(@player, @world),
        if(
        equals_ic(@player, player()) ||
        _home_has_perm('admin.any') ||
        pisop() ||
        equals_ic(player(), '~console'),
            _home_remove(@player, @world)
            msg(color(green), 'Home deleted.')
        , # else
            msg(color(red), 'You can\'t delete someone else\'s home!')
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to delete!')
        , # else
            msg(color(yellow), @player, color(red), 'doesn\'t have a home to delete!')
        )
    )
)

proc(_home_list, @world,
    # Get a list of homes, sensitive to if it
    # is accessible by the user or not.
    assign(@homes, _home_getallworld(@world))
    assign(@player, to_lower(player()))
    
    msg('Players whose homes you can visit in this world:')
    
    foreach(@homes, @home,
        # Either the home must be public, the player must be invited to it,
        # or the player must have the admin permission
        
        # TODO: PAGINATION RAWRG
        # Pagination is already done in CHMail, have a look at the code for inbox. -EntityReborn
        if(
        equals_ic(@home['owner'], @player) ||
        equals(@home['isprivate'], false) ||
        _home_has_perm('admin.any') ||
        array_contains(@home['sharedto'], @player),
            # x) Player
            msg('-' @home['owner'])
        )
    )
)

proc(_home_create, @player, @world, assign(@private, true),
    # Set the data for the player's home    
    assign(@home, array())
    
    array_set(@home, 'owner', to_lower(@player))
    array_set(@home, 'location', ploc())
    array_set(@home, 'facing', pfacing())
    array_set(@home, 'sharedto', array())
    array_set(@home, 'isprivate', @private)
    array_set(@home, 'welcome', 'Welcome to ' . @player . '\'s home!')
    
    _home_set(@player, @world, @home)
    msg(color(green), 'Your home has been set! Make yourself at home ;)')
)

proc(_home_welcome, @player, @world, @message,
    if(_home_exists(@player, @world),
        assign(@home, _home_get(@player, @world))
        
        # Must be owner to change this.
        if(
        to_lower(player()) != @player &&
        player() != '~console' &&
        !_home_has_perm('admin.any'),
            die(color(red) . 'You\'re not the boss of ' . @player . '\'s home!')
        )
        
        # Change the private bit.
        array_set(@home, 'welcome', @message)
        _home_set(@player, @world, @home)
        
        # Notify.
        msg(color(green), 'Your home\'s welcome message has been changed to:')
        die(color(gold) . @message)
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to change the welcome message of! D:')
            die(color(blue) . 'Might we suggest setting a home with ' . color(green) . '/home set' . color(blue) . '?')
        , # else
            die(color(yellow) . @player . color(red) . 'doesn\'t have a home! D:')
        )
    )
)

proc(_home_private, @player, @world, @private,
    if(_home_exists(@player, @world),
        assign(@home, _home_get(@player, @world))
        
        # Must be owner to change this.
        if(
        !equals_ic(player(), @player) &&
        !_home_has_perm('admin.any'),
            die(color(red) . 'You\'re not the boss of ' . @player . '\'s home!')
        )
        
        # Change the private bit.
        array_set(@home, 'isprivate', @private)
        _home_set(@player, @world, @home)
        
        # Notify.
        if(@private,
            die(color(green) . 'Your home is now private.')
        , # else
            die(color(green) . 'Your home is now public.')
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to change the privacy of! D:')
            die(color(blue) . 'Might we suggest setting a home with ' . color(green) . '/home set' . color(blue) . '?')
        , # else
            die(color(yellow) . @player . color(red) . 'doesn\'t have a home! D:')
        )
    )
)

proc(_home_invite, @player, @world, @i, assign(@shared, true),
    # Invite someone to your home.
    assign(@invitee, to_lower(@i))
    
    if(_home_exists(@player, @world),
        assign(@home, _home_get(@player, @world))
        
        # Make sure the player is the home's owner.
        if(player() == @player ||
        _home_has_perm('admin.any'),
            if(@shared,
                # Have a cookie.
                if(!array_contains(@home['sharedto'], @invitee),
                    # Only add if the player isn't already in the list.
                    
                    array_push(@home['sharedto'], @invitee)
                    _home_set(@player, @world, @home)
                    
                    die(color(blue) . @i . color(green) . ' has been invited to your home.')
                , # else
                    # Player already on list.
                    
                    die(color(red) . 'You\'ve already invited ' . @i . ' to your home!')
                )
            , # else
                # NO HOME 4 U!
                if(array_contains(@home['sharedto'], @player),
                    # Need to loop thru the whole list due to no array_remove_value (yet!).
                    foreach(@home['sharedto'], assign(@item, 0), 
                        if(equals_ic(@item, @invitee),
                            array_remove(@home['sharedto'], @item)
                            _home_set(@player, @world, @home)
                            
                            die(color(blue) . @i . color(green) . ' is no longer invited to your home.')
                        , # else
                            inc(@item)
                        )
                    )
                , # else
                    # Player is already denied.
                    die(color(red) . @player . ' already !')
                )
            )
        , # else
            die(color(red) . 'You\'re not the boss of ' . @player . '\'s home!')
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to invite anyone to for `' . @world . '`! D:')
            die(color(blue) . 'Might we suggest setting a home with ' . color(green) . '/home set' . color(blue) . '?')
        , # else
            die(color(yellow) . @player . color(red) . 'doesn\'t have a home for `' . @world . '`! D:')
        )
    )
)

proc(_home_tp, @player, @world,
    assign(@player, to_lower(@player))
    assign(@world, to_lower(@world))
    
    if(_home_exists(@player, @world),
        # Grab the info
        assign(@home, _home_get(@player, @world))
        assign(@shared, @home['sharedto'])
        
        # Can I haz tp to home?
        if(
        equals_ic(player(), @player) ||
        @home['isprivate'] == false ||
        _home_has_perm('admin.any') ||
        array_contains(@shared, @player),
            # ACTIVATE
            pfacing(@home['facing'][0], @home['facing'][1])
            set_ploc(@home['location'])
            
            if(
            is_string(@home['welcome']) &&
            @home['welcome'] != '',
                die(color(gold) . @home['welcome'])
            )
        , # else
            msg(color(red), 'You don\'t have permission!')
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to teleport to for `' . @world . '`! D:')
            die(color(blue) . 'Might we suggest setting a home with ' . color(green) . '/home set' . color(blue) . '?')
        , # else
            die(color(yellow) . @player . color(red) . 'doesn\'t have a home for `' . @world . '`! D:')
        )
    )
)