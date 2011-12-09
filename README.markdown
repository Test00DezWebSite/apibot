API Bot
=======

This stuff is very Alpha, but here's the general idea:

Using some Natural Language Processing and magic, API Bot will allow non-technical people to query APIs. For example:

    show me sethvargo's repos
    get @sethvargo's last 5 tweets
    fetch sethvargo's orgs on github

The system will attempt to guess the service based on a series of keywords and guessing. Like github's Hubot, each service will be a 'drop-in' CoffeeScript file. Please fork and add additional services. I've written `github.coffee` to give people and idea of what it can do.

Usage
-----
    cake compile && node app

Using an Existing Service
-------------------------
If the service requires some kind of credentials, they are in a a file `src/scripts/[SERVICE]/config.example.json`. These might be oauth2 credentials or some kind of API key. Rename this file `config.json` and fill out the required fields. (Re)start the application server, and the service should just work.

Creating a New Service
----------------------
I have OCD. It's really handy when creating a large project though. As such, there's a clearly outline directory structure and format that developers should following when submitting additional scripts:

 1. Everything must be written in CoffeeScript.
 2. Each script must be namespaced in it's own folder.
 3. All view files must be written in Jade and placed in the views directory.
 4. You code must be properly namespaced and very readable. If it makes sense to breaks things into smaller modules, break them into smaller modules and files.

See the github one for an example.

FAQ
---
**Can I submit regular javascript files for scripts?**
*No. Only CoffeeScript.*