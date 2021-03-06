context("Stored procedure creation,exection,remove")
SERVER_ADDRESS <- "192.168.0.10"




get_connection <- 
  function(){
    url = "Server=%s;Database=TEST_RSQLSERVER;User Id=collateral;Password=Kollat;"   
    url <- sprintf(url,SERVER_ADDRESS)
    dbConnect('SqlServer',url=url)
  }

test_that("create and execute a stored procedure",{
  on.exit(dbDisconnect(conn))
  
 ## create proc
 lines = readLines('../resources/spSummaryProduct.sql')
 reqs <- split(lines,cumsum(lines =="GO"))
 stmt.remove <- paste(reqs[[1]],collapse='\n')
 stmt.create <- paste(reqs[[2]][-1],collapse='\n')
 ## create procedure
 conn <- get_connection()
 dbNonQuery(conn,stmt.remove)
 dbNonQuery(conn,stmt.create)
 ## create data 
 dat <- data.frame(value = sample(1:100,50,rep=TRUE))
 dbWriteTable(conn,'T_PRODUCT',dat,overwrite=TRUE)
 lapply(c('mean','sum','median'),function(x){
   db.value = dbCallProcedure(conn,"spSummaryProduct",x)
   r.value = do.call(x,list(dat$value))
   expect_equal (db.value,r.value)
 })
 dbRemoveTable(conn,'T_PRODUCT')
 rsqlserver:::dropProc(conn,'spSummaryProduct')
})