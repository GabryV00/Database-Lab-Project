/*
OPERAZIONE: Mostra il numero di ordini per ogni reparto
*/

select nome, numero, numordini
from reparto
group by nome, numero

/*
OPERAZIONE: Mostra l'elenco dei prodotti in vendita, per ogni reparto
*/

select R.nome, R.numero, codice, P.nome
from prodotto P, reparto R
where P.nomereparto = R.nome and P.numeroreparto = R.numero
order by nomereparto, numeroreparto

/*
OPERAZIONE: Mostra la somma mensile spesa in stipendi per ogni reparto
*/

select nomereparto, numeroreparto, sum (stipendio)
from dipendente
group by nomereparto, numeroreparto


/*
OPERAZIONE: Mostra i clienti con saldo superiore a 50 euro
*/

select codicefiscalecliente, saldo
from cliente C
where C.saldo >= 50
