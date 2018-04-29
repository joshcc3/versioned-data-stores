module Application.Data where

type Err a = (String, a)
type Check a = a -> Either (Err a) a

data Data m a = Data { checks :: Check (m, a), metadata :: m, dat :: a }

noCheck = Right
