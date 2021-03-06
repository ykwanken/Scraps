module Main where

import Control.Monad (forM_, liftM, when)
import System.Directory
import System.FilePath
import System.IO
import System.Process

main = do
	putStrLn "Starting..."
	root <- canonicalizePath "./"
	paths <- getRecursiveDirectories root (root </> "desktopMaster.ini")
	return()

safeOpenFile :: FilePath -> IOMode -> IO (Maybe Handle)
safeOpenFile file mode = do
	catch (Just `liftM` (openFile file mode)) (\e -> return Nothing)

getRecursiveDirectories :: FilePath -> FilePath -> IO ()
getRecursiveDirectories root iniMaster = do
	iniFile <- safeOpenFile (root </> "desktop.ini") ReadMode
	code <- (when (iniFile == Nothing) $ do
		system ("cp " ++ iniMaster ++ " " ++ root </> "desktop.ini")
		return ())
	names <- getDirectoryContents root
	let dirs = filter (`notElem` [".", ".."]) names
	forM_ dirs $ \f -> do
		let fullpath = root </> f
		let file = dropExtensions f
		isDir <- doesDirectoryExist fullpath
		if isDir
			then getRecursiveDirectories fullpath iniMaster
			else
				when (file == "Front" || file == "front") $ do
					system ("cp " ++ fullpath ++ " " ++ (root </> "Folder") ++ (takeExtensions f))
					return ()
	return ()

