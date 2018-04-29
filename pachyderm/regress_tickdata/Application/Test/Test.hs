module Application.Test.Test where

import Application.Data
import Application.PathComponent
import Application.Tree
import Application.Price
import Application.Main    
import Application.Bin

import qualified Data.Map as M    


nodePathPath1 = Node [mkPath "12" ()] [nodePath1]
nodePathPath2 = Node [mkPath "10" ()] [nodePath2, nodePath3]

nodePath1 = Node [mkPath "01" ()] [leafPath1]
nodePath2 = Node [mkPath "02" ()] [leafPath2, leafPath3]
nodePath3 = Node [mkPath "03" ()] [leafPath4]           
            
leafPath1 = Leaf [mkPath "SPX" ()] (mkPrice mempty 10)
leafPath2 = Leaf [mkPath "RUT" ()] (mkPrice mempty 100)
leafPath3 = Leaf [mkPath "SPX" ()] (mkPrice mempty 12)
leafPath4 = Leaf [mkPath "RUT" ()] (mkPrice mempty 30)

binned1 = M.fromList [(mkBin ("01", "02"), nodePathPath1)]
binned2 = M.fromList [(mkBin ("01", "02"), nodePathPath2)]          

test1 = M.toList $ evaluate nodePath1 binned1
test2 = M.toList $ evaluate nodePathPath2 binned2
test3 = M.toList $ evaluate nodePathPath1 binned2
