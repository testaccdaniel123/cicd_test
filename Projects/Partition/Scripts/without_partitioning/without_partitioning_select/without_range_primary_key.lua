local con = sysbench.sql.driver():connect()

function select_without_range_direct()
    local without_range_direct_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG = '1985-01-01';
    ]];
    con:query(without_range_direct_query)
end

function event()
    select_without_range_direct()
end