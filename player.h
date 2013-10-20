#ifndef _FM_PLAYER_H_
#define _FM_PLAYER_H_

#include "playlist.h"
#include <mpg123.h>
#include <ao/ao.h>
#include <curl/curl.h>
#include <pthread.h>
#include <neaacdec.h>

#define AUDIO_INBUF_SIZE 20480
#define AUDIO_REFILL_THRESH 4096
enum fm_player_status {
    FM_PLAYER_PLAY,
    FM_PLAYER_PAUSE,
    FM_PLAYER_STOP
};

typedef struct {
    size_t file_size;
    int samples;
} fm_player_info_t;

typedef struct {
    int rate;
    int channels;
    int encoding;
    char driver[16];
    char dev[16];
    // for local mode
    char tmp_dir[128];
} fm_player_config_t;

typedef struct {
    char title[128];
    char artist[128];
    char album[128];
    int pubdate;
    char cover[128];
    char url[128];
    int like;

    // local mode
    FILE *tmpstream;
    char tmpstream_path[128];
    char tmpimage_path[128];
} fm_download_info_t;

typedef enum {
    plMP3,
    plMP4
} fm_player_mode;

typedef struct {
    unsigned char buf[AUDIO_INBUF_SIZE];
    unsigned char *data;
    int size;
} aac_buffer_t;

typedef struct fm_player {
    mpg123_handle *mh;
    ao_device *dev;
    CURL *curl;

    // the mode that dictates the stream format
    fm_player_mode mode;

    // faad configurations
    NeAACDecHandle aach;
    aac_buffer_t aacb;
    int aac_inited;

    // for referring to some of the attributes in the playlist
    fm_playlist_t *playlist;
    // for local mode
    fm_download_info_t download;

    fm_player_info_t info;
    fm_player_config_t config;
    enum fm_player_status status;

    pthread_t tid_ack;
    int sig_ack;

    pthread_t tid_dl;
    pthread_t tid_play;
    pthread_mutex_t mutex_status;
    pthread_cond_t cond_play;
} fm_player_t;

// these two methods to transmit rating information to the downloader (determining whether download should be performed)
void fm_player_download_info_unrate(fm_player_t *pl);
void fm_player_download_info_rate(fm_player_t *pl);

int fm_player_set_url(fm_player_t *pl, fm_song_t *song);
void fm_player_set_ack(fm_player_t *pl, pthread_t tid, int sig);

int fm_player_pos(fm_player_t *pl);
int fm_player_length(fm_player_t *pl);

void fm_player_play(fm_player_t *pl);
void fm_player_pause(fm_player_t *pl);
void fm_player_toggle(fm_player_t *pl);
void fm_player_stop(fm_player_t *pl);

int fm_player_open(fm_player_t *pl, fm_player_config_t *config, fm_playlist_t *playlist);
void fm_player_close(fm_player_t *pl);
void fm_player_init();
void fm_player_exit();

#endif
