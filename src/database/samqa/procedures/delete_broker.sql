create or replace procedure samqa.delete_broker (
    p_broker_lic in varchar2
) as
begin
    for x in (
        select
            broker_id
        from
            broker
        where
            broker_lic = p_broker_lic
    ) loop
        if x.broker_id is not null then
            delete from broker_commission_register
            where
                broker_id = x.broker_id;

            delete from broker_assignments
            where
                broker_id = x.broker_id;

            delete from broker_payments
            where
                broker_id = x.broker_id;

            delete from online_users
            where
                find_key = p_broker_lic;

            update account
            set
                broker_id = 0
            where
                broker_id = x.broker_id;

            delete from broker
            where
                broker_id = x.broker_id;

            delete from person
            where
                pers_id = x.broker_id;

        end if;
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"41e81dc8554b0cc0e78341385cbb366c7f93cc59","type":"PROCEDURE","name":"DELETE_BROKER","schemaName":"SAMQA","sxml":""}