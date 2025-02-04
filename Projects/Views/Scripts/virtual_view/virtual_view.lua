local con = sysbench.sql.driver():connect()
function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255),
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (
            BESTELLUNG_ID INT AUTO_INCREMENT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            UMSATZ       INT,
            FK_KUNDEN    INT NOT NULL,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID) ON DELETE CASCADE
        );
    ]]

    local create_view_query = [[
        CREATE VIEW KUNDEN_OVERVIEW AS
        SELECT
            EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
            K.LAND AS Land,
            SUM(B.UMSATZ) AS Gesamtumsatz
        FROM KUNDEN K
                 JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
        GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    con:query(create_view_query)
    print("Table 'KUNDEN', Table 'BESTELLUNG' and View 'KUNDEN_OVERVIEW' have been successfully created.")
end

function cleanup()
    local drop_view_query = "DROP VIEW IF EXISTS KUNDEN_OVERVIEW;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNG;"
    con:query(drop_view_query)
    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done.")
end
