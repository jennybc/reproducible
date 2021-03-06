% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache-helpers.R
\docType{methods}
\name{Copy}
\alias{Copy}
\alias{Copy,ANY-method}
\alias{Copy,data.table-method}
\alias{Copy,environment-method}
\alias{Copy,list-method}
\alias{Copy,data.frame-method}
\alias{Copy,Raster-method}
\title{Recursive copying of nested environments, and other "hard to copy" objects}
\usage{
Copy(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{ANY}(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{data.table}(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{environment}(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{list}(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{data.frame}(object, filebackedDir = tempdir(), ...)

\S4method{Copy}{Raster}(object, filebackedDir = tempdir(), ...)
}
\arguments{
\item{object}{An R object (likely containing environments) or an environment.}

\item{filebackedDir}{A directory to copy any files that are backing R objects,
currently only valid for \code{Raster} classes. Defaults
to \code{tempdir()}, which is unlikely to be very useful.}

\item{...}{Only used for custom Methods}
}
\description{
When copying environments and all the objects contained within them, there are
no copies made: it is a pass-by-reference operation. Sometimes, a deep copy is
needed, and sometimes, this must be recursive (i.e., environments inside
environments).
}
\examples{
e <- new.env()
e$abc <- letters
e$one <- 1L
e$lst <- list(W = 1:10, X = runif(10), Y = rnorm(10), Z = LETTERS[1:10])
ls(e)

# 'normal' copy
f <- e
ls(f)
f$one
f$one <- 2L
f$one
e$one ## uh oh, e has changed!

# deep copy
e$one <- 1L
g <- Copy(e)
ls(g)
g$one
g$one <- 3L
g$one
f$one
e$one

}
\seealso{
\code{\link{.robustDigest}}
}
\author{
Eliot McIntire
}
