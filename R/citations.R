#' Citation frequency distribution
#'
#' It calculates frequency distribution of citations.
#'
#' @param M is a bibliographic data frame obtained by the converting function \code{\link{convert2df}}.
#'        It is a data matrix with cases corresponding to manuscripts and variables to Field Tag in the original SCOPUS and Thomson Reuters' ISI Web of Knowledge file.
#' @param field is a character. It can be "article" or "author" to obtain frequency distribution of cited citations or cited authors (only first authors for ISI database) respectively. The default is \code{field = "article"}.
#' @param sep is the field separator character. This character separates citations in each string of CR column of the bibiographic data frame. The default is \code{sep = ";"}.
#' @return an object of \code{class} "list"  containing the following components:
#'
#' \tabular{lll}{
#' Cited \tab  \tab the most frequent cited manuscripts or authors\cr
#' Year \tab       \tab the pubblication year (only for cited article analysis)\cr
#' Source \tab      \tab the journal (only for cited article analysis)}
#'
#' 
#'
#' @examples
#' ## EXAMPLE 1: Cited articles
#' 
#' data(scientometrics)
#'
#' CR <- citations(scientometrics, field = "article", sep = ";")
#'
#' CR$Cited[1:10]
#' CR$Year[1:10]
#' CR$Source[1:10]
#'
#' ## EXAMPLE 2: Cited first authors
#' 
#' data(scientometrics)
#'
#' CR <- citations(scientometrics, field = "author", sep = ";")
#'
#' CR$Cited[1:10]
#'
#' @seealso \code{\link{biblioAnalysis}} function for bibliometric analysis.
#' @seealso \code{\link{summary}} to obtain a summary of the results.
#' @seealso \code{\link{plot}} to draw some useful plots of the results.
#'
#' @export

citations <- function(M, field = "article", sep = ";"){
  CR=NULL
  Year=NULL
  SO=NULL
  
  if (field=="article"){
    listCR=strsplit(M$CR,sep)
    listCR=lapply(listCR, function(l){
      l=l[grep(",",l)]
      })
  }
  
  if (field=="author"){
    listCR=strsplit(M$CR,sep)
    if (M$DB[1]=="ISI"){ 
      listCR=lapply(listCR, function(l){
        ListL=lapply(strsplit(unlist(l),","),function(x) x[1])
        l=unlist(ListL)
      })}
    if (M$DB[1]=="SCOPUS"){ 
      listCR=lapply(listCR, function(l){
        ListL=lapply(l,function(x) {
          a=strsplit(x,"\\., ")
          ind=which(grepl("[[:digit:]]", a[[1]]))
          if (length(ind)==0) ind=1
          x=unlist(a[[1]][1:(ind[1]-1)])
        })
        l=unlist(ListL)
      })}
  }
  CR=unlist(listCR)
  #CR=gsub("\\.","",CR)
  CR=CR[nchar(CR)>=3]
  CR=trim.leading(CR)
  CR=sort(table(CR),decreasing=TRUE)
  if (field=="article"){
    listCR=strsplit(rownames(CR),",")
    Year=unlist(lapply(listCR, function(l){
      if (length(l)>1){
      l=suppressWarnings(as.numeric(l[2]))} else{l=NA}
      }))
    SO=unlist(lapply(listCR, function(l){
      if (length(l)>2){
      l=l[3]} else{l=NA}
    }))
    SO=trim.leading(SO)
  }
  CR=list(Cited=CR,Year=Year,Source=SO)
  return(CR)
}