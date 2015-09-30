-lite | Frog DNA, basically
===========================

Libite is a lightweight library of *frog DNA*.  It can be used to fill
the gaps in any dinosaur project.  It holds useful functions and macros
developed by both [Finit][1] and the [OpenBSD][2] project.  Most notably
the string functions: [strlcpy(3)][3], [strlcat(3)][3] and the highly
useful *BSD [sys/queue.h][4] API.

Libite aims to fill in the gaps missing in GLIBC/EGLIBC.  (It does not
aimo to become another [GLIB][5] though.)  One such gap in GLIBC is the
missing `_SAFE` macros in `sys/queue.h` &mdash; highly recommended when
traversing lists to delete/free nodes.

The code is open sourced under a mix of the [MIT/X11 license][MIT], the
[ISC license][ISC] used by OpenBSD, and [BSD licenses][BSD], all of them
are extremely liberal and can be used freely in proprietary software if
needed.

For an introduction to why Libite happened, and how you can use it, see
[this blog post][6].


Helper Macros
-------------

- `atonum(str)`

  Convert string to natural number, works for 32-bit non-negative
  integers.  Returns -1 on error.  (Uses `strtonum()` internally.)

- `blkdev(dev)`

  Create block device

- `chardev(dev)`

  Create character device

- `erase(path)`

  Erase file/directory with `remove()`.  Errors on stderr

- `makedir(path)`

  Create directory, like `mkdir()`.  Errors on stderr

- `makefifo(path)`

  Create a FIFO, like `mkfifo()`.  Errors on stderr

- `touch(path)`

  Create a file, or update mtime.  Errors on stderr

- `S_ISEXEC(mode_t m)`

  Mysteriously missing from GLIBC

- `UNUSED(var)`

  Shorter and more readable version of `var __attribute__ ((unused))`


Generic Functions
-----------------

- `chomp(str)`

  Perl like chomp function, chop off last char if newline.

- `copyfile(src, dst, len, symlink)`

  Like the shell `cp(1)` and `dd(1),` can also create symlinks.

- `dir(dir, ext, filter, list, strip)`

  Wrapper for `scandir()` with optional filter.  Returns a list of
  names: files and directories that must be freed after use.  See
  the unit test at the bottom for an example.

- `fcopyfile(src, dst)`

  Like `copyfile()` but uses already open `FILE *` pointers.  Copies
  from current file positions to current file positions until EOF.

- `fexist(file)`

  Check for the existance of a file, returns True(1) or False(0).

- `fisdir(path)`

  Check for the existance of a directory, returns True(1) or False(0).

- `fmode(file)`

  Returns the `mode_t` bits of a file or directory.

- `fsendfile(src, dst, len)`

  Copy data between file streams, very similar to `fcopyfile()`, but
  `dst` is allowed to be `NULL` to be able to read and discard `len`
  bytes from `src`.

- `ifconfig(ifname, addr, mask, up)`

  Basic ifconfig like operations on an interface.  Only supports IPv4
  adresses.  Note that mask is not CIDR notation.

- `makepath(dir)`

  Create all components of the specified directory.

- `mkpath(dir, mode)`

  Like `makepath()`, but also takes a `mode_t` permission mode argument.

- `movefile(src, dst)`

  Like `copyfile()`, but renames `src` to `dst`, or recreates symlink
  with the `dst` name.  On successful operation the source is removed
  and the function returns POSIX OK (0).

- `pidfile(basename)`

  Write a daemon pid file.  Creates a pidfile in `_PATH_VARRUN` using
  either `basename` or, if `basename` is `NULL`, `__progname`.  The
  file name has the form `/var/run/basename.pid`.

  Use this function to create a pid file for your daemon when it is
  ready to receive signals.  A client application may poll for the
  existence of this file, so make sure to have your signal handlers
  properly setup before calling this function.
  
  The pidfile is removed when the program exits, using an `atexit()`
  handler.  However, depending on how the program terminates the file
  may still exist even though the program is no longer running.  This
  is only a problem for clients.

  See below for link to OpenBSD man page.

- `pidfile_read(pidfile)`

  Read PID from pid file created by `pidfile()`.

- `pidfile_signal(pidfile, signal)`

  Send signal to PID found in pid file created by `pidfile()`.

- `rsync(src, dst, delete, *filter())`

  Very simple `rsync()` to copy files files and directories
  recursively.

- `tempfile()`

  Secure replacement for `tmpfile()`.  Creates an invisible temporary
  file in `/tmp` that is removed when the returned `FILE` pointer is
  closed.  **Note:** Requires Linux v3.11, or later.


OpenBSD Functions
-----------------

The following are the popular OpenBSD string functions.

- `pidfile(basename)`

  http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/pidfile.3

- `strlcpy(dst, src, len)`

  http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/strlcpy.3

- `strlcat(dst, src, len)`

  http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/strlcat.3

- `strtonum()`

  http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/strtonum.3

- `sys/queue.h` API

  http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/LIST_EMPTY.3


TODO
----

- Improve documentation, possibly use kdoc or gdoc2 to generate docs from API.
- Continuously, update OpenBSD functions/macros.

[1]: https://github.com/troglobit/finit
[2]: http://www.openbsd.org/
[3]: http://www.openbsd.org/cgi-bin/man.cgi?query=strlcpy
[4]: http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/LIST_EMPTY.3
[5]: https://developer.gnome.org/glib/
[6]: http://troglobit.com/blog/2015/07/02/howto-using-lite-with-a-git-based-application/
[MIT]: https://en.wikipedia.org/wiki/MIT_License
[ISC]: https://en.wikipedia.org/wiki/ISC_license
[BSD]: https://en.wikipedia.org/wiki/BSD_licenses


<!--
  -- Local Variables:
  -- mode: markdown
  -- End:
  -->
