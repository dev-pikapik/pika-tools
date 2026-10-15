#import <MediaExtension/MediaExtension.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavcodec/bsf.h>
#include <libavutil/imgutils.h>

static const int64_t PikaNoTimestamp = AV_NOPTS_VALUE;
static const int PikaErrorEOF = AVERROR_EOF;
static const int PikaErrorAgain = AVERROR(EAGAIN);

static inline int PikaReadByteSource(MEByteSource *source, uint8_t *buffer, int size, int64_t offset) {
    size_t read = 0;
    NSError *error = nil;
    if (![source readDataOfLength:size fromOffset:offset toDestination:buffer bytesRead:&read error:&error] || read == 0) {
        return error && error.code != MEErrorEndOfStream ? AVERROR(EIO) : AVERROR_EOF;
    }
    return (int)read;
}
