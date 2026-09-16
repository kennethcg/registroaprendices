create table public.aprendiz (
    id int not null,
    nombre1 varchar(20) not null,
    nombre2 varchar(20),
    apellido1 varchar(20) not null,
    apellido2 varchar(20),
    genero char(1) not null,
    fecha_nacimiento date not null,
    celular varchar(10) not null,
    email varchar(50) not null,

    constraint pk_aprendiz
    primary key (id)
);

grant select, insert, update, delete
on public.aprendiz
to authenticated;

alter table public.aprendiz
enable row level security;


create policy "permitir select"
on public.aprendiz
for select
to authenticated
using (true);


create policy "permitir insert"
on public.aprendiz
for insert
to authenticated
with check (true);


create policy "permitir update"
on public.aprendiz
for update
to authenticated
using (true)
with check (true);


create policy "permitir delete"
on public.aprendiz
for delete
to authenticated
using (true);