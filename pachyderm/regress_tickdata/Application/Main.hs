{-# LANGUAGE DeriveFunctor, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric #-}



import Application.CFlow
import Application.PathComponent
import Application.Price
import Application.Score
import Application.CSVRecord

import System.Directory.Tree
import Data.Csv

type ClosePrice = Price


type DataSample = Tree [PathComponent] ClosePrice


type Observed = DataSample
type Expected = DataSample
type Binned = Map Bin Observed
type Evaluated = Map Bin Score
type ScoreAsCSV = CSVRecord
type FPath = String
type OutputRecord = Rec


observed :: String -> IO Expected
observed = undefined

binned :: String -> IO Binned
binned = undefined

evaluate :: Expected -> Binned -> Evaluated
evaluate = undefined

csvRecord :: Evaluated -> Map FileName [CSVRecord]
csvRecord = undefined


writeRecord :: FileName -> [Rec] -> IO ()
writeRecord = undefined


main :: IO ()
main = do
  expected <- observed
  bins <- binned
  evaluated <- evaluate expected bins
  recs <- csvRecord evaluated
  mapM_ (M.toList recs) (\(fname, csvrecs) -> writeRecord fname (dat csvrecs))
