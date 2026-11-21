-- 1.1 Выгрузка Закупок (Extract)
select 
    so.id as operation_id,
    cast(year(d.period) as varchar) + right('0' + cast(month(d.period) as varchar), 2) as time_code,
    so.productid as product_id,
    so.vendorid as vendor_id,
    so.count as qty,
    so.amount as total_amount
from bm_storageoperations so
inner join bm_journalbarnetdocs d on d.id = so.documentid
where so.count > 0
order by so.id;

select 
    'insert into fact_purchases (operation_id, time_code, product_id, vendor_id, qty, amount) values (' as part1,
    cast(so.id as varchar) + ',' as operation_id,
    cast(year(d.period) as varchar) + right('0' + cast(month(d.period) as varchar), 2) + ',' as time_code,
    cast(so.productid as varchar) + ',' as product_id,
    cast(so.vendorid as varchar) + ',' as vendor_id,
    cast(so.count as varchar) + ',' as qty,
    cast(so.amount as varchar) + ');' as total_amount
from bm_storageoperations so
inner join bm_journalbarnetdocs d on d.id = so.documentid
where so.count > 0
order by so.id;