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



