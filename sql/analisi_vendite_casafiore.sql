/*
   Progetto: Analisi dei dati di vendita di un e-commerce con SQL
*/


/*
   FASE 1 - PREPARAZIONE DEL DATABASE
*/

-- Creiamo il database dove metteremo le nostre tabelle e i valori
CREATE DATABASE casafiore_shop;


/*
   FASE 2 - CREAZIONE DELLE TABELLE
*/

CREATE TABLE casafiore_shop.prodotto (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    prezzo DECIMAL(10, 2) NOT NULL
);

CREATE TABLE casafiore_shop.cliente (
    id INT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE casafiore_shop.ordini (
    id_prodotto INT,
    id_cliente INT,
    data DATE,
    FOREIGN KEY (id_prodotto) REFERENCES prodotto(id),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

/*
   FASE 3 - INSERIMENTO DEI DATI NELLE TABELLE
*/

-- Inserimento dei dati nella tabella 'prodotto'
INSERT INTO casafiore_shop.prodotto (id, nome, prezzo) VALUES
(1, 'Smartphone', 699.99),
(2, 'Laptop', 1099.99),
(3, 'Auricolari Bluetooth', 49.99),
(4, 'Monitor 4K', 299.99),
(5, 'Mouse Wireless', 19.99),
(6, 'Tastiera Meccanica', 89.99),
(7, 'Tablet', 499.99),
(8, 'Smartwatch', 199.99),
(9, 'Fotocamera DSLR', 799.99),
(10, 'Stampante', 129.99);

-- Inserimento dei dati nella tabella 'cliente'
INSERT INTO casafiore_shop.cliente (id, email) VALUES
(1, 'mario.rossi@example.com'),
(2, 'luigi.verdi@example.com'),
(3, 'anna.bianchi@example.com'),
(4, 'carla.neri@example.com'),
(5, 'giulia.ferri@example.com');

-- Inserimento dei dati nella tabella 'ordini'
INSERT INTO casafiore_shop.ordini (id_prodotto, id_cliente, data) VALUES
(1, 1, '2025-01-01'),
(2, 1, '2025-01-02'),
(3, 2, '2025-01-03'),
(4, 3, '2025-01-04'),
(5, 4, '2025-01-05'),
(6, 5, '2025-01-06'),
(7, 1, '2025-01-07'),
(8, 2, '2025-01-08'),
(9, 3, '2025-01-09'),
(10, 4, '2025-01-10'),
(1, 5, '2025-01-11'),
(2, 1, '2025-01-12'),
(3, 2, '2025-01-13'),
(4, 3, '2025-01-14'),
(5, 4, '2025-01-15'),
(6, 5, '2025-01-16'),
(7, 1, '2025-01-17'),
(8, 2, '2025-01-18'),
(9, 3, '2025-01-19'),
(10, 4, '2025-01-20');

-- Con queste query controlliamo che i dati siano stati aggiunti correttamente

SELECT * FROM casafiore_shop.prodotto;
SELECT * FROM casafiore_shop.cliente;
SELECT * FROM casafiore_shop.ordini;


/*
   FASE 4 - CREAZIONE DEL DATASET INTEGRATO
*/

/*
Adesso creeremo il dataset integrato 
La tabella ordini viene collegata alla tabella cliente tramite
id_cliente e alla tabella prodotto tramite id_prodotto.
*/

-- Con i select visualizziamo tutto il dataset integrato 
SELECT
    o.id_cliente,
    c.email AS email_cliente,
    o.id_prodotto,
    p.nome AS nome_prodotto,
    p.prezzo AS prezzo_prodotto,
    o.data AS data_ordine
-- Qui facciamo tutti i join che ci permettono di collegare le tabelle l'una con l'altra
-- Gli diamo degli alias facili da usare 
FROM casafiore_shop.ordini AS o
INNER JOIN casafiore_shop.cliente AS c
    ON o.id_cliente = c.id
INNER JOIN casafiore_shop.prodotto AS p
    ON o.id_prodotto = p.id
ORDER BY o.data;


/*
   FASE 5 - ANALISI DEI CLIENTI
*/

/*
Calcoliamo la spesa totale effettuata da ogni cliente
collegato alla propria e-mail.
Con Sum sommiamo il prezzo di tutti i prodotti acquistati
dal cliente, arrotondando con Round.
Con Count calcoliamo il numero di transazioni effettuate.
L'ordinamento decrescente permette di individuare subito
i clienti che hanno speso di più.
*/

SELECT
    c.id AS id_cliente,
    c.email AS email_cliente,
    COUNT(*) AS numero_acquisti,
    ROUND(SUM(p.prezzo), 2) AS spesa_totale
FROM casafiore_shop.cliente AS c
INNER JOIN casafiore_shop.ordini AS o
    ON c.id = o.id_cliente
INNER JOIN casafiore_shop.prodotto AS p
    ON o.id_prodotto = p.id
GROUP BY 1,2
ORDER BY spesa_totale DESC;

/*
   FASE 6 - ANALISI DEI PRODOTTI
*/

/*
Calcoliamo il fatturato totale generato da ogni prodotto.
Nella tabella ordini ogni riga rappresenta l'acquisto
di un prodotto, per calcolare il fatturato sommiamo il prezzo
del prodotto per ogni transazione.
Con Count indichiamo quante volte il prodotto è stato acquistato.
In questo modo vediamo il prodotto che ha fatturato di più dalla sua vendita.
*/

SELECT
    p.id AS id_prodotto,
    p.nome AS nome_prodotto,
    p.prezzo AS prezzo_unitario,
    COUNT(*) AS quantita_venduta,
    ROUND(SUM(p.prezzo), 2) AS fatturato_totale
FROM casafiore_shop.prodotto AS p
INNER JOIN casafiore_shop.ordini AS o
    ON p.id = o.id_prodotto
GROUP BY 1,2,3
ORDER BY fatturato_totale DESC;


/*
   FASE 7 - ANALISI TEMPORALE
*/

/*
Prima calcoliamo il fatturato totale di ogni singolo giorno.
Con DayName mettiamo il nome di ogni giorno della settimana 
*/

SELECT
    o.data AS data_ordine,
    DAYNAME(o.data) AS giorno_settimana,
    COUNT(*) AS numero_transazioni,
    ROUND(SUM(p.prezzo), 2) AS fatturato_giornaliero
FROM casafiore_shop.ordini AS o
INNER JOIN casafiore_shop.prodotto AS p
    ON o.id_prodotto = p.id
GROUP BY 1,2
ORDER BY o.data;

/*
Creiamo una tabella temporanea contenente il fatturato totale
in ogni singola data.
Con SUM sommiamo il prezzo dei prodotti venduti nella stessa data.
*/

CREATE TEMPORARY TABLE casafiore_shop.fatturato_giornaliero AS
SELECT
    o.data AS data_ordine,
    SUM(p.prezzo) AS fatturato_del_giorno
FROM casafiore_shop.ordini AS o
INNER JOIN casafiore_shop.prodotto AS p
    ON o.id_prodotto = p.id
GROUP BY 1;

/*
Calcoliamo il fatturato medio per ciascun giorno della settimana.
DAYNAME ci dà il giorno della settimana.
Con il Count indichiamo quante date del dataset appartengono a quel
giorno della settimana.
Con AVG calcoliamo la media di fatturato per ogni giorno.
Infine ordiniamo la tabella partendo dal giorno con fatturato 
medio più alto.
*/

SELECT
    DAYNAME(data_ordine) AS giorno_settimana,
    COUNT(*) AS numero_giornate,
    ROUND(AVG(fatturato_del_giorno), 2)
        AS fatturato_medio_giornaliero
FROM casafiore_shop.fatturato_giornaliero
GROUP BY 1
ORDER BY fatturato_medio_giornaliero DESC;

/*
   FASE 8 - ANALISI DEGLI ORDINI
*/

/*
Creiamo una tabella temporanea nella quale ogni transazione
viene considerata come un ordine.
ROW_NUMBER ci serve per assegnare un numero progressivo a ogni ordine.
La colonna numero_prodotti contiene il numero di prodotti
presenti nell'ordine. 
Però ogni riga della tabella ordini registra
l'acquisto di un prodotto, quindi il valore è pari a 1.
*/

CREATE TEMPORARY TABLE casafiore_shop.prodotti_per_ordine AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY o.data, o.id_cliente, o.id_prodotto
    ) AS id_ordine,
    o.id_cliente,
    o.data AS data_ordine,
    o.id_prodotto,
    1 AS numero_prodotti
FROM casafiore_shop.ordini AS o;

/*
Visualizziamo gli ordini e il relativo numero di prodotti.
*/

SELECT
    id_ordine,
    id_cliente,
    data_ordine,
    id_prodotto,
    numero_prodotti
FROM casafiore_shop.prodotti_per_ordine
ORDER BY id_ordine;

/*
Qui calcoliamo la media del numero di prodotti contenuti 
negli ordini, che in questo caso sarà 1.
*/

SELECT
    ROUND(AVG(numero_prodotti), 2)
        AS media_prodotti_per_ordine
FROM casafiore_shop.prodotti_per_ordine;

/*
Facendo la distribuzione vediamo quanti ordini contengono
un determinato numero di prodotti.
Il raggruppamento viene effettuato utilizzando numero_prodotti.
Contiamo con Count il numero di ordini presenti in ogni categoria.
*/

SELECT
    numero_prodotti,
    COUNT(*) AS numero_ordini
FROM casafiore_shop.prodotti_per_ordine
GROUP BY 1
ORDER BY numero_prodotti;


/*
   FASE 9 - CONCLUSIONE
*/

/*
Il progetto integra e analizza i dati relativi a clienti, 
prodotti e ordini. Ho individuato il cliente che spende di più, 
il prodotto best-seller, l'andamento delle vendite nella 
settimana e un analisi su ogni ordine eseguito. 
Il lavoro e le query, sono state organizzate per fase.
Ho utilizzato le tabelle temporanee per facilitare il lavoro senza
riempire il database con la creazione di tabelle vere.

*/
