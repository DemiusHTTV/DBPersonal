do $$
begin 

   RAISE NOTICE 'x = -5, y = %',
        public.calculate_interpolation(-5, public.my_interpolation_func(-5));

    RAISE NOTICE 'x = 12, y = %',
        public.calculate_interpolation(12, public.my_interpolation_func(12));

    RAISE NOTICE 'x = 35, y = %',
        public.calculate_interpolation(35, public.my_interpolation_func(35));

    RAISE NOTICE 'x = 23, y = %',
        public.calculate_interpolation(23, public.my_interpolation_func(23));

    RAISE NOTICE 'x = 25, y = %',
        public.calculate_interpolation(25, public.my_interpolation_func(25));

end;
$$;
