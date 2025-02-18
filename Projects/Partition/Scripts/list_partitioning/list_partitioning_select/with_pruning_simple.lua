local con = sysbench.sql.driver():connect()

function select_with_pruning_simple()
    local with_pruning_simple_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN AND k.LAND = b.LAND
        WHERE k.LAND = 'Germany';
    ]];
    con:query(with_pruning_simple_query)
end

function event()
    select_with_pruning_simple()
end