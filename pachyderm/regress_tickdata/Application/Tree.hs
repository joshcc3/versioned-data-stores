module Tree where


data Tree_ m a = Leaf m a | Node m [Tree_ m a] deriving (Functor)
type TreeMetadata = [String]
type Tree = Tree Metadata

instance Monoid m => Applicative (Tree m) where
    pure x = Leaf mempty x
    Leaf m f <*> Leaf m' a = Leaf (m <> m') (f a)
    Leaf m f <*> Node m' ts = Node (m <> m') (map (Leaf m f <*>) ts)
    Node m ts <*> Leaf m' a = Node (m <> m') (map (<*> Leaf m' a) ts)
    Node m ts <*> Node m' ts' = Node (m <> m') (zipWith (<*>) ts ts')

