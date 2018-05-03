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
import System.Directory
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
    
type BinnedScores = M.Map Key Score    
    
type Parse = FilePth -> IO (List Score)
type ScoreKey = Score -> Key
type Scored = List (M.Map Key Score) -> BinnedScores
type Result = BinnedScores -> List CSVRecordResult

binned :: List Score -> List (M.Map Key Score)
binned scores = do
  scz <- scores
  ks <- mkSizeBoundedList (==length scz) (map scoreKey scz)
  return . map (M.fromList . (:[])) $ zip ks scz
  
  

main = do
  as <- getArgs >>= either abort pure . dat . mkArgs
  let config = mkCfg (as !! 0) (as !! 1)
      Cfg inputRoot outputRoot = either (\_ -> error "Config check failed") id (dat config)
  fpth <- getFilePathFromDat inputRoot
  dirContents <- listDirectory fpth
  let fs = map (mkFPathFile . ((fpth ++ "/") ++)) dirContents
  scoreLists <- traverse parse fs
  ofile <- getFilePathFromDat outputRoot
  let resCSV :: [FinalRec]
      resCSV = map (either abort id . dat) . either abort id . dat . result . scored . binned . fmap concat . traverse id $ scoreLists
  LBS.writeFile (ofile ++ "/output.csv") (encode resCSV)
  

parse :: Parse
parse fpth = do
  let expectedFname x = mkData expectedFname_ () x
      expectedFname_ x =  case (reverse . takeWhile (/= '/') . reverse . snd $ x) of
                          (_:_:'-':_:_:".csv") -> right x
                          x -> left ("Binned fname did not match expected", x)
  fname <- eitherT abort pure . dat $ unwrap fpth >>= expectedFname
  fcontent <- BS.readFile fname
  let recs :: V.Vector Rec
      recs = either abort id . decode NoHeader $ LBS.fromStrict fcontent
      toScore :: Rec -> Score
      toScore = toScore_ . either abort id . dat . mkCSVRecord
      toScore_ (Rec u s e v) = mkScoreM (SMeta (mkUnderlier u) (Just (mkBin (s, e)))) v
  return . mkSizeBoundedList (>= 1) . map toScore . V.toList $ recs


scoreKey :: ScoreKey
scoreKey = Score.underlier . metadata

scored :: Scored
scored = foldl (M.unionWith unioner) M.empty . simpleDat
    where
      unioner l m = do
        s1 <- l
        s2 <- m
        if s1 < s2
        then l
        else m

         
result :: Result
result mp = mkNonEmptyList . map f  $ M.toList mp
    where
      f (_, s) = either abort id . dat $ do
                   let meta = metadata s
                   u <- Score.underlier $ meta
                   let Just b = scoreBin meta
                   (b1, b2) <- b
                   return $ mkCSVRecord (FinalRec u b1 b2)


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
      check (_, as) = Left ("You must supply 2 arguments: the input root,  output root", show as)
