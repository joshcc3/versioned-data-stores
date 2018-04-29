module Application.Price where

import Application.Data
import Data.Monoid


type Price a = SimpleData PriceMetadata a

mkPrice :: PriceMetadata -> Double -> Price Double
mkPrice m price = mkData checks m price
  where
    checks x@(m, a)
        | check (a >=) (fst (bound m))
          && check (a <=) (snd (bound m)) = Right x
        | otherwise = Left ("Price doesn't fall within expected bounds", show a) 
    check f = maybe True f

data PriceMetadata = PMetadata { source :: Maybe [String], bound :: Bounds Double, description :: Maybe [String] }

instance Monoid PriceMetadata where
    mempty = PMetadata Nothing (Nothing, Nothing) Nothing
    mappend (PMetadata s b d) (PMetadata s' b' d') = PMetadata (s <> s') (m b b') (d <> d')
        where
          m (x, y) (x', y') = (min x x', max y y')
                   
type Bounds a = (Maybe a, Maybe a) 
