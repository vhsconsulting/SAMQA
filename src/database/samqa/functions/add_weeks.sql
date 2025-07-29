create or replace function samqa.add_weeks (
    in_dt     in date,
    num_weeks in integer
) return date is
    out_dt date;
begin
    select
        in_dt + ( num_weeks * 7 )
    into out_dt
    from
        dual;

    return ( out_dt );
end;
/


-- sqlcl_snapshot {"hash":"27911453b38c17b42749f2eff3c9adae3be6db04","type":"FUNCTION","name":"ADD_WEEKS","schemaName":"SAMQA","sxml":""}