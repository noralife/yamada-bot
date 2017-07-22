# yamada-bot

[![Build Status](https://travis-ci.org/noralife/yamada-bot.svg?branch=master)](https://travis-ci.org/noralife/yamada-bot)
[![Code Climate](https://codeclimate.com/repos/56769ead5cd2431f25004178/badges/4da9c99725b511726cf5/gpa.svg)](https://codeclimate.com/repos/56769ead5cd2431f25004178/feed)

yamada-bot is a chat bot built on the [botkit][botkit] framework.

[botkit]: https://github.com/howdyai/botkit

### Development with Vagrant

You can create a development environment for yamada-bot by running the following.
Because currently botkit does not support mock, you need Slack Credential to run yamada-bot.

To begin with, you need install [VirtualBox][VirtualBox] and [Vagrant][Vagrant].
[VirtualBox]: https://www.virtualbox.org/
[Vagrant]: https://www.vagrantup.com/

Then, `Vagrantfile` generates a development environment:

    $ git clone https://github.com/noralife/yamada-bot.git
    $ cd yamada-bot
    $ vagrant up

Now, you can start yamada-bot locally by running:

    $ vagrant ssh
    vagrant@ubuntu:~$ cd /vagrant
    vagrant@ubuntu:~/vagrant$ npm install
    vagrant@ubuntu:~/vagrant$ export METADATA_API_KEY=<INPUT_METADATA_API_KEY_HETE>
    vagrant@ubuntu:~/vagrant$ export CHANNEL=<INPUT_CHANNEL_ID_HERE>
    vagrant@ubuntu:~/vagrant$ export SLACK_TOKEN=<INPUT_SLACK_TOKEN_HERE>
    vagrant@ubuntu:~/vagrant$ coffee ./scripts/bot.coffee

### License

Please refer to LICENSE.md

### Contributing

1. Fork it ( https://github.com/noralife/yamada-bot )
2. Clone it (`git clone https://github.com/your-github-account/yamada-bot`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
