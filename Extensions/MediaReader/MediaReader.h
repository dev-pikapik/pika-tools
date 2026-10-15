#import <MediaExtension/MediaExtension.h>
#import "FFmpeg.h"

static inline int PikaReadByteSource(MEByteSource *source, uint8_t *buffer, int size, int64_t offset) {
    size_t read = 0;
    NSError *error = nil;
    if (![source readDataOfLength:size fromOffset:offset toDestination:buffer bytesRead:&read error:&error] || read == 0) {
        return error && error.code != MEErrorEndOfStream ? AVERROR(EIO) : AVERROR_EOF;
    }
    return (int)read;
}
