import System.Environment
import System.Directory.Tree
import Control.Monad

main = do
  [a] <- getArgs
  z <- buildL a
  forM_ (foldMap (:[]) (dirTree z))
        print 

