-- 1.Názvy niektorých obcí v tabuľke obec sa opakujú, pretože na Slovensku existujú obce,
--   ktoré majú rovnaký názov. Zistite: a.koľko je takých obcí (1 dopyt)
--                                      b.ktorý názov obce je použitý najviac (1 dopyt)

--a
SELECT COUNT(*) AS pocet
FROM (SELECT nazov, COUNT(nazov) AS pocet FROM obec
GROUP BY nazov
HAVING COUNT(nazov) > 1) AS obec1;

--b
--Cez limit
SELECT nazov, (COUNT(nazov)) AS pocet FROM obec
GROUP BY nazov
ORDER BY pocet DESC
LIMIT 2;

--Cez vnoreny select
-- SELECT nazov, COUNT(nazov) AS pocet FROM obec
-- GROUP BY nazov
-- HAVING COUNT(nazov) = (
--     SELECT MAX(COUNT(nazov)) AS pocet FROM obec
--     GROUP BY nazov
--     );

-- 2. Koľko okresov sa nachádza v košickom kraji?

SELECT COUNT(o.nazov) FROM okres o
INNER JOIN kraj k
ON o.id_kraj = k.id
WHERE k.nazov = 'Kosicky kraj';

-- 3.A koľko má košický kraj obcí? Pri tvorbe dopytu vám môže pomôcť informácia,
--   že trenčiansky kraj má spolu 276 obcí.

SELECT COUNT(*) FROM obec ob
INNER JOIN okres ok
ON ob.id_okres = ok.id
INNER JOIN kraj k
ON ok.id_kraj = k.id
WHERE k.nazov = 'Kosicky kraj';

-- 4. Zistite, ktorá obec (mesto) bola na Slovensku najväčšia v roku 2012.
--     Pri tvorbe dopytu vám môže pomôcť informácia, že táto obec (mesto)
--     bola najväčšia na Slovensku v rokoch 2009-2012, avšak má v populácii klesajúcu tendenciu.
--     Vo výsledku vypíšte jej názov a počet obyvateľov.

SELECT o.nazov, (p.muzi + p.zeny) AS pocet_obyvatelov FROM obec o
INNER JOIN populacia p
ON o.id = p.id_obec
WHERE p.rok = '2012'
ORDER BY pocet_obyvatelov DESC
LIMIT 1;

-- 5.Koľko obyvateľov mal okres Sabinov v roku 2012?
--     Pri tvorbe dopytu vám môže pomôcť informácia,
--     že okres Dolný Kubín mal v roku 2010 39553 obyvateľov.

SELECT  SUM(p.muzi + p.zeny) AS pocet_obyvatelov FROM obec o
INNER JOIN populacia p
ON o.id = p.id_obec
INNER JOIN okres ok
ON o.id_okres = ok.id
WHERE p.rok = '2012' AND ok.nazov = 'Sabinov';

-- 6.Ako sme na tom na Slovensku? Vymierame alebo rastieme?
-- Zobrazte trend vývoja populácie za jednotlivé roky a výsledok
-- zobrazte od najnovších informácií po najstaršie.

SELECT p.rok, SUM(p.muzi + p.zeny) AS pocet_obyvatelov FROM populacia p
GROUP BY p.rok
ORDER BY rok DESC;

-- 7. Zistite, ktorá obec alebo obce boli najmenšie v okrese Tvrdošín v roku 2011.
--     Pri tvorbe dopytu vám môže pomôcť informácia, že v okrese Ružomberok to bola
--     v roku 2012 obec Potok s počtom obyvateľov 107.

SELECT o.nazov, (p.muzi + p.zeny) AS pocet_obyvatelov FROM populacia p
INNER JOIN obec o
ON p.id_obec = o.id
INNER JOIN okres ok
ON o.id_okres = ok.id AND ok.nazov = 'Tvrdosin'
WHERE p.rok = '2011' AND (p.muzi + p.zeny) = (
    SELECT min(p.muzi + p.zeny) FROM populacia p
    INNER JOIN obec o
    ON p.id_obec = o.id
    INNER JOIN okres ok
    ON o.id_okres = ok.id AND ok.nazov = 'Tvrdosin'
    WHERE p.rok = '2011'
    );

-- 8.Zistite všetky obce (ich názvy), ktoré mali v roku 2010 počet obyvateľov do 5000.
--   Pri tvorbe dopytu vám môže pomôcť informácia, že v roku 2009 bolo týchto obcí o 1 viac ako v roku 2010.

SELECT o.nazov, (p.muzi + p.zeny) AS pocet_obyvatelov FROM obec o
INNER JOIN populacia p
ON o.id = p.id_obec
WHERE p.rok = 2010 AND (p.muzi + p.zeny) < 5000
ORDER BY pocet_obyvatelov ASC;

-- 9.Zistite 10 obcí s populáciou nad 20000, ktoré mali v roku 2012 najväčší pomer žien
--     voči mužom (viac žien v obci ako mužov). Týchto 10 obcí vypíšte v poradí od najväčšieho
--     pomeru po najmenší. Vo výsledku okrem názvu obce vypíšte aj pomer zaokrúhlený na 4 desatinné miesta.
--     Pri tvorbe dopytu vám môže pomôcť informácia, že v roku 2011 bol tento pomer
--     pre obec Košice  - Juh 1,1673.

SELECT O.nazov, TRUNC(((p.zeny*1.0)/p.muzi),4) AS pomer FROM obec o
INNER JOIN populacia p
ON o.id = p.id_obec
WHERE (p.muzi + p.zeny) > 20000
AND p.rok = '2012'
ORDER BY pomer DESC
LIMIT 10;

-- 10.Vypíšte sumárne informácie o stave Slovenska v roku 2012 v podobe tabuľky,
--    ktorá bude obsahovať pre každý kraj informácie o počte obyvateľov, o počte obcí a počte okresov.

SELECT k.nazov, SUM(p.muzi + p.zeny) AS pocet_obyvatelov,
       COUNT(ob.nazov) AS pocet_obci,
       COUNT(DISTINCT ok.nazov) AS pocet_okresov
FROM kraj k
INNER JOIN okres ok
ON k.id = ok.id_kraj
INNER JOIN obec ob
ON ok.id = ob.id_okres
INNER JOIN populacia p
ON ob.id = p.id_obec AND p.rok = '2012'
GROUP BY k.nazov
ORDER BY pocet_obyvatelov DESC;

-- 11.To, či vymierame alebo rastieme, sme už zisťovali. Ale ktoré obce sú na tom naozaj zle?
--     Kde by sa nad touto otázkou mali naozaj zamyslieť? Zobrazte obce, ktoré majú klesajúci
--     trend (rozdiel v populácii dvoch posledných rokov je menší ako 0) - vypíšte ich názov,
--     počet obyvateľov v poslednom roku, počet obyvateľov v predchádzajúcom roku a rozdiel v
--     populácii posledného oproti predchádzajúcemu roku. Zoznam utrieďte vzostupne podľa tohto
--     rozdielu od obcí s najmenším prírastkom obyvateľov po najväčší.

SELECT o.nazov,
       p1.rok,
       (p1.muzi + p1.zeny) AS pocet_obyvatelov_2012,
       p2.rok,
       (p2.muzi + p2.zeny) AS pocet_obyvatelov_2011,
       ((p2.muzi + p2.zeny) - (p1.muzi + p1.zeny)) AS rozdiel
FROM obec o
INNER JOIN populacia p1
ON o.id = p1.id_obec AND p1.rok IN ('2012')
INNER JOIN populacia p2
ON o.id = p2.id_obec AND p2.rok IN ('2011')
WHERE (p1.muzi + p1.zeny) < (p2.muzi + p2.zeny);

-- 12. Zistite počet obcí, ktorých počet obyvateľov v roku 2012 je nižší,
--     ako bol slovenský priemer v danom roku.

SELECT COUNT(*) FROM obec o
INNER JOIN populacia p
ON o.id = p.id_obec
WHERE p.rok = '2012'AND (p.muzi + p.zeny) < (
    SELECT (SUM(p.muzi + p.zeny)/COUNT(o.nazov)) AS priemerny_pocet_obyvatelov_na_pocet_obci FROM obec o
    INNER JOIN populacia p
    ON o.id = p.id_obec
    WHERE p.rok = '2012'
    );


