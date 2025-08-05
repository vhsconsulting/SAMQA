create or replace function samqa.get_quarter_date (
    p_start_date in date,
    p_in_date    in date
) return date is
begin
  --Checking for the dates quarterly period
    if
        p_start_date is not null
        and p_in_date is not null
    then
        for x in (
            select
                rownum                                   rn,
                add_months(p_start_date, rownum * 3) - 1 period_date
            from
                all_objects
            where
                rownum <= 4
        ) loop
            if p_in_date <= x.period_date then
                return x.period_date;
            end if;
        end loop;

    end if;
end;
/


-- sqlcl_snapshot {"hash":"ce7c3dbccdf2c1520bfdac034af7c392a219b8c2","type":"FUNCTION","name":"GET_QUARTER_DATE","schemaName":"SAMQA","sxml":""}