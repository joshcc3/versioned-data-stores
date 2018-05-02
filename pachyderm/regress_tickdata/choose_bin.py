


type Parsed = FilePath -> IO CSVRecord
type Mp = CSVRecord -> M.Map String Score
type OutCSV = M.Map String Score -> CSVRecordOut




def parseRecords(filePath):
    assert isFile(filePath)
    with open(filePath, 'r') as f:
        rows = f.read().splitlines()
        assert len(rows) >= 1
    
    for row in rows:
        toks = ",".split(row)
        assert len(toks) == 4
        row



def parseRecordToMap(csvRecord):



def writeOutResult(resultMap):
















