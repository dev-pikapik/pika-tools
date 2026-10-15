// The macOS SDK ships libarchive.tbd but not its headers, so this declares the calls Preview uses (libarchive 3.x).
#include <stdint.h>
#include <sys/types.h>

struct archive;
struct archive_entry;

typedef ssize_t (*archive_read_callback)(struct archive *, void *client, const void **buffer);
typedef int64_t (*archive_skip_callback)(struct archive *, void *client, int64_t request);
typedef int64_t (*archive_seek_callback)(struct archive *, void *client, int64_t offset, int whence);
typedef int (*archive_open_callback)(struct archive *, void *client);
typedef int (*archive_close_callback)(struct archive *, void *client);

struct archive *archive_read_new(void);
int archive_read_free(struct archive *);
int archive_read_support_filter_gzip(struct archive *);
int archive_read_support_filter_bzip2(struct archive *);
int archive_read_support_filter_xz(struct archive *);
int archive_read_support_filter_lzma(struct archive *);
int archive_read_support_filter_zstd(struct archive *);
int archive_read_support_filter_compress(struct archive *);
int archive_read_support_format_zip(struct archive *);
int archive_read_support_format_7zip(struct archive *);
int archive_read_support_format_rar(struct archive *);
int archive_read_support_format_rar5(struct archive *);
int archive_read_support_format_tar(struct archive *);
int archive_read_support_format_cpio(struct archive *);
int archive_read_support_format_lha(struct archive *);
int archive_read_support_format_cab(struct archive *);
int archive_read_support_format_raw(struct archive *);
int archive_read_set_seek_callback(struct archive *, archive_seek_callback);
int archive_read_open2(struct archive *, void *client, archive_open_callback, archive_read_callback, archive_skip_callback, archive_close_callback);
int archive_read_next_header(struct archive *, struct archive_entry **);
int archive_format(struct archive *);
int archive_filter_count(struct archive *);
int archive_read_has_encrypted_entries(struct archive *);

const char *archive_entry_pathname(struct archive_entry *);
const char *archive_entry_pathname_utf8(struct archive_entry *);
int64_t archive_entry_size(struct archive_entry *);
int archive_entry_size_is_set(struct archive_entry *);
mode_t archive_entry_filetype(struct archive_entry *);
mode_t archive_entry_mode(struct archive_entry *);
int archive_entry_is_encrypted(struct archive_entry *);
