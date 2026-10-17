DO $$
BEGIN
    BEGIN
        DROP FUNCTION IF EXISTS public.my_interpolation_func(NUMERIC) CASCADE;
        DROP TABLE IF EXISTS public.calc_temperature_correction CASCADE;
    END;


    BEGIN
     
        CREATE TABLE public.calc_temperature_correction (
            temperature NUMERIC(8,2),
            correction NUMERIC(8,2)
        );

        INSERT INTO public.calc_temperature_correction(temperature, correction)
        VALUES
            (0, 0.5),
            (5, 0.5),
            (10, 1),
            (20, 1),
            (25, 2),
            (30, 3.5),
            (40, 4.5);
    END;

    -- 3. Создание первой функции
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.my_interpolation_func(p_target_temp NUMERIC)
        RETURNS public."interType" AS $body$
        DECLARE
            var_result public."interType";
        BEGIN
            SELECT temperature, correction
            INTO var_result.x0, var_result.y0
            FROM public.calc_temperature_correction
            WHERE temperature <= p_target_temp
            ORDER BY temperature DESC
            LIMIT 1;

            SELECT temperature, correction
            INTO var_result.x1, var_result.y1
            FROM public.calc_temperature_correction
            WHERE temperature >= p_target_temp
            ORDER BY temperature ASC
            LIMIT 1;

            IF var_result.x0 IS NULL THEN
                var_result.x0 := var_result.x1;
                var_result.y0 := var_result.y1;
            END IF;

            IF var_result.x1 IS NULL THEN
                var_result.x1 := var_result.x0;
                var_result.y1 := var_result.y0;
            END IF;

            RETURN var_result;
        END;
        $body$ LANGUAGE plpgsql;
    $func$;
	
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.calculate_interpolation(
            p_x NUMERIC,
            p_struct public."interType"
        )
        RETURNS NUMERIC AS $body$
        BEGIN
            IF p_struct.x1 = p_struct.x0 THEN
                RETURN p_struct.y0;
            END IF;

            RETURN p_struct.y0
                + (p_x - p_struct.x0)
                * (p_struct.y1 - p_struct.y0)
                / (p_struct.x1 - p_struct.x0);
        END;
        $body$ LANGUAGE plpgsql;
    $func$;

END;
$$;CREATE OR REPLACE FUNCTION public.my_interpolation_func(p_target_temp NUMERIC)
RETURNS public.interType AS $BODY$
DECLARE 
    var_result public.interType;
BEGIN

    SELECT 
        COALESCE(
            (SELECT MAX(t1.temperature) FROM calc_temperature_correction t1 WHERE t1.temperature <= p.target_temp),
            (SELECT MIN(t2.temperature) FROM calc_temperature_correction t2)
        ) AS x0,

        COALESCE(
            (SELECT t3.correction FROM calc_temperature_correction t3 
             WHERE t3.temperature = (SELECT MAX(t1.temperature) FROM calc_temperature_correction t1 WHERE t1.temperature <= p.target_temp)),
            (SELECT t4.correction FROM calc_temperature_correction t4 
             WHERE t4.temperature = (SELECT MIN(t2.temperature) FROM calc_temperature_correction t2))
        ) AS y0,

        COALESCE(
            (SELECT MIN(t1.temperature) FROM calc_temperature_correction t1 WHERE t1.temperature >= p.target_temp),
            (SELECT MAX(t2.temperature) FROM calc_temperature_correction t2)
        ) AS x1,

        COALESCE(
            (SELECT t3.correction FROM calc_temperature_correction t3 
             WHERE t3.temperature = (SELECT MIN(t1.temperature) FROM calc_temperature_correction t1 WHERE t1.temperature >= p.target_temp)),
            (SELECT t4.correction FROM calc_temperature_correction t4 
             WHERE t4.temperature = (SELECT MAX(t2.temperature) FROM calc_temperature_correction t2))
        ) AS y1

    INTO 
        var_result.x0,
        var_result.y0,
        var_result.x1,
        var_result.y1

    FROM (
        SELECT p_target_temp AS target_temp
    ) p;

    RETURN var_result; 
END;
$BODY$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION public.my_interpolation_func()
RETURNS public.interType AS $BODY$
DECLARE 
    var_result public.interType;
BEGIN
    
    var_result.x0 := 1;
    var_result.y0 := 1;
    var_result.x1 := 1;
    var_result.y1 := 1;

    RETURN var_result; 
END;
$BODY$ LANGUAGE plpgsql;


