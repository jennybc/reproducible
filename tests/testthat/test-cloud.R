test_that("test Cache(useCloud=TRUE, ...)", {
  if (interactive()) {
    testInitOut <- testInit(c("googledrive", "raster"), tmpFileExt = c(".tif", ".grd"),
                            opts = list("reproducible.cachePath" = file.path(tempdir(), rndstr(1, 7)),
                                        "reproducible.ask" = FALSE))
    on.exit({
      testOnExit(testInitOut)
      retry(drive_rm(as_id(newDir$id)))
    }, add = TRUE)
    clearCache(x = tmpCache)
    newDir <- retry(drive_mkdir("testFolder"))
    cloudFolderID = newDir$id
    #######################################
    # local absent, cloud absent
    #######################################
    mess1 <- capture_messages(a1 <- Cache(rnorm, 1, cloudFolderID = cloudFolderID,
                                         cacheRepo = tmpCache, useCloud = TRUE))
    expect_true(any(grepl("uploaded", mess1)))

    #######################################
    # local present, cloud present
    #######################################
    mess2 <- capture_messages(a1 <- Cache(rnorm, 1, cloudFolderID = cloudFolderID,
                                         cacheRepo = tmpCache, useCloud = TRUE))
    expect_true(grepl("loading cached", mess2))
    expect_false(grepl("uploaded", mess2))
    expect_false(grepl("download", mess2))

    #######################################
    # local absent, cloud present
    #######################################
    clearCache(userTags = .robustDigest(1), x = tmpCache)
    mess3 <- capture_messages(a1 <- Cache(rnorm, 1, cloudFolderID = cloudFolderID,
                                          cacheRepo = tmpCache, useCloud = TRUE))
    expect_false(any(grepl("loading cached", mess3)))
    expect_false(any(grepl("uploaded", mess3)))
    expect_true(any(grepl("download", mess3)))

    #######################################
    # local present, cloud absent
    #######################################
    clearCache(x = tmpCache, useCloud = TRUE, cloudFolderID = cloudFolderID)
    a1 <- Cache(rnorm, 2, cloudFolderID = cloudFolderID, cacheRepo = tmpCache)
    mess4 <- capture_messages(a2 <- Cache(rnorm, 2, cloudFolderID = cloudFolderID,
                                          cacheRepo = tmpCache, useCloud = TRUE))

    expect_true(any(grepl("loading cached", mess4)))
    expect_true(any(grepl("uploaded", mess4)))
    expect_false(any(grepl("download", mess4)))

    #######################################
    # cloudFolderID missing
    #######################################
    clearCache(x = tmpCache, useCloud = TRUE, cloudFolderID = cloudFolderID)

    opts <- options("reproducible.cloudFolderID" = NULL)
    warn5 <- capture_warnings(
      mess5 <- capture_messages(
        a2 <- Cache(rnorm, 3, cacheRepo = tmpCache, useCloud = TRUE)))

    expect_true(any(grepl("Folder created", mess5)))
    expect_true(any(grepl("Uploading", mess5)))
    expect_false(any(grepl("download", mess5)))
    expect_true(any(grepl("No cloudFolderID", warn5)))

    warn6 <- capture_warnings(
      mess6 <- capture_messages(
        a2 <- Cache(rnorm, 3, cacheRepo = tmpCache, useCloud = TRUE)))

    expect_false(any(grepl("Folder created", mess6)))
    expect_false(any(grepl("Uploading", mess6)))
    expect_false(any(grepl("download", mess6)))
    expect_true(any(grepl("loading cached", mess6)))
    expect_true(isTRUE(all.equal(length(warn6), 0)))

    ########
    clearCache(x = tmpCache, useCloud = TRUE, cloudFolderID = cloudFolderID)
    # Add 3 things to cloud and local -- then clear them all
    for (i in 1:3)
      a1 <- Cache(rnorm, i, cloudFolderID = cloudFolderID, cacheRepo = tmpCache, useCloud = TRUE)
    expect_silent(mess1 <- capture_messages(clearCache(x = tmpCache, useCloud = TRUE, cloudFolderID = cloudFolderID)))
    expect_true(NROW(drive_ls(path = as_id(cloudFolderID)))==0)

    # Add 3 things to local, only 2 to cloud -- clear them all, without an error
    for (i in 1:2)
      a1 <- Cache(rnorm, i, cloudFolderID = cloudFolderID, cacheRepo = tmpCache, useCloud = TRUE)
    a1 <- Cache(rnorm, 3, cloudFolderID = cloudFolderID, cacheRepo = tmpCache, useCloud = FALSE)
    expect_silent(mess2 <- capture_messages(clearCache(x = tmpCache, useCloud = TRUE, cloudFolderID = cloudFolderID)))
    expect_true(NROW(drive_ls(path = as_id(cloudFolderID)))==0)

    # Add 2 things to local, only 1 to cloud -- clear them all, without an error
    Cache(rnorm, 1, cloudFolderID = cloudFolderID, cacheRepo = tmpCache, useCloud = TRUE)
    Cache(rnorm, 2, cloudFolderID = cloudFolderID, cacheRepo = tmpCache, useCloud = TRUE)
    expect_silent(mess2 <- capture_messages(clearCache(x = tmpCache, userTags = .robustDigest(1), useCloud = TRUE, cloudFolderID = cloudFolderID)))

    expect_true(NROW(drive_ls(path = as_id(cloudFolderID)))==1)

  }
})


test_that("test Cache(useCloud=TRUE, ...) with raster-backed objs -- tif and grd", {
  if (interactive()) {
    testInitOut <- testInit(c("googledrive", "raster"), tmpFileExt = c(".tif", ".grd"),
                            opts = list("reproducible.ask" = FALSE))

    opts <- options("reproducible.cachePath" = tmpdir)
    suppressWarnings(rm(list = "aaa", envir = .GlobalEnv))
    on.exit({
      testOnExit(testInitOut)
      retry(drive_rm(as_id(newDir$id)))
      options(opts)
    }, add = TRUE)
    clearCache(x = tmpdir)
    newDir <- retry(drive_mkdir("testFolder"))
    cloudFolderID = newDir$id

    testRasterInCloud(".tif", cloudFolderID = cloudFolderID, numRasterFiles = 1, tmpdir = tmpdir,
                      type = "Raster")

    retry(drive_rm(as_id(newDir$id)))
    clearCache(x = tmpdir)
    newDir <- retry(drive_mkdir("testFolder"))
    cloudFolderID = newDir$id

    testRasterInCloud(".grd", cloudFolderID = cloudFolderID, numRasterFiles = 2, tmpdir = tmpdir,
                      type = "Raster")

  }
})

test_that("test Cache(useCloud=TRUE, ...) with raster-backed objs -- stack", {
  if (interactive()) {
    testInitOut <- testInit(c("googledrive", "raster"), tmpFileExt = c(".tif", ".grd"),
                            opts = list("reproducible.ask" = FALSE))

    opts <- options("reproducible.cachePath" = tmpdir)
    suppressWarnings(rm(list = "aaa", envir = .GlobalEnv))
    on.exit({
      testOnExit(testInitOut)
      retry(drive_rm(as_id(newDir$id)))
      options(opts)
    }, add = TRUE)
    clearCache(x = tmpdir)
    newDir <- retry(drive_mkdir("testFolder"))
    cloudFolderID = newDir$id

    testRasterInCloud(".tif", cloudFolderID = cloudFolderID, numRasterFiles = 2, tmpdir = tmpdir,
                      type = "Stack")

  }
})

test_that("test Cache(useCloud=TRUE, ...) with raster-backed objs -- brick", {
  if (interactive()) {
    testInitOut <- testInit(c("googledrive", "raster"), tmpFileExt = c(".tif", ".grd"),
                            opts = list("reproducible.ask" = FALSE))

    opts <- options("reproducible.cachePath" = tmpdir)
    suppressWarnings(rm(list = "aaa", envir = .GlobalEnv))
    on.exit({
      testOnExit(testInitOut)
      retry(drive_rm(as_id(newDir$id)))
      options(opts)
    }, add = TRUE)
    clearCache(x = tmpdir)
    newDir <- retry(drive_mkdir("testFolder"))
    cloudFolderID = newDir$id

    testRasterInCloud(".tif", cloudFolderID = cloudFolderID, numRasterFiles = 1, tmpdir = tmpdir,
                      type = "Brick")

  }
})


test_that("Filenames for environment", {
    testInitOut <- testInit(c("raster"), tmpFileExt = c(".tif", ".grd", ".tif", ".tif", ".grd"),
                            opts = list("reproducible.ask" = FALSE))

    on.exit({
      testOnExit(testInitOut)
      options(opts)
      rm(s)
    }, add = TRUE)

    s <- new.env(parent = emptyenv())
    s$r <- raster(extent(0,10,0,10), vals = 1, res = 1)
    s$r2 <- raster(extent(0,10,0,10), vals = 1, res = 1)
    s$r <- writeRaster(s$r, filename = tmpfile[1], overwrite = TRUE)
    s$r2 <- writeRaster(s$r2, filename = tmpfile[3], overwrite = TRUE)
    s$s <- stack(s$r, s$r2)
    s$b <- writeRaster(s$s, filename = tmpfile[5], overwrite = TRUE)

    Fns <- Filenames(s)

    expect_true(identical(Fns$b, filename(s$b)))
    expect_true(identical(Fns$r, filename(s$r)))
    expect_true(identical(Fns$r2, filename(s$r2)))
    expect_true(identical(Fns$s, sapply(seq_len(nlayers(s$s)), function(rInd) filename(s$s[[rInd]]))))

    FnsR <- Filenames(s$r)
    expect_true(identical(FnsR, filename(s$r)))

    FnsS <- Filenames(s$s)
    expect_true(identical(FnsS, sapply(seq_len(nlayers(s$s)), function(rInd) filename(s$s[[rInd]]))))

    FnsB <- Filenames(s$b)
    expect_true(identical(FnsB, filename(s$b)))

})

