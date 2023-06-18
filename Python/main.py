#------Import------#
import datetime

import pandas as pd
import random as rd
import csv
from faker import Faker
from collections import defaultdict
import string

#------End Import------#


#------Setup------#

numeroClienti = 100
numeroOrdiniClienti = 1000
numeroProdotti = 300
numeroFornitori = 40
numeroReparti = 20
numeroOrdiniReparti = 2000
numeroDipendenti = 100
dataInizioVitaDB = datetime.date(2022, 1, 1)
dataFinePopolamentoDB = datetime.date(2022, 3, 13)

fake = Faker('en_US')
fakeITA = Faker("it_IT")
Faker.seed(0)
rd.seed(0)

#------End Setup------#


#------Funzioni------#

def standardizzazionePrezzo(prezzo):
    prezzo = str(prezzo)
    if('.' in prezzo):
        diff = len(prezzo) - prezzo.index('.')
        if(diff < 3):
            prezzo = prezzo + "0"
    else:
        prezzo = prezzo + ".00"
    return prezzo

def sceltaProdotto(indiceReparto):
    prodottiDelReparto = []
    for j in range(0, numeroProdotti):
        if((prodotti[j][3] == reparti[indiceReparto][0]) and (prodotti[j][4] == reparti[indiceReparto][1])):
            prodottiDelReparto.append(prodotti[j][0])
    if(len(prodottiDelReparto) > 0):
        return int(prodottiDelReparto[rd.randint(0, len(prodottiDelReparto) - 1)])
    else:
        return -1

def popolamentoTabella(nomeFile, nomeTabella, popolazione, numeroParametri, parametri):
    for i in range(0, popolazione):
        nomeFile.write("INSERT INTO " + nomeTabella + " values (")
        for j in range(0, numeroParametri):
            if(type(parametri[i][j]) is str):
                nomeFile.write("'" + parametri[i][j] + "'")
            else:
                if (((nomeTabella == "prodotto") and (j == 2)) or((nomeTabella == "fornitore") and (j == 1))):  # Sentinella per la visualizzazione del parametro prezzo della tabella "prodotto" sottoforma di numero con due cifre decimali
                    nomeFile.write(str(standardizzazionePrezzo(parametri[i][j])))
                else:
                    nomeFile.write(str(parametri[i][j]))
            if (j < numeroParametri - 1):
                nomeFile.write(", ")
        nomeFile.write(");\n")
    nomeFile.write("\n")

#------End Funzioni------#


#-------Reparti-------#

file = open("Reparti.csv")
csvreader = csv.reader(file)
header = next(csvreader)

repartiDaFile = []
for row in csvreader:
    repartiDaFile.append(row)

for i in range(0, numeroReparti):
    repartiDaFile[i] = str(str(repartiDaFile[i]).replace('[\'', '')).replace('\']', '')

reparti = [["0" for x in range(0, 4)] for y in range(0, numeroReparti)]
counter = 0

for i in range(0, numeroReparti):
    numeroReparto = 1
    for k in range(0, counter):
        if(reparti[k][0] == repartiDaFile[i]):
            numeroReparto += 1
    reparti[counter][0] = str(repartiDaFile[i])
    reparti[counter][1] = numeroReparto
    counter = counter + 1
    reparti[i][2] = 0

#------End Reparti------#


#------Persona------#

clienti = [["0" for x in range(0, 4)] for y in range(0, numeroClienti)]

for i in range(0, numeroClienti):
    clienti[i][0] = ''.join(rd.choices(string.ascii_uppercase + string.digits, k = 16))
    clienti[i][1] = str(fake.name())
    clienti[i][2] = str(fake.street_address())
    clienti[i][3] = rd.choice(range(0, 1000))

dipendenti = [["0" for x in range(0, 7)] for y in range(0, numeroDipendenti)] #range(0,7) poichè la colonna 7 è utile per identificare lo stato di capo-reparto

for i in range(0, numeroDipendenti):
    dipendenti[i][0] = ''.join(rd.choices(string.ascii_uppercase + string.digits, k = 16))
    dipendenti[i][1] = str(fake.street_address())
    dipendenti[i][2] = rd.choice(range(1000, 1800))
    dipendenti[i][3] = " "
    reparto = rd.choice(range(0, 19))
    dipendenti[i][4] = reparti[reparto][0]
    dipendenti[i][5] = reparti[reparto][1]
    dipendenti[i][6] = 'False'

#------End Persona------#


#------CapoReparto------#
for i in range (0, numeroReparti):
    for j in range(0, numeroDipendenti):
        if((reparti[i][3] == '0') and (reparti[i][0] == dipendenti[j][4]) and (reparti[i][1] == dipendenti[j][5])):
                reparti[i][3] = dipendenti[j][0]
                dipendenti[j][6] = 'True'

#Modifica il reparto di afferenza di un dipendente al fine di avere almeno un dipendente che operi in almeno un reparto
for i in range (0, numeroReparti):
    j = 0
    while(reparti[i][3] == '0'):
        if(dipendenti[j][6] == 'False'):
            dipendenti[j][4] = reparti[i][0]
            dipendenti[j][5] = reparti[i][1]
            dipendenti[j][6] = 'True'
            reparti[i][3] = dipendenti[j][0]
        j = j + 1

#------End CapoReparto------#


#------Fornitore------#

fornitori = [["0" for x in range(0, 3)] for y in range(0, numeroFornitori)]

prefissoITA = "+39 "

for i in range(0, numeroFornitori):
    fornitori[i][0] = fake.unique.company()
    fornitori[i][1] = fake.unique.street_address()
    numeroTelefono = fakeITA.unique.phone_number()
    if(prefissoITA in str(numeroTelefono)):
        numeroTelefono = numeroTelefono.replace(prefissoITA, "")
    fornitori[i][2] = numeroTelefono

#------End Fornitore------#


#------Prodotti------#

#Prodotto(CodProdotto, Nome, PrezzoVendita, NomeReparto, Numero Reparto)

file = open("Prodotti.csv")
csvreader = csv.reader(file)
header = next(csvreader)

prodottiDaFile = []
counter = 0

for row in csvreader:
    prodottiDaFile.append(row)
    prodottiDaFile[counter] = str(prodottiDaFile[counter]).replace('[\'', '').replace('\']', '')
    counter += 1
file.close()

prodotti = [["0" for x in range(0, 5)] for y in range(numeroProdotti)]
#Possibilità di creare un array di numeri da 1 a numeroProdotti e ogni qualvolta assegno uno di questi numeri, lo rimuovo dall'array
#Questo per randomizzare anche i codici prodotti, nota che se fai questa modifica, devi moificare l'ordine reparti,
# nella parte di assegnamento dei prodotti

for i in range(0, numeroProdotti):
    prodotti[i][0] = i + 1
    prodotti[i][1] = prodottiDaFile[i]
    prodotti[i][2] = round(rd.uniform(0.50, 10.00), 2)
    indiceRandom = rd.randrange(0, numeroReparti - 1)
    if(i < numeroReparti):
        indiceRandom = i
    prodotti[i][3] = reparti[indiceRandom][0]
    prodotti[i][4] = reparti[indiceRandom][1]

#------End Prodotti------#


#------Fornisce------#

fornisceFornitore_Prodotto = [["0" for x in range(0, 3)] for y in range(numeroProdotti)]

for i in range(0, numeroProdotti):
    fornisceFornitore_Prodotto[i][0] = prodotti[i][0]
    indiceRandom = rd.randrange(0, numeroFornitori - 1)
    fornisceFornitore_Prodotto[i][1] = fornitori[indiceRandom][0]
    fornisceFornitore_Prodotto[i][2] = round(rd.uniform(0.50, float(prodotti[i][2])), 2)

#------End Fornisce------#


#------OrdineCliente------#

ordiniClienti = [["0" for x in range(0, 3)] for y in range(numeroOrdiniClienti)]
frequenzaClienteOrdine = [0 for x in range(0, numeroClienti)]

for i in range(0, numeroOrdiniClienti):
    if(i < numeroClienti): #Questa sentinella è posta al fine di avere almeno un ordine per ciascun cliente
        frequenzaClienteOrdine[i] += 1
        ordiniClienti[i][0] = frequenzaClienteOrdine[i]
        ordiniClienti[i][1] = clienti[i][0]
        ordiniClienti[i][2] = str(fake.date_between(dataInizioVitaDB, dataFinePopolamentoDB))
    else:
        indiceRandom = rd.randint(0, numeroClienti - 1)
        frequenzaClienteOrdine[indiceRandom] += 1
        ordiniClienti[i][0] = frequenzaClienteOrdine[indiceRandom]
        ordiniClienti[i][1] = clienti[indiceRandom][0]
        ordiniClienti[i][2] = str(fake.date_between(dataInizioVitaDB, dataFinePopolamentoDB))


#------End OrdineCliente------#


#------RiferimentoOrdineCliente------#

riferimentoOrdineCliente = [["0" for x in range(0, 4)] for y in range(numeroOrdiniClienti)]

for i in range(0, numeroOrdiniClienti):
    riferimentoOrdineCliente[i][0] = ordiniClienti[i][0]
    riferimentoOrdineCliente[i][1] = ordiniClienti[i][1]
    riferimentoOrdineCliente[i][2] = prodotti[rd.randint(0, numeroProdotti - 1)][0]
    riferimentoOrdineCliente[i][3] = rd.randint(1, 5)

#------End RiferimentoOrdineCliente------#


#------RiferimentoOrdineReparto------#

#OrdineReparto(NumeroOrdineReparto, NomeReparto, NumeroReparto, Data, Quantit`a, NomeFornitore, CodProdotto)

riferimentoOrdineReparto = [["0" for x in range(0, 7)] for y in range(numeroOrdiniReparti)]
frequenzaOrdiniReparto = [0 for x in range(0, numeroReparti)]

for i in range(0, numeroOrdiniReparti):

    while True:
        indiceRandom = rd.randint(0, numeroReparti - 1)
        prodottoScelto = sceltaProdotto(indiceRandom)
        if (not(prodottoScelto == -1)):
            break

    riferimentoOrdineReparto[i][1] = reparti[indiceRandom][0]
    riferimentoOrdineReparto[i][2] = reparti[indiceRandom][1]
    frequenzaOrdiniReparto[indiceRandom] += 1
    riferimentoOrdineReparto[i][0] = frequenzaOrdiniReparto[indiceRandom]
    riferimentoOrdineReparto[i][3] = str(fake.date_between(dataInizioVitaDB, dataFinePopolamentoDB))
    riferimentoOrdineReparto[i][4] = fornisceFornitore_Prodotto[prodottoScelto - 1][1]  #Perchè -1? perchè dal metodo scelta prodotto ottengo non l'indice ma bensi' il codiceProdotto
    riferimentoOrdineReparto[i][5] = prodotti[prodottoScelto - 1][0]
    riferimentoOrdineReparto[i][6] = rd.randint(10, 100)

    #Già che ci sono riempio la colonna numeroOrdini della matrice reparti
    reparti[indiceRandom][2] += 1


#------End RiferimentoOrdineReparto------#


#------Scrittura su file------#
f = open("PopolamentoInizialeTabelle.sql", 'w')

popolamentoTabella(f, "cliente", numeroClienti, 4, clienti)
popolamentoTabella(f, "fornitore", numeroFornitori, 3, fornitori)
popolamentoTabella(f, "reparto", numeroReparti, 3, reparti)  #numero parametri non e' 4, in quanto il caporeparto va inserto solo in un secondo momento
popolamentoTabella(f, "dipendente", numeroDipendenti, 6, dipendenti)

for i in range(0, numeroReparti):
    f.write("UPDATE reparto SET cfcaporeparto=\'" + reparti[i][3] + "\' WHERE nome=\'" + reparti[i][0] + "\' AND numero=" + str(reparti[i][1]) + ";\n")
f.write("\n")

popolamentoTabella(f, "prodotto", numeroProdotti, 5, prodotti)
popolamentoTabella(f, "ordinereparto", numeroOrdiniReparti, 7, riferimentoOrdineReparto)
popolamentoTabella(f, "fornisce", numeroProdotti, 3, fornisceFornitore_Prodotto)
popolamentoTabella(f, "ordinecliente", numeroOrdiniClienti, 3, ordiniClienti)
popolamentoTabella(f, "riferimentocliente", numeroOrdiniClienti, 4, riferimentoOrdineCliente)

f.close()

#------End ScritturaFile------#

