module Application.Price where

import Application.Data

type Price a = SimpleData PriceMetadata a

mkPrice :: PriceMetadata -> Double -> Price Double
mkPrice m price = mkData checks m price
  where
    checks x@(m, a)
        | check (a >=) (fst (bound m))
          && check (a <=) (snd (bound m)) = Right x
        | otherwise = Left ("Price doesn't fall within expected bounds", a) 
    check f = maybe True f

data PriceMetadata = PMetadata { source :: Maybe String, bound :: Bounds Double, description :: Maybe String }

type Bounds a = (Maybe a, Maybe a)
