# Guida alla configurazione — Casafiore Shop SQL

## Requisiti

- **MySQL 8.0 o superiore** (server) — lo script usa funzioni di MySQL (`DAYNAME`) e la funzione finestra `ROW_NUMBER()`
- Un client per eseguire lo script: **MySQL Workbench** (consigliato per vedere i risultati) oppure la riga di comando `mysql`

Non serve installare altro.

## 1. Scarica il progetto

```bash
git clone https://github.com/FilloFerro05/casafiore-sales-analysis-sql.git
cd casafiore-sales-analysis-sql
```

In alternativa scarica lo ZIP da GitHub (**Code → Download ZIP**) e decomprimilo.

## 2. Esegui lo script

### Opzione A — MySQL Workbench (consigliata)

1. Apri MySQL Workbench e collegati al tuo server (di solito `localhost`).
2. Menu **File → Open SQL Script** e scegli `sql/analisi_vendite_casafiore.sql`.
3. Premi l'icona del **fulmine** per eseguire tutto lo script.
4. Il risultato di ogni `SELECT` compare in una scheda nel pannello **Result**, in basso: scorri tra le schede per vedere i risultati di ciascuna fase.

> Lo script crea database, tabelle e dati, quindi **non serve preparare nulla prima**.

### Opzione B — Riga di comando

```bash
mysql -u <utente> -p < sql/analisi_vendite_casafiore.sql
```

(`<utente>` è il tuo utente MySQL, ad esempio `root`; senza parentesi). Vengono eseguite tutte le query in sequenza, ma i risultati sono poco leggibili: per leggerli meglio usa Workbench, oppure apri il client con `mysql -u <utente> -p` ed esegui il file con `source sql/analisi_vendite_casafiore.sql`.

## 3. Eseguire solo una parte

Il file è diviso in fasi. Per rieseguire una sola analisi in Workbench, seleziona il blocco di query (ad esempio la fase 5) ed esegui solo la selezione (**Ctrl+Shift+Invio**).

**Attenzione:** le fasi 7 e 8 creano **tabelle temporanee** (`fatturato_giornaliero`, `prodotti_per_ordine`) che esistono solo nella sessione corrente. Le query che le usano vanno eseguite nella stessa sessione, dopo la `CREATE TEMPORARY TABLE` corrispondente.

## 4. Rieseguire lo script da zero

`CREATE DATABASE` dà errore se il database esiste già. Per ripartire da zero:

```sql
DROP DATABASE casafiore_shop;
```

e poi rilancia lo script.

## 5. Risultati attesi

Se tutto è andato bene, controlla questi valori:

| Controllo | Valore atteso |
|-----------|---------------|
| Righe in `prodotto`, `cliente`, `ordini` | 10, 5, 20 |
| Righe del dataset integrato (fase 4) | 20 |
| Cliente che spende di più (fase 5) | `mario.rossi@example.com`, 5 acquisti, 3.899,95 € |
| Prodotto con più fatturato (fase 6) | Laptop, 2 vendite, 2.199,98 € |
| Giorno con la media più alta (fase 7) | Thursday, 663,32 € |
| Media prodotti per ordine (fase 8) | 1,00 |

## 6. Personalizzazione

- **Giorni della settimana in italiano:** prima della query della fase 7 aggiungi `SET lc_time_names = 'it_IT';`
- **Nuovi dati:** aggiungi righe agli `INSERT` della fase 3 (rispettando le chiavi esterne: il prodotto e il cliente devono esistere).

## Problemi comuni

| Problema | Soluzione |
|----------|-----------|
| `Can't create database 'casafiore_shop'; database exists` | Il database esiste già: `DROP DATABASE casafiore_shop;` e rilancia lo script |
| `ERROR 1064` (errore di sintassi) sulla query con `ROW_NUMBER() OVER` della fase 8 | La versione di MySQL è troppo vecchia (le funzioni finestra richiedono la 8.0+): controlla la versione con `SELECT VERSION();` e aggiorna il server |
| `Table 'casafiore_shop.fatturato_giornaliero' doesn't exist` | La tabella temporanea è sparita perché la sessione si è chiusa: riesegui la `CREATE TEMPORARY TABLE` della fase 7 nella stessa sessione |
| `ERROR 1045: Access denied` | Utente o password sbagliati: controlla le credenziali del server |
| `ERROR 1044` / `1142 ... command denied` | L'utente non ha il permesso di creare database o tabelle: usa un utente con i privilegi necessari (ad esempio `root` in locale) |
| I nomi dei giorni sono in inglese | È il comportamento di default di `DAYNAME`: vedi "Personalizzazione" |
