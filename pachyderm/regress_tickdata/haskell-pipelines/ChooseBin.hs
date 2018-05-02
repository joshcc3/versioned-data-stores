{-# LANGUAGE TypeSynonymInstances #-}

import System.Directory.Tree
import Util
import Application.Data
import Application.CSVRecord
import Application.Data
import Application.Tree
import Application.PathComponent
import Application.Price
import qualified Application.Score as Score
import Application.CSVRecord
import Application.Bin
import Application.FilePath    
import Application.List
import Util
import Application.Score


import qualified Data.Set as S
import System.Environment
import Control.Monad.Trans
import Control.Monad
import Data.Monoid
import qualified Control.Exception as E
import qualified Data.Semigroup as S
import Control.Monad.Trans.Either
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString as BS    
import System.Directory.Tree
import Data.Csv
import qualified Data.Map as M


type Key = SimpleData () String    
type CSVRecordResult = ()
instance ToRecord CSVRecordResult
instance FromRecord CSVRecordResult    
    
type BinnedScores = M.Map Key Score    
    
type Parse = FilePth -> IO (List Score)
type ScoreKey = Score -> Key
type Scored = List (M.Map Key Score) -> BinnedScores
type Result = BinnedScores -> List CSVRecordResult

binned :: List Score -> List (M.Map Key Score)
binned scores = do
  scz <- scores
  let 
      unique ks =
        fmap S.toList $ foldl (\a b -> do
                        s <- a
                        if S.member b s
                        then Left ("Keys contain duplicate Elements", show ks)
                        else Right (S.insert b s)
                        )
                (Right S.empty)
                ks
  ks <- mkListWithChecks [unique] (map scoreKey scz)
  return . map (M.fromList . (:[])) $ zip ks scz
  
  

main = do
  as <- getArgs >>= either abort pure . dat . mkArgs
  let config = mkCfg (as !! 0) (as !! 1)
      Cfg inputRoot outputRoot = either (\_ -> error "Config check failed") id (dat config)
  let ofile = ""
  scoreList <- parse undefined
  let resCSV :: [CSVRecordResult]
      resCSV = either abort id . dat . result . scored . binned $ scoreList
  LBS.writeFile ofile (encode resCSV)
  

parse :: Parse
parse fpth = do
  let expectedFname x = mkData (expectedFname_ . reverse . takeWhile (/= '/') . reverse . snd) () x
      expectedFname_ x@(_:_:'-':_:_:".csv") = right ((), x)
      expectedFname_ x = left ("Binned fname did not match expected", x)
  fname <- eitherT abort pure . dat $ unwrap fpth >>= expectedFname
  fcontent <- BS.readFile fname
  let recs :: V.Vector ()
      recs = either abort id . decode HasHeader $ LBS.fromStrict fcontent
      binInf = toBinInfo fname
      toBinInfo = undefined
      toScore = undefined
  return . mkNonEmptyList . map (toScore binInf) . V.toList $ recs



scoreKey :: ScoreKey
scoreKey = undefined

scored :: Scored
scored = undefined
         
result :: Result
result = undefined





data Cfg = Cfg { inputRoot :: FilePth, outputRoot :: FilePth } deriving (Eq, Ord, Show)

type Config = SimpleData () Cfg

    
mkCfg :: String -> String -> Config
mkCfg inp out = mkData check () (Cfg (mkNonEmptyFPath inp) (mkEmptyFPath out))
    where
      check x@(_, Cfg a c)
            | a /= c = Right x
            | otherwise = Left ("A pair(s) for the provided roots were duplicated", show x)

type Args = SimpleData () [String]
data As = Args { arg1 :: String, arg3 :: String }

mkArgs :: [String] -> Args
mkArgs = mkData check ()
    where
      check (m, x@[_, _]) = Right (m, x)
      check (_, as) = Left ("You must supply 3 arguments: the binned tickdata root, the expected outcome data root, evaluation output root", show as)
         
