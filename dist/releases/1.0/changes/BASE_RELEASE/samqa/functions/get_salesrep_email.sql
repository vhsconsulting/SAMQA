-- liquibase formatted sql
-- changeset SAMQA:1754373927935 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_salesrep_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_salesrep_email.sql:null:a43f5d18b85a62db67551eb4abcba40d68909380:create

create or replace function samqa.get_salesrep_email (
    p_salesrep_id in number
) return varchar2 is
    l_email varchar2(100);
begin
    for x in (
        select
            a.name,
            b.user_id,
            c.user_name,
            b.email
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
        l_email := x.email;
    end loop;

    return l_email;
end get_salesrep_email;
/

