with points as (
    select
        temperature as x0,
        correction  as y0,
        coalesce(lead(temperature) over (), temperature) as x1,
        coalesce(lead(correction)  over (), correction)  as y1
    from calc_temperature_correction
)
select
    row_number() over () as "№",
    points.x0, points.y0, points.x1, points.y1,
    round((points.x0 + points.x1) / 2, 2) as "x",
    public.calculate_interpolation(
        round((points.x0 + points.x1) / 2, 2),
        row(points.x0, points.x1, points.y0, points.y1)::public."interType"
    ) as "y"
from points;
