API Bot
=======

This stuff is very Alpha, but here's the general idea:

Using some Natural Language Processing and magic, this Robot will allow non-technical people to query APIs. For example:

    show me sethvargo's repos
    get @sethvargo's last 5 tweets
    fetch sethvargo's orgs on github

The system will attempt to guess the service, and, like github's Hubot, each service will be a 'drop-in' `.js` file. Check back as I continue to work on this...