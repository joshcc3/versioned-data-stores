{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveFunctor #-}
module Application.Tree where

import Control.Comonad
import Control.Applicative
import Data.Monoid

data Tree m a = Leaf m a | Node m [Tree m a] deriving (Functor, Foldable, Traversable)


instance Monoid m => Applicative (Tree m) where
    pure x = Leaf mempty x
    Leaf m f <*> Leaf m' a = Leaf (m <> m') (f a)
    Leaf m f <*> Node m' ts = Node (m <> m') (map (Leaf m f <*>) ts)
    Node m ts <*> Leaf m' a = Node (m <> m') (map (<*> Leaf m' a) ts)
    Node m ts <*> Node m' ts' = Node (m <> m') (zipWith (<*>) ts ts')

instance Monoid m => Monad (Tree m) where
    return x = Leaf mempty x
               
    Leaf m x >>= f = f x
    Node m ls >>= f = Node m (map (>>= f) ls)
    
