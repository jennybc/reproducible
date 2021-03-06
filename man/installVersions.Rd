% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/packages.R
\name{installVersions}
\alias{installVersions}
\title{Install exact package versions from a package version text file & GitHub}
\usage{
installVersions(gitHubPackages,
  packageVersionFile = ".packageVersions.txt",
  libPath = .libPaths()[1], standAlone = FALSE,
  repos = getOption("repos")["CRAN"])
}
\arguments{
\item{gitHubPackages}{Character vectors indicating repository/packageName@branch}

\item{packageVersionFile}{Path to the package version file, defaults to
       the \file{.packageVersions.txt}.

This uses CRAN, CRAN archives, or MRAN (accessed via \code{versions::install.versions})
for remote repositories.
This will attempt to install all packages in the \code{packageVersionFile},
with their exact version described in that file. For GitHub packages, it will
use \code{\link[remotes]{install_github}}. This will be called internally by
\code{Require}, and so often doesn't need to be used by a user.

Because of potential conflicts with loaded packages, this function will run
\code{install.packages} in a separate R process.}

\item{libPath}{The library path where all packages should be installed, and looked for to load
(i.e., call \code{library})}

\item{standAlone}{Logical. If \code{TRUE}, all packages will be installed and loaded strictly
from the \code{libPaths} only. If \code{FALSE}, all \code{.libPaths} will
be used to find the correct versions. This can be create dramatically faster
installs if the user has a substantial number of the packages already in their
personal library. In the case of \code{TRUE}, there will be a hidden file
place in the \code{libPath} directory that lists all the packages
that were needed during the \code{Require} call. Default \code{FALSE} to
minimize package installing.}

\item{repos}{The remote repository (e.g., a CRAN mirror), passed to either
\code{install.packages}, \code{install_github} or \code{installVersions}.}
}
\description{
Install exact package versions from a package version text file & GitHub
}
\examples{
\dontrun{
# requires the packageVersionFile -- this doesn't work -- safer to use Require
installVersions("PredictiveEcology/reproducible@development")

# make a package version snapshot -- this will be empty because no packages in directory
tempPkgFolder <- file.path(tempdir(), "Packages")
dir.create(tempPkgFolder)
packageVersionFile <- file.path(tempPkgFolder, ".packageVersion.txt")
pkgSnapshot(libPath = tempPkgFolder, packageVersionFile)

Require("crayon", libPath = tempPkgFolder) # install.packages first, then library

# install a specific version
# make a package version snapshot
packageVersionFile <- file.path(tempPkgFolder, ".packageVersion.txt")
pkgSnapshot(libPath=tempPkgFolder, packageVersionFile, standAlone = FALSE)

installVersions("crayon", packageVersionFile = packageVersionFile)

}
}
