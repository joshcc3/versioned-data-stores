{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric #-}


import Application.Data
import Application.Tree
import Application.PathComponent
import Application.Price
import Application.Score
import Application.CSVRecord
import Application.Bin

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


observed :: String -> IO Expected
observed = undefined

binned :: String -> IO Binned
binned = undefined

evaluate :: Expected -> Binned -> Evaluated
evaluate = undefined

csvRecord :: Evaluated -> M.Map FileName [CSVRecord]
csvRecord = undefined


writeRecord :: FileName -> [Rec] -> IO ()
writeRecord = undefined


main :: IO ()
main = do
  let rootPath = "/pfs/tickdata"
  expected <- observed rootPath
  bins <- binned rootPath
  let evaluated = evaluate expected bins
      recs = csvRecord evaluated
  mapM_ (\(fname, csvrecs) -> writeRecord fname (map dat csvrecs)) (M.toList recs)
