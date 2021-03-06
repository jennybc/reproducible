% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache-tools.R
\docType{methods}
\name{clearCache}
\alias{clearCache}
\alias{clearCache,ANY-method}
\alias{cc}
\alias{showCache}
\alias{showCache,ANY-method}
\alias{keepCache}
\alias{keepCache,ANY-method}
\title{Examining and modifying the cache}
\usage{
clearCache(x, userTags = character(), after, before,
  ask = getOption("reproducible.ask"), useCloud = FALSE,
  cloudFolderID = NULL, ...)

\S4method{clearCache}{ANY}(x, userTags = character(), after, before,
  ask = getOption("reproducible.ask"), useCloud = FALSE,
  cloudFolderID = getOption("reproducible.cloudFolderID", NULL), ...)

cc(secs, ...)

showCache(x, userTags = character(), after, before, ...)

\S4method{showCache}{ANY}(x, userTags = character(), after, before, ...)

keepCache(x, userTags = character(), after, before,
  ask = getOption("reproducible.ask"), ...)

\S4method{keepCache}{ANY}(x, userTags = character(), after, before,
  ask = getOption("reproducible.ask"), ...)
}
\arguments{
\item{x}{A simList or a directory containing a valid archivist repository. Note:
For compatibility with \code{Cache} argument, \code{cacheRepo} can also be
used instead of \code{x}, though \code{x} will take precedence.}

\item{userTags}{Character vector. If used, this will be used in place of the
\code{after} and \code{before}.
Specifying one or more \code{userTag} here will clear all
objects that match those tags.
Matching is via regular expression, meaning partial matches
will work unless strict beginning (^) and end ($) of string
characters are used.
Matching will be against any of the 3 columns returned by \code{showCache()},
i.e., \code{artifact}, \code{tagValue} or \code{tagName}.
Also, length \code{userTags} > 1, then matching is by `and`.
For `or` matching, use \code{|} in a single character string.
See examples.}

\item{after}{A time (POSIX, character understandable by data.table).
Objects cached after this time will be shown or deleted.}

\item{before}{A time (POSIX, character understandable by data.table).
Objects cached before this time will be shown or deleted.}

\item{ask}{Logical. If \code{FALSE}, then it will not ask to confirm deletions using
\code{clearCache} or \code{keepCache}. Default is \code{TRUE}}

\item{useCloud}{Logical. If \code{TRUE}, then every object that is deleted locally will
also be deleted in the \code{cloudFolderID}, if it is non-\code{NULL}}

\item{cloudFolderID}{A googledrive id of a folder, e.g., using \code{drive_mkdir()}. If
left as \code{NULL}, the function will create a cloud folder with a warning. The warning
will have the cloudFolderID that should be used in subsequent calls. It will also be
added to options("reproducible.cloudFolderID"), but this will not persist across sessions.}

\item{...}{Other arguments. Currently, \code{regexp}, a logical, can be provided.
This must be \code{TRUE} if the use is passing a regular expression.
Otherwise, \code{userTags} will need to be exact matches. Default is
missing, which is the same as \code{TRUE}. If there are errors due
to regular expression problem, try \code{FALSE}. For \code{cc}, it is
passed to \code{clearCache}, e.g., \code{ask}, \code{userTags}}

\item{secs}{Currently 3 options: the number of seconds to pass to \code{clearCache(after = secs)},
a \code{POSIXct} time e.g., from \code{Sys.time()}, or missing. If missing,
        the default, then it will delete the most recent entry in the Cache.}
}
\value{
Will clear all objects (or those that match \code{userTags}, or those
between \code{after} or \code{before}) from the repository located at
\code{cachePath} of the sim object, if \code{sim} is provided, or located in
\code{cacheRepo}.
Invisibly returns a \code{data.table} of the removed items.
}
\description{
These are convenience wrappers around \code{archivist} package functions.
They allow the user a bit of control over what is being cached.
}
\details{
If neither \code{after} or \code{before} are provided, nor \code{userTags},
then all objects will be removed.
If both \code{after} and \code{before} are specified, then all objects between
\code{after} and \code{before} will be deleted.
If \code{userTags} is used, this will override \code{after} or \code{before}.

\code{cc(secs)} is just a shortcut for \code{clearCache(repo = Paths$cachePath, after = secs)},
i.e., to remove any cache entries touched in the last \code{secs} seconds.

\describe{
  \item{\code{clearCache}}{remove items from the cache based on their
                           \code{userTag} or \code{times} values.}
  \item{\code{keepCache}}{remove all cached items \emph{except} those based on
                          certain \code{userTags} or \code{times} values.}
  \item{\code{showCache}}{display the contents of the cache.}
}
}
\note{
If the cache is larger than 10MB, and clearCache is used, there will be
a message and a pause, if interactive, to prevent accidentally deleting of a
large cache repository.
}
\examples{
library(raster)

tmpDir <- file.path(tempdir(), "reproducible_examples", "Cache")
try(clearCache(tmpDir, ask = FALSE), silent = TRUE) # just to make sure it is clear

# Basic use
ranNumsA <- Cache(rnorm, 10, 16, cacheRepo = tmpDir)

# All same
ranNumsB <- Cache(rnorm, 10, 16, cacheRepo = tmpDir) # recovers cached copy
ranNumsC <- Cache(cacheRepo = tmpDir) \%C\% rnorm(10, 16)  # recovers cached copy
ranNumsD <- Cache(quote(rnorm(n = 10, 16)), cacheRepo = tmpDir) # recovers cached copy

# Any minor change makes it different
ranNumsE <- Cache(cacheRepo = tmpDir) \%C\% rnorm(10, 6)# different

## Example 1: basic cache use with tags
ranNumsA <- Cache(rnorm, 4, cacheRepo = tmpDir, userTags = "objectName:a")
ranNumsB <- Cache(runif, 4, cacheRepo = tmpDir, userTags = "objectName:b")
ranNumsC <- Cache(runif, 40, cacheRepo = tmpDir, userTags = "objectName:b")

showCache(tmpDir, userTags = c("objectName"))
showCache(tmpDir, userTags = c("^a$")) # regular expression ... "a" exactly

# Fine control of cache elements -- pick out only the large runif object, and remove it
cache1 <- showCache(tmpDir, userTags = c("runif")) # show only cached objects made during runif
toRemove <- cache1[tagKey=="object.size"][as.numeric(tagValue) > 700]$artifact
clearCache(tmpDir, userTags = toRemove, ask = FALSE)
cacheAfter <- showCache(tmpDir, userTags = c("runif")) # Only the small one is left

tmpDir <- file.path(tempdir(), "reproducible_examples", "Cache")
try(clearCache(tmpDir, ask = FALSE), silent = TRUE) # just to make sure it is clear

Cache(rnorm, 1, cacheRepo = tmpDir)
thisTime <- Sys.time()
Cache(rnorm, 2, cacheRepo = tmpDir)
Cache(rnorm, 3, cacheRepo = tmpDir)
Cache(rnorm, 4, cacheRepo = tmpDir)
showCache(x = tmpDir) # shows all 4 entries
cc(ask = FALSE, x = tmpDir)
showCache(x = tmpDir) # most recent is gone
cc(thisTime, ask = FALSE, x = tmpDir)
showCache(x = tmpDir) # all those after thisTime gone, i.e., only 1 left
cc(ask = FALSE, x = tmpDir) # Cache is
cc(ask = FALSE, x = tmpDir) # Cache is already empty
}
\seealso{
\code{\link{mergeCache}}, \code{\link[archivist]{splitTagsLocal}}. Many more examples
in \code{\link{Cache}}
}
