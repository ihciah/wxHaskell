module Main where


import Graphics.UI.WX
import Graphics.UI.WXCore

main 
  = do printDataSources 
       -- printInfo "pubs"
       -- printAuthorNames
       -- printTitlePrices

{----------------------------------------------------------
   Some queries on the "pubs" database
----------------------------------------------------------}
printAuthorNames
  = dbWithConnection "pubs" "" "" $ \db ->
    do names <- dbQuery db "SELECT au_fname, au_lname, contract FROM authors" 
                (\row -> do fname <- dbRowGetString row "au_fname"
                            lname <- dbRowGetString row "au_lname"
                            contr <- dbRowGetBool row "contract"
                            return (fname ++ " " ++ lname ++ (if contr then "" else " (no contract)")))
       putStrLn $ unlines names

printTitlePrices
  = dbWithConnection "pubs" "" "" $ \db ->
    do dbQuery_ db "SELECT title, price FROM titles" 
        (\row -> do title   <- dbRowGetString row "title"
                    mbprice <- dbRowGetIntegerMb row "price" 
                    -- print price nicely
                    info    <- dbRowGetColumnInfo row "price"
                    let prec   = columnDecimalDigits info
                        price  = case mbprice of
                                   Nothing -> "no price"
                                   Just p  -> let s = show p
                                              in "$" ++
                                                 reverse (drop prec (reverse s)) 
                                                 ++ "." ++ 
                                                 take 2 (reverse (take prec (reverse s)))
                    -- print fields
                    putStrLn (title ++ " (" ++ price ++ ")"))



{----------------------------------------------------------
   Print data sources
----------------------------------------------------------}
printDataSources :: IO ()
printDataSources
  = do srcs <- dbGetDataSources
       putStrLn "data sources:"
       putStrLn $ unlines $ [" " ++ adjust 25 name ++ ": " ++ desc | (name,desc) <- srcs]

adjust :: Int -> String -> String
adjust n s  | length s < n  = s ++ replicate (n - length s) ' '
            | otherwise     = s

{----------------------------------------------------------
   Print meta information about  a particular data source
----------------------------------------------------------}
printInfo :: DataSourceName -> IO ()
printInfo dbName
  = do info <- dbGetDataSourceInfo dbName "" ""
       print info
