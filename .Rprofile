sqlite <- function(dbname){
    if (require("RSQLite")) {
        return(dbConnect(RSQLite::SQLite(), dbname=dbname))
    }
}

sahibinden <- function(link){
    con = sqlite("~/work/projects/sahibinden/sahibinden.db")
    return(dbGetQuery(con, sprintf(
        "SELECT b.name, s.name, m.name, m2.name, year, km, color, price, currency, city
        FROM car AS c
        JOIN brand AS b ON c.brand=b.id
        JOIN series AS s ON c.series=s.id
        JOIN model AS m ON c.model=m.id
        LEFT JOIN model2 AS m2 ON c.model2=m2.id
        WHERE '%s' IN (b.link, s.link, m.link, m2.link)", link)))
}

