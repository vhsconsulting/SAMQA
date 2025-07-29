create or replace editionable trigger samqa.broker_payments_t1 before
    insert or update on samqa.broker_payments
    for each row
begin
    if inserting then
        :new.creation_date := sysdate;
        :new.created_by := get_user_id(v('APP_USER'));
    end if;

    if updating then
        :new.last_update_date := sysdate;
        :new.last_updated_by := get_user_id(v('APP_USER'));
    end if;

end;
/

alter trigger samqa.broker_payments_t1 enable;


-- sqlcl_snapshot {"hash":"14bea9704f95f70233d988f58e9786a57cc60238","type":"TRIGGER","name":"BROKER_PAYMENTS_T1","schemaName":"SAMQA","sxml":""}