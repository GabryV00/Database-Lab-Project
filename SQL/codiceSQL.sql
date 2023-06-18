create table cliente(
  codicefiscalecliente char(16) primary key,
  nome varchar(50) not null,
  indirizzo varchar(80) not null,
  saldo integer not null);

create table fornitore(
  nome varchar(50) primary key,
  indirizzo varchar(80) not null,
  recapiti varchar(50) not null);

create table reparto(
  nome varchar(50),
  numero integer,
  numordini integer not null,
  cfcaporeparto char(16) unique,
  primary key (nome, numero));

create table dipendente(
  cf char(16) primary key,
  indirizzo varchar(80) not null,
  stipendio integer not null,
  infointeresse varchar(100),
  nomereparto varchar(50),
  numeroreparto integer,
  foreign key (nomereparto, numeroreparto) references reparto(nome, numero) on update cascade on delete no action);

alter table reparto
add constraint fk_rep
foreign key(cfcaporeparto) references dipendente on update cascade on delete no action deferrable initially deferred;


create table prodotto(
  codice integer primary key,
  nome varchar(50) not null,
  prezzovendita real not null,
  nomereparto varchar(50),
  numeroreparto integer,
  foreign key (nomereparto, numeroreparto) references reparto(nome, numero) on update cascade on delete no action);


create table ordinereparto(
  numeroordine integer,
  nomereparto varchar(50),
  numeroreparto integer,
  data date not null,
  nomefornitore varchar(50) references fornitore on update cascade on delete no action,
  codprodotto integer references prodotto on update cascade on delete no action,
  quantità integer not null,
  primary key(numeroordine, nomereparto, numeroreparto),
  foreign key (nomereparto, numeroreparto) references reparto(nome, numero) on update cascade on delete no action);

create table fornisce(
  codprodotto integer references prodotto on update cascade on delete no action,
  nomefornitore varchar(50) references fornitore on update cascade on delete no action,
  prezzoacquisto real not null,
  primary key (codprodotto, nomefornitore));

create table ordinecliente(
  numeroordine integer,
  cfcliente char(16) references cliente on update cascade on delete no action,
  data date not null,
  primary key (numeroordine, cfcliente));

create table riferimentocliente(
  numeroordinecliente integer,
  cfcliente char(16),
  codprodotto integer references prodotto on update cascade on delete no action,
  quantità integer not null,
  primary key (numeroordinecliente, cfcliente, codprodotto),
  foreign key (numeroordinecliente, cfcliente) references ordinecliente(numeroordine, cfcliente) on update cascade on delete no action);


create or replace function check_prodotti()
  returns trigger language plpgsql as
  $$
  declare
     numrep integer;
     nomerep varchar(50);
  begin
     select numeroreparto, nomereparto into numrep, nomerep from prodotto P
     where new.codprodotto = P.codice;

     if ((numrep != new.numeroreparto) or (nomerep != new.nomereparto)) then
        raise notice 'Prodotto venduto da un altro reparto: impossibile ordinarlo!';
        return null;
     end if;

     return new;
  end;
 $$;

create trigger controlla_ordini
  before insert or update on ordinereparto
  for each row
  execute procedure check_prodotti();


create or replace function check_dipendenti()
  returns trigger language plpgsql as
  $$
  declare
    numrep integer;
    nomerep varchar(50);
  begin
    select numeroreparto, nomereparto into numrep, nomerep from dipendente D
    where new.cfcaporeparto = D.cf;

    if ((numrep != new.numero) or (nomerep != new.nome)) then
        raise notice 'Questo dipendente afferisce ad un reparto diverso: non può fare il capo in questo reparto!';
        return null;
    end if;

    return new;
  end;
$$;

create trigger check_caporeparto
  before insert or update on reparto
  for each row
  execute procedure check_dipendenti();

create or replace function is_capo()
  returns trigger language plpgsql as
  $$
  declare
    num integer;
  begin
    select count(*) into num from reparto R
    where new.cf = R.cfcaporeparto;

    if (num > 0) then
        raise notice 'Questo dipendente non può cambiare reparto: è capo del reparto a cui afferisce!';
        return null;
    end if;

    return new;
  end;
$$;

create trigger check_reparto
  before update on dipendente
  for each row
  execute procedure is_capo();


create index indice_saldo on cliente using btree(
  saldo ASC
);
