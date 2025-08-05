-- liquibase formatted sql
-- changeset SAMQA:1754374143423 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\delete_employee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/delete_employee.sql:null:fe96d5e56e9ca6a4caeea3f38d0f4225a1ca4ce7:create

create or replace procedure samqa.delete_employee is
begin
    for x in (
        select
            e.pers_id,
            e.ssn,
            a.acc_id
        from
            person         e,
            account        a,
            g_acc_num_list g
        where
                e.pers_id = a.pers_id
            and g.acc_num = a.acc_num
    ) loop
        if x.pers_id is not null then
            delete from insure
            where
                pers_id = x.pers_id;

            delete from claimn
            where
                pers_id = x.pers_id;

            delete from card_debit
            where
                card_id = x.pers_id;

            delete from income
            where
                acc_id = x.acc_id;

            delete from payment
            where
                acc_id = x.acc_id;

            delete from ben_plan_enrollment_setup
            where
                acc_id = x.acc_id;

            delete from online_users
            where
                tax_id = replace(x.ssn, '-');

            delete from account
            where
                pers_id = x.pers_id;

            delete from debit_card_updates
            where
                pers_id = x.pers_id;

            delete from person
            where
                pers_id = x.pers_id;

        end if;
    end loop;
end;
/

