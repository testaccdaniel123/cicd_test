function select_query()
    local query_city = "SELECT * FROM KUNDEN WHERE STADT = 'City_7' OR STADT = 'City_10';"
    local query_age = "SELECT NAME, GEBURTSTAG FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';"
    local query_count_city = "SELECT STADT, COUNT(*) AS num_customers FROM KUNDEN GROUP BY STADT;"
    local query_order_name = "SELECT * FROM KUNDEN ORDER BY NAME DESC;"
    local query_by = "SELECT NAME,GEBURTSTAG,STADT AS num_customers FROM KUNDEN GROUP BY NAME,GEBURTSTAG,STADT;"

    db_query(query_city)
    db_query(query_age)
    db_query(query_count_city)
    db_query(query_order_name)
    db_query(query_by)
end

function event()
    select_query()
end