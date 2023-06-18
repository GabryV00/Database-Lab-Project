library(DBI)
library(ggplot2)
library(chron)
library(lubridate, warn.conflicts = FALSE)

con <- dbConnect(RPostgres::Postgres(), dbname = 'GestoreMercato', host = 'localhost', port = 5432, user = 'postgres', password = 'admin')

dipendentiDaDB <- dbReadTable(con, 'dipendente')
repartiDaDB <- dbReadTable(con, 'reparto')
prodottiDaDB <- dbReadTable(con, 'prodotto')
ordineClienteDaDB <- dbReadTable(con, 'ordinecliente')
riferimentoClienteDaDB <- dbReadTable(con, 'riferimentocliente')

#Top10 Dipendenti più pagati

dipendentipiuPagati <- dipendentiDaDB[order(-dipendentiDaDB$stipendio),]
dipendentipiuPagati <- head(dipendentipiuPagati, 10)

ggplot(data = dipendentipiuPagati, aes(x=reorder(cf, -stipendio), y=stipendio)) + 
  geom_bar(stat="identity", aes(fill = stipendio)) + 
  scale_fill_gradient(low = "#0033FF", high = "#99FFFF") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) + 
  xlab("\nCF Dipendente") + 
  ylab("Stipendio\n") +
  scale_y_continuous(breaks = seq(from = 0, to = max(dipendentipiuPagati$stipendio + 100), by = 100), labels = seq(from = 0, to = max(dipendentipiuPagati$stipendio + 100), by = 100)) +
  guides(fill = guide_legend(title = "Stipendio")) +
  ggtitle("Top 10 Dipendenti più Pagati")

#Top10 Prodotti più venduti

occorenze <- table(unlist(riferimentoClienteDaDB$codprodotto))
occorenzeDataFrame <- data.frame(occorenze)
occorenzeDataFrame <- occorenzeDataFrame[order(-occorenzeDataFrame$Freq), ]
occorenzeDataFrame <- head(occorenzeDataFrame, 10)

maxOccorenzaProdotto <- max(occorenzeDataFrame$Freq)

ggplot(data = occorenzeDataFrame, aes(x = reorder(Var1, -Freq), y = Freq)) + 
  geom_bar(stat="identity", aes(fill = Freq)) + 
  scale_fill_gradient(low = "#FF9900", high = "#FFFF33", breaks = seq(from = 1, to = maxOccorenzaProdotto, by = 1), label = seq(from = 1, to = maxOccorenzaProdotto, by = 1)) +
  xlab("\nCodiceProdotto") + 
  ylab("Quanitità venduta\n") + 
  scale_y_continuous(breaks = c(1:(occorenzeDataFrame[[2]][1] + 1)), labels = c(1:(occorenzeDataFrame[[2]][1] + 1))) +
  guides(fill = guide_legend(title = "Quantità Venduta")) +
  ggtitle("Top 10 Prodotti più Venduti ai Clienti")

#Top10 Clienti con saldo maggiore

clientiSaldoMaggiore <- clientiDaDB[order(-clientiDaDB$saldo), ]

clientiSaldoMaggiore <- head(clientiSaldoMaggiore, 10)

ggplot(data = clientiSaldoMaggiore, aes(x = reorder(codicefiscalecliente, -saldo), y = saldo)) + 
  geom_bar(stat="identity",aes(fill =  saldo)) +
  scale_fill_gradient(low="#6600FF", high="#FF66CC") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  xlab("CF Cliente") + 
  ylab("Saldo") +
  scale_y_continuous(breaks = seq(from = 0, to = max(clientiSaldoMaggiore$saldo + 100), by = 100), labels = seq(from = 0, to = max(clientiSaldoMaggiore$saldo + 100), by = 100)) +
  guides(fill = guide_legend(title = "Saldo")) +
  ggtitle("Top 10 Clienti Aventi Saldo Maggiore")
  
#Numero Dipendenti per ciascun reparto

repartiDipendenti <- data.frame(reparto = c(paste(dipendentiDaDB$nomereparto, dipendentiDaDB$numeroreparto)))

counterRepartiDipendenti <- data.frame(reparto = c(paste(repartiDaDB$nome, repartiDaDB$numero)), numeroDipendenti = rep(0, nrow(repartiDaDB)))

for(i in c(1:nrow(dipendentiDaDB))){
  for(j in c(1:nrow(repartiDaDB))){
    if(counterRepartiDipendenti$reparto[j] == repartiDipendenti$reparto[i]){
      counterRepartiDipendenti$numeroDipendenti[j] <- counterRepartiDipendenti$numeroDipendenti[j] + 1
    }
  }
}

maxNumeroDipendenti <- max(counterRepartiDipendenti$numeroDipendenti)

ggplot(data = counterRepartiDipendenti, aes(x = reparto, y = numeroDipendenti)) + 
  geom_bar(stat = "identity", aes(fill = numeroDipendenti)) +
  scale_fill_gradient(low="#3300CC", high="#FFCC33", breaks = seq(from = 1, to = maxNumeroDipendenti, by = floor(maxNumeroDipendenti/4)), labels =  seq(from = 1, to = maxNumeroDipendenti, by = floor(maxNumeroDipendenti/4))) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  xlab("\nReparto") +
  ylab("Numero Dipendenti\n") + 
  scale_y_continuous(breaks = seq(from = 0, to = max(counterRepartiDipendenti$numeroDipendenti + 5), by = 1), labels = seq(from = 0, to = max(counterRepartiDipendenti$numeroDipendenti + 5), by = 1)) +
  guides(fill = guide_legend(title = "Reparto")) +
  ggtitle("Distribuzione Dipendenti nei Reparti")

#Top 10 Reparti che vendono più prodotti

prodottiReparti <- data.frame(reparto = c(paste(prodottiDaDB$nomereparto, prodottiDaDB$numeroreparto)))

distribuzioneProdotti <- data.frame(reparto = c(paste(repartiDaDB$nome, repartiDaDB$numero)), numeroProdottiVenduti = rep(0, nrow(repartiDaDB)))

for(i in c(1:nrow(prodottiDaDB))){
  for(j in c(1:nrow(distribuzioneProdotti))){
    if(distribuzioneProdotti[[1]][j] == prodottiReparti[[1]][i]){
      distribuzioneProdotti[[2]][j] <- distribuzioneProdotti[[2]][j] + 1
    }
  }
}

distribuzioneProdotti <- head(distribuzioneProdotti[order(-distribuzioneProdotti$numeroProdottiVenduti), ], 10)

maxProdottoVenduto <- max(distribuzioneProdotti$numeroProdottiVenduti)

ggplot(data = distribuzioneProdotti, aes(x = reorder(reparto, -numeroProdottiVenduti) , y = numeroProdottiVenduti)) + 
  geom_bar(stat = "identity", aes(fill=numeroProdottiVenduti)) + 
  scale_fill_gradient(low = "#336633", high = "#CCFF33") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  xlab("\nReparto") +
  ylab("Numero Prodotti\n")  + 
  scale_y_continuous(breaks = seq(from = 0, to = maxProdottoVenduto + 1, by = 2), labels = seq(from = 0, to = maxProdottoVenduto + 1, by = 2)) +
  guides(fill = guide_legend(title = "Numero Prodotti Venduti")) +
  ggtitle("Top 10 Reparti che vendono più Tipi di Prodotti")

# Numero Prodotti venduti in ciascuna settimana

date <- data.frame(data = ordineClienteDaDB[[3]])

dataMax <- date[[1]][1]
dataMin <- date[[1]][1]
for(i in c(2:nrow(date))){
  if(dataMax < date[[1]][i]){
    dataMax <- date[[1]][i]
  }
  if(dataMin > date[[1]][i]){
    dataMin <- date[[1]][i]
  }
}


primoLunedi <- function(x) 7 * floor(as.numeric(x-1+4)/7) + as.Date(1-4, origin="1970-01-01")
startDate <- floor_date(as.Date(dataMin, "%Y/%m/%d"), unit="week") + 1

numeroSettimane <- ceiling(julian(dataMax, primoLunedi(startDate))/7)
vettoreSettimane <- rep(0, numeroSettimane[1])

startSettimane <- rep(startDate, numeroSettimane)
endSettimane <- rep(startDate + 6, numeroSettimane)

for(i in c(2:numeroSettimane)){
  startSettimane[i] <- startSettimane[i - 1] + 7
  endSettimane[i] <- endSettimane[i - 1] + 7
}

contatoreSettimana <- c(numeroSettimana = rep(0, nrow(ordineClienteDaDB)))

for(i in c(1:nrow(ordineClienteDaDB))){
  for(j in c(1:numeroSettimane)){
    if((ordineClienteDaDB[[3]][i] >= startSettimane[j]) & (ordineClienteDaDB[[3]][i] <= endSettimane[j])){
      contatoreSettimana[i] <- j
      break
    }
  }
}

sommaSettimane <- data.frame(numeroVenditeSettimana = rep(0, numeroSettimane))

for(i in c(1:nrow(ordineClienteDaDB))){
  sommaSettimane[[1]][contatoreSettimana[i]] <- sommaSettimane[[1]][contatoreSettimana[i]] + 1
}


ggplot(data = sommaSettimane, aes(x = c(1 : numeroSettimane), y = numeroVenditeSettimana)) + 
  geom_bar(stat = "identity", aes(fill = numeroVenditeSettimana)) +
  scale_fill_gradient(low = "#663300", high = "#FFFF00") +
  xlab("\nNumero Settimana") + 
  ylab("Numero Prodotti Venduti\n") + 
  scale_x_continuous(breaks = c(1:numeroSettimane), labels = c(1:numeroSettimane)) +
  scale_y_continuous(breaks = seq(from = 0, to = max(sommaSettimane), by = 10), labels = seq(from = 0, to = max(sommaSettimane), by = 10)) +
  guides(fill = guide_legend(title = "Numero Vendite Settimanali")) +
  ggtitle("Numero Prodotti Venduti in Ciascuna Settimana")
  


ggplot(data = sommaSettimane, mapping = aes(x = c(1:numeroSettimane), y = numeroVenditeSettimana, group = 1)) + 
  geom_line(color = "red") + 
  geom_point() +
  xlab("\nNumero Settimana") + 
  ylab("Vendite ai Clienti\n") +
  scale_x_continuous(breaks = c(1:numeroSettimane), labels = c(1:numeroSettimane)) +
  scale_y_continuous(breaks = seq(from = 0, to = max(sommaSettimane), by = 10), labels = seq(from = 0, to = max(sommaSettimane), by = 10)) +
  ggtitle("Numero Prodotti Venduti in Ciascuna Settimana")
     
dbDisconnect(con)
