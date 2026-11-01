do $$
begin 
	begin
		drop table if exists standard_heights;
		drop table if exists avg_wind_speeds ;
	end;

	begin 	
		create table standard_heights (
			height integer not null
		);
		create table avg_wind_speeds (
    		equipment_type_id integer      not null,
    		height            integer      not null,
    		input_value       numeric(5,1) not null,
    		wind_speed        numeric(5,1) not null
		);
	end;

	begin 
		insert into avg_wind_speeds (equipment_type_id, height, input_value, wind_speed) values
    (1, 200,  3,  4),
    (1, 200,  4,  6),
    (1, 200,  5,  8),
    (1, 200,  6,  9),
    (1, 400,  3,  5),
    (1, 400,  4,  7);
	end;

	begin
	insert into standard_heights (height) values
    (200), (400), (800), (1200), (1600), (2000), (2400), (3000), (4000);
	end;
	
  begin
        alter table standard_heights
            add constraint pk_standard_heights primary key (height);

        alter table avg_wind_speeds
            add constraint pk_avg_wind_speeds
                primary key (equipment_type_id, height, input_value),
            add constraint fk_avg_wind_speeds_height
                foreign key (height) references standard_heights (height),
            add constraint fk_avg_wind_speeds_equipment
                foreign key (equipment_type_id) references equipment_types (id);
    end;
end;
$$;
