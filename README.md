Constable
=========

Seascape Study with Rain Cloud was painted by John Constable around 1824.

Constable the Gem is a way of providing ImageMagick as a service. I doubt
anything quite as powerful will be generated using the service, but if you do
make something nice please let me know!


Up and running fast
-------------------

I've provided a Vagrant setup that will get you up and running fast. Install
the necessary gems using bundler:

    cd /path/to/checkout/of/constable
    bundle

Ask Vagrant to bring up the server components for you:

    cd /path/to/checkout/of/constable
    bundle exec vagrant up

Ask Constable to do some work:

    cd /path/to/checkout/of/constable
    cat /path/to/input.png | ./bin/constable-identify

That's it, you just used ImageMagick as a service.

Of course, if you want to use it as a real service on your network you'll
probably want to set it up a little differently. See the following sections on
Installing and Usage for information on how to setup your own ImageMagick
service.


Installing
----------

The server needs ImageMagick installed. Mostly I do this using `apt-get`:

    apt-get install imagemagick

You'll need a broker that talks Stomp somewhere on your network. I use Apache
Apollo, and I'm not totally sure if the code uses anything that's specific to
that. I'd love it to be broker-agnostic though, so if you have patches that'll
bring this closer to reality please send them to me!


Usage
-----

ImageMagick provides a huge number of commands and options. Supporting them
all is a big task, so I'm implementing just the few that I use. If you need
something else supported, please do fork and patch the project. Let me know
and I'll pull your changes.

Run the server, somewhere that has ImageMagick installed:

    constabled --broker=stomp://mq.yourdomain.com:61613

Use the services on the command line. You don't need ot have ImageMagick
installed on your client machines, just constable.

Command names are based on ImageMagick command names, prefixed with
`constable-`, eg `constable-identify`. All commands will respond to --help
and will give you a decent explanation of what they do and their options if
you ask for it.

The commands are designed to take their input on standard input and return
results on standard output. It's up to you what you do with the input and
output; write it to a file, pipe it to another process, that's not handled by
Constable (and I have no plans to handle it).

A brief example of what interacting with Constable looks like, here
identifying some image file I had lying around on disk:

    $ cat input_file | constable-identify --broker=stomp://mq.yourdomain.com:61613
    constabled-164829495-102948483-1939485.jpg JPEG 640x480 DirectClass 87kb 0.050u 0:01

I explicitly state the broker in the above commands but if you leave out that
option it'll default to stomp://localhost:61613 ie it expects a broker running
on your local machine if you don't tell it otherwise.


Authors
-------

Craig R Webster <http://barkingiguana.com/>
