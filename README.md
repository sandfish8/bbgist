bbgist is a simple app to help with copying/pasting snippets of code from remote servers

https://bbgist.blueboxgrid.com

Usage Story
-----------

Scenario:
You are bbshed into a Bluebox server, and you want to get a file off the the remote server and onto your local machine.

You can do this:
```bash
$ curl -k -F file=@FILE_NAME https://bbgist.blueboxgrid.com
```

and the output will be:
```bash
https://bbgist.blueboxgrid.com/get?name=abnjpserdg
```

Then paste that returned link into a browser.
Select All  and Copy / Paste as you please.

Why bbgist?
----------
scp to/from a remote host can be a real PITA when it's behind a bastion host. <br />
I've had to create users on these hosts just to do a scp.  This feels like a security anti-pattern. <br />

Access Restrictions
-------------------

only hosts on bluebox network can hit bbgist without authenticating<br />
When you access https://bbgist.blueboxgrid.com from your workstation you will need to authenticate.  The password is on the Boxpanel PW page.<br />
(would like to get our openID solution working with this for single signon)<br />

Once you've entered the password a cookie will be generated so you don't have to auth for quite awhile.

ACLs ?
-------
There are none.  So every text file that's been uploaded to bbgist is open for READing and DELETEing for all Bluebox folks.<br />

Help
------
If you forget the syntax to use bbgist you can issue this to get an example
```bash
curl https://bbgist.blueboxgrid.com/help
```

bbgist will only accept unauthenticated connections from servers on the Bluebox network.  So you cna

Binaries?
---------
You can also push binaries to bbgist.   Not sure what the size limits will be here so MMV.
To download a binary use the 'download' link on the bbgist webpage.

To Do
-------
Write a script to allow for cooler syntax. e.g.  curl https://bbgist.blueboxgrid.com/sh -file foo.conf | bash

