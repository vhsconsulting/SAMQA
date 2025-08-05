-- liquibase formatted sql
-- changeset SAMQA:1754373927954 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_salesrep_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_salesrep_user_name.sql:null:d3212186aca44c9eaef0e62a4541993745d0d5b9:create

create or replace function samqa.get_salesrep_user_name (
    p_salesrep_id in number
) return varchar2 is
    l_user_name varchar2(100);
begin
    for x in (
        select
            a.name,
            b.user_id,
            c.user_name
        from
            salesrep  a,
            employee  b,
            sam_users c
        where
                a.salesrep_id = p_salesrep_id
            and a.emp_id = b.emp_id
            and a.status = 'A'
            and b.user_id = c.user_id (+)
            and c.status (+) = 'A'
    ) loop
        l_user_name := x.user_name;
    end loop;

    return l_user_name;
end get_salesrep_user_name;
/

