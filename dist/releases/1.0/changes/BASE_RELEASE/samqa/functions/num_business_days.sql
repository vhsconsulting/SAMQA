-- liquibase formatted sql
-- changeset SAMQA:1754373928183 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\num_business_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/num_business_days.sql:null:a13d6452e99f97265a503e2093090841f8c13b25:create

create or replace function samqa.num_business_days (
    start_date in date,
    end_date   in date
) return number is
    busdays number := 0;
    stdate  date;
    endate  date;
begin

/*   select count(*)
      from ( select rownum rnum
               from all_objects
              where rownum <= to_date('16-MAY-2003') - to_date('14-MAY-2003')+1 )
     where to_char( to_date('14-MAY-2003')+rnum-1, 'DY' )
                      not in ( 'SAT', 'SUN' )
        and       NOT EXISTS ( SELECT NULL FROM HOLIDAYS WHERE HOLIDAYDATE =
                     TRUNC(TO_DATE(NVL('16-MAY-2003',TO_DATE(SYSDATE)))+RNUM-1) ) ;
*/
    stdate := trunc(start_date);
    endate := trunc(end_date);
    if endate >= stdate then
  -- Get the absolute date range
        busdays := endate - stdate
        -- Now subtract the weekends
        --  this statement rounds the range to whole weeks (using
        --  TRUNC and determines the number of days in the range.
        --  then it divides by 7 to get the number of weeks, and
        --  multiplies by 2 to get the number of weekend days.
         - ( ( trunc(endate, 'D') - trunc(stdate, 'D') ) / 7 ) * 2
        -- Add one to make the range inclusive
         + 1;

  /* Adjust for ending date on a saturday */
        if to_char(endate, 'D') = '7' then
            busdays := busdays - 1;
        end if;

  /* Adjust for starting date on a sunday */
        if to_char(stdate, 'D') = '1' then
            busdays := busdays - 1;
        end if;

    else
        busdays := 0;
    end if;

    return ( busdays );
end;
/

