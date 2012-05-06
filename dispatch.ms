proc(_home_dispatch, @input,
    # Parse the incoming command, depending on its first
    # word.
    
    # Called with empty command?
    assign(@match, reg_match('^\\s*([^ ]+)(\\s+(.*)\\s*)?$', @input))
    if(@match,
        assign(@first, to_lower(@match[1]))
        assign(@args, @match[3])
    , # else
        # Need permissions checks. Also, this should be in a switch.
        msg(color(green), 'The following commands are available:')
        msg(color(gold), '- ', color(blue), '/home help', color(gold), ': show this message.')
        msg(color(gold), '- ', color(blue), '/home ', color(gray), '[world]', color(gold), ': teleport to your home (in ', color(gray), '[world]', color(gold), ').')
        msg(color(gold), '- ', color(blue), '/home set', color(gold), ': set your home.')
        msg(color(gold), '- ', color(blue), '/home delete', color(gold), ': delete your home.')
        msg(color(gold), '- ', color(blue), '/home public', color(gold), ': allow everyone to access your home.')
        msg(color(gold), '- ', color(blue), '/home private', color(gold), ': stop everyone from accessing your home.')
        msg(color(gold), '- ', color(blue), '/home welcome ', color(gray), '[message]', color(gold), ': set your home\'s welcome message (leave blank to clear).')
        msg(color(gold), '- ', color(blue), '/home invite ', color(gray), '<player>', color(gold), ': allow ', color(gray), '<player> ', color(gold), 'to access your home.')
        msg(color(gold), '- ', color(blue), '/home uninvite ', color(gray), '<player>', color(gold), ': disallow ', color(gray), '<player> ', color(gold), 'from accessing your home.')
        msg(color(gold), '- ', color(blue), '/home list', color(gold), ': list homes that you can access.')
        msg(color(gold), '- ', color(blue), '/home ilist', color(gold), ': list people invited to your home.')
        msg(color(gray), '[world] parameters allow you to direct an action to (a) home(s) in a specific world; it defaults to the current world.')
        return()
    )
    
    # Needs to be updated to reflect 
    switch(@first,
        'set',
            assign(@args, reg_match('^(.+)$', @args))
            
            if(@args,
                _home_create(@args[1], @first == 'pcreate')
            , # else
                die(concat(color(red), 'Usage: /home set'))
            ),
            
        'delete',
            assign(@args, reg_match('^(.+)$', @args))
            
            if(@args,
                _warp_delete(@args[1])
            , # else
                die('Usage: /home delete <name>')
            ),
            
        'public',
            assign(@args, reg_match('^(.+)$', @args))
            
            if(@args,
                _warp_private(@args[1], false)
            , # else
                die('Usage: /home public <name>')
            ),
            
        'private',
            assign(@args, reg_match('^(.+)$', @args))
            
            if(@args,
                _warp_private(@args[1], true)
            , # else
                die('Usage: /home private <name>')
            ),
            
        'welcome',
            assign(@args, reg_match('^(.*?)\\s+([^ ]+)$', @args))
            
            if(@args,
                _warp_welcome(@args[1], @args[2])
            , # else
                die('Usage: /home welcome <name> [message]')
            ),
            
        'invite',
            assign(@args, reg_match('^(.*?)\\s+([^ ]+)$', @args))
            
            if(@args,
                _warp_share(@args[1], @args[2], true)
            , # else
                die('Usage: /home invite <name> <player>')
            ),
            
        'uninvite',
            assign(@args, reg_match('^(.*?)\\s+([^ ]+)$', @args))
            
            if(@args,
                _warp_share(@args[1], @args[2], false)
            , # else
                die('Usage: /home uninvite <name> <player>')
            ),
            
        'list',
            _warp_list()
            return(),
        # default
            _warp_to(@input)
    )
)