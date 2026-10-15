#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavcodec/bsf.h>
#include <libavutil/imgutils.h>

static const int64_t PikaNoTimestamp = AV_NOPTS_VALUE;
static const int PikaErrorEOF = AVERROR_EOF;
static const int PikaErrorAgain = AVERROR(EAGAIN);
