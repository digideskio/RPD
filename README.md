# RPD (Radio Player Daemon)

[RPD](http://rpd.lynnard.tk) is a fork from [FMD](https://github.com/hzqtc/fmd) that aims to provide more advanced features

* Support for a wide variety of audio formats
* Multi-threaded music streaming
* Support for natural language music search engine [Jing.fm](http://jing.fm) in addition to the popular [Douban.fm](http://douban.fm)
* [Automatic music download/tagging](#automatic-music-download) for liked songs
* More [commands](#commands), including changing bitrates on the fly
* Playing local songs via [local channel](#local channel)

RPD uses a TCP server-client model similar to that in FMD and MPD:

* you run `rpd` to launch the radio daemon that listens on a specific port
* then in any terminal you can use `rpc` to access and control the daemon you just now launched

## Install

### Dependencies

* `ffmpeg` for music decoding
* `libao` for music playing
* `libcurl` for api calls and music downloading
* `json-c` for json parsing
* `openssl` for validating downloaded songs using sha256
* [mutagen-CLI](https://github.com/lynnard/mutagen-CLI) for manipulating music ID3 tags

### Steps

1. clone the repo somewhere
2. `cd` into the directory
3. `make`

Note: you would almost certainly want to also install [RPC][RPC] to access and control the daemon. Follow the instruction there to finish installing `rpc`.

### Configuration

By default, the configuration file resides in `~/.rpd/rpd.conf`.

A template config file looks like this

    [Radio]
    channel = 999

    [DoubanFM]
    uid = <uid>
    uname = <username>
    token = <token>
    expire = <expire>
    kbps = 

    [JingFM]
    uid = <uid>
    atoken = <atoken>
    rtoken = <rtoken>

    [Output]
    driver = alsa
    device = default

    [Server]
    address = 0.0.0.0
    port = 10098

    [Local]
    music_dir = ~/Music
    download_lyrics = 0


* `channel` under `[Radio]`: determines the default channel on startup; `999` is the [local music channel](#local_channel)
* `kbps` under `[DoubanFM]` is only applicable for paid users (who have access to `128` and `192` bitrates); leave it blank if you are using the free service
* `[Local]`
    * `music_dir`: where to store the downloaded songs
    * `download_lyrics`: change it to 1 if you wish to download lyrics automatically using [lrcdown](https://github.com/lynnard/rpdlrc) 

To simplify the process of obtaining the user ids and tokens for the two services, you should use the `rpc-update-conf.sh` included in the repository. 

Make sure you set the usernames and passwords in the file, and then you can put something like this in your crontab to periodically update the configuration (since the tokens change from time to time)

    0 0 */3 * * rpd-update-conf.sh > ~/.rpd/rpd.conf

## Commands

To communicate with RPD, the client should make a TCP connection to the designated port in the configuration.

A client can make the following requests:

* `play`: start playing
* `stop`: stop playing
* `pause`: pause playing
* `toggle`: toggle between play and pause
* `skip`: skip to the next song
* `rate`: like the song
* `unrate`: unlike the song
* `ban`: dislike the song
* `info`: get song information
* `setch <channel>`: switch to the given radio channel
    * if `<channel` is `999`, use the [local music channel](#local-channel)
    * if `<channel>` is an integer, than use the corresponding channel from Douban.fm
    * otherwise search for `<channel>` on Jing.fm
        * e.g., `setch Adele` starts playing music from Adele
        * there are also some special channels for Jing.fm
            * `#top`: the hottest music right now
            * `#rand`: this will start a random channel using a trending search term
            * `#psn`: this starts Jing's personal recommendation channel (making use of your like and dislike data)
* `kbps <bitrate>`: on-the-fly switching of music quality
* `webpage`: opens the douban music page for the current song using the browser specified in the shell variable `$BROWSER`; if the page url is not available e.g. for Jing.fm channels, it will open the search page on douban music
* `end`: tell RPD to exit

The response is in JSON format and normally contains all the information about the currently playing song.

Note: if you installed `rpc` as I recommended before, you can easily use these commands as `rpc <command>`.

## Automatic music download

All played and liked songs will be saved to `music_dir` in `artist/title.<ext>` format. 

The ID3 tags (for `m4a`, iTunes-style tags) will be saved along as well. 

The cover image, when downloadable, will be downloaded and embedded into the song.

If you've turned on `download_lyrics`, and have installed [lrcdown](https://github.com/lynnard/rpdlrc), then the lyrics will be downloaded as `artist/title.lrc` in the same directory.

## Local channel

The local channel has the id `999`. When switching to this channel, RPD retrieves all files of mimetype `audio/*` within the `music_dir`, shuffles them and make up its playlist.

### Like

By default all music is `liked`. If you unrate a song, the action would be the same as `ban`.

### Ban

The song will be removed from your disk. In addition, if it's enclosed in some directory that becomes empty, that directory is removed as well.

## Related work

* [RPC][RPC]: RPD client
* [rpclrc](https://github.com/lynnard/rpclrc): lyrics display

[RPC]: https://github.com/lynnard/RPC "RPC"
