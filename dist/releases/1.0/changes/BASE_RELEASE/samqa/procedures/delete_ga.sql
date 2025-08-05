-- liquibase formatted sql
-- changeset SAMQA:1754374143481 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\delete_ga.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/delete_ga.sql:null:44f92cadda08cf30add8e81441da292fad5e96ef:create

create or replace procedure samqa.delete_ga (
    p_ga_lic in varchar2
) as
begin
    for x in (
        select
            ga_id
        from
            general_agent
        where
            ga_lic = p_ga_lic
    ) loop
        if x.ga_id is not null then
            delete from general_agent
            where
                ga_id = x.ga_id;

            delete from online_users
            where
                find_key = p_ga_lic;

            update account
            set
                ga_id = null
            where
                ga_id = x.ga_id;

        end if;
    end loop;
end;
/

