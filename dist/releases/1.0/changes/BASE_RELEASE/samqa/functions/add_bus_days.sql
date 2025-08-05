-- liquibase formatted sql
-- changeset SAMQA:1754373926805 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\add_bus_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/add_bus_days.sql:null:d87e883fc7d78629c91f29a333c58c094b7f73bf:create

create or replace function samqa.add_bus_days (
    p_date    in date,
    p_add_num in integer
) return date as
  --
    v_cnt     number;
    v_bus_day date := trunc(p_date);
  --
begin
  --
    select
        max(rnum)
    into v_cnt
    from
        (
            select
                rownum rnum
            from
                all_objects
        )
    where
            rownum <= p_add_num
        and to_char(v_bus_day + rnum, 'DY') not in ( 'SAT', 'SUN' );

    v_bus_day := v_bus_day + v_cnt;
  --
    return v_bus_day;
  --
end add_bus_days;
/

