-- liquibase formatted sql
-- changeset SAMQA:1754374142629 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\change_setup_fee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/change_setup_fee.sql:null:2a86e8e1d6846d6f802b9fed273b9b8eace40455:create

create or replace procedure samqa.change_setup_fee as
-- Change setup fee effective 9/1/2011
begin
    for x in (
        select
            acc_id
        from
            account,
            plans
        where
            account.entrp_id is not null
            and account.fee_setup is not null
            and account.account_type = 'HSA'
            and account.plan_code = plans.plan_code
            and account.end_date is null
    ) loop
        update account
        set
            fee_setup =
                case
                    when fee_setup = 28 then
                        15
                    when fee_setup > 28 then
                        25
                    else
                        fee_setup
                end,
            last_update_date = sysdate,
            last_updated_by = 0,
            note = note
                   || chr(10)
                   || 'Changing setup fee from '
                   || fee_setup
                   || ' to '
                   ||
                   case
                       when fee_setup = 28 then
                           15
                       when fee_setup > 28 then
                           25
                       else
                           fee_setup
                   end
                   || to_char(sysdate, 'MM/DD/YYYY hh:mi:ss')
        where
            acc_id = x.acc_id;

    end loop;
end;
/

