module Data where

type Check a = a -> Either (Err (m, a)) a

data Data m a = Data { checks :: Check (m, a), metadata :: m, dat :: a }



