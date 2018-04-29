{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric #-}


import Application.Data
import Application.Tree
import Application.PathComponent
import Application.Price
import Application.Score
import Application.CSVRecord
import Application.Bin
import Application.Config
import Application.FilePath    

import Control.Monad.Trans.Either
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy as LBS
import System.Directory.Tree
import Data.Csv
import qualified Data.Map as M

type ClosePrice = Price Double


type DataSample = Tree [PathComponent] ClosePrice


type Observed = DataSample
type Expected = DataSample
type Binned = M.Map Bin Observed
type Evaluated = M.Map Bin Score
type ScoreAsCSV = CSVRecord
type FPath = String
type OutputRecord = Rec


observed :: FilePth -> IO Expected
observed = undefined

binned :: FilePth -> IO Binned
binned = undefined

evaluate :: Expected -> Binned -> Evaluated
evaluate = undefined

(//) :: FilePth -> FilePth -> FilePth
(//) fp1 fp2 = (\a b -> a ++ "/" ++ b) <$> fp1 <*> fp2        


csvRecord :: FilePth -> Evaluated -> M.Map FilePth [CSVRecord]
csvRecord outputFp evaled = M.mapKeys toFname undefined -- (M.mapWithKey toCsvRecord evaled)
    where
      toFname bin = outputFp // fmap binToFname bin
          where
            binToFname (l, u) = l ++ "-" ++ u ++ ".csv"
      toCsvRecord = undefined

-- What happens to stuff like open file handles and all the other bits of global state left lying around?
writeRecord :: FileName -> [Rec] -> IO ()
writeRecord fname recs = do
  result <- LBS.writeFile fname (encode recs)
  putStrLn $ "Wrote csv records to " ++ fname ++ ": " ++ show result

abort :: (Show a) => a -> b
abort = error . show
        
main :: IO ()
main = do
  let config = mkCfg "/pfs/tickdata" "/pfs/out"
      Cfg inputRoot outputRoot = either (\_ -> error "Config check failed") id (dat config)
  expected <- observed inputRoot
  bins <- binned inputRoot
  let evaluated = evaluate expected bins
      recs = csvRecord outputRoot evaluated
      handleRecord fname csvrecs = writeRecord fname . either abort id . traverse dat $ csvrecs
  mapM_ (\(fpth, csvrecs) -> do
           fname <- eitherT abort pure (dat . unwrap $ fpth)
           handleRecord fname csvrecs)
        (M.toList recs)
        
