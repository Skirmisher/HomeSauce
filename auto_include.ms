# skirmisher.chhomes
#     +-homes
#     |    +-<player> array
#     |        +-<location> vector
#     |        +-<name> string
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

proc(_home_delete, @player,
    assign(@homes, _home_getall())
    
    if(_home_exists(@player),
        if(or(
        equals_ic(@player, player()),
        _home_has_perm('admin.any'),
        pisop(),
        equals_ic(player(), '~console')),
            _home_remove(to_lower(@player))
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

proc(_home_list,
    # Get a list of homes, sensitive to if it
    # is accessible by the user or not.
    
    assign(@homes, _home_getall())
    assign(@player, to_lower(player()))
    
    msg('Players whose homes you can visit:')
    
    foreach(@homes, @home,
        # Either the home must be public, the player must be invited to it,
        # or the player must have the admin permission
        
        # To do: PAGINATION RAWRG
        if(or(
        equals(@home['isprivate'], false),
        equals_ic(@home, @player),
        _home_has_perm('admin.any'),
        array_contains(@home['sharedto'], @player)),
            # x) Player
            msg('-' @home)
        )
    )
)

proc(_home_create, @player, assign(@private, import('chhomes.defaultprivacy')),
    # Set the data for the player's home    
    assign(@home, array())
    array_set(@home, 'location', ploc())
    array_set(@home, 'facing', pfacing())
    array_set(@home, 'sharedto', array())
    array_set(@home, 'isprivate', @private)
    # I CC BECAUSE I'M LAZY
    array_set(@home, 'welcome', cc('Welcome to ' @player '\'s home!'))
    
    _home_set(@player, @home)
    msg(concat(color(green), 'Your home has been set! Make yourself at home ;)'))
)

proc(_home_welcome, @player, @message,
    
    if(_home_exists(@player),
        assign(@home, _home_get(@player))
        
        # Must be owner to change this.
        if(to_lower(player()) != @player &&
        player() != '~console' &&
        !_home_has_perm('admin.any'),
            die(concat(color(red), 'You\'re not the boss of ', @player, '\'s home!'))
        )
        
        # Change the private bit.
        array_set(@home, 'welcome', @message)
        _home_set(@player, @home)
        
        # Notify.
        msg(color(green), 'Your home\'s welcome message has been changed to:')
        die(concat(color(gold), @message))
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to change the welcome message of! D:')
            die(concat(color(blue), concat('Might we suggest setting a home with ', color(green), '/home set', color(blue), '?')))
        , # else
            die(concat(color(yellow), @player, color(red), 'doesn\'t have a home! D:'))
        )
    )
)

proc(_home_private, @player, @private,
    if(_home_exists(@player),
        assign(@home, _home_get(@player))
        
        # Must be owner to change this.
        if(!equals_ic(player(), @player) &&
        !_home_has_perm('admin.any'),
            die(concat(color(red), 'You\'re not the boss of ', @player, '\'s home!'))
        )
        
        # Change the private bit.
        array_set(@home, 'isprivate', @private)
        _home_set(@player, @home)
        
        # Notify.
        if(@private,
            die(concat(color(green), 'Your home is now private.'))
        , # else
            die(concat(color(green), 'Your home is now public.'))
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to change the privacy of! D:')
            die(concat(color(blue), concat('Might we suggest setting a home with ', color(green), '/home set', color(blue), '?')))
        , # else
            die(concat(color(yellow), @player, color(red), 'doesn\'t have a home! D:'))
        )
    )
)

proc(_home_invite, @player, @i, assign(@s, true),
    # Invite someone to your home.
    assign(@invitee, to_lower(@i))
    
    # Allow only true/false.
    switch(@s,
        array(true, false),
            assign(@shared, @s),
        die('Invalid option.')
    )
    
    if(_home_exists(@player),
        assign(@home, _home_get(@player))
        # Make sure the player is the home's owner.
        if(player() == @player ||
        _home_has_perm('admin.any'),
            if(@shared,
                # Have a cookie.
                
                if(!array_contains(@home['sharedto'], @invitee),
                    # Only add if the player isn't already in the list.
                    
                    array_push(@home['sharedto'], @invitee)
                    _home_set(@player, @home)
                    
                    die(concat(color(blue), @i, color(green), ' has been invited to your home.'))
                , # else
                    # Player already on list.
                    
                    die(concat(color(red), 'You\'ve already invited ', @i, ' to your home!'))
                )
            , # else
                # NO HOME 4 U!
                
                if(array_contains(@home['sharedto'], @player),
                
                    # Need to loop thru the whole list due to no array_remove_value (yet!).
                    foreach(@home['sharedto'], assign(@item, 0), 
                        if(equals_ic(@item, @invitee),
                            array_remove(@home['sharedto'], @item)
                            _home_set(@player, @home)
                            
                            die(concat(color(blue), @i, color(green), ' is no longer invited to your home.'))
                        , # else
                            inc(@item)
                        )
                    )
                , # else
                    # Player is already denied.
                    
                    die(concat(color(red), @player, ' already !'))
                )
            )
        , # else
            die(concat(color(red), 'You\'re not the boss of ', @player, '\'s home!'))
        )
    , # else
        if(equals_ic(@player, player()),
            msg(color(red), 'You don\'t have a home to invite anyone to! D:')
            die(concat(color(blue), concat('Might we suggest setting a home with ', color(green), '/home set', color(blue), '?')))
        , # else
            die(concat(color(yellow), @player, color(red), 'doesn\'t have a home! D:'))
        )
    )
)

proc(_home_tp, @p,
    if(_home_exists(@player),
        # Grab the info
        assign(@home, _home_get(@p))
        assign(@shared, @home['sharedto'])
        assign(@player, to_lower(player()))
        
        # Can I haz tp to home?
        if(or(
        equals_ic(player(), @player), 
        equals(@home['isprivate'], false),
        _home_has_perm('admin.any'),
        array_contains(@shared, @player)),
            # ACTIVATE
            pfacing(@home['facing'][0], @home['facing'][1])
            set_ploc(@home['location'])
            
            if(and(
            is_string(@home['welcome']),
            not(equals(@home['welcome'], ''))),
                die(concat(color(gold), @home['welcome']))
            )
        , # else
            msg(color(red), 'You don\'t have permission!')
        )
    , # else
        if(equals_ic(@p, player()),
            if(_home_has_perm('tp'),
                msg(color(red), 'You don\'t have a home to teleport to! D:')
                die(concat(color(blue), concat('Might we suggest setting a home with ', color(green), '/home set', color(blue), '?')))
            , # else
                die(concat(color(red), 'You don\'t have permission!'))
            )
        , # else
            if(_home_has_perm('tp.others'),
                die(concat(color(yellow), @p, color(red), 'doesn\'t have a home! D:'))
            , # else
                die(concat(color(red), 'You don\'t have permission!'))
            )
        )
    )
)